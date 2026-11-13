import '../../kit/buttons.dart';
import 'order_route_data.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/hold_store.dart';
import '../../backend/member_flow.dart' show money2;
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../widgets/common.dart' show Rings;
import '../../resources/merchant_svgs.dart';
import '../../routes.dart' show openRoute;

// ───────── 挂单列表 ─────────

/// 列表里一张卡片要显示的内容（来自真实挂单接口）。
class _HoldCard {
  final String? id;
  final Map<String, dynamic>? row;
  final String initial, name, level, plate, status, items, amount, meta, note;
  final bool plateGreen;
  final bool ready; // 待结算：主按钮为蓝色，次按钮为“提醒取车”
  const _HoldCard({
    this.id,
    this.row,
    required this.initial,
    required this.name,
    required this.level,
    required this.plate,
    this.plateGreen = false,
    required this.status,
    required this.items,
    required this.amount,
    required this.meta,
    this.note = '',
    this.ready = false,
  });
}

String _clock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// `14:02 挂单` / `昨天 16:20 挂单` / `10月30日 09:10 挂单`
String holdTimeText(DateTime at, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final t = at.toLocal();
  final today = DateTime(n.year, n.month, n.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  final prefix = diff <= 0
      ? ''
      : diff == 1
      ? '昨天 '
      : '${t.month}月${t.day}日 ';
  return '$prefix${_clock(t)} 挂单';
}

_HoldCard _cardOf(Map<String, dynamic> h) {
  final member = Map<String, dynamic>.from((h['member'] as Map?) ?? const {});
  final card = Map<String, dynamic>.from((member['card'] as Map?) ?? const {});
  final walkIn = h['member_id'] == null && member.isEmpty;
  final name = walkIn ? '散客' : '${member['name'] ?? ''}';
  final items =
      List<Map<String, dynamic>>.from((h['items'] as List?) ?? const [])..sort(
        (a, b) => ((a['position'] ?? 0) as num).compareTo(
          (b['position'] ?? 0) as num,
        ),
      );
  final plate = '${h['vehicle_plate'] ?? ''}';
  final created = DateTime.tryParse('${h['created_at'] ?? ''}');
  return _HoldCard(
    id: '${h['id']}',
    row: h,
    initial: walkIn || name.isEmpty ? '客' : name.substring(0, 1),
    name: name,
    level: walkIn ? '非会员' : '${card['name'] ?? ''}',
    plate: HoldStore.plateOf(h),
    // 新能源车牌（8 位）用绿牌样式
    plateGreen: plate.length >= 8,
    status: '${h['status']}',
    items: items.map((e) => '${e['name']}').join(' · '),
    amount: '¥${money2(HoldStore.estimateOf(h))}',
    // TODO: 技师、工位、预计完工要等员工 / 工位模块接入后再显示，目前只显示挂单时间。
    meta: created == null ? '' : holdTimeText(created),
    note: '${h['note'] ?? ''}',
    ready: h['status'] == '待结算',
  );
}

const _shadowLight = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 1),
  BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
  BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
];
const _shadowTab = [
  BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
  BoxShadow(color: Color(0x0A000000), offset: Offset(0, 2), blurRadius: 4),
];
const _shadowDark = [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)];

/// 挂单列表的布局与交互；编辑目标通过 OrderRouteData 传递。
class HoldBoard extends StatefulWidget {
  const HoldBoard({super.key});
  @override
  State<HoldBoard> createState() => _HoldBoardState();
}

class _HoldBoardState extends State<HoldBoard> {
  final contentKey = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  int tab = 0;
  bool refreshPending = false;
  final Set<String> _removing = {};
  @override
  void initState() {
    super.initState();
    HoldStore.invalidated.addListener(_changed);
  }

  void _changed() {
    if (!mounted || !merchantApi.hasSession) return;
    if (contentKey.currentState?.busy == true) {
      refreshPending = true;
    } else {
      contentKey.currentState?.reload();
    }
  }

