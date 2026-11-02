import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1862,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
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
                        '选择套餐',
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
                  child: HSelHolder(
                    groups: [
                      ({1}, false),
                    ],
                    builder: (context, g1) => hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 0,
                              on: hbox(
                                h: 36,
                                radius: BorderRadius.circular(16),
                                shadow: dk(context, [
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
                                ], null),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '月付',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 36,
                                radius: BorderRadius.circular(16),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '月付',
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
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 1,
                              on: hbox(
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(16),
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
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '年付 ',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 20,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '省 2 个月',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(16),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '年付 ',
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
                                        TextSpan(
                                          text: '省 2 个月',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 20,
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
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(28),
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
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: hcol(
                    [
                      hrow(
                        [
                          Text(
                            '基础版',
                            style: hts(
                              18,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 26,
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox.shrink()),
                          hbox(
                            w: 24,
                            h: 24,
                            radius: BorderRadius.circular(12),
                            border: dk(
                              context,
                              Border.all(color: Color(0xFFD4D4D8), width: 2),
                              Border.all(color: Color(0xFF3F3F46), width: 2),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      Text(
                        '单店起步，开单与会员管理',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                      hrow(
                        [
                          Text(
                            '¥166',
                            style: hts(
                              32,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 38,
                              ls: -1,
                            ),
                          ),
                          Text(
                            '/月 · 年付',
                            style: hts(
                              13,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox.shrink()),
                          Text(
                            '年付 ¥1,990',
                            style: hts(
                              12,
                              dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 4,
                      ),
                      hcol(
                        [
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 141,
                                child: Text(
                                  '1 家门店 · 3 个员工账号',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 173,
                                child: Text(
                                  '开单收银 · 会员 · 挂单 · 库存',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 95,
                                child: Text(
                                  '每月 200 条短信',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s308, w: 14, h: 14),
                              Flexible(
                                flex: 117,
                                child: Text(
                                  '预约管理与微信通知',
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
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
                  shadow: [
                    BoxShadow(
                      color: Color(0xFF0485F7),
                      offset: Offset(0, 0),
                      blurRadius: 0,
                      spreadRadius: 2,
                    ),
                  ],
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
                            Text(
                              '专业版',
                              style: hts(
                                18,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 26,
                              ),
                            ),
                            hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                '推荐',
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
                            Expanded(flex: 1, child: SizedBox.shrink()),
                            hbox(
                              w: 24,
                              h: 24,
                              bg: Color(0xFF0485F7),
                              radius: BorderRadius.circular(12),
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
                          gap: 8,
                        ),
                        Text(
                          '预约、微信通知与经营分析',
                          style: hts(
                            13,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 18,
                          ),
                        ),
                        hrow(
                          [
                            Text(
                              '¥333',
                              style: hts(
                                36,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 40,
                                ls: -1,
                              ),
                            ),
                            Text(
                              '/月 · 年付',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                              ),
                            ),
                            Expanded(flex: 1, child: SizedBox.shrink()),
                            Text(
                              '年付 ¥3,990 · 省 2 个月',
                              style: hts(12, Color(0xFFF5D78E)),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.baseline,
                          gap: 4,
                        ),
                        hcol(
                          [
                            hrow(
                              [
                                hsvg(Svgs.s310, w: 14, h: 14),
                                Flexible(
                                  flex: 149,
                                  child: Text(
                                    '3 家门店 · 10 个员工账号',
                                    style: hts(13, Color(0xFFE4E4E7), lh: 18),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hrow(
                              [
                                hsvg(Svgs.s310, w: 14, h: 14),
                                Flexible(
                                  flex: 91,
                                  child: Text(
                                    '基础版全部功能',
                                    style: hts(13, Color(0xFFE4E4E7), lh: 18),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hrow(
                              [
                                hsvg(Svgs.s310, w: 14, h: 14),
                                Flexible(
                                  flex: 159,
                                  child: Text(
                                    '预约管理 · 微信 / 短信通知',
                                    style: hts(13, Color(0xFFE4E4E7), lh: 18),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hrow(
                              [
                                hsvg(Svgs.s310, w: 14, h: 14),
                                Flexible(
                                  flex: 157,
                                  child: Text(
                                    '开支管理与预算 · 数据导出',
                                    style: hts(13, Color(0xFFE4E4E7), lh: 18),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hrow(
                              [
                                hsvg(Svgs.s310, w: 14, h: 14),
                                Flexible(
                                  flex: 109,
                                  child: Text(
                                    '每月 1,000 条短信',
                                    style: hts(13, Color(0xFFE4E4E7), lh: 18),
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
                          gap: 8,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -110,
                        right: -110,
                        child: hsvg(Svgs.s7, w: 240, h: 240),
                      ),
                    ],
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(28),
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
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: hcol(
                    [
                      hrow(
                        [
                          Text(
                            '旗舰版',
                            style: hts(
                              18,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 26,
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox.shrink()),
                          hbox(
                            w: 24,
                            h: 24,
                            radius: BorderRadius.circular(12),
                            border: dk(
                              context,
                              Border.all(color: Color(0xFFD4D4D8), width: 2),
                              Border.all(color: Color(0xFF3F3F46), width: 2),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      Text(
                        '连锁多店，专属服务',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                      hrow(
                        [
                          Text(
                            '¥583',
                            style: hts(
                              32,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 38,
                              ls: -1,
                            ),
                          ),
                          Text(
                            '/月 · 年付',
                            style: hts(
                              13,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            ),
                          ),
                          Expanded(flex: 1, child: SizedBox.shrink()),
                          Text(
                            '年付 ¥6,990',
                            style: hts(
                              12,
                              dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 4,
                      ),
                      hcol(
                        [
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 150,
                                child: Text(
                                  '10 家门店 · 不限员工账号',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 91,
                                child: Text(
                                  '专业版全部功能',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 143,
                                child: Text(
                                  '连锁总部看板与统一会员',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 109,
                                child: Text(
                                  '每月 3,000 条短信',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 144,
                                child: Text(
                                  '专属客服 · 优先上门培训',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
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
                        gap: 8,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '功能对比',
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
                      pad: EdgeInsets.fromLTRB(0, 6, 0, 6),
                      child: hcol(
                        [
                          hbox(
                            minH: 36,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '基础版',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '专业版',
                                    style: hts(
                                      12,
                                      Color(0xFF0485F7),
                                      w: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '旗舰版',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '门店数',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '1',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '3',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '10',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '员工账号',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '3',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '10',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '不限',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '每月短信',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '200',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '1,000',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '3,000',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '开单 · 会员 · 库存',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '预约管理',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '微信通知',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '开支与预算',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '数据导出',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '连锁总部看板',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hbox(
                            minH: 40,
                            pad: EdgeInsets.fromLTRB(16, 0, 12, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '专属客服',
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
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '—',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                hbox(
                                  w: 64,
                                  align: Alignment.center,
                                  child: Text(
                                    '✓',
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
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
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
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '常见问题',
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
                            minH: 50,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '试用期结束后会自动扣费吗',
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
                                  '不会',
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
                            minH: 50,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '年付可以退款吗',
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
                                  '7 天内可退',
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
                            minH: 50,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '随时升级套餐',
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
                                  '按剩余天数补差价',
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
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '专业版 · 年付',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                      Text.rich(
                        TextSpan(
                          style: hts(
                            20,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 26,
                          ),
                          children: [
                            TextSpan(
                              text: '¥3,990 ',
                              style: hts(
                                20,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 26,
                              ),
                            ),
                            TextSpan(
                              text: '/年',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 26,
                              ),
                            ),
                          ],
                        ),
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
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    pad: EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '立即订阅',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'PlanCheckout',
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
