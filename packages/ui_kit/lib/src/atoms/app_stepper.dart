import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/app_tokens.dart';
import 'app_tap_target.dart';

/// 标准（灰底，表单、入库数量、套餐次数）· 行内（白减蓝加，选择服务弹层）。
enum AppStepperStyle { standard, inline }

/// 数量加减：32 圆的减、加按钮，中间是数字（15/22 · 600，等宽数字）。
/// 内置逻辑：上下限钳制、到下限减号置灰、到上限加号置灰、按住连续增减、点数字直接输入。
class AppStepper extends StatefulWidget {
  final num value;
  final num min;
  final num max;
  final num step;
  final bool allowDecimal;
  final AppStepperStyle style;
  final ValueChanged<num> onChanged;
  const AppStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
    this.allowDecimal = false,
    this.style = AppStepperStyle.standard,
  });

  @override
  State<AppStepper> createState() => _AppStepperState();
}

class _AppStepperState extends State<AppStepper> {
  Timer? _repeat;
  bool _editing = false;
  late final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (!_focus.hasFocus && _editing) _commit();
    });
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  num _clamp(num v) => v < widget.min
      ? widget.min
      : v > widget.max
      ? widget.max
      : v;

  String _format(num v) {
    if (!widget.allowDecimal || v == v.roundToDouble()) {
      return v.round().toString();
    }
    return v.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  }

  void _change(int direction) {
    final next = _clamp(
      widget.allowDecimal
          ? double.parse((widget.value + direction * widget.step).toStringAsFixed(2))
          : widget.value + direction * widget.step,
    );
    if (next != widget.value) widget.onChanged(next);
  }

  void _startRepeat(int direction) {
    _repeat?.cancel();
    _repeat = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _change(direction);
    });
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  void _commit() {
    final parsed = num.tryParse(_controller.text.trim());
    setState(() => _editing = false);
    if (parsed != null) {
      final next = _clamp(widget.allowDecimal ? parsed : parsed.round());
      if (next != widget.value) widget.onChanged(next);
    }
  }

  Widget _button(
    AppTokens t, {
    required IconData icon,
    required bool enabled,
    required bool plus,
    required String label,
  }) {
    final inline = widget.style == AppStepperStyle.inline;
    final direction = plus ? 1 : -1;
    return AppTapTarget(
      semanticLabel: label,
      // 热区高度外扩到 44；宽度只外扩到 38，避免把一排控件撑得过宽。
      minWidth: 38,
      onTap: enabled ? () => _change(direction) : null,
      onLongPressStart: enabled ? () => _startRepeat(direction) : null,
      onLongPressEnd: _stopRepeat,
      builder: (context, pressed) {
        Color bg;
        Color fg;
        List<BoxShadow>? shadow;
        if (inline && plus) {
          bg = t.primary;
          fg = t.onPrimary;
        } else if (inline) {
          bg = t.surface;
          fg = t.ink;
          shadow = t.cardShadow;
        } else {
          bg = t.inset;
          fg = t.ink;
        }
        if (!enabled) {
          fg = t.inkFaint;
          if (inline && plus) bg = t.fillStrong;
        }
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.alphaBlend(
              pressed && enabled ? t.pressedOverlay : Colors.transparent,
              bg,
            ),
            boxShadow: enabled ? shadow : null,
          ),
          child: Icon(icon, size: 16, color: fg),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final inline = widget.style == AppStepperStyle.inline;
    final minWidth = inline ? 14.0 : 36.0;
    final text = _format(widget.value);
    final number = _editing
        ? SizedBox(
            width: 56,
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.allowDecimal,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(widget.allowDecimal ? r'[0-9.]' : r'[0-9]'),
                ),
              ],
              onSubmitted: (_) => _commit(),
              style: t.body.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: AppTokens.tabular,
              ),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
              ),
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _controller.text = text;
              _controller.selection = TextSelection(
                baseOffset: 0,
                extentOffset: text.length,
              );
              setState(() => _editing = true);
            },
            child: Container(
              constraints: BoxConstraints(minWidth: minWidth, minHeight: 32),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
              child: Text(
                text,
                style: t.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: AppTokens.tabular,
                ),
              ),
            ),
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(
          t,
          icon: Icons.remove_rounded,
          enabled: widget.value > widget.min,
          plus: false,
          label: '减少',
        ),
        number,
        _button(
          t,
          icon: Icons.add_rounded,
          enabled: widget.value < widget.max,
          plus: true,
          label: '增加',
        ),
      ],
    );
  }
}
