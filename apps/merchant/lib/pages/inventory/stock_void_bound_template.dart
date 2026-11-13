import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;

import '../../kit/buttons.dart';
import '../../kit/async_kit.dart';

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
                AppChoiceGroup<int>(
                  items: [
                    ChoiceItem(value: 0, label: '录错数量'),
                    ChoiceItem(value: 1, label: '录错商品'),
                    ChoiceItem(value: 2, label: '供应商退货'),
                    ChoiceItem(value: 3, label: '其他'),
                  ],
                  selected: c.voidReasonIndex,
                  onChanged: c.selectVoidReason,
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
                      child: AppButton(
                        label: '再想想',
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
                      child: ActionButton(
                        actionKey: c.actionKey,
                        label: c.voidConfirmLabel,
                        kind: AppButtonKind.danger,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: c.busy ? null : () => c.confirmVoid(context),
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
