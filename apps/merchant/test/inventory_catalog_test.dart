import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/widgets/inventory_bindings.dart';
import 'package:autocare_merchant/pages/inventory_supplier_page.dart';
import 'package:autocare_merchant/theme.dart';

Future<void> capture(WidgetTester tester, String name) async {
  const path = String.fromEnvironment('INVENTORY_RENDER');
  if (path.isEmpty) return;
  await tester.runAsync(() async {
    final boundary = tester.firstRenderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary),
    );
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(path).create(recursive: true);
    await File('$path/$name.png').writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('product editor sections and required fields ($dark)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      C.dark = dark;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: const InventoryProductEditor(),
        ),
      );
      await tester.pumpAndSettle();
      await capture(tester, 'product-$dark');
      expect(find.text('基本信息'), findsOneWidget);
      expect(find.text('不填则系统自动生成'), findsOneWidget);
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();
      expect(find.text('请填写商品名称 *'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('需要管理保质期'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('supplier required name is validated without a request', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: InventorySupplierEditor()));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('请填写供应商名称'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
