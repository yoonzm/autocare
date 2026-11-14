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
        minus: hbox(
          w: 32,
          h: 32,
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
          radius: BorderRadius.circular(16),
          child: hrow(
            [hsvg(dk(context, Svgs.s16, Svgs.s17), w: 14, h: 14)],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            gap: 0,
          ),
        ),
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
        plus: hbox(
          w: 32,
          h: 32,
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
          radius: BorderRadius.circular(16),
          child: hrow(
            [hsvg(dk(context, Svgs.s18, Svgs.s19), w: 14, h: 14)],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            gap: 0,
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
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: c.busy ? null : () => c.add(context),
    child: hbox(
      h: 42,
      bg: dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)),
      radius: BorderRadius.circular(21),
      child: hrow(
        [
          hsvg(dk(context, Svgs.s360, Svgs.s361), w: 16, h: 16),
          Flexible(
            flex: 56,
            child: Text(
              '添加商品',
              style: hts(
                14,
                dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
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
  );
}
