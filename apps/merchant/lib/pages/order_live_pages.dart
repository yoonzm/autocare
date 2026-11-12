import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/member_flow.dart' show plateText;
import '../backend/order_flow.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../kit/page_header.dart';
import '../kit/sheet_frame.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/choice_chip_group.dart';
import '../widgets/common.dart' show PrimaryButton, Segmented;
import 'gen/svgs.dart';

// ───────────────────────── 通用小件（样式取自设计稿 OrderList / OrderDetail）─────────────────────────

BoxDecoration _card([double radius = 24]) => BoxDecoration(
  color: C.card,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: softShadow,
);

/// 每种订单类型的图标和底色（消费蓝 / 充值黄 / 次卡绿 / 退款红）。
({Color bg, String icon, String iconDark}) _kindStyle(String kind) =>
    switch (kind) {
      'recharge' => (bg: C.amberSoft, icon: Svgs.s234, iconDark: Svgs.s235),
      'package' => (bg: C.greenSoft, icon: Svgs.s426, iconDark: Svgs.s427),
      'refund' => (bg: C.redSoft, icon: Svgs.s428, iconDark: Svgs.s429),
      _ => (bg: C.primarySoft, icon: Svgs.s169, iconDark: Svgs.s170),
    };

/// 订单详情要查的类型：退款行指向原订单（消费退款 → consume，次卡退款 → package）。
String _detailKind(Map<String, dynamic> row) {
  if (row['kind'] != 'refund') return '${row['kind']}';
  return '${row['title']}'.startsWith('次卡') ? 'package' : 'consume';
}

class OrderRef {
  OrderRef._();

  /// 订单详情页读取的订单（字符串路由没有参数，先放在这里再打开）。
  static ({String kind, String id})? current;
  static void open(BuildContext context, Map<String, dynamic> row) {
    current = (kind: _detailKind(row), id: '${row['id']}');
    openRoute(context, 'OrderDetail');
  }
}

// ───────────────────────── 订单列表 ─────────────────────────

class OrderListLivePage extends StatefulWidget {
  const OrderListLivePage({super.key});
  @override
  State<OrderListLivePage> createState() => _OrderListState();
}

