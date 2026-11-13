import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/staff_svgs.dart';
import '../../backend/hold_store.dart';
import 'st_cash_queue_template.dart' show StQueueFlow;
import 'st_live.dart';

class StFrontHomeTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StFrontHomeTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final name = '${d['name']}';
    final upcoming = [
      for (final t in (d['upcoming'] as List? ?? const []))
        Map<String, dynamic>.from(t as Map),
    ];
    String itemsOf(Map<String, dynamic> t) =>
        ((t['items'] as List?) ?? const [])
            .map((e) => '${(e as Map)['name']}')
            .join(' + ');
    String plateOf(Map<String, dynamic> t) =>
        '${t['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${t['plate']}';
    final queue = [
      for (final q in (d['queue'] as List? ?? const []))
        Map<String, dynamic>.from(q as Map),
    ];
    String itemsOfQ(Map<String, dynamic> q) =>
        ((q['items'] as List?) ?? const [])
            .map((e) => '${(e as Map)['name']}')
            .join(' + ');
    String qWho(Map<String, dynamic> q) =>
        '${(q['submitter'] as Map?)?['name'] ?? '—'} · ${stClock(q['created_at'])} 提交';
    String qPayable(Map<String, dynamic> q) =>
        stMoney(((q['quote'] as Map?)?['payable']) ?? 0);
    String qMember(Map<String, dynamic> q) =>
        '${(q['member'] as Map?)?['name'] ?? ''} · ${((q['member'] as Map?)?['card'] as Map?)?['name'] ?? '会员'} · 会员价';
    // _queueBlock：待收银 · 技师提交（有队列时显示）
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 968,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 110),
            child: hcol(
              [
                hrow(
                  [
                    hbox(
                      w: 40,
                      h: 40,
                      bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                      radius: BorderRadius.circular(20),
                      align: Alignment(0, 0),
                      child: Text(
                        stInitial(name),
                        style: hts(16, Color(0xFFF5D78E), w: FontWeight.w600),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          Text(
                            '${stGreeting()}，$name',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 25,
                            ),
                          ),
                          Text(
                            '${Access.roleBrief()} · ${Access.storeName}',
                            style: hts(
                              12,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 1,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
                hbox(
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [
                      Color(0xFF26262C),
                      Color(0xFF18181B),
                      Color(0xFF2B2418),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            Text(
                              '今日收款笔数',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                w: FontWeight.w500,
                                lh: 19,
                              ),
                            ),
                            Expanded(flex: 1, child: SizedBox.shrink()),
                            hbox(
                              bg: Color.fromRGBO(23, 201, 100, 0.2),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                '营业中',
                                style: hts(
                                  11,
                                  Color(0xFF6EE7A8),
                                  w: FontWeight.w600,
                                  lh: 18,
                                ),
                                softWrap: false,
                                maxLines: 1,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 10,
                        ),
                        Text(
                          '${d['orders_today'] ?? 0} 笔',
                          style: hts(
                            34,
                            Color(0xFFF5D78E),
                            w: FontWeight.w600,
                            lh: 42,
                          ),
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '${queue.length}',
                                    style: hts(
                                      17,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                  Text(
                                    '待收银',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '${d['waiting'] ?? 0}',
                                    style: hts(
                                      17,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                  Text(
                                    '待到店',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '${d['working'] ?? 0}',
                                    style: hts(
                                      17,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                  Text(
                                    '施工中',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 16,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 0,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -120,
                        right: -120,
                        child: IntrinsicWidth(
                          child: hsvg(Svgs.s2, w: 260, h: 260),
                        ),
                      ),
                      Positioned(
                        top: -100,
                        right: -80,
                        width: 260,
                        height: 260,
                        child: hbox(
                          w: 260,
                          h: 260,
                          radius: BorderRadius.circular(130),
                        ),
                      ),
                    ],
                  ),
                ),
                hbox(
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
                  pad: EdgeInsets.fromLTRB(6, 0, 6, 0),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openRoute(context, 'Order'),
                          child: hbox(
                            pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                            child: hcol(
                              [
                                hbox(
                                  w: 46,
                                  h: 46,
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s23, Svgs.s24),
                                        w: 22,
                                        h: 22,
                                      ),
                                    ],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                                Text(
                                  '开单收银',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 19,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openRoute(context, 'Recharge'),
                          child: hbox(
                            pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                            child: hcol(
                              [
                                hbox(
                                  w: 46,
                                  h: 46,
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s25, Svgs.s26),
                                        w: 22,
                                        h: 22,
                                      ),
                                    ],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                                Text(
                                  '会员充值',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 19,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openRoute(context, 'StVerify'),
                          child: hbox(
                            pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                            child: hcol(
                              [
                                hbox(
                                  w: 46,
                                  h: 46,
                                  bg: dk(
                                    context,
                                    Color(0xFFDDF6E7),
                                    Color.fromRGBO(23, 201, 100, 0.16),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s27, Svgs.s28),
                                        w: 22,
                                        h: 22,
                                      ),
                                    ],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                                Text(
                                  '扫码找会员',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 19,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openRoute(context, 'Appointments'),
                          child: hbox(
                            pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                            child: hcol(
                              [
                                hbox(
                                  w: 46,
                                  h: 46,
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s29, Svgs.s30),
                                        w: 22,
                                        h: 22,
                                      ),
                                    ],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                                Text(
                                  '预约管理',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 19,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.start,
                    gap: 0,
                  ),
                ),
                if (queue.isNotEmpty)
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '待收银 · 技师提交',
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
                            ),
                            AppButton(
                              label: '全部 ${queue.length}',
                              kind: AppButtonKind.text,
                              size: AppButtonSize.medium,
                              expanded: false,
                              onPressed: () =>
                                  openRoute(context, 'StCashQueue'),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      for (final q in queue.take(2))
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => openRoute(context, 'StCashQueue'),
                          child: hbox(
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
                            pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: hcol(
                              [
                                hrow(
                                  [
                                    hbox(
                                      grad: LinearGradient(
                                        begin: Alignment(-0, -1),
                                        end: Alignment(0, 1),
                                        colors: [
                                          Color(0xFF2F73F2),
                                          Color(0xFF1A4FC4),
                                        ],
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
                                        color: Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.75,
                                        ),
                                        width: 1.5,
                                      ),
                                      pad: EdgeInsets.fromLTRB(7, 1, 7, 1),
                                      child: Text(
                                        plateOf(q),
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
                                    Expanded(flex: 1, child: SizedBox.shrink()),
                                    Text(
                                      qWho(q),
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 17,
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
                                      flex: 1,
                                      child: Text(
                                        itemsOfQ(q),
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 22,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      qPayable(q),
                                      style: hts(
                                        17,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 24,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 8,
                                ),
                                Text(
                                  qMember(q),
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 17,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                            ),
                          ),
                        ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                  ),
                if (upcoming.isNotEmpty)
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '即将到店',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
                          ),
                        ),
                      ),
                      hbox(
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
                        pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: hcol(
                          [
                            for (var i = 0; i < upcoming.length; i++) ...[
                              if (i > 0)
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                                ),
                              (() {
                                final t = upcoming[i];
                                return hbox(
                                  minH: 56,
                                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 44,
                                        child: Text(
                                          stClock(t['starts_at']),
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '${plateOf(t)} · ${itemsOf(t)}',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 20,
                                              ),
                                            ),
                                            Text(
                                              '${t['customer']}',
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  Color(0xFF71717A),
                                                  Color(0xFF9A9AA3),
                                                ),
                                                lh: 16,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.stretch,
                                          gap: 1,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 12,
                                  ),
                                );
                              })(),
                            ],
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
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

/// 前台工作台：今日收款笔数（只给笔数，不给金额）、待到店、施工中与即将到店。
class StFrontHomeLivePage extends StatelessWidget {
  const StFrontHomeLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '工作台',
    refresh: Listenable.merge([StQueueFlow.changed, HoldStore.invalidated]),
    load: () async {
      final home = await merchantApi.staffHome();
      // 无此权限时不请求；已授权请求失败由统一边界展示并允许重试。
      if (!Access.can('cash_queue')) return home;
      final q = await merchantApi.staffWork('staff_cash_queue');
      return {...home, 'queue': q['items'] ?? const []};
    },
    builder: (_, d) => StFrontHomeTemplate(d: d),
  );
}
