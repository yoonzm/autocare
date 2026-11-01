import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class CardTiersPage extends StatelessWidget {
  const CardTiersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1000,
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
                        '会员卡种与权益',
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
                        w: 44,
                        h: 44,
                        bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        radius: BorderRadius.circular(22),
                        child: hrow(
                          [hsvg(dk(context, Svgs.s81, Svgs.s82), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      to: 'CardTierEdit',
                    ),
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
                          child: HToggle(
                            initial: true,
                            on: hbox(
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
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  '等级储值卡 4',
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
                            off: hbox(
                              h: 32,
                              radius: BorderRadius.circular(16),
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  '等级储值卡 4',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
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
                                  '次卡套餐 6',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 20,
                                  ),
                                ),
                              ),
                            ),
                            to: 'CardPackages',
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
                hTap(
                  context,
                  hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                    radius: BorderRadius.circular(24),
                    pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    clip: true,
                    child: hstack(
                      hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '黑金卡',
                                  style: hts(
                                    18,
                                    Color(0xFFF5D78E),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    ls: 0.72,
                                  ),
                                ),
                              ),
                              Text.rich(
                                TextSpan(
                                  style: hts(
                                    26,
                                    Color(0xFFF5D78E),
                                    w: FontWeight.w600,
                                    lh: 30,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '9',
                                      style: hts(
                                        26,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' 折',
                                      style: hts(
                                        14,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.baseline,
                            gap: 8,
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '充值 ¥10,000 / 累计消费 ¥30,000 · 积分 2 倍',
                                  style: hts(12, Color(0xFFD4D4D8), lh: 16),
                                ),
                              ),
                              Text(
                                '86 人',
                                style: hts(
                                  12,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w600,
                                  lh: 16,
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
                        gap: 22,
                      ),
                      [],
                      behind: [
                        Positioned(
                          top: -80,
                          right: -60,
                          child: hsvg(
                            dk(context, Svgs.s83, Svgs.s84),
                            w: 200,
                            h: 200,
                          ),
                        ),
                      ],
                    ),
                  ),
                  to: 'CardTierEdit',
                ),
                hTap(
                  context,
                  hbox(
                    bg: Color(0xFFF3E2B3),
                    radius: BorderRadius.circular(24),
                    pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: hcol(
                      [
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '金卡',
                                style: hts(
                                  18,
                                  Color(0xFF3D2B0E),
                                  w: FontWeight.w600,
                                  lh: 26,
                                  ls: 0.72,
                                ),
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                style: hts(
                                  26,
                                  Color(0xFF3D2B0E),
                                  w: FontWeight.w600,
                                  lh: 30,
                                ),
                                children: [
                                  TextSpan(
                                    text: '95',
                                    style: hts(
                                      26,
                                      Color(0xFF3D2B0E),
                                      w: FontWeight.w600,
                                      lh: 30,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 折',
                                    style: hts(
                                      14,
                                      Color(0xFF3D2B0E),
                                      w: FontWeight.w600,
                                      lh: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.baseline,
                          gap: 8,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '充值 ¥5,000 / 累计消费 ¥10,000 · 积分 1.5 倍',
                                style: hts(12, Color(0xFF5C4520), lh: 16),
                              ),
                            ),
                            Text(
                              '312 人',
                              style: hts(
                                12,
                                Color(0xFF3D2B0E),
                                w: FontWeight.w600,
                                lh: 16,
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
                      gap: 22,
                    ),
                  ),
                  to: 'CardTierEdit',
                ),
                hTap(
                  context,
                  hbox(
                    bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                    radius: BorderRadius.circular(24),
                    pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: hcol(
                      [
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '银卡',
                                style: hts(
                                  18,
                                  dk(
                                    context,
                                    Color(0xFF27272A),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 26,
                                  ls: 0.72,
                                ),
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                style: hts(
                                  26,
                                  dk(
                                    context,
                                    Color(0xFF27272A),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 30,
                                ),
                                children: [
                                  TextSpan(
                                    text: '98',
                                    style: hts(
                                      26,
                                      dk(
                                        context,
                                        Color(0xFF27272A),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 30,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' 折',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF27272A),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.baseline,
                          gap: 8,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '充值 ¥2,000 / 累计消费 ¥3,000 · 积分 1 倍',
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
                            ),
                            Text(
                              '540 人',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF27272A),
                                  Color(0xFFD4D4D8),
                                ),
                                w: FontWeight.w600,
                                lh: 16,
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
                      gap: 22,
                    ),
                  ),
                  to: 'CardTierEdit',
                ),
                hTap(
                  context,
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
                    pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: hcol(
                      [
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '普通会员',
                                style: hts(
                                  18,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 26,
                                  ls: 0.72,
                                ),
                              ),
                            ),
                            Text(
                              '原价',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
                                w: FontWeight.w500,
                                lh: 30,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.baseline,
                          gap: 8,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '扫码免费注册 · 消费累积积分',
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
                            ),
                            Text(
                              '348 人',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 16,
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
                      gap: 22,
                    ),
                  ),
                  to: 'CardTierEdit',
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
                        '通用规则',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '充值或消费自动升级',
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
                                  '单次充值或累计消费达标，实时升级，取最高等级',
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
                              gap: 0,
                            ),
                          ),
                          HSwitch(initial: true),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 12,
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '储值余额可退款',
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
                                  '退款时扣除已赠送金额',
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
                              gap: 0,
                            ),
                          ),
                          HSwitch(initial: false),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 12,
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
      overlays: [],
    );
  }
}
