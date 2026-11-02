import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ForgotVerifyPage extends StatelessWidget {
  const ForgotVerifyPage({super.key});

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
                        '忘记密码',
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
                        '验证手机号',
                        style: hts(
                          22,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 30,
                        ),
                      ),
                      Text(
                        '输入注册时使用的手机号，验证通过后设置新密码',
                        style: hts(
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
                            '手机号',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
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
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: hrow(
                              [
                                Text(
                                  '+86',
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
                                hbox(
                                  w: 1,
                                  h: 18,
                                  bg: dk(
                                    context,
                                    Color(0xFFD4D4D8),
                                    Color(0xFF3F3F46),
                                  ),
                                ),
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
                                    hint: '请输入手机号',
                                    value: '138 0000 1234',
                                    keyboard: TextInputType.phone,
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
                            '验证码',
                            style: hts(
                              13,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
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
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(14, 0, 6, 0),
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
                                    hint: '6 位数字',
                                    value: '483920',
                                    keyboard: TextInputType.number,
                                  ),
                                ),
                                HCodeHolder(
                                  builder: (context, k1) => hTap(
                                    context,
                                    hbox(
                                      h: 36,
                                      bg: dk(
                                        context,
                                        Color(0xFFE4E4E7),
                                        Color(0xFF3A3A40),
                                      ),
                                      radius: BorderRadius.circular(18),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: hCodeText(
                                          k1,
                                          hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF71717A),
                                              Color(0xFF9A9AA3),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    onTap: () => hSendCode(context, k1),
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
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    '收不到验证码？请确认手机号是否为已开通门店账号的号码，或联系客服。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                      lh: 18,
                    ),
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
                      child: hBusy(
                        'ForgotVerify>ForgotReset',
                        Text(
                          '下一步',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                        label: '提交中…',
                      ),
                    ),
                  ),
                  to: 'ForgotReset',
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
