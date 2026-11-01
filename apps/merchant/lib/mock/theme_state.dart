import 'package:flutter/material.dart';

/// 全局外观模式：跟随系统 / 浅色 / 深色（仅内存，mock）。
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier(ThemeMode.system);

String themeModeLabel(ThemeMode m) => switch (m) {
  ThemeMode.system => '跟随系统',
  ThemeMode.light => '浅色',
  ThemeMode.dark => '深色',
};
