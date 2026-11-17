import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_in_live_template.dart';

Map<String, dynamic> product(
  String id, {
  num cost = 0,
  num? lastCost,
  bool decimal = true,
}) => {
  'id': id,
  'name': '9H 陶瓷镀晶液',
  'category': '镀晶',
  'unit': '瓶',
  'stock': 6,
  'safe': 2,
  'cost': cost,
  'last_cost': lastCost,
  'allow_decimal': decimal,
  'version': 1,
  'shelf_life': false,
};

const id1 = '10000000-0000-0000-0000-000000000001';

Future<InventoryController> open(
  WidgetTester t,
  Map<String, dynamic> p, {
  num quantity = 10,
}) async {
  t.view.physicalSize = const Size(390, 1200);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  final c = InventoryController('in', [p], {}, null, p['id'] as String);
  c.lines.first['quantity'] = quantity;
  await t.pumpWidget(
    MaterialApp(
      home: ListenableBuilder(
        listenable: c,
        builder: (_, _) => StockInLiveTemplate(c: c),
      ),
    ),
  );
  await t.pumpAndSettle();
  return c;
}

void main() {
  test('默认单价：最近一次入库单价 > 商品成本价 > 留空（成本 0 不算）', () {
    expect(defaultInboundCost(product(id1, cost: 168, lastCost: 160)), 160);
    expect(defaultInboundCost(product(id1, cost: 168)), 168);
    expect(defaultInboundCost(product(id1)), isNull);
    // 最近一次是赠品（0）也照实带出，由用户决定
    expect(defaultInboundCost(product(id1, cost: 168, lastCost: 0)), 0);
  });

  testWidgets('没有默认价：单价块显示「请输入」，不显示 ¥0.00，也不能提交', (t) async {
    final c = await open(t, product(id1));
    expect(find.text('请输入'), findsOneWidget);
    expect(find.text('—'), findsWidgets); // 小计也不显示 ¥0.00
    expect(c.lines.first['cost'], isNull);
    expect(c.inboundLineIssue(), contains('入库单价'));
    expect(c.inboundLineIssue(draft: true), isNull);
  });

  testWidgets('修改单价弹层：快捷项、实时小计；输入 0 出赠品提示；留空不能确定', (t) async {
    final c = await open(t, product(id1, cost: 168, lastCost: 160));
    expect(find.text('¥160.00'), findsWidgets);
    await t.tap(find.text('单价'));
    await t.pumpAndSettle();
    expect(find.text('修改单价'), findsWidgets);
    expect(find.text('9H 陶瓷镀晶液 · 本次入库 10 瓶'), findsOneWidget);
    expect(find.text('上次进价 ¥160.00'), findsOneWidget);
    expect(find.text('商品成本价 ¥168.00'), findsOneWidget);
    expect(find.textContaining('10 瓶 × ¥160.00 = '), findsOneWidget);

    await t.tap(find.text('商品成本价 ¥168.00'));
    await t.pump();
    expect(find.textContaining('10 瓶 × ¥168.00 = '), findsOneWidget);
    expect(find.textContaining('¥1,680.00', findRichText: true), findsWidgets);

    await t.enterText(find.byType(TextField).last, '0');
    await t.pump();
    expect(find.textContaining('将按赠品入库'), findsOneWidget);
    expect(find.text('确定，按赠品入库'), findsOneWidget);

    await t.enterText(find.byType(TextField).last, '');
    await t.pump();
    final ok = find.widgetWithText(InkWell, '确定');
    expect(ok, findsNothing); // 留空时按钮是禁用样式，点了也没有反应
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('修改单价'), findsWidgets);

    await t.enterText(find.byType(TextField).last, '12.5');
    await t.pump();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(c.lines.first['cost'], 12.5);
    expect(find.text('¥12.50'), findsOneWidget);
    expect(find.text('¥125.00'), findsOneWidget);
  });

  testWidgets('单价 0：确认后该行标记赠品，可以提交', (t) async {
    final c = await open(t, product(id1, cost: 168));
    await t.tap(find.text('单价'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '0');
    await t.pump();
    await t.tap(find.text('确定，按赠品入库'));
    await t.pumpAndSettle();
    expect(c.lines.first['cost'], 0);
    expect(find.text('赠品'), findsOneWidget);
    expect(c.inboundLineIssue(), isNull);
  });

  testWidgets('数量是输入框：直接输入，最大 9999；不允许小数的商品只能填整数', (t) async {
    final c = await open(t, product(id1, cost: 10, decimal: false));
    final field = find.byType(TextField).first;
    await t.enterText(field, '12');
    expect(c.lines.first['quantity'], 12);
    await t.enterText(field, '99999');
    await t.pump();
    expect(c.lines.first['quantity'], 9999);
    await t.enterText(field, '3.5');
    await t.pump();
    expect(c.lines.first['quantity'], 3); // 不允许小数：小数点及其后内容被过滤
    await t.enterText(field, '');
    await t.pump();
    expect(c.lines.first['quantity'], isNull);
    expect(c.inboundLineIssue(), contains('数量'));
    // 加减按钮仍然可用，并同步到输入框
    c.lines.first['quantity'] = 5;
    c.adjust(c.lines.first, 1);
    await t.pump();
    expect(c.lines.first['quantity'], 6);
    expect(find.text('6'), findsOneWidget);
  });
}
