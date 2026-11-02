// 通用颜色选择：色块单选（含“自定义”入口）+ 自定义颜色选色器（底部弹层）+ 最近使用。
//
// 车身颜色（新增会员）、卡面颜色（编辑卡种）共用：页面只传色块列表、选中项和回调，
// 不各自实现选色逻辑（设计稿：ColorPicker / ColorPickerCard）。
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';
import '../widgets/app_icon.dart';
import 'kit.dart' show dk, hts;

/// `#RRGGBB`（大写）。
String hexOf(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// `#7a4b2a` / `7A4B2A` -> 颜色；不是 6 位十六进制返回 null。
Color? colorFromHex(String text) {
  final t = text.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(t)) return null;
  return Color(0xFF000000 | int.parse(t, radix: 16));
}

/// 选色结果：颜色 + 名称（选填）。
class PickedColor {
  final Color color;
  final String name;
  const PickedColor(this.color, [this.name = '']);
  String get hex => hexOf(color);
}

/// 最近使用的自定义颜色（最多 5 个，存在本机）。
class RecentColors {
  RecentColors._();
  static const _key = 'recent_custom_colors';
  static const max = 5;
  static final ValueNotifier<List<Color>> list = ValueNotifier(const []);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key) ?? const [];
      list.value = [
        for (final h in saved)
          if (colorFromHex(h) != null) colorFromHex(h)!,
      ];
    } catch (_) {
      // 本机存储不可用（测试 / 被清理）时只用内存里的
    }
  }

  static Future<void> add(Color c) async {
    final hex = hexOf(c);
    final next = [
      c,
      for (final e in list.value)
        if (hexOf(e) != hex) e,
    ].take(max).toList();
    list.value = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, [for (final e in next) hexOf(e)]);
    } catch (_) {}
  }

  static void clearMemory() => list.value = const [];
}

// ───────── 色块单选 ─────────

/// 一个预设色块。[check] 是选中时对勾的颜色（深色底用浅色对勾）；
/// [lightRing] 表示浅色底（白 / 银 / 香槟金），描边用 1.5px 的浅灰，否则 1px 半透明黑。
class ColorOption {
  final String label;
  final Color color;
  final Color check;
  final bool lightRing;
  const ColorOption(
    this.label,
    this.color, {
    this.check = const Color(0xFFFFFFFF),
    this.lightRing = false,
  });
}

/// 色块单选组 + 末尾的“自定义颜色”入口（彩虹圈里一个 +）。
/// 选中了自定义颜色时，入口里显示那个颜色，并带选中环。
class ColorChoices extends StatelessWidget {
  final List<ColorOption> options;

  /// 选中的预设下标；-1 = 没有预设被选中。
  final int selected;

  /// 当前的自定义颜色（选中它时不为空）。
  final Color? custom;
  final double size;

  /// 网格列数；为空时排成一行。
  final int? columns;
  final ValueChanged<int> onSelect;
  final VoidCallback onCustom;
  const ColorChoices({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onCustom,
    this.custom,
    this.size = 34,
    this.columns,
  });

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      for (var i = 0; i < options.length; i++)
        _swatch(context, options[i], i == selected, () => onSelect(i)),
      _customButton(context),
    ];
    if (columns == null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            items[i],
          ],
        ],
      );
    }
    final rows = <List<Widget>>[];
    for (var i = 0; i < items.length; i += columns!) {
      rows.add(items.sublist(i, (i + columns!).clamp(0, items.length)));
    }
    return Column(
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 14),
          Row(
            children: [
              for (var c = 0; c < columns!; c++)
                Expanded(
                  child: Center(
                    child: c < rows[r].length
                        ? rows[r][c]
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// 选中环：内圈留一圈底色，外圈为主色（设计稿 0 0 0 2px 白, 0 0 0 4px 主色）。
  List<BoxShadow> _ring(BuildContext context) => [
    const BoxShadow(color: C.primary, spreadRadius: 4),
    BoxShadow(
      color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      spreadRadius: 2,
    ),
  ];

  Widget _tap({
    required String label,
    required bool selected,
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
      // 色块 32–34px，上下补到 44px 的可点高度
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ExcludeSemantics(child: child),
      ),
    ),
  );

  Widget _swatch(
    BuildContext context,
    ColorOption o,
    bool on,
    VoidCallback onTap,
  ) => _tap(
    label: o.label,
    selected: on,
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: o.color,
        shape: BoxShape.circle,
        border: Border.all(
          color: o.lightRing
              ? const Color(0xFFD4D4D8)
              : const Color(0x1F000000),
          width: o.lightRing ? 1.5 : 1,
        ),
        boxShadow: on ? _ring(context) : null,
      ),
      child: on ? AppIcon('check', size: 16, color: o.check, stroke: 3) : null,
    ),
  );

  Widget _customButton(BuildContext context) {
    final on = custom != null;
    final inner = size - 14;
    return _tap(
      label: on ? '自定义颜色 ${hexOf(custom!)}' : '自定义颜色',
      selected: on,
      onTap: onCustom,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
            colors: [
              Color(0xFFFF3B30),
              Color(0xFFFFCC00),
              Color(0xFF34C759),
              Color(0xFF00C7BE),
              Color(0xFF0A84FF),
              Color(0xFFAF52DE),
              Color(0xFFFF3B30),
            ],
          ),
          boxShadow: on ? _ring(context) : null,
        ),
        child: Container(
          width: inner,
          height: inner,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? custom : const Color(0xFFFFFFFF),
            shape: BoxShape.circle,
          ),
          child: on
              ? null
              : const AppIcon(
                  'add',
                  size: 11,
                  color: Color(0xFF18181B),
                  stroke: 3,
                ),
        ),
      ),
    );
  }
}

