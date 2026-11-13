import 'voucher_gallery.dart';

import 'package:flutter/material.dart';

import 'expense_controller.dart';

/// Only renders the supplied value and forwards input; no screen/field/index lookup.
class ExpenseInput extends StatefulWidget {
  final String value, hint;
  final ValueChanged<String> onChanged;
  final TextStyle style;
  final TextInputType? keyboard;
  final int? maxLines;
  final TextAlign align;
  const ExpenseInput({
    super.key,
    required this.value,
    required this.onChanged,
    required this.style,
    required this.hint,
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

Future<String?> expenseInput(
  BuildContext context,
  String title,
  String hint,
  String value,
) async {
  final ctrl = TextEditingController(text: value);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  ctrl.dispose();
  return result;
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
