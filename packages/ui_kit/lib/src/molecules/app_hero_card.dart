import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 概览卡样式：flat 深底（深色模式改为 surface 加描边）· gradient 品牌渐变加金色光晕（后台概览、账号详情顶部）。
enum AppHeroStyle { flat, gradient }

/// 深色概览卡：深底白字、圆角 28，右上角有同心圆装饰。每页最多一张；
/// 深色模式下改为 surface 色加描边（由令牌决定）。
/// 标题 + 数值 + 备注用默认构造；需要放头像、状态等任意内容时用 [AppHeroCard.custom]。
class AppHeroCard extends StatelessWidget {
  final String? title;
  final String? value;
  final String? footnote;
  final Widget? trailing;
  final Widget? child;
  final AppHeroStyle style;
  final EdgeInsets padding;
  const AppHeroCard({
    super.key,
    required String this.title,
    required String this.value,
    this.footnote,
    this.trailing,
    this.style = AppHeroStyle.flat,
  }) : child = null,
       padding = const EdgeInsets.all(20);

  /// 自定义内容（白字在深底上）。
  const AppHeroCard.custom({
    super.key,
    required Widget this.child,
    this.style = AppHeroStyle.gradient,
    this.padding = const EdgeInsets.all(20),
  }) : title = null,
       value = null,
       footnote = null,
       trailing = null;

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final gradient = style == AppHeroStyle.gradient;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.hero),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: gradient ? null : t.heroBg,
          gradient: gradient
              ? LinearGradient(
                  begin: const Alignment(-.6, -1),
                  end: const Alignment(.8, 1),
                  colors: t.heroGradient,
                  stops: const [0, .55, 1],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadius.hero),
          border: gradient ? null : Border.all(color: t.heroBorder),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -100,
              top: -100,
              child: CustomPaint(
                size: const Size(260, 260),
                painter: _RingsPainter(t.heroRing),
              ),
            ),
            if (gradient)
              Positioned(
                right: -60,
                top: -80,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [t.heroGlow, t.heroGlow.withValues(alpha: 0)],
                      stops: const [0, .68],
                    ),
                  ),
                ),
              ),
            Padding(
              padding: padding,
              child: child ?? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          style: t.small.copyWith(
                            color: t.heroInkSub,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          value!,
                          style: t.display.copyWith(
                            color: t.heroInk,
                            fontFeatures: AppTokens.tabular,
                          ),
                        ),
                        if (footnote != null) ...[
                          const SizedBox(height: AppSpacing.s4),
                          Text(
                            footnote!,
                            style: t.caption.copyWith(color: t.heroInkSub),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  final Color color;
  const _RingsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final center = size.center(Offset.zero);
    for (final r in const [60.0, 90.0, 118.0]) {
      canvas.drawCircle(center, r * size.width / 240, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingsPainter old) => old.color != color;
}
