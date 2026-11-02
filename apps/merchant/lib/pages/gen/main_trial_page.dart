import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class MainTrialPage extends StatelessWidget {
  const MainTrialPage({super.key});

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
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          Text(
                            '周六 · 10月31日',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 18,
                            ),
                          ),
                          hTap(
                            context,
                            hrow(
                              [
                                Flexible(
                                  flex: 132,
                                  child: Text(
                                    '驰光汽车美容',
                                    style: hts(
                                      22,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 30,
                                      ls: -0.44,
                                    ),
                                  ),
                                ),
                                hsvg(
                                  dk(context, Svgs.s173, Svgs.s174),
                                  w: 18,
                                  h: 18,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 4,
                            ),
                            to: 'StoreSwitch',
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hTap(
                      context,
                      hbox(
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                        child: hstack(
                          hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s175, Svgs.s176),
                                w: 20,
                                h: 20,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          [
                            Positioned(
                              top: 11,
                              right: 12,
                              width: 8,
                              height: 8,
                              child: hbox(
                                w: 8,
                                h: 8,
                                bg: Color(0xFFFF383C),
                                radius: BorderRadius.circular(4),
                                shadow: dk(
                                  context,
                                  [
                                    BoxShadow(
                                      color: Color(0xFFFFFFFF),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  [
                                    BoxShadow(
                                      color: Color(0xFF18181B),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      to: 'Messages',
                    ),
                    hTap(
                      context,
                      hbox(
                        w: 44,
                        h: 44,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(22),
                        shadow: dk(
                          context,
                          [
                            BoxShadow(
                              color: Color(0xFFFFFFFF),
                              offset: Offset(0, 0),
                              blurRadius: 0,
                              spreadRadius: 3,
                            ),
                          ],
                          [
                            BoxShadow(
                              color: Color(0xFF18181B),
                              offset: Offset(0, 0),
                              blurRadius: 0,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                        align: Alignment(0, 0),
                        child: Text(
                          '陈',
                          style: hts(16, Color(0xFFFFFFFF), w: FontWeight.w600),
                        ),
                      ),
                      to: 'Settings',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
                hbox(
                  bg: dk(
                    context,
                    Color(0xFFFFE1E2),
                    Color.fromRGBO(255, 56, 60, 0.18),
                  ),
                  radius: BorderRadius.circular(22),
                  pad: EdgeInsets.fromLTRB(14, 12, 12, 12),
                  child: hrow(
                    [
                      hbox(
                        w: 36,
                        h: 36,
                        bg: dk(
                          context,
                          Color.fromRGBO(255, 255, 255, 0.7),
                          Color.fromRGBO(9, 9, 11, 0.92),
                        ),
                        radius: BorderRadius.circular(18),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s205, Svgs.s99),
                              w: 18,
                              h: 18,
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '试用剩余 3 天',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF8A2A29),
                                    Color(0xFFFF7B7E),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                              hbox(
                                opacity: .8,
                                child: Text(
                                  '11.14 结束，之后进入只读模式',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF8A2A29),
                                      Color(0xFFFF7B7E),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                          ),
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          h: 34,
                          bg: Color(0xFFA43433),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment(-1, 0),
                            widthFactor: 1,
                            child: Text(
                              '去订阅',
                              style: hts(
                                13,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        to: 'Plans',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  border: dk(
                    context,
                    null,
                    Border(
                      top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      bottom: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                    ),
                  ),
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '今日营业额（元）',
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
                                  Text(
                                    '12,860.00',
                                    style: hts(
                                      34,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 40,
                                      ls: -1.02,
                                      tab: true,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      hsvg(Svgs.s180, w: 14, h: 14),
                                      Flexible(
                                        flex: 90,
                                        child: Text(
                                          '较上周六 +18.4%',
                                          style: hts(
                                            12,
                                            Color(0xFF4ADE80),
                                            w: FontWeight.w500,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 4,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 4,
                              ),
                            ),
                            hbox(
                              h: 64,
                              child: hrow(
                                [
                                  hbox(
                                    w: 10,
                                    h: 30,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 22,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 38,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 28,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 44,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 52,
                                    bg: Color(0xFF3F3F46),
                                    radius: BorderRadius.circular(5),
                                  ),
                                  hbox(
                                    w: 10,
                                    h: 64,
                                    bg: Color(0xFF0485F7),
                                    radius: BorderRadius.circular(5),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 6,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.end,
                          gap: 12,
                        ),
                        hbox(
                          border: Border(
                            top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          ),
                          pad: EdgeInsets.fromLTRB(0, 14, 0, 0),
                          child: hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '订单数',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      Text(
                                        '36',
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
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
                                        '新增会员',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      Text(
                                        '5',
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
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
                                        '客单价',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      Text(
                                        '¥357',
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                              ],
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                              min: false,
                            ),
                          ], gap: 8),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 16,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -100,
                        right: -90,
                        child: hsvg(Svgs.s178, w: 220, h: 220),
                      ),
                    ],
                  ),
                ),
                hcol([
                  SizedBox(
                    height: 190,
                    child: hrow(
                      [
                        Expanded(
                          child: hTap(
                            context,
                            hbox(
                              bg: Color(0xFF0485F7),
                              radius: BorderRadius.circular(28),
                              pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                              clip: true,
                              child: hstack(
                                hcol(
                                  [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hbox(
                                        w: 44,
                                        h: 44,
                                        bg: dk(
                                          context,
                                          Color.fromRGBO(255, 255, 255, 0.2),
                                          Color.fromRGBO(9, 9, 11, 0.92),
                                        ),
                                        radius: BorderRadius.circular(22),
                                        child: hrow(
                                          [hsvg(Svgs.s190, w: 22, h: 22)],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                    hcol(
                                      [
                                        Text(
                                          '开单收银',
                                          style: hts(
                                            20,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w700,
                                            lh: 26,
                                          ),
                                        ),
                                        hbox(
                                          opacity: .85,
                                          child: Text(
                                            '选车 · 选服务 · 收款',
                                            style: hts(
                                              12,
                                              Color(0xFFFFFFFF),
                                              lh: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 4,
                                    ),
                                  ],
                                  main: MainAxisAlignment.spaceBetween,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 0,
                                ),
                                [],
                                behind: [
                                  Positioned(
                                    right: -96,
                                    bottom: -96,
                                    child: hsvg(Svgs.s189, w: 190, h: 190),
                                  ),
                                ],
                              ),
                            ),
                            to: 'Order',
                          ),
                        ),
                        Expanded(
                          child: hcol([
                            SizedBox(
                              height: 90,
                              child: hTap(
                                context,
                                hbox(
                                  minH: 76,
                                  bg: dk(
                                    context,
                                    Color(0xFFDDF6E7),
                                    Color.fromRGBO(23, 201, 100, 0.16),
                                  ),
                                  radius: BorderRadius.circular(24),
                                  pad: EdgeInsets.fromLTRB(14, 14, 14, 14),
                                  clip: true,
                                  child: hstack(
                                    hcol(
                                      [
                                        hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s183, Svgs.s184),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Flexible(
                                              flex: 60,
                                              child: Text(
                                                '会员充值',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF1F5E37),
                                                    Color(0xFF5FD48C),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 8,
                                        ),
                                        hbox(
                                          opacity: .75,
                                          child: Text(
                                            '今日 ¥12,600',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF1F5E37),
                                                Color(0xFF5FD48C),
                                              ),
                                              lh: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.spaceBetween,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                    [],
                                    behind: [
                                      Positioned(
                                        right: -22,
                                        bottom: -24,
                                        child: hsvg(
                                          dk(context, Svgs.s181, Svgs.s182),
                                          w: 64,
                                          h: 64,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                to: 'Recharge',
                              ),
                            ),
                            SizedBox(
                              height: 90,
                              child: hTap(
                                context,
                                hbox(
                                  minH: 76,
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(24),
                                  pad: EdgeInsets.fromLTRB(14, 14, 14, 14),
                                  clip: true,
                                  child: hstack(
                                    hcol(
                                      [
                                        hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s187, Svgs.s188),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Flexible(
                                              flex: 60,
                                              child: Text(
                                                '商品入库',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF6B4A1F),
                                                    Color(0xFFF0C46A),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 22,
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 8,
                                        ),
                                        hbox(
                                          opacity: .75,
                                          child: Text(
                                            '3 件待补货',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF6B4A1F),
                                                Color(0xFFF0C46A),
                                              ),
                                              lh: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.spaceBetween,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                    [],
                                    behind: [
                                      Positioned(
                                        right: -22,
                                        bottom: -24,
                                        child: hsvg(
                                          dk(context, Svgs.s185, Svgs.s186),
                                          w: 64,
                                          h: 64,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                to: 'Inventory',
                              ),
                            ),
                          ], gap: 10),
                        ),
                      ],
                      cross: CrossAxisAlignment.stretch,
                      gap: 10,
                      min: false,
                    ),
                  ),
                  SizedBox(
                    height: 64,
                    child: hTap(
                      context,
                      hbox(
                        bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                        radius: BorderRadius.circular(24),
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        clip: true,
                        border: dk(
                          context,
                          null,
                          Border(
                            top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                            right: BorderSide(
                              color: Color(0xFF2E2E33),
                              width: 1,
                            ),
                            bottom: BorderSide(
                              color: Color(0xFF2E2E33),
                              width: 1,
                            ),
                            left: BorderSide(
                              color: Color(0xFF2E2E33),
                              width: 1,
                            ),
                          ),
                        ),
                        child: hstack(
                          hrow(
                            [
                              hbox(
                                w: 36,
                                h: 36,
                                bg: Color(0xFFF5D78E),
                                radius: BorderRadius.circular(18),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s193, Svgs.s194),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '预约管理',
                                      style: hts(
                                        15,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '待到店 2 · 下一位 17:30 刘先生',
                                      style: hts(
                                        12,
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
                                  gap: 0,
                                ),
                              ),
                              hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s195, Svgs.s196),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.start,
                                gap: 0,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          [],
                          behind: [
                            Positioned(
                              top: -70,
                              right: -66,
                              child: hsvg(Svgs.s191, w: 190, h: 190),
                            ),
                          ],
                        ),
                      ),
                      to: 'Appointments',
                    ),
                  ),
                ], gap: 10),
                hcol(
                  [
                    hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: Text.rich(
                            TextSpan(
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
                              children: [
                                TextSpan(
                                  text: '施工中 ',
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
                                TextSpan(
                                  text: '· 2 个工位',
                                  style: hts(
                                    17,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        hTap(
                          context,
                          Text(
                            '全部',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                          to: 'HoldList',
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    hTap(
                      context,
                      hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                                  bg: Color(0xFF0B5FD6),
                                  radius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Color(0xFF5B9BF0),
                                    width: 1.5,
                                  ),
                                  pad: EdgeInsets.fromLTRB(8, 3, 8, 3),
                                  child: Text(
                                    '沪A·8K29M',
                                    style: hts(
                                      13,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w600,
                                      lh: 18,
                                      ls: 0.52,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '宝马 5系 · 黑',
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
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '3 号工位',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '镀晶养护 · 内饰精洗',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                Text(
                                  '预计 17:00',
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
                              cross: CrossAxisAlignment.baseline,
                              gap: 8,
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
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.65,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFF0485F7),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                ),
                                Text(
                                  '65%',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                    tab: true,
                                  ),
                                ),
                                hbox(
                                  w: 24,
                                  h: 24,
                                  bg: dk(
                                    context,
                                    Color(0xFFE4E4E7),
                                    Color(0xFF3A3A40),
                                  ),
                                  radius: BorderRadius.circular(12),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '周',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
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
                          gap: 12,
                        ),
                      ),
                      to: 'HoldList',
                    ),
                    hTap(
                      context,
                      hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                                  bg: Color(0xFFD7F5E1),
                                  radius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Color(0xFF86D9A4),
                                    width: 1.5,
                                  ),
                                  pad: EdgeInsets.fromLTRB(8, 3, 8, 3),
                                  child: Text(
                                    '沪AD·61207',
                                    style: hts(
                                      13,
                                      Color(0xFF14532D),
                                      w: FontWeight.w600,
                                      lh: 18,
                                      ls: 0.52,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '特斯拉 Model Y · 白',
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
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '贴膜间',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '全车隐形车衣',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                Text(
                                  '预计 明天 18:00',
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
                              cross: CrossAxisAlignment.baseline,
                              gap: 8,
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
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.3,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFFF5A524),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                ),
                                Text(
                                  '30%',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                    tab: true,
                                  ),
                                ),
                                hbox(
                                  w: 24,
                                  h: 24,
                                  bg: dk(
                                    context,
                                    Color(0xFFE4E4E7),
                                    Color(0xFF3A3A40),
                                  ),
                                  radius: BorderRadius.circular(12),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '张',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
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
                          gap: 12,
                        ),
                      ),
                      to: 'HoldList',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 12,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 20,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [
        HBottomDock(
          child: hbox(
            h: 108,
            child: hstack(
              hcol(
                [],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 0,
                min: false,
              ),
              [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 84,
                  child: hbox(
                    h: 84,
                    child: hcol(
                      [
                        Align(
                          alignment: Alignment.topLeft,
                          child: hbox(
                            w: 390,
                            h: 84,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
                      min: false,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 84,
                  child: hbox(
                    h: 84,
                    pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: hcol([
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hTap(
                              context,
                              hbox(
                                pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: hcol(
                                  [
                                    hsvg(Svgs.s197, w: 24, h: 24),
                                    Text(
                                      '首页',
                                      style: hts(
                                        11,
                                        Color(0xFF0485F7),
                                        w: FontWeight.w600,
                                        lh: 14,
                                      ),
                                    ),
                                    hbox(
                                      w: 4,
                                      h: 4,
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(2),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 3,
                                ),
                              ),
                              to: 'Main',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hTap(
                              context,
                              hbox(
                                pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: hcol(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s198, Svgs.s199),
                                      w: 24,
                                      h: 24,
                                    ),
                                    Text(
                                      '会员',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 14,
                                      ),
                                    ),
                                    hbox(w: 4, h: 4),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 3,
                                ),
                              ),
                              to: 'Members',
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox.shrink()),
                          Expanded(
                            flex: 1,
                            child: hTap(
                              context,
                              hbox(
                                pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: hcol(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s200, Svgs.s201),
                                      w: 24,
                                      h: 24,
                                    ),
                                    Text(
                                      '库存',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 14,
                                      ),
                                    ),
                                    hbox(w: 4, h: 4),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 3,
                                ),
                              ),
                              to: 'Inventory',
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hTap(
                              context,
                              hbox(
                                pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: hcol(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s202, Svgs.s203),
                                      w: 24,
                                      h: 24,
                                    ),
                                    Text(
                                      '统计',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 14,
                                      ),
                                    ),
                                    hbox(w: 4, h: 4),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 3,
                                ),
                              ),
                              to: 'Stats',
                            ),
                          ),
                        ],
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                        intrinsic: true,
                        min: false,
                      ),
                    ], gap: 0),
                  ),
                ),
                Positioned(
                  top: 0,
                  width: 56,
                  height: 56,
                  child: hTap(
                    context,
                    NegMargin(
                      top: 0,
                      left: -28,
                      child: hbox(
                        w: 56,
                        h: 56,
                        grad: LinearGradient(
                          begin: Alignment(-0.574, -0.819),
                          end: Alignment(0.574, 0.819),
                          colors: [
                            Color(0xFF4DB0FF),
                            Color(0xFF0485F7),
                            Color(0xFF0568D8),
                          ],
                          stops: [0, 0.55, 1],
                        ),
                        radius: BorderRadius.circular(28),
                        shadow: [
                          BoxShadow(
                            color: Color.fromRGBO(4, 133, 247, 0.35),
                            offset: Offset(0, 2),
                            blurRadius: 6,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(4, 133, 247, 0.55),
                            offset: Offset(0, 10),
                            blurRadius: 26,
                            spreadRadius: 0,
                          ),
                        ],
                        child: hrow(
                          [hsvg(Svgs.s425, w: 26, h: 26)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
                    to: 'FindScanPlate',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
