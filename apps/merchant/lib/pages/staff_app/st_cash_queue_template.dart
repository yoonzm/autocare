import 'package:flutter/material.dart';

import '../../backend/hold_store.dart';
import '../orders/order_route_data.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/staff_svgs.dart';
import '../staff/staff_live.dart';
import 'st_live.dart';

/// 待收银队列变化（退回 / 收银后）时刷新列表与前台工作台。
class StQueueFlow {
  static final changed = ValueNotifier<int>(0);
}

/// 前台待收银：技师提交的单。「去收银」把这张单放回开单页走既有的取单结算（价格、折扣、次卡抵扣由数据库结算时重新计算）。
class StCashQueueTemplate extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const StCashQueueTemplate({super.key, required this.items});

  @override
  State<StCashQueueTemplate> createState() => _StCashQueueTemplateState();
}

class _StCashQueueTemplateState extends State<StCashQueueTemplate> {
  final _prefix = 'staff-queue:${UniqueKey()}';
  final _returned = <String>{};
  List<Map<String, dynamic>> get items =>
      widget.items.where((e) => !_returned.contains('${e['id']}')).toList();
  String _returnKey(Map<String, dynamic> h) => '$_prefix:${h['id']}';

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
  String _who(Map<String, dynamic> h) =>
      '${(h['member'] as Map?)?['name'] ?? ''} · ${_level(h)}';
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

  Future<void> _return(Map<String, dynamic> h) async {
    var saved = false;
    await runBusy(_returnKey(h), () async {
      try {
        await merchantApi.staffWork('staff_order_return', {
          'id': h['id'],
          'reason': '请核对后重新提交',
        });
        saved = true;
      } catch (e) {
        if (mounted) AppToast.error(context, e);
      }
    });
    if (!saved) return;
    if (mounted) setState(() => _returned.add('${h['id']}'));
    HoldStore.recordRemoved('${h['id']}');
    StQueueFlow.changed.value++;
    if (mounted) AppToast.show(context, '已退回，已通知提交人', kind: ToastKind.success);
  }

  void _collect(Map<String, dynamic> h) {
    openRoute(context, 'Order', arguments: OrderRouteData(hold: h));
  }

  Widget _card(
    BuildContext context,
    Map<String, dynamic> h,
  ) => AsyncActionScope(
    actionKey: _returnKey(h),
    child: hbox(
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
                flex: 10,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _return(h),
                    child: hbox(
                      h: 44,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(22),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: hBusy(
                          _returnKey(h),
                          Text(
                            '退回修改',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 14,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _collect(h),
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
    ),
  );

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 0),
            child: hcol(
              [
                hrow(
                  [
                    hbox(
                      w: 87,
                      child: hrow(
                        [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).maybePop(),
                              child: hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(22),
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
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s0, Svgs.s1),
                                      w: 20,
                                      h: 20,
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                        intrinsic: true,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '待收银',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 87),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: hbox(
                            h: 34,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(17),
                            shadow: dk(
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
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              widthFactor: 1,
                              child: Text.rich(
                                TextSpan(
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '待收银 ',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${items.length}',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
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
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              /* TODO: staff_cash_queue 仅返回待收银，已收历史/汇总接口未提供。 */
                              AppToast.show(context, '今日已收明细暂未接通');
                            },
                            child: hbox(
                              h: 34,
                              radius: BorderRadius.circular(17),
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text.rich(
                                  TextSpan(
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 18,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '今日已收 ',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '—',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
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
                    if (items.isEmpty)
                      hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(24),
                        pad: EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Text(
                          '暂无待收银的订单',
                          style: hts(
                            14,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final h in items) _card(context, h),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 12,
                ),
                hbox(
                  margin: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    '技师在「开单」提交后进入这里，收银完成后会通知提交人。老板、店长、前台都能处理。',
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
    ),
  );
}
