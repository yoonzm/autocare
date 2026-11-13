import 'data_snapshot.dart';
import 'store_context.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import 'merchant_api.dart';
import 'member_flow.dart' show plateText;

/// 真实待处理挂单的只读缓存与刷新信号，供首页与数量提示读取。
/// 表单状态归页面；估价、结算与权限由云函数执行。
class HoldStore {
  HoldStore._();

  static const statuses = ['待施工', '施工中', '待结算'];
  static const reminds = ['不提醒', '30 分钟', '1 小时', '完工时'];

  /// 设计稿默认选中“施工中”“完工时”。
  static const defaultStatus = 1;
  static const defaultRemind = 3;

  /// 待处理的挂单；还没读到时为 null。
  static List<Map<String, dynamic>>? _holds;
  static List<Map<String, dynamic>>? get holds => _holds;
  static AppError? error;
  static bool loading = false;
  static int _loadVersion = 0;
  static final tick = ValueNotifier<int>(0);

  /// 写入或会话失效才触发重读；读取完成只更新 tick，避免多个列表互相触发请求。
  static final invalidated = ValueNotifier<int>(0);

  static int get count => holds?.length ?? 0;

  static void reset() {
    _loadVersion++;
    _holds = null;
    error = null;
    loading = false;
    tick.value++;
    invalidated.value++;
  }

  /// 页面 initState 里请求读取：等这一帧画完再开始，避免构建期间通知监听者。
  static void loadSoon() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(load()));

  /// 读取待处理挂单。已有数据时静默刷新，失败只保留旧数据并记下错误。
  static Future<void> load() async {
    if (!merchantApi.hasSession || loading) return;
    final epoch = StoreContext.epoch;
    final version = ++_loadVersion;
    loading = true;
    if (holds == null) error = null;
    tick.value++;
    try {
      final rows = await merchantApi.holds();
      if (version != _loadVersion || epoch != StoreContext.epoch) return;
      _holds = List.unmodifiable(rows.map(dataSnapshot));
      error = null;
    } catch (e) {
      if (version == _loadVersion && epoch == StoreContext.epoch) {
        error = AppError.from(e);
      }
    } finally {
      // Only the request that owns the loading state may finish it. An epoch
      // change discards its result, but must not strand the loading flag.
      if (version == _loadVersion) {
        loading = false;
        tick.value++;
        if (epoch != StoreContext.epoch && merchantApi.hasSession) {
          unawaited(load());
        }
      }
    }
  }

  static Map<String, dynamic>? byId(String id) {
    for (final h in holds ?? const <Map<String, dynamic>>[]) {
      if ('${h['id']}' == id) return h;
    }
    return null;
  }

  static void recordRead(List<Map<String, dynamic>> rows) {
    _loadVersion++;
    loading = false;
    error = null;
    _holds = List.unmodifiable(rows.map(dataSnapshot));
    tick.value++;
  }

  /// 只合并真实写接口返回的记录；表单草稿不进入读取缓存。
  static void recordSaved(Map<String, dynamic> row) {
    _loadVersion++;
    loading = false;
    error = null;
    _holds = List.unmodifiable([
      dataSnapshot(row),
      for (final h in holds ?? const <Map<String, dynamic>>[])
        if (h['id'] != row['id']) h,
    ]);
    tick.value++;
    invalidated.value++;
  }

  static void recordRemoved(String id) {
    _loadVersion++;
    loading = false;
    error = null;
    _holds = List.unmodifiable([
      for (final h in holds ?? const <Map<String, dynamic>>[])
        if (h['id'] != id) h,
    ]);
    tick.value++;
    invalidated.value++;
  }

  // ───────── 列表上的数字 ─────────
  static num estimateOf(Map<String, dynamic> h) =>
      num.tryParse('${h['estimate'] ?? 0}') ?? 0;

  static num get totalEstimate => (holds ?? const <Map<String, dynamic>>[])
      .fold<num>(0, (s, h) => s + estimateOf(h));

  static int countOf(String status) => (holds ?? const <Map<String, dynamic>>[])
      .where((h) => h['status'] == status)
      .length;

  /// 已完工（待结算）超过 [minutes] 分钟还没取单的数量。
  static int waitingOver(int minutes, [DateTime? now]) {
    final at = now ?? DateTime.now();
    return (holds ?? const <Map<String, dynamic>>[]).where((h) {
      if (h['status'] != '待结算') return false;
      final t = DateTime.tryParse('${h['updated_at'] ?? ''}');
      return t != null && at.difference(t).inMinutes >= minutes;
    }).length;
  }

  static String plateOf(Map<String, dynamic> h) {
    final p = '${h['vehicle_plate'] ?? ''}';
    return p.isEmpty ? '未登记车辆' : plateText(p);
  }
}
