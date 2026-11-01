import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class BayEditPage extends StatelessWidget {
  const BayEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
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
                        '编辑工位',
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
                        h: 44,
                        minW: 44,
                        child: Align(
                          alignment: Alignment(1, 0),
                          widthFactor: 1,
                          child: Text(
                            '保存',
                            style: hts(
                              15,
                              Color(0xFF0485F7),
                              w: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      to: 'BusinessHours',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
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
                                  text: '工位名称 ',
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
                                    hint: '如：1 号工位',
                                    value: '3 号工位',
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
                          Text(
                            '工位类型',
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
                            builder: (context, g1) => hwrap(
                              [
                                HSel(
                                  ctrl: g1[0],
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
                                        '洗车',
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
                                        '洗车',
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
                                        '美容',
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
                                        '美容',
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
                                  ctrl: g1[0],
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
                                        '贴膜',
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
                                        '贴膜',
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
                        gap: 8,
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
                              child: hcol(
                                [
                                  Text(
                                    '开放在线预约',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                  Text(
                                    '关闭后仅店内可安排',
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
                            HSwitch(initial: true),
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
                                '默认技师',
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
                              '李国强',
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
                                '排序',
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
                              '第 3 位',
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
                  bg: dk(
                    context,
                    Color(0xFFFDEFD6),
                    Color.fromRGBO(245, 165, 36, 0.16),
                  ),
                  radius: BorderRadius.circular(18),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      hsvg(dk(context, Svgs.s24, Svgs.s25), w: 18, h: 18),
                      Flexible(
                        flex: 327,
                        child: Text(
                          '今天该工位有 1 个施工中订单，停用前需先完成或转移。',
                          style: hts(
                            13,
                            dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)),
                            lh: 19,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.start,
                    gap: 10,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 52,
                    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                    radius: BorderRadius.circular(26),
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
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '停用该工位',
                        style: hts(
                          15,
                          dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  to: 'BusinessHours',
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
