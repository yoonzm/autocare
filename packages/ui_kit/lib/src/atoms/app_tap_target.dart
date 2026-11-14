import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 点击热区：视觉小于 44 × 44 时外扩点击区，并带语义与按下状态。组件内部使用。
class AppTapTarget extends StatefulWidget {
  final Widget Function(BuildContext context, bool pressed) builder;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final String? semanticLabel;
  final bool button;
  final bool? selected;
  final bool? toggled;
  final double minWidth;
  final double minHeight;
  const AppTapTarget({
    super.key,
    required this.builder,
    this.onTap,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.semanticLabel,
    this.button = true,
    this.selected,
    this.toggled,
    this.minWidth = AppSpacing.minTap,
    this.minHeight = AppSpacing.minTap,
  });

  @override
  State<AppTapTarget> createState() => _AppTapTargetState();
}

class _AppTapTargetState extends State<AppTapTarget> {
  bool pressed = false;

  void _set(bool value) {
    if (pressed != value && mounted) setState(() => pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: widget.button,
      enabled: enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      excludeSemantics: widget.semanticLabel != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        onLongPressStart: widget.onLongPressStart == null
            ? null
            : (_) => widget.onLongPressStart!(),
        onLongPressEnd: widget.onLongPressEnd == null
            ? null
            : (_) => widget.onLongPressEnd!(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: widget.minWidth,
            minHeight: widget.minHeight,
          ),
          child: Center(
            widthFactor: 1,
            heightFactor: 1,
            child: widget.builder(context, pressed),
          ),
        ),
      ),
    );
  }
}
