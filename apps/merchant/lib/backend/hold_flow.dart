import 'dart:async';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import 'catalog_draft.dart';
import 'merchant_api.dart';
import 'member_flow.dart' show plateText;

/// 开单页准备挂起的一单（只有选择，没有价格：估价由云函数按服务端价格算）。
class HoldDraft {
  /// 为空 = 散客挂单。
  final String? memberId;
  final String memberName;
  final String level;

  /// 页面上显示的车牌（`沪A·8K29M` / `未登记车辆`）。
  final String plateLabel;
  final String plate;
  final List<Map<String, dynamic>> lines;

  /// 开单页当前显示的应收（仅用于挂单弹层的展示，真正的估价在云函数）。
  final String payableText;
  final String? holdId;
  const HoldDraft({
    this.memberId,
    required this.memberName,
    required this.level,
    required this.plateLabel,
    required this.plate,
    required this.lines,
    required this.payableText,
    this.holdId,
  });
}

/// 开单页要响应的事件：取单（把挂单内容放回开单页）、清空（挂单后 / 新开一单）、挂单被删除。
class HoldEvent {
  final String kind; // resume | reset | removed
  final Map<String, dynamic>? row;
  final String? id;
  const HoldEvent.resume(this.row) : kind = 'resume', id = null;
  const HoldEvent.reset() : kind = 'reset', row = null, id = null;
  const HoldEvent.removed(this.id) : kind = 'removed', row = null;
}

/// 挂单：把开单页上选好的项目存起来，之后取单结算 / 加项 / 删除。
/// 估价、结算时的价格 / 折扣 / 次卡抵扣 / 扣款都由云函数执行；这里只收集输入、展示结果。
class HoldFlow {
  HoldFlow._();

  static const statuses = ['待施工', '施工中', '待结算'];
  static const reminds = ['不提醒', '30 分钟', '1 小时', '完工时'];

  /// 设计稿默认选中“施工中”“完工时”。
  static const defaultStatus = 1;
  static const defaultRemind = 3;

  /// 待处理的挂单；还没读到时为 null。
  static List<Map<String, dynamic>>? holds;
  static AppError? error;
  static bool loading = false;
  static final tick = ValueNotifier<int>(0);

  /// 列表页签：0 全部 / 1 待施工 / 2 施工中 / 3 待结算。
  static final tab = ValueNotifier<int>(0);

  static HoldDraft? draft;

  static HoldEvent? event;
  static final eventTick = ValueNotifier<int>(0);

  static int get count => holds?.length ?? 0;

  static void reset() {
    holds = null;
    error = null;
    loading = false;
    draft = null;
    event = null;
    tab.value = 0;
    tick.value++;
  }

  static void emit(HoldEvent e) {
    event = e;
    eventTick.value++;
  }

  /// 页面 initState 里请求读取：等这一帧画完再开始，避免构建期间通知监听者。
  static void loadSoon() =>
      WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(load()));

  /// 读取待处理挂单。已有数据时静默刷新，失败只保留旧数据并记下错误。
  static Future<void> load() async {
    if (loading) return;
    loading = true;
    if (holds == null) error = null;
    tick.value++;
    try {
      holds = await merchantApi.holds();
      error = null;
    } catch (e) {
      error = AppError.from(e);
    } finally {
      loading = false;
      tick.value++;
    }
  }

  static Map<String, dynamic>? byId(String id) {
    for (final h in holds ?? const <Map<String, dynamic>>[]) {
      if ('${h['id']}' == id) return h;
    }
    return null;
  }

  // ───────── 挂单保存弹层 ─────────
  /// 开单页点“挂单”：记下这一单，状态 / 备注 / 提醒从上次挂的内容（如果是取回来加项的）或默认值开始。
  static void begin(HoldDraft d) {
    draft = d;
    final old = d.holdId == null ? null : byId(d.holdId!);
    CatalogDraft.begin('hold', {
      'status_index': old == null
          ? defaultStatus
          : statuses.indexOf('${old['status']}').clamp(0, statuses.length - 1),
      'note': old == null ? '' : '${old['note'] ?? ''}',
      'remind_index': old == null
          ? defaultRemind
          : reminds.indexOf('${old['remind']}').clamp(0, reminds.length - 1),
    });
  }

  static Map<String, dynamic> get _fields =>
      CatalogDraft.current?.kind == 'hold'
      ? CatalogDraft.current!.fields
      : const {};

  static int _index(String key, int fallback, int length) {
    final i = int.tryParse('${_fields[key]}') ?? fallback;
    return i.clamp(0, length - 1);
  }

  /// 弹层里选中的车辆状态 / 提醒（给界面和测试看）。
  static int get statusIndex =>
      _index('status_index', defaultStatus, statuses.length);
  static int get remindIndex =>
      _index('remind_index', defaultRemind, reminds.length);

  /// 确认挂单：成功后清空开单页、刷新列表，返回 true 让调用方跳到挂单列表。
  static Future<bool> save(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final d = draft;
    if (d == null) {
      AppToast.showOn(messenger, '请先在开单页选择项目', kind: ToastKind.error);
      return false;
    }
    final note = '${_fields['note'] ?? ''}'.trim();
    if (note.length > 200) {
      AppToast.showOn(messenger, '备注不能超过 200 字', kind: ToastKind.error);
      return false;
    }
    try {
      final row = await merchantApi.saveHold(
        holdId: d.holdId,
        memberId: d.memberId,
        lines: d.lines,
        status: statuses[statusIndex],
        note: note,
        remind: reminds[remindIndex],
        plate: d.plate,
      );
      final list = [...?holds];
      final at = list.indexWhere((e) => '${e['id']}' == '${row['id']}');
      if (at >= 0) {
        list[at] = row;
      } else {
        list.insert(0, row);
      }
      holds = list;
      draft = null;
      tick.value++;
      emit(const HoldEvent.reset());
      AppToast.showOn(messenger, '已挂单', kind: ToastKind.success);
      return true;
    } catch (e) {
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
      return false;
    }
  }

  /// 删除一张挂单（页面已经确认过）。成功后局部移除。
  static Future<bool> remove(BuildContext context, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await merchantApi.cancelHold(id);
      holds = [
        for (final h in holds ?? const <Map<String, dynamic>>[])
          if ('${h['id']}' != id) h,
      ];
      tick.value++;
      emit(HoldEvent.removed(id));
      AppToast.showOn(messenger, '已删除挂单', kind: ToastKind.success);
      return true;
    } catch (e) {
      final err = AppError.from(e);
      AppToast.showOn(messenger, err.message, kind: ToastKind.error);
      // 已被别处处理 / 删除：列表里不再留着它
      if (err.type == AppErrorType.notFound) unawaited(load());
      return false;
    }
  }

  /// 取单结算 / 加项：把挂单内容放回开单页。
  static void takeOut(Map<String, dynamic> row) => emit(HoldEvent.resume(row));

  /// 新开一单：开单页回到空白。
  static void startNew() => emit(const HoldEvent.reset());

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
