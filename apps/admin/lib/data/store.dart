import 'package:flutter/foundation.dart';
import 'package:autocare_async_kit/async_kit.dart';

import 'admin_api.dart';
import 'models.dart';

/// Server-backed state only; failed requests never fall back to sample records.
class Store extends ChangeNotifier {
  Store({AdminApi? api}) : api = api ?? AdminApi();
  final AdminApi api;
  List<Account> accounts = [];
  List<Merchant> merchants = [];
  List<Order> orders = [];
  List<Ticket> tickets = [];
  List<PlanInfo> plans = [];
  Account? me;
  Map<String, dynamic> stats = {};
  List<num> history = List.filled(5, 0);
  List<String> months = [];
  bool loaded = false;
  Future<bool>? _refreshing;
  int _generation = 0;
  bool get isSuper => me?.role == Role.superAdmin;
  num get subsRevenue => stats['subs_revenue'] as num? ?? 0;
  num get addonRevenue => stats['addon_revenue'] as num? ?? 0;
  num get refundTotal => stats['refund_total'] as num? ?? 0;
  num get monthRevenue => subsRevenue + addonRevenue - refundTotal;
  num get mrr => stats['mrr'] as num? ?? 0;
  int get paidCount => stats['paid_count'] as int? ?? 0;
  int get trialCount => stats['trial_count'] as int? ?? 0;
  int get weekNew => stats['week_new'] as int? ?? 0;
  int get weekDelta => stats['week_delta'] as int? ?? 0;
  int get expiring7 => followUps(1).length;
  int get todoTickets => tickets.where((t) => t.status == TStatus.todo).length;
  void reset() {
    _generation++;
    _refreshing = null;
    me = null;
    accounts = [];
    merchants = [];
    orders = [];
    tickets = [];
    plans = [];
    stats = {};
    history = List.filled(5, 0);
    months = [];
    loaded = false;
    notifyListeners();
  }

  Future<String?> checkCredentials(String username, String password) async {
    if (username.trim().isEmpty) return '请输入用户名';
    if (password.isEmpty) return '请输入密码';
    try {
      final data = await api.login(username.trim(), password);
      _generation++;
      _refreshing = null;
      me = Account.fromJson(data['me'] as Map);
      notifyListeners();
      return null;
    } catch (e) {
      return AppError.from(e).message;
    }
  }

  bool needsPasswordChange(String _) => me?.mustChange ?? false;
  Future<void> signOut() async {
    await api.call('logout');
    await api.clearSession();
    reset();
  }

  Future<String?> changePassword(Account a, String next, String again) async {
    if (next != again) return '两次输入的密码不一致';
    try {
      await api.changePassword(next);
      a.mustChange = false;
      notifyListeners();
      return null;
    } catch (e) {
      return AppError.from(e).message;
    }
  }

  Future<bool> restore() async {
    if (!api.hasSession) return false;
    final data = await api.call('me');
    me = Account.fromJson(data['me'] as Map);
    return true;
  }

  Future<bool> refresh() {
    if (_refreshing != null) return _refreshing!;
    final pending = _load();
    _refreshing = pending;
    return pending.whenComplete(() {
      if (identical(_refreshing, pending)) _refreshing = null;
    });
  }

  Future<bool> _load() async {
    final generation = _generation;
    final lists = <String, List<Map>>{
      for (final key in ['merchants', 'orders', 'tickets', 'accounts']) key: [],
    };
    Map<String, dynamic>? first;
    for (var offset = 0; ; offset += 200) {
      final data = await api.call('snapshot', {'offset': offset});
      first ??= data;
      for (final key in lists.keys) {
        lists[key]!.addAll((data[key] as List).cast<Map>());
      }
      if (data['more'] != true) break;
    }
    // Commit only after all pages succeed; a failed refresh retains old data.
    if (generation != _generation) {
      throw const AppError('登录状态已变化，请重新加载', type: AppErrorType.auth);
    }
    refreshError = null;
    me = Account.fromJson(first['me'] as Map);
    stats = Map<String, dynamic>.from(first['stats'] as Map);
    serverNow = DateTime.parse(first['now'] as String).toUtc();
    serverClockReadAt = DateTime.now().toUtc();
    merchants = lists['merchants']!.map(Merchant.fromJson).toList();
    orders = lists['orders']!.map(Order.fromJson).toList();
    tickets = lists['tickets']!.map(Ticket.fromJson).toList();
    accounts = lists['accounts']!.map(Account.fromJson).toList();
    plans = (first['plans'] as List).cast<Map>().map(PlanInfo.fromJson).toList()
      ..sort((a, b) => b.kind.index.compareTo(a.kind.index));
    final series = (stats['history'] as List).cast<Map>();
    months = series.map((e) => e['month'] as String).toList();
    history = series.take(5).map((e) => e['value'] as num).toList();
    loaded = true;
    notifyListeners();
    return true;
  }

