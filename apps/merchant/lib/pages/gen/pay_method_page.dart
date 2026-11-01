import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PayMethodPage extends StatelessWidget {
  const PayMethodPage({super.key});

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
                        '支付方式',
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
                      hbox(
                        minH: 64,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
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
                                    dk(context, Svgs.s258, Svgs.s259),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '微信支付',
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
                                  Text(
                                    '已授权自动续费 · 2027.10.27 扣款',
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
                            hbox(
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: Text(
                                '默认',
                                style: hts(
                                  11,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 18,
                                ),
                                softWrap: false,
                                maxLines: 1,
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
                        minH: 64,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
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
                                    dk(context, Svgs.s292, Svgs.s293),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '支付宝',
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
                                  Text(
                                    '未授权',
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
                            Text(
                              '去授权',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF1E63AE),
                                  Color(0xFF6AB4FA),
                                ),
                                w: FontWeight.w600,
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
                        minH: 64,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            hbox(
                              w: 32,
                              h: 32,
                              bg: dk(
                                context,
                                Color(0xFFEEEEF0),
                                Color(0xFF27272A),
                              ),
                              radius: BorderRadius.circular(10),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s294, Svgs.s295),
                                    w: 18,
                                    h: 18,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '对公转账',
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
                                  Text(
                                    '手动转账，1 个工作日内确认开通',
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
                                    '到期自动续费',
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
                                    '到期前 3 天扣款 ¥3,990',
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
                Text(
                  '关闭自动续费后，套餐将在到期日停止服务，不会产生额外扣款。我们会在扣款前 3 天通知您。',
                  style: hts(
                    12,
                    dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                    lh: 18,
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
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '完成',
                          style: hts(
                            15,
                            dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Subscription',
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
