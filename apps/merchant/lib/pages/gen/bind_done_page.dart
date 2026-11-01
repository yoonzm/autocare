import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class BindDonePage extends StatelessWidget {
  const BindDonePage({super.key});

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
                          [hsvg(dk(context, Svgs.s26, Svgs.s27), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      back: true,
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(0, 26, 0, 6),
                  child: hstack(
                    hcol(
                      [
                        hbox(
                          w: 128,
                          h: 128,
                          child: hstack(
                            hrow(
                              [
                                hbox(
                                  w: 76,
                                  h: 76,
                                  grad: LinearGradient(
                                    begin: Alignment(-0.342, -0.94),
                                    end: Alignment(0.342, 0.94),
                                    colors: [
                                      Color(0xFF3BDC86),
                                      Color(0xFF17C964),
                                    ],
                                    stops: [0, 1],
                                  ),
                                  radius: BorderRadius.circular(38),
                                  shadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(23, 201, 100, 0.35),
                                      offset: Offset(0, 10),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  child: hrow(
                                    [hsvg(Svgs.s29, w: 40, h: 40)],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                            [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: hsvg(Svgs.s28, w: 128, h: 128),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '绑定成功',
                          style: hts(
                            21,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                        ),
                        Text(
                          '今后的消费、充值都会通过微信通知您',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 19,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    [],
                    behind: [
                      Positioned(
                        left: 38,
                        top: 30,
                        width: 8,
                        height: 8,
                        child: hbox(
                          w: 8,
                          h: 8,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4),
                        ),
                      ),
                      Positioned(
                        left: 300,
                        top: 52,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 150,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Positioned(
                        left: 318,
                        top: 140,
                        width: 9,
                        height: 9,
                        child: hbox(
                          w: 9,
                          h: 9,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4.5),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 100,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 344,
                        top: 98,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
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
                            hbox(
                              w: 44,
                              h: 44,
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(22),
                              align: Alignment(0, 0),
                              child: Text(
                                '李',
                                style: hts(
                                  17,
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
                              child: hcol(
                                [
                                  Text(
                                    '李女士',
                                    style: hts(
                                      16,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 22,
                                    ),
                                  ),
                                  Text(
                                    '139 **** 5530',
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
                                cross: CrossAxisAlignment.stretch,
                                gap: 0,
                              ),
                            ),
                            hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(11),
                              pad: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                '金卡会员',
                                style: hts(
                                  12,
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
                          gap: 12,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '储值余额（元）',
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
                                  Text(
                                    '1,260.00',
                                    style: hts(
                                      30,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 36,
                                      ls: -0.9,
                                    ),
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
                                  '洗车次卡',
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
                                Text(
                                  '6 / 10 次',
                                  style: hts(
                                    16,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w600,
                                    lh: 22,
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
                          gap: 0,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        right: -90,
                        bottom: -120,
                        child: hsvg(
                          dk(context, Svgs.s30, Svgs.s31),
                          w: 260,
                          h: 260,
                        ),
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
                  pad: EdgeInsets.fromLTRB(18, 4, 18, 4),
                  child: hcol(
                    [
                      hbox(
                        minH: 56,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '消费通知',
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
                                    '每次到店消费后提醒',
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
                      ),
                      hbox(
                        minH: 56,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '充值通知',
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
                                    '储值到账后提醒',
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
                      ),
                      hbox(
                        minH: 56,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '到期与生日提醒',
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
                                    '次卡将到期、生日祝福',
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
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
              Color.fromRGBO(255, 255, 255, 0.92),
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
            child: hcol(
              [
                hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '查看我的会员卡',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'Main',
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
        ),
      ],
    );
  }
}
