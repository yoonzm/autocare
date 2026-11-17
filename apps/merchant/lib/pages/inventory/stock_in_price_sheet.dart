import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppButton, AppButtonSize;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../kit/text_input.dart' show MoneyInputFormatter;
import '../../kit/kit.dart' show dk;
import '../../theme.dart';
import 'inventory_controller.dart' show qty;

/// 带千分位的金额：¥2,380.00。
String moneyGrouped(num n) {
  final fixed = n.toStringAsFixed(2).split('.');
  final grouped = fixed[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '¥$grouped.${fixed[1]}';
}

/// 入库「修改单价」底部弹层（设计稿 StockInPrice / StockInPriceZero）。
///
/// - 数字键盘直接输入，两位小数；留空时「确定」不可点。
/// - 快捷项：上次进价（最近一次入库批次单价）、商品成本价（现存批次加权平均），有值才显示。
/// - 实时显示「数量 × 单价 = 小计」。
/// - 单价为 0：输入框描边变橙色，提示按赠品入库、成本记为 0，按钮文案改为「确定，按赠品入库」。
/// 返回确认后的单价；关闭返回 null。
Future<num?> showStockInPriceSheet(
  BuildContext context, {
  required String productName,
  required String unit,
  required num quantity,
  required num? current,
  num? lastCost,
  num? productCost,
}) => showModalBottomSheet<num>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: C.card,
  barrierColor: Colors.black.withValues(alpha: .5),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  ),
  builder: (ctx) => _PriceSheet(
    productName: productName,
    unit: unit,
    quantity: quantity,
    current: current,
    lastCost: lastCost,
    productCost: productCost,
  ),
);

class _PriceSheet extends StatefulWidget {
  final String productName, unit;
  final num quantity;
  final num? current, lastCost, productCost;
  const _PriceSheet({
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.current,
    required this.lastCost,
    required this.productCost,
  });

  @override
  State<_PriceSheet> createState() => _PriceSheetState();
}

class _PriceSheetState extends State<_PriceSheet> {
  late final _ctrl = TextEditingController(
    text: widget.current == null ? '' : widget.current!.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  num? get _value {
    final text = _ctrl.text.replaceAll(',', '').trim();
    return text.isEmpty ? null : num.tryParse(text);
  }

  void _fill(num v) => setState(() {
    _ctrl.text = v.toStringAsFixed(2);
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
  });

  Widget _chip(String label, num value) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => _fill(value),
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: C.chip,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Text(
        '$label ${moneyGrouped(value)}',
        style: ts(
          13,
          w: FontWeight.w500,
          color: dk(context, const Color(0xFF3F3F46), const Color(0xFFD4D4D8)),
          h: 18,
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final value = _value;
    final gift = value != null && value == 0;
    final chips = [
      if (widget.lastCost != null) _chip('上次进价', widget.lastCost!),
      if (widget.productCost != null && widget.productCost! > 0)
        _chip('商品成本价', widget.productCost!),
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: C.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text('修改单价', style: ts(20, w: FontWeight.w600, h: 28)),
              Text(
                '${widget.productName} · 本次入库 ${qty(widget.quantity)} ${widget.unit}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts(13, color: C.muted, h: 18),
              ),
              const SizedBox(height: 14),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: C.chip,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: gift ? const Color(0xFFF5A524) : C.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '¥',
                      style: ts(20, w: FontWeight.w600, color: C.sub, h: 28),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          const MoneyInputFormatter(),
                          LengthLimitingTextInputFormatter(12),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: ts(24, w: FontWeight.w600, h: 32, tabular: true),
                        cursorColor: C.primary,
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: ts(
                            24,
                            w: FontWeight.w600,
                            color: C.faint,
                            h: 32,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      '/ ${widget.unit}',
                      style: ts(14, color: C.muted, h: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (gift)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEFD6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '!',
                        style: ts(
                          13,
                          w: FontWeight.w700,
                          color: const Color(0xFF855F2E),
                          h: 19,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '单价为 0，将按赠品入库，这批货的成本记为 0。如果是漏填，请输入实际进价。',
                          style: ts(13, color: const Color(0xFF855F2E), h: 19),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                if (chips.isNotEmpty)
                  Wrap(spacing: 8, runSpacing: 8, children: chips),
                if (chips.isNotEmpty) const SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    text:
                        '${qty(widget.quantity)} ${widget.unit} × ${value == null ? '¥—' : moneyGrouped(value)} = ',
                    children: [
                      TextSpan(
                        text: value == null
                            ? '—'
                            : moneyGrouped(value * widget.quantity),
                        style: ts(13, w: FontWeight.w700, h: 18),
                      ),
                    ],
                  ),
                  style: ts(13, color: C.sub, h: 18),
                ),
              ],
              const SizedBox(height: 14),
              AppButton(
                label: gift ? '确定，按赠品入库' : '确定',
                size: AppButtonSize.large,
                expanded: true,
                onPressed: value == null
                    ? null
                    : () => Navigator.of(context).pop(value),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
