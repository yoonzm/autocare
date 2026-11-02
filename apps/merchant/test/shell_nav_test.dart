import 'package:autocare_merchant/pages/shell.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('底部导航中间的圆形按钮是“扫码找会员”，点击进入扫码页（不再是开单收银）', (t) async {
    navTracker.stack.clear();
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final sem = t.ensureSemantics();
    await t.pumpWidget(
      MaterialApp(navigatorObservers: [navTracker], home: const Shell()),
    );
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('开单收银'), findsNothing);
    await t.tap(find.bySemanticsLabel('扫码找会员'));
    await t.pumpAndSettle();
    expect(navTracker.has('FindScanPlate'), isTrue);
    sem.dispose();
    navTracker.stack.clear();
  });
}
