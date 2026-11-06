import 'package:flutter/material.dart';

import 'async_theme.dart';

/// 闪光骨架元素：1.4s 循环；系统开启“减少动态效果”时改为静态灰块。
class AppSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const AppSkeleton({super.key, this.width, this.height = 14, this.radius = 7});

  /// 圆形（头像）
  const AppSkeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size / 2;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (still) {
      _c.stop();
      _started = false;
    } else if (!_started) {
      _c.repeat();
      _started = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AsyncKitTheme.of(context).skeletonBase;
    final glow = AsyncKitTheme.of(context).skeletonGlow;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _started ? _c.value : 0.0;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            color: base,
            gradient: _started
                ? LinearGradient(
                    begin: Alignment(-1.6 + 3.2 * t, 0),
                    end: Alignment(-0.6 + 3.2 * t, 0),
                    colors: [base, glow, base],
                    stops: const [0.25, 0.5, 0.75],
                  )
                : null,
          ),
        );
      },
    );
  }
}
