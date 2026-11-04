import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1300,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: HSelHolder(
              groups: [
                ({0}, false),
              ],
              builder: (context, g1) => HDyn(
                texts: [
                  '今天实收 ¥4,182 · 退款 ¥432全车镀晶 · 9H12:05 · 储值 + 微信 · 王建国¥1,422精致洗车11:40 · 微信 · 沪B·Q5566¥68储值充值 · 送 ¥30010:20 · 微信 · 李女士¥2,000次卡售卖 · 精致洗车年卡09:50 · 支付宝 · 周先生¥1,080次卡退款09:15 · 原路退回 · 陈先生-¥432漆面抛光08:30 · 现金 · 沪A·F2210¥612',
                  '昨天 11.02实收 ¥2,860车身打蜡17:20 · 微信 · 沪C·D9981¥198内饰深度清洁15:05 · 次卡抵扣 · 沪AF·09316¥0储值充值11:30 · 现金 · 赵先生¥2,000',
                ],
                filter: g1[0],
                labels: ['全部', '消费', '充值', '次卡', '退款'],
                builder: (context, d2) => hcol(
                  [
                    hrow(
                      [
                        hTap(
                          context,
                          hbox(
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
                          back: true,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '订单',
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
                          ({0}, false),
                        ],
                        builder: (context, g3) => hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: HSel(
                                  ctrl: g3[0],
                                  index: 0,
                                  segment: true,
                                  on: hbox(
                                    h: 32,
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
                                      child: Text(
                                        '今日',
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
                                    ),
                                  ),
                                  off: hbox(
                                    h: 32,
                                    radius: BorderRadius.circular(16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '今日',
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
                                  ctrl: g3[0],
                                  index: 1,
                                  segment: true,
                                  on: hbox(
                                    h: 32,
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
                                      child: Text(
                                        '昨日',
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
                                    ),
                                  ),
                                  off: hbox(
                                    h: 32,
                                    radius: BorderRadius.circular(16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '昨日',
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
                                  ctrl: g3[0],
                                  index: 2,
                                  segment: true,
                                  on: hbox(
                                    h: 32,
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
                                      child: Text(
                                        '本周',
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
                                    ),
                                  ),
                                  off: hbox(
                                    h: 32,
                                    radius: BorderRadius.circular(16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '本周',
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
                                  ctrl: g3[0],
                                  index: 3,
                                  segment: true,
                                  on: hbox(
                                    h: 32,
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
                                      child: Text(
                                        '本月',
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
                                    ),
                                  ),
                                  off: hbox(
                                    h: 32,
                                    radius: BorderRadius.circular(16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '本月',
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
                                  ctrl: g3[0],
                                  index: 4,
                                  segment: true,
                                  on: hbox(
                                    h: 32,
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
                                      child: Text(
                                        '自定义',
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
                                    ),
                                  ),
                                  off: hbox(
                                    h: 32,
                                    radius: BorderRadius.circular(16),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '自定义',
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
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '今日收款',
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
                                '11.03 周二',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '实收',
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
                                    Text(
                                      '¥4,182',
                                      style: hts(
                                        20,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 26,
                                        ls: -0.4,
                                        tab: true,
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
                                      '退款',
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
                                    Text(
                                      '¥432',
                                      style: hts(
                                        20,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 26,
                                        ls: -0.4,
                                        tab: true,
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
                                      '净收入',
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
                                    Text(
                                      '¥3,750',
                                      style: hts(
                                        20,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 26,
                                        ls: -0.4,
                                        tab: true,
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
                            gap: 8,
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hcol(
                            [
                              Text(
                                '按收款方式',
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
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                      child: hcol(
                                        [
                                          Text(
                                            '微信',
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
                                          Text(
                                            '¥2,490',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                              tab: true,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                      child: hcol(
                                        [
                                          Text(
                                            '支付宝',
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
                                          Text(
                                            '¥1,080',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                              tab: true,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 1,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                                intrinsic: true,
                              ),
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                      child: hcol(
                                        [
                                          Text(
                                            '现金',
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
                                          Text(
                                            '¥612',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                              tab: true,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 1,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(12, 8, 12, 8),
                                      child: hcol(
                                        [
                                          Text(
                                            '储值抵扣',
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
                                          Text(
                                            '¥1,000',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFFA1A1AA),
                                                Color(0xFF80808A),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                              tab: true,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 1,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                                intrinsic: true,
                              ),
                              Text(
                                '储值抵扣是会员用余额消费，不是新收的钱，不计入实收',
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
                            gap: 8,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                    hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hbox(
                            minH: 44,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s418, Svgs.s419),
                                  w: 18,
                                  h: 18,
                                ),
                                Flexible(
                                  flex: 153,
                                  child: Text(
                                    '车牌 / 手机号 / 订单号',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                        ),
                        hTap(
                          context,
                          hbox(
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
                                  dk(context, Svgs.s12, Svgs.s13),
                                  w: 20,
                                  h: 20,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          to: 'OrderFilter',
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    hbox(
                      clip: true,
                      child: hrow(
                        [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
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
                                    '全部',
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
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '全部',
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
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 1,
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
                                    '消费',
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
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '消费',
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
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 2,
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
                                    '充值',
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
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '充值',
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
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 3,
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
                                    '次卡',
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
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '次卡',
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
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 4,
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
                                    '退款',
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
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '退款',
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
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                        intrinsic: true,
                      ),
                    ),
                    ...d2.vis([
                      hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '今天',
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
                                Text(
                                  '实收 ¥4,182 · 退款 ¥432',
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.start,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s169,
                                                  Svgs.s170,
                                                ),
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
                                                  '全车镀晶 · 9H',
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
                                                  '12:05 · 储值 + 微信 · 王建国',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥1,422',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s169,
                                                  Svgs.s170,
                                                ),
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
                                                  '精致洗车',
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
                                                  '11:40 · 微信 · 沪B·Q5566',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥68',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFFDEFD6),
                                            Color.fromRGBO(245, 165, 36, 0.16),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s234,
                                                  Svgs.s235,
                                                ),
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
                                                  '储值充值 · 送 ¥300',
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
                                                  '10:20 · 微信 · 李女士',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥2,000',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s426,
                                                  Svgs.s427,
                                                ),
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
                                                  '次卡售卖 · 精致洗车年卡',
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
                                                  '09:50 · 支付宝 · 周先生',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥1,080',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFFFE1E2),
                                            Color.fromRGBO(255, 56, 60, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s428,
                                                  Svgs.s429,
                                                ),
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
                                                  '次卡退款',
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
                                                  '09:15 · 原路退回 · 陈先生',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '-¥432',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s169,
                                                  Svgs.s170,
                                                ),
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
                                                  '漆面抛光',
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
                                                  '08:30 · 现金 · 沪A·F2210',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥612',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
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
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '昨天 11.02',
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
                                Text(
                                  '实收 ¥2,860',
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.start,
                              gap: 0,
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s169,
                                                  Svgs.s170,
                                                ),
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
                                                  '车身打蜡',
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
                                                  '17:20 · 微信 · 沪C·D9981',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥198',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s169,
                                                  Svgs.s170,
                                                ),
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
                                                  '内饰深度清洁',
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
                                                  '15:05 · 次卡抵扣 · 沪AF·09316',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥0',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
                                ),
                                hbox(
                                  h: 1,
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 40,
                                          h: 40,
                                          bg: dk(
                                            context,
                                            Color(0xFFFDEFD6),
                                            Color.fromRGBO(245, 165, 36, 0.16),
                                          ),
                                          radius: BorderRadius.circular(13),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s234,
                                                  Svgs.s235,
                                                ),
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
                                                Text(
                                                  '11:30 · 现金 · 赵先生',
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
                                              gap: 2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '¥2,000',
                                          style: hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                            tab: true,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                  to: 'OrderDetail',
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
                    ]),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
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
