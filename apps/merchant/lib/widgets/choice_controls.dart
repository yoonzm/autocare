// 会员等级的业务选择卡；普通分段选择使用 AppSegmented。
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

const Duration _kAnim = Duration(milliseconds: 140);

/// 单选语义 + 点击反馈。
Widget _selectable({
  required bool selected,
  required String label,
  required VoidCallback onTap,
  required Widget child,
}) => Semantics(
  button: true,
  selected: selected,
  inMutuallyExclusiveGroup: true,
  label: label,
  child: GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      if (!selected) HapticFeedback.selectionClick();
      onTap();
    },
    child: ExcludeSemantics(child: child),
  ),
);

/// 选中环：内圈留一圈卡片底色，外圈为主色（设计稿 0 0 0 2px 白, 0 0 0 4px 主色）。
List<BoxShadow> _ring(Color gap) => [
  const BoxShadow(color: C.primary, spreadRadius: 4),
  BoxShadow(color: gap, spreadRadius: 2),
];

/// 会员等级：普通 / 银卡 / 金卡 / 黑金，选中项带主色环并标注「当前」。
class HTierPicker extends StatefulWidget {
  final int initial;
  final ValueChanged<int>? onChanged;
  final List<String> labels, rules;
  const HTierPicker({
    super.key,
    required this.labels,
    required this.rules,
    this.initial = 0,
    this.onChanged,
  });

  @override
  State<HTierPicker> createState() => _HTierPickerState();
}

class _HTierPickerState extends State<HTierPicker> {
  int get sel => widget.initial;

  (Color, Color) _colors(int i) => switch (i) {
    0 => (C.inset, C.ink),
    1 => (C.stroke, C.dark ? const Color(0xFFD4D4D8) : const Color(0xFF27272A)),
    2 => (const Color(0xFFF3E2B3), const Color(0xFF3D2B0E)),
    _ => (C.pill, C.gold),
  };

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      // 等级之间的连接线，位于胶囊后面
      Positioned(
        left: 0,
        right: 0,
        top: 15,
        child: FractionallySizedBox(
          widthFactor: 0.75,
          child: Container(height: 2, color: C.stroke),
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < widget.labels.length; i++)
            Expanded(
              child: _selectable(
                selected: sel == i,
                label: '${widget.labels[i]}${sel == i ? '，当前' : ''}',
                onTap: () {
                  widget.onChanged?.call(i);
                },
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: _kAnim,
                      height: 32,
                      constraints: const BoxConstraints(minWidth: 52),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _colors(i).$1,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: sel == i ? _ring(C.card) : null,
                      ),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          widget.labels[i],
                          style: ts(
                            13,
                            w: FontWeight.w600,
                            color: _colors(i).$2,
                            h: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 28,
                      child: sel == i
                          ? Text('当前', style: ts(11, w: FontWeight.w600, h: 14))
                          : Text(
                              widget.rules[i],
                              textAlign: TextAlign.center,
                              softWrap: false,
                              style: ts(
                                10,
                                color: C.muted,
                                h: 14,
                                spacing: -0.2,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
