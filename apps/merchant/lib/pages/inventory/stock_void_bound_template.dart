import '../../kit/async_kit.dart';
import '../../kit/single_selection.dart';

// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockVoidBoundTemplate extends StatelessWidget {
  const StockVoidBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return AsyncActionScope(
      actionKey: c.actionKey,
      child: hbox(
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
              c.voidTitle,
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            hbox(
              bg: dk(
                context,
                Color(0xFFFDEFD6),
                Color.fromRGBO(245, 165, 36, 0.16),
              ),
              radius: BorderRadius.circular(14),
              pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: hrow(
                [
                  hsvg(dk(context, Svgs.s430, Svgs.s431), w: 16, h: 16),
                  Flexible(
                    flex: 398,
                    child: Text(
                      c.voidEffectLabel,
                      style: hts(
                        13,
                        dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)),
                        w: FontWeight.w500,
                        lh: 18,
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.start,
                gap: 8,
              ),
            ),
            hbox(
              bg: dk(
                context,
                Color(0xFFFFE1E2),
                Color.fromRGBO(255, 56, 60, 0.18),
              ),
              radius: BorderRadius.circular(14),
              pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: hrow(
                [
                  hsvg(dk(context, Svgs.s466, Svgs.s467), w: 16, h: 16),
                  Flexible(
                    flex: 489,
                    child: Text(
                      c.voidAvailabilityLabel,
                      style: hts(
                        13,
                        dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                        w: FontWeight.w500,
                        lh: 18,
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.start,
                gap: 8,
              ),
            ),
            hcol(
              [
                Text(
                  '作废原因',
                  style: hts(
                    13,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    w: FontWeight.w500,
                    lh: 18,
                  ),
                ),
                SingleSelection(
                  index: c.voidReasonIndex,
                  onChanged: c.selectVoidReason,
                  builder: (context, selection) => hwrap(
                    [
                      HSel(
                        ctrl: selection,
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
                              '录错数量',
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
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '录错数量',
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
                        ctrl: selection,
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
                              '录错商品',
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
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '录错商品',
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
                        ctrl: selection,
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
                              '供应商退货',
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
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '供应商退货',
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
                        ctrl: selection,
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
                              '其他',
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
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(17),
                          pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '其他',
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
              gap: 8,
            ),
            hbox(
              pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: hrow(
                [
                  Expanded(
                    flex: 1,
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
                              '再想想',
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
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: UnconstrainedBox(
                      alignment: Alignment.topLeft,
                      constrainedAxis: Axis.horizontal,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: c.busy ? null : () => c.confirmVoid(context),
                        child: hbox(
                          h: 50,
                          bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                          radius: BorderRadius.circular(25),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: c.busyLabel(
                              Text(
                                c.voidConfirmLabel,
                                style: hts(
                                  15,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
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
      ),
    );
  }
}
