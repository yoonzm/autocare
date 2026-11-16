import 'package:autocare_merchant/pages/inventory/expiry_sheet.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_in_line_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _product(String id, String name, {bool shelf = false}) => {
  'id': id,
  'name': name,
  'unit': '瓶',
  'stock': 6,
  'safe': 1,
  'cost': 168,
  'shelf_life': shelf,
};

void main() {
  testWidgets('入库明细：启用保质期的商品显示必填到期日，其余显示自动生成批次', (t) async {
    final c = InventoryController(
      'in',
      [_product('a', '9H 陶瓷镀晶液', shelf: true), _product('b', '玻璃水')],
      {},
      null,
      null,
    );
    addTearDown(c.dispose);
    c.lines = [
      {'id': 'a', 'quantity': 10, 'cost': 168},
      {'id': 'b', 'quantity': 2, 'cost': 20},
    ];
    await t.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                StockInLineTemplate(c: c, line: c.lines[0]),
                StockInLineTemplate(c: c, line: c.lines[1]),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('到期日'), findsOneWidget);
    expect(find.text('请选择'), findsOneWidget);
    expect(find.text('自动生成 · 无保质期'), findsOneWidget);
    expect(find.text('小计'), findsNWidgets(2));
    expect(find.text('数量'), findsNWidgets(2));
    c.lines[0]['expires_on'] = '2028-10-31';
    c.notifyListeners();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StockInLineTemplate(c: c, line: c.lines[0]),
        ),
      ),
    );
    expect(find.text('2028.10.31'), findsOneWidget);
    expect(find.text('请选择'), findsNothing);
  });

  testWidgets('到期日弹层：快捷按钮按入库日期推算，确定返回 YYYY-MM-DD', (t) async {
    await t.binding.setSurfaceSize(const Size(390, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    String? result;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => result = await pickExpiryDate(
                context,
                productName: '9H 陶瓷镀晶液',
                received: DateTime(2026, 10, 31),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('选择到期日'), findsOneWidget);
    expect(find.text('按入库日期 10.31 推算'), findsOneWidget);
    await t.tap(find.text('+24 个月'));
    await t.pump();
    expect(find.text('2028 年 10 月'), findsOneWidget);
    expect(find.textContaining('已选 2028.10.31'), findsOneWidget);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(result, '2028-10-31');
  });

  test('addMonths 月末取当月最后一天', () {
    expect(addMonths(DateTime(2026, 8, 31), 6), DateTime(2027, 2, 28));
    expect(addMonths(DateTime(2026, 10, 31), 24), DateTime(2028, 10, 31));
  });
}
