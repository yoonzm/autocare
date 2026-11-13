import 'buttons.dart';

import 'package:flutter/material.dart';

import 'keyboard.dart';

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
  const PasswordVisibilityButton({
    super.key,
    required this.visible,
    required this.onPressed,
  });
  @override
  Widget build(BuildContext context) => AppIconButton(
    icon: visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
    semanticLabel: visible ? '隐藏密码' : '显示密码',
    onPressed: onPressed,
  );
}
