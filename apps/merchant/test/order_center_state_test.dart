import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/orders/order_detail_ref.dart';
import 'package:autocare_merchant/pages/orders/order_list_controller.dart';
import 'package:autocare_merchant/pages/orders/order_live_pages.dart';
import 'package:autocare_merchant/pages/orders/order_refund_controller.dart';

import 'orders_test.dart' show OrderApi;
import 'members_test.dart' show phone;
import 'wallet_state_test.dart' show RecordingApi;

class ControlledOrders extends OrderApi {
  final reads = <Completer<Map<String, dynamic>>>[];
  @override
  Future<Map<String, dynamic>> orderCenter(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    calls.add({'action': action, ...values});
    final read = Completer<Map<String, dynamic>>();
    reads.add(read);
    return read.future;
  }
}

Map<String, dynamic> feed(String id, {bool more = false}) => {
  'items': [
    {'kind': 'consume', 'id': id, 'at': '2026-11-12T01:00:00Z'},
  ],
  'summary': {'received': 42},
  'has_more': more,
};
Map<String, dynamic> refundable(String id, [String method = '储值余额']) => {
  'id': id,
  'kind': 'consume',
  'can_refund': true,
  'amount': 42,
  'payments': [
    {'label': method, 'amount': 42},
  ],
};

