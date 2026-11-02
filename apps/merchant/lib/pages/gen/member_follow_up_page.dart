import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class MemberFollowUpPage extends StatelessWidget {
  const MemberFollowUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 980,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
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
                        '回访提醒',
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
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(24),
                  pad: EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '今日待回访',
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
                          hFollowRich(
                            [
                              (f) => '已完成 ',
                              (f) => '${f.done}',
                              (f) => ' / ${f.done + f.pending}',
                            ],
                            ['已完成 ', '5', ' / 23'],
                            [
                              hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                lh: 18,
                              ),
                              hts(
                                13,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 18,
                              ),
                              hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                lh: 18,
                              ),
                            ],
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 8,
                      ),
                      hFollowRich(
                        [(f) => '${f.pending} ', (f) => '位客户'],
                        ['18 ', '位客户'],
                        [
                          hts(
                            30,
                            Color(0xFFFAFAFA),
                            w: FontWeight.w600,
                            lh: 36,
                            ls: -0.6,
                          ),
                          hts(
                            14,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            w: FontWeight.w500,
                            lh: 36,
                            ls: -0.6,
                          ),
                        ],
                      ),
                      hFollowProgress(),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                NegMargin(
                  top: 0,
                  left: 0,
                  child: hbox(
                    clip: true,
                    child: HSelHolder(
                      groups: [
                        ({0}, false),
                      ],
                      builder: (context, g1) => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipAll,
                                      '全部 18',
                                      hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFFFFFFF),
                                          Color(0xFF18181B),
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
                                    Color(0xFF18181B),
                                    Color(0xFF34343A),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipAll,
                                      '全部 18',
                                      hts(
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipExpire,
                                      '次卡到期 5',
                                      hts(
                                        13,
                                        Color(0xFFFFFFFF),
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
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipExpire,
                                      '次卡到期 5',
                                      hts(
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipCare,
                                      '养护到期 6',
                                      hts(
                                        13,
                                        Color(0xFFFFFFFF),
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
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipCare,
                                      '养护到期 6',
                                      hts(
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipBirthday,
                                      '生日 2',
                                      hts(
                                        13,
                                        Color(0xFFFFFFFF),
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
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipBirthday,
                                      '生日 2',
                                      hts(
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
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(17),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipSleep,
                                      '沉睡 5',
                                      hts(
                                        13,
                                        Color(0xFFFFFFFF),
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
                                  border: dk(
                                    context,
                                    Border.all(
                                      color: Color(0xFFE4E4E7),
                                      width: 1,
                                    ),
                                    Border.all(
                                      color: Color(0xFF3A3A40),
                                      width: 1,
                                    ),
                                  ),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: hFollowText(
                                      (f) => f.chipSleep,
                                      '沉睡 5',
                                      hts(
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
                    ),
                  ),
                ),
                hReminderList(),
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
