import 'package:flutter/material.dart';

import '../atoms/app_status_tag.dart';
import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

/// 分段排列：等宽铺满，或按内容宽度收缩。
enum AppSegmentedLayout { expanded, compact }

class SegmentItem<T> {
  final T value;
  final String label;

  /// 普通数量；null 隐藏，0 仍显示。与告警 badge 分开。
  final int? count;
  final bool enabled;

  /// 标签后的告警数字；0 隐藏。
  final int badge;
  final Tone badgeTone;
  const SegmentItem({
    required this.value,
    required this.label,
    this.count,
    this.enabled = true,
    this.badge = 0,
    this.badgeTone = Tone.bad,
  });
}

/// 2～5 项分段选择。统一 32px 滑块和 4px 内边距；状态由调用者持有。
class AppSegmented<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final AppSegmentedLayout layout;
  final bool enabled;
  const AppSegmented({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.layout = AppSegmentedLayout.expanded,
    this.enabled = true,
  }) : assert(items.length >= 2 && items.length <= 5, '分段控件只支持 2~5 项');

  Widget _segment(AppTokens t, SegmentItem<T> item) {
    final active = item.value == selected;
    final available = enabled && item.enabled;
    final compact = layout == AppSegmentedLayout.compact;
    final label = '${item.label}${item.count == null ? '' : ' ${item.count}'}';
    return AppTapTarget(
      selected: active,
      mutuallyExclusive: true,
      semanticLabel: '$label${item.badge > 0 ? '，提醒 ${item.badge}' : ''}',
      minWidth: 0,
      minHeight: 32,
      onTap: available
          ? () {
              if (!active) onChanged(item.value);
            }
          : null,
      builder: (context, pressed) => Opacity(
        opacity: available ? 1 : .5,
        child: Container(
          height: 32,
          width: compact ? null : double.infinity,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: AppSpacing.s14)
              : null,
          alignment: compact ? null : Alignment.center,
          decoration: BoxDecoration(
            color: active ? t.segmentActive : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? t.cardShadow : null,
          ),
          child: Center(
            widthFactor: compact ? 1 : null,
            child: Text.rich(
              TextSpan(
                text: label,
                children: [
                  if (item.badge > 0)
                    TextSpan(
                      text: ' ${item.badge}',
                      style: TextStyle(color: toneColors(t, item.badgeTone).fg),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.small.copyWith(color: active ? t.ink : t.inkSub),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final compact = layout == AppSegmentedLayout.compact;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: t.segment,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          for (final item in items)
            if (compact)
              Flexible(child: _segment(t, item))
            else
              Expanded(child: _segment(t, item)),
        ],
      ),
    );
  }
}
