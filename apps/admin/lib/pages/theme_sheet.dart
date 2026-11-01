import 'package:flutter/material.dart';

import '../data/theme_state.dart';
import '../theme.dart';
import '../ui.dart';

/// 外观：跟随系统 / 浅色 / 深色，点“应用”后真正切换全局主题（与商家端一致）。
Future<void> showThemeSheet(BuildContext context) =>
    showSheet<void>(context, (_) => const ThemeSheet());

class ThemeSheet extends StatefulWidget {
  const ThemeSheet({super.key});
  @override
  State<ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends State<ThemeSheet> {
  late ThemeMode _sel = appThemeMode.value;

  static const _opts = [
    (ThemeMode.system, '跟随系统', '自动匹配手机的深色 / 浅色设置'),
    (ThemeMode.light, '浅色', '始终使用浅色界面'),
    (ThemeMode.dark, '深色', '始终使用深色界面，夜间更护眼'),
  ];

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('外观', style: ts(20, w: FontWeight.w600, h: 28)),
      const SizedBox(height: 4),
      Text('选择应用的显示模式', style: ts(13, color: C.muted, h: 18)),
      const SizedBox(height: 14),
      for (final o in _opts)
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _sel = o.$1),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: C.inset,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _sel == o.$1 ? C.ink : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.$2, style: ts(15, w: FontWeight.w500, h: 22)),
                      Text(o.$3, style: ts(12, color: C.muted, h: 17)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _sel == o.$1 ? C.ink : Colors.transparent,
                    border: Border.all(
                      color: _sel == o.$1 ? C.ink : C.stroke,
                      width: 1.5,
                    ),
                  ),
                  child: _sel == o.$1
                      ? Icon(Icons.check, size: 14, color: C.card)
                      : null,
                ),
              ],
            ),
          ),
        ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            flex: 5,
            child: Btn('取消', ghost: true, onTap: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 7,
            child: Btn(
              '应用',
              onTap: () {
                appThemeMode.value = _sel;
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    ],
  );
}
