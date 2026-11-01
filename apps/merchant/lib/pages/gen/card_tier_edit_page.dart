import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class CardTierEditPage extends StatelessWidget {
  const CardTierEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1140,
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
                          [hsvg(dk(context, Svgs.s71, Svgs.s72), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      to: 'CardTiers',
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '编辑卡种',
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
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(22),
                        pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '保存',
                            style: hts(
                              14,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                      to: 'CardTiers',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  h: 168,
                  bg: dk(context, Color(0xFF18181B), Color(0xFF34343A)),
                  radius: BorderRadius.circular(24),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '驰光汽车美容',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 16,
                                  ls: 0.96,
                                ),
                              ),
                            ),
                            Text(
                              '卡面预览',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFFA1A1AA),
                                  Color(0xFF80808A),
                                ),
                                lh: 18,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 8,
                        ),
                        Text(
                          '黑金卡',
                          style: hts(
                            26,
                            Color(0xFFF5D78E),
                            w: FontWeight.w600,
                            lh: 32,
                            ls: 1.56,
                          ),
                        ),
                        Text(
                          'NO. 0000 0028 · 全场 9 折',
                          style: hts(13, Color(0xFFD4D4D8), lh: 18, tab: true),
                        ),
                      ],
                      main: MainAxisAlignment.spaceBetween,
                      cross: CrossAxisAlignment.stretch,
                      gap: 0,
                      min: false,
                    ),
                    [],
                    behind: [
                      Positioned(
                        right: -80,
                        bottom: -110,
                        child: hsvg(
                          dk(context, Svgs.s73, Svgs.s74),
                          w: 240,
                          h: 240,
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
                  pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: hcol(
                    [
                      hbox(
                        minH: 54,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            hbox(
                              w: 72,
                              child: Text(
                                '卡种名称',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 20,
                                ),
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
                                hint: '请输入卡种名称',
                                value: '黑金卡',
                                align: TextAlign.right,
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
                        minH: 60,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '卡面颜色',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            HSelHolder(
                              groups: [
                                ({0}, false),
                              ],
                              builder: (context, g1) => hrow(
                                [
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: HSel(
                                      ctrl: g1[0],
                                      index: 0,
                                      on: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFF34343A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        shadow: dk(
                                          context,
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFFFFFFF),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFF18181B),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      off: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFF34343A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: HSel(
                                      ctrl: g1[0],
                                      index: 1,
                                      on: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: Color(0xFFF3E2B3),
                                        radius: BorderRadius.circular(16),
                                        shadow: dk(
                                          context,
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFFFFFFF),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFF18181B),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      off: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: Color(0xFFF3E2B3),
                                        radius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: HSel(
                                      ctrl: g1[0],
                                      index: 2,
                                      on: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFD4D4D8),
                                          Color(0xFF3F3F46),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        shadow: dk(
                                          context,
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFFFFFFF),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFF18181B),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      off: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFD4D4D8),
                                          Color(0xFF3F3F46),
                                        ),
                                        radius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: HSel(
                                      ctrl: g1[0],
                                      index: 3,
                                      on: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(16),
                                        shadow: dk(
                                          context,
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFFFFFFF),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          [
                                            BoxShadow(
                                              color: Color(0xFF0485F7),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFF18181B),
                                              offset: Offset(0, 0),
                                              blurRadius: 0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      off: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 10,
                                intrinsic: true,
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
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '升级条件（满足任一即实时升级）',
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
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '单次充值满',
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
                                  '¥',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                                hbox(
                                  w: 72,
                                  child: HInput(
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
                                    hint: '请输入单次充值满',
                                    value: '10,000',
                                    keyboard: TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '累计消费满',
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
                                  '¥',
                                  style: hts(
                                    15,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 22,
                                  ),
                                ),
                                hbox(
                                  w: 72,
                                  child: HInput(
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
                                    hint: '请输入累计消费满',
                                    value: '30,000',
                                    keyboard: TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
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
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '会员权益',
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
                          hbox(
                            minH: 58,
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
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '%',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '项目折扣',
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
                                HHolder(
                                  inits: [90],
                                  builder: (context, ctrls) {
                                    final c2 = ctrls[0];
                                    return hrow(
                                      [
                                        hTap(
                                          context,
                                          hbox(
                                            w: 30,
                                            h: 30,
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(15),
                                            align: Alignment.center,
                                            child: Text(
                                              '−',
                                              style: hts(
                                                17,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 17,
                                              ),
                                            ),
                                          ),
                                          onTap: () => c2.add(-1),
                                        ),
                                        hbox(
                                          w: 52,
                                          align: Alignment.center,
                                          child: hCount(
                                            c2,
                                            hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 22,
                                            ),
                                            1,
                                            ' 折',
                                            false,
                                          ),
                                        ),
                                        hTap(
                                          context,
                                          hbox(
                                            w: 30,
                                            h: 30,
                                            bg: dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFF34343A),
                                            ),
                                            radius: BorderRadius.circular(15),
                                            align: Alignment.center,
                                            child: Text(
                                              '+',
                                              style: hts(
                                                17,
                                                Color(0xFFFFFFFF),
                                                w: FontWeight.w500,
                                                lh: 17,
                                              ),
                                            ),
                                          ),
                                          onTap: () => c2.add(1),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 4,
                                    );
                                  },
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
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
                          HStrHolder(
                            initial: '2 倍',
                            builder: (context, s3) => hTap(
                              context,
                              hbox(
                                minH: 58,
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
                                            dk(context, Svgs.s75, Svgs.s76),
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
                                        '积分倍率',
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
                                    hStr(
                                      s3,
                                      hts(
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
                              onTap: () =>
                                  hPick(context, 'multiplier', '积分倍率', s3),
                            ),
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
                          HStrHolder(
                            initial: '赠精致洗车 2 次',
                            builder: (context, s4) => hTap(
                              context,
                              hbox(
                                minH: 58,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
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
                                            dk(context, Svgs.s77, Svgs.s78),
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
                                            '生日礼',
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
                                          hStr(
                                            s4,
                                            hts(
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
                              onTap: () => hPick(context, 'gift', '生日礼', s4),
                            ),
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
                          hbox(
                            minH: 58,
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
                                        dk(context, Svgs.s79, Svgs.s80),
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
                                    '预约优先排期',
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      Text(
                        '有效期',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hbox(
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: HSelHolder(
                          groups: [
                            ({0}, false),
                          ],
                          builder: (context, g5) => hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g5[0],
                                    index: 0,
                                    on: hbox(
                                      h: 32,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFFFFF),
                                        Color(0xFF18181B),
                                      ),
                                      radius: BorderRadius.circular(16),
                                      shadow: dk(
                                        context,
                                        [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.08,
                                            ),
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
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
                                          '永久有效',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    off: hbox(
                                      h: 32,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFFFFF),
                                        Color(0xFF18181B),
                                      ),
                                      radius: BorderRadius.circular(16),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '永久有效',
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
                                  child: HSel(
                                    ctrl: g5[0],
                                    index: 1,
                                    on: hbox(
                                      h: 32,
                                      radius: BorderRadius.circular(16),
                                      shadow: dk(context, [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.08),
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                        ),
                                      ], null),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '1 年',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
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
                                          '1 年',
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
                                  child: HSel(
                                    ctrl: g5[0],
                                    index: 2,
                                    on: hbox(
                                      h: 32,
                                      radius: BorderRadius.circular(16),
                                      shadow: dk(context, [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.08),
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                        ),
                                      ], null),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '2 年',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
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
                                          '2 年',
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 2,
                            intrinsic: true,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 10,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 48,
                    radius: BorderRadius.circular(24),
                    child: Align(
                      alignment: Alignment.center,
                      widthFactor: 1,
                      child: Text(
                        '停用此卡种',
                        style: hts(
                          15,
                          dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => hConfirmPop(context, '停用此卡种'),
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
