import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class RechargeCardPage extends StatelessWidget {
  const RechargeCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1060,
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
                        '会员充值',
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
                          child: hTap(
                            context,
                            hbox(
                              h: 34,
                              radius: BorderRadius.circular(17),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  '储值充值',
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
                              ),
                            ),
                            to: 'Recharge',
                          ),
                        ),
                      ),
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
                              alignment: Alignment(0, 0),
                              widthFactor: 1,
                              child: Text(
                                '购买次卡',
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
                    hbox(
                      bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(22),
                      pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: hrow(
                        [
                          hbox(
                            w: 44,
                            h: 44,
                            bg: Color(0xFFF5D78E),
                            radius: BorderRadius.circular(22),
                            align: Alignment(0, 0),
                            child: Text(
                              '王',
                              style: hts(
                                17,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '王建国',
                                  style: hts(
                                    16,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w600,
                                    lh: 22,
                                  ),
                                ),
                                Text(
                                  '138 **** 6021 · 沪A·8K29M',
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
                              gap: 2,
                            ),
                          ),
                          hbox(
                            bg: Color(0xFFF5D78E),
                            radius: BorderRadius.circular(9),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              '黑金会员',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
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
                        gap: 12,
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          Text(
                            '选择套餐',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          HSelHolder(
                            groups: [
                              ({0}, false),
                            ],
                            builder: (context, g1) => hcol(
                              [
                                HSel(
                                  ctrl: g1[0],
                                  index: 0,
                                  on: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 90,
                                                    child: Text(
                                                      '精致洗车年卡',
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
                                                  Flexible(
                                                    flex: 38,
                                                    child: hbox(
                                                      bg: dk(
                                                        context,
                                                        Color(0xFFFFE1E2),
                                                        Color.fromRGBO(
                                                          255,
                                                          56,
                                                          60,
                                                          0.18,
                                                        ),
                                                      ),
                                                      radius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                      pad: EdgeInsets.fromLTRB(
                                                        8,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                      child: Text(
                                                        '热卖',
                                                        style: hts(
                                                          11,
                                                          dk(
                                                            context,
                                                            Color(0xFFA43433),
                                                            Color(0xFFFF7B7E),
                                                          ),
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
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '20 次 · 12 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥1,080',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥1,360',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          bg: Color(0xFF0485F7),
                                          radius: BorderRadius.circular(11),
                                          child: hrow(
                                            [hsvg(Svgs.s309, w: 14, h: 14)],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  off: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 90,
                                                    child: Text(
                                                      '精致洗车年卡',
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
                                                  Flexible(
                                                    flex: 38,
                                                    child: hbox(
                                                      bg: dk(
                                                        context,
                                                        Color(0xFFFFE1E2),
                                                        Color.fromRGBO(
                                                          255,
                                                          56,
                                                          60,
                                                          0.18,
                                                        ),
                                                      ),
                                                      radius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                      pad: EdgeInsets.fromLTRB(
                                                        8,
                                                        0,
                                                        8,
                                                        0,
                                                      ),
                                                      child: Text(
                                                        '热卖',
                                                        style: hts(
                                                          11,
                                                          dk(
                                                            context,
                                                            Color(0xFFA43433),
                                                            Color(0xFFFF7B7E),
                                                          ),
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
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '20 次 · 12 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥1,080',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥1,360',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          bg: Color(0xFF0485F7),
                                          radius: BorderRadius.circular(11),
                                          child: hrow(
                                            [hsvg(Svgs.s309, w: 14, h: 14)],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g1[0],
                                  index: 1,
                                  on: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 116,
                                                    child: Text(
                                                      '精致洗车 10 次卡',
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
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '10 次 · 6 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥580',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥680',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          radius: BorderRadius.circular(11),
                                          border: dk(
                                            context,
                                            Border.all(
                                              color: Color(0xFFD4D4D8),
                                              width: 2,
                                            ),
                                            Border.all(
                                              color: Color(0xFF3F3F46),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  off: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 116,
                                                    child: Text(
                                                      '精致洗车 10 次卡',
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
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '10 次 · 6 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥580',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥680',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          radius: BorderRadius.circular(11),
                                          border: dk(
                                            context,
                                            Border.all(
                                              color: Color(0xFFD4D4D8),
                                              width: 2,
                                            ),
                                            Border.all(
                                              color: Color(0xFF3F3F46),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g1[0],
                                  index: 2,
                                  on: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 138,
                                                    child: Text(
                                                      '内饰深度清洁 6 次卡',
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
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '6 次 · 12 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥1,380',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥1,788',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          radius: BorderRadius.circular(11),
                                          border: dk(
                                            context,
                                            Border.all(
                                              color: Color(0xFFD4D4D8),
                                              width: 2,
                                            ),
                                            Border.all(
                                              color: Color(0xFF3F3F46),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  off: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              hrow(
                                                [
                                                  Flexible(
                                                    flex: 138,
                                                    child: Text(
                                                      '内饰深度清洁 6 次卡',
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
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                              Text(
                                                '6 次 · 12 个月有效',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF52525B),
                                                    Color(0xFFA8A8B3),
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
                                        hcol(
                                          [
                                            Text(
                                              '¥1,380',
                                              style: hts(
                                                16,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                            ),
                                            Text(
                                              '¥1,788',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                                lh: 14,
                                                deco:
                                                    TextDecoration.lineThrough,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.end,
                                          gap: 0,
                                        ),
                                        hbox(
                                          w: 22,
                                          h: 22,
                                          radius: BorderRadius.circular(11),
                                          border: dk(
                                            context,
                                            Border.all(
                                              color: Color(0xFFD4D4D8),
                                              width: 2,
                                            ),
                                            Border.all(
                                              color: Color(0xFF3F3F46),
                                              width: 2,
                                            ),
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
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: hTap(
                              context,
                              Text(
                                '查看全部 5 个在售套餐',
                                style: hts(13, Color(0xFF0485F7)),
                              ),
                              to: 'RechargePick',
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          Text(
                            '收款方式',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          HSelHolder(
                            groups: [
                              ({0}, false),
                            ],
                            builder: (context, g2) => hwrap(
                              [
                                HSel(
                                  ctrl: g2[0],
                                  index: 0,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '微信',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF1E63AE),
                                            Color(0xFF6AB4FA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '微信',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF3F3F46),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g2[0],
                                  index: 1,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '支付宝',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF1E63AE),
                                            Color(0xFF6AB4FA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '支付宝',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF3F3F46),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g2[0],
                                  index: 2,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '现金',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF1E63AE),
                                            Color(0xFF6AB4FA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '现金',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF3F3F46),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g2[0],
                                  index: 3,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        'POS 刷卡',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF1E63AE),
                                            Color(0xFF6AB4FA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        'POS 刷卡',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF3F3F46),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                HSel(
                                  ctrl: g2[0],
                                  index: 4,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: Color(0xFF0485F7),
                                      width: 1.5,
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '储值余额 ¥3,680',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF1E63AE),
                                            Color(0xFF6AB4FA),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '储值余额 ¥3,680',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF3F3F46),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              gap: 8,
                              rowGap: 8,
                              cross: WrapCrossAlignment.start,
                            ),
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '经办人',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                              Text(
                                '陈明（店长）',
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          Text(
                            '会员卡种折扣不叠加在次卡套餐上',
                            style: hts(
                              12,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
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
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '原价合计',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥1,360',
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '套餐优惠',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '−¥280',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF2B7745),
                                      Color(0xFF5FD48C),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '应收',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥1,080.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 28,
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
                  gap: 16,
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
                          '取消',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'MemberDetail',
                  ),
                ),
                Expanded(
                  flex: 16,
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
                          '确认收款 ¥1,080',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'PackageSold',
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
