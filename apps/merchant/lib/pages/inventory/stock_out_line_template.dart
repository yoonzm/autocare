import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockOutLineTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> line;
  const StockOutLineTemplate({super.key, required this.c, required this.line});
  @override
  Widget build(BuildContext context) => hrow(
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
              c.lineRemainingLabel(line),
              style: hts(
                12,
                dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                lh: 16,
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
          flex: 25,
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
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 10,
  );
}

class StockOutAddTemplate extends StatelessWidget {
  final InventoryController c;
  const StockOutAddTemplate({super.key, required this.c});
  @override
  Widget build(BuildContext context) => AppButton(
    label: '添加商品',
    kind: AppButtonKind.secondary,
    size: AppButtonSize.medium,
    expanded: false,
    svg: dk(context, Svgs.s360, Svgs.s361),
    onPressed: c.busy ? null : () => c.add(context),
  );
}
