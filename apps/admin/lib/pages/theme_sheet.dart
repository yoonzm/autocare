import 'package:flutter/material.dart';

import '../data/theme_state.dart';
import '../ui.dart';

/// 外观：跟随系统 / 浅色 / 深色，点“应用”后真正切换全局主题（与商家端一致）。
Future<void> showThemeSheet(BuildContext context) => showAppBottomSheet<void>(
  context,
  title: '外观',
  subtitle: '选择应用的显示模式',
  builder: (_) => const ThemeSheet(),
);

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
      AppChoiceGroup<ThemeMode>(
        kind: ChipKind.option,
        expanded: true,
        selected: _sel,
        onChanged: (m) => setState(() => _sel = m),
        items: [
          for (final o in _opts)
            ChoiceItem(value: o.$1, label: o.$2, subtitle: o.$3),
        ],
      ),
      const SizedBox(height: AppSpacing.s16),
      Row(
        children: [
          Expanded(
            child: AppButton(
              label: '取消',
              kind: AppButtonKind.secondary,
              size: AppButtonSize.large,
              expanded: true,
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: '应用',
              size: AppButtonSize.large,
              expanded: true,
              onPressed: () {
                appThemeMode.value = _sel;
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s16),
    ],
  );
}
