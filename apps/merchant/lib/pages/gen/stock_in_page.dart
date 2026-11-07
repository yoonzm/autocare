import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StockInPage extends StatelessWidget {
  const StockInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1500,
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
                          [hsvg(dk(context, Svgs.s26, Svgs.s27), w: 20, h: 20)],
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
                        '商品入库',
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
                            '草稿',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                      to: 'Inventory',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '单据信息',
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
                              minH: 54,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text.rich(
                                      TextSpan(
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                          lh: 20,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '供应商 ',
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
                                          TextSpan(
                                            text: '*',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFFA43433),
                                                Color(0xFFFF7B7E),
                                              ),
                                              lh: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '蓝盾膜业',
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
                            to: 'SupplierPicker',
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
                          HStrHolder(
                            initial: '今天 10.31',
                            builder: (context, s1) => hTap(
                              context,
                              hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '入库日期',
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
                                    hStr(
                                      s1,
                                      hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
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
                              onTap: () => hPick(context, 'date', '入库日期', s1),
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
                                    '入库单号',
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
                                Text(
                                  'RK-20261031-03',
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
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '入库明细',
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: HDyn(
                        texts: [
                          'TPU 隐形车衣 7.5mil当前库存 2 卷 · 低于安全库存单价 ¥2,380.00 / 卷批次 自动生成 · 无保质期6¥14,280.00',
                          '9H 陶瓷镀晶液 50ml当前库存 6 瓶单价 ¥168.00 / 瓶批次 自动生成 · 有效期 2028.1010¥1,680.00',
                        ],
                        builder: (context, d2) => hcol(
                          [
                            ...d2.vis([
                              hcol(
                                [
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              'TPU 隐形车衣 7.5mil',
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
                                              '当前库存 2 卷 · 低于安全库存',
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
                                          gap: 2,
                                        ),
                                      ),
                                      hTap(
                                        context,
                                        hbox(
                                          w: 32,
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s358,
                                                  Svgs.s359,
                                                ),
                                                w: 14,
                                                h: 14,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                        onTap: () =>
                                            d2.confirmRemove(context, 0),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '单价 ¥2,380.00 / 卷',
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
                                              '批次 自动生成 · 无保质期',
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
                                          gap: 2,
                                        ),
                                      ),
                                      HHolder(
                                        inits: [6],
                                        builder: (context, ctrls) {
                                          final c3 = ctrls[0];
                                          return HNumberStepper(
                                            ctrl: c3,
                                            step: 1,
                                            minus: hbox(
                                              w: 32,
                                              h: 32,
                                              bg: dk(
                                                context,
                                                Color(0xFFF4F4F5),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(16),
                                              child: hrow(
                                                [
                                                  hsvg(
                                                    dk(
                                                      context,
                                                      Svgs.s16,
                                                      Svgs.s17,
                                                    ),
                                                    w: 14,
                                                    h: 14,
                                                  ),
                                                ],
                                                main: MainAxisAlignment.center,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 0,
                                              ),
                                            ),
                                            value: Flexible(
                                              flex: 9,
                                              child: hbox(
                                                minW: 36,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  widthFactor: 1,
                                                  child: hCount(
                                                    c3,
                                                    hts(
                                                      15,
                                                      dk(
                                                        context,
                                                        Color(0xFF18181B),
                                                        Color(0xFFFAFAFA),
                                                      ),
                                                      w: FontWeight.w600,
                                                      lh: 22,
                                                      tab: true,
                                                    ),
                                                    0,
                                                    '',
                                                    false,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            plus: hbox(
                                              w: 32,
                                              h: 32,
                                              bg: dk(
                                                context,
                                                Color(0xFFF4F4F5),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(16),
                                              child: hrow(
                                                [
                                                  hsvg(
                                                    dk(
                                                      context,
                                                      Svgs.s18,
                                                      Svgs.s19,
                                                    ),
                                                    w: 14,
                                                    h: 14,
                                                  ),
                                                ],
                                                main: MainAxisAlignment.center,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 0,
                                              ),
                                            ),
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 4,
                                          );
                                        },
                                      ),
                                      hbox(
                                        minW: 78,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          widthFactor: 1,
                                          child: Text(
                                            '¥14,280.00',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 22,
                                              tab: true,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 10,
                              ),
                              hcol(
                                [
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '9H 陶瓷镀晶液 50ml',
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
                                              '当前库存 6 瓶',
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
                                          gap: 2,
                                        ),
                                      ),
                                      hTap(
                                        context,
                                        hbox(
                                          w: 32,
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(
                                                  context,
                                                  Svgs.s358,
                                                  Svgs.s359,
                                                ),
                                                w: 14,
                                                h: 14,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                        onTap: () =>
                                            d2.confirmRemove(context, 1),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                  hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '单价 ¥168.00 / 瓶',
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
                                              '批次 自动生成 · 有效期 2028.10',
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
                                          gap: 2,
                                        ),
                                      ),
                                      HHolder(
                                        inits: [10],
                                        builder: (context, ctrls) {
                                          final c4 = ctrls[0];
                                          return HNumberStepper(
                                            ctrl: c4,
                                            step: 1,
                                            minus: hbox(
                                              w: 32,
                                              h: 32,
                                              bg: dk(
                                                context,
                                                Color(0xFFF4F4F5),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(16),
                                              child: hrow(
                                                [
                                                  hsvg(
                                                    dk(
                                                      context,
                                                      Svgs.s16,
                                                      Svgs.s17,
                                                    ),
                                                    w: 14,
                                                    h: 14,
                                                  ),
                                                ],
                                                main: MainAxisAlignment.center,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 0,
                                              ),
                                            ),
                                            value: Flexible(
                                              flex: 17,
                                              child: hbox(
                                                minW: 36,
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  widthFactor: 1,
                                                  child: hCount(
                                                    c4,
                                                    hts(
                                                      15,
                                                      dk(
                                                        context,
                                                        Color(0xFF18181B),
                                                        Color(0xFFFAFAFA),
                                                      ),
                                                      w: FontWeight.w600,
                                                      lh: 22,
                                                      tab: true,
                                                    ),
                                                    0,
                                                    '',
                                                    false,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            plus: hbox(
                                              w: 32,
                                              h: 32,
                                              bg: dk(
                                                context,
                                                Color(0xFFF4F4F5),
                                                Color(0xFF27272A),
                                              ),
                                              radius: BorderRadius.circular(16),
                                              child: hrow(
                                                [
                                                  hsvg(
                                                    dk(
                                                      context,
                                                      Svgs.s18,
                                                      Svgs.s19,
                                                    ),
                                                    w: 14,
                                                    h: 14,
                                                  ),
                                                ],
                                                main: MainAxisAlignment.center,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 0,
                                              ),
                                            ),
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 4,
                                          );
                                        },
                                      ),
                                      hbox(
                                        minW: 78,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          widthFactor: 1,
                                          child: Text(
                                            '¥1,680.00',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 22,
                                              tab: true,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 10,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 10,
                              ),
                            ]),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 42,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(21),
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s360, Svgs.s361),
                                              w: 16,
                                              h: 16,
                                            ),
                                            Flexible(
                                              flex: 56,
                                              child: Text(
                                                '添加商品',
                                                style: hts(
                                                  14,
                                                  dk(
                                                    context,
                                                    Color(0xFF1E63AE),
                                                    Color(0xFF6AB4FA),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                      ),
                                      to: 'ProductPicker',
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
                                        h: 42,
                                        bg: dk(
                                          context,
                                          Color(0xFFEEEEF0),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(21),
                                        child: hrow(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s362, Svgs.s363),
                                              w: 16,
                                              h: 16,
                                            ),
                                            Flexible(
                                              flex: 56,
                                              child: Text(
                                                '扫码添加',
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
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                      ),
                                      to: 'ScanProduct',
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
                        '费用',
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
                          HStrHolder(
                            initial: '¥120.00',
                            builder: (context, s5) => hTap(
                              context,
                              hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '运费',
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
                                    hStr(
                                      s5,
                                      hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
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
                              onTap: () => hPick(context, 'amount', '运费', s5),
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
                                    '商品合计',
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
                                Text(
                                  '¥15,960.00',
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
                                  child: Text(
                                    '应付合计',
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
                                ),
                                Text(
                                  '¥16,080.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    tab: true,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.baseline,
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
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '付款与记账',
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          hcol(
                            [
                              Text(
                                '付款方式',
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
                              HSelHolder(
                                groups: [
                                  ({2}, false),
                                ],
                                builder: (context, g6) => hwrap(
                                  [
                                    HSel(
                                      ctrl: g6[0],
                                      index: 0,
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '现金',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '现金',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: g6[0],
                                      index: 1,
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '微信',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '微信',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: g6[0],
                                      index: 2,
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '对公转账',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '对公转账',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    HSel(
                                      ctrl: g6[0],
                                      index: 3,
                                      on: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFE1F0FE),
                                          Color.fromRGBO(4, 133, 247, 0.18),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        border: Border.all(
                                          color: Color(0xFF0485F7),
                                          width: 1.5,
                                        ),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '挂账',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF1E63AE),
                                                Color(0xFF6AB4FA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                      off: hbox(
                                        h: 34,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(17),
                                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '挂账',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF3F3F46),
                                                Color(0xFFD4D4D8),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  gap: 8,
                                  rowGap: 8,
                                  cross: WrapCrossAlignment.start,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 10,
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '同步记一笔开支',
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
                                      '材料采购 · ¥16,080.00',
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
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
                      Text.rich(
                        TextSpan(
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 20,
                          ),
                          children: [
                            TextSpan(
                              text: '送货单 / 发票 ',
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
                            TextSpan(
                              text: '· 选填',
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
                          ],
                        ),
                      ),
                      hrow(
                        [
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: hbox(
                              w: 72,
                              h: 72,
                              bg: dk(
                                context,
                                Color(0xFFEEEEF0),
                                Color(0xFF27272A),
                              ),
                              radius: BorderRadius.circular(16),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s142, Svgs.s143),
                                    w: 26,
                                    h: 26,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                          ),
                          UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HImageAdd(
                              imgKey: 'StockIn_10',
                              size: 72,
                              radius: 16,
                              child: hbox(
                                w: 72,
                                h: 72,
                                radius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFFC7C7CC),
                                  width: 1.5,
                                ),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s125, Svgs.s126),
                                      w: 24,
                                      h: 24,
                                    ),
                                  ],
                                  main: MainAxisAlignment.center,
                                  cross: CrossAxisAlignment.center,
                                  gap: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                        intrinsic: true,
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
                  child: hcol(
                    [
                      Text(
                        '应付 · 16 件商品',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                      Text(
                        '¥16,080.00',
                        style: hts(
                          24,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 30,
                          ls: -0.48,
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
                  hbox(
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    pad: EdgeInsets.fromLTRB(28, 0, 28, 0),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '确认入库',
                        style: hts(
                          15,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'Expenses',
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
