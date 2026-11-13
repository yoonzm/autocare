import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockInLineTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> line;
  const StockInLineTemplate({super.key, required this.c, required this.line});
  @override
  Widget build(BuildContext context) => hcol(
    [
      hrow(
        [
          Expanded(
            flex: 1,
            child: hcol(
              [
                Text(
                  c.lineName(line),
                  style: hts(
                    15,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 22,
                  ),
                ),
                Text(
                  c.lineStockLabel(line),
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 2,
            ),
          ),
          AppIconButton(
            svg: dk(context, Svgs.s358, Svgs.s359),
            semanticLabel: '移除商品',
            onPressed: () => c.remove(line),
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
                GestureDetector(
                  onTap: () => c.editLine(context, line, 'cost'),
                  child: Text(
                    c.lineUnitCostLabel(line),
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 16,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => c.editLine(context, line, 'expires_on'),
                  child: Text(
                    c.lineBatchLabel(line),
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 16,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 2,
            ),
          ),
          HNumberStepper.controlled(
            onDecrease: () => c.adjust(line, -1),
            onIncrease: () => c.adjust(line, 1),

            value: Flexible(
              flex: 9,
              child: hbox(
                minW: 36,
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1,
                  child: c.quantityLabel(context, line),
                ),
              ),
            ),

            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 4,
          ),
          hbox(
            minW: 78,
            child: Align(
              alignment: Alignment.centerRight,
              widthFactor: 1,
              child: Text(
                c.lineTotalLabel(line),
                style: hts(
                  15,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
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
  );
}

class StockInAddTemplate extends StatelessWidget {
  final InventoryController c;
  const StockInAddTemplate({super.key, required this.c});
  @override
  Widget build(BuildContext context) => hrow(
    [
      Expanded(
        flex: 1,
        child: UnconstrainedBox(
          alignment: Alignment.topLeft,
          constrainedAxis: Axis.horizontal,
          child: AppButton(
            label: '添加商品',
            kind: AppButtonKind.secondary,
            size: AppButtonSize.medium,
            expanded: false,
            svg: dk(context, Svgs.s360, Svgs.s361),
            onPressed: c.busy ? null : () => c.add(context),
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: UnconstrainedBox(
          alignment: Alignment.topLeft,
          constrainedAxis: Axis.horizontal,
          child: AppButton(
            label: '扫码添加',
            kind: AppButtonKind.secondary,
            size: AppButtonSize.medium,
            expanded: false,
            svg: dk(context, Svgs.s362, Svgs.s363),
            onPressed: c.busy ? null : () => c.scan(context),
          ),
        ),
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.stretch,
    gap: 8,
    intrinsic: true,
  );
}