class _OrderListState extends State<OrderListLivePage> {
  final _search = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    OrderFlow.reset();
    OrderFlow.tick.addListener(_changed);
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 200) unawaited(OrderFlow.loadMore());
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(OrderFlow.load(withOptions: true)),
    );
  }

  @override
  void dispose() {
    OrderFlow.tick.removeListener(_changed);
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _pickRange(int i) async {
    if (OrderFlow.ranges[i] != 'custom') {
      OrderFlow.setRange(i);
      return;
    }
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: OrderFlow.custom,
      helpText: '选择订单日期',
      saveText: '确定',
    );
    if (picked == null) return;
    OrderFlow.custom = picked;
    OrderFlow.rangeIndex = i;
    unawaited(OrderFlow.load());
  }

  @override
  Widget build(BuildContext context) {
    final items = OrderFlow.items;
    final firstLoad = items == null && OrderFlow.error == null;
    final failed = items == null && OrderFlow.error != null;
    final empty = items != null && items.isEmpty;
    final plainEmpty =
        empty &&
        !OrderFlow.filtered &&
        !OrderFlow.searching &&
        OrderFlow.typeIndex == 0;
    return Scaffold(
      backgroundColor: C.bg,
      body: RefreshIndicator(
        onRefresh: () => OrderFlow.load(),
        edgeOffset: topInset(context),
        child: ListView(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
          children: [
            const AppPageHeader(title: '订单'),
            const SizedBox(height: 16),
            Segmented(
              labels: OrderFlow.rangeLabels,
              selected: OrderFlow.rangeIndex,
              onChanged: _pickRange,
            ),
            if (failed) ...[
              const SizedBox(height: 16),
              ErrorView(
                error: OrderFlow.error!,
                onRetry: () => OrderFlow.load(withOptions: true),
              ),
            ] else ...[
              const SizedBox(height: 16),
              _SummaryCard(loading: firstLoad),
              if (!plainEmpty && !firstLoad) ...[
                const SizedBox(height: 16),
                _SearchRow(controller: _search),
                const SizedBox(height: 16),
                const _TypeChips(),
              ],
              const SizedBox(height: 16),
              if (firstLoad)
                const _ListSkeleton()
              else if (plainEmpty)
                _EmptyDay(
                  rangeLabel: OrderFlow.rangeLabels[OrderFlow.rangeIndex],
                )
              else if (empty)
                EmptyView.filtered(
                  onAction: () {
                    _search.clear();
                    OrderFlow.query = '';
                    OrderFlow.typeIndex = 0;
                    OrderFlow.setFilter(method: 0, status: 0, operatorName: '');
                  },
                )
              else
                ..._days(),
              if (OrderFlow.loadingMore)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: AppSpinner(size: 20, color: C.primary)),
                )
              else if (items != null &&
                  items.isNotEmpty &&
                  !OrderFlow.hasMore &&
                  items.length > 8)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Center(
                    child: Text(
                      '— 没有更多了 —',
                      style: ts(12, color: C.faint, h: 16),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _days() => [
    for (final (i, day) in OrderFlow.groups().indexed) ...[
      if (i > 0) const SizedBox(height: 16),
      _DaySection(day: day),
    ],
  ];
}

class _SummaryCard extends StatelessWidget {
  final bool loading;
  const _SummaryCard({required this.loading});

  Widget _stat(String label, String value, {Color? color}) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ts(12, color: C.muted, h: 16)),
        const SizedBox(height: 2),
        loading
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 3),
                child: AppSkeleton(width: 64, height: 20),
              )
            : Text(
                value,
                style: ts(
                  20,
                  w: FontWeight.w600,
                  color: color ?? C.ink,
                  h: 26,
                  spacing: -0.4,
                  tabular: true,
                ),
              ),
      ],
    ),
  );

  Widget _tile(String label, String value, {Color? color}) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: C.inset,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ts(12, color: C.muted, h: 16)),
          const SizedBox(height: 1),
          loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 3),
                  child: AppSkeleton(width: 48, height: 14),
                )
              : Text(
                  value,
                  style: ts(
                    14,
                    w: FontWeight.w600,
                    color: color ?? C.ink,
                    h: 20,
                    tabular: true,
                  ),
                ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                OrderFlow.summaryTitle,
                style: ts(15, w: FontWeight.w600, color: C.ink, h: 22),
              ),
            ),
            Text(OrderFlow.summaryDate(), style: ts(12, color: C.muted)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _stat('实收', OrderFlow.sum('received')),
            const SizedBox(width: 8),
            _stat('退款', OrderFlow.sum('refunded'), color: C.redInk),
            const SizedBox(width: 8),
            _stat('净收入', OrderFlow.sum('net')),
          ],
        ),
        const SizedBox(height: 12),
        Container(height: 1, color: C.line),
        const SizedBox(height: 12),
        Text('按收款方式', style: ts(12, color: C.muted, h: 16)),
        const SizedBox(height: 8),
        Row(
          children: [
            _tile('微信', OrderFlow.sum('wechat')),
            const SizedBox(width: 8),
            _tile('支付宝', OrderFlow.sum('alipay')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _tile('现金', OrderFlow.sum('cash_pay')),
            const SizedBox(width: 8),
            _tile('储值抵扣', OrderFlow.sum('balance'), color: C.faint),
          ],
        ),
        const SizedBox(height: 8),
        Text('储值抵扣是会员用余额消费，不是新收的钱，不计入实收', style: ts(11, color: C.faint, h: 16)),
      ],
    ),
  );
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  const _SearchRow({required this.controller});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: _card(),
          child: Row(
            children: [
              hsvg(dk(context, Svgs.s418, Svgs.s419), w: 18, h: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: OrderFlow.search,
                  textInputAction: TextInputAction.search,
                  style: ts(15, color: C.ink, h: 22),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '车牌 / 手机号 / 订单号',
                    hintStyle: ts(15, color: C.muted, h: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 8),
      Semantics(
        button: true,
        label: '筛选',
        child: hTap(
          context,
          hbox(
            w: 44,
            h: 44,
            bg: C.card,
            radius: BorderRadius.circular(22),
            shadow: softShadow,
            child: Center(
              child: hsvg(dk(context, Svgs.s12, Svgs.s13), w: 20, h: 20),
            ),
          ),
          onTap: () => openRoute(context, 'OrderFilter'),
        ),
      ),
    ],
  );
}