// ───────── 自定义选色器（底部弹层） ─────────

/// 弹出选色器。返回 null = 取消；点“确定”返回选中的颜色（和名称），并记入“最近使用”。
/// [withName] 为 true 时多一个“名称，选填”输入框（车身颜色）。
Future<PickedColor?> showColorPicker(
  BuildContext context, {
  required String title,
  Color initial = const Color(0xFF7A4B2A),
  String initialName = '',
  bool withName = false,
}) {
  unawaited(RecentColors.load());
  return showModalBottomSheet<PickedColor>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    routeSettings: const RouteSettings(name: 'sheet:ColorPicker'),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: ColorPickerSheet(
        title: title,
        initial: initial,
        initialName: initialName,
        withName: withName,
      ),
    ),
  );
}

class ColorPickerSheet extends StatefulWidget {
  final String title;
  final Color initial;
  final String initialName;
  final bool withName;
  const ColorPickerSheet({
    super.key,
    required this.title,
    required this.initial,
    this.initialName = '',
    this.withName = false,
  });
  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late HSVColor hsv = HSVColor.fromColor(widget.initial);
  late final _hex = TextEditingController(
    text: hexOf(widget.initial).substring(1),
  );
  late final _name = TextEditingController(text: widget.initialName);

  Color get color => hsv.toColor();

  @override
  void dispose() {
    _hex.dispose();
    _name.dispose();
    super.dispose();
  }

