import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import 'app_tap_target.dart';

/// 语义类型：primary 主要 / secondary 次要（底栏、取消）/ surface 白底带阴影（筛选，补充约定）/
/// danger 危险 / soft 浅蓝底蓝字（卡片内的轻量主操作，如「复制」）/ text 文字按钮。黑色不是按钮色。
enum AppButtonKind { primary, secondary, surface, danger, soft, text }

/// 尺寸档：large 50（底栏）· medium 44（页内）· small 32（卡片内）。
enum AppButtonSize { large, medium, small }

/// 按钮。只开放有限的语义参数，没有 color / radius / height / textStyle。
///
/// 点击后页面应立即把 [loading] 置为 true：文字前加转圈、整体透明度 .72、不可再点，失败后恢复。
/// [onPressed] 为 null 即禁用（禁用用 fillStrong 底 + inkFaint 字，不只降透明度）。
class AppButton extends StatefulWidget {
  final String label;
  final AppButtonKind kind;
  final AppButtonSize size;
  final bool loading;
  final IconData? icon;
  final bool expanded;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  const AppButton({
    super.key,
    required this.label,
    this.kind = AppButtonKind.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.icon,
    this.expanded = false,
    this.onPressed,
    this.semanticLabel,
  });

  const AppButton.danger({
    Key? key,
    required String label,
    AppButtonSize size = AppButtonSize.medium,
    bool loading = false,
    bool expanded = false,
    VoidCallback? onPressed,
  }) : this(
         key: key,
         label: label,
         kind: AppButtonKind.danger,
         size: size,
         loading: loading,
         expanded: expanded,
         onPressed: onPressed,
       );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  Timer? _guard;

  @override
  void dispose() {
    _guard?.cancel();
    super.dispose();
  }

  double get _height => switch (widget.size) {
    AppButtonSize.large => 50,
    AppButtonSize.medium => 44,
    AppButtonSize.small => 32,
  };

  void _tap() {
    // 防重复点击：加载中或极短间隔内的连点不触发。
    if (widget.loading || (_guard?.isActive ?? false)) return;
    _guard = Timer(const Duration(milliseconds: 350), () {});
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final disabled = widget.onPressed == null && !widget.loading;
    final active = widget.onPressed != null && !widget.loading;
    final small = widget.size == AppButtonSize.small;
    return AppTapTarget(
      onTap: active ? _tap : null,
      semanticLabel: widget.semanticLabel ?? widget.label,
      minHeight: AppSpacing.minTap,
      minWidth: 0,
      builder: (context, pressed) {
        Color bg;
        Color fg;
        List<BoxShadow>? shadow;
        switch (widget.kind) {
          case AppButtonKind.primary:
            bg = pressed ? t.primaryPressed : t.primary;
            fg = t.onPrimary;
          case AppButtonKind.secondary:
            bg = t.fill;
            fg = t.ink;
          case AppButtonKind.surface:
            bg = t.surface;
            fg = t.ink;
            shadow = t.cardShadow;
          case AppButtonKind.danger:
            bg = t.danger.bg;
            fg = t.danger.fg;
          case AppButtonKind.soft:
            bg = t.primarySoft;
            fg = t.primaryText;
          case AppButtonKind.text:
            bg = Colors.transparent;
            fg = t.primaryText;
        }
        if (pressed && widget.kind != AppButtonKind.primary) {
          bg = Color.alphaBlend(t.pressedOverlay, bg);
        }
        if (disabled && widget.kind != AppButtonKind.text) {
          bg = t.fillStrong;
          fg = t.inkFaint;
          shadow = null;
        } else if (disabled) {
          fg = t.inkFaint;
        }
        final style = (small ? t.small : t.body).copyWith(
          color: fg,
          fontWeight: widget.kind == AppButtonKind.primary
              ? FontWeight.w600
              : FontWeight.w500,
        );
        final content = Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(fg),
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon, size: small ? 14 : 16, color: fg),
              const SizedBox(width: AppSpacing.s6),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: style,
              ),
            ),
          ],
        );
        return Opacity(
          opacity: widget.loading ? .72 : 1,
          child: Container(
            height: _height,
            width: widget.expanded ? double.infinity : null,
            constraints: BoxConstraints(minWidth: small ? 56 : 88),
            padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(_height / 2),
              boxShadow: shadow,
            ),
            child: content,
          ),
        );
      },
    );
  }
}
