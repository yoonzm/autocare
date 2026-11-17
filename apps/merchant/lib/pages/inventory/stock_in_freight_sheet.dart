import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppButton, AppButtonSize;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../kit/kit.dart' show HSwitchValue, dk;
import '../../kit/text_input.dart' show MoneyInputFormatter;
import '../../theme.dart';
import 'stock_in_price_sheet.dart' show moneyGrouped;

/// 运费弹层的结果：运费金额，以及是否把运费摊入商品成本。
class FreightResult {
  final num freight;
  final bool toCost;
  const FreightResult(this.freight, this.toCost);
}

/// 入库「运费」底部弹层（设计稿 StockInFreight）。
///
/// - 数字键盘输入，两位小数，默认 ¥0.00，留空按 0；不能为负，最大 99999.99。
/// - 快捷项：「无运费」清零；「上次 ¥120.00」是同一供应商最近一次的运费，没有记录不显示（[loadLast]）。
/// - 「运费计入商品成本」开关默认关闭；打开后运费按商品金额比例摊入各批次成本（服务端提交入库时计算）。
/// - 底部实时显示「商品合计 + 运费 = 应付合计」；点「确定」返回，点遮罩不保存。
Future<FreightResult?> showStockInFreightSheet(
  BuildContext context, {
  required num current,
  required bool toCost,
  required num? goodsTotal,
  required Future<num?> Function() loadLast,
}) => showModalBottomSheet<FreightResult>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: C.card,
  barrierColor: Colors.black.withValues(alpha: .5),
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  ),
  builder: (ctx) => _FreightSheet(
    current: current,
    toCost: toCost,
    goodsTotal: goodsTotal,
    loadLast: loadLast,
  ),
);

class _FreightSheet extends StatefulWidget {
  final num current;
  final bool toCost;
  final num? goodsTotal;
  final Future<num?> Function() loadLast;
  const _FreightSheet({
    required this.current,
    required this.toCost,
    required this.goodsTotal,
    required this.loadLast,
  });

  @override
  State<_FreightSheet> createState() => _FreightSheetState();
}

class _FreightSheetState extends State<_FreightSheet> {
  static const _max = 99999.99;
  late final _ctrl = TextEditingController(
    text: widget.current > 0 ? widget.current.toStringAsFixed(2) : '',
  );
  late bool _toCost = widget.toCost;
  num? _last;

  @override
  void initState() {
    super.initState();
    widget.loadLast().then((v) {
      if (mounted) setState(() => _last = v);
    }, onError: (_) {});
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// 留空按 0 处理。
  num get _value {
    final text = _ctrl.text.replaceAll(',', '').trim();
    return text.isEmpty ? 0 : (num.tryParse(text) ?? 0);
  }

  bool get _blank => _ctrl.text.trim().isEmpty;

  void _fill(num v) => setState(() {
    _ctrl.text = v == 0 ? '0.00' : v.toStringAsFixed(2);
    _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
  });

  void _typed(String _) {
    if (_value > _max) {
      _ctrl.text = _max.toStringAsFixed(2);
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    }
    setState(() {});
  }

  Widget _chip(String label, num value) {
    final on = !_blank && _value == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _fill(value),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? C.primarySoft : C.chip,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: on ? C.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: ts(
            13,
            w: FontWeight.w500,
            color: on
                ? C.primaryInk
                : dk(context, const Color(0xFF3F3F46), const Color(0xFFD4D4D8)),
            h: 18,
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: ts(
            13,
            w: bold ? FontWeight.w600 : FontWeight.w400,
            h: 18,
          ).copyWith(color: bold ? C.ink : C.sub),
        ),
      ),
      Text(
        value,
        style: ts(
          13,
          w: bold ? FontWeight.w600 : FontWeight.w400,
          h: 18,
          tabular: true,
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final goods = widget.goodsTotal;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
              Text('运费', style: ts(20, w: FontWeight.w600, h: 28)),
              Text('本单的运输费用，计入应付合计', style: ts(13, color: C.muted, h: 18)),
              const SizedBox(height: 14),
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: C.chip,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: C.primary, width: 1.5),
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
                          LengthLimitingTextInputFormatter(9),
                        ],
                        onChanged: _typed,
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
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('无运费', 0),
                  if (_last != null)
                    _chip('上次 ${moneyGrouped(_last!)}', _last!),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('运费计入商品成本', style: ts(14, h: 20)),
                        Text(
                          '打开后按商品金额比例摊入各批次成本',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                      ],
                    ),
                  ),
                  HSwitchValue(
                    value: _toCost,
                    onChanged: (_) => setState(() => _toCost = !_toCost),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: C.chip,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _line('商品合计', goods == null ? '—' : moneyGrouped(goods)),
                    const SizedBox(height: 6),
                    _line('运费', moneyGrouped(_value)),
                    const SizedBox(height: 6),
                    _line(
                      '应付合计',
                      goods == null ? '—' : moneyGrouped(goods + _value),
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AppButton(
                label: '确定',
                size: AppButtonSize.large,
                expanded: true,
                onPressed: () =>
                    Navigator.of(context)
                        .pop(FreightResult(_value, _value > 0 && _toCost)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
