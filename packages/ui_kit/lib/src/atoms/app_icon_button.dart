import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import '../states/states.dart' show AppSpinner;
import 'app_badge.dart';
import 'app_tap_target.dart';
import 'button_icon.dart';

enum AppIconButtonSize { regular, small }

/// surface 白底带阴影（默认）· primary 主色实心（页面右上角的「添加」这类入口）。
enum AppIconButtonKind { surface, primary }

/// 圆形图标按钮：页面头部的返回、关闭、右上角入口。白底 + 卡片阴影，44 × 44。
/// 带文字的入口用 [AppIconButton.pill]（高度同样 44）。
class AppIconButton extends StatelessWidget {
  final IconData? icon;

  /// 单色 SVG 源码，与 [icon] 互斥；颜色跟随按钮状态。
  final String? svg;
  final String? darkSvg;
  final bool loading;
  final String? label;
  final int? badge;
  final String semanticLabel;
  final AppIconButtonSize size;
  final AppIconButtonKind kind;
  final VoidCallback? onPressed;

  const AppIconButton({
    super.key,
    this.icon,
    this.svg,
    this.darkSvg,
    this.loading = false,
    required this.semanticLabel,
    this.size = AppIconButtonSize.regular,
    this.kind = AppIconButtonKind.surface,
    this.onPressed,
  }) : assert((icon != null) != (svg != null)),
       assert(darkSvg == null || svg != null),
       label = null,
       badge = null;

  /// 胶囊入口，如「挂单 4」。
  const AppIconButton.pill({
    super.key,
    required String this.label,
    this.badge,
    this.icon,
    this.svg,
    this.darkSvg,
    this.loading = false,
    this.onPressed,
  }) : assert(icon == null || svg == null),
       assert(darkSvg == null || svg != null),
       semanticLabel = label,
       size = AppIconButtonSize.regular,
       kind = AppIconButtonKind.surface;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final small = size == AppIconButtonSize.small;
    final enabled = onPressed != null || loading;
    Widget loadingContent(Widget child, Color color) => !loading
        ? child
        : Stack(
            alignment: Alignment.center,
            children: [
              ExcludeSemantics(child: Opacity(opacity: 0, child: child)),
              Positioned.fill(
                child: Center(
                  child: Semantics(
                    label: '处理中',
                    liveRegion: true,
                    child: OverflowBox(
                      minWidth: 20,
                      maxWidth: 20,
                      minHeight: 20,
                      maxHeight: 20,
                      child: AppSpinner(size: 20, color: color),
                    ),
                  ),
                ),
              ),
            ],
          );
    return AppTapTarget(
      onTap: loading ? null : onPressed,
      semanticLabel: loading ? '$semanticLabel，处理中' : semanticLabel,
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
            child: loadingContent(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null || svg != null) ...[
                    buttonIcon(
                      context,
                      icon: icon,
                      svg: svg,
                      darkSvg: darkSvg,
                      size: 18,
                      color: fg,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                  ],
                  Text(label!, style: t.base.copyWith(color: fg)),
                  if (badge != null) ...[
                    const SizedBox(width: AppSpacing.s6),
                    AppBadge(count: badge!),
                  ],
                ],
              ),
              t.primary,
            ),
          );
        } else {
          final d = small ? 32.0 : 44.0;
          final primary = kind == AppIconButtonKind.primary;
          content = Container(
            width: d,
            height: d,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary
                  ? (pressed ? t.primaryPressed : t.primary)
                  : Color.alphaBlend(
                      pressed ? t.pressedOverlay : Colors.transparent,
                      small ? t.inset : t.surface,
                    ),
              boxShadow: small || primary ? null : t.cardShadow,
              border: small && !primary
                  ? Border.all(color: t.fillStrong)
                  : null,
            ),
            child: loadingContent(
              buttonIcon(
                context,
                icon: icon,
                svg: svg,
                darkSvg: darkSvg,
                size: small ? 16 : 20,
                color: primary ? t.onPrimary : (small ? t.inkSub : fg),
              ),
              primary ? t.onPrimary : t.primary,
            ),
          );
        }
        return content;
      },
    );
  }
}
