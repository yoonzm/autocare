import 'dart:math';

import 'package:flutter/foundation.dart' show ValueNotifier, visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../kit/async_kit.dart';
import 'store_profile.dart';

export '../kit/async_kit.dart' show AppError, AppErrorType;

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://wghsytekrmpcofpugyua.supabase.co',
);
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_tc78tqPIqF7dPAkA5oRiMg_KlE4UT2y',
);

/// 登录态失效（刷新令牌也失败）时 +1，App 根据它回到登录页。
final ValueNotifier<int> authExpired = ValueNotifier(0);

/// Only calls the V1 cloud function. Business tables are never written here.
/// [MerchantApi.members] 的结果。
class MemberPage {
  final List<Map<String, dynamic>> items;
  final Map<String, int> counts;
  final int total;
  final int matched;
  final num totalBalance;
  final int newThisMonth;
  const MemberPage({
    required this.items,
    this.counts = const {},
    this.total = 0,
    int? matched,
    this.totalBalance = 0,
    this.newThisMonth = 0,
  }) : matched = matched ?? items.length;
}

class MerchantApi {
  SupabaseClient get client => Supabase.instance.client;

  bool get hasSession {
    try {
      return client.auth.currentSession != null;
    } catch (_) {
      return false; // Widget tests may construct the app without main().
    }
  }

  /// 不需要登录态的动作：401 是业务失败（如密码错误），不能当成登录失效。
  static const _publicActions = {
    'send_mock_code',
    'check_code',
    'holds',
    'hold_get',
    'register',
    'login_password',
    'login_code',
  };

  /// 只读、可重复的请求：失败时静默重试 1 次；写请求不自动重试。
  static const _readActions = {
    'list',
    'get',
    'get_store',
    'check_code',
    'reminders',
  };

  static final _rand = Random.secure();