class RefundApi extends OrderApi {
  final writes = <Map<String, dynamic>>[];
  Completer<Map<String, dynamic>>? write;
  bool fail = true;
  @override
  Future<Map<String, dynamic>> refundOrder(
    String id,
    String reason, {
    String? requestId,
  }) async {
    writes.add({'id': id, 'reason': reason, 'requestId': requestId});
    if (write != null) return write!.future;
    if (fail) throw const AppError('稍后重试');
    return {'order_id': id};
  }
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
  });
  tearDown(() {
    merchantApi = original;
  });

  test('订单退款客户端将重试标识交给请求层', () async {
    final api = RecordingApi();
    await api.refundOrder('o1', '服务问题', requestId: 'retry-o1');
    expect(api.requests.single.id, 'retry-o1');
    expect(api.requests.single.body, {
      'action': 'order_refund',
      'id': 'o1',
      'reason': '服务问题',
    });
  });

  testWidgets('详情页改选订单后，晚到的旧详情不能覆盖新目标', (t) async {
    phone(t);
    final fixture = await OrderApi().orderCenter('detail');
    final api = ControlledOrders();
    merchantApi = api;
    Future<void> show(String id) async {
      await t.pumpWidget(
        MaterialApp(
          home: OrderDetailLivePage(
            order: OrderDetailRef(kind: 'consume', id: id),
          ),
        ),
      );
      await t.pump();
    }

    await show('old');
    await show('new');
    expect(api.calls.map((e) => e['id']), ['old', 'new']);
    api.reads[1].complete({...fixture, 'id': 'new', 'order_no': 'NEW-ORDER'});
    await t.pumpAndSettle();
    expect(find.textContaining('NEW-ORDER'), findsOneWidget);
    api.reads[0].complete({...fixture, 'id': 'old', 'order_no': 'OLD-ORDER'});
    await t.pumpAndSettle();
    expect(find.textContaining('NEW-ORDER'), findsOneWidget);
    expect(find.textContaining('OLD-ORDER'), findsNothing);
  });

  test('两个列表独立；筛选后的旧分页不能覆盖新结果或释放新加载锁', () async {
    final api = ControlledOrders();
    merchantApi = api;
    final a = OrderListController(), b = OrderListController();
    final first = a.load(), second = b.load();
    api.reads[0].complete(feed('a', more: true));
    api.reads[1].complete(feed('b'));
    await Future.wait([first, second]);
    final more = a.loadMore();
    a.setType(1);
    api.reads[2].complete(feed('old'));
    await more;
    expect(a.loading, isTrue);
    expect(a.items!.single['id'], 'a');
    api.reads[3].complete(feed('new'));
    await Future<void>.delayed(Duration.zero);
    expect(a.items!.single['id'], 'new');
    expect(b.items!.single['id'], 'b');
    expect(b.typeIndex, 0);
    a.dispose();
    b.dispose();
  });

  testWidgets('搜索防抖立即废弃旧响应；销毁取消待发请求并忽略正在读取的结果', (t) async {
    final api = ControlledOrders();
    merchantApi = api;
    final a = OrderListController();
    final pending = a.load();
    a.search('沪A');
    api.reads[0].complete(feed('old'));
    await pending;
    expect(a.items, isNull);
    await t.pump(const Duration(milliseconds: 301));
    expect(api.calls.last['q'], '沪A');
    a.dispose();
    api.reads[1].complete(feed('late'));
    await t.pump();
    expect(a.items, isNull);
    final b = OrderListController();
    b.search('待发送');
    b.dispose();
    await t.pump(const Duration(milliseconds: 301));
    expect(api.calls.length, 2);
  });

  test('分页错误可重试且成功清除错误；请求期间忽略重复分页', () async {
    final api = ControlledOrders();
    merchantApi = api;
    final a = OrderListController();
    final first = a.load();
    api.reads[0].complete(feed('a', more: true));
    await first;
    final more = a.loadMore();
    await a.loadMore();
    expect(api.calls.length, 2);
    api.reads[1].completeError(const AppError('网络错误'));
    await more;
    expect(a.items!.single['id'], 'a');
    expect(a.error, isNotNull);
    final retry = a.loadMore();
    api.reads[2].complete(feed('b'));
    await retry;
    expect(a.error, isNull);
    expect(a.items!.length, 2);
    a.dispose();
  });

  test('退款记录由接口确认原类型，非不存在错误不回退次卡', () async {
    final api = ControlledOrders();
    merchantApi = api;
    final future = const OrderDetailRef(kind: 'refund', id: 'r').load();
    api.reads[0].completeError(
      AppError.fromStatus(404, '订单不存在'),
    );
    await Future<void>.delayed(Duration.zero);
    expect(api.calls[1]['type'], 'package');
    api.reads[1].complete({'kind': 'package', 'id': 'r'});
    expect((await future)['kind'], 'package');
    final error = const OrderDetailRef(kind: 'refund', id: 'x').load();
    api.reads[2].completeError(
      AppError.fromStatus(403, '无权查看'),
    );
    await expectLater(error, throwsA(isA<AppError>()));
    expect(api.calls.length, 3);
  });

  test('退款实例与快照隔离，同一失败重试沿用标识，更换原因创建新标识', () async {
    final api = RefundApi();
    merchantApi = api;
    final row = refundable('a');
    final a = OrderRefundController(row),
        b = OrderRefundController(refundable('b'));
    row['id'] = 'changed';
    await expectLater(a.submit('服务问题'), throwsA(isA<AppError>()));
    await expectLater(a.submit('服务问题'), throwsA(isA<AppError>()));
    expect(api.writes[0]['id'], 'a');
    expect(api.writes[0]['requestId'], isNotNull);
    expect(api.writes[0]['requestId'], api.writes[1]['requestId']);
    await expectLater(a.submit('录入错误'), throwsA(isA<AppError>()));
    await expectLater(b.submit('服务问题'), throwsA(isA<AppError>()));
    expect(api.writes[2]['requestId'], isNot(api.writes[1]['requestId']));
    expect(api.writes[3]['requestId'], isNot(api.writes[0]['requestId']));
    a.dispose();
    b.dispose();
  });

  test('退款防重复，销毁后成功不通知已释放实例', () async {
    final api = RefundApi()..write = Completer<Map<String, dynamic>>();
    merchantApi = api;
    final a = OrderRefundController(refundable('a'));
    var notifications = 0;
    a.addListener(() => notifications++);
    final first = a.submit('服务问题');
    expect(await a.submit('服务问题'), isFalse);
    a.dispose();
    api.write!.complete({'order_id': 'a'});
    expect(await first, isTrue);
    expect(api.writes.length, 1);
    expect(notifications, 1);
  });

  test('微信支付宝及未知支付方式阻止假退款，现金储值与次卡记账调用真实接口', () async {
    final api = RefundApi()..fail = false;
    merchantApi = api;
    for (final method in ['微信支付', '支付宝支付', '未知方式']) {
      final c = OrderRefundController(refundable('x', method));
      await expectLater(c.submit('服务问题'), throwsA(isA<AppError>()));
      c.dispose();
    }
    expect(api.writes, isEmpty);
    for (final method in ['储值余额', '现金支付', '次卡抵扣']) {
      final c = OrderRefundController(refundable('x', method));
      expect(await c.submit('服务问题'), isTrue);
      c.dispose();
    }
    expect(api.writes.length, 3);
  });

  testWidgets('筛选弹层取消不修改传入条件；确认返回独立条件', (t) async {
    phone(t);
    const initial = OrderFilters(type: 1, operatorName: '陈明');
    OrderFilters? result;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<OrderFilters>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const OrderFilterLiveSheet(
                    initial: initial,
                    operators: ['陈明'],
                  ),
                );
              },
              child: const Text('筛选'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('筛选'));
    await t.pumpAndSettle();
    await t.tap(find.text('充值'));
    await t.pumpAndSettle();
    Navigator.of(t.element(find.text('筛选订单'))).pop();
    await t.pumpAndSettle();
    expect(result, isNull);
    expect(initial.type, 1);
    await t.tap(find.text('筛选'));
    await t.pumpAndSettle();
    await t.tap(find.text('充值'));
    await t.tap(find.text('查看订单'));
    await t.pumpAndSettle();
    expect(result!.type, 2);
    expect(result!.operatorName, '陈明');
    expect(initial.type, 1);
  });
}
