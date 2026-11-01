import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qimei_guanjia/pages/gen/gen_routes.dart';

/// 所有由设计稿生成的页面都能构建并布局；忽略测试字体导致的文字溢出。
void main() {
  sheetTests();
  for (final e in genRoutes.entries) {
    testWidgets('gen page ${e.key}', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.exceptionAsString());
      addTearDown(() => FlutterError.onError = old);
      await tester.pumpWidget(MaterialApp(home: Builder(builder: e.value)));
      await tester.pump(const Duration(milliseconds: 100));
      final real = errors.where((m) => !m.contains('overflowed')).toList();
      expect(real, isEmpty, reason: real.join('\n'));
    });
  }
}

/// 设计稿里叠在其他页面上的界面，作为底部弹层单独生成。
void sheetTests() {
  for (final e in genSheets.entries) {
    testWidgets('gen sheet ${e.key}', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final errors = <String>[];
      final old = FlutterError.onError;
      FlutterError.onError = (d) => errors.add(d.exceptionAsString());
      addTearDown(() => FlutterError.onError = old);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: Builder(builder: e.value)),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final real = errors.where((m) => !m.contains('overflowed')).toList();
      expect(real, isEmpty, reason: real.join('\n'));
    });
  }
}
