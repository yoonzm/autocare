import 'package:flutter/material.dart';

import 'async_theme.dart';
import 'spinner.dart';
import 'timing.dart';
import 'toast.dart';

enum LoadingButtonStyle { primary, secondary, danger }

/// 会发请求的按钮：点击立即进入 loading，期间禁用（防连点），宽高不变；
/// 成功后可短暂显示结果，失败后恢复可点并用 Toast 说明原因，输入内容保留。
class LoadingButton extends StatefulWidget {
  final String label;
  final String? loadingLabel;
  final String? successLabel;
  final Future<void> Function()? onPressed;
  final LoadingButtonStyle style;
  final double height;

  /// 禁用原因（置灰时说明为什么，如“请先填写手机号”）。
  final String? disabledReason;
  const LoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.successLabel,
    this.style = LoadingButtonStyle.primary,
    this.height = 50,
    this.disabledReason,
  });

  @override
  State<LoadingButton> createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _busy = false;
  bool _done = false;

  Future<void> _tap() async {
    if (_busy || widget.onPressed == null) return;
    setState(() {
      _busy = true;
      _done = false;
    });
    var ok = true;
    try {
      // 指示一旦出现至少停留 500ms，避免一闪而过
      await Future.wait([
        widget.onPressed!(),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
    } catch (e) {
      ok = false;
      if (mounted) AppToast.error(context, e);
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _done = ok && widget.successLabel != null;
    });
    if (_done) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _done = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final (bg, fg) = switch (widget.style) {
      LoadingButtonStyle.primary => (
        AsyncKitTheme.of(context).primary,
        Colors.white,
      ),
      LoadingButtonStyle.secondary => (
        AsyncKitTheme.of(context).chip,
        AsyncKitTheme.of(context).ink,
      ),
      LoadingButtonStyle.danger => (
        AsyncKitTheme.of(context).red,
        Colors.white,
      ),
    };
    final text = _busy
        ? (widget.loadingLabel ?? widget.label)
        : (_done ? widget.successLabel! : widget.label);
    return Semantics(
      button: true,
      enabled: !disabled && !_busy,
      label: disabled && widget.disabledReason != null
          ? '${widget.label}，${widget.disabledReason}'
          : text,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled
            ? () {
                if (widget.disabledReason != null) {
                  AppToast.show(context, widget.disabledReason!);
                }
              }
            : _tap,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: disabled ? AsyncKitTheme.of(context).faint : bg,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_busy) ...[
                AppSpinner(size: 18, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: AsyncKitTheme.of(context)
                    .textStyle(16, w: FontWeight.w600, color: fg, h: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
