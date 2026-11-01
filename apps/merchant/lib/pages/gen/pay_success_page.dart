import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PaySuccessPage extends StatelessWidget {
  const PaySuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 907,
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
                          '收款成功',
                          style: hts(
                            21,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                        ),
                        Text(
                          '¥1,422.00',
                          style: hts(
                            34,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 40,
                            ls: -0.5,
                          ),
                        ),
                        Text(
                          '沪A·8K826 · 王建国 · 储值支付 · 14:32',
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
                  pad: EdgeInsets.fromLTRB(18, 6, 18, 6),
                  child: hcol(
                    [
                      hbox(
                        minH: 44,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '消费项目',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              '镀晶养护 · 内饰精洗',
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
                        minH: 44,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '优惠',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              '黑金 9 折 −¥158.00',
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
                        minH: 44,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '储值扣款',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              '¥1,422.00',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 20,
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
                      ),
                      hbox(
                        minH: 44,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '当前余额',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              '¥2,258.00',
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
                        minH: 44,
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '获得积分',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              '+1,422',
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
                  pad: EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          hbox(
                            w: 40,
                            h: 40,
                            bg: dk(
                              context,
                              Color(0xFFDDF6E7),
                              Color.fromRGBO(23, 201, 100, 0.16),
                            ),
                            radius: BorderRadius.circular(13),
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s278, Svgs.s279),
                                  w: 20,
                                  h: 20,
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
                                  '已自动通知会员',
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
                                Text(
                                  '王建国 · 微信 · 消费通知',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 17,
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
                            child: Text(
                              '已送达',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF2B7745),
                                  Color(0xFF5FD48C),
                                ),
                                w: FontWeight.w600,
                                lh: 20,
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
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                      hTap(
                        context,
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '按「通知与消息」策略自动发送，微信未送达时自动转短信',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 17,
                                ),
                              ),
                            ),
                            Text(
                              '通知设置',
                              style: hts(
                                12,
                                Color(0xFF0485F7),
                                w: FontWeight.w500,
                                lh: 17,
                              ),
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 6,
                        ),
                        to: 'NotifySettings',
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
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '继续开单',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Order',
                  ),
                ),
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
                    to: 'Main',
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ),
        ),
      ],
    );
  }
}
