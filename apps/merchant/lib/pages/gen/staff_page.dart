import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

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
                        '员工与权限',
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
                          [hsvg(dk(context, Svgs.s81, Svgs.s82), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      to: 'StaffAdd',
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
                  child: HSelHolder(
                    groups: [
                      ({3}, false),
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
                                h: 34,
                                radius: BorderRadius.circular(17),
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
                                  child: Text.rich(
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
                                          text: '全部 ',
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
                                          text: '8',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '全部 ',
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
                                        TextSpan(
                                          text: '8',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                                h: 34,
                                radius: BorderRadius.circular(17),
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
                                  child: Text.rich(
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
                                          text: '店长 ',
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
                                          text: '1',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '店长 ',
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
                                        TextSpan(
                                          text: '1',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                              index: 2,
                              on: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
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
                                  child: Text.rich(
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
                                          text: '前台收银 ',
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
                                          text: '2',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '前台收银 ',
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
                                        TextSpan(
                                          text: '2',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                              index: 3,
                              on: hbox(
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
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
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
                                          text: '施工技师 ',
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
                                          text: '5',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '施工技师 ',
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
                                        TextSpan(
                                          text: '5',
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
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                                radius: BorderRadius.circular(20),
                                align: Alignment(0, 0),
                                child: Text(
                                  '李',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF1E63AE),
                                      Color(0xFF6AB4FA),
                                    ),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '李国强 ',
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
                                          TextSpan(
                                            text: '· 镀晶 / 抛光',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '本月 118 台次',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 6,
                                      h: 6,
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(3),
                                    ),
                                    Flexible(
                                      flex: 36,
                                      child: Text(
                                        '施工中',
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
                                  gap: 5,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'StaffDetail',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                radius: BorderRadius.circular(20),
                                align: Alignment(0, 0),
                                child: Text(
                                  '张',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF855F2E),
                                      Color(0xFFF0C46A),
                                    ),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '张伟 ',
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
                                          TextSpan(
                                            text: '· 贴膜',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '本月 46 台次',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 6,
                                      h: 6,
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(3),
                                    ),
                                    Flexible(
                                      flex: 36,
                                      child: Text(
                                        '施工中',
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
                                  gap: 5,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'StaffDetail',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                radius: BorderRadius.circular(20),
                                align: Alignment(0, 0),
                                child: Text(
                                  '王',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF2B7745),
                                      Color(0xFF5FD48C),
                                    ),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '王磊 ',
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
                                          TextSpan(
                                            text: '· 洗车 / 内饰',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '本月 203 台次',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 6,
                                      h: 6,
                                      bg: Color(0xFF17C964),
                                      radius: BorderRadius.circular(3),
                                    ),
                                    Flexible(
                                      flex: 24,
                                      child: Text(
                                        '空闲',
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
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 5,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'StaffDetail',
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
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
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(20),
                                align: Alignment(0, 0),
                                child: Text(
                                  '刘',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '刘洋 ',
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
                                          TextSpan(
                                            text: '· 洗车',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '本月 176 台次',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  '今日休息',
                                  style: hts(
                                    12,
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                        to: 'StaffDetail',
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
                                radius: BorderRadius.circular(20),
                                align: Alignment(0, 0),
                                child: Text(
                                  '赵',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF855F2E),
                                      Color(0xFFF0C46A),
                                    ),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '赵敏 ',
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
                                          TextSpan(
                                            text: '· 洗车',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '邀请已发送，等待员工登录',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFDEFD6),
                                  Color.fromRGBO(245, 165, 36, 0.16),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  '待激活',
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
                        ),
                        to: 'StaffDetail',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 56,
                    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                    radius: BorderRadius.circular(20),
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
                        Expanded(
                          flex: 1,
                          child: Text(
                            '已停用账号',
                            style: hts(
                              15,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 22,
                            ),
                          ),
                        ),
                        Text(
                          '1 人',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          ),
                        ),
                        hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                  to: 'StaffDetailOff',
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
                              '技师可以',
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
                          hTap(
                            context,
                            Text(
                              '编辑权限',
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
                            to: 'RolePermission',
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                      hcol([
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFDDF6E7),
                                      Color.fromRGBO(23, 201, 100, 0.16),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s350, Svgs.s351),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 104,
                                    child: Text(
                                      '查看派给我的工单',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
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
                            ),
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFDDF6E7),
                                      Color.fromRGBO(23, 201, 100, 0.16),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s350, Svgs.s351),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 78,
                                    child: Text(
                                      '更新施工进度',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
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
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFDDF6E7),
                                      Color.fromRGBO(23, 201, 100, 0.16),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s350, Svgs.s351),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 52,
                                    child: Text(
                                      '领用耗材',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
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
                            ),
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFDDF6E7),
                                      Color.fromRGBO(23, 201, 100, 0.16),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s350, Svgs.s351),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 78,
                                    child: Text(
                                      '查看个人业绩',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
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
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s352, Svgs.s353),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 91,
                                    child: Text(
                                      '查看门店营业额',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hrow(
                                [
                                  hbox(
                                    w: 20,
                                    h: 20,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s352, Svgs.s353),
                                          w: 12,
                                          h: 12,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 91,
                                    child: Text(
                                      '会员充值与退款',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                          intrinsic: true,
                          min: false,
                        ),
                      ], gap: 0),
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
      overlays: [],
    );
  }
}
