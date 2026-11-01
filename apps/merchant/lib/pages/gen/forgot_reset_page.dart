import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ForgotResetPage extends StatelessWidget {
  const ForgotResetPage({super.key});

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
                        '设置新密码',
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
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: hcol(
                    [
                      Text(
                        '设置新密码',
                        style: hts(
                          22,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 30,
                        ),
                      ),
                      hFlowText(
                        (f) => f.live
                            ? ('手机号 ${f.maskedPhone} 已验证通过')
                            : '手机号 138 **** 1234 已验证通过',
                        hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 19,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 6,
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
                      hcol(
                        [
                          Text(
                            '新密码',
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
                                    hint: '8-20 位，含字母和数字',
                                    value: 'Aa123456xy',
                                    obscure: true,
                                  ),
                                ),
                                hTap(
                                  context,
                                  NegMargin(
                                    top: 0,
                                    left: 0,
                                    child: hbox(
                                      w: 32,
                                      h: 32,
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s85, Svgs.s86),
                                            w: 20,
                                            h: 20,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                  ),
                                  label: '显示密码',
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
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hbox(
                                    h: 4,
                                    bg: Color(0xFF17C964),
                                    radius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hbox(
                                    h: 4,
                                    bg: Color(0xFF17C964),
                                    radius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hbox(
                                    h: 4,
                                    bg: Color(0xFF17C964),
                                    radius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hbox(
                                    h: 4,
                                    bg: dk(
                                      context,
                                      Color(0xFFE4E4E7),
                                      Color(0xFF3A3A40),
                                    ),
                                    radius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                            intrinsic: true,
                          ),
                          Text(
                            '强度：强',
                            style: hts(
                              12,
                              dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                      ),
                      hcol(
                        [
                          Text(
                            '确认新密码',
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
                                    hint: '再次输入新密码',
                                    value: 'Aa123456xy',
                                    obscure: true,
                                  ),
                                ),
                                hTap(
                                  context,
                                  NegMargin(
                                    top: 0,
                                    left: 0,
                                    child: hbox(
                                      w: 32,
                                      h: 32,
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s85, Svgs.s86),
                                            w: 20,
                                            h: 20,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                  ),
                                  label: '显示密码',
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
                          hsvg(Svgs.s87, w: 14, h: 14),
                          Flexible(
                            flex: 76,
                            child: Text(
                              '长度 8–20 位',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
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
                            flex: 117,
                            child: Text(
                              '同时包含字母和数字',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
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
                            flex: 117,
                            child: Text(
                              '不含手机号连续数字',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
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
            child: hcol(
              [
                hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '确认重置',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'ForgotDone',
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
