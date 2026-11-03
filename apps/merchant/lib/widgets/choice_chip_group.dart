import 'package:flutter/material.dart';

import '../theme.dart';

enum ChipKind { pill, tile }

class ChoiceChipItem<T> {
  final T value;
  final String label;
  final bool isOriginal;
  final bool disabled;
  const ChoiceChipItem({
    required this.value,
    required this.label,
    this.isOriginal = false,
    this.disabled = false,
  });
}

/// 受控的单选标签；选中外观只由 [selected] 决定。
class ChoiceChipGroup<T> extends StatelessWidget {
  final List<ChoiceChipItem<T>> items;
  final T? selected;
  final ValueChanged<T> onChanged;
  final ChipKind kind;
  final int columns;
  final String semanticLabel;
  const ChoiceChipGroup({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    required this.kind,
    required this.semanticLabel,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    explicitChildNodes: true,
    child: kind == ChipKind.pill && items.length == 1
        ? IntrinsicWidth(child: _chip(context, items.single))
        : kind == ChipKind.pill
        ? Wrap(
            spacing: 8,
            runSpacing: 0,
            children: [for (final item in items) _chip(context, item)],
          )
        : LayoutBuilder(
            builder: (context, box) => Wrap(
              spacing: 8,
              runSpacing: 0,
              children: [
                for (final item in items)
                  SizedBox(
                    width: (box.maxWidth - (columns - 1) * 8) / columns,
                    child: _chip(context, item),
                  ),
              ],
            ),
          ),
  );

  Widget _chip(BuildContext context, ChoiceChipItem<T> item) {
    final sel = !item.disabled && item.value == selected;
    final dark = C.dark;
    final bg = item.disabled
        ? (dark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
        : sel
        ? (dark
              ? const Color.fromRGBO(4, 133, 247, 0.18)
              : const Color(0xFFE1F0FE))
        : item.isOriginal
        ? (dark ? const Color(0xFF34343A) : const Color(0xFFEEEEF0))
        : (dark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5));
    final fg = item.disabled
        ? (dark ? const Color(0xFF71717A) : const Color(0xFFC4C4C9))
        : sel
        ? (dark ? const Color(0xFF6AB4FA) : const Color(0xFF1E63AE))
        : item.isOriginal
        ? (dark ? const Color(0xFF9A9AA3) : const Color(0xFF71717A))
        : kind == ChipKind.tile
        ? (dark ? const Color(0xFFFAFAFA) : const Color(0xFF18181B))
        : (dark ? const Color(0xFFD4D4D8) : const Color(0xFF3F3F46));
    final border = sel
        ? const Color(0xFF0485F7)
        : item.isOriginal && !item.disabled
        ? const Color(0xFFC7C7CC)
        : Colors.transparent;
    final label = item.isOriginal && !item.label.endsWith(' 原')
        ? '${item.label} 原'
        : item.label;
    final radius = kind == ChipKind.pill ? 17.0 : 12.0;
    return _ChipCell<T>(
      value: item.value,
      onChanged: onChanged,
      disabled: item.disabled,
      selected: sel,
      semanticLabel: item.isOriginal
          ? '${item.label.endsWith(' 原') ? item.label.substring(0, item.label.length - 2) : item.label}，原预约时间'
          : item.label,
      label: label,
      kind: kind,
      background: bg,
      foreground: fg,
      border: border,
      radius: radius,
    );
  }
}

class _ChipCell<T> extends StatefulWidget {
  final T value;
  final ValueChanged<T> onChanged;
  final bool disabled, selected;
  final String semanticLabel, label;
  final ChipKind kind;
  final Color background, foreground, border;
  final double radius;
  const _ChipCell({
    required this.value,
    required this.onChanged,
    required this.disabled,
    required this.selected,
    required this.semanticLabel,
    required this.label,
    required this.kind,
    required this.background,
    required this.foreground,
    required this.border,
    required this.radius,
  });
  @override
  State<_ChipCell<T>> createState() => _ChipCellState<T>();
}

class _ChipCellState<T> extends State<_ChipCell<T>> {
  bool pressed = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: widget.selected,
    enabled: !widget.disabled,
    inMutuallyExclusiveGroup: true,
    label: widget.semanticLabel,
    child: ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.disabled
            ? null
            : (_) => setState(() => pressed = true),
        onTapUp: widget.disabled
            ? null
            : (_) => setState(() => pressed = false),
        onTapCancel: widget.disabled
            ? null
            : () => setState(() => pressed = false),
        onTap: widget.disabled ? null : () => widget.onChanged(widget.value),
        child: SizedBox(
          height: 44,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(minWidth: 44),
              decoration: BoxDecoration(
                color: pressed
                    ? Color.alphaBlend(
                        const Color(0x0F000000),
                        widget.background,
                      )
                    : widget.background,
                borderRadius: BorderRadius.circular(widget.radius),
                border: Border.all(color: widget.border, width: 1.5),
              ),
              child: SizedBox(
                height: widget.kind == ChipKind.pill ? 34 : 38,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.kind == ChipKind.pill ? 14 : 0,
                  ),
                  child: Center(
                    widthFactor: widget.kind == ChipKind.pill ? 1 : null,
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      style: TextStyle(
                        color: widget.foreground,
                        fontSize: widget.kind == ChipKind.pill ? 13 : 14,
                        height: widget.kind == ChipKind.pill
                            ? 18 / 13
                            : 20 / 14,
                        fontWeight: FontWeight.w500,
                        decoration: widget.disabled
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
