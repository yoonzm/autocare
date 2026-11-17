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
          .where(
            (w) =>
                w.selected && InventoryController.outReasons.contains(w.label),
          )
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

  testWidgets('损耗报废版式：报废原因默认破损，可改；备注占位；报废成本；没有关联信息', (t) async {
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
    expect(find.text('关联信息'), findsOneWidget);
    await t.tap(find.text('损耗报废'));
    await t.pumpAndSettle();
    expect(find.text('出库 · 损耗报废'), findsOneWidget);
    expect(find.text('关联信息'), findsNothing);
    expect(find.text('报废原因'), findsOneWidget);
    expect(c.payload['scrap_reason'], '破损');
    await t.tap(find.text('过期'));
    await t.pumpAndSettle();
    expect(c.payload['scrap_reason'], '过期');
    expect(find.text('选填，如：搬运时摔裂'), findsOneWidget);
    expect(find.text('报废成本'), findsOneWidget);
    expect(find.text('+ 添加商品'), findsOneWidget);
    expect(find.text('取消'), findsNothing); // 设计稿只有一个「确认出库」
    expect(c.outIssue(), isNull);
    // 切回施工领用：恢复关联信息
    await t.tap(find.text('施工领用'));
    await t.pumpAndSettle();
    expect(find.text('关联信息'), findsOneWidget);
  });

  testWidgets('退回供应商版式：供应商必填、应退金额记录；退款开支暂未开放不假装成功', (t) async {
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
    await t.tap(find.text('退回供应商'));
    await t.pumpAndSettle();
    expect(find.text('出库 · 退回供应商'), findsOneWidget);
    expect(find.text('请选择供应商'), findsOneWidget);
    expect(c.outIssue(), '请选择供应商');
    c.payload['supplier'] = '蓝盾膜业';
    c.changed();
    await t.pumpAndSettle();
    expect(c.outIssue(), isNull);
    await t.enterText(find.byType(TextField).first, '1280');
    expect(c.payload['refund_amount'], 1280);
    expect(find.text('暂未开放：开支暂不支持负数'), findsOneWidget);
  });
}
