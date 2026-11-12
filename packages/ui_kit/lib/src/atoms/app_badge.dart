import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

/// 红点数字：最小宽 18、圆角 9，只用于待处理数量。数量 ≤ 0 时不显示，超过 99 显示 99+。
class AppBadge extends StatelessWidget {
  final int count;
  const AppBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final t = AppTokens.of(context);
    return Semantics(
      label: '$count 条待处理',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18),
        height: 18,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.badge,
          borderRadius: BorderRadius.circular(AppRadius.tag),
        ),
        child: Text(
          count > 99 ? '99+' : '$count',
          style: t.micro.copyWith(
            color: t.onPrimary,
            fontFeatures: AppTokens.tabular,
          ),
        ),
      ),
    );
  }
}
