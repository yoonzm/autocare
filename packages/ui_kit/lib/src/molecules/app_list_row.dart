import 'package:flutter/material.dart';

import '../atoms/app_status_tag.dart';
import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';
import 'app_card.dart';

/// 列表行左侧的 32 圆角图标底。
class AppIconTile extends StatelessWidget {
  final IconData icon;
  final Tone tone;
  const AppIconTile({super.key, required this.icon, this.tone = Tone.wait});

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final c = toneColors(t, tone);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: c.fg),
    );
  }
}

/// 列表行高度档：standard 54（默认）· comfortable 60（后台「我的」「概览待办」等）·
/// spacious 70（带副标题的列表，如工单）。
enum AppRowSize { standard, comfortable, spacious }

/// 列表行：最小高按 [size]（默认 54）；左侧可选图标底，右侧可放文字、箭头、开关。
/// 整行可点（[onTap] 不为空）时才显示箭头，点击反馈为整行叠 4% 黑色。
class AppListRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final String? value;
  final bool showChevron;
  final VoidCallback? onTap;
  final AppRowSize size;
  const AppListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.value,
    this.showChevron = true,
    this.onTap,
    this.size = AppRowSize.standard,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    Widget row(bool pressed) => Container(
      constraints: BoxConstraints(
        minHeight: switch (size) {
          AppRowSize.standard => 54,
          AppRowSize.comfortable => 60,
          AppRowSize.spacious => 70,
        },
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      color: pressed ? t.pressedOverlay : Colors.transparent,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: AppSpacing.s12),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.body),
                if (subtitle != null)
                  Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.caption),
              ],
            ),
          ),
          if (value != null) ...[
            const SizedBox(width: AppSpacing.s8),
            Flexible(
              child: Text(
                value!,
                overflow: TextOverflow.ellipsis,
                style: t.base.copyWith(
                  color: t.inkMute,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.s8),
            trailing!,
          ],
          if (onTap != null && showChevron) ...[
            const SizedBox(width: AppSpacing.s4),
            Icon(Icons.chevron_right_rounded, size: 20, color: t.inkFaint),
          ],
        ],
      ),
    );
    if (onTap == null) return row(false);
    return AppTapTarget(
      onTap: onTap,
      minWidth: 0,
      minHeight: 0,
      builder: (context, pressed) => SizedBox(
        width: double.infinity,
        child: row(pressed),
      ),
    );
  }
}

/// 一组列表行：白色卡片，行间分割线（有图标底时左缩进 60，否则 16），最后一行不画。
class AppListGroup extends StatelessWidget {
  final List<Widget> rows;
  const AppListGroup({super.key, required this.rows});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.s4),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card - 4),
      child: AppDividedColumn(
        indent: rows.whereType<AppListRow>().any((r) => r.leading != null)
            ? 60
            : AppSpacing.s16,
        children: rows,
      ),
    ),
  );
}
