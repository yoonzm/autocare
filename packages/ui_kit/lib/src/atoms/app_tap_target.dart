import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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

  /// true：点击区只向外扩展、不撑大布局（视觉 34 高的标签仍按 34 排版，热区仍有 44）。
  final bool hitSlopOnly;
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
    this.hitSlopOnly = false,
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
    final inner = Center(
      widthFactor: 1,
      heightFactor: 1,
      child: widget.builder(context, pressed),
    );
    final gesture = GestureDetector(
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
      child: widget.hitSlopOnly
          ? inner
          : ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: widget.minWidth,
                minHeight: widget.minHeight,
              ),
              child: inner,
            ),
    );
    final semantic = Semantics(
      button: widget.button,
      enabled: enabled,
      selected: widget.selected,
      toggled: widget.toggled,
      label: widget.semanticLabel,
      onTap: widget.onTap,
      excludeSemantics: widget.semanticLabel != null,
      child: gesture,
    );
    // 命中扩展必须在最外层：中间任何一层的普通盒子都会先按自己的尺寸拒绝范围外的点击。
    return widget.hitSlopOnly
        ? _HitSlop(
            minSize: Size(widget.minWidth, widget.minHeight),
            child: semantic,
          )
        : semantic;
  }
}

/// 只外扩点击区、不改变布局尺寸：子组件小于 [minSize] 时，四周按差值的一半外扩命中范围。
class _HitSlop extends SingleChildRenderObjectWidget {
  final Size minSize;
  const _HitSlop({required this.minSize, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHitSlop(minSize);

  @override
  void updateRenderObject(BuildContext context, _RenderHitSlop renderObject) =>
      renderObject.minSize = minSize;
}

class _RenderHitSlop extends RenderProxyBox {
  _RenderHitSlop(this._minSize);
  Size _minSize;
  set minSize(Size value) {
    if (value != _minSize) _minSize = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final dx = ((_minSize.width - size.width) / 2).clamp(0.0, double.infinity);
    final dy = ((_minSize.height - size.height) / 2).clamp(
      0.0,
      double.infinity,
    );
    final area = Rect.fromLTRB(-dx, -dy, size.width + dx, size.height + dy);
    if (!area.contains(position)) return false;
    // 命中扩展区时把位置收回到子组件范围内，让子组件的手势识别照常响应。
    final inside = Offset(
      position.dx.clamp(0.0, size.width - 0.01),
      position.dy.clamp(0.0, size.height - 0.01),
    );
    return super.hitTest(result, position: inside);
  }
}
