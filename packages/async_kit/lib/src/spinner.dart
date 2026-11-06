import 'package:flutter/material.dart';

/// 转圈指示，样式与设计稿一致：淡色圆环 + 一段 1/4 圆弧，0.8s 一圈。
/// 系统开启“减少动态效果”时不转动。
class AppSpinner extends StatefulWidget {
  final double size;
  final Color color;
  const AppSpinner({super.key, this.size = 18, required this.color});
  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  bool _spinning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still) {
      _c.stop();
      _spinning = false;
    } else if (!_spinning) {
      _c.repeat();
      _spinning = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: RotationTransition(
      turns: _c,
      child: CustomPaint(painter: _SpinnerPainter(widget.color)),
    ),
  );
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  const _SpinnerPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24; // 设计稿的图标是 24 的坐标系
    final stroke = 3 * unit;
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: 9 * unit,
    );
    canvas.drawArc(
      rect,
      0,
      2 * 3.141592653589793,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.3),
    );
    canvas.drawArc(
      rect,
      -3.141592653589793 / 2,
      3.141592653589793 / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.color != color;
}
