import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PackageDetailPage extends StatelessWidget {
  const PackageDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 912,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: hcol(
              [
                hrow(
                  [
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
                        child: hrow(
                          [hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      back: true,
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '次卡详情',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 44),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [
                      Color(0xFF2A2A30),
                      Color(0xFF18181B),
                      Color(0xFF121214),
                    ],
                    stops: [0, 0.6, 1],
                  ),
                  radius: BorderRadius.circular(28),
                  shadow: [
                    BoxShadow(
                      color: Color.fromRGBO(24, 24, 27, 0.16),
                      offset: Offset(0, 10),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                  pad: EdgeInsets.fromLTRB(18, 18, 18, 18),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            hbox(
                              w: 84,
                              h: 84,
                              child: hstack(
                                hrow(
                                  [
                                    Flexible(
                                      flex: 30,
                                      child: IntrinsicWidth(
                                        child: hcol(
                                          [
                                            hcol(
                                              [
                                                Text(
                                                  '8',
                                                  style: hts(
                                                    24,
                                                    Color(0xFFFAFAFA),
                                                    w: FontWeight.w600,
                                                    lh: 26,
                                                  ),
                                                ),
                                                Text(
                                                  '剩余次',
                                                  style: hts(
                                                    10,
                                                    dk(
                                                      context,
                                                      Color(0xFFA1A1AA),
                                                      Color(0xFF80808A),
                                                    ),
                                                    w: FontWeight.w600,
                                                    lh: 14,
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
                                          gap: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                                [],
                                behind: [
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: hsvg(Svgs.s273, w: 84, h: 84),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '精致洗车年卡',
                                    style: hts(
                                      19,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w600,
                                      lh: 26,
                                    ),
                                  ),
                                  Text(
                                    '王建国 · 黑金会员',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 17,
                                    ),
                                  ),
                                  hbox(
                                    margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                    child: hrow(
                                      [
                                        Flexible(
                                          flex: 49,
                                          child: hbox(
                                            bg: Color.fromRGBO(
                                              23,
                                              201,
                                              100,
                                              0.2,
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '使用中',
                                              style: hts(
                                                11,
                                                Color(0xFF5FD48C),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 82,
                                          child: hbox(
                                            bg: Color.fromRGBO(
                                              245,
                                              165,
                                              36,
                                              0.2,
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '150 天后到期',
                                              style: hts(
                                                11,
                                                Color(0xFFF0C46A),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 6,
                                      intrinsic: true,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 3,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 16,
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
                                        '购买日期',
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
                                      Text(
                                        '2026.03.31',
                                        style: hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
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
                                        '到期日',
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
                                      Text(
                                        '2027.03.31',
                                        style: hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
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
                                        '实付',
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
                                      Text(
                                        '¥1,080',
                                        style: hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
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
                        right: -90,
                        bottom: -120,
                        child: hsvg(Svgs.s272, w: 240, h: 240),
                      ),
                    ],
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '包含服务',
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
                          hbox(
                            minH: 64,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 32,
                                  h: 32,
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s274, Svgs.s275),
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
                                        '精致洗车',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      Text(
                                        '剩余 8 次 / 共 20 次',
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
                                Text(
                                  '已用 12',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 19,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      Text(
                        '使用记录',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                        child: hstack(
                          hrow(
                            [
                              UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: hbox(
                                  w: 12,
                                  h: 12,
                                  bg: Color(0xFF0485F7),
                                  radius: BorderRadius.circular(6),
                                  shadow: [
                                    BoxShadow(
                                      color: Color(0xFFE1F0FE),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '核销 1 次',
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
                                      '沪A·8K29M · 技师 老周',
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
                                  gap: 2,
                                ),
                              ),
                              Text(
                                '今天 12:05',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 14,
                            intrinsic: true,
                          ),
                          [
                            Positioned(
                              left: 5,
                              top: 16,
                              bottom: -14,
                              width: 2,
                              child: hbox(
                                w: 2,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                        child: hstack(
                          hrow(
                            [
                              UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: hbox(
                                  w: 12,
                                  h: 12,
                                  bg: Color(0xFF0485F7),
                                  radius: BorderRadius.circular(6),
                                  shadow: [
                                    BoxShadow(
                                      color: Color(0xFFE1F0FE),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '核销 1 次',
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
                                      '沪A·8K29M · 技师 小林',
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
                                  gap: 2,
                                ),
                              ),
                              Text(
                                '10.20 16:40',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 14,
                            intrinsic: true,
                          ),
                          [
                            Positioned(
                              left: 5,
                              top: 16,
                              bottom: -14,
                              width: 2,
                              child: hbox(
                                w: 2,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                        child: hstack(
                          hrow(
                            [
                              UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: hbox(
                                  w: 12,
                                  h: 12,
                                  bg: Color(0xFF0485F7),
                                  radius: BorderRadius.circular(6),
                                  shadow: [
                                    BoxShadow(
                                      color: Color(0xFFE1F0FE),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '核销 1 次',
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
                                      '沪AF·09316 · 技师 老周',
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
                                  gap: 2,
                                ),
                              ),
                              Text(
                                '09.28 10:12',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 14,
                            intrinsic: true,
                          ),
                          [
                            Positioned(
                              left: 5,
                              top: 16,
                              bottom: -14,
                              width: 2,
                              child: hbox(
                                w: 2,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                        child: hstack(
                          hrow(
                            [
                              UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: hbox(
                                  w: 12,
                                  h: 12,
                                  bg: Color(0xFF0485F7),
                                  radius: BorderRadius.circular(6),
                                  shadow: [
                                    BoxShadow(
                                      color: Color(0xFFE1F0FE),
                                      offset: Offset(0, 0),
                                      blurRadius: 0,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '核销 1 次',
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
                                      '沪A·8K29M · 技师 老周',
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
                                  gap: 2,
                                ),
                              ),
                              Text(
                                '09.05 15:30',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 14,
                            intrinsic: true,
                          ),
                          [
                            Positioned(
                              left: 5,
                              top: 16,
                              bottom: -14,
                              width: 2,
                              child: hbox(
                                w: 2,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: hTap(
                          context,
                          hbox(
                            margin: EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: Text(
                              '查看全部 12 条记录',
                              style: hts(13, Color(0xFF0485F7)),
                            ),
                          ),
                          to: 'MemberRecords',
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 14,
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
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFE4E4E7),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF3A3A40),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '延期',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'PackageExtend',
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '退款',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'PackageRefund',
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '开单抵扣',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Order',
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}
