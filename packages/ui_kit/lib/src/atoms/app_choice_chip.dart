import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';
import 'app_avatar.dart';
import 'app_tap_target.dart';

/// 形态：pill 胶囊（高 34）· tile 方块（高 38）· avatar 带头像（高 36）· option 方块选项（标题 + 副标题）。
enum ChipKind { pill, tile, avatar, option }

/// 选择标签。「选中」只有一种表达：浅蓝底 + 1.5px 内描边蓝 + 蓝字，三者同时出现；
/// 未选中也预留同样的描边空间，切换时不抖动。选中状态只来自受控变量 [selected]。
class AppChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ChipKind kind;
  final String? subtitle;
  final String? avatarName;
  final VoidCallback? onTap;
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.kind = ChipKind.pill,
    this.subtitle,
    this.avatarName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final disabled = onTap == null;
    final (height, radius) = switch (kind) {
      ChipKind.pill => (34.0, 17.0),
      ChipKind.tile => (38.0, AppRadius.tile),
      ChipKind.avatar => (36.0, 18.0),
      ChipKind.option => (0.0, AppRadius.field),
    };
    final fg = disabled
        ? t.inkFaint
        : selected
        ? t.primaryText
        : t.ink;
    final bg = selected ? t.primarySoft : t.inset;
    return AppTapTarget(
      onTap: onTap,
      selected: selected,
      semanticLabel: subtitle == null ? label : '$label，$subtitle',
      minWidth: 0,
      minHeight: kind == ChipKind.option ? 0 : AppSpacing.minTap,
      builder: (context, pressed) {
        final body = switch (kind) {
          ChipKind.option => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: t.base.copyWith(color: fg)),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: t.caption.copyWith(
                    color: disabled ? t.inkFaint : t.inkMute,
                  ),
                ),
            ],
          ),
          ChipKind.avatar => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAvatar(name: avatarName ?? label, size: 28),
              const SizedBox(width: AppSpacing.s6),
              Text(label, style: t.small.copyWith(color: fg)),
            ],
          ),
          _ => Text(label, style: t.small.copyWith(color: fg)),
        };
        return Container(
          height: kind == ChipKind.option ? null : height,
          padding: EdgeInsets.symmetric(
            horizontal: kind == ChipKind.avatar ? AppSpacing.s6 : AppSpacing.s14,
            vertical: kind == ChipKind.option ? AppSpacing.s10 : 0,
          ).copyWith(right: kind == ChipKind.avatar ? AppSpacing.s14 : null),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              pressed ? t.pressedOverlay : Colors.transparent,
              bg,
            ),
            borderRadius: BorderRadius.circular(radius),
            // 内描边：未选中时同样占位（透明），切换不抖动。
            border: Border.all(
              color: selected ? t.primary : Colors.transparent,
              width: 1.5,
            ),
          ),
          // 不用 Container.alignment：它会在 Wrap / Row 的宽松约束下把标签撑满整行。
          child: kind == ChipKind.option
              ? body
              : Center(widthFactor: 1, child: body),
        );
      },
    );
  }
}

/// [AppChoiceGroup] 的一项。[enabled] 为 false 时不可选。
class ChoiceItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final String? avatarName;
  final bool enabled;
  const ChoiceItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.avatarName,
    this.enabled = true,
  });
}

/// 单选互斥的一组选择标签：同组最多一个选中，禁用项跳过。
class AppChoiceGroup<T> extends StatelessWidget {
  final List<ChoiceItem<T>> items;
  final T? selected;
  final ValueChanged<T> onChanged;
  final ChipKind kind;
  const AppChoiceGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.kind = ChipKind.pill,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.s8,
    runSpacing: AppSpacing.s8,
    children: [
      for (final item in items)
        AppChoiceChip(
          label: item.label,
          subtitle: item.subtitle,
          avatarName: item.avatarName,
          kind: kind,
          selected: item.value == selected,
          onTap: item.enabled ? () => onChanged(item.value) : null,
        ),
    ],
  );
}
