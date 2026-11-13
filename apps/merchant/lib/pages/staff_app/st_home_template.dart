import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/staff_svgs.dart';
import 'st_live.dart';

class StHomeTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StHomeTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final name = '${d['name']}';
    final tasks = [
      for (final t in (d['tasks'] as List? ?? const []))
        Map<String, dynamic>.from(t as Map),
    ];
    final working = [
      for (final t in tasks)
        if (t['status'] == 'arrived') t,
    ];
    final waiting = [
      for (final t in tasks)
        if (t['status'] != 'arrived') t,
    ];
    String itemsOf(Map<String, dynamic> t) =>
        ((t['items'] as List?) ?? const [])
            .map((e) => '${(e as Map)['name']}')
            .join(' + ');
    String plateOf(Map<String, dynamic> t) =>
        '${t['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${t['plate']}';
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
                        hcol(
                          [
                            hrow(
                              [
                                Text(
                                  '今日业绩',
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
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                        Text(
                          stMoney(d['revenue_today']),
                          style: hts(
                            34,
                            Color(0xFFF5D78E),
                            w: FontWeight.w600,
                            lh: 42,
                          ),
                        ),
                        hcol(
                          [
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '${d['done_today'] ?? 0}',
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '完成单',
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
                                        stMoney(d['commission_today']),
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '预计提成',
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
                                        '待施工',
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
                          gap: 0,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [
                      Positioned(
                        top: 24,
                        right: -6,
                        child: IntrinsicWidth(
                          child: hbox(
                            opacity: .3,
                            child: hcol(
                              [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: hsvg(Svgs.s36, w: 90, h: 34),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                          onTap: () => openRoute(context, 'StOrder'),
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
                                  '开单',
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
                          onTap: () => openRoute(context, 'StMember'),
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
                                        dk(context, Svgs.s37, Svgs.s38),
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
                                  '会员查询',
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
                          onTap: () => openRoute(context, 'StArrivals'),
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
                                  '今日到店',
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
                if (working.isNotEmpty)
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '进行中',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
                          ),
                        ),
                      ),
                      for (final t in working)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => stOpenTask(context, '${t['id']}'),
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
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s39, Svgs.s40),
                                  w: 78,
                                  h: 29,
                                ),
                                Expanded(
                                  flex: 1,
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
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.08,
                                                ),
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
                                            pad: EdgeInsets.fromLTRB(
                                              7,
                                              1,
                                              7,
                                              1,
                                            ),
                                            child: Text(
                                              plateOf(t),
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
                                            child: SizedBox.shrink(),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        itemsOf(t),
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
                                      hrow(
                                        [
                                          Expanded(
                                            flex: 1,
                                            child: hbox(
                                              h: 6,
                                              bg: dk(
                                                context,
                                                Color(0xFFEEEEF0),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(3),
                                              clip: true,
                                              child: hcol(
                                                [
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: hfrac(
                                                      0.0,
                                                      hbox(
                                                        h: 6,
                                                        bg: Color(0xFF0485F7),
                                                        radius:
                                                            BorderRadius.circular(
                                                              3,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.stretch,
                                                gap: 0,
                                                min: false,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '进行中',
                                            style: hts(
                                              12,
                                              Color(0xFF0485F7),
                                              w: FontWeight.w600,
                                              lh: 17,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 10,
                                      ),
                                      Text(
                                        '${t['bay_name'] ?? '未指定工位'} · 预计 ${stClock(stEnd(t))}',
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
                                    gap: 6,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                        ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                  ),
                if (waiting.isNotEmpty)
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '待施工',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
                          ),
                        ),
                      ),
                      for (final t in waiting)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => stOpenTask(context, '${t['id']}'),
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
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s39, Svgs.s40),
                                  w: 78,
                                  h: 29,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      hrow(
                                        [
                                          (stPlateGreen(t['plate'])
                                              ? hbox(
                                                  grad: LinearGradient(
                                                    begin: Alignment(-0, -1),
                                                    end: Alignment(0, 1),
                                                    colors: [
                                                      Color(0xFFE9FBEF),
                                                      Color(0xFFB8F0CB),
                                                    ],
                                                    stops: [0, 1],
                                                  ),
                                                  radius: BorderRadius.circular(
                                                    5,
                                                  ),
                                                  shadow: [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                        0,
                                                        0,
                                                        0,
                                                        0.08,
                                                      ),
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
                                                  pad: EdgeInsets.fromLTRB(
                                                    7,
                                                    1,
                                                    7,
                                                    1,
                                                  ),
                                                  child: Text(
                                                    plateOf(t),
                                                    style: hts(
                                                      12,
                                                      Color(0xFF14532D),
                                                      w: FontWeight.w600,
                                                      lh: 18,
                                                      ls: 0.5,
                                                    ),
                                                    softWrap: false,
                                                    maxLines: 1,
                                                  ),
                                                )
                                              : hbox(
                                                  grad: LinearGradient(
                                                    begin: Alignment(-0, -1),
                                                    end: Alignment(0, 1),
                                                    colors: [
                                                      Color(0xFF2F73F2),
                                                      Color(0xFF1A4FC4),
                                                    ],
                                                    stops: [0, 1],
                                                  ),
                                                  radius: BorderRadius.circular(
                                                    5,
                                                  ),
                                                  shadow: [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                        0,
                                                        0,
                                                        0,
                                                        0.08,
                                                      ),
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
                                                  pad: EdgeInsets.fromLTRB(
                                                    7,
                                                    1,
                                                    7,
                                                    1,
                                                  ),
                                                  child: Text(
                                                    plateOf(t),
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
                                                )),
                                          Expanded(
                                            flex: 1,
                                            child: SizedBox.shrink(),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFFDEFD6),
                                              Color.fromRGBO(
                                                245,
                                                165,
                                                36,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '待开工',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF855F2E),
                                                  Color(0xFFF0C46A),
                                                ),
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
                                        gap: 8,
                                      ),
                                      Text(
                                        itemsOf(t),
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
                                      hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s41, Svgs.s42),
                                            w: 14,
                                            h: 14,
                                          ),
                                          Flexible(
                                            flex: 89,
                                            child: Text(
                                              '预计 ${stClock(t['starts_at'])} 到店',
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  Color(0xFF71717A),
                                                  Color(0xFF9A9AA3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 6,
                                      ),
                                      Text(
                                        '${stDayLabel(t['starts_at'])} · 客户 ${t['customer']}',
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
                                    gap: 6,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
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

/// 技师工作台：今日任务、业绩与预计提成都来自服务端（只统计自己的预约订单）。
class StHomeLivePage extends StatelessWidget {
  const StHomeLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '工作台',
    load: merchantApi.staffHome,
    builder: (_, d) => StHomeTemplate(d: d),
  );
}
