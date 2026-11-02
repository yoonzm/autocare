import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/hold_flow.dart';
import '../backend/member_flow.dart' show money2;
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../pages/gen/svgs.dart';
import '../routes.dart' show openRoute;

/// 挂单保存弹层里的文字（来自开单页准备挂起的 [HoldFlow.draft]）。
class HoldView {
  const HoldView();
  HoldDraft get _d => HoldFlow.draft!;
  String get avatar =>
      _d.memberName.isEmpty ? '客' : _d.memberName.substring(0, 1);
  String get name => _d.memberName;
  String get plate => _d.plateLabel;
  String get countText => '${_d.lines.length} 项服务';
  String get payableText => '¥${_d.payableText}';
}

Widget hHoldText(
  String Function(HoldView h) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ListenableBuilder(
  listenable: HoldFlow.tick,
  builder: (_, _) => Text(
    merchantApi.hasSession && HoldFlow.draft != null
        ? text(const HoldView())
        : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

// ───────── 挂单列表 ─────────

/// 列表里一张卡片要显示的内容（登录后来自后端的挂单，设计预览时是设计稿的示例）。
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

const _samples = [
  _HoldCard(
    initial: '王',
    name: '王建国',
    level: '黑金',
    plate: '沪A·8K29M',
    status: '施工中',
    items: '镀晶养护 · 内饰精洗',
    amount: '¥1,422.00',
    meta: '老周 · 3 号工位 · 14:02 挂单 · 预计 17:00 完工',
    note: '客户去开会，17:00 取车',
  ),
  _HoldCard(
    initial: '赵',
    name: '赵先生',
    level: '金卡',
    plate: '沪AD·61207',
    plateGreen: true,
    status: '施工中',
    items: '全车隐形车衣',
    amount: '¥18,800.00',
    meta: '张师傅 · 贴膜间 · 预计 明天 18:00 · 昨天 16:20 挂单',
  ),
  _HoldCard(
    initial: '李',
    name: '李女士',
    level: '金卡',
    plate: '沪B·2C519',
    status: '待结算',
    items: '全车精洗 · 打蜡',
    amount: '¥880.00',
    meta: '小陈 · 已完工，等待 25 分钟 · 14:16 挂单',
    ready: true,
  ),
  _HoldCard(
    initial: '客',
    name: '散客',
    level: '非会员',
    plate: '苏K·5F218',
    status: '待施工',
    items: '基础洗车 · 轮毂清洁',
    amount: '¥98.00',
    meta: '预约 15:30 到店 · 13:40 挂单',
  ),
];

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
  final name = '${member['name'] ?? ''}';
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
    initial: name.isEmpty ? '客' : name.substring(0, 1),
    name: name,
    level: '${card['name'] ?? ''}',
    plate: HoldFlow.plateOf(h),
    // 新能源车牌（8 位）用绿牌样式
    plateGreen: plate.length >= 8,
    status: '${h['status']}',
    items: items.map((e) => '${e['name']}').join(' · '),
    amount: '¥${money2(HoldFlow.estimateOf(h))}',
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

/// 挂单概况 + 状态页签 + 挂单卡片。
Widget hHoldBoard() => const _HoldBoard();

class _HoldBoard extends StatefulWidget {
  const _HoldBoard();
  @override
  State<_HoldBoard> createState() => _HoldBoardState();
}

class _HoldBoardState extends State<_HoldBoard> {
  Timer? _timer;
  bool _slow = false;
  bool _wasLoading = false;
  final Set<String> _removing = {};

  @override
  void initState() {
    super.initState();
    HoldFlow.tab.value = 0;
    HoldFlow.tick.addListener(_onTick);
    if (merchantApi.hasSession) HoldFlow.loadSoon();
  }

  @override
  void dispose() {
    _timer?.cancel();
    HoldFlow.tick.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;
    final loading = HoldFlow.loading;
    if (loading && !_wasLoading && HoldFlow.holds == null) {
      // 300ms 内什么都不显示，之后才出骨架
      _slow = false;
      _timer?.cancel();
      _timer = Timer(kIndicatorDelay, () {
        if (mounted && HoldFlow.loading) setState(() => _slow = true);
      });
    }
    final failedWithData =
        _wasLoading &&
        !loading &&
        HoldFlow.error != null &&
        HoldFlow.holds != null;
    _wasLoading = loading;
    if (failedWithData) {
      final err = HoldFlow.error!;
      AppToast.show(
        context,
        err.message,
        kind: ToastKind.error,
        actionLabel: err.retryable ? '重试' : null,
        onAction: err.retryable ? () => unawaited(HoldFlow.load()) : null,
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return _content(context, _samples, _sampleStats);
    }
    final holds = HoldFlow.holds;
    if (holds == null) {
      if (HoldFlow.error != null) {
        return SizedBox(
          height: 420,
          child: ErrorView(
            error: HoldFlow.error!,
            retrying: HoldFlow.loading,
            onRetry: () => unawaited(HoldFlow.load()),
          ),
        );
      }
      return _slow ? const SkeletonList(count: 3) : const SizedBox(height: 240);
    }
    return _content(context, [for (final h in holds) _cardOf(h)], _liveStats());
  }

  static const _sampleStats = (
    total: '¥21,200.00',
    count: 4,
    tabs: ['全部 4', '待施工 1', '施工中 2', '待结算 1'],
    alert: '1 单已完工，等待超 20 分钟',
  );

  ({String total, int count, List<String> tabs, String? alert}) _liveStats() {
    final waiting = HoldFlow.waitingOver(20);
    return (
      total: '¥${money2(HoldFlow.totalEstimate)}',
      count: HoldFlow.count,
      tabs: [
        '全部 ${HoldFlow.count}',
        for (final s in HoldFlow.statuses) '$s ${HoldFlow.countOf(s)}',
      ],
      alert: waiting > 0 ? '$waiting 单已完工，等待超 20 分钟' : null,
    );
  }

  Widget _content(
    BuildContext context,
    List<_HoldCard> all,
    ({String total, int count, List<String> tabs, String? alert}) s,
  ) {
    return ValueListenableBuilder<int>(
      valueListenable: HoldFlow.tab,
      builder: (context, tab, _) {
        final cards = tab == 0
            ? all
            : [
                for (final c in all)
                  if (c.status == HoldFlow.statuses[tab - 1]) c,
              ];
        return hcol([
          _summary(context, s),
          _tabs(context, s.tabs, tab),
          if (all.isEmpty)
            const EmptyView.firstTime(
              title: '暂无挂单',
              message: '在开单页点“挂单”，可以先把这一单存下来',
            )
          else if (cards.isEmpty)
            EmptyView.filtered(onAction: () => HoldFlow.tab.value = 0)
          else
            for (final c in cards) _card(context, c),
        ], gap: 16);
      },
    );
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
                  hTap(
                    context,
                    hbox(
                      h: 30,
                      bg: const Color(0xFFF5D78E),
                      radius: BorderRadius.circular(15),
                      pad: const EdgeInsets.symmetric(horizontal: 14),
                      child: Align(
                        widthFactor: 1,
                        child: Text(
                          '提醒取车',
                          style: hts(
                            13,
                            dk(
                              context,
                              const Color(0xFF18181B),
                              const Color(0xFFFAFAFA),
                            ),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    onTap: () => _remind(context),
                    label: '提醒取车',
                  ),
                ],
                cross: CrossAxisAlignment.center,
                gap: 10,
              ),
            ),
        ], gap: 14),
        const [],
        behind: [
          Positioned(
            top: -90,
            right: -90,
            child: hsvg(dk(context, Svgs.s7, Svgs.s8), w: 240, h: 240),
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
              onTap: () => HoldFlow.tab.value = i,
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
                child: hTap(
                  context,
                  hbox(
                    h: 42,
                    bg: c.ready
                        ? const Color(0xFF0485F7)
                        : dk(
                            context,
                            const Color(0xFF18181B),
                            const Color(0xFFFAFAFA),
                          ),
                    radius: BorderRadius.circular(21),
                    child: Align(
                      widthFactor: 1,
                      child: Text(
                        '取单结算',
                        style: hts(
                          14,
                          c.ready
                              ? const Color(0xFFFFFFFF)
                              : dk(
                                  context,
                                  const Color(0xFFFFFFFF),
                                  const Color(0xFF18181B),
                                ),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => _takeOut(context, c),
                  label: '取单结算',
                ),
              ),
            ),
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.horizontal,
              child: hTap(
                context,
                hbox(
                  h: 42,
                  bg: dk(
                    context,
                    const Color(0xFFEEEEF0),
                    const Color(0xFF27272A),
                  ),
                  radius: BorderRadius.circular(21),
                  pad: const EdgeInsets.symmetric(horizontal: 18),
                  child: Align(
                    widthFactor: 1,
                    child: Text(
                      c.ready ? '提醒取车' : '加项',
                      style: hts(14, ink, w: FontWeight.w500, lh: 20),
                    ),
                  ),
                ),
                onTap: c.ready
                    ? () => _remind(context)
                    : () => _takeOut(context, c),
                label: c.ready ? '提醒取车' : '加项',
              ),
            ),
            UnconstrainedBox(
              alignment: Alignment.topLeft,
              constrainedAxis: Axis.horizontal,
              child: Semantics(
                label: '删除挂单',
                button: true,
                child: hTap(
                  context,
                  hbox(
                    w: 42,
                    h: 42,
                    bg: dk(
                      context,
                      const Color(0xFFFFE1E2),
                      const Color.fromRGBO(255, 56, 60, 0.18),
                    ),
                    radius: BorderRadius.circular(21),
                    child: hrow(
                      [
                        removing
                            ? AppSpinner(
                                size: 20,
                                color: dk(
                                  context,
                                  const Color(0xFFA43433),
                                  const Color(0xFFFF7B7E),
                                ),
                              )
                            : hsvg(
                                dk(context, Svgs.s165, Svgs.s166),
                                w: 18,
                                h: 18,
                              ),
                      ],
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                    ),
                  ),
                  onTap: removing ? () {} : () => _remove(context, c),
                  label: '删除挂单',
                ),
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
    if (c.row == null) {
      // 设计预览（未登录）：只演示跳转
      openRoute(context, 'Order');
      return;
    }
    HoldFlow.takeOut(c.row!);
    openRoute(context, 'Order');
  }

  Future<void> _remove(BuildContext context, _HoldCard c) async {
    if (c.id == null) {
      hToast(context, '已删除（演示）');
      return;
    }
    final ok = await hConfirm(
      context,
      '确认删除？',
      ok: '删除',
      message: '删除后这张挂单无法恢复',
    );
    if (!ok || !context.mounted) return;
    setState(() => _removing.add(c.id!));
    final started = DateTime.now();
    try {
      await HoldFlow.remove(context, c.id!);
      final left = kIndicatorMinShow - DateTime.now().difference(started);
      if (left > Duration.zero) await Future<void>.delayed(left);
    } finally {
      if (mounted) setState(() => _removing.remove(c.id));
    }
  }
}
