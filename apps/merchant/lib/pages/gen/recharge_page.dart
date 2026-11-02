import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class RechargePage extends StatelessWidget {
  const RechargePage({super.key});

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
                              radius: BorderRadius.circular(17),
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
                            to: 'RechargeCard',
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
                      radius: BorderRadius.circular(28),
                      pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                      clip: true,
                      border: dk(
                        context,
                        null,
                        Border(
                          top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          bottom: BorderSide(
                            color: Color(0xFF2E2E33),
                            width: 1,
                          ),
                          left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                        ),
                      ),
                      child: hstack(
                        hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  w: 36,
                                  h: 36,
                                  bg: Color(0xFFF5D78E),
                                  radius: BorderRadius.circular(18),
                                  align: Alignment(0, 0),
                                  child: hMemberText(
                                    (m) => m.avatar,
                                    '王',
                                    hts(
                                      14,
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
                                  child: hMemberRich(
                                    [
                                      (m) => '${m.name} ',
                                      (m) => '· ${m.maskedPhone}',
                                    ],
                                    ['王建国 ', '· 138 **** 6021'],
                                    [
                                      hts(
                                        15,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w500,
                                        lh: 22,
                                      ),
                                      hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 22,
                                      ),
                                    ],
                                  ),
                                ),
                                hbox(
                                  bg: Color(0xFFF5D78E),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: hMemberText(
                                    (m) => m.levelMember,
                                    '黑金会员',
                                    hts(
                                      11,
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '当前余额',
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
                                      hMemberText(
                                        (m) => m.balanceText,
                                        '¥3,680.00',
                                        hts(
                                          24,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 30,
                                          tab: true,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
                                  child: hsvg(
                                    dk(context, Svgs.s325, Svgs.s326),
                                    w: 20,
                                    h: 20,
                                  ),
                                ),
                                hcol(
                                  [
                                    Text(
                                      '充值后',
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
                                    hRechargeText(
                                      (r) => r.afterText,
                                      '¥5,980.00',
                                      hts(
                                        24,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 30,
                                        tab: true,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.end,
                                  gap: 2,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 14,
                        ),
                        [],
                        behind: [
                          Positioned(
                            right: -80,
                            bottom: -110,
                            child: hsvg(
                              dk(context, Svgs.s323, Svgs.s324),
                              w: 220,
                              h: 220,
                            ),
                          ),
                        ],
                      ),
                    ),
                    HSelHolder(
                      groups: [
                        ({1}, false),
                      ],
                      builder: (context, g1) => hcol([
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: g1[0],
                                index: 0,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥1,000',
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
                                      Text(
                                        '送 ¥100',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
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
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥1,000',
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
                                      Text(
                                        '送 ¥100',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
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
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hstack(
                                    hcol(
                                      [
                                        Text(
                                          '¥2,000',
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
                                        hRechargeText(
                                          (r) => RechargeView.giftLabel(1),
                                          '送 ¥300 + 洗车 2 次',
                                          hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 16,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 4,
                                    ),
                                    [
                                      Positioned(
                                        top: -8,
                                        right: 12,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFF1F1F23),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: Text(
                                            '最多人选',
                                            style: hts(
                                              11,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                off: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
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
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hstack(
                                    hcol(
                                      [
                                        Text(
                                          '¥2,000',
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
                                        hRechargeText(
                                          (r) => RechargeView.giftLabel(1),
                                          '送 ¥300 + 洗车 2 次',
                                          hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 16,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 4,
                                    ),
                                    [
                                      Positioned(
                                        top: -8,
                                        right: 12,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFF1F1F23),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: Text(
                                            '最多人选',
                                            style: hts(
                                              11,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: g1[0],
                                index: 2,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥5,000',
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
                                      Text(
                                        '送 ¥1,000',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
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
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥5,000',
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
                                      Text(
                                        '送 ¥1,000',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
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
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥10,000',
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
                                      hRechargeText(
                                        (r) => RechargeView.giftLabel(3),
                                        '送 ¥2,500 + 镀晶 1 次',
                                        hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
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
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        '¥10,000',
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
                                      hRechargeText(
                                        (r) => RechargeView.giftLabel(3),
                                        '送 ¥2,500 + 镀晶 1 次',
                                        hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 2,
                              child: hbox(
                                h: 52,
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
                                    Text(
                                      '自定义金额',
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
                                    Expanded(
                                      child: HInput(
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 20,
                                        ),
                                        hint: '输入金额，不享赠送',
                                        keyboard:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        align: TextAlign.right,
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
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                      ], gap: 10),
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
                            builder: (context, g2) => hcol([
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: g2[0],
                                      index: 0,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s327, Svgs.s328),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '微信',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFFFAFAFA),
                                                  Color(0xFF18181B),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s328, Svgs.s327),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '微信',
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
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: g2[0],
                                      index: 1,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(Svgs.s330, w: 20, h: 20),
                                            Text(
                                              '支付宝',
                                              style: hts(
                                                13,
                                                Color(0xFFFAFAFA),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s329, Svgs.s330),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '支付宝',
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
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: g2[0],
                                      index: 2,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(Svgs.s332, w: 20, h: 20),
                                            Text(
                                              '现金',
                                              style: hts(
                                                13,
                                                Color(0xFFFAFAFA),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s331, Svgs.s332),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '现金',
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
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: g2[0],
                                      index: 3,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(Svgs.s334, w: 20, h: 20),
                                            Text(
                                              'POS 刷卡',
                                              style: hts(
                                                13,
                                                Color(0xFFFAFAFA),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s333, Svgs.s334),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              'POS 刷卡',
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
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
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
                              hLiveText(
                                (p) => p.live ? (p.operatorText) : '陈明（店长）',
                                hts(
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
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.04),
                  offset: Offset(0, -8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0xFFE8E8EA),
                  offset: Offset(0, -1),
                  blurRadius: 0,
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
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      hRechargeText(
                        (r) => r.payLine,
                        '实收 · 到账 ¥2,300 + 洗车 2 次',
                        hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                      hRechargeText(
                        (r) => r.amountText,
                        '¥2,000.00',
                        hts(
                          24,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 30,
                          ls: -0.48,
                          tab: true,
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
                    pad: EdgeInsets.fromLTRB(28, 0, 28, 0),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: hBusy(
                        'Recharge>RechargeSuccess',
                        Text(
                          '确认收款',
                          style: hts(
                            16,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                        ),
                        style: hts(
                          16,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        label: '提交中…',
                      ),
                    ),
                  ),
                  to: 'RechargeSuccess',
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
        ),
      ],
    );
  }
}
