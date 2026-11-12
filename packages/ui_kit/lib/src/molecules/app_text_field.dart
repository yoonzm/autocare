import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_tokens.dart';
import 'app_input_format.dart';

/// 输入框（标签在上）：13/18 · 500 的标签，下方灰底块（圆角 14，最小高 48）。
/// 用于登录、改密这类一项一块的表单；成排的设置类表单用 [AppFormRow]。
///
/// - [hint] 必填：没有值时一定有占位文字。
/// - 必填标签后加红星；错误时灰底块加红描边，下方显示 12px 红字。
/// - [obscure] 时右侧带显示 / 隐藏密码按钮（内置逻辑）。
class AppTextField extends StatefulWidget {
  final String label;
  final String hint;
  final bool required;
  final TextEditingController? controller;
  final AppInputFormat format;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  final String? prefix;
  final Widget? suffix;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool obscure;
  final bool enabled;
  final int maxLines;
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.required = false,
    this.controller,
    this.format = AppInputFormat.none,
    this.keyboard,
    this.formatters,
    this.prefix,
    this.suffix,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.obscure = false,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final error = widget.errorText;
    final hasError = error != null && error.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.label,
            children: [
              if (widget.required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: t.requiredStar),
                ),
            ],
          ),
          style: t.small,
        ),
        const SizedBox(height: AppSpacing.s6),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
          decoration: BoxDecoration(
            color: t.inset,
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: hasError ? Border.all(color: t.badge, width: 1.2) : null,
          ),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s4),
                  child: Text(
                    widget.prefix!,
                    style: t.body.copyWith(color: t.inkMute, fontWeight: FontWeight.w400),
                  ),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  enabled: widget.enabled,
                  obscureText: widget.obscure && !_show,
                  keyboardType: widget.keyboard ?? widget.format.keyboard,
                  inputFormatters: [
                    ...widget.format.formatters,
                    ...?widget.formatters,
                  ],
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLines: widget.obscure ? 1 : widget.maxLines,
                  minLines: 1,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  style: t.body.copyWith(fontWeight: FontWeight.w400),
                  cursorColor: t.primary,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: t.body.copyWith(
                      color: t.inkFaint,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              if (widget.obscure)
                IconButton(
                  onPressed: () => setState(() => _show = !_show),
                  tooltip: _show ? '隐藏密码' : '显示密码',
                  icon: Icon(
                    _show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: t.inkMute,
                  ),
                ),
              ?widget.suffix,
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.s4, left: 2),
            child: Text(error, style: t.caption.copyWith(color: t.requiredStar)),
          ),
      ],
    );
  }
}
