import 'dart:io';

import 'package:autocare_merchant/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 卡片背景的同心圆要和设计稿的 SVG 一致：半径按画布缩放、每一圈颜色、描边宽度、小圆点；
/// 并且不能被卡片内边距截断（Stack 要 `Clip.none`）。
void main() {
  testWidgets('半径、描边宽度按 viewBox 缩放，每一圈可以单独上色', (t) async {
    const a = Color(0xFF3A3226), b = Color(0xFF2E2A24), c = Color(0xFF27272A);
    await t.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Rings(
            size: 190,
            viewBox: 240,
            radii: [60, 90, 118],
            colors: [a, b, c],
          ),
        ),
      ),
    );
    final k = 190 / 240;
    expect(
      find.byType(Rings),
      paints
        ..circle(x: 95, y: 95, radius: 60 * k, color: a, strokeWidth: 1.5 * k)
        ..circle(x: 95, y: 95, radius: 90 * k, color: b)
        ..circle(x: 95, y: 95, radius: 118 * k, color: c),
    );
  });

  testWidgets('登录页品牌区的圆点：画布里的 (180,100)，半径 5，实心', (t) async {
    await t.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Rings(
            size: 360,
            viewBox: 360,
            radii: [80, 120, 160],
            dot: (Offset(180, 100), 5, Color(0xFF0485F7)),
          ),
        ),
      ),
    );
    expect(
      find.byType(Rings),
      paints
        ..circle(radius: 80)
        ..circle(radius: 120)
        ..circle(radius: 160)
        ..circle(x: 180, y: 100, radius: 5, color: const Color(0xFF0485F7)),
    );
  });

  test('生成页里的同心圆装饰深色模式不换色（不能变成一圈亮白线）', () {
    final svgs = File('lib/pages/gen/svgs.dart').readAsStringSync();
    final rings = <String>{};
    for (final m in RegExp(
      r"static const (s\d+) =\s*'((?:[^'\\]|\\.)*)';",
    ).allMatches(svgs)) {
      final body = m.group(2)!;
      if (RegExp('<circle').allMatches(body).length >= 3 &&
          !body.contains('<path') &&
          !body.contains('<rect')) {
        rings.add(m.group(1)!);
      }
    }
    expect(rings, isNotEmpty);
    final bad = <String>[];
    for (final f in Directory('lib/pages/gen').listSync()) {
      if (f is! File || f.path.endsWith('svgs.dart')) continue;
      final src = f.readAsStringSync();
      for (final m in RegExp(
        r'dk\(\s*context,\s*Svgs\.(s\d+),\s*Svgs\.(s\d+)\s*\)',
      ).allMatches(src)) {
        if (rings.contains(m.group(1)) || rings.contains(m.group(2))) {
          bad.add('${f.path}: ${m.group(0)}');
        }
      }
    }
    expect(bad, isEmpty, reason: '同心圆装饰在深色模式下应使用同一个 SVG');
  });
}