  /// 写请求的幂等标识（X-Request-Id）。TODO: 服务端按它去重，目前只下发。
  static String newRequestId() {
    final b = List<int>.generate(16, (_) => _rand.nextInt(256));
    return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = kRequestTimeout,
  }) async {
    final action = body['action']?.toString() ?? '';
    final isRead = _readActions.contains(action);
    // 同一次点击的重试沿用同一个标识
    final requestId = isRead ? null : newRequestId();
    try {
      return await performRequest(body, timeout, requestId);
    } on AppError catch (e) {
      if (e.type == AppErrorType.auth && !_publicActions.contains(action)) {
        // 401：先静默刷新令牌；仍失败才判定登录失效
        try {
          await refreshAuth();
          return await performRequest(body, timeout, requestId);
        } catch (_) {
          authExpired.value++;
          throw const AppError('登录已过期，请重新登录', type: AppErrorType.auth);
        }
      }
      if (isRead && e.retryable) {
        await Future<void>.delayed(const Duration(seconds: 1));
        return performRequest(body, timeout, requestId);
      }
      rethrow;
    }
  }

  /// 静默刷新令牌（401 时调用）。
  @visibleForTesting
  Future<void> refreshAuth() async {
    await client.auth.refreshSession();
  }

  /// 发出一次请求，失败统一抛 [AppError]（不含重试 / 刷新令牌逻辑）。
  @visibleForTesting
  Future<Map<String, dynamic>> performRequest(
    Map<String, dynamic> body,
    Duration timeout,
    String? requestId,
  ) async {
    try {
      final response = await client.functions
          .invoke(
            'merchant-v1',
            body: body,
            headers: {'X-Request-Id': ?requestId},
          )
          .timeout(timeout);
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (response.status < 200 ||
          response.status >= 300 ||
          data['error'] != null) {
        throw AppError.fromStatus(response.status, data['error']?.toString());
      }
      return data;
    } catch (e) {
      throw AppError.from(e);
    }
  }

  Future<String> sendMockCode(String phone) async {
    final data = await invoke({'action': 'send_mock_code', 'phone': phone});
    return data['code'] as String;
  }

  /// Validates the code on the server without consuming it.
  Future<void> checkCode(String phone, String code) async {
    await invoke({'action': 'check_code', 'phone': phone, 'code': code});
  }

  /// 开通门店。返回云函数给新门店初始化的数据量：
  /// `{'services': 服务项目数, 'cards': 会员卡种数}`。
  Future<Map<String, dynamic>> register({
    required String phone,
    required String code,
    required String password,
    required String storeName,
    Map<String, dynamic> profile = const {},
  }) async {
    return invoke({
      'action': 'register',
      'phone': phone,
      'code': code,
      'password': password,
      'store_name': storeName,
      ...profile,
    });
  }

  Future<Map<String, dynamic>> getStore() async {
    final data = await invoke({'action': 'get_store'});
    return Map<String, dynamic>.from(data['store'] as Map);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await invoke({
      'action': 'change_password',
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<void> changePhone({
    required String code,
    required String newPhone,
    required String newCode,
  }) async {
    await invoke({
      'action': 'change_phone',
      'code': code,
      'new_phone': newPhone,
      'new_code': newCode,
    });
  }

  /// Starts the 15-day cooling-off period; the server also ends all sessions.
  Future<void> deleteAccount(String code) async {
    await invoke({'action': 'delete_account', 'code': code});
  }

  /// 忘记密码第 1 步：验证码正确，且该手机号是已开通门店的账号。
  Future<void> forgotVerify(String phone, String code) async {
    await invoke({'action': 'forgot_verify', 'phone': phone, 'code': code});
  }

  /// 忘记密码第 2 步：重置密码；成功后所有设备的登录状态都会失效。
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await invoke({
      'action': 'reset_password',
      'phone': phone,
      'code': code,
      'new_password': newPassword,
    });
  }

  Future<void> loginPassword(String phone, String password) async {
    final data = await invoke({
      'action': 'login_password',
      'phone': phone,
      'password': password,
    });
    await client.auth.setSession(
      data['refresh_token'] as String,
      accessToken: data['access_token'] as String,
    );
  }

  Future<void> loginCode(String phone, String code) async {
    final data = await invoke({
      'action': 'login_code',
      'phone': phone,
      'code': code,
    });
    await client.auth.setSession(
      data['refresh_token'] as String,
      accessToken: data['access_token'] as String,
    );
  }

  Future<void> signOut() async {
    storeProfile.clear();
    await client.auth.signOut();
  }

  /// 退出所有设备：作废这个账号的全部会话。
  Future<void> signOutAll() async {
    storeProfile.clear();
    await client.auth.signOut(scope: SignOutScope.global);
  }

  Future<List<Map<String, dynamic>>> list(String kind) async {
    final data = await invoke({'action': 'list', 'kind': kind});
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  /// 会员卡的通用规则（充值或消费自动升级 / 储值余额可退款）。
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async {
    final data = await invoke({'action': 'rules', 'kind': 'cards'});
    final r = Map<String, dynamic>.from(data['rules'] as Map);
    return (
      autoUpgrade: r['auto_upgrade'] == true,
      balanceRefundable: r['balance_refundable'] == true,
    );
  }

  Future<void> saveCardRules({
    required bool autoUpgrade,
    required bool balanceRefundable,
  }) async {
    await invoke({
      'action': 'save_rules',
      'kind': 'cards',
      'auto_upgrade': autoUpgrade,
      'balance_refundable': balanceRefundable,
    });
  }

  /// 会员列表：可按姓名 / 手机号 / 车牌搜索，按卡种、储值余额、最近到店筛选，分页。
  /// [counts] 是各卡种的会员数、[total] 是会员总数、[totalBalance] 是储值余额合计、
  /// [newThisMonth] 是本月新增（这几项不受搜索和筛选影响）；[matched] 是符合条件的总数。
  Future<MemberPage> members({
    String? query,
    String? cardTypeId,
    List<String>? cardTypeIds,
    num? balanceMin,
    num? balanceMax,
    int? visitedWithinDays,
    int? visitedOverDays,
    int offset = 0,
    int limit = 50,
    bool recent = false,
  }) async {
    final data = await invoke({
      'action': 'list',
      'kind': 'members',
      if (recent) 'sort': 'recent',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      'card_type_id': ?cardTypeId,
      if (cardTypeIds != null && cardTypeIds.isNotEmpty)
        'card_type_ids': cardTypeIds,
      'balance_min': ?balanceMin,
      'balance_max': ?balanceMax,
      'visited_within_days': ?visitedWithinDays,
      'visited_over_days': ?visitedOverDays,
      'offset': offset,
      'limit': limit,
    });
    return MemberPage(
      items: List<Map<String, dynamic>>.from(data['items'] as List),
      counts: {
        for (final e in Map<String, dynamic>.from(
          (data['counts'] as Map?) ?? const {},
        ).entries)
          e.key: (e.value as num).toInt(),
      },
      total: (data['total'] as num?)?.toInt() ?? 0,
      matched: (data['matched'] as num?)?.toInt() ?? 0,
      totalBalance: (data['total_balance'] as num?) ?? 0,
      newThisMonth: (data['new_this_month'] as num?)?.toInt() ?? 0,
    );
  }

  // ───────── 次卡（会员名下） ─────────
  Future<List<Map<String, dynamic>>> memberPackages(String memberId) async {
    final data = await invoke({
      'action': 'list',
      'kind': 'member_packages',
      'member_id': memberId,
    });
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  Future<Map<String, dynamic>> memberPackage(String id) async {
    final data = await invoke({
      'action': 'get',
      'kind': 'member_packages',
      'id': id,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 购买次卡：价格、次数、有效期、限购都由云函数决定；收款方式只是记账。
  Future<Map<String, dynamic>> sellPackage({
    required String memberId,
    required String packageId,
    required String method,
  }) async {
    final data = await invoke({
      'action': 'sell',
      'kind': 'member_packages',
      'member_id': memberId,
      'package_id': packageId,
      'method': method,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> extendPackage({
    required String id,
    required int days,
    required String reason,
  }) async {
    final data = await invoke({
      'action': 'extend',
      'kind': 'member_packages',
      'id': id,
      'days': days,
      'reason': reason,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> refundPackage({
    required String id,
    required String to,
    required String reason,
  }) async {
    final data = await invoke({
      'action': 'refund',
      'kind': 'member_packages',
      'id': id,
      'to': to,
      'reason': reason,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  // ───────── 扫码找会员（车牌识别） ─────────
  /// 车牌识别。目前是开发环境的 mock（云函数不看照片）：约一半概率返回门店里已有的会员，
  /// 否则返回一个库里没有的随机车牌。返回 `matched`、`plate`，匹配时还有 `member`、`package_summary`、`last_visit_text`。
  // TODO: 真实识别要先把照片上传到存储，再按存储路径请求识别服务。
  Future<Map<String, dynamic>> recognizePlate() =>
      invoke({'action': 'recognize_plate', 'kind': 'members'});

  // ───────── 开单收银 ─────────
  /// [lines]: `[{service_id, qty, member_package_id?}]`。价格、折扣、次卡抵扣、扣款都由云函数算。
  Future<Map<String, dynamic>> checkout({
    required String memberId,
    required List<Map<String, dynamic>> lines,
    required String method,
    num? balancePart,
    String? other,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    final data = await invoke({
      'action': 'checkout',
      'kind': 'orders',
      'member_id': memberId,
      'lines': lines,
      'method': method,
      'balance_part': ?balancePart,
      'other': ?other,
      'plate': plate,
      'remark': remark,
      'hold_id': ?holdId,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 散客开单：不记会员、没有折扣和次卡抵扣，只能用微信 / 支付宝 / 现金 / POS 刷卡。
  Future<Map<String, dynamic>> checkoutWalkIn({
    required List<Map<String, dynamic>> lines,
    required String method,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    final data = await invoke({
      'action': 'checkout',
      'kind': 'orders',
      'walk_in': true,
      'hold_id': ?holdId,
      'lines': lines,
      'method': method,
      'plate': plate,
      'remark': remark,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  // ───────── 挂单 ─────────
  /// 待处理的挂单（含明细、会员、云函数按当时价格算的估价 `estimate`）。
  Future<List<Map<String, dynamic>>> holds() async {
    final data = await invoke({'action': 'holds', 'kind': 'orders'});
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  /// 挂起 / 修改一张挂单。[holdId] 为空 = 新挂单，否则整单替换明细。
  Future<Map<String, dynamic>> saveHold({
    String? holdId,

    /// 为空 = 散客挂单（不记会员，没有折扣和次卡）。
    String? memberId,
    required List<Map<String, dynamic>> lines,
    String status = '待施工',
    String note = '',
    String remind = '不提醒',
    String plate = '',
  }) async {
    final data = await invoke({
      'action': 'hold',
      'kind': 'orders',
      'hold_id': ?holdId,
      if (memberId == null) 'walk_in': true else 'member_id': memberId,
      'lines': lines,
      'status': status,
      'note': note,
      'remind': remind,
      'plate': plate,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<void> cancelHold(String id) async {
    await invoke({'action': 'hold_cancel', 'kind': 'orders', 'id': id});
  }

  // ───────── 回访 ─────────
  Future<List<Map<String, dynamic>>> followUps(String memberId) async {
    final data = await invoke({
      'action': 'list',
      'kind': 'follow_ups',
      'member_id': memberId,
    });
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  Future<void> saveFollowUp({
    required String memberId,
    required String method,
    required String result,
    String content = '',
    String? nextAt,
  }) async {
    await invoke({
      'action': 'save',
      'kind': 'follow_ups',
      'member_id': memberId,
      'method': method,
      'result': result,
      'content': content,
      'next_at': ?nextAt,
    });
  }

  Future<void> markFollowedUp(String memberId, {String content = ''}) async {
    await invoke({
      'action': 'mark',
      'kind': 'follow_ups',
      'member_id': memberId,
      'content': content,
    });
  }

  /// 回访提醒：次卡到期 / 生日 / 沉睡客户，今天回访过的不再出现。
  Future<Map<String, dynamic>> reminders() =>
      invoke({'action': 'reminders', 'kind': 'follow_ups'});

  /// 储值充值：赠送金额由云函数按规则算出；返回到账后的余额、赠送、获得积分、是否升级。
  Future<Map<String, dynamic>> recharge({
    required String memberId,
    required num amount,
    required String method,
    String note = '',
  }) async {
    final data = await invoke({
      'action': 'recharge',
      'kind': 'members',
      'id': memberId,
      'amount': amount,
      'method': method,
      'note': note,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 手动调整卡种 / 积分（必须带原因）。
  Future<void> adjustMember({
    required String memberId,
    String? tierId,
    int points = 0,
    required String reason,
    String note = '',
  }) async {
    await invoke({
      'action': 'adjust',
      'kind': 'members',
      'id': memberId,
      'tier_id': ?tierId,
      'points': points,
      'reason': reason,
      'note': note,
    });
  }

  /// 会员的流水（充值、调整、升级），新的在前。
  Future<({List<Map<String, dynamic>> items, int total})> ledger(
    String memberId, {
    String filter = 'all',
    int offset = 0,
    int limit = 30,
  }) async {
    final data = await invoke({
      'action': 'ledger',
      'kind': 'members',
      'id': memberId,
      'filter': filter,
      'offset': offset,
      'limit': limit,
    });
    return (
      items: List<Map<String, dynamic>>.from(data['items'] as List),
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  Future<Map<String, dynamic>> member(String id) async {
    final data = await invoke({'action': 'get', 'kind': 'members', 'id': id});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> save(String kind, Map<String, dynamic> values) =>
      invoke({'action': 'save', 'kind': kind, ...values});

  Future<void> delete(String kind, String id) async {
    await invoke({'action': 'delete', 'kind': kind, 'id': id});
  }
}

MerchantApi merchantApi = MerchantApi();
