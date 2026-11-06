import 'package:flutter/material.dart';

import 'async_theme.dart';
import 'skeleton.dart';

/// 列表行骨架：头像 + 两行文字 + 右侧一小段。
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: AsyncKitTheme.of(context).card,
      borderRadius: BorderRadius.circular(22),
    ),
    child: const Row(
      children: [
        AppSkeleton.circle(size: 46),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 96, height: 14),
              SizedBox(height: 8),
              AppSkeleton(width: 150, height: 12, radius: 6),
            ],
          ),
        ),
        AppSkeleton(width: 48, height: 14),
      ],
    ),
  );
}

/// 列表骨架：[count] 行，布局与真实列表一致。
class SkeletonList extends StatelessWidget {
  final int count;
  const SkeletonList({super.key, this.count = 5});
  @override
  Widget build(BuildContext context) => Semantics(
    label: '加载中',
    liveRegion: true,
    child: ExcludeSemantics(
      child: Column(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            const SkeletonRow(),
          ],
        ],
      ),
    ),
  );
}

/// 方形图标、两行文字与右侧数值的分组列表骨架。
class SkeletonTileList extends StatelessWidget {
  final int count;
  const SkeletonTileList({super.key, this.count = 5});
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AsyncKitTheme.of(context).card,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const Divider(height: 1, indent: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const AppSkeleton(width: 44, height: 44, radius: 14),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 110, height: 16),
                      SizedBox(height: 8),
                      AppSkeleton(width: 152, height: 12),
                    ],
                  ),
                ),
                const AppSkeleton(width: 42, height: 14),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

/// 看板卡片保留卡片轮廓，也反映卡片内的标题、数值和辅助信息。
class SkeletonDashboardCard extends StatelessWidget {
  final double height;
  final double radius;
  const SkeletonDashboardCard({
    super.key,
    required this.height,
    required this.radius,
  });
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: double.infinity,
    padding: EdgeInsets.all(height > 100 ? 20 : 14),
    decoration: BoxDecoration(
      color: AsyncKitTheme.of(context).card,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: height <= 100
        ? const Row(
            children: [
              AppSkeleton(width: 34, height: 34, radius: 10),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSkeleton(width: 94, height: 12),
                    SizedBox(height: 6),
                    AppSkeleton(width: 130, height: 12),
                  ],
                ),
              ),
            ],
          )
        : const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSkeleton(width: 94, height: 13),
              SizedBox(height: 12),
              AppSkeleton(width: 150, height: 28),
              SizedBox(height: 12),
              AppSkeleton(width: 180, height: 12),
            ],
          ),
  );
}

// ───────── 空数据 ─────────
