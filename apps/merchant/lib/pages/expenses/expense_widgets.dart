import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../kit/async_kit.dart';
import '../../backend/merchant_api.dart';
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
  final Widget child;
  const ExpenseAttachment({super.key, required this.c, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      c.vouchers(context),
      GestureDetector(
        onTap: () => runBusy(c.uploadKey, () async {
          c.setBusy(true);
          try {
            if ((c.draft['attachments'] as List).length >= 5) {
              throw const AppError('最多上传五张凭证');
            }
            final source = await showModalBottomSheet<ImageSource>(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('拍照'),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    ListTile(
                      title: const Text('从相册选择'),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            );
            if (source == null || !context.mounted || c.disposed) return;
            final f = await ImagePicker().pickImage(
              source: source,
              maxWidth: 1600,
              imageQuality: 85,
            );
            if (f == null || !context.mounted || c.disposed) return;
            final r = await merchantApi.invoke({
              'action': 'expense_upload',
              'data': base64Encode(await f.readAsBytes()),
            }, timeout: const Duration(seconds: 60));
            if (c.disposed) return;
            final a = List<String>.from(c.draft['attachments']);
            if (a.length >= 5) throw const AppError('最多上传五张凭证');
            a.add(r['item']['path']);
            c.draft['attachments'] = a;
            c.changed();
          } catch (e) {
            if (context.mounted) AppToast.error(context, e);
          } finally {
            c.setBusy(false);
          }
        }),
        child: hBusy(c.uploadKey, child, icon: true),
      ),
    ],
  );
}
