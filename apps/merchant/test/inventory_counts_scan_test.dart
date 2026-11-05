import 'dart:io';

import 'package:flutter/services.dart';

import 'inventory_catalog_test.dart' show capture;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory_count_page.dart';
import 'package:autocare_merchant/pages/inventory_scan_page.dart';
import 'package:autocare_merchant/theme.dart';

const cid = '10000000-0000-0000-0000-000000000001';

class CountApi extends MerchantApi {
  bool blind = true;
  final calls = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> lines = [
    {
      'id': 'a',
      'name': '测试盘点商品',
      'unit': '卷',
      'location': 'A-01',
      'allow_decimal': true,
      'quantity': null,
    },
  ];
  int revision = 0;
  Map<String, dynamic> get doc => {
    'id': cid,
    'scope': 'all',
    'scope_value': '',
    'status': 'active',
    'blind': blind,
    'revision': revision,
    'lines': lines.map((l) => {...l, if (!blind) 'stock': 3}).toList(),
  };
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    calls.add(body);
    switch (body['action']) {
      case 'inventory_count_get':
        return {'item': doc};
      case 'inventory_count_save':
        lines = [
          {...lines.first, 'quantity': body['lines'][0]['quantity']},
        ];
        revision++;
        return {'item': doc};
      case 'inventory_count_review':
        return {
          'item': {
            ...doc,
            'result': {
              'counted': 1,
              'total': 1,
              'positive': 0,
              'negative': -30,
              'net': -30,
              'differences': [
                {
                  'id': 'a',
                  'name': '测试盘点商品',
                  'unit': '卷',
                  'stock': 3,
                  'quantity': 0,
                  'difference': -3,
                  'amount': -30,
                },
              ],
            },
          },
        };
      case 'inventory_count_post':
        return {
          'item': {...doc, 'status': 'posted'},
        };
      case 'inventory_scan':
        return {
          'item': {'id': 'a', 'name': '扫码商品', 'sku': body['code']},
        };
      case 'inventory_list':
        return {
          'items': [
            {
              'id': 'a',
              'name': '测试盘点商品',
              'category': '贴膜',
              'location': 'A-01',
              'active': true,
            },
          ],
        };
      case 'inventory_count_list':
        return {'active': [], 'items': []};
      default:
        throw Exception('Unexpected ${body['action']}');
    }
  }
}

void main() {
  setUpAll(() async {
    const path = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc';
    if (File(path).existsSync()) {
      await (FontLoader('InventoryReview')..addFont(
            Future.value(File(path).readAsBytesSync().buffer.asByteData()),
          ))
          .load();
    }
  });
  late MerchantApi previous;
  late CountApi api;
  setUp(() {
    previous = merchantApi;
    api = CountApi();
    merchantApi = api;
  });
  tearDown(() {
    merchantApi = previous;
    debugDefaultTargetPlatformOverride = null;
  });
  Future<void> screen(WidgetTester tester, Widget page) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    C.dark = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildTheme().copyWith(
          textTheme: buildTheme().textTheme.apply(
            fontFamily: "InventoryReview",
          ),
        ),
        home: page,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'blind count saves zero and reviews server totals before posting',
    (tester) async {
      await screen(tester, const InventoryCountPage(id: cid));
      await capture(tester, 'count-entry');
      expect(find.textContaining('系统 3'), findsNothing);
      await tester.enterText(find.byType(TextFormField), '0');
      await tester.pump();
      await tester.tap(find.text('暂存'));
      await tester.pumpAndSettle();
      expect(api.calls.last['action'], 'inventory_count_save');
      expect(api.calls.last['lines'][0]['quantity'], 0);
      await tester.tap(find.text('提交盘点（已盘 1 项）'));
      await tester.pumpAndSettle();
      await capture(tester, 'count-result');
      expect(find.text('盘点结果'), findsOneWidget);
      expect(find.text('系统 3 · 实盘 0'), findsOneWidget);
      expect(find.text('-¥30.00'), findsNWidgets(2));
      expect(
        api.calls.where((c) => c['action'] == 'inventory_count_post'),
        isEmpty,
      );
      await tester.tap(find.text('确认提交'));
      await tester.pumpAndSettle();
      expect(api.calls.last['action'], 'inventory_count_post');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('count setup switches category/location and pause options', (
    tester,
  ) async {
    await screen(tester, const InventoryCountStartPage());
    await capture(tester, 'count-start');
    await tester.tap(find.text('按货位'));
    await tester.pumpAndSettle();
    expect(find.text('请选择货位'), findsOneWidget);
    expect(find.text('盲盘'), findsOneWidget);
    expect(find.text('盘点期间暂停出入库'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('manual scan sends exact code and returns real lookup result', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    await screen(tester, const InventoryScanPage());
    await tester.tap(find.text('手动输入编码'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'SKU-123');
    await tester.tap(find.text('查询'));
    await tester.pumpAndSettle();
    expect(api.calls.last['action'], 'inventory_scan');
    expect(api.calls.last['code'], 'SKU-123');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
    expect(tester.takeException(), isNull);
  });
}
