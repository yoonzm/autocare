import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class CardPackagesPage extends StatelessWidget {
  const CardPackagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 888,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 40),
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
                        '会员卡种与权益',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hTap(
                      context,
                      hbox(
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        radius: BorderRadius.circular(22),
                        child: hrow(
                          [hsvg(dk(context, Svgs.s58, Svgs.s59), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      to: 'PackageEdit',
                    ),
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
                                  '等级储值卡 4',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ),
                            to: 'CardTiers',
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: hTap(
                            context,
                            hbox(
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
                                  '次卡套餐 6',
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
                            to: 'CardPackages',
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
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '本月次卡营收',
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
                                  Text(
                                    '¥42,860',
                                    style: hts(
                                      32,
                                      Color(0xFFF5D78E),
                                      w: FontWeight.w600,
                                      lh: 38,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            hbox(
                              bg: Color.fromRGBO(23, 201, 100, 0.18),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                '较上月 +12%',
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
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.end,
                          gap: 0,
                        ),
                        hbox(
                          border: Border(
                            top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          ),
                          pad: EdgeInsets.fromLTRB(0, 12, 0, 0),
                          child: hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '本月售出',
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
                                        '38 张',
                                        style: hts(
                                          16,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 1,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '在用次卡',
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
                                        '214 张',
                                        style: hts(
                                          16,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 1,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '将到期',
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
                                        '18 张',
                                        style: hts(
                                          16,
                                          Color(0xFFF5A524),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 1,
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
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -118,
                        right: -98,
                        child: hsvg(Svgs.s60, w: 220, h: 220),
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
                  pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: hcol(
                    [
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s61, Svgs.s62),
                                      w: 22,
                                      h: 22,
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
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '20 次 · 12 个月有效 · 已售 86',
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
                                    gap: 3,
                                  ),
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 37,
                                        child: Text(
                                          '¥1,360',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '上架中',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s61, Svgs.s62),
                                      w: 22,
                                      h: 22,
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
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '10 次 · 6 个月有效 · 已售 142',
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
                                    gap: 3,
                                  ),
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 25,
                                        child: Text(
                                          '¥680',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '上架中',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFFDEFD6),
                                  Color.fromRGBO(245, 165, 36, 0.16),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s63, Svgs.s64),
                                      w: 22,
                                      h: 22,
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
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '6 次 · 12 个月有效 · 已售 48',
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
                                    gap: 3,
                                  ),
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 37,
                                        child: Text(
                                          '¥1,788',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '上架中',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s65, Svgs.s66),
                                      w: 22,
                                      h: 22,
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
                                      hrow(
                                        [
                                          Flexible(
                                            flex: 108,
                                            child: Text(
                                              '镀晶养护 3 次卡',
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
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '3 次 · 12 个月有效 · 已售 21',
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
                                    gap: 3,
                                  ),
                                ),
                              ),
                              hcol(
                                [
                                  Text(
                                    '¥2,980',
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 37,
                                        child: Text(
                                          '¥3,540',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '上架中',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s67, Svgs.s68),
                                      w: 22,
                                      h: 22,
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
                                      hrow(
                                        [
                                          Flexible(
                                            flex: 108,
                                            child: Text(
                                              '空调杀菌 4 次卡',
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
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '4 次 · 6 个月有效 · 已售 35',
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
                                    gap: 3,
                                  ),
                                ),
                              ),
                              hcol(
                                [
                                  Text(
                                    '¥380',
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 25,
                                        child: Text(
                                          '¥480',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '上架中',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(72, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                          opacity: .62,
                          child: hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFFFE1E2),
                                  Color.fromRGBO(255, 56, 60, 0.18),
                                ),
                                radius: BorderRadius.circular(14),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s69, Svgs.s70),
                                      w: 22,
                                      h: 22,
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
                                      hrow(
                                        [
                                          Flexible(
                                            flex: 75,
                                            child: Text(
                                              '新客体验卡',
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
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '3 次 · 3 个月有效 · 已售 0',
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
                                    gap: 3,
                                  ),
                                ),
                              ),
                              hcol(
                                [
                                  Text(
                                    '¥99',
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 25,
                                        child: Text(
                                          '¥204',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 16,
                                            deco: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 49,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFEEEEF0),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '已下架',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF52525B),
                                                Color(0xFFA8A8B3),
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
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.end,
                                gap: 3,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'PackageEdit',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    '次卡在开单时按项目自动抵扣；到期未用完的次数作废，如需延期可在会员的次卡详情里操作。',
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
