import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 深色概览卡：深底白字、圆角 28，右上角有同心圆装饰。每页最多一张；
/// 深色模式下改为 surface 色加描边（由令牌决定）。
class AppHeroCard extends StatelessWidget {
  final String title;
  final String value;
  final String? footnote;
  final Widget? trailing;
  const AppHeroCard({
    super.key,
    required this.title,
    required this.value,
    this.footnote,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.hero),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: t.heroBg,
          borderRadius: BorderRadius.circular(AppRadius.hero),
          border: Border.all(color: t.heroBorder),
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: t.small.copyWith(
                            color: t.heroInkSub,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s4),
                        Text(
                          value,
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
