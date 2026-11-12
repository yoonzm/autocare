import 'package:autocare_admin/theme.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => C.dark = false);

  for (final dark in [false, true]) {
    test('后台令牌 C 与组件库 AppTokens 一致（${dark ? '深色' : '浅色'}）', () {
      C.dark = dark;
      final t = AppTokens.forBrightness(dark ? Brightness.dark : Brightness.light);
      final pairs = <String, (Color, Color)>{
        'bg': (C.bg, t.bg),
        'card/surface': (C.card, t.surface),
        'inset': (C.inset, t.inset),
        'chip/fill': (C.chip, t.fill),
        'segment': (C.segment, t.segment),
        'line': (C.line, t.line),
        'stroke/fillStrong': (C.stroke, t.fillStrong),
        'ink': (C.ink, t.ink),
        'sub/inkSub': (C.sub, t.inkSub),
        'muted/inkMute': (C.muted, t.inkMute),
        'faint/inkFaint': (C.faint, t.inkFaint),
        'primary': (C.primary, t.primary),
        'primaryInk/primaryText': (C.primaryInk, t.primaryText),
        'primarySoft': (C.primarySoft, t.primarySoft),
        'greenInk/ok.fg': (C.greenInk, t.ok.fg),
        'greenSoft/ok.bg': (C.greenSoft, t.ok.bg),
        'amberInk/warn.fg': (C.amberInk, t.warn.fg),
        'amberSoft/warn.bg': (C.amberSoft, t.warn.bg),
        'redInk/danger.fg': (C.redInk, t.danger.fg),
        'redSoft/danger.bg': (C.redSoft, t.danger.bg),
        'violetInk/violet.fg': (C.violetInk, t.violet.fg),
        'violetSoft/violet.bg': (C.violetSoft, t.violet.bg),
        'gold': (C.gold, t.gold),
        'red/badge': (C.red, t.badge),
        'green/success': (C.green, t.success),
      };
      for (final e in pairs.entries) {
        expect(e.value.$1, e.value.$2, reason: e.key);
      }
    });
  }

  testWidgets('应用主题里注册了 AppTokens，随亮度切换', (tester) async {
    for (final b in [Brightness.light, Brightness.dark]) {
      expect(buildTheme(b).extension<AppTokens>()!.darkMode, b == Brightness.dark);
    }
  });
}
