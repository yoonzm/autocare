import 'package:flutter/material.dart';

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

enum AppBannerKind { info, warn, err }

/// 提示横幅：圆角 14、内边距 10 × 14、13/18 · 500，左侧一个 16 图标；info / warn / err 三种，
/// 浅底 + 深字，与状态色一致。出现在页面内容顶部或表单上方，不盖住内容，也不自动消失。
class AppBanner extends StatelessWidget {
  final String message;
  final AppBannerKind kind;
  final VoidCallback? onTap;
  const AppBanner(
    this.message, {
    super.key,
    this.kind = AppBannerKind.info,
    this.onTap,
  });

  const AppBanner.info(String message, {Key? key, VoidCallback? onTap})
    : this(message, key: key, kind: AppBannerKind.info, onTap: onTap);
  const AppBanner.warn(String message, {Key? key, VoidCallback? onTap})
    : this(message, key: key, kind: AppBannerKind.warn, onTap: onTap);
  const AppBanner.err(String message, {Key? key, VoidCallback? onTap})
    : this(message, key: key, kind: AppBannerKind.err, onTap: onTap);

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final c = switch (kind) {
      AppBannerKind.info => t.wait,
      AppBannerKind.warn => t.warn,
      AppBannerKind.err => t.danger,
    };
    Widget box(bool pressed) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          pressed ? t.pressedOverlay : Colors.transparent,
          c.bg,
        ),
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline_rounded, size: 16, color: c.fg),
          ),
          const SizedBox(width: AppSpacing.s8),
          Expanded(child: Text(message, style: t.small.copyWith(color: c.fg))),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, size: 18, color: c.fg),
        ],
      ),
    );
    if (onTap == null) return box(false);
    return AppTapTarget(
      onTap: onTap,
      minWidth: 0,
      minHeight: 0,
      builder: (context, pressed) => box(pressed),
    );
  }
}
