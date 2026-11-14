import 'package:flutter/material.dart';

import '../atoms/app_status_tag.dart';
import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

class SegmentItem<T> {
  final T value;
  final String label;

  /// 标签后的红色数字角标，如「失败 3」。
  final int badge;

  /// 角标颜色：默认 bad（红），提醒类用 warn。
  final Tone badgeTone;
  const SegmentItem({
    required this.value,
    required this.label,
    this.badge = 0,
    this.badgeTone = Tone.bad,
  });
}

/// 分段控件：用于「切换整页内容」，选中是白色滑块。2~4 项，超过 4 项改用选择标签或下拉。
/// 不用黑色，也不和选择标签混用。
class AppSegmented<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  const AppSegmented({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
  }) : assert(items.length >= 2 && items.length <= 4, '分段控件只支持 2~4 项');

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s4),
      decoration: BoxDecoration(
        color: t.segment,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (final item in items)
            Expanded(
              child: AppTapTarget(
                selected: item.value == selected,
                semanticLabel: item.label,
                minWidth: 0,
                minHeight: 32,
                onTap: () => onChanged(item.value),
                builder: (context, pressed) {
                  final active = item.value == selected;
                  return Container(
                    height: 32,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? t.segmentActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: active ? t.cardShadow : null,
                    ),
                    child: Text.rich(
                      TextSpan(
                        text: item.label,
                        children: [
                          if (item.badge > 0)
                            TextSpan(
                              text: ' ${item.badge}',
                              style: TextStyle(color: toneColors(t, item.badgeTone).fg),
                            ),
                        ],
                      ),
                      style: t.small.copyWith(
                        color: active ? t.ink : t.inkSub,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
