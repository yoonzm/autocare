import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class BindH5Page extends StatelessWidget {
  const BindH5Page({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 900,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 0),
            child: hcol(
              [
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 22, 20, 22),
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
                              w: 48,
                              h: 48,
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(24),
                              align: Alignment(0, 0),
                              child: Text(
                                '驰',
                                style: hts(
                                  18,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 97,
                              child: IntrinsicWidth(
                                child: hcol(
                                  [
                                    Text(
                                      '驰光汽车美容',
                                      style: hts(
                                        16,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      '徐汇店 · 会员中心',
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
                                  gap: 2,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                        Text(
                          '绑定会员\n余额次卡一手掌握',
                          style: hts(
                            24,
                            Color(0xFFFAFAFA),
                            w: FontWeight.w600,
                            lh: 32,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 16,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -90,
                        right: -90,
                        child: hsvg(
                          dk(context, Svgs.s7, Svgs.s8),
                          w: 240,
                          h: 240,
                        ),
                      ),
                    ],
                  ),
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                        pad: EdgeInsets.fromLTRB(8, 12, 8, 12),
                        child: hcol(
                          [
                            hbox(
                              w: 32,
                              h: 32,
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(10),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s32, Svgs.s33),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Text(
                              '查余额',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 6,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                        pad: EdgeInsets.fromLTRB(8, 12, 8, 12),
                        child: hcol(
                          [
                            hbox(
                              w: 32,
                              h: 32,
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(10),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s34, Svgs.s35),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Text(
                              '看次卡',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 6,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hbox(
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
                        pad: EdgeInsets.fromLTRB(8, 12, 8, 12),
                        child: hcol(
                          [
                            hbox(
                              w: 32,
                              h: 32,
                              bg: dk(
                                context,
                                Color(0xFFFFE1E2),
                                Color.fromRGBO(255, 56, 60, 0.18),
                              ),
                              radius: BorderRadius.circular(10),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s36, Svgs.s37),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Text(
                              '收通知',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF3F3F46),
                                  Color(0xFFD4D4D8),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 6,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 10,
                  intrinsic: true,
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
                  pad: EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: hcol(
                    [
                      Text(
                        '请验证您在店内登记的手机号，验证后即可绑定',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                      hcol(
                        [
                          Text(
                            '手机号',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 18,
                            ),
                          ),
                          hbox(
                            h: 48,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(16),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            align: Alignment.centerLeft,
                            child: HInput(
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
                              value: '139 **** 5530',
                              keyboard: TextInputType.phone,
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
                            '验证码',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 18,
                            ),
                          ),
                          hrow(
                            [
                              Expanded(
                                child: hbox(
                                  h: 48,
                                  minW: 0,
                                  bg: dk(
                                    context,
                                    Color(0xFFF4F4F5),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  align: Alignment.centerLeft,
                                  child: HInput(
                                    style: hts(
                                      17,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                      ls: 4,
                                    ),
                                    value: '4 8 2 0',
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                              ),
                              hTap(
                                context,
                                hbox(
                                  h: 48,
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '52 秒后重发',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF1E63AE),
                                          Color(0xFF6AB4FA),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                label: '52 秒后重发',
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                            intrinsic: true,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 6,
                      ),
                      hrow(
                        [
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                            child: HCheck(
                              initial: true,
                              size: 16,
                              color: Color(0xFF0485F7),
                            ),
                          ),
                          Flexible(
                            flex: 348,
                            child: Text(
                              '同意商家向我发送消费、充值及到期提醒等服务通知，可随时关闭',
                              style: hts(
                                12,
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
                        cross: CrossAxisAlignment.start,
                        gap: 8,
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
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '确认绑定',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'BindDone',
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
