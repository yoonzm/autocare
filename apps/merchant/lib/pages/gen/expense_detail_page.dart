import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ExpenseDetailPage extends StatelessWidget {
  const ExpenseDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1100,
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
                        '开支详情',
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
                  pad: EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: hcol(
                    [
                      hbox(
                        w: 52,
                        h: 52,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s140, Svgs.s141),
                              w: 26,
                              h: 26,
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Text(
                        '材料采购',
                        style: hts(
                          14,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 20,
                        ),
                      ),
                      Text(
                        '−¥16,080.00',
                        style: hts(
                          36,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 44,
                          ls: -1.08,
                          tab: true,
                        ),
                      ),
                      hbox(
                        bg: dk(
                          context,
                          Color(0xFFDDF6E7),
                          Color.fromRGBO(23, 201, 100, 0.16),
                        ),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          '已付款',
                          style: hts(
                            11,
                            dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
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
                                '日期',
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
                              '2026.10.31 14:55',
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
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                '支付账户',
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
                              '对公转账',
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
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                '收款方',
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
                              '蓝盾膜业',
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
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                '记录人',
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
                              '陈明（店长）',
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
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      hTap(
                        context,
                        hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '来源',
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
                                '入库单 RK-20261031-03',
                                style: hts(
                                  15,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  lh: 22,
                                ),
                              ),
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'StockIn',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      hbox(
                        minH: 62,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '备注',
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
                              'TPU 车衣 6 卷、镀晶液 10 瓶，含运费 ¥120',
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
                        '凭证',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      hrow(
                        [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: hbox(
                              w: 88,
                              h: 88,
                              bg: dk(
                                context,
                                Color(0xFFEEEEF0),
                                Color(0xFF27272A),
                              ),
                              radius: BorderRadius.circular(16),
                              child: hcol(
                                [
                                  hsvg(
                                    dk(context, Svgs.s142, Svgs.s143),
                                    w: 26,
                                    h: 26,
                                  ),
                                  Text(
                                    '送货单',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 4,
                                min: false,
                              ),
                            ),
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: hbox(
                              w: 88,
                              h: 88,
                              bg: dk(
                                context,
                                Color(0xFFEEEEF0),
                                Color(0xFF27272A),
                              ),
                              radius: BorderRadius.circular(16),
                              child: hcol(
                                [
                                  hsvg(
                                    dk(context, Svgs.s142, Svgs.s143),
                                    w: 26,
                                    h: 26,
                                  ),
                                  Text(
                                    '转账回单',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 4,
                                min: false,
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
                      bg: dk(
                        context,
                        Color(0xFFFFE1E2),
                        Color.fromRGBO(255, 56, 60, 0.18),
                      ),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '删除',
                          style: hts(
                            15,
                            dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Expenses',
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: hrow(
                        [
                          hsvg(dk(context, Svgs.s144, Svgs.s145), w: 18, h: 18),
                          Flexible(
                            flex: 30,
                            child: Text(
                              '编辑',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 6,
                      ),
                    ),
                    to: 'ExpenseAdd',
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
