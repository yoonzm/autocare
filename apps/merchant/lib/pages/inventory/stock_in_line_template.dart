import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../kit/kit.dart';
import 'inventory_controller.dart';
import '../../resources/merchant_svgs.dart';
import '../../widgets/app_icon.dart';

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

  /// 单价：带笔形图标的灰色块，点击弹出「修改单价」；没有默认价显示「请输入」，单价为 0 标「赠品」。
  Widget _priceChip(BuildContext context, Color muted, Color ink) {
    final has = line['cost'] is num;
    return Semantics(
      button: true,
      label: '修改单价',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: c.busy ? null : () => c.editLine(context, line, 'cost'),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: dk(
              context,
              const Color(0xFFF4F4F5),
              const Color(0xFF27272A),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('单价', style: hts(12, muted, lh: 16)),
              const SizedBox(width: 6),
              Text(
                c.lineCostText(line),
                style: has
                    ? hts(14, ink, w: FontWeight.w600, lh: 20, tab: true)
                    : hts(
                        14,
                        dk(
                          context,
                          const Color(0xFFA1A1AA),
                          const Color(0xFF71717A),
                        ),
                        lh: 20,
                      ),
              ),
              if (has) ...[
                const SizedBox(width: 6),
                Text('/ ${c.lineUnit(line)}', style: hts(12, muted, lh: 16)),
              ],
              if (c.lineIsGift(line)) ...[
                const SizedBox(width: 6),
                Text(
                  '赠品',
                  style: hts(
                    11,
                    const Color(0xFF855F2E),
                    w: FontWeight.w600,
                    lh: 16,
                  ),
                ),
              ],
              const SizedBox(width: 6),
              AppIcon('pencil', size: 14, color: muted),
            ],
          ),
        ),
      ),
    );
  }

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
              child: Align(
                alignment: Alignment.centerLeft,
                // 金额很大或字体放大时整体缩小，不溢出。
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _priceChip(context, muted, ink),
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
                    child: StockQtyField(c: c, line: line),
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

/// 入库数量：数字做成输入框，点击直接输入，加减按钮保留。
/// 数量大于 0、最大 9999；不允许小数的商品只能输入整数。
class StockQtyField extends StatefulWidget {
  final InventoryController c;
  final Map<String, dynamic> line;
  const StockQtyField({super.key, required this.c, required this.line});

  @override
  State<StockQtyField> createState() => _StockQtyFieldState();
}

class _StockQtyFieldState extends State<StockQtyField> {
  late final _ctrl = TextEditingController(text: _text());

  String _text() {
    final q = widget.line['quantity'];
    return q is num && q > 0 ? qty(q) : '';
  }

  bool get _decimal => widget.c.product(widget.line)['allow_decimal'] != false;

  @override
  void didUpdateWidget(StockQtyField old) {
    super.didUpdateWidget(old);
    // 加减按钮改了数量：同步到输入框；用户正在输入的内容不覆盖。
    final typed = num.tryParse(_ctrl.text);
    final q = widget.line['quantity'];
    if (q is num && q != typed) {
      _ctrl.text = _text();
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _changed(String v) {
    var n = num.tryParse(v);
    if (n != null && n > 9999) {
      n = 9999;
      _ctrl.text = '9999';
      _ctrl.selection = const TextSelection.collapsed(offset: 4);
    }
    widget.line['quantity'] = n;
    widget.c.changed();
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 48, maxWidth: 88),
    width: 64,
    height: 32,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: dk(context, const Color(0xFFD4D4D8), const Color(0xFF3F3F46)),
      ),
    ),
    alignment: Alignment.center,
    child: TextField(
      controller: _ctrl,
      enabled: !widget.c.busy,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.numberWithOptions(decimal: _decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          _decimal ? RegExp(r'^\d*\.?\d{0,3}') : RegExp(r'^\d*'),
        ),
        LengthLimitingTextInputFormatter(8),
      ],
      onChanged: _changed,
      style: hts(
        16,
        dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
        w: FontWeight.w600,
        lh: 22,
        tab: true,
      ),
      decoration: const InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: '0',
      ),
    ),
  );
}