/// 订单类型标签：未选中是白底（页面底色是灰），选中是蓝底 + 蓝描边。
class _TypeChips extends StatelessWidget {
  const _TypeChips();
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 34,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: OrderFlow.typeLabels.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final on = OrderFlow.typeIndex == i;
        return Semantics(
          button: true,
          selected: on,
          label: OrderFlow.typeLabels[i],
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => OrderFlow.setType(i),
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? C.primarySoft : C.card,
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: on ? C.primary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                OrderFlow.typeLabels[i],
                style: ts(
                  13,
                  w: FontWeight.w500,
                  color: on
                      ? C.primaryInk
                      : dk(
                          context,
                          const Color(0xFF3F3F46),
                          const Color(0xFFD4D4D8),
                        ),
                  h: 18,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _DaySection extends StatelessWidget {
  final OrderDay day;
  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                day.title,
                style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
              ),
            ),
            Text(
              day.refunded > 0
                  ? '实收 ${OrderFlow.money(day.received)} · 退款 ${OrderFlow.money(day.refunded)}'
                  : '实收 ${OrderFlow.money(day.received)}',
              style: ts(13, color: C.sub, h: 18),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: _card(),
        child: Column(
          children: [
            for (final (i, row) in day.rows.indexed) ...[
              if (i > 0)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 68),
                  color: C.line,
                ),
              _OrderRow(row: row),
            ],
          ],
        ),
      ),
    ],
  );
}

class _OrderRow extends StatelessWidget {
  final Map<String, dynamic> row;
  const _OrderRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final kind = '${row['kind']}';
    final st = _kindStyle(kind);
    final amount = OrderFlow.num_(row['amount']);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => OrderRef.open(context, row),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: st.bg,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: hsvg(dk(context, st.icon, st.iconDark), w: 18, h: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${row['title']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(14, w: FontWeight.w500, color: C.ink, h: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    OrderFlow.subtitle(row),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, color: C.muted, h: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              OrderFlow.money(amount),
              style: ts(
                15,
                w: FontWeight.w600,
                color: kind == 'refund' ? C.redInk : C.ink,
                h: 22,
                tabular: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4),
        child: AppSkeleton(width: 48, height: 13),
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: _card(),
        child: Column(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 68),
                  color: C.line,
                ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    AppSkeleton(width: 40, height: 40, radius: 13),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSkeleton(width: 120, height: 14),
                          SizedBox(height: 6),
                          AppSkeleton(width: 168, height: 12),
                        ],
                      ),
                    ),
                    AppSkeleton(width: 48, height: 15),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

/// 今日无订单（设计稿 OrderListEmpty）：汇总卡片仍显示 ¥0，下面是空状态和“去开单”。
class _EmptyDay extends StatelessWidget {
  final String rangeLabel;
  const _EmptyDay({required this.rangeLabel});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 360,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: C.primarySoft,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 44,
            color: C.primaryInk,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          rangeLabel == '今日' ? '今天还没有订单' : '$rangeLabel没有订单',
          style: ts(18, w: FontWeight.w600, color: C.ink, h: 26),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 260,
          child: Text(
            '开单收款后，订单会出现在这里',
            textAlign: TextAlign.center,
            style: ts(14, color: C.sub, h: 21),
          ),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          '去开单',
          onTap: () => openRoute(context, 'Order'),
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
      ],
    ),
  );
}

// ───────────────────────── 订单详情 ─────────────────────────

class OrderDetailLivePage extends StatefulWidget {
  const OrderDetailLivePage({super.key});
  @override
  State<OrderDetailLivePage> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetailLivePage> {
  final _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  final ref = OrderRef.current;

  @override
  Widget build(BuildContext context) {
    final r = ref;
    return Scaffold(
      backgroundColor: C.bg,
      body: r == null
          ? ErrorView(
              error: const AppError('请从订单列表选择订单', type: AppErrorType.notFound),
              onNext: () => Navigator.of(context).maybePop(),
            )
          : AsyncView<Map<String, dynamic>>(
              key: _key,
              load: () => OrderFlow.detail(r.kind, r.id),
              isEmpty: (_) => false,
              skeletonPadding: EdgeInsets.zero,
              skeletonScrollable: true,
              waiting: _Shell(),
              skeleton: _Shell(loading: true),
              empty: (_) => const SizedBox.shrink(),
              builder: (context, d) =>
                  _DetailBody(data: d, onRefund: () => _refund(context, d)),
            ),
    );
  }

  Future<void> _refund(BuildContext context, Map<String, dynamic> d) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      routeSettings: const RouteSettings(name: 'sheet:OrderRefund'),
      builder: (_) => OrderRefundLiveSheet(order: d),
    );
    _key.currentState?.reload();
  }
}

