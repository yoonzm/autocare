import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_in_live_template.dart';
import 'package:autocare_merchant/pages/inventory/stock_out_live_template.dart';
import 'package:autocare_merchant/pages/inventory/stock_check_live_template.dart';
import 'package:autocare_merchant/pages/inventory/product_detail_live_template.dart';
import 'package:autocare_merchant/theme.dart';

void main() {
  setUpAll(() async {
    const font = 'C:/Windows/Fonts/msyh.ttc';
    if (File(font).existsSync()) {
      final loader = FontLoader('InventoryTest')
        ..addFont(
          Future.value(File(font).readAsBytesSync().buffer.asByteData()),
        );
      await loader.load();
    }
  });
  final p = <String, dynamic>{
    'id': '10000000-0000-0000-0000-000000000001',
    'name': '测试库存商品',
    'category': '贴膜',
    'unit': '卷',
    'stock': 2.5,
    'safe': 5,
    'cost': 10,
    'version': 1,
    'sku': 'TEST-01',
    'specification': '测试规格',
    'location': 'A-01',
    'supplier': '测试供应商',
    'batches': [
      {
        'id': '30000000-0000-0000-0000-000000000001',
        'quantity': 2.5,
        'cost': 10,
        'received_on': '2026-11-03',
        'expires_on': null,
      },
    ],
    'movements': [
      for (final kind in ['in', 'out', 'check'])
        {
          'payload': {
            'kind': kind,
            'supplier': '测试供应商',
            'reason': '内部使用',
            'note': '实际流水',
          },
          'created_at': '2026-11-03T10:00:00Z',
          'before_stock': 2,
          'after_stock': kind == 'in' ? 3 : 1,
          'cost': 10,
        },
    ],
  };
  test(
    'count drafts retain uncounted products and preserve snapshot versions',
    () {
      final c = InventoryController(
        'check',
        [
          p,
          {...p, 'id': 'second'},
        ],
        {},
        {
          'id': 'draft',
          'revision': 2,
          'payload': {
            'lines': [
              {'id': p['id'], 'quantity': 0, 'version': 0},
            ],
          },
        },
        null,
      );
      expect(c.lines.length, 2);
      expect(c.counted.length, 1);
      expect(c.lines.first['version'], 0);
      expect(c.lines.last['quantity'], null);
      c.dispose();
    },
  );
  for (final dark in [false, true]) {
    for (final mode in ['in', 'out', 'check', 'detail']) {
      testWidgets(
        '$mode renders real fields without fixture text (${dark ? 'dark' : 'light'})',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          C.dark = dark;
          final c = InventoryController(
            mode,
            [p],
            mode == 'detail' ? p : {},
            null,
            p['id'],
          );
          final key = GlobalKey();
          Widget page() => switch (mode) {
            'in' => StockInLiveTemplate(c: c),
            'out' => StockOutLiveTemplate(c: c),
            'check' => StockCheckLiveTemplate(c: c),
            _ => ProductDetailLiveTemplate(c: c),
          };
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                fontFamily: 'InventoryTest',
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              home: RepaintBoundary(
                key: key,
                child: ListenableBuilder(
                  listenable: c,
                  builder: (_, _) => page(),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('TPU 隐形车衣 7.5mil'), findsNothing);
          expect(find.text('蓝盾膜业'), findsNothing);
          expect(find.text('测试库存商品'), findsOneWidget);
          if (mode == 'check') {
            expect(c.counted, isEmpty);
            await tester.enterText(find.byType(TextFormField), '0');
            await tester.pump();
            expect(c.counted.length, 1);
            expect(find.text('提交盘点（已盘 1 项）'), findsOneWidget);
          }
          const out = String.fromEnvironment('INVENTORY_RENDER');
          if (out.isNotEmpty) {
            await tester.runAsync(() async {
              final image =
                  await (key.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(out).create(recursive: true);
              await File('$out/$mode-${dark ? 'dark' : 'light'}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.pumpWidget(const SizedBox());
          c.dispose();
        },
      );
    }
  }
}
