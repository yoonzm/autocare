import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('浅色与深色令牌取自设计稿', () {
    const l = AppTokens.light;
    const d = AppTokens.dark;
    expect(l.primary, const Color(0xFF0485F7));
    expect(l.ink, const Color(0xFF18181B));
    expect(l.bg, const Color(0xFFF4F4F5));
    expect(l.surface, const Color(0xFFFFFFFF));
    expect(l.line, const Color(0xFFEFEFF1));
    expect(l.ok.fg, const Color(0xFF2B7745));
    expect(l.danger.bg, const Color(0xFFFFE1E2));
    expect(d.bg, const Color(0xFF09090B));
    expect(d.surface, const Color(0xFF18181B));
    expect(d.ink, const Color(0xFFFAFAFA));
    expect(d.primary, l.primary, reason: '主色在深色下不变');
    expect(d.gold, l.gold, reason: '品牌金色保持不变');
  });

  test('字号：size / lineHeight / weight', () {
    const t = AppTokens.light;
    expect([t.display.fontSize, t.display.height! * t.display.fontSize!], [32, 38]);
    expect(t.display.fontWeight, FontWeight.w600);
    expect([t.page.fontSize, t.page.height! * 17], [17, 24]);
    expect(t.body.fontWeight, FontWeight.w500);
    expect(t.caption.fontWeight, FontWeight.w400);
    expect(t.micro.fontSize, 11);
  });

  test('圆角与间距刻度', () {
    expect(
      [
        AppRadius.tag,
        AppRadius.tile,
        AppRadius.field,
        AppRadius.inset,
        AppRadius.block,
        AppRadius.card,
        AppRadius.hero,
        AppRadius.sheet,
      ],
      [9, 12, 14, 16, 20, 24, 28, 32],
    );
    expect(AppSpacing.pageGutter, 20);
    expect(AppSpacing.minTap, 44);
  });

  test('卡片阴影：浅色三层，深色改为 1px 细描边', () {
    expect(AppTokens.light.cardShadow.length, 3);
    expect(AppTokens.dark.cardShadow.length, 1);
    expect(AppTokens.dark.cardShadow.single.spreadRadius, 1);
  });

  testWidgets('AppTokens.of：优先主题扩展，否则按亮度', (t) async {
    late AppTokens fromBrightness;
    late AppTokens fromExtension;
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.dark),
        home: Builder(
          builder: (context) {
            fromBrightness = AppTokens.of(context);
            return Theme(
              data: Theme.of(context).copyWith(extensions: [AppTokens.light]),
              child: Builder(
                builder: (inner) {
                  fromExtension = AppTokens.of(inner);
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      ),
    );
    expect(fromBrightness.darkMode, isTrue);
    expect(fromExtension.darkMode, isFalse);
  });
}
