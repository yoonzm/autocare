import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PayApplyReviewingPage extends StatelessWidget {
  const PayApplyReviewingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 900,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
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
                        '开通进度',
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
                        hcol(
                          [
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '微信审核中',
                                    style: hts(
                                      18,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 26,
                                    ),
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
                                    '审核中',
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
                              gap: 10,
                            ),
                            Text(
                              '预计 1–3 个工作日出结果，结果会通过微信和 App 消息通知你。',
                              style: hts(13, Color(0xFFD4D4D8), lh: 19),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 12,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -110,
                        right: -110,
                        child: hsvg(Svgs.s7, w: 240, h: 240),
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          hcol(
                            [
                              hbox(
                                w: 20,
                                h: 20,
                                bg: Color(0xFF17C964),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [hsvg(Svgs.s444, w: 12, h: 12)],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                              hbox(w: 2, minH: 28, bg: Color(0xFF17C964)),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          Flexible(
                            flex: 105,
                            child: hbox(
                              pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                              child: IntrinsicWidth(
                                child: hcol(
                                  [
                                    Text(
                                      '已提交申请',
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
                                    Text(
                                      '2026.11.03 23:40',
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
                                  gap: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 12,
                      ),
                      hrow(
                        [
                          hcol(
                            [
                              hbox(
                                w: 20,
                                h: 20,
                                bg: Color(0xFF0485F7),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 8,
                                      h: 8,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFFFFF),
                                        Color(0xFF18181B),
                                      ),
                                      radius: BorderRadius.circular(4),
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                              hbox(
                                w: 2,
                                minH: 28,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          Flexible(
                            flex: 147,
                            child: hbox(
                              pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                              child: IntrinsicWidth(
                                child: hcol(
                                  [
                                    Text(
                                      '微信审核中',
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
                                    Text(
                                      '资料审核通常 1–3 个工作日',
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
                                  gap: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 12,
                      ),
                      hrow(
                        [
                          hcol(
                            [
                              hbox(
                                w: 20,
                                h: 20,
                                bg: dk(
                                  context,
                                  Color(0xFFD4D4D8),
                                  Color(0xFF3F3F46),
                                ),
                                radius: BorderRadius.circular(10),
                              ),
                              hbox(
                                w: 2,
                                minH: 28,
                                bg: dk(
                                  context,
                                  Color(0xFFE4E4E7),
                                  Color(0xFF3A3A40),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          Flexible(
                            flex: 84,
                            child: hbox(
                              pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                              child: IntrinsicWidth(
                                child: hcol(
                                  [
                                    Text(
                                      '法人扫码签约',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '审核通过后进行',
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
                                  gap: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 12,
                      ),
                      hrow(
                        [
                          hcol(
                            [
                              hbox(
                                w: 20,
                                h: 20,
                                bg: dk(
                                  context,
                                  Color(0xFFD4D4D8),
                                  Color(0xFF3F3F46),
                                ),
                                radius: BorderRadius.circular(10),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                          Flexible(
                            flex: 72,
                            child: hbox(
                              pad: EdgeInsets.fromLTRB(0, 0, 0, 14),
                              child: IntrinsicWidth(
                                child: hcol(
                                  [
                                    Text(
                                      '开通完成',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '即可开始收款',
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
                                  gap: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 12,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 46,
                    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                    radius: BorderRadius.circular(23),
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
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '查看提交的资料',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  to: 'PayApplyReview',
                ),
                Text.rich(
                  TextSpan(
                    style: hts(
                      12,
                      dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      lh: 20,
                    ),
                    children: [
                      TextSpan(
                        text: '原型跳转：',
                        style: hts(
                          12,
                          dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: '审核未通过',
                        style: hts(
                          12,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: ' · ',
                        style: hts(
                          12,
                          dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: '审核通过待签约',
                        style: hts(
                          12,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                          lh: 20,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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
