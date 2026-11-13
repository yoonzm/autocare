import '../../kit/buttons.dart';

// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockOutShortBoundTemplate extends StatelessWidget {
  const StockOutShortBoundTemplate({super.key, required this.c});
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
            '库存不足',
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
              Color(0xFFFFE1E2),
              Color.fromRGBO(255, 56, 60, 0.18),
            ),
            radius: BorderRadius.circular(14),
            pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s466, Svgs.s467), w: 16, h: 16),
                Flexible(
                  flex: 273,
                  child: Text(
                    '库存不足，无法出库。请先减少数量或先入库。',
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
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(16),
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hcol(
              [
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        c.shortageName,
                        style: hts(
                          14,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 20,
                        ),
                      ),
                    ),
                    Text(
                      c.shortageNeeded,
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 20,
                        tab: true,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.start,
                  gap: 12,
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '当前库存',
                        style: hts(
                          14,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 20,
                        ),
                      ),
                    ),
                    Text(
                      c.shortageStock,
                      style: hts(
                        14,
                        dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                        w: FontWeight.w500,
                        lh: 20,
                        tab: true,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.start,
                  gap: 12,
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: Text(
                        '缺少',
                        style: hts(
                          14,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 20,
                        ),
                      ),
                    ),
                    Text(
                      c.shortageQuantity,
                      style: hts(
                        14,
                        dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                        w: FontWeight.w600,
                        lh: 20,
                        tab: true,
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
              gap: 8,
            ),
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
                    child: AppButton(
                      label: '改数量',
                      kind: AppButtonKind.secondary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: c.busy
                          ? null
                          : () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: AppButton(
                      label: '去入库',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: c.busy
                          ? null
                          : () => c.replenishShortage(context),
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
