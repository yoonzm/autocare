import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory/inventory_page.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class _InventoryApi extends MemberFakeApi {
  int categories = 0;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] != 'inventory_list') {
      return super.invoke(
        body,
        timeout: timeout ?? const Duration(seconds: 30),
        requestId: requestId,
      );
    }
    return {
      'items': [
        for (var i = 0; i < categories; i++)
          {
            'id': 'p$i',
            'name': '商品$i',
            'category': '分类$i',
            'unit': '个',
            'stock': 2,
            'safe': 1,
            'cost': 10,
            'stock_value': 20,
          },
      ],
    };
  }
}

void main() {
  testWidgets('库存动态分类支持仅全部和超过五项，并可横滑筛选', (t) async {
    final original = merchantApi;
    final api = _InventoryApi();
    merchantApi = api;
    addTearDown(() => merchantApi = original);
    phone(t);
    for (final count in [0, 7]) {
      api.categories = count;
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(const MaterialApp(home: InventoryPage()));
      await t.pumpAndSettle();
      final group = find.byType(AppChoiceGroup<int>);
      expect(group, findsOneWidget);
      expect(t.widget<AppChoiceGroup<int>>(group).items.length, count + 1);
      if (count > 0) {
        await t.drag(group, const Offset(-800, 0));
        await t.pumpAndSettle();
        await t.tap(find.text('分类6').first);
        await t.pumpAndSettle();
        expect(t.widget<AppChoiceGroup<int>>(group).selected, 7);
        expect(find.text('商品6'), findsOneWidget);
        expect(find.text('商品0'), findsNothing);
      }
      expect(t.takeException(), isNull);
    }
  });
  test('商户分段选择统一组件，旧封装与内联分段标记不再出现', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      expect(
        RegExp(r'\b(?:HSegmented|Segmented)\s*\(').hasMatch(source),
        isFalse,
        reason: file.path,
      );
      expect(source.contains('segment: true'), isFalse, reason: file.path);
    }
  });
}