class _Shell extends StatelessWidget {
  final bool loading;
  const _Shell({this.loading = false});
  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
    children: [
      const AppPageHeader(title: '订单详情'),
      if (loading) ...[
        const SizedBox(height: 16),
        const AppSkeleton(height: 130, radius: 28),
        const SizedBox(height: 16),
        const AppSkeleton(height: 72, radius: 24),
        const SizedBox(height: 16),
        const AppSkeleton(height: 150, radius: 24),
        const SizedBox(height: 16),
        const AppSkeleton(height: 110, radius: 24),
      ],
    ],
  );
}

class _DetailBody extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefund;
  const _DetailBody({required this.data, required this.onRefund});

  String get kind => '${data['kind']}';
  bool get refunded => data['status'] == 'refunded';

  String get _typeLabel => switch (kind) {
    'recharge' => '储值充值',
    'package' => '次卡售卖',
    _ => '消费订单',
  };

  Widget _row(String label, String value, {bool bold = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(label, style: ts(14, color: C.sub, h: 20)),
      ),
      const SizedBox(width: 12),
      Text(
        value,
        style: ts(
          14,
          w: bold ? FontWeight.w600 : FontWeight.w500,
          color: C.ink,
          h: 20,
          tabular: true,
        ),
      ),
    ],
  );

  Widget _section(String title, List<Widget> rows) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _card(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: ts(15, w: FontWeight.w600, color: C.ink, h: 22),
        ),
        for (final r in rows) ...[const SizedBox(height: 12), r],
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final member = data['member'] is Map
        ? Map<String, dynamic>.from(data['member'] as Map)
        : null;
    final items = [
      for (final e in data['items'] as List? ?? const [])
        Map<String, dynamic>.from(e as Map),
    ];
    final pays = [
      for (final e in data['payments'] as List? ?? const [])
        Map<String, dynamic>.from(e as Map),
    ];
    final canRefund = data['can_refund'] == true;
    final plate = '${data['plate'] ?? ''}';
    final name = '${member?['name'] ?? ''}';
    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
          children: [
            const AppPageHeader(title: '订单详情'),
            const SizedBox(height: 16),
            // 深色概览卡
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: C.heroCard,
                borderRadius: BorderRadius.circular(28),
                border: C.heroBorder,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -90,
                    top: -90,
                    child: hsvg(Svgs.s7, w: 240, h: 240),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _typeLabel,
                                style: ts(13, color: const Color(0xFFA1A1AA)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              height: 18,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: refunded ? C.redSoft : C.greenSoft,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Text(
                                refunded ? '已退款' : '已完成',
                                style: ts(
                                  11,
                                  w: FontWeight.w600,
                                  color: refunded ? C.redInk : C.greenInk,
                                  h: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          OrderFlow.money2(data['amount']),
                          style: ts(
                            32,
                            w: FontWeight.w600,
                            color: const Color(0xFFFAFAFA),
                            h: 38,
                            spacing: -0.96,
                            tabular: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '订单号 ${data['order_no']} · ${_when(data['at'])}',
                          style: ts(12, color: const Color(0xFFA1A1AA)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (member != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => openRoute(context, 'MemberDetail'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _card(),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment(-0.5, -1),
                            end: Alignment(0.5, 1),
                            colors: [Color(0xFFFBE7B0), Color(0xFFE6B85C)],
                          ),
                        ),
                        child: Text(
                          name.isEmpty ? '' : name.substring(0, 1),
                          style: ts(
                            17,
                            w: FontWeight.w600,
                            color: const Color(0xFF18181B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name${'${member['level'] ?? ''}'.isEmpty ? '' : ' · ${member['level']}'}',
                              style: ts(
                                15,
                                w: FontWeight.w600,
                                color: C.ink,
                                h: 22,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plate.isNotEmpty
                                  ? plateText(plate)
                                  : kind == 'recharge' &&
                                        member['balance'] != null
                                  ? '余额 ${OrderFlow.money(member['balance'])}'
                                  : '',
                              style: ts(12, color: C.muted, h: 16),
                            ),
                          ],
                        ),
                      ),
                      AppIcon('chevronRight', size: 16, color: C.faint),
                    ],
                  ),
                ),
              ),
            ],
            if (items.isNotEmpty) ...[
              const SizedBox(height: 16),
              _section('项目明细', [
                for (final it in items)
                  _row(
                    '${it['name']}${(it['qty'] ?? 1) > 1 ? ' × ${it['qty']}' : ''}${it['package'] != null ? ' · 次卡抵扣' : ''}',
                    OrderFlow.money(it['line_total']),
                  ),
              ]),
            ],
            if (kind == 'recharge') ...[
              const SizedBox(height: 16),
              _section('入账明细', [
                _row('充值本金', '+${OrderFlow.money(data['amount'])}'),
                _row('赠送金额', '+${OrderFlow.money(data['gift'])}'),
                Container(height: 1, color: C.line),
                _row(
                  '入账后余额',
                  OrderFlow.money(data['balance_after']),
                  bold: true,
                ),
              ]),
            ],
            const SizedBox(height: 16),
            _section('支付明细', [
              for (final p in pays)
                _row('${p['label']}', OrderFlow.money(p['amount'])),
              if (kind == 'consume' && pays.length > 1) ...[
                Container(height: 1, color: C.line),
                _row('实付合计', OrderFlow.money(data['amount']), bold: true),
              ],
            ]),
            const SizedBox(height: 16),
            _section('其他信息', [
              _row(
                '经办人',
                '${data['operator'] ?? ''}'.isEmpty
                    ? '—'
                    : '${data['operator']}',
              ),
              if (kind != 'recharge')
                _row(
                  '备注',
                  '${data['remark'] ?? ''}'.isEmpty ? '无' : '${data['remark']}',
                ),
            ]),
            if (refunded && data['refund'] is Map) ...[
              const SizedBox(height: 16),
              _section('退款信息', [
                _row('退款时间', _when((data['refund'] as Map)['at'])),
                if ('${(data['refund'] as Map)['reason'] ?? ''}'.isNotEmpty)
                  _row('退款原因', '${(data['refund'] as Map)['reason']}'),
                _row(
                  '退款金额',
                  OrderFlow.money((data['refund'] as Map)['amount']),
                  bold: true,
                ),
              ]),
            ],
          ],
        ),
        // 一期暂不提供小票打印，仅有退款权限时显示操作栏。
        if (canRefund)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottomInset(context, 30),
              ),
              decoration: BoxDecoration(
                color: dk(
                  context,
                  const Color.fromRGBO(255, 255, 255, 0.94),
                  const Color.fromRGBO(9, 9, 11, 0.92),
                ),
                border: Border(top: BorderSide(color: C.stroke)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _BarButton(
                      '退款',
                      bg: C.redSoft,
                      fg: C.redInk,
                      onTap: onRefund,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  static String _when(Object? iso) {
    final d = OrderFlow.local(iso);
    final t = OrderFlow.local(DateTime.now().toUtc().toIso8601String());
    final sameDay = d.year == t.year && d.month == t.month && d.day == t.day;
    return '${sameDay ? '今天' : '${d.year}.${OrderFlow.md(d)}'} ${OrderFlow.hm(iso)}';
  }
}

class _BarButton extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final VoidCallback onTap;
  const _BarButton(
    this.label, {
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: ts(15, w: FontWeight.w500, color: fg, h: 22),
        ),
      ),
    ),
  );
}