  void _set(HSVColor v) {
    setState(() => hsv = v);
    final text = hexOf(v.toColor()).substring(1);
    if (_hex.text.toUpperCase() != text) {
      _hex.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  void _onHex(String text) {
    final c = colorFromHex(text);
    // 黑 / 白 / 灰没有色相：沿用当前色相，避免滑块跳到 0
    if (c != null) {
      final next = HSVColor.fromColor(c);
      setState(
        () => hsv = next.saturation == 0 || next.value == 0
            ? next.withHue(hsv.hue)
            : next,
      );
    }
  }

  Widget _hexBox({
    required Color field,
    required Color ink,
    required Color muted,
  }) => Container(
    height: 44,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: field,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Text('#', style: hts(13, muted)),
        const SizedBox(width: 4),
        Expanded(
          child: Semantics(
            label: '颜色值',
            child: TextField(
              controller: _hex,
              onChanged: _onHex,
              maxLength: 6,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
              ],
              style: hts(15, ink, w: FontWeight.w500, lh: 22, ls: .6),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                counterText: '',
                hintText: '6 位色值',
              ),
            ),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    final field = dk(context, const Color(0xFFF4F4F5), const Color(0xFF27272A));
    final pure = HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      decoration: BoxDecoration(
        color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: dk(
                    context,
                    const Color(0xFFD4D4D8),
                    const Color(0xFF3F3F46),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 36,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: hts(17, ink, w: FontWeight.w600, lh: 24),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: '关闭',
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: field,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AppIcon(
                            'close',
                            size: 18,
                            color: dk(
                              context,
                              const Color(0xFF52525B),
                              const Color(0xFFA8A8B3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 饱和度（左右）与明度（上下）
            _Pad(
              height: 180,
              radius: 18,
              semantics: '饱和度与明度',
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFFFFF), pure],
                ),
              ),
              overlay: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xFF000000), Color(0x00000000)],
                ),
              ),
              fx: hsv.saturation,
              fy: 1 - hsv.value,
              thumb: color,
              onChange: (fx, fy) =>
                  _set(hsv.withSaturation(fx).withValue(1 - fy)),
            ),
            const SizedBox(height: 16),
            // 色相
            _Pad(
              height: 16,
              radius: 8,
              semantics: '色相',
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF0000),
                    Color(0xFFFFFF00),
                    Color(0xFF00FF00),
                    Color(0xFF00FFFF),
                    Color(0xFF0000FF),
                    Color(0xFFFF00FF),
                    Color(0xFFFF0000),
                  ],
                ),
              ),
              fx: hsv.hue / 360,
              fy: .5,
              thumb: pure,
              horizontalOnly: true,
              onChange: (fx, _) =>
                  _set(hsv.withHue((fx * 360).clamp(0, 359.99))),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0x1F000000)),
                  ),
                ),
                const SizedBox(width: 12),
                widget.withName
                    ? SizedBox(
                        width: 112,
                        child: _hexBox(field: field, ink: ink, muted: muted),
                      )
                    : Expanded(
                        child: _hexBox(field: field, ink: ink, muted: muted),
                      ),
                if (widget.withName) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: field,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: TextField(
                        controller: _name,
                        maxLength: 10,
                        style: hts(14, ink, lh: 20),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isCollapsed: true,
                          counterText: '',
                          hintText: '名称，选填',
                          hintStyle: hts(14, muted, lh: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            ValueListenableBuilder<List<Color>>(
              valueListenable: RecentColors.list,
              builder: (context, recent, _) {
                if (recent.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('最近使用', style: hts(12, muted, lh: 17)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final c in recent) ...[
                            Semantics(
                              button: true,
                              label: '使用 ${hexOf(c)}',
                              child: GestureDetector(
                                onTap: () => _set(HSVColor.fromColor(c)),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0x1F000000),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 10,
                  child: _SheetButton(
                    '取消',
                    bg: dk(
                      context,
                      const Color(0xFFEEEEF0),
                      const Color(0xFF27272A),
                    ),
                    fg: ink,
                    weight: FontWeight.w500,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 14,
                  child: _SheetButton(
                    '确定',
                    bg: const Color(0xFF0485F7),
                    fg: const Color(0xFFFFFFFF),
                    weight: FontWeight.w600,
                    onTap: () {
                      final picked = PickedColor(color, _name.text.trim());
                      unawaited(RecentColors.add(picked.color));
                      Navigator.of(context).pop(picked);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  final String text;
  final Color bg, fg;
  final FontWeight weight;
  final VoidCallback onTap;
  const _SheetButton(
    this.text, {
    required this.bg,
    required this.fg,
    required this.weight,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: text,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(text, style: hts(15, fg, w: weight, lh: 22)),
      ),
    ),
  );
}

/// 可拖动取值的色板 / 滑条：底色渐变 + 可选的叠加渐变 + 圆形取色点。
class _Pad extends StatelessWidget {
  final double height, radius;
  final String semantics;
  final BoxDecoration decoration;
  final BoxDecoration? overlay;
  final double fx, fy;
  final Color thumb;
  final bool horizontalOnly;
  final void Function(double fx, double fy) onChange;
  const _Pad({
    required this.height,
    required this.radius,
    required this.semantics,
    required this.decoration,
    required this.fx,
    required this.fy,
    required this.thumb,
    required this.onChange,
    this.overlay,
    this.horizontalOnly = false,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final w = box.maxWidth;
      void at(Offset p) => onChange(
        (p.dx / w).clamp(0.0, 1.0),
        horizontalOnly ? .5 : (p.dy / height).clamp(0.0, 1.0),
      );
      return Semantics(
        label: semantics,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => at(d.localPosition),
          onPanUpdate: (d) => at(d.localPosition),
          child: SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: DecoratedBox(decoration: decoration)),
                if (overlay != null)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: overlay!.copyWith(
                        borderRadius: BorderRadius.circular(radius),
                      ),
                    ),
                  ),
                Positioned(
                  left: fx * w - 12,
                  top: fy * height - 12,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: thumb,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0xFFFFFFFF), spreadRadius: 3),
                        BoxShadow(
                          color: Color(0x59000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
