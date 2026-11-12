import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import 'app_badge.dart';
import 'app_tap_target.dart';

enum AppIconButtonSize { regular, small }

/// 圆形图标按钮：页面头部的返回、关闭、右上角入口。白底 + 卡片阴影，44 × 44。
/// 带文字的入口用 [AppIconButton.pill]（高度同样 44）。
class AppIconButton extends StatelessWidget {
  final IconData? icon;
  final String? label;
  final int? badge;
  final String semanticLabel;
  final AppIconButtonSize size;
  final VoidCallback? onPressed;

  const AppIconButton({
    super.key,
    required IconData this.icon,
    required this.semanticLabel,
    this.size = AppIconButtonSize.regular,
    this.onPressed,
  }) : label = null,
       badge = null;

  /// 胶囊入口，如「挂单 4」。
  const AppIconButton.pill({
    super.key,
    required String this.label,
    this.badge,
    this.icon,
    this.onPressed,
  }) : semanticLabel = label,
       size = AppIconButtonSize.regular;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final small = size == AppIconButtonSize.small;
    final enabled = onPressed != null;
    return AppTapTarget(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      builder: (context, pressed) {
        final fg = enabled ? t.ink : t.inkFaint;
        Widget content;
        if (label != null) {
          content = Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                pressed ? t.pressedOverlay : Colors.transparent,
                t.surface,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: t.cardShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: fg),
                  const SizedBox(width: AppSpacing.s6),
                ],
                Text(label!, style: t.base.copyWith(color: fg)),
                if (badge != null) ...[
                  const SizedBox(width: AppSpacing.s6),
                  AppBadge(count: badge!),
                ],
              ],
            ),
          );
        } else {
          final d = small ? 32.0 : 44.0;
          content = Container(
            width: d,
            height: d,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.alphaBlend(
                pressed ? t.pressedOverlay : Colors.transparent,
                small ? t.inset : t.surface,
              ),
              boxShadow: small ? null : t.cardShadow,
              border: small ? Border.all(color: t.fillStrong) : null,
            ),
            child: Icon(icon, size: small ? 16 : 20, color: small ? t.inkSub : fg),
          );
        }
        return content;
      },
    );
  }
}
