import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSwitchValue;
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_in_live_template.dart';

import 'members_test.dart' show MemberFakeApi;

class FreightApi extends MemberFakeApi {
  num? lastFreight;
  final lastAsks = <String>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_last_freight') {
      lastAsks.add('${body['supplier']}');
      return {'freight': lastFreight};
    }
    if (body['action'] == 'inventory_quote') {
      return {
        'item': {'subtotal': 15960, 'total': 15960},
      };
    }
    return super.invoke(body, requestId: requestId);
  }
}

const id1 = '10000000-0000-0000-0000-000000000001';
final product = <String, dynamic>{
  'id': id1,
  'name': '9H 陶瓷镀晶液',
  'category': '镀晶',
  'unit': '瓶',
  'stock': 6,
  'safe': 2,
  'cost': 168,
  'version': 1,
};

Future<InventoryController> open(WidgetTester t, FreightApi api) async {
  merchantApi = api;
  t.view.physicalSize = const Size(390, 1800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  final c = InventoryController('in', [product], {}, null, id1);
  c.payload['supplier'] = '蓝盾膜业';
  c.quote = {'subtotal': 15960, 'total': 15960};
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
  late MerchantApi original;
  setUp(() => original = merchantApi);
  tearDown(() => merchantApi = original);

  testWidgets('运费弹层：快捷项、开关、实时应付合计；确定后回写并显示「计入成本」', (t) async {
    final api = FreightApi()..lastFreight = 120;
    final c = await open(t, api);
    expect(c.freightLabel, '¥0.00');
    expect(find.text('计入成本'), findsNothing);

    await t.tap(find.text('运费').first);
    await t.pumpAndSettle();
    expect(find.text('本单的运输费用，计入应付合计'), findsOneWidget);
    expect(api.lastAsks, ['蓝盾膜业']);
    expect(find.text('无运费'), findsOneWidget);
    expect(find.text('上次 ¥120.00'), findsOneWidget);
    expect(find.text('运费计入商品成本'), findsOneWidget);
    expect(find.text('¥15,960.00'), findsWidgets);

    await t.tap(find.text('上次 ¥120.00'));
    await t.pump();
    expect(find.text('¥16,080.00'), findsWidgets);

    await t.tap(find.byType(HSwitchValue).last);
    await t.pump();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(c.payload['freight'], 120);
    expect(c.payload['freight_to_cost'], true);
    expect(find.text('计入成本'), findsOneWidget);
    expect(c.freightLabel, '¥120.00');
  });

  testWidgets('没有上次运费不显示快捷项；无运费清零且不计入成本；最大 99999.99', (t) async {
    final api = FreightApi();
    final c = await open(t, api);
    c.payload['freight'] = 50;
    c.payload['freight_to_cost'] = true;
    c.changed();
    await t.pumpAndSettle();
    expect(find.text('计入成本'), findsOneWidget);

    await t.tap(find.text('运费').first);
    await t.pumpAndSettle();
    expect(find.textContaining('上次 ¥'), findsNothing);

    await t.enterText(find.byType(TextField).last, '999999');
    await t.pump();
    expect(
      t.widget<TextField>(find.byType(TextField).last).controller!.text,
      '99999.99',
    );

    await t.tap(find.text('无运费'));
    await t.pump();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(c.payload['freight'], 0);
    expect(c.payload['freight_to_cost'], false);
    expect(find.text('计入成本'), findsNothing);
  });
}