  List<Merchant> byStatus(MStatus? s) =>
      s == null ? merchants : merchants.where((m) => m.status == s).toList();
  List<Merchant> followUps(int tab) =>
      merchants
          .where(
            (m) => switch (tab) {
              0 => m.status == MStatus.expired,
              1 => m.status != MStatus.expired && m.daysLeft <= 7,
              _ => m.status != MStatus.expired && m.daysLeft <= 30,
            },
          )
          .toList()
        ..sort((a, b) => a.expiry.compareTo(b.expiry));
  Future<void> _write(String action, Map<String, dynamic> input) async {
    await api.call(action, input);
    // A committed write is not a failed submission when the following read fails.
    try {
      await refresh();
    } catch (e) {
      refreshError = AppError.from(e);
      notifyListeners();
    }
  }

  AppError? refreshError;
  Future<void> addLog(Merchant m, String text) =>
      _write('follow_save', {'id': m.id, 'text': text.trim()});
  Future<String> adjust(Merchant m, int option) async {
    await _write(
      switch (option) {
        0 => 'merchant_extend',
        1 => 'merchant_upgrade',
        _ => 'merchant_pause',
      },
      {'id': m.id, if (option > 1) 'value': !m.paused},
    );
    return option == 0
        ? '已延长 7 天'
        : option == 1
        ? '已升级到专业版'
        : m.paused
        ? '已恢复服务'
        : '已暂停服务';
  }

  Future<String> account(Merchant m, int option) async {
    await _write(
      switch (option) {
        0 => 'merchant_send_code',
        1 => 'merchant_revoke',
        _ => 'merchant_freeze',
      },
      {'id': m.id, if (option > 1) 'value': !m.frozen},
    );
    return option == 0
        ? '验证码已发送'
        : option == 1
        ? '已退出所有设备'
        : m.frozen
        ? '商家账号已解冻'
        : '商家账号已冻结';
  }

  Future<String?> addAccount(
    String name,
    String username,
    String password,
    Role role,
  ) async {
    try {
      await _write('account_create', {
        'name': name,
        'username': username,
        'password': password,
        'role': role.name,
      });
      return null;
    } catch (e) {
      return AppError.from(e).message;
    }
  }

  Future<void> setRole(Account a, Role r) =>
      _write('account_role', {'id': a.id, 'role': r.name});
  Future<void> setEnabled(Account a, bool v) =>
      _write('account_enabled', {'id': a.id, 'value': v});
  Future<String> resetPassword(Account a) async =>
      (await api.call('account_reset', {'id': a.id}))['temporary_password']
          as String;
  Future<String?> refund(Order o, String input) async {
    try {
      await _write('refund', {'id': o.id, 'amount': num.tryParse(input)});
      return null;
    } catch (e) {
      return AppError.from(e).message;
    }
  }

  Future<void> reply(Ticket t, String text) =>
      _write('ticket_reply', {'id': t.id, 'text': text});
  Future<void> resolve(Ticket t) => _write('ticket_resolve', {'id': t.id});
  Future<String?> savePlan(
    PlanInfo p, {
    required String name,
    required String fee,
    required String staff,
    required bool sms,
    required bool export,
    required bool multi,
  }) async {
    try {
      final f = int.tryParse(fee);
      if (f == null) return p.kind == PlanKind.trial ? '请输入试用天数' : '请输入年费';
      await _write('plan_save', {
        'kind': p.kind.name,
        'name': name,
        'fee': p.kind == PlanKind.trial ? f : f * 100,
        'staff': staff,
        'sms': sms,
        'export': export,
        'multi': multi,
      });
      return null;
    } catch (e) {
      return AppError.from(e).message;
    }
  }
}

Store store = Store();
