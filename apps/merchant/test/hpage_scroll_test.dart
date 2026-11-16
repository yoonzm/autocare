import 'package:autocare_merchant/kit/kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpPage(WidgetTester t, double contentHeight) async {
  t.view.physicalSize = const Size(390, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      home: HPage(
        bg: Colors.white,
        flow: SizedBox(height: contentHeight, width: double.infinity),
      ),
    ),
  );
}

void main() {
  testWidgets('内容不足一屏时页面不可滚动', (t) async {
    await pumpPage(t, 300);
    final scroll = t.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, 0);
  });

  testWidgets('内容超过一屏时才可滚动，滚动范围等于超出的高度', (t) async {
    await pumpPage(t, 1000);
    final scroll = t.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, 200);
  });
}