  @override
  void dispose() {
    HoldStore.invalidated.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return ErrorView(
        error: const AppError('请先登录', type: AppErrorType.auth),
        onNext: () => openRoute(context, 'Login'),
      );
    }
    return AsyncView<List<Map<String, dynamic>>>(
      key: contentKey,
      shrinkWrap: true,
      inlineError: true,
      skeletonScrollable: false,
      pullToRefresh: false,
      load: () async {
        while (true) {
          refreshPending = false;
          try {
            final rows = await merchantApi.holds();
            if (!mounted || !refreshPending) return rows;
          } catch (_) {
            if (!mounted || !refreshPending) rethrow;
          }
        }
      },
      onLoaded: (rows) {
        if (refreshPending) {
          contentKey.currentState?.reload();
          return;
        }
        HoldStore.recordRead(rows);
      },
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 3),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, rows) =>
          _content(context, [for (final h in rows) _cardOf(h)], _stats(rows)),
    );
  }

  ({String total, int count, List<String> tabs, String? alert}) _stats(
    List<Map<String, dynamic>> rows,
  ) {
    final waiting = rows.where((h) {
      final at = DateTime.tryParse('${h['updated_at']}');
      return h['status'] == '待结算' &&
          at != null &&
          DateTime.now().difference(at).inMinutes >= 20;
    }).length;
    return (
      total:
          '¥${money2(rows.fold<num>(0, (sum, h) => sum + HoldStore.estimateOf(h)))}',
      count: rows.length,
      tabs: [
        '全部 ${rows.length}',
        for (final status in HoldStore.statuses)
          '$status ${rows.where((h) => h['status'] == status).length}',
      ],
      alert: waiting > 0 ? '$waiting 单已完工，等待超 20 分钟' : null,
    );
  }

  Widget _content(
    BuildContext context,
    List<_HoldCard> all,
    ({String total, int count, List<String> tabs, String? alert}) s,
  ) {
    final cards = tab == 0
        ? all
        : all.where((c) => c.status == HoldStore.statuses[tab - 1]).toList();
    return hcol([
      _summary(context, s),
      _tabs(context, s.tabs, tab),
      if (all.isEmpty)
        const EmptyView.firstTime(
          title: '暂无挂单',
          message: '在开单页点“挂单”，可以先把这一单存下来',
        )
      else if (cards.isEmpty)
        EmptyView.filtered(onAction: () => setState(() => tab = 0))
      else
        for (final c in cards) _card(context, c),
    ], gap: 16);
  }

  // ── 概况卡片 ──
  Widget _summary(
    BuildContext context,
    ({String total, int count, List<String> tabs, String? alert}) s,
  ) {
    final muted = dk(context, const Color(0xFFA1A1AA), const Color(0xFF80808A));
    return hbox(
      bg: dk(context, const Color(0xFF18181B), const Color(0xFF1F1F23)),
      radius: BorderRadius.circular(28),
      pad: const EdgeInsets.all(20),
      clip: true,
      border: dk<Border?>(
        context,
        null,
        Border.all(color: const Color(0xFF2E2E33)),
      ),
      child: hstack(
        hcol([
          hcol([
            Text('挂单待收款', style: hts(13, muted, lh: 18)),
            hrow(
              [
                Flexible(
                  flex: 200,
                  child: Text(
                    s.total,
                    style: hts(
                      36,
                      const Color(0xFFFAFAFA),
                      w: FontWeight.w600,
                      lh: 44,
                      tab: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 45,
                  child: Text('共 ${s.count} 单', style: hts(14, muted)),
                ),
              ],
              cross: CrossAxisAlignment.baseline,
              gap: 8,
            ),
          ], gap: 4),
          if (s.alert != null)
            hbox(
              bg: const Color(0xFF27272A),
              radius: BorderRadius.circular(18),
              pad: const EdgeInsets.fromLTRB(14, 10, 10, 10),
              child: hrow(
                [
                  hsvg(Svgs.s162, w: 18, h: 18),
                  Expanded(
                    child: hbox(
                      minW: 0,
                      child: Text(
                        s.alert!,
                        style: hts(13, const Color(0xFFF5D78E), lh: 18),
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  AppButton(
                    label: '提醒取车',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.small,
                    expanded: false,
                    onPressed: () => _remind(context),
                  ),
                ],
                cross: CrossAxisAlignment.center,
                gap: 10,
              ),
            ),
        ], gap: 14),
        const [],
        behind: [
          // 设计稿 top -90 / right -90，容器内边距 20
          const Positioned(
            top: -110,
            right: -110,
            child: Rings(size: 240, viewBox: 240, radii: [60, 90, 118]),
          ),
        ],
      ),
    );
  }

  // TODO: 提醒取车要给会员发微信 / 短信通知，依赖微信与消息模块，
  // 预期接口：merchant-v1 orders/hold_remind（按挂单 ID 发送取车提醒），目前不假装已发送。
  void _remind(BuildContext context) =>
      hToast(context, '提醒取车暂未接通（依赖微信 / 消息通知模块）');

  // ── 状态页签 ──
  Widget _tabs(BuildContext context, List<String> labels, int tab) {
    return hbox(
      bg: dk(context, const Color(0xFFE9E9EB), const Color(0xFF1F1F23)),
      radius: BorderRadius.circular(20),
      pad: const EdgeInsets.all(4),
      child: hrow([
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => this.tab = i),
              child: hbox(
                h: 32,
                bg: i == tab
                    ? dk(
                        context,
                        const Color(0xFFFFFFFF),
                        const Color(0xFF18181B),
                      )
                    : null,
                radius: BorderRadius.circular(16),
                shadow: i == tab
                    ? dk<List<BoxShadow>>(context, _shadowTab, _shadowDark)
                    : null,
                child: Align(
                  child: Text(
                    labels[i],
                    style: hts(
                      13,
                      i == tab
                          ? dk(
                              context,
                              const Color(0xFF18181B),
                              const Color(0xFFFAFAFA),
                            )
                          : dk(
                              context,
                              const Color(0xFF52525B),
                              const Color(0xFFA8A8B3),
                            ),
                      w: FontWeight.w500,
                      lh: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ], gap: 2),
    );
  }

  // ── 挂单卡片 ──
  Widget _card(BuildContext context, _HoldCard c) {
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    final removing = c.id != null && _removing.contains(c.id);
    return hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: BorderRadius.circular(24),
      shadow: dk<List<BoxShadow>>(context, _shadowLight, _shadowDark),
      pad: const EdgeInsets.all(16),
      child: hcol([
        hrow(
          [
            _avatar(context, c),
            Expanded(
              child: hbox(
                minW: 0,
                child: hcol([
                  hrow(
                    [
                      Flexible(
                        flex: 45,
                        child: Text(
                          c.name,
                          style: hts(15, ink, w: FontWeight.w600, lh: 22),
                        ),
                      ),
                      if (c.level.isNotEmpty)
                        Flexible(flex: 38, child: _levelPill(context, c.level)),
                    ],
                    cross: CrossAxisAlignment.center,
                    gap: 6,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: hbox(
                      bg: c.plateGreen
                          ? const Color(0xFFD7F5E1)
                          : const Color(0xFF0B5FD6),
                      radius: BorderRadius.circular(4),
                      border: Border.all(
                        color: c.plateGreen
                            ? const Color(0xFF86D9A4)
                            : const Color(0xFF5B9BF0),
                        width: 1.5,
                      ),
                      pad: const EdgeInsets.fromLTRB(5, 1, 5, 1),
                      child: Text(
                        c.plate,
                        style: hts(
                          11,
                          c.plateGreen
                              ? const Color(0xFF14532D)
                              : const Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 16,
                        ),
                      ),
                    ),
                  ),
                ], gap: 3),
              ),
            ),
            _statusPill(context, c.status),
          ],
          cross: CrossAxisAlignment.center,
          gap: 10,
        ),
        hrow(
          [
            Expanded(
              child: Text(
                c.items,
                style: hts(
                  14,
                  dk(context, const Color(0xFF3F3F46), const Color(0xFFD4D4D8)),
                  lh: 20,
                ),
              ),
            ),
            Text(
              c.amount,
              style: hts(20, ink, w: FontWeight.w600, lh: 26, tab: true),
            ),
          ],
          cross: CrossAxisAlignment.end,
          gap: 12,
        ),
        if (c.meta.isNotEmpty)
          hrow(
            [
              hsvg(dk(context, Svgs.s163, Svgs.s164), w: 14, h: 14),
              Flexible(
                flex: 261,
                child: Text(c.meta, style: hts(12, muted, lh: 16)),
              ),
            ],
            cross: CrossAxisAlignment.center,
            gap: 6,
          ),
        if (c.note.isNotEmpty)
          hbox(
            bg: dk(
              context,
              const Color(0xFFFDF8EC),
              const Color.fromRGBO(245, 165, 36, 0.1),
            ),
            radius: BorderRadius.circular(12),
            pad: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Text(
              '备注：${c.note}',
              style: hts(
                12,
                dk(context, const Color(0xFF855F2E), const Color(0xFFF0C46A)),
                lh: 18,
              ),
            ),
          ),
        hrow(
          [
            Expanded(
              child: UnconstrainedBox(
                alignment: Alignment.topLeft,
                constrainedAxis: Axis.horizontal,
                child: AppButton(
                  label: '取单结算',
                  kind: AppButtonKind.primary,
                  size: AppButtonSize.medium,
                  expanded: false,
                  onPressed: () => _takeOut(context, c),
                ),
              ),
            ),
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.horizontal,
              child: AppButton(
                label: c.ready ? '提醒取车' : '加项',
                kind: AppButtonKind.secondary,
                size: AppButtonSize.medium,
                expanded: false,
                onPressed: c.ready
                    ? () => _remind(context)
                    : () => _takeOut(context, c),
              ),
            ),
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.horizontal,
              child: AppIconButton(
                svg: dk(context, Svgs.s165, Svgs.s166),
                semanticLabel: '删除挂单',
                loading: removing,
                onPressed: removing ? null : () => _remove(context, c),
              ),
            ),
          ],
          cross: CrossAxisAlignment.stretch,
          gap: 8,
          intrinsic: true,
        ),
      ], gap: 12),
    );
  }

  Widget _avatar(BuildContext context, _HoldCard c) {
    final (bg, fg) = switch (c.level) {
      '黑金' => (
        dk(context, const Color(0xFF18181B), const Color(0xFF34343A)),
        const Color(0xFFF5D78E),
      ),
      '金卡' => (const Color(0xFFF3E2B3), const Color(0xFF3D2B0E)),
      '非会员' || '' => (
        dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A)),
        dk(context, const Color(0xFF3F3F46), const Color(0xFFD4D4D8)),
      ),
      _ => (
        dk(
          context,
          const Color(0xFFE1F0FE),
          const Color.fromRGBO(4, 133, 247, 0.18),
        ),
        dk(context, const Color(0xFF1E63AE), const Color(0xFF6AB4FA)),
      ),
    };
    return hbox(
      w: 40,
      h: 40,
      bg: bg,
      radius: BorderRadius.circular(20),
      align: Alignment.center,
      child: Text(c.initial, style: hts(16, fg, w: FontWeight.w600)),
    );
  }

  Widget _levelPill(BuildContext context, String level) {
    final (bg, fg) = switch (level) {
      '黑金' => (
        dk(context, const Color(0xFF18181B), const Color(0xFF34343A)),
        const Color(0xFFF5D78E),
      ),
      '金卡' => (
        const Color(0xFFF5D78E),
        dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
      ),
      _ => (
        dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A)),
        dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
      ),
    };
    return hbox(
      bg: bg,
      radius: BorderRadius.circular(9),
      pad: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(level, style: hts(11, fg, w: FontWeight.w600, lh: 18)),
    );
  }

  Widget _statusPill(BuildContext context, String status) {
    final (bg, fg) = switch (status) {
      '施工中' => (
        dk(
          context,
          const Color(0xFFE1F0FE),
          const Color.fromRGBO(4, 133, 247, 0.18),
        ),
        dk(context, const Color(0xFF1E63AE), const Color(0xFF6AB4FA)),
      ),
      '待结算' => (
        dk(
          context,
          const Color(0xFFFDEFD6),
          const Color.fromRGBO(245, 165, 36, 0.16),
        ),
        dk(context, const Color(0xFF855F2E), const Color(0xFFF0C46A)),
      ),
      _ => (
        dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A)),
        dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
      ),
    };
    return hbox(
      bg: bg,
      radius: BorderRadius.circular(9),
      pad: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(status, style: hts(11, fg, w: FontWeight.w600, lh: 18)),
    );
  }

  // ── 动作 ──
  void _takeOut(BuildContext context, _HoldCard c) {
    if (c.row != null) {
      openRoute(context, 'Order', arguments: OrderRouteData(hold: c.row));
    }
  }

  Future<void> _remove(BuildContext context, _HoldCard c) async {
    if (c.id == null) return;
    final requestId = MerchantApi.newRequestId();
    final confirmed = await hConfirm(
      context,
      '确认删除？',
      ok: '删除',
      message: '删除后这张挂单无法恢复',
      onConfirm: () async {
        if (mounted) setState(() => _removing.add(c.id!));
        try {
          await merchantApi.cancelHold(c.id!, requestId: requestId);
          HoldStore.recordRemoved(c.id!);
        } finally {
          if (mounted) setState(() => _removing.remove(c.id));
        }
      },
    );
    if (confirmed && context.mounted) {
      AppToast.show(context, '已删除挂单', kind: ToastKind.success);
    }
  }
}
