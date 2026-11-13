import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/data_snapshot.dart';

/// 订单中心：统一的“营业记录”（消费 / 充值 / 次卡 / 退款）。
/// 汇总口径（实收 = 微信 + 支付宝 + 现金，储值抵扣不计入实收，净收入 = 实收 − 退款）、
/// 退款规则都在云函数 / 数据库里；这里只保存筛选条件、读取并展示结果。
class OrderListController extends ChangeNotifier {
  OrderListController();
  bool _disposed = false;

  static const ranges = ['today', 'yesterday', 'week', 'month', 'custom'];
  static const rangeLabels = ['今日', '昨日', '本周', '本月', '自定义'];
  static const types = ['all', 'consume', 'recharge', 'package', 'refund'];
  static const typeLabels = ['全部', '消费', '充值', '次卡', '退款'];
  static const methods = ['', '微信', '支付宝', '现金', '储值抵扣'];
  static const methodLabels = ['全部', '微信', '支付宝', '现金', '储值抵扣'];
  static const statuses = ['', 'completed', 'refunded'];
  static const statusLabels = ['全部', '已完成', '已退款'];
  static const refundReasons = ['服务问题', '会员不再需要', '录入错误', '其他'];
  static const _weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];

  // ───────── 筛选条件 ─────────
  int rangeIndex = 0;
  DateTimeRange? custom;
  int typeIndex = 0;
  int methodIndex = 0;
  int statusIndex = 0;
  String operator = '';
  String query = '';

  // ───────── 读取结果 ─────────
  List<Map<String, dynamic>>? items;
  Map<String, dynamic> summary = const {};
  List<String> operators = const [];
  bool hasMore = false;
  AppError? error;
  bool loading = false;
  bool loadingMore = false;
  int _gen = 0;
  Timer? _debounce;

  String get range => ranges[rangeIndex];
  bool get filtered =>
      methodIndex != 0 || statusIndex != 0 || operator.isNotEmpty;
  bool get searching => query.isNotEmpty;

  String _day(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> get _params => {
    'range': range,
    if (range == 'custom' && custom != null) ...{
      'from': _day(custom!.start),
      'to': _day(custom!.end),
    },
    'type': types[typeIndex],
    'method': methods[methodIndex],
    'status': statuses[statusIndex],
    'operator': operator,
    'q': query,
  };

  /// 读取第一页。已有数据时保留旧内容（筛选 / 刷新不退回骨架），失败只记下错误。
  Future<void> load({bool withOptions = false}) async {
    if (_disposed) return;
    _debounce?.cancel();
    final gen = ++_gen;
    loadingMore = false;
    loading = true;
    if (items == null) error = null;
    _changed();
    try {
      if (!merchantApi.hasSession) {
        throw const AppError('请先登录', type: AppErrorType.auth);
      }
      final data = await merchantApi.orderCenter('list', {
        ..._params,
        if (withOptions) 'with_options': true,
      });
      if (gen != _gen) return;
      items = [
        for (final e in data['items'] as List)
          dataSnapshot(Map<String, dynamic>.from(e as Map)),
      ];
      summary = Map<String, dynamic>.from(data['summary'] as Map? ?? const {});
      hasMore = data['has_more'] == true;
      if (data['operators'] is List) {
        operators = [for (final o in data['operators'] as List) '$o'];
      }
      error = null;
    } catch (e) {
      if (gen != _gen) return;
      error = AppError.from(e);
    } finally {
      if (gen == _gen) {
        loading = false;
        _changed();
      }
    }
  }

  /// 滚动到底：用最后一条的时间继续读下一页。
  Future<void> loadMore() async {
    if (_disposed ||
        _debounce?.isActive == true ||
        loading ||
        loadingMore ||
        !hasMore ||
        items == null ||
        items!.isEmpty) {
      return;
    }
    loadingMore = true;
    _changed();
    final gen = _gen;
    try {
      if (!merchantApi.hasSession) {
        throw const AppError('请先登录', type: AppErrorType.auth);
      }
      final data = await merchantApi.orderCenter('list', {
        ..._params,
        'before': items!.last['at'],
      });
      if (gen != _gen) return;
      items = [
        ...items!,
        for (final e in data['items'] as List)
          dataSnapshot(Map<String, dynamic>.from(e as Map)),
      ];
      hasMore = data['has_more'] == true;
      error = null;
    } catch (e) {
      if (gen == _gen) error = AppError.from(e);
    } finally {
      if (gen == _gen) {
        loadingMore = false;
        _changed();
      }
    }
  }

  void setRange(int i) {
    if (rangeIndex == i) return;
    _debounce?.cancel();
    rangeIndex = i;
    load();
  }

  void setType(int i) {
    if (typeIndex == i) return;
    _debounce?.cancel();
    typeIndex = i;
    load();
  }

  void setFilter({
    required int method,
    required int status,
    required String operatorName,
  }) {
    methodIndex = method;
    statusIndex = status;
    operator = operatorName;
    load();
  }

  /// 搜索：防抖 300ms，保留已有结果。
  void search(String value) {
    final v = value.trim();
    if (v == query) return;
    if (_disposed) return;
    query = v;
    _gen++;
    loading = false;
    loadingMore = false;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), load);
    _changed();
  }

  // ───────── 展示用的文字 ─────────
  static num num_(Object? v) => v is num ? v : num.tryParse('$v') ?? 0;

  /// ¥1,234 / ¥1,234.50（整数不带小数）；负数写成 -¥432。
  static String money(Object? v) {
    final n = num_(v);
    final neg = n < 0;
    final abs = n.abs();
    final fixed = abs == abs.roundToDouble()
        ? abs.toStringAsFixed(0)
        : abs.toStringAsFixed(2);
    final parts = fixed.split('.');
    final ip = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${neg ? '-' : ''}¥$ip${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  /// 总是两位小数：¥1,422.00（订单详情的大数字）。
  static String money2(Object? v) {
    final n = num_(v);
    final parts = n.abs().toStringAsFixed(2).split('.');
    final ip = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${n < 0 ? '-' : ''}¥$ip.${parts[1]}';
  }

  static DateTime local(Object? iso) =>
      (DateTime.tryParse('$iso') ?? DateTime.now()).toUtc().add(
        const Duration(hours: 8),
      );

  static String hm(Object? iso) {
    final d = local(iso);
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String md(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  static String dayKey(Object? iso) {
    final d = local(iso);
    return '${d.year}-${d.month}-${d.day}';
  }

  /// 日期分组标题：今天 / 昨天 / 11.02 周日。
  static String dayTitle(Object? iso, {DateTime? now}) {
    final d = local(iso);
    final t = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
    final today = DateTime.utc(t.year, t.month, t.day);
    final day = DateTime.utc(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '昨天 ${md(d)}';
    return '${md(d)} ${_weekdays[d.weekday % 7]}';
  }

  /// 汇总卡片标题：今日收款 / 昨日收款 / 本周收款 / 本月收款 / 自定义收款。
  String get summaryTitle => '${rangeLabels[rangeIndex]}收款';

  /// 汇总卡片右侧的日期：今日 / 昨日是 11.03 周二，其他是范围。
  String summaryDate({DateTime? now}) {
    final t = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
    final today = DateTime.utc(t.year, t.month, t.day);
    switch (range) {
      case 'today':
        return '${md(today)} ${_weekdays[today.weekday % 7]}';
      case 'yesterday':
        final y = today.subtract(const Duration(days: 1));
        return '${md(y)} ${_weekdays[y.weekday % 7]}';
      case 'week':
        final s = today.subtract(Duration(days: (today.weekday + 6) % 7));
        return '${md(s)} – ${md(today)}';
      case 'month':
        return '${md(DateTime.utc(today.year, today.month, 1))} – ${md(today)}';
      default:
        final c = custom;
        return c == null ? '' : '${md(c.start)} – ${md(c.end)}';
    }
  }

  String sum(String key) => money(summary[key]);

  /// 日期分组：保持后端的时间倒序，同一天的归在一起，并带当天的实收 / 退款。
  List<OrderDay> groups({DateTime? now}) {
    final out = <OrderDay>[];
    for (final e in items ?? const <Map<String, dynamic>>[]) {
      final key = dayKey(e['at']);
      if (out.isEmpty || out.last.key != key) {
        out.add(OrderDay(key, dayTitle(e['at'], now: now)));
      }
      out.last.rows.add(e);
    }
    return out;
  }

  /// 列表行第二行：12:05 · 储值 + 微信 · 王建国
  static String subtitle(Map<String, dynamic> e) {
    final who = '${e['who'] ?? ''}';
    return '${hm(e['at'])} · ${e['pay_label']}${who.isEmpty ? '' : ' · $who'}';
  }

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _gen++;
    _debounce?.cancel();
    super.dispose();
  }
}

class OrderDay {
  final String key;
  final String title;
  final List<Map<String, dynamic>> rows = [];
  OrderDay(this.key, this.title);

  /// 当天的实收 / 退款（按已读到的行累加真正收进来的钱，储值抵扣不计入；汇总卡片才是整个范围的权威口径）。
  num get received => rows
      .where((e) => e['kind'] != 'refund')
      .fold<num>(0, (s, e) => s + OrderListController.num_(e['cash']));
  num get refunded => rows
      .where((e) => e['kind'] == 'refund')
      .fold<num>(0, (s, e) => s - OrderListController.num_(e['cash']));
}
