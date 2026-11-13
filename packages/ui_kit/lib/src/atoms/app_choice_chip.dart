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

  /// 撑满可用宽度（单选操作弹层里一项一行）；默认按内容收缩。
  final bool expanded;
  final VoidCallback? onTap;
  final bool mutuallyExclusive;
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    this.kind = ChipKind.pill,
    this.subtitle,
    this.avatarName,
    this.expanded = false,
    this.onTap,
    this.mutuallyExclusive = false,
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
      mutuallyExclusive: mutuallyExclusive,
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
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.small.copyWith(color: fg),
              ),
            ],
          ),
          _ => Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.small.copyWith(color: fg),
          ),
        };
        return Container(
          width: expanded ? double.infinity : null,
          height: kind == ChipKind.option ? null : height,
          padding: EdgeInsets.symmetric(
            horizontal: kind == ChipKind.avatar
                ? AppSpacing.s6
                : AppSpacing.s14,
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

/// 标签排列：自动换行、单行横向滚动；传 columns 时按指定列数等宽排列。
enum AppChoiceLayout { wrap, horizontal }

/// 受控选择组。单选使用 selected，多选使用 .multiple 与 selectedValues。
/// 禁用项不显示为选中；单选再次点击当前项不会触发回调。
class AppChoiceGroup<T> extends StatelessWidget {
  final List<ChoiceItem<T>> items;
  final T? selected;
  final ValueChanged<T>? onChanged;
  final Set<T>? selectedValues;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final ChipKind kind;
  final bool expanded;
  final AppChoiceLayout layout;
  final int? columns;
  final String? semanticLabel;

  /// 横向标签末尾的独立操作，不参与选中状态。
  final Widget? trailing;

  const AppChoiceGroup({
    super.key,
    required this.items,
    required this.selected,
    required ValueChanged<T> this.onChanged,
    this.kind = ChipKind.pill,
    this.expanded = false,
    this.layout = AppChoiceLayout.wrap,
    this.columns,
    this.semanticLabel,
    this.trailing,
  }) : selectedValues = null,
       onSelectionChanged = null,
       assert(columns == null || columns > 0),
       assert(!expanded || (columns == null && layout == AppChoiceLayout.wrap)),
       assert(columns == null || layout == AppChoiceLayout.wrap),
       assert(trailing == null || layout == AppChoiceLayout.horizontal);

  const AppChoiceGroup.multiple({
    super.key,
    required this.items,
    required Set<T> this.selectedValues,
    required ValueChanged<Set<T>> onChanged,
    this.kind = ChipKind.pill,
    this.expanded = false,
    this.layout = AppChoiceLayout.wrap,
    this.columns,
    this.semanticLabel,
    this.trailing,
  }) : selected = null,
       onChanged = null,
       onSelectionChanged = onChanged,
       assert(columns == null || columns > 0),
       assert(!expanded || (columns == null && layout == AppChoiceLayout.wrap)),
       assert(columns == null || layout == AppChoiceLayout.wrap),
       assert(trailing == null || layout == AppChoiceLayout.horizontal);

  bool get _multiple => selectedValues != null;

  Widget _chip(ChoiceItem<T> item, {bool fill = false}) {
    final active =
        item.enabled &&
        (_multiple
            ? selectedValues!.contains(item.value)
            : item.value == selected);
    return AppChoiceChip(
      label: item.label,
      subtitle: item.subtitle,
      avatarName: item.avatarName,
      kind: kind,
      expanded: fill,
      selected: active,
      mutuallyExclusive: !_multiple,
      onTap: !item.enabled
          ? null
          : () {
              if (_multiple) {
                final next = Set<T>.of(selectedValues!);
                if (!next.add(item.value)) next.remove(item.value);
                onSelectionChanged!(Set<T>.unmodifiable(next));
              } else if (!active) {
                onChanged!(item.value);
              }
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (expanded) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.s8),
            _chip(items[i], fill: true),
          ],
        ],
      );
    } else if (layout == AppChoiceLayout.horizontal) {
      body = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.s8),
              _chip(items[i]),
            ],
            if (trailing != null) ...[
              if (items.isNotEmpty) const SizedBox(width: AppSpacing.s8),
              trailing!,
            ],
          ],
        ),
      );
    } else if (columns != null) {
      body = LayoutBuilder(
        builder: (context, constraints) {
          final width =
              ((constraints.maxWidth - (columns! - 1) * AppSpacing.s8) /
                      columns!)
                  .clamp(0.0, double.infinity);
          return Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: [
              for (final item in items)
                SizedBox(width: width, child: _chip(item, fill: true)),
            ],
          );
        },
      );
    } else {
      body = Wrap(
        spacing: AppSpacing.s8,
        runSpacing: AppSpacing.s8,
        children: [for (final item in items) _chip(item)],
      );
    }
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: body,
    );
  }
}
