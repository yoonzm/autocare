import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockInLineTemplate extends StatelessWidget {
  final InventoryController c;
  final Map<String, dynamic> line;
  const StockInLineTemplate({super.key, required this.c, required this.line});

  Widget _round(BuildContext context, String svgLight, String svgDark) => hbox(
    w: 32,
    h: 32,
    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
    radius: BorderRadius.circular(16),
    child: hrow(
      [hsvg(dk(context, svgLight, svgDark), w: 14, h: 14)],
      main: MainAxisAlignment.center,
      cross: CrossAxisAlignment.center,
      gap: 0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final muted = dk(context, Color(0xFF71717A), Color(0xFF9A9AA3));
    final ink = dk(context, Color(0xFF18181B), Color(0xFFFAFAFA));
    final shelf = c.lineShelf(line);
    final expiry = c.lineExpiry(line);
    return hcol(
      [
        // 商品名、库存、移除
        hrow(
          [
            Expanded(
              child: hcol(
                [
                  Text(
                    c.lineName(line),
                    style: hts(16, ink, w: FontWeight.w600, lh: 22),
                  ),
                  Text(c.lineStockLabel(line), style: hts(12, muted, lh: 16)),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 2,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => c.remove(line),
              child: _round(context, Svgs.s358, Svgs.s359),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.start,
          gap: 10,
        ),
        // 单价（可改）+ 小计
        hrow(
          [
            Expanded(
              child: GestureDetector(
                onTap: () => c.editLine(context, line, 'cost'),
                child: Text(
                  c.lineUnitCostLabel(line),
                  style: hts(13, muted, lh: 18),
                ),
              ),
            ),
            Text('小计', style: hts(13, muted, lh: 18)),
            hbox(
              minW: 86,
              child: Align(
                alignment: Alignment.centerRight,
                widthFactor: 1,
                child: Text(
                  c.lineTotalLabel(line),
                  style: hts(16, ink, w: FontWeight.w600, lh: 22, tab: true),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 10,
        ),
        // 数量
        hrow(
          [
            Expanded(child: Text('数量', style: hts(13, muted, lh: 18))),
            HNumberStepper.controlled(
              onDecrease: () => c.adjust(line, -1),
              onIncrease: () => c.adjust(line, 1),
              minus: _round(context, Svgs.s16, Svgs.s17),
              value: Flexible(
                flex: 9,
                child: hbox(
                  minW: 40,
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1,
                    child: c.quantityLabel(context, line, size: 16),
                  ),
                ),
              ),
              plus: _round(context, Svgs.s18, Svgs.s19),
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 4,
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 10,
        ),
        if (shelf)
          // 启用保质期管理：必填到期日，点击打开日期弹层。
          Semantics(
            button: true,
            label: '选择到期日',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: c.busy
                  ? null
                  : () => c.editLine(context, line, 'expires_on'),
              child: hbox(
                h: 44,
                bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                radius: BorderRadius.circular(14),
                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: hrow(
                  [
                    Text.rich(
                      TextSpan(
                        text: '到期日 ',
                        children: [
                          TextSpan(
                            text: '*',
                            style: TextStyle(color: Color(0xFFA43433)),
                          ),
                        ],
                      ),
                      style: hts(
                        13,
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                        lh: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      expiry ?? '请选择',
                      style: hts(
                        14,
                        expiry == null ? muted : ink,
                        w: FontWeight.w500,
                        lh: 20,
                      ),
                    ),
                    hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
              ),
            ),
          )
        else
          // 未启用保质期：批次自动生成，只读。
          _DashedTop(
            child: hrow(
              [
                Text('批次', style: hts(13, muted, lh: 18)),
                Expanded(
                  child: Text(
                    c.lineBatchLabel(line),
                    textAlign: TextAlign.right,
                    style: hts(13, muted, lh: 18),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
          ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 12,
    );
  }
}

/// 顶部一条虚线的分隔容器。
class _DashedTop extends StatelessWidget {
  final Widget child;
  const _DashedTop({required this.child});
  @override
  Widget build(BuildContext context) {
    final color = dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40));
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 1,
            child: LayoutBuilder(
              builder: (_, box) => Row(
                children: [
                  for (var i = 0; i < (box.maxWidth / 6).floor(); i++)
                    Container(
                      width: 3,
                      height: 1,
                      margin: const EdgeInsets.only(right: 3),
                      color: color,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
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
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.busy ? null : () => c.add(context),
            child: hbox(
              h: 42,
              bg: dk(
                context,
                Color(0xFFE1F0FE),
                Color.fromRGBO(4, 133, 247, 0.18),
              ),
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
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: UnconstrainedBox(
          alignment: Alignment.topLeft,
          constrainedAxis: Axis.horizontal,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.busy ? null : () => c.scan(context),
            child: hbox(
              h: 42,
              bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
              radius: BorderRadius.circular(21),
              child: hrow(
                [
                  hsvg(dk(context, Svgs.s362, Svgs.s363), w: 16, h: 16),
                  Flexible(
                    flex: 56,
                    child: Text(
                      '扫码添加',
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
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
