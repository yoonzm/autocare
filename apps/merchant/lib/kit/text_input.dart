import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'keyboard.dart';
import '../theme.dart' show C;

/// 普通受控输入框，只负责输入与视觉，不推断路由、字段或业务草稿。
class AppTextInput extends StatelessWidget {
  final TextStyle style;
  final String hint;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool obscure;
  final int? maxLines;
  final TextAlign align;
  final TextInputType? keyboard;
  final Color hintColor;
  final List<TextInputFormatter>? inputFormatters;

  const AppTextInput({
    super.key,
    required this.style,
    required this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.obscure = false,
    this.maxLines = 1,
    this.align = TextAlign.start,
    this.keyboard,
    this.hintColor = const Color(0xFF71717A),
    this.inputFormatters,
  }) : assert(controller == null || initialValue == null);

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: initialValue,
    onChanged: onChanged,
    onTapOutside: onTapOutsideDismiss,
    readOnly: readOnly,
    onTap: onTap,
    textInputAction: obscure || maxLines == 1
        ? TextInputAction.done
        : TextInputAction.newline,
    style: style,
    textAlign: align,
    keyboardType: keyboard,
    inputFormatters: inputFormatters,
    obscureText: obscure,
    maxLines: obscure ? 1 : maxLines,
    minLines: 1,
    decoration: InputDecoration(
      isCollapsed: true,
      border: InputBorder.none,
      hintText: hint,
      hintStyle: style.copyWith(
        color:
            hintColor == const Color(0xFF71717A) &&
                Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF9A9AA3)
            : hintColor,
      ),
    ),
  );
}

/// 密码可见性由页面持有，通过回调切换，不查找相邻输入框。
class PasswordVisibilityButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;
  final Widget hiddenIcon;
  const PasswordVisibilityButton({
    super.key,
    required this.visible,
    required this.onPressed,
    required this.hiddenIcon,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: visible ? '隐藏密码' : '显示密码',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: visible
          ? SizedBox(
              width: 32,
              height: 32,
              child: Center(
                child: Icon(
                  Icons.visibility_outlined,
                  size: 20,
                  color: C.muted,
                ),
              ),
            )
          : hiddenIcon,
    ),
  );
}

/// 金额输入：只保留数字和一个小数点（最多 2 位小数），整数部分按千分位加逗号，如 `1,580.5`。
class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  /// 把数值格式化成输入框里的文字（无多余的 .0）。
  static String format(num v) => _group(
    v == v.roundToDouble()
        ? v.toInt().toString()
        : v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), ''),
  );

  static String _group(String raw) {
    final parts = raw.split('.');
    final digits = parts.first;
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return parts.length > 1 ? '$out.${parts[1]}' : '$out';
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue value,
  ) {
    var raw = value.text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    final dot = raw.indexOf('.');
    if (dot >= 0) {
      final decimals = raw.substring(dot + 1).replaceAll('.', '');
      raw =
          '${raw.substring(0, dot)}.${decimals.length > 2 ? decimals.substring(0, 2) : decimals}';
    }
    if (raw.startsWith('.')) raw = '0$raw';
    final intPart = raw.split('.').first.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    final text = _group(dot >= 0 ? '$intPart.${raw.split('.').last}' : intPart);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
