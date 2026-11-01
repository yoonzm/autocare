import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class RegShopPage extends StatelessWidget {
  const RegShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1010,
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
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.06),
                              offset: Offset(0, 0),
                              blurRadius: 1,
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
                        '门店信息',
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
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: hbox(
                        h: 4,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        h: 4,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        h: 4,
                        bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
                        radius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 6,
                  intrinsic: true,
                ),
                hcol(
                  [
                    Text(
                      '介绍一下你的门店',
                      style: hts(
                        24,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w600,
                        lh: 32,
                        ls: -0.48,
                      ),
                    ),
                    Text(
                      '用于生成默认的服务项目和工位',
                      style: hts(
                        14,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 20,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 6,
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(24),
                  shadow: dk(
                    context,
                    [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 0),
                        blurRadius: 1,
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
                      hcol(
                        [
                          Text.rich(
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
                                  text: '门店名称 ',
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
                                  text: '*',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA43433),
                                      Color(0xFFFF7B7E),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hbox(
                            minH: 48,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: hrow(
                              [
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '如：驰光汽车美容',
                                    value: '驰光汽车美容',
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                      HStrHolder(
                        initial: '上海市 · 浦东新区',
                        builder: (context, s1) => hTap(
                          context,
                          hcol(
                            [
                              Text.rich(
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
                                      text: '所在城市 ',
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
                                      text: '*',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              HStrHolder(
                                initial: '上海市 · 浦东新区',
                                builder: (context, s2) => hTap(
                                  context,
                                  hbox(
                                    minH: 48,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(14),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: hStr(
                                            s2,
                                            hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                            ),
                                          ),
                                        ),
                                        hsvg(
                                          dk(context, Svgs.s3, Svgs.s4),
                                          w: 16,
                                          h: 16,
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 10,
                                    ),
                                  ),
                                  onTap: () =>
                                      hPick(context, 'city', '所在城市', s2),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                          onTap: () => hPick(context, 'city', '所在城市', s1),
                        ),
                      ),
                      hcol(
                        [
                          Text(
                            '详细地址',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                          hbox(
                            minH: 48,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: hrow(
                              [
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '街道、门牌号（选填）',
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                      hcol(
                        [
                          Text.rich(
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
                                  text: '联系人 ',
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
                                  text: '*',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA43433),
                                      Color(0xFFFF7B7E),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hbox(
                            minH: 48,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: hrow(
                              [
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '您的姓名',
                                    value: '陈明',
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 16,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(24),
                  shadow: dk(
                    context,
                    [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.04),
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 0),
                        blurRadius: 1,
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
                        '您的身份',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      HSelHolder(
                        groups: [
                          ({0}, false),
                        ],
                        builder: (context, g3) => hwrap(
                          [
                            HSel(
                              ctrl: g3[0],
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
                                    '老板',
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
                                    '老板',
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
                              ctrl: g3[0],
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
                                    '店长',
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
                                    '店长',
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
                              ctrl: g3[0],
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
                                    '前台',
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
                                    '前台',
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
                      Text(
                        '工位数量',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      HSelHolder(
                        groups: [
                          ({1}, false),
                        ],
                        builder: (context, g4) => hwrap(
                          [
                            HSel(
                              ctrl: g4[0],
                              index: 0,
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
                                    '1-3 个',
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
                                    '1-3 个',
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
                              ctrl: g4[0],
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
                                    '4-6 个',
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
                                    '4-6 个',
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
                              ctrl: g4[0],
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
                                    '7-10 个',
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
                                    '7-10 个',
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
                              ctrl: g4[0],
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
                                    '10 个以上',
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
                                    '10 个以上',
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
                      Text.rich(
                        TextSpan(
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 20,
                          ),
                          children: [
                            TextSpan(
                              text: '主营业务 ',
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
                              text: '· 可多选',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      HSelHolder(
                        groups: [
                          ({0, 1, 2}, true),
                        ],
                        builder: (context, g5) => hwrap(
                          [
                            HSel(
                              ctrl: g5[0],
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
                                    '洗车美容',
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
                                    '洗车美容',
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
                              ctrl: g5[0],
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
                                    '镀晶镀膜',
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
                                    '镀晶镀膜',
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
                              ctrl: g5[0],
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
                                    '隐形车衣',
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
                                    '隐形车衣',
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
                              ctrl: g5[0],
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
                                    '改色膜',
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
                                    '改色膜',
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
                              ctrl: g5[0],
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
                                    '保养维修',
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
                                    '保养维修',
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
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
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
                  flex: 1,
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
                          '开通并开始试用',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'RegDone',
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
