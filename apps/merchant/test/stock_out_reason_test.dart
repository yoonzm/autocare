import 'package:autocare_ui_kit/autocare_ui_kit.dart' show AppChoiceChip;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_out_live_template.dart';

const id1 = '10000000-0000-0000-0000-000000000001';
final product = <String, dynamic>{
  'id': id1,
  'name': '中性洗车液 20L',
  'category': '洗护',
  'unit': '桶',
  'stock': 10,
  'safe': 2,
  'cost': 30,
  'version': 1,
};

void main() {
  testWidgets('出库类型：四个标签互斥，点谁谁选中，payload.reason 跟着变', (t) async {
    t.view.physicalSize = const Size(390, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final c = InventoryController('out', [product], {}, null, id1);
    await t.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: c,
          builder: (_, _) => StockOutLiveTemplate(c: c),
        ),
      ),
    );
    await t.pumpAndSettle();

    String selected() {
      final chips = t
          .widgetList<AppChoiceChip>(find.byType(AppChoiceChip))
          .where((w) => w.selected)
          .toList();
      expect(chips.length, 1);
      return chips.single.label;
    }

    expect(selected(), '施工领用');
    for (final r in ['损耗报废', '退回供应商', '内部使用', '施工领用']) {
      await t.tap(find.text(r));
      await t.pumpAndSettle();
      expect(selected(), r);
      expect(c.payload['reason'], r);
    }
  });
}
