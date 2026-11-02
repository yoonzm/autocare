import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class PackageDetailPage extends StatelessWidget {
  const PackageDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 912,
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
                        '次卡详情',
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
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [
                      Color(0xFF2A2A30),
                      Color(0xFF18181B),
                      Color(0xFF121214),
                    ],
                    stops: [0, 0.6, 1],
                  ),
                  radius: BorderRadius.circular(28),
                  shadow: [
                    BoxShadow(
                      color: Color.fromRGBO(24, 24, 27, 0.16),
                      offset: Offset(0, 10),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                  pad: EdgeInsets.fromLTRB(18, 18, 18, 18),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            hPackageRing(),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hPackageText(
                                    (k) => k.name,
                                    '精致洗车年卡',
                                    hts(
                                      19,
                                      Color(0xFFFFFFFF),
                                      w: FontWeight.w600,
                                      lh: 26,
                                    ),
                                  ),
                                  hPackageText(
                                    (k) => k.owner,
                                    '王建国 · 黑金会员',
                                    hts(
                                      12,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 17,
                                    ),
                                  ),
                                  hbox(
                                    margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                                    child: hrow(
                                      [
                                        Flexible(
                                          flex: 49,
                                          child: hbox(
                                            bg: Color.fromRGBO(
                                              23,
                                              201,
                                              100,
                                              0.2,
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: hPackageText(
                                              (k) => k.status,
                                              '使用中',
                                              hts(
                                                11,
                                                Color(0xFF5FD48C),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          flex: 82,
                                          child: hbox(
                                            bg: Color.fromRGBO(
                                              245,
                                              165,
                                              36,
                                              0.2,
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: hPackageText(
                                              (k) => k.expiryNote,
                                              '150 天后到期',
                                              hts(
                                                11,
                                                Color(0xFFF0C46A),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 6,
                                      intrinsic: true,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 3,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 16,
                        ),
                        hbox(
                          border: Border(
                            top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          ),
                          pad: EdgeInsets.fromLTRB(0, 14, 0, 0),
                          child: hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '购买日期',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      hPackageText(
                                        (k) => k.purchasedAt,
                                        '2026.03.31',
                                        hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '到期日',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      hPackageText(
                                        (k) => k.expiresAt,
                                        '2027.03.31',
                                        hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 20,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '实付',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      hPackageText(
                                        (k) => k.paidText,
                                        '¥1,080',
                                        hts(
                                          14,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
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
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                              min: false,
                            ),
                          ], gap: 8),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 16,
                    ),
                    [],
                    behind: [
                      Positioned(
                        right: -108,
                        bottom: -138,
                        child: hsvg(Svgs.s272, w: 240, h: 240),
                      ),
                    ],
                  ),
                ),
                hPackageServices(),
                hPackageRecords(),
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
                  flex: 10,
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
                          '延期',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'PackageExtend',
                  ),
                ),
                Expanded(
                  flex: 10,
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
                          '退款',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'PackageRefund',
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '开单抵扣',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'Order',
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
