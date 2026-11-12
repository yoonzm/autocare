import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 在指定亮度下渲染一个组件。
Future<void> pump(
  WidgetTester t,
  Widget child, {
  Brightness brightness = Brightness.light,
  Size size = const Size(390, 844),
}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        splashFactory: NoSplash.splashFactory,
        extensions: [AppTokens.forBrightness(brightness)],
      ),
      home: Scaffold(
        backgroundColor: AppTokens.forBrightness(brightness).bg,
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
}

/// 取某个文字所在的 [Container] 背景色（按钮、标签等）。
Color? backgroundBehind(WidgetTester t, String text) {
  final container = t.widget<Container>(
    find.ancestor(of: find.text(text), matching: find.byType(Container)).first,
  );
  final decoration = container.decoration;
  return decoration is BoxDecoration ? decoration.color : container.color;
}
