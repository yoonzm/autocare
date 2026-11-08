import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/product_edit_live_page.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class _Api extends MemberFakeApi {
  final calls = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_create' ||
        body['action'] == 'inventory_update') {
      calls.add(body);
      return {
        'item': {...body, 'version': 1, 'stock': 0},
      };
    }
    return super.invoke(body, requestId: requestId);
  }
}

void main() {
  testWidgets('新增商品：路由是设计稿整页，必填项不全不发请求，保存按设计稿分类映射到后端分类', (t) async {
    final api = _Api();
    merchantApi = api;
    phone(t);
    expect(pageFor('ProductEdit'), isA<ProductEditLivePage>());
    await t.pumpWidget(const MaterialApp(home: ProductEditLivePage()));
    await t.pumpAndSettle();
    expect(find.text('新增商品'), findsOneWidget);
    expect(find.text('如：隐形车衣 TPU'), findsOneWidget);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.calls, isEmpty);

    await t.enterText(find.byType(TextField).first, '测试清洁剂');
    await t.tap(find.text('其他'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('「其他」分类暂未接通，请先选择其他分类'), findsWidgets);
    await t.tap(find.text('清洁用品'));
    await t.pump();
    await t.enterText(find.widgetWithText(TextField, '').at(2), '12.5');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.calls, hasLength(1));
    final c = api.calls.single;
    expect(c['action'], 'inventory_create');
    expect(c['name'], '测试清洁剂');
    expect(c['category'], '洗护');
    expect(c['unit'], '件');
    expect(c['cost'], 12.5);
  });

  testWidgets('编辑商品：回填现有资料，成本只读，保存走 inventory_update', (t) async {
    final api = _Api();
    merchantApi = api;
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        home: ProductEditLivePage(
          product: const {
            'id': 'a',
            'name': '镀晶剂',
            'category': '配件',
            'unit': '罐',
            'safe': 3,
            'location': 'A-02',
            'cost': 1280,
            'supplier': '蓝盾膜业',
            'specification': '',
            'sku': '',
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('编辑商品'), findsOneWidget);
    expect(find.text('罐'), findsWidgets); // 原有单位不在预设里，也保留为一个可选项
    expect(find.text('蓝盾膜业'), findsOneWidget);
    expect(find.text('¥ 1,280.00'), findsOneWidget);
    await t.ensureVisible(find.text('停用此商品'));
    await t.tap(find.text('停用此商品'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('商品停用暂未接通'), findsWidgets);
    await t.tap(find.text('保存修改'));
    await t.pumpAndSettle();
    final c = api.calls.single;
    expect(c['action'], 'inventory_update');
    expect(c['category'], '配件'); // 工具 <-> 配件
    expect(c['cost'], 1280);
    expect(c['supplier'], '蓝盾膜业');
  });
}
