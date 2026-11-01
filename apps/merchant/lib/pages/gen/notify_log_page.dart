import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class NotifyLogPage extends StatelessWidget {
  const NotifyLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1120,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 40),
            child: HSelHolder(
              groups: [
                ({0}, false),
              ],
              builder: (context, g1) => HDyn(
                texts: [
                  '今天微信王建国 · 消费扣款已送达14:32微信王建国 · 储值充值已送达14:38短信李女士 · 消费扣款已送达13:05微信张先生 · 次卡核销已送达11:47短信刘先生 · 消费扣款微信未送达，已转短信送达10:20短信赵女士 · 余额不足发送失败 · 手机号停机09:15重发',
                  '昨天微信陈先生 · 储值充值已送达18:22短信孙女士 · 次卡将到期已送达10:00微信周先生 · 消费扣款已送达16:40',
                ],
                filter: g1[0],
                labels: ['全部', '微信', '短信', '失败'],
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
                            '发送记录',
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
                    HSelHolder(
                      groups: [
                        ({2}, false),
                      ],
                      builder: (context, g3) => hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g3[0],
                              index: 0,
                              on: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFE1E2),
                                  Color.fromRGBO(255, 56, 60, 0.18),
                                ),
                                radius: BorderRadius.circular(20),
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '今日发送',
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
                                      '12',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              off: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(20),
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
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '今日发送',
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
                                      '12',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g3[0],
                              index: 1,
                              on: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFE1E2),
                                  Color.fromRGBO(255, 56, 60, 0.18),
                                ),
                                radius: BorderRadius.circular(20),
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '送达率',
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
                                      '91.7%',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFF2B7745),
                                          Color(0xFF5FD48C),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              off: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(20),
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
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '送达率',
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
                                      '91.7%',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFF2B7745),
                                          Color(0xFF5FD48C),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g3[0],
                              index: 2,
                              on: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFE1E2),
                                  Color.fromRGBO(255, 56, 60, 0.18),
                                ),
                                radius: BorderRadius.circular(20),
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '失败',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        lh: 16,
                                      ),
                                    ),
                                    Text(
                                      '1',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              off: hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(20),
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
                                pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                                child: hcol(
                                  [
                                    Text(
                                      '失败',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        lh: 16,
                                      ),
                                    ),
                                    Text(
                                      '1',
                                      style: hts(
                                        22,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                        intrinsic: true,
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(21),
                      pad: EdgeInsets.fromLTRB(3, 3, 3, 3),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 0,
                              on: hbox(
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(18),
                                shadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.12),
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '全部',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
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
                                radius: BorderRadius.circular(18),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '全部',
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
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 1,
                              on: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                shadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.12),
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '微信',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
                                    ),
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '微信',
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
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 2,
                              on: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                shadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.12),
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '短信',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
                                    ),
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '短信',
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
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 3,
                              on: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                shadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.12),
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    spreadRadius: 0,
                                  ),
                                ],
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '失败',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
                                    ),
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 36,
                                radius: BorderRadius.circular(18),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '失败',
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                        intrinsic: true,
                      ),
                    ),
                    ...d2.vis([
                      hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
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
                            pad: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: hcol(
                              [
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '微信',
                                          style: hts(
                                            11,
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
                                                    text: '王建国 ',
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
                                                    text: '· 消费扣款',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '14:32',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '微信',
                                          style: hts(
                                            11,
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
                                                    text: '王建国 ',
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
                                                    text: '· 储值充值',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '14:38',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '短信',
                                          style: hts(
                                            11,
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
                                                    text: '李女士 ',
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
                                                    text: '· 消费扣款',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '13:05',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '微信',
                                          style: hts(
                                            11,
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
                                                    text: '张先生 ',
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
                                                    text: '· 次卡核销',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '11:47',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '短信',
                                          style: hts(
                                            11,
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
                                                    text: '刘先生 ',
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
                                                    text: '· 消费扣款',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFFF5A524),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 144,
                                                  child: Text(
                                                    '微信未送达，已转短信送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF855F2E),
                                                        Color(0xFFF0C46A),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '10:20',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '短信',
                                          style: hts(
                                            11,
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
                                                    text: '赵女士 ',
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
                                                    text: '· 余额不足',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFFF31260),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 121,
                                                  child: Text(
                                                    '发送失败 · 手机号停机',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFFA43433),
                                                        Color(0xFFFF7B7E),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '09:15',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFFA1A1AA),
                                                Color(0xFF80808A),
                                              ),
                                              lh: 16,
                                            ),
                                          ),
                                          hTap(
                                            context,
                                            hbox(
                                              h: 28,
                                              bg: dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFF34343A),
                                              ),
                                              radius: BorderRadius.circular(14),
                                              pad: EdgeInsets.fromLTRB(
                                                12,
                                                0,
                                                12,
                                                0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                widthFactor: 1,
                                                child: Text(
                                                  '重发',
                                                  style: hts(
                                                    12,
                                                    Color(0xFFFFFFFF),
                                                    w: FontWeight.w500,
                                                    lh: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            label: '重发',
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                      hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Text(
                              '昨天',
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
                            pad: EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: hcol(
                              [
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '微信',
                                          style: hts(
                                            11,
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
                                                    text: '陈先生 ',
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
                                                    text: '· 储值充值',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '18:22',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '短信',
                                          style: hts(
                                            11,
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
                                                    text: '孙女士 ',
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
                                                    text: '· 次卡将到期',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '10:00',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
                                  margin: EdgeInsets.fromLTRB(52, 0, 0, 0),
                                ),
                                hbox(
                                  pad: EdgeInsets.fromLTRB(0, 12, 0, 12),
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
                                          '微信',
                                          style: hts(
                                            11,
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
                                                    text: '周先生 ',
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
                                                    text: '· 消费扣款',
                                                    style: hts(
                                                      13,
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
                                            hrow(
                                              [
                                                hbox(
                                                  w: 6,
                                                  h: 6,
                                                  bg: Color(0xFF17C964),
                                                  radius: BorderRadius.circular(
                                                    3,
                                                  ),
                                                ),
                                                Flexible(
                                                  flex: 36,
                                                  child: Text(
                                                    '已送达',
                                                    style: hts(
                                                      12,
                                                      dk(
                                                        context,
                                                        Color(0xFF2B7745),
                                                        Color(0xFF5FD48C),
                                                      ),
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.center,
                                              gap: 5,
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
                                            '16:40',
                                            style: hts(
                                              12,
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
                                        cross: CrossAxisAlignment.end,
                                        gap: 4,
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
