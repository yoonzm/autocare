import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory/inventory_live_page.dart';

import 'members_test.dart' show MemberFakeApi, phone;

Map<String, dynamic> _p(
  String id,
  String name,
  String cat,
  num stock,
  num safe,
  String supplier,
) => {
  'id': id,
  'name': name,
  'category': cat,
  'unit': '瓶',
  'stock': stock,
  'safe': safe,
  'cost': 10,
  'location': '',
  'sku': 'SKU-$id',
  'specification': '',
  'supplier': supplier,
  'expiring': false,
  'version': 0,
};

class _Api extends MemberFakeApi {
  final suppliers = <Map<String, dynamic>>[
    {'name': '蓝盾膜业', 'contact': '联系人甲', 'phone': '13900001111'},
    {'name': '速洁化工', 'contact': '联系人乙', 'phone': '13900002222'},
  ];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_options') return {'suppliers': suppliers};
    if (body['action'] == 'inventory_supplier_save') {
      final item = Map<String, dynamic>.from(body['payload']);
      suppliers.add(item);
      return {'item': item};
    }
    if (body['action'] == 'inventory_list') {
      return {
        'items': [
          _p('a', '镀晶剂', '镀晶', 2, 5, '蓝盾膜业'),
          _p('b', '玻璃水', '洗护', 9, 3, '速洁化工'),
          _p('c', '改色膜', '贴膜', 9, 3, '蓝盾膜业'),
        ],
      };
    }
    if (body['action'] == 'inventory_draft') return {'item': null};
    return super.invoke(body, requestId: requestId);
  }
}

void main() {
  testWidgets('入库：商品选择是设计稿的多选弹层（搜索 / 分类 / 低库存 / 计数按钮）', (t) async {
    merchantApi = _Api();
    phone(t);
    await t.pumpWidget(const MaterialApp(home: InventoryLivePage(mode: 'in')));
    await t.pumpAndSettle();
    await t.tap(find.text('添加商品').first);
    await t.pumpAndSettle();
    expect(find.text('选择商品'), findsOneWidget);
    expect(find.text('低库存'), findsOneWidget);
    expect(find.text('找不到？新增商品'), findsOneWidget);
    // 没选商品时确定不可用。
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('选择商品'), findsOneWidget);
    // 分类过滤 + 搜索。
    await t.tap(find.text('洗护').last);
    await t.pumpAndSettle();
    expect(find.text('镀晶剂'), findsNothing);
    expect(find.text('玻璃水'), findsOneWidget);
    await t.tap(find.text('全部').last);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '改色');
    await t.pumpAndSettle();
    expect(find.text('玻璃水'), findsNothing);
    await t.enterText(find.byType(TextField), '');
    await t.pumpAndSettle();
    await t.tap(find.text('镀晶剂'));
    await t.tap(find.text('玻璃水'));
    await t.pumpAndSettle();
    expect(find.text('确定 · 添加 2 件'), findsOneWidget);
    await t.tap(find.text('确定 · 添加 2 件'));
    await t.pumpAndSettle();
    expect(find.text('选择商品'), findsNothing);
    expect(find.text('镀晶剂'), findsOneWidget);
    expect(find.text('玻璃水'), findsOneWidget);
  });

  testWidgets('入库：供应商选择是设计稿的单选弹层，新增供应商走独立页面', (t) async {
    merchantApi = _Api();
    phone(t);
    await t.pumpWidget(const MaterialApp(home: InventoryLivePage(mode: 'in')));
    await t.pumpAndSettle();
    await t.tap(find.text('请输入供应商'));
    await t.pumpAndSettle();
    expect(find.text('选择供应商'), findsOneWidget);
    expect(find.text('蓝盾膜业'), findsOneWidget); // 同一供应商只出现一次
    expect(find.text('速洁化工'), findsOneWidget);
    await t.tap(find.text('速洁化工'));
    await t.pump();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('速洁化工'), findsOneWidget);
    expect(find.text('选择供应商'), findsNothing);

    await t.tap(find.text('速洁化工'));
    await t.pumpAndSettle();
    await t.tap(find.text('+ 新增供应商'));
    await t.pumpAndSettle();
    expect(find.text('新增供应商'), findsOneWidget);
    // 名称没填时保存无效。
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('新增供应商'), findsOneWidget);
    await t.enterText(find.byType(TextField).first, '新供应商');
    await t.pumpAndSettle();
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('选择供应商'), findsOneWidget);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('新供应商'), findsOneWidget);
  });
}