// ───────────────────────── 底部弹层：筛选订单 / 订单退款 ─────────────────────────

Widget _group(
  String label,
  List<String> labels,
  int selected,
  ValueChanged<int> onChanged,
) => Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      label,
      style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
    ),
    const SizedBox(height: 8),
    ChoiceChipGroup<int>(
      semanticLabel: label,
      kind: ChipKind.pill,
      selected: selected,
      onChanged: onChanged,
      items: [
        for (final (i, l) in labels.indexed) ChoiceChipItem(value: i, label: l),
      ],
    ),
  ],
);

/// 筛选订单：类型 / 收款方式 / 状态 / 经办人（设计稿 OrderFilter）。
class OrderFilterLiveSheet extends StatefulWidget {
  const OrderFilterLiveSheet({super.key});
  @override
  State<OrderFilterLiveSheet> createState() => _FilterState();
}

class _FilterState extends State<OrderFilterLiveSheet> {
  int type = OrderFlow.typeIndex;
  int method = OrderFlow.methodIndex;
  int status = OrderFlow.statusIndex;
  late int op = (['全部', ...OrderFlow.operators])
      .indexOf(OrderFlow.operator.isEmpty ? '全部' : OrderFlow.operator)
      .clamp(0, OrderFlow.operators.length);

  @override
  Widget build(BuildContext context) {
    final ops = ['全部', ...OrderFlow.operators];
    return AppSheetFrame(
      title: '筛选订单',
      children: [
        _group(
          '类型',
          OrderFlow.typeLabels,
          type,
          (i) => setState(() => type = i),
        ),
        _group(
          '收款方式',
          OrderFlow.methodLabels,
          method,
          (i) => setState(() => method = i),
        ),
        _group(
          '状态',
          OrderFlow.statusLabels,
          status,
          (i) => setState(() => status = i),
        ),
        _group('经办人', ops, op, (i) => setState(() => op = i)),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Expanded(
                child: _BarButton(
                  '重置',
                  bg: C.chip,
                  fg: C.ink,
                  onTap: () => setState(() {
                    type = 0;
                    method = 0;
                    status = 0;
                    op = 0;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _BarButton(
                  '查看订单',
                  bg: C.primary,
                  fg: Colors.white,
                  onTap: () {
                    OrderFlow.typeIndex = type;
                    OrderFlow.setFilter(
                      method: method,
                      status: status,
                      operatorName: op == 0 ? '' : ops[op],
                    );
                    Navigator.of(context).maybePop();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 订单退款：全额退款，退回明细和退款原因（设计稿 OrderRefund）。退款规则在云函数 / 数据库里执行。
class OrderRefundLiveSheet extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderRefundLiveSheet({super.key, required this.order});
  @override
  State<OrderRefundLiveSheet> createState() => _RefundState();
}

class _RefundState extends State<OrderRefundLiveSheet> {
  int amount = 0;
  int reason = 0;
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final total = OrderFlow.money(widget.order['amount']);
    final pays = [
      for (final e in widget.order['payments'] as List? ?? const [])
        Map<String, dynamic>.from(e as Map),
    ];
    return AppSheetFrame(
      title: '订单退款',
      children: [
        _group('退款金额', ['全额退款 $total', '部分退款'], amount, (i) {
          if (i == 1) {
            // TODO: 部分退款需要后端按支付方式拆分退回金额的规则，预期接口：order_refund 的 amount 参数；暂只支持全额。
            AppToast.show(context, '部分退款暂未支持，请选择全额退款');
            return;
          }
          setState(() => amount = i);
        }),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '退回明细',
              style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  for (final (i, p) in pays.indexed) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${p['label']} ${OrderFlow.money(p['amount'])}'
                                .replaceAll('支付 ', ' '),
                            style: ts(14, color: C.sub, h: 20),
                          ),
                        ),
                        Text(
                          '${p['label']}'.startsWith('储值')
                              ? '退回储值余额'
                              : '原路退回${'${p['label']}'.replaceAll('支付', '')}',
                          style: ts(
                            14,
                            w: FontWeight.w500,
                            color: C.ink,
                            h: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        _group(
          '退款原因',
          OrderFlow.refundReasons,
          reason,
          (i) => setState(() => reason = i),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.amberSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppIcon('info', size: 16, color: C.amberInk, stroke: 1.8),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '退款后订单状态变为已退款，操作不能撤销。',
                  style: ts(13, w: FontWeight.w500, color: C.amberInk, h: 18),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 10,
              child: _BarButton(
                '再想想',
                bg: C.chip,
                fg: C.ink,
                onTap: busy ? () {} : () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 14,
              child: PrimaryButton(
                '确认退款 $total',
                bg: C.redSoft,
                fg: C.redInk,
                loading: busy,
                loadingText: '提交中…',
                onTap: _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    setState(() => busy = true);
    try {
      await OrderFlow.refund(
        '${widget.order['id']}',
        OrderFlow.refundReasons[reason],
      );
      nav.pop();
      AppToast.showOn(messenger, '已退款', kind: ToastKind.success);
    } catch (e) {
      if (mounted) setState(() => busy = false);
      AppToast.showOn(
        messenger,
        AppError.from(e).message,
        kind: ToastKind.error,
      );
    }
  }
}
