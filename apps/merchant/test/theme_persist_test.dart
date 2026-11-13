import 'package:autocare_merchant/preferences/theme_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => appThemeMode.value = ThemeMode.system);

  test('没有保存过：保持跟随系统', () async {
    SharedPreferences.setMockInitialValues({});
    await loadThemeMode();
    expect(appThemeMode.value, ThemeMode.system);
  });

  test('读回上次保存的外观；无法识别的值回到跟随系统', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    await loadThemeMode();
    expect(appThemeMode.value, ThemeMode.dark);
    SharedPreferences.setMockInitialValues({'theme_mode': 'sepia'});
    await loadThemeMode();
    expect(appThemeMode.value, ThemeMode.system);
  });

  test('切换外观后写入本机，重新打开 App 读回的就是切换后的值', () async {
    SharedPreferences.setMockInitialValues({});
    persistThemeMode();
    appThemeMode.value = ThemeMode.dark;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'dark',
    );
    appThemeMode.value = ThemeMode.light;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'light');
    // 重新打开 App：从本机读回（读取逻辑见上一个用例）
    SharedPreferences.setMockInitialValues({
      'theme_mode': prefs.getString('theme_mode')!,
    });
    await loadThemeMode();
    expect(appThemeMode.value, ThemeMode.light);
  });
}
