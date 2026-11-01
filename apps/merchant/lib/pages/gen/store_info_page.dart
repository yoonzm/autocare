import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 960,
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
                        '门店信息',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hTap(
                      context,
                      hbox(
                        h: 44,
                        bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        radius: BorderRadius.circular(22),
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '编辑',
                            style: hts(
                              14,
                              dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                              w: FontWeight.w500,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                      to: 'StoreEdit',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(28),
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
                  clip: true,
                  child: hcol(
                    [
                      HImageSlot(
                        imgKey: 'StoreInfo_15',
                        radius: 16,
                        child: hbox(
                          h: 150,
                          bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                          child: hstack(
                            hcol(
                              [
                                hsvg(
                                  dk(context, Svgs.s372, Svgs.s373),
                                  w: 28,
                                  h: 28,
                                ),
                                Text(
                                  '[门店门头照片]',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                              min: false,
                            ),
                            [
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: hbox(
                                  bg: Color.fromRGBO(24, 24, 27, 0.7),
                                  radius: BorderRadius.circular(12),
                                  pad: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: Text(
                                    '共 6 张',
                                    style: hts(
                                      12,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w500,
                                      lh: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                        child: hcol(
                          [
                            Text(
                              '驰光汽车美容 · 徐汇店',
                              style: hts(
                                19,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 26,
                                ls: -0.38,
                              ),
                            ),
                            hwrap(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFDDF6E7),
                                    Color.fromRGBO(23, 201, 100, 0.16),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 6,
                                        h: 6,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(3),
                                      ),
                                      Flexible(
                                        flex: 36,
                                        child: Text(
                                          '营业中',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 5,
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '专业版',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(11),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '门店编号 CG-0021',
                                    style: hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 22,
                                    ),
                                  ),
                                ),
                              ],
                              gap: 6,
                              rowGap: 6,
                              cross: WrapCrossAlignment.start,
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s374, Svgs.s375),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '门店地址',
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
                                    '上海市徐汇区[详细地址]',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                            hTap(
                              context,
                              Text(
                                '导航',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 20,
                                ),
                              ),
                              label: '导航',
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s376, Svgs.s377),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '联系电话',
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
                                    '021-[门店电话]',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s378, Svgs.s379),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '营业时间',
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
                                    '每天 09:00 – 20:00',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(48, 0, 0, 0),
                      ),
                      hbox(
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hrow(
                          [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                              child: hsvg(
                                dk(context, Svgs.s380, Svgs.s381),
                                w: 20,
                                h: 20,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '工位配置 · 共 6 个',
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 51,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(11),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '洗车 2',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 51,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFDDF6E7),
                                            Color.fromRGBO(23, 201, 100, 0.16),
                                          ),
                                          radius: BorderRadius.circular(11),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '美容 2',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 63,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFFDEFD6),
                                            Color.fromRGBO(245, 165, 36, 0.16),
                                          ),
                                          radius: BorderRadius.circular(11),
                                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                          child: Text(
                                            '贴膜间 2',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF855F2E),
                                                Color(0xFFF0C46A),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 6,
                                    intrinsic: true,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 6,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 12,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '资质证照',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
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
                          hTap(
                            context,
                            hbox(
                              h: 56,
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
                                          dk(context, Svgs.s382, Svgs.s383),
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
                                    child: Text(
                                      '营业执照',
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
                                  ),
                                  Text(
                                    '已认证',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF2B7745),
                                        Color(0xFF5FD48C),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 18,
                                    ),
                                  ),
                                  hsvg(
                                    dk(context, Svgs.s3, Svgs.s4),
                                    w: 16,
                                    h: 16,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            to: 'License',
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hTap(
                            context,
                            hbox(
                              h: 56,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  hbox(
                                    w: 32,
                                    h: 32,
                                    bg: dk(
                                      context,
                                      Color(0xFFFDEFD6),
                                      Color.fromRGBO(245, 165, 36, 0.16),
                                    ),
                                    radius: BorderRadius.circular(10),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s384, Svgs.s385),
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
                                    child: Text(
                                      '排水许可 / 环保备案',
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
                                  ),
                                  Text(
                                    '待上传',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w500,
                                      lh: 18,
                                    ),
                                  ),
                                  hsvg(
                                    dk(context, Svgs.s3, Svgs.s4),
                                    w: 16,
                                    h: 16,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            to: 'EcoFiling',
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
                hTap(
                  context,
                  hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                    radius: BorderRadius.circular(22),
                    pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: hrow(
                      [
                        hbox(
                          w: 40,
                          h: 40,
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(12),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s386, Svgs.s387),
                                w: 22,
                                h: 22,
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
                                '门店二维码',
                                style: hts(
                                  15,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w500,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '客户扫码即可入会、预约',
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
                        hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                  to: 'StoreQR',
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
