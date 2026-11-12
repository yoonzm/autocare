import 'package:flutter/material.dart';

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

class AppNavItem {
  final String label;
  final IconData icon;
  const AppNavItem({required this.label, required this.icon});
}

/// 底部导航：5 个位置，中间是凸起的扫码浮动按钮，高 84（含安全区另加）。
/// 当前项：主色图标和文字 + 下方 4px 圆点；其他项 inkMute。只在一级页面出现，二级页面进入后隐藏。
/// [items] 为左右各两个共 4 项。
class AppBottomNav extends StatelessWidget {
  final List<AppNavItem> items;
  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onScan;
  final String scanLabel;
  const AppBottomNav({
    super.key,
    required this.items,
    required this.current,
    required this.onTap,
    required this.onScan,
    this.scanLabel = '扫码',
  }) : assert(items.length == 4, '底部导航固定 4 项 + 中间扫码按钮');

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;
    Widget slot(int index) {
      final active = index == current;
      final color = active ? t.primary : t.inkMute;
      return Expanded(
        child: AppTapTarget(
          selected: active,
          semanticLabel: items[index].label,
          minWidth: 0,
          minHeight: 0,
          onTap: () => onTap(index),
          builder: (context, pressed) => SizedBox(
            height: 84,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.s10),
                Icon(items[index].icon, size: 24, color: color),
                const SizedBox(height: 3),
                Text(
                  items[index].label,
                  style: t.micro.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? t.primary : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 84 + bottom,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              slot(0),
              slot(1),
              const Expanded(child: SizedBox()),
              slot(2),
              slot(3),
            ],
          ),
          Positioned(
            top: -18,
            left: 0,
            right: 0,
            child: Center(
              child: AppTapTarget(
                onTap: onScan,
                semanticLabel: scanLabel,
                minWidth: 64,
                minHeight: 64,
                builder: (context, pressed) => Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pressed ? t.primaryPressed : t.primary,
                    boxShadow: [
                      BoxShadow(
                        color: t.scanGlow,
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(Icons.center_focus_strong_rounded, size: 26, color: t.onPrimary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
