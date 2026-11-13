import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局外观模式：跟随系统 / 浅色 / 深色。选择会保存在本机，下次打开 App 沿用。
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

String themeModeLabel(ThemeMode m) => switch (m) {
  ThemeMode.system => '跟随系统',
  ThemeMode.light => '浅色',
  ThemeMode.dark => '深色',
};

const _kThemeKey = 'theme_mode';

/// 从本机读回上次选择的外观；没有记录 / 读取失败时保持“跟随系统”。
Future<void> loadThemeMode() async {
  try {
    final saved = (await SharedPreferences.getInstance()).getString(_kThemeKey);
    appThemeMode.value = ThemeMode.values.firstWhere(
      (m) => m.name == saved,
      orElse: () => ThemeMode.system,
    );
  } catch (_) {
    // 本机存储不可用时用默认值
  }
}

/// 外观变化时写入本机。只需调用一次（App 启动时）。
void persistThemeMode() => appThemeMode.addListener(() async {
  try {
    await (await SharedPreferences.getInstance()).setString(
      _kThemeKey,
      appThemeMode.value.name,
    );
  } catch (_) {
    // 保存失败不影响当前外观
  }
});
