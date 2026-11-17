import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart';
import 'package:autocare_merchant/pages/inventory/stock_out_live_template.dart';
import 'package:autocare_merchant/pages/inventory/stock_out_pickers.dart'
    show startedText;

import 'members_test.dart' show MemberFakeApi;

class AssignApi extends MemberFakeApi {
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_assignments') {
      return {
        'technicians': [
          {'id': 't1', 'name': '老周', 'skills': '镀晶 · 贴膜', 'status': 'busy'},
          {'id': 't2', 'name': '小陈', 'skills': '贴膜', 'status': 'idle'},
        ],
        'workorders': [
          {
            'id': 'w1',
            'plate': '沪A·8K29M',
            'service': '镀晶养护',
            'technician_id': 't1',
            'technician': '老周',
            'started_at': DateTime.now().toUtc().toIso8601String(),
          },
        ],
        'orders': [],
      };
    }
    return super.invoke(body, requestId: requestId);
  }
}

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

/// 打开选择器：数据请求带最短加载时间（不是动画帧），先走过它再等弹层动画。
Future<void> open(WidgetTester t, String row) async {
  await t.tap(find.text(row));
  await t.pump(const Duration(seconds: 1));
  await t.pumpAndSettle();
}

void main() {
  late MerchantApi original;
  setUp(() => original = merchantApi);
  tearDown(() => merchantApi = original);

  test('开始时间：今天显示「今天 14:20」，其他日子显示「11.16 14:20」（北京时间）', () {
    final now = DateTime.utc(2026, 11, 17, 8); // 北京 16:00
    expect(startedText('2026-11-17T06:20:00Z', now), '今天 14:20');
    expect(startedText('2026-11-16T06:20:00Z', now), '11.16 14:20');
    expect(startedText('', now), '');
  });

  testWidgets('关联工单 / 领用技师：设计稿弹层，选中、自动带入技师、清除', (t) async {
    merchantApi = AssignApi();
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
    expect(find.text('未关联'), findsOneWidget);
    expect(find.text('未指定'), findsOneWidget);
    expect(find.text('未关联工单，仅记录出库成本'), findsOneWidget);

    // 选工单：技师自动带入
    await open(t, '关联工单');
    expect(find.text('选择工单'), findsOneWidget);
    expect(find.text('进行中的工单'), findsOneWidget);
    expect(find.text('选中工单后，领用技师会自动带入该工单的技师，可再修改。'), findsOneWidget);
    expect(find.textContaining('今天'), findsOneWidget);
    await t.tap(find.text('镀晶养护'));
    await t.pumpAndSettle();
    expect(c.payload['workorder_id'], 'w1');
    expect(c.payload['workorder'], '沪A·8K29M 镀晶养护');
    expect(c.payload['technician_id'], 't1');
    expect(find.text('沪A·8K29M 镀晶养护'), findsOneWidget);
    expect(find.text('将计入该工单的成本核算'), findsOneWidget);

    // 技师可以再改；列表有状态和擅长
    await open(t, '领用技师');
    expect(find.text('选择技师'), findsOneWidget);
    expect(find.text('施工中'), findsOneWidget);
    expect(find.text('空闲'), findsOneWidget);
    expect(find.text('镀晶 · 贴膜'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '陈');
    await t.pump();
    expect(find.text('老周'), findsOneWidget); // 只剩页面上已选的技师，列表里被过滤掉
    await t.enterText(find.byType(TextField).last, '没有这个人');
    await t.pump();
    expect(find.text('没有找到技师'), findsOneWidget);
    await t.enterText(find.byType(TextField).last, '陈');
    await t.pump();
    await t.tap(find.text('小陈'));
    await t.pumpAndSettle();
    expect(c.payload['technician_id'], 't2');
    expect(c.payload['technician'], '小陈');

    // 清除工单：技师不清除
    await open(t, '关联工单');
    await t.tap(find.text('清除'));
    await t.pumpAndSettle();
    expect(c.payload['workorder_id'], isNull);
    expect(c.payload['technician'], '小陈');
    expect(find.text('未关联'), findsOneWidget);
    expect(find.text('未关联工单，仅记录出库成本'), findsOneWidget);

    // 清除技师
    await open(t, '领用技师');
    await t.tap(find.text('清除'));
    await t.pumpAndSettle();
    expect(c.payload['technician_id'], isNull);
    expect(find.text('未指定'), findsOneWidget);
  });
}
