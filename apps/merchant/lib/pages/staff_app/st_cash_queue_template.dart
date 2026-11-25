import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/hold_store.dart';
import '../orders/order_detail_ref.dart';
import '../orders/order_route_data.dart';
import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../staff/staff_live.dart';
import 'st_live.dart';
import '../../kit/page_header.dart';

/// 待收银队列变化（收银后）时刷新列表与前台工作台。
class StQueueFlow {
  static final changed = ValueNotifier<int>(0);
}

/// 前台待收银：技师提交的单。「去收银」把这张单放回开单页走既有的取单结算（价格、折扣、次卡抵扣由数据库结算时重新计算）。
class StCashQueueTemplate extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final List<Map<String, dynamic>> collected;
  final int? collectedCount;
  const StCashQueueTemplate({
    super.key,
    required this.items,
    this.collected = const [],
    this.collectedCount,
  });

  @override
  State<StCashQueueTemplate> createState() => _StCashQueueTemplateState();
}

class _StCashQueueTemplateState extends State<StCashQueueTemplate> {
  int _tab = 0;
  List<Map<String, dynamic>> get items => widget.items;
  int get _collectedCount => widget.collectedCount ?? widget.collected.length;

  Map<String, dynamic> _quote(Map<String, dynamic> h) =>
      Map<String, dynamic>.from((h['quote'] as Map?) ?? const {});
  num _discount(Map<String, dynamic> h) =>
      (_quote(h)['discount_off'] as num?) ?? 0;
  String _plate(Map<String, dynamic> h) =>
      '${h['vehicle_plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${h['vehicle_plate']}';
  String _level(Map<String, dynamic> h) {
    final l = '${((h['member'] as Map?)?['card'] as Map?)?['name'] ?? ''}';
    return l.isEmpty ? '会员' : l;
  }

  String _sub(Map<String, dynamic> h) =>
      '${(h['member'] as Map?)?['phone'] ?? ''}';
  String _time(Map<String, dynamic> h) => '${stClock(h['created_at'])} 提交';
  String _who(Map<String, dynamic> h) {
    final m = h['member'] as Map?;
    if (m == null) return '散客 · 非会员';
    return '${m['name'] ?? ''} · ${_level(h)}';
  }

  String _submitter(Map<String, dynamic> h) {
    final s = h['submitter'] as Map?;
    if (s == null) return '提交人 —';
    final role = switch ('${s['role']}') {
      'technician' => '技师',
      'cashier' => '前台',
      'manager' => '店长',
      _ => '',
    };
    return '提交人 ${s['name']}${role.isEmpty ? '' : '（$role）'}';
  }

  String _payable(Map<String, dynamic> h) =>
      _quote(h)['payable'] == null ? '待重新估价' : stMoney(_quote(h)['payable']);
  String _discLabel(Map<String, dynamic> h) => '${_level(h)}价';
  String _discAmount(Map<String, dynamic> h) => '-${stMoney(_discount(h))}';

  List<Map<String, dynamic>> _lines(Map<String, dynamic> h) => [
    for (final l in (h['lines'] as List? ?? const []))
      {
        'label':
            '${(l as Map)['name']}${((l['qty'] as num?) ?? 1) > 1 ? ' × ${l['qty']}' : ''}',
        'amount': stMoney(
          ((l['unit_price'] as num?) ?? 0) * ((l['qty'] as num?) ?? 1),
        ),
      },
  ];

  void _collect(BuildContext context, Map<String, dynamic> h) {
    openRoute(context, 'Order', arguments: OrderRouteData(hold: h));
  }

