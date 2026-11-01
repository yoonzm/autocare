// 新增会员页的选择类控件：称呼（分段）、车身颜色、会员等级、客户来源。
//
// 这些控件原先由设计稿自动转换生成，转换时把「选中 / 未选中」两套样式拼错了
// （嵌套的按钮、白字叠在浅灰底上、品牌色被深色模式反转等），这里改为手写：
// 每个控件只维护一个选中下标，样式统一从 [C] 色板与设计稿的固定品牌色取值。
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

/// 称呼：先生 / 女士 分段选择。
class HSegmented extends StatefulWidget {
  final List<String> labels;
  final int initial;
  final ValueChanged<int>? onChanged;
  const HSegmented({
    super.key,
    required this.labels,
    this.initial = 0,
    this.onChanged,
  });
  @override
  State<HSegmented> createState() => _HSegmentedState();
}

class _HSegmentedState extends State<HSegmented> {
  late int sel = widget.initial;

  @override
  Widget build(BuildContext context) {
    // 浅色：白色滑块；深色：比轨道更亮的滑块，保证选中项一眼可辨
    final thumb = C.dark ? const Color(0xFF3F3F46) : Colors.white;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: C.chip,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < widget.labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _selectable(
              selected: sel == i,
              label: widget.labels[i],
              onTap: () {
                setState(() => sel = i);
                widget.onChanged?.call(i);
              },
              child: AnimatedContainer(
                duration: _kAnim,
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: sel == i ? thumb : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: sel == i && !C.dark
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    widget.labels[i],
                    style: ts(
                      13,
                      w: FontWeight.w500,
                      color: sel == i ? C.ink : C.sub,
                      h: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 选中环：内圈留一圈卡片底色，外圈为主色（设计稿 0 0 0 2px 白, 0 0 0 4px 主色）。
List<BoxShadow> _ring(Color gap) => [
  const BoxShadow(color: C.primary, spreadRadius: 4),
  BoxShadow(color: gap, spreadRadius: 2),
];

/// 车身颜色：品牌色是真实车漆颜色，不随深色模式反转。
class HColorDots extends StatefulWidget {
  final int initial;
  final ValueChanged<int>? onChanged;
  const HColorDots({super.key, this.initial = 0, this.onChanged});

  static const names = ['黑色', '白色', '灰色', '蓝色', '红色'];
  static const colors = [
    Color(0xFF18181B),
    Color(0xFFFFFFFF),
    Color(0xFF8E8E93),
    Color(0xFF1E40AF),
    Color(0xFFB91C1C),
  ];

  @override
  State<HColorDots> createState() => _HColorDotsState();
}

class _HColorDotsState extends State<HColorDots> {
  late int sel = widget.initial;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < HColorDots.colors.length; i++)
        _selectable(
          selected: sel == i,
          label: HColorDots.names[i],
          onTap: () {
            setState(() => sel = i);
            widget.onChanged?.call(i);
          },
          // 间距 8 = 左右各 4 的点击余量；上下补到 44 的可点高度
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
            child: AnimatedContainer(
              duration: _kAnim,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: HColorDots.colors[i],
                shape: BoxShape.circle,
                // 黑 / 白两色与卡片底色接近，补一圈描边
                border: i == 0 || i == 1
                    ? Border.all(
                        color: C.dark
                            ? const Color(0xFF3F3F46)
                            : const Color(0xFFD4D4D8),
                        width: 1.5,
                      )
                    : null,
                boxShadow: sel == i ? _ring(C.card) : null,
              ),
            ),
          ),
        ),
    ],
  );
}

/// 会员等级：普通 / 银卡 / 金卡 / 黑金，选中项带主色环并标注「当前」。
class HTierPicker extends StatefulWidget {
  final int initial;
  final ValueChanged<int>? onChanged;
  const HTierPicker({super.key, this.initial = 0, this.onChanged});

  static const tiers = ['普通', '银卡', '金卡', '黑金'];
  // 升级门槛（普通为默认等级，无门槛说明）
  static const _rules = [
    '',
    '充值 ¥2,000\n或消费 ¥3,000',
    '充值 ¥5,000\n或消费 ¥10,000',
    '充值 ¥10,000\n或消费 ¥30,000',
  ];

  @override
  State<HTierPicker> createState() => _HTierPickerState();
}

class _HTierPickerState extends State<HTierPicker> {
  late int sel = widget.initial;

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
          for (var i = 0; i < HTierPicker.tiers.length; i++)
            Expanded(
              child: _selectable(
                selected: sel == i,
                label: '${HTierPicker.tiers[i]}${sel == i ? '，当前' : ''}',
                onTap: () {
                  setState(() => sel = i);
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
                          HTierPicker.tiers[i],
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
                              HTierPicker._rules[i],
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

/// 客户来源：单选标签组。选中为反白 / 深色实心，未选中为卡片内凹陷底。
class HChipGroup extends StatefulWidget {
  final List<String> labels;
  final int initial;
  final ValueChanged<int>? onChanged;
  const HChipGroup({
    super.key,
    required this.labels,
    this.initial = 0,
    this.onChanged,
  });
  @override
  State<HChipGroup> createState() => _HChipGroupState();
}

class _HChipGroupState extends State<HChipGroup> {
  late int sel = widget.initial;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (var i = 0; i < widget.labels.length; i++)
        _selectable(
          selected: sel == i,
          label: widget.labels[i],
          onTap: () {
            setState(() => sel = i);
            widget.onChanged?.call(i);
          },
          child: AnimatedContainer(
            duration: _kAnim,
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: sel == i ? C.btn : C.inset,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              widthFactor: 1,
              child: Text(
                widget.labels[i],
                style: ts(
                  13,
                  w: FontWeight.w500,
                  color: sel == i
                      ? C.btnFg
                      : (C.dark
                            ? const Color(0xFFD4D4D8)
                            : const Color(0xFF3F3F46)),
                  h: 18,
                ),
              ),
            ),
          ),
        ),
    ],
  );
}
