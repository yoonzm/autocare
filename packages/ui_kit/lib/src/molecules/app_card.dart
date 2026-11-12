import 'package:flutter/material.dart';

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

/// 卡片：白底、圆角 24、内边距 16、卡片阴影（深色下为细描边）；页面背景上的卡片不加描边。
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    Widget box(bool pressed) => Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          pressed ? t.pressedOverlay : Colors.transparent,
          t.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: t.cardShadow,
      ),
      child: child,
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

/// 分组标题：13/18 · 500，灰字，放在卡片上方、左缩进 4。
class AppSectionTitle extends StatelessWidget {
  final String text;
  const AppSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s4),
      child: Text(text, style: t.small.copyWith(color: t.inkSub)),
    );
  }
}

/// 行与行之间 1px 分割线，左缩进 [indent]，最后一行不画。
class AppDividedColumn extends StatelessWidget {
  final List<Widget> children;
  final double indent;
  const AppDividedColumn({
    super.key,
    required this.children,
    this.indent = AppSpacing.s16,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0)
            Container(
              height: 1,
              margin: EdgeInsets.only(left: indent),
              color: t.line,
            ),
          children[i],
        ],
      ],
    );
  }
}
