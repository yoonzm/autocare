import 'package:flutter/material.dart';

import '../kit/color_picker.dart';
import '../kit/kit.dart' show dk, hts;

/// 车身颜色的预设色块（设计稿顺序）。
const vehicleColorOptions = [
  ColorOption('黑色', Color(0xFF18181B)),
  ColorOption(
    '白色',
    Color(0xFFFFFFFF),
    check: Color(0xFF18181B),
    lightRing: true,
  ),
  ColorOption(
    '银色',
    Color(0xFFC9CDD2),
    check: Color(0xFF18181B),
    lightRing: true,
  ),
  ColorOption('灰色', Color(0xFF8E8E93)),
  ColorOption('红色', Color(0xFFC0392B)),
  ColorOption('蓝色', Color(0xFF1E63AE)),
  ColorOption('棕色', Color(0xFF6B4A2B)),
  ColorOption(
    '香槟金',
    Color(0xFFCDB68A),
    check: Color(0xFF18181B),
    lightRing: true,
  ),
  ColorOption('绿色', Color(0xFF2B7745)),
  ColorOption('橙色', Color(0xFFE8761A)),
  ColorOption('紫色', Color(0xFF6B46C1)),
];

/// 卡面颜色的 4 个系统默认配色（顺序与 [CardColorChoices.values] 一致）。
const cardColorOptions = [
  ColorOption('黑金卡配色', Color(0xFF18181B), check: Color(0xFFF5D78E)),
  ColorOption('金卡配色', Color(0xFFF3E2B3), check: Color(0xFF3D2B0E)),
  ColorOption(
    '银卡配色',
    Color(0xFFE4E4E7),
    check: Color(0xFF18181B),
    lightRing: true,
  ),
  ColorOption(
    '普通会员配色',
    Color(0xFFFFFFFF),
    check: Color(0xFF18181B),
    lightRing: true,
  ),
];

/// 新增会员里的“车身颜色”：标题行显示当前颜色名，下面是 6 列色块网格，末尾是自定义颜色。
/// 选中的颜色名写入会员草稿（自定义颜色没填名称时用色值，如 `#7A4B2A`）。
class HVehicleColor extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const HVehicleColor({
    super.key,
    required this.value,
    required this.onChanged,
  });
  @override
  State<HVehicleColor> createState() => _HVehicleColorState();
}

class _HVehicleColorState extends State<HVehicleColor> {
  Color? _customColor;
  String _customLabel = '';
  int get sel =>
      vehicleColorOptions.indexWhere((option) => option.label == widget.value);
  String get label => widget.value;
  String get customLabel => widget.value;
  Color? get custom => sel >= 0
      ? null
      : _customLabel == widget.value
      ? _customColor
      : colorFromHex(widget.value) ?? const Color(0xFF7A4B2A);

  Future<void> _pickCustom() async {
    final r = await showColorPicker(
      context,
      title: '自定义车身颜色',
      initial: custom ?? const Color(0xFF7A4B2A),
      initialName: sel < 0 && customLabel != hexOf(custom ?? Colors.black)
          ? customLabel
          : '',
      withName: true,
    );
    if (r == null || !mounted) return;
    setState(() {
      _customColor = r.color;
      _customLabel = r.name.isEmpty ? r.hex : r.name;
    });
    widget.onChanged(_customLabel);
  }

  @override
  Widget build(BuildContext context) {
    final sub = dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3));
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('车身颜色', style: hts(14, sub, lh: 20))),
              Text(label, style: hts(14, ink, w: FontWeight.w500, lh: 20)),
            ],
          ),
          const SizedBox(height: 7),
          ColorChoices(
            options: vehicleColorOptions,
            selected: sel,
            custom: sel < 0 ? custom : null,
            columns: 6,
            onSelect: (i) {
              widget.onChanged(vehicleColorOptions[i].label);
            },
            onCustom: _pickCustom,
          ),
        ],
      ),
    );
  }
}

/// 卡面颜色受控输入；状态归页面所有，不读取或修改全局草稿。
class CardColorChoices extends StatelessWidget {
  static const values = ['black', 'champagne', 'silver', 'white'];
  final String value;
  final ValueChanged<String> onChanged;
  const CardColorChoices({
    super.key,
    required this.value,
    required this.onChanged,
  });

  Color? get custom =>
      RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value) ? colorFromHex(value) : null;

  Future<void> _pickCustom(BuildContext context) async {
    final result = await showColorPicker(
      context,
      title: '自定义卡面颜色',
      initial: custom ?? const Color(0xFF7A4B2A),
    );
    if (result != null && context.mounted) onChanged(result.hex);
  }

  @override
  Widget build(BuildContext context) => ColorChoices(
    options: cardColorOptions,
    selected: custom != null ? -1 : values.indexOf(value),
    custom: custom,
    size: 32,
    onSelect: (i) => onChanged(values[i]),
    onCustom: () => _pickCustom(context),
  );
}
