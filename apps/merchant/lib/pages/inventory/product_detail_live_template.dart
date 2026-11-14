import '../../kit/single_selection.dart';
import 'inventory_controller.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class ProductDetailLiveTemplate extends StatelessWidget {
  const ProductDetailLiveTemplate({super.key, required this.c});
  final InventoryController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1420,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: hcol(
              [
                hrow(
                  [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.busy
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      child: hbox(
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
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '商品详情',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.busy
                          ? null
                          : () => editProduct(context, c.detail),
                      child: hbox(
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
                          [
                            hsvg(
                              dk(context, Svgs.s460, Svgs.s461),
                              w: 20,
                              h: 20,
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
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
                        hrow(
                          [
                            hbox(
                              w: 44,
                              h: 44,
                              bg: Color(0xFF27272A),
                              radius: BorderRadius.circular(14),
                              child: hrow(
                                [hsvg(Svgs.s315, w: 22, h: 22)],
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
                                    c.productName,
                                    style: hts(
                                      16,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 22,
                                    ),
                                  ),
                                  Text(
                                    c.skuCategoryLabel,
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
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '当前库存',
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
                                  hrow(
                                    [
                                      Flexible(
                                        flex: 22,
                                        child: Text(
                                          c.stockLabel,
                                          style: hts(
                                            38,
                                            Color(0xFFFF8A8C),
                                            w: FontWeight.w600,
                                            lh: 44,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 14,
                                        child: Text(
                                          c.unitLabel,
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
                                gap: 2,
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
                                c.stockStatusLabel,
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
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.end,
                          gap: 0,
                        ),
                        hcol(
                          [
                            hbox(
                              h: 8,
                              bg: Color(0xFF27272A),
                              radius: BorderRadius.circular(4),
                              child: hstack(
                                hcol(
                                  [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hfrac(
                                        c.stockRatio,
                                        hbox(
                                          h: 8,
                                          bg: Color(0xFFFF383C),
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
                                [
                                  Positioned(
                                    top: -3,
                                    width: 2,
                                    height: 14,
                                    child: NegMargin(
                                      top: 0,
                                      left: -2,
                                      child: hbox(
                                        w: 2,
                                        h: 14,
                                        bg: Color(0xFFFAFAFA),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '0',
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
                                ),
                                Text(
                                  c.safeStockLabel,
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
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.start,
                              gap: 0,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 6,
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
                                      '本月消耗',
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
                                      c.monthUsedLabel,
                                      style: hts(
                                        15,
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
                                      '预计可用',
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
                                      c.availableDaysLabel,
                                      style: hts(
                                        15,
                                        Color(0xFFF5D78E),
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
                                      '建议补货',
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
                                      c.replenishLabel,
                                      style: hts(
                                        15,
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
                      gap: 16,
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
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '基本信息',
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
                                    '规格',
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
                                  c.specificationLabel,
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
                                    '成本价',
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
                                  c.unitCostLabel,
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
                                    '库存成本',
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
                                  c.stockCostLabel,
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
                          Builder(
                            builder: (context) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: c.busy
                                  ? null
                                  : () => c.pick(context, 'supplier', '供应商'),
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '供应商',
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
                                      c.supplierLabel,
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
                                    '货位',
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
                                  c.locationLabel,
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
                        '批次库存 · 先进先出',
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
                      child: c.batchesWidget(context),
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
                        '出入库流水',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(20),
                      pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                      child: SingleSelection(
                        index: c.filter,
                        onChanged: c.selectFilter,
                        builder: (context, g2) => hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: UnconstrainedBox(
                                alignment: Alignment.topLeft,
                                constrainedAxis: Axis.horizontal,
                                child: HSel(
                                  ctrl: g2,
                                  index: 0,
                                  segment: true,
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
                                        '全部',
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
                                        '全部',
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
                                  ctrl: g2,
                                  index: 1,
                                  segment: true,
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
                                        '入库',
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
                                        '入库',
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
                                  ctrl: g2,
                                  index: 2,
                                  segment: true,
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
                                        '出库',
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
                                        '出库',
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
                      child: c.historyWidget(context),
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
                  flex: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: c.busy ? null : () => c.openMovement(context, 'out'),
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '出库',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: c.busy ? null : () => c.openMovement(context, 'in'),
                    child: hbox(
                      h: 50,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      child: hrow(
                        [
                          hsvg(Svgs.s14, w: 18, h: 18),
                          Flexible(
                            flex: 60,
                            child: Text(
                              '入库补货',
                              style: hts(
                                15,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 6,
                      ),
                    ),
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
