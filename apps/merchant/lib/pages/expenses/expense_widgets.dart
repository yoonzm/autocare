import 'voucher_gallery.dart';

import 'package:flutter/material.dart';

import 'expense_controller.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

/// Only renders the supplied value and forwards input; no screen/field/index lookup.
class ExpenseInput extends StatefulWidget {
  final String value, hint;
  final ValueChanged<String> onChanged;
  final TextStyle style;

  /// 占位文字样式；不传时沿用输入样式（备注框）。金额框用它避免占位文字和输入同样粗大。
  final TextStyle? hintStyle;
  final TextInputType? keyboard;
  final int? maxLines;
  final TextAlign align;
  const ExpenseInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.style,
    required this.hint,
    this.hintStyle,
    this.keyboard,
    this.maxLines = 1,
    this.align = TextAlign.start,
  });
  @override
  State<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends State<ExpenseInput> {
  late final ctrl = TextEditingController(text: widget.value);
  bool _edited = false;
  @override
  void didUpdateWidget(covariant ExpenseInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A keystroke can be an incomplete decimal ("20."). Preserve its lexical input;
    // changes coming from a suggestion or reload replace the display explicitly.
    if (!_edited &&
        widget.value != oldWidget.value &&
        widget.value != ctrl.text) {
      ctrl.text = widget.value;
    }
    _edited = false;
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    style: widget.style,
    textAlign: widget.align,
    keyboardType: widget.keyboard,
    maxLines: widget.maxLines,
    decoration: InputDecoration(
      hintText: widget.hint,
      hintStyle: widget.hintStyle,
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
    ),
    onChanged: (value) {
      _edited = true;
      widget.onChanged(value);
    },
  );
}

class ExpenseAttachment extends StatelessWidget {
  final ExpenseController c;
  const ExpenseAttachment({super.key, required this.c});
  @override
  Widget build(BuildContext context) => VoucherGallery(
    helper: '发票、收据、转账截图',
    paths: List<String>.from(c.draft['attachments'] ?? []),
    request: c.request,
    enabled: !c.busy,
    onBusyChanged: c.setBusy,
    onChanged: (paths) {
      if (c.disposed) return;
      c.draft['attachments'] = paths;
      c.changed();
    },
  );
}

/// 分类图标：与「记一笔」分类宫格同一套；未收录的分类（如「损耗」）沿用「其他」。
String expenseCategorySvg(BuildContext context, String? category) {
  final (light, dark) = switch (category) {
    '房租' => (Svgs.s109, Svgs.s110),
    '水电' => (Svgs.s111, Svgs.s112),
    '人工' => (Svgs.s113, Svgs.s114),
    '材料采购' => (Svgs.s115, Svgs.s116),
    '设备维修' => (Svgs.s117, Svgs.s118),
    '营销推广' => (Svgs.s119, Svgs.s120),
    '税费' => (Svgs.s121, Svgs.s122),
    _ => (Svgs.s123, Svgs.s124),
  };
  return dk(context, light, dark);
}
