import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/product_detail_live_template.dart';

Map<String, dynamic> detail({
  num stock = 2,
  num safe = 5,
  String spec = '',
  String location = '',
}) => {
  'id': '10000000-0000-0000-0000-000000000001',
  'name': '9H 陶瓷镀晶液 50ml',
  'sku':
      'SKU-4f634540b4aa4e05955bd53926d2e6f7-4f634540b4aa4e05955bd53926d2e6f7',
  'category': '镀晶',
  'unit': '瓶',
  'stock': stock,
  'safe': safe,
  'cost': 2380,
  'version': 1,
  'specification': spec,
  'location': location,
  'supplier': '蓝盾膜业',
  'batches': [
    {
      'id': '30000000-0000-0000-0000-000000000001',
      'quantity': 2,
      'cost': 2380,
      'received_on': '2026-11-03',
      'expires_on': null,
    },
  ],
  'movements': [],
  'month_used': 1,
};

InventoryController ctrl(Map<String, dynamic> d) =>
    InventoryController('detail', [], d, null, d['id'] as String);

void main() {
  test('库存状态：低于安全库存 / 库存充足 / 没设置安全库存', () {
    final low = ctrl(detail(stock: 2, safe: 5));
    expect(low.stockState, 'low');
    expect(low.stockStatusLabel, '低于安全库存');
    expect(low.stockRatio, closeTo(0.4, 1e-9)); // 设计稿：2/5 画 40%
    final ok = ctrl(detail(stock: 8, safe: 5));
    expect(ok.stockState, 'ok');
    expect(ok.stockStatusLabel, '库存充足');
    expect(ok.stockRatio, 1);
    final unset = ctrl(detail(stock: 20, safe: 0));
    expect(unset.stockState, 'unset');
    expect(unset.stockStatusLabel, '未设置安全库存');
    expect(unset.replenishLabel, '—');
  });

  test('建议补货：补到安全库存的 2 倍；金额带千分位；没填的规格、货位显示 —', () {
    final c = ctrl(detail(stock: 2, safe: 5));
    expect(c.replenishLabel, '8 瓶');
    expect(c.unitCostLabel, '¥2,380.00 / 瓶');
    expect(c.stockCostLabel, '¥4,760.00');
    expect(c.specificationLabel, '—');
    expect(c.locationLabel, '—');
    final filled = ctrl(detail(spec: '1.52m × 15m / 卷', location: 'A-02'));
    expect(filled.specificationLabel, '1.52m × 15m / 卷');
    expect(filled.locationLabel, 'A-02');
  });

  testWidgets('商品详情：状态标签随库存变化，长 SKU 不换行', (t) async {
    t.view.physicalSize = const Size(390, 1600);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    for (final (d, label) in [
      (detail(stock: 2, safe: 5), '低于安全库存'),
      (detail(stock: 8, safe: 5), '库存充足'),
      (detail(stock: 20, safe: 0), '未设置安全库存'),
    ]) {
      final c = ctrl(d);
      await t.pumpWidget(MaterialApp(home: ProductDetailLiveTemplate(c: c)));
      await t.pumpAndSettle();
      expect(find.text(label), findsOneWidget);
      expect(tester(t), isNull);
    }
  });
}

Object? tester(WidgetTester t) => t.takeException();