  Widget _card(BuildContext context, Map<String, dynamic> h) => hbox(
    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
    radius: BorderRadius.circular(24),
    shadow: dk(
      context,
      [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 0),
          blurRadius: 1,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.06),
          offset: Offset(0, 1),
          blurRadius: 2,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          offset: Offset(0, 2),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ],
      [
        BoxShadow(
          color: Color(0xFF26262B),
          offset: Offset(0, 0),
          blurRadius: 0,
          spreadRadius: 1,
        ),
      ],
    ),
    pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
    child: hcol(
      [
        hrow(
          [
            hbox(
              grad: LinearGradient(
                begin: Alignment(-0, -1),
                end: Alignment(0, 1),
                colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                stops: [0, 1],
              ),
              radius: BorderRadius.circular(5),
              shadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.08),
                  offset: Offset(0, 0),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
              border: Border.all(
                color: Color.fromRGBO(255, 255, 255, 0.75),
                width: 1.5,
              ),
              pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
              child: Text(
                _plate(h),
                style: hts(
                  12,
                  Color(0xFFFFFFFF),
                  w: FontWeight.w600,
                  lh: 18,
                  ls: 0.5,
                ),
                softWrap: false,
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                _sub(h),
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 17,
                ),
              ),
            ),
            Text(
              _time(h),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 17,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 8,
        ),
        hcol(
          [
            for (final l in _lines(h))
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      l['label'],
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 20,
                      ),
                    ),
                  ),
                  Text(
                    l['amount'],
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      lh: 20,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 0,
              ),
            if (_discount(h) > 0)
              hrow(
                [
                  Expanded(
                    flex: 1,
                    child: Text(
                      _discLabel(h),
                      style: hts(
                        13,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ),
                  Text(
                    _discAmount(h),
                    style: hts(
                      13,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 18,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 0,
              ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 6,
        ),
        hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
        hrow(
          [
            Expanded(
              flex: 1,
              child: hcol(
                [
                  Text(
                    _who(h),
                    style: hts(
                      13,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w500,
                      lh: 18,
                    ),
                  ),
                  Text(
                    _submitter(h),
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 16,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 1,
              ),
            ),
            Text(
              _payable(h),
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 8,
        ),
        hrow(
          [
            Expanded(
              flex: 14,
              child: UnconstrainedBox(
                alignment: Alignment.topLeft,
                constrainedAxis: Axis.horizontal,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _collect(context, h),
                  child: hbox(
                    h: 44,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(22),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '去收银',
                        style: hts(14, Color(0xFFFFFFFF), w: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 10,
          intrinsic: true,
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 12,
    ),
  );

  Widget _collectedCard(BuildContext context, Map<String, dynamic> o) {
    final discountOff = (o['discount_off'] as num?) ?? 0;
    final cardOff = (o['card_off'] as num?) ?? 0;
    final payMethod = '${o['pay_method'] ?? ''}'.trim();
    final operatorName = '${o['operator'] ?? ''}'.trim();
    final meta = payMethod.isEmpty
        ? (operatorName.isEmpty ? '已收银' : operatorName)
        : (operatorName.isEmpty ? payMethod : '$payMethod · $operatorName');
    final canDetail =
        Access.can('order_view_all') || Access.can('order_view_own');
    final card = hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.circular(24),
      shadow: dk(
        context,
        [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 0),
            blurRadius: 1,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        [
          BoxShadow(
            color: Color(0xFF26262B),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: hcol(
        [
          hrow(
            [
              hbox(
                grad: LinearGradient(
                  begin: Alignment(-0, -1),
                  end: Alignment(0, 1),
                  colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                  stops: [0, 1],
                ),
                radius: BorderRadius.circular(5),
                shadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.08),
                    offset: Offset(0, 0),
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(
                  color: Color.fromRGBO(255, 255, 255, 0.75),
                  width: 1.5,
                ),
                pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
                child: Text(
                  _plate(o),
                  style: hts(
                    12,
                    Color(0xFFFFFFFF),
                    w: FontWeight.w600,
                    lh: 18,
                    ls: 0.5,
                  ),
                  softWrap: false,
                  maxLines: 1,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  _sub(o),
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 17,
                  ),
                ),
              ),
              Text(
                '${stClock(o['created_at'])} 已收',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 17,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 8,
          ),
          hcol(
            [
              for (final l in _lines(o))
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        l['label'],
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          lh: 20,
                        ),
                      ),
                    ),
                    Text(
                      l['amount'],
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 20,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
              if (discountOff > 0)
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '${_level(o)}价',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Text(
                      '-${stMoney(discountOff)}',
                      style: hts(
                        13,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
              if (cardOff > 0)
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '次卡抵扣',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Text(
                      '-${stMoney(cardOff)}',
                      style: hts(
                        13,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 18,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 6,
          ),
          hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
          hrow(
            [
              Expanded(
                flex: 1,
                child: hcol(
                  [
                    Text(
                      _who(o),
                      style: hts(
                        13,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 18,
                      ),
                    ),
                    Text(
                      meta,
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 1,
                ),
              ),
              Text(
                stMoney(o['payable']),
                style: hts(
                  20,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w600,
                  lh: 28,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 8,
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 12,
      ),
    );
    if (!canDetail) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openRoute(
        context,
        'OrderDetail',
        arguments: OrderDetailRef(kind: 'consume', id: '${o['id']}'),
      ),
      child: card,
    );
  }

  Widget _tabPill(
    BuildContext context, {
    required int index,
    required String label,
    required int count,
  }) {
    final active = _tab == index;
    return Expanded(
      flex: 1,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        constrainedAxis: Axis.horizontal,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_tab != index) setState(() => _tab = index);
          },
          child: hbox(
            h: 34,
            bg: active
                ? dk(context, Color(0xFFFFFFFF), Color(0xFF18181B))
                : null,
            radius: BorderRadius.circular(17),
            shadow: active
                ? dk(
                    context,
                    [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                    [
                      BoxShadow(
                        color: Color(0xFF26262B),
                        offset: Offset(0, 0),
                        blurRadius: 0,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: Align(
              alignment: Alignment.center,
              widthFactor: 1,
              child: Text.rich(
                TextSpan(
                  style: hts(
                    13,
                    active
                        ? dk(context, Color(0xFF18181B), Color(0xFFFAFAFA))
                        : dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    w: FontWeight.w500,
                    lh: 18,
                  ),
                  children: [
                    TextSpan(text: '$label '),
                    TextSpan(
                      text: '$count',
                      style: hts(
                        13,
                        active
                            ? dk(context, Color(0xFF71717A), Color(0xFF9A9AA3))
                            : dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                        lh: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCollected = _tab == 1;
    final list = showCollected ? widget.collected : items;
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      header: AppPageHeader(title: '待收银'),
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: hcol(
              [
                hbox(
                  bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: hrow(
                    [
                      _tabPill(
                        context,
                        index: 0,
                        label: '待收银',
                        count: items.length,
                      ),
                      _tabPill(
                        context,
                        index: 1,
                        label: '今日已收',
                        count: _collectedCount,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                    intrinsic: true,
                  ),
                ),
                hcol(
                  [
                    if (list.isEmpty)
                      hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(24),
                        pad: EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Text(
                          showCollected ? '今日暂无已收银的订单' : '暂无待收银的订单',
                          style: hts(
                            14,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final item in list)
                      showCollected
                          ? _collectedCard(context, item)
                          : _card(context, item),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 12,
                ),
                hbox(
                  margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    showCollected
                        ? '展示今日已完成收银的消费订单。'
                        : '技师在「开单」提交后进入这里，老板、店长、前台都能处理。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 18,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 16,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [],
    );
  }
}

/// 待收银：门店里技师提交、还没收银的单。
class StCashQueueLivePage extends StatelessWidget {
  const StCashQueueLivePage({super.key});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    needsId: false,
    title: '待收银',
    refresh: Listenable.merge([StQueueFlow.changed, HoldStore.invalidated]),
    load: (_) => merchantApi.staffWork('staff_cash_queue'),
    builder: (_, d) => StCashQueueTemplate(
      items: [
        for (final x in (d['items'] as List? ?? const []))
          Map<String, dynamic>.from(x as Map),
      ],
      collected: [
        for (final x in (d['collected'] as List? ?? const []))
          Map<String, dynamic>.from(x as Map),
      ],
      collectedCount: (d['collected_count'] as num?)?.toInt(),
    ),
  );
}
