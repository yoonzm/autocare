import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ExpenseBudgetPage extends StatelessWidget {
  const ExpenseBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1900,
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
                        '月度预算',
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
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '编辑',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                      to: 'BudgetTotal',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                HHolder(
                  inits: [24321],
                  builder: (context, ctrls) {
                    final m1 = ctrls[0];
                    return hrow(
                      [
                        hTap(
                          context,
                          hbox(
                            w: 36,
                            h: 36,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(18),
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
                              [
                                hsvg(
                                  dk(context, Svgs.s127, Svgs.s128),
                                  w: 16,
                                  h: 16,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          onTap: () => m1.add(-1, min: 0),
                        ),
                        Flexible(
                          flex: 96,
                          child: hbox(
                            minW: 130,
                            child: Align(
                              alignment: Alignment.center,
                              widthFactor: 1,
                              child: hMonth(
                                m1,
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
                            ),
                          ),
                        ),
                        hTap(
                          context,
                          hbox(
                            w: 36,
                            h: 36,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(18),
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
                              [
                                hsvg(
                                  dk(context, Svgs.s129, Svgs.s130),
                                  w: 16,
                                  h: 16,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          onTap: () => m1.add(1, min: 0),
                        ),
                      ],
                      main: MainAxisAlignment.center,
                      cross: CrossAxisAlignment.center,
                      gap: 6,
                    );
                  },
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
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '本月总预算 ¥171,000',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                      lh: 18,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 88,
                                        child: Text(
                                          '97.7%',
                                          style: hts(
                                            32,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 40,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 42,
                                        child: Text(
                                          '已使用',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.baseline,
                                    gap: 6,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 4,
                              ),
                            ),
                            hTap(
                              context,
                              hbox(
                                h: 34,
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(17),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: hrow(
                                  [
                                    hsvg(Svgs.s131, w: 15, h: 15),
                                    Flexible(
                                      flex: 26,
                                      child: Text(
                                        '调整',
                                        style: hts(
                                          13,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 6,
                                ),
                              ),
                              to: 'BudgetTotal',
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.end,
                          gap: 0,
                        ),
                        hbox(
                          h: 8,
                          bg: Color(0xFF27272A),
                          radius: BorderRadius.circular(4),
                          child: hcol(
                            [
                              Align(
                                alignment: Alignment.topLeft,
                                child: hfrac(
                                  0.98,
                                  hbox(
                                    h: 8,
                                    bg: Color(0xFFF5A524),
                                    radius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                            min: false,
                          ),
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hbox(
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: hcol(
                                  [
                                    Text(
                                      '已用',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 14,
                                      ),
                                    ),
                                    Text(
                                      '¥167,070',
                                      style: hts(
                                        15,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 20,
                                        tab: true,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hbox(
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: hcol(
                                  [
                                    Text(
                                      '剩余',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 14,
                                      ),
                                    ),
                                    Text(
                                      '¥3,930',
                                      style: hts(
                                        15,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 20,
                                        tab: true,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hbox(
                                bg: Color(0xFF27272A),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                                child: hcol(
                                  [
                                    Text(
                                      '剩余天数',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 14,
                                      ),
                                    ),
                                    Text(
                                      '1 天',
                                      style: hts(
                                        15,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 20,
                                        tab: true,
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
                          cross: CrossAxisAlignment.stretch,
                          gap: 8,
                          intrinsic: true,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
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
                  bg: dk(
                    context,
                    Color(0xFFFFE1E2),
                    Color.fromRGBO(255, 56, 60, 0.18),
                  ),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      hbox(
                        w: 36,
                        h: 36,
                        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                        radius: BorderRadius.circular(12),
                        child: hrow(
                          [
                            hsvg(
                              dk(context, Svgs.s132, Svgs.s133),
                              w: 19,
                              h: 19,
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
                              '材料采购已超支 ¥4,570',
                              style: hts(
                                14,
                                Color(0xFF7A1F1E),
                                w: FontWeight.w600,
                                lh: 20,
                              ),
                            ),
                            Text(
                              '可追加预算或从其他分类调剂',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFFA43433),
                                  Color(0xFFFF7B7E),
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
                      hTap(
                        context,
                        hbox(
                          h: 34,
                          bg: Color(0xFFA43433),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment(-1, 0),
                            widthFactor: 1,
                            child: Text(
                              '追加预算',
                              style: hts(
                                13,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        to: 'BudgetAdjust',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(18),
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
                          pad: EdgeInsets.fromLTRB(4, 12, 4, 12),
                          child: hcol(
                            [
                              hbox(
                                w: 34,
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(11),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s134, Svgs.s135),
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
                                '复制上月预算',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 6,
                          ),
                        ),
                        to: 'BudgetTotal',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(18),
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
                          pad: EdgeInsets.fromLTRB(4, 12, 4, 12),
                          child: hcol(
                            [
                              hbox(
                                w: 34,
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(11),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s136, Svgs.s137),
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
                                '按营收比例分配',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 6,
                          ),
                        ),
                        to: 'BudgetTotal',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(18),
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
                          pad: EdgeInsets.fromLTRB(4, 12, 4, 12),
                          child: hcol(
                            [
                              hbox(
                                w: 34,
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(11),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s138, Svgs.s139),
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
                                '添加分类预算',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 6,
                          ),
                        ),
                        to: 'BudgetEdit',
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                  intrinsic: true,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '分类预算 · 点击可调整',
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
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s42, Svgs.s43),
                                              w: 17,
                                              h: 17,
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
                                          '房租',
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
                                      ),
                                      Text(
                                        '100%',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
                                        w: 16,
                                        h: 16,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        hbox(
                                          h: 6,
                                          bg: Color(0xFFF5A524),
                                          radius: BorderRadius.circular(3),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥28,000 · 预算 ¥28,000',
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
                                        '100% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                          hTap(
                            context,
                            hbox(
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s44, Svgs.s45),
                                              w: 17,
                                              h: 17,
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
                                          '人工',
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
                                      ),
                                      Text(
                                        '95%',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
                                        w: 16,
                                        h: 16,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.95,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFFF5A524),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥82,000 · 预算 ¥86,000',
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
                                        '80% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                          hTap(
                            context,
                            hbox(
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s46, Svgs.s47),
                                              w: 17,
                                              h: 17,
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
                                          '材料采购',
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
                                      ),
                                      hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFFFE1E2),
                                          Color.fromRGBO(255, 56, 60, 0.18),
                                        ),
                                        radius: BorderRadius.circular(9),
                                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                        child: Text(
                                          '超支 ¥4,570',
                                          style: hts(
                                            11,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 18,
                                          ),
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
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        hbox(
                                          h: 6,
                                          bg: Color(0xFFFF383C),
                                          radius: BorderRadius.circular(3),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥36,570 · 预算 ¥32,000',
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
                                        '80% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                          hTap(
                            context,
                            hbox(
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s48, Svgs.s49),
                                              w: 17,
                                              h: 17,
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
                                          '水电',
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
                                      ),
                                      Text(
                                        '89%',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
                                        w: 16,
                                        h: 16,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.89,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFFF5A524),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥6,200 · 预算 ¥7,000',
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
                                        '80% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                          hTap(
                            context,
                            hbox(
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s50, Svgs.s51),
                                              w: 17,
                                              h: 17,
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
                                          '营销',
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
                                      ),
                                      Text(
                                        '82%',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
                                        w: 16,
                                        h: 16,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.82,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFF17C964),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥9,800 · 预算 ¥12,000',
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
                                        '90% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                          hTap(
                            context,
                            hbox(
                              pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: hcol(
                                [
                                  hrow(
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
                                              dk(context, Svgs.s52, Svgs.s53),
                                              w: 17,
                                              h: 17,
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
                                          '其他',
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
                                      ),
                                      Text(
                                        '75%',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
                                        w: 16,
                                        h: 16,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hbox(
                                    h: 6,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(3),
                                    child: hcol(
                                      [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hfrac(
                                            0.75,
                                            hbox(
                                              h: 6,
                                              bg: Color(0xFF17C964),
                                              radius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                      min: false,
                                    ),
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '已用 ¥4,500 · 预算 ¥6,000',
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
                                        '80% 提醒',
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
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 8,
                              ),
                            ),
                            to: 'BudgetEdit',
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
                        '提醒与规则',
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
                                  child: hcol(
                                    [
                                      Text(
                                        '使用达阈值时提醒我',
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
                                        '各分类可单独设置阈值',
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
                                  child: hcol(
                                    [
                                      Text(
                                        '超支时通知店长',
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
                                        '推送到店长手机',
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
                                  child: hcol(
                                    [
                                      Text(
                                        '下月沿用本月预算',
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
                                        '月初自动生成，可再调整',
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
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
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
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '调整预算',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                    to: 'BudgetTotal',
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
