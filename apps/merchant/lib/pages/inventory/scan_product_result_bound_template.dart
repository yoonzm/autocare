// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class ScanProductResultBoundTemplate extends StatelessWidget {
  const ScanProductResultBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '扫码结果',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
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
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: c.busy
                      ? null
                      : () => c.openScannedProduct(context, replenish: false),
                  child: hbox(
                    pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: hrow(
                      [
                        hbox(
                          w: 40,
                          h: 40,
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(13),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s464, Svgs.s465),
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
                          child: hbox(
                            minW: 0,
                            child: hcol(
                              [
                                hrow(
                                  [
                                    Flexible(
                                      flex: 128,
                                      child: Text(
                                        c.scanName,
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
                                    Flexible(
                                      flex: 49,
                                      child: hbox(
                                        bg: dk(
                                          context,
                                          Color(0xFFFFE1E2),
                                          Color.fromRGBO(255, 56, 60, 0.18),
                                        ),
                                        radius: BorderRadius.circular(9),
                                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                        child: Text(
                                          c.scanStockState,
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
                                          softWrap: false,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 6,
                                ),
                                Text(
                                  c.scanSkuLocation,
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
                        ),
                        Text(
                          c.scanStock,
                          style: hts(
                            15,
                            dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                            w: FontWeight.w600,
                            lh: 22,
                            tab: true,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.busy
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      child: hbox(
                        h: 50,
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: Text(
                            '继续扫码',
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
                ),
                Expanded(
                  flex: 14,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.busy
                          ? null
                          : () =>
                                c.openScannedProduct(context, replenish: true),
                      child: hbox(
                        h: 50,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
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
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
