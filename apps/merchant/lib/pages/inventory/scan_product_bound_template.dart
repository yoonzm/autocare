import '../../kit/buttons.dart';

// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class ScanProductBoundTemplate extends StatelessWidget {
  const ScanProductBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [
        Positioned.fill(child: c.camera(context)),
        Positioned(
          left: 20,
          top: 56,
          right: 20,
          child: hrow(
            [
              AppIconButton(
                svg: Svgs.s27,
                semanticLabel: "返回",
                onPressed: c.busy
                    ? null
                    : () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '扫码查询',
                  style: hts(17, Color(0xFFFAFAFA), w: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              hbox(w: 44),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 8,
          ),
        ),
        Positioned(
          left: 65,
          top: 200,
          width: 260,
          height: 260,
          child: hbox(
            w: 260,
            h: 260,
            child: hstack(
              hcol(
                [],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 0,
                min: false,
              ),
              [
                Positioned(
                  left: 0,
                  top: 0,
                  width: 36,
                  height: 36,
                  child: hbox(w: 36, h: 36),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  width: 36,
                  height: 36,
                  child: hbox(w: 36, h: 36),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  width: 36,
                  height: 36,
                  child: hbox(w: 36, h: 36),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: 36,
                  height: 36,
                  child: hbox(w: 36, h: 36),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          top: 490,
          right: 0,
          child: Text(
            '把商品条码放进框内，自动识别',
            style: hts(14, dk(context, Color(0xFFA1A1AA), Color(0xFF80808A))),
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 40,
          height: 50,
          child: ActionButton(
            actionKey: c.actionKey,
            label: '手动输入编码',
            kind: AppButtonKind.primary,
            size: AppButtonSize.large,
            expanded: false,
            onPressed: c.busy ? null : () => c.enterBarcode(context),
          ),
        ),
      ],
    );
  }
}
