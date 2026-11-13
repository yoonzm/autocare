import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/pages/orders/hold_controller.dart';
import 'package:autocare_merchant/pages/orders/hold_draft.dart';
import 'package:autocare_merchant/pages/orders/hold_list_page.dart';
import 'package:autocare_merchant/pages/orders/hold_board.dart';
import 'package:autocare_merchant/pages/orders/order_checkout.dart';
import 'package:autocare_merchant/pages/orders/order_page.dart';
import 'package:autocare_merchant/pages/orders/order_route_data.dart';
import 'package:autocare_merchant/pages/orders/pay_success_page.dart';
import 'package:autocare_merchant/pages/scan/scan_result.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'members_test.dart' show MemberFakeApi, row, phone;
import 'holds_test.dart' show hold;
import 'wallet_state_test.dart' show RecordingApi;

class FlowApi extends MemberFakeApi {
  Completer<void>? gate;
  Completer<List<Map<String, dynamic>>>? oldCover;
  bool fail = false;
  bool memberReadFails = false;
  int holdReads = 0;
  Completer<List<Map<String, dynamic>>>? heldRead;
  final requests = <Map<String, dynamic>>[];
  @override
  Future<List<Map<String, dynamic>>> holds() async {
    holdReads++;
    if (heldRead != null) return heldRead!.future;
    return super.holds();
  }

  @override
  Future<Map<String, dynamic>> member(String id) async {
    if (memberReadFails) throw const AppError('会员刷新失败');
    return super.member(id);
  }

  @override
  Future<void> cancelHold(String id, {String? requestId}) async {
    requests.add({'cancel': id, 'requestId': requestId});
    if (fail) throw const AppError('删除失败');
    return super.cancelHold(id, requestId: requestId);
  }

  @override
  Future<Map<String, dynamic>> checkout({
    String? requestId,
    required String memberId,
    required List<Map<String, dynamic>> lines,
    required String method,
    num? balancePart,
    String? other,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    requests.add({
      'id': memberId,
      'lines': lines,
      'method': method,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('收款未完成');
    return {
      'id': 'order-$memberId',
      'payable': 123,
      'balance': 456,
      'pay_method': method,
      'items': '真实服务',
    };
  }

  @override
  Future<Map<String, dynamic>> saveHold({
    String? requestId,
    String? holdId,
    String? memberId,
    required List<Map<String, dynamic>> lines,
    String status = '待施工',
    String note = '',
    String remind = '不提醒',
    String plate = '',
  }) async {
    requests.add({
      'id': memberId,
      'lines': lines,
      'status': status,
      'note': note,
      'remind': remind,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('挂单未完成');
    return {
      'id': holdId ?? 'hold-$memberId',
      'member_id': memberId,
      'status': status,
      'note': note,
      'remind': remind,
      'items': lines,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> memberPackages(String id) async {
    if (id == 'old' && oldCover != null) return oldCover!.future;
    return [];
  }
}

HoldDraft draft(String id, {Map<String, dynamic>? original}) => HoldDraft(
  memberId: id,
  memberName: id,
  level: '金卡',
  plateLabel: '沪A·12345',
  plate: '沪A12345',
  lines: [
    {'service_id': 's1', 'qty': 1},
  ],
  payableText: '68',
  original: original,
);

void main() {
  late MerchantApi original;
  late FlowApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = FlowApi();
    HoldStore.reset();
    ServiceStore.clear();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    HoldStore.reset();
    ServiceStore.clear();
    navTracker.stack.clear();
  });

  test('会员、散客、预约、挂单和删除都把幂等标识传到请求层', () async {
    final client = RecordingApi();
    final lines = [
      {'service_id': 's1', 'qty': 1},
    ];
    await client.checkout(
      memberId: 'm',
      lines: lines,
      method: '现金',
      requestId: 'member',
    );
    await client.checkoutWalkIn(
      lines: lines,
      method: '现金',
      requestId: 'walk-in',
    );
    await client.checkoutAppointment({
      'id': 'a',
      'lines': lines,
      'method': '现金',
    }, requestId: 'appointment');
    await client.saveHold(memberId: 'm', lines: lines, requestId: 'hold');
    await client.cancelHold('h', requestId: 'cancel');
    expect(client.requests.map((r) => r.id), [
      'member',
      'walk-in',
      'appointment',
      'hold',
      'cancel',
    ]);
    expect(client.requests[2].body['action'], 'appointment_checkout');
  });

  test('收款实例隔离，同一实例防重，失败重试复用标识', () async {
    final a = OrderCheckout(), b = OrderCheckout();
    final lines = [
      {'service_id': 's1', 'qty': 1},
    ];
    api.fail = true;
    await expectLater(
      a.pay(
        member: row(id: 'a'),
        lines: lines,
        method: '现金',
      ),
      throwsA(isA<AppError>()),
    );
    await expectLater(
      a.pay(
        member: row(id: 'a'),
        lines: lines,
        method: '现金',
      ),
      throwsA(isA<AppError>()),
    );
    expect(api.requests[0]['requestId'], isNotNull);
    expect(api.requests[1]['requestId'], api.requests[0]['requestId']);
    api.fail = false;
    api.memberReadFails = true;
    api.gate = Completer<void>();
    final first = a.pay(
      member: row(id: 'a'),
      lines: lines,
      method: '现金',
    );
    expect(
      await a.pay(
        member: row(id: 'a'),
        lines: lines,
        method: '现金',
      ),
      isNull,
    );
    final second = b.pay(
      member: row(id: 'b'),
      lines: lines,
      method: '会员余额',
    );
    lines.single['qty'] = 9;
    expect((api.requests[2]['lines'] as List).single['qty'], 1);
    api.gate!.complete();
    final results = await Future.wait([first, second]);
    expect(results.map((r) => r!.data['id']), ['order-a', 'order-b']);
    expect(results.first!.data['payable'], 123);
    a.dispose();
    b.dispose();
  });

  test('修改收款意图后使用新标识，销毁页面仍交付真实结果且不通知旧监听', () async {
    final c = OrderCheckout();
    api.fail = true;
    await expectLater(
      c.pay(
        member: row(id: 'a'),
        lines: [
          {'service_id': 's1', 'qty': 1},
        ],
        method: '现金',
      ),
      throwsA(isA<AppError>()),
    );
    api.fail = false;
    api.gate = Completer<void>();
    var notifications = 0;
    c.addListener(() => notifications++);
    final pending = c.pay(
      member: row(id: 'b'),
      lines: [
        {'service_id': 's1', 'qty': 2},
      ],
      method: '现金',
    );
    expect(
      api.requests.last['requestId'],
      isNot(api.requests.first['requestId']),
    );
    c.dispose();
    final before = notifications;
    api.gate!.complete();
    final receipt = (await pending)!;
    expect(notifications, before);
    expect(receipt.data['id'], 'order-b');
    expect(() => receipt.data['payable'] = 999, throwsUnsupportedError);
  });

  test('挂单状态和备注独立，失败保留输入和请求标识', () async {
    final a = HoldController(draft('a')), b = HoldController(draft('b'));
    a.chooseStatus(2);
    a.chooseRemind(1);
    a.note.text = '甲的备注';
    b.note.text = '乙的备注';
    api.fail = true;
    await expectLater(a.save(), throwsA(isA<AppError>()));
    await expectLater(a.save(), throwsA(isA<AppError>()));
    expect(a.note.text, '甲的备注');
    expect(a.status, 2);
    expect(a.remind, 1);
    expect(api.requests[1]['requestId'], api.requests[0]['requestId']);
    api.fail = false;
    api.gate = Completer<void>();
    final first = a.save();
    expect(await a.save(), isNull);
    final second = b.save();
    a.chooseStatus(0);
    expect(a.status, 2);
    api.gate!.complete();
    await Future.wait([first, second]);
    expect(api.requests[2]['note'], '甲的备注');
    expect(api.requests[3]['note'], '乙的备注');
    expect(HoldStore.count, 2);
    a.dispose();
    b.dispose();
  });

  test('导航、挂单和识别参数复制嵌套数据，旧输入不会改变本次页面快照', () {
    final source = hold();
    final args = OrderRouteData(hold: source);
    (source['items'] as List).first['qty'] = 8;
    expect((args.hold!['items'] as List).first['qty'], 1);
    expect(OrderRouteData(hold: source), isNot(args));
    final d = draft('a', original: source);
    (source['items'] as List).first['qty'] = 9;
    expect((d.original!['items'] as List).first['qty'], 8);
    final result = {
      'matched': true,
      'plate': '粤B22222',
      'member': row(
        vehicles: [
          {'plate': '沪A11111'},
          {'plate': '粤B22222'},
        ],
      ),
    };
    final scanned = ScanResult(result);
    (result['member'] as Map)['name'] = '外部修改';
    expect(scanned.member!['name'], '王建国');
    expect((scanned.member!['vehicles'] as List).first['plate'], '粤B22222');
    expect(
      ((result['member'] as Map)['vehicles'] as List).first['plate'],
      '沪A11111',
    );
    expect(ScanResult({'matched': false, 'member': row()}).member, isNull);
  });

  testWidgets('取单保留真实数量，展示金额并按原数量提交', (t) async {
    phone(t);
    final member = row();
    api.rows.add(member);
    api.services.add({
      'id': 's1',
      'name': '精致洗车',
      'price': 68,
      'category': '洗车',
      'active': true,
    });
    final held = hold(items: ['精致洗车']);
    (held['items'] as List).single['qty'] = 3;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: OrderPage(hold: held),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('精致洗车 × 3'), findsOneWidget);
    expect(find.text('¥193.80'), findsWidgets);
    await t.tap(find.text('确认收款'));
    await t.pumpAndSettle();
    expect((api.requests.single['lines'] as List).single['qty'], 3);
    expect(find.byType(PaySuccessPage), findsOneWidget);
  });

  testWidgets('更换会员释放旧次卡响应，旧结果不能抵扣新会员', (t) async {
    phone(t);
    api.oldCover = Completer<List<Map<String, dynamic>>>();
    api.services.add({
      'id': 's1',
      'name': '精致洗车',
      'price': 68,
      'category': '洗车',
      'active': true,
    });
    await t.pumpWidget(
      MaterialApp(
        home: OrderPage(member: memberFromRow(row(id: 'old'))),
      ),
    );
    await t.pump();
    await t.pumpWidget(
      MaterialApp(
        home: OrderPage(member: memberFromRow(row(id: 'new'))),
      ),
    );
    await t.pumpAndSettle();
    api.oldCover!.complete([
      {
        'id': 'old-package',
        'items': [
          {'service_id': 's1', 'total': 10, 'used': 0},
        ],
      },
    ]);
    await t.pumpAndSettle();
    await t.tap(find.text('精致洗车'));
    await t.pump();
    expect(find.text('次卡抵扣 1 次'), findsNothing);
    await t.tap(find.text('确认收款'));
    await t.pumpAndSettle();
    expect(api.requests.single['id'], 'new');
    expect(
      (api.requests.single['lines'] as List).single.containsKey(
        'member_package_id',
      ),
      isFalse,
    );
  });

  testWidgets('缺少真实回执时不展示成功数据', (t) async {
    await t.pumpWidget(const MaterialApp(home: PaySuccessPage()));
    await t.pumpAndSettle();
    expect(t.widget<ErrorView>(find.byType(ErrorView)).error.message, '请先完成收款');
    expect(find.text('收款成功'), findsNothing);
  });

  testWidgets('次卡读取失败阻止收款，重试成功后再提交', (t) async {
    phone(t);
    api.oldCover = Completer<List<Map<String, dynamic>>>();
    api.services.add({
      'id': 's1',
      'name': '精致洗车',
      'price': 68,
      'category': '洗车',
      'active': true,
    });
    await t.pumpWidget(
      MaterialApp(
        home: OrderPage(member: memberFromRow(row(id: 'old'))),
      ),
    );
    await t.pump();
    api.oldCover!.completeError(
      const AppError('次卡读取失败', type: AppErrorType.network),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('精致洗车'));
    await t.pump();
    await t.tap(find.text('确认收款'));
    await t.pump();
    expect(api.requests, isEmpty);
    api.oldCover = null;
    await t.tap(find.text('重试').first);
    await t.pumpAndSettle();
    await t.tap(find.text('确认收款'));
    await t.pumpAndSettle();
    expect(api.requests.single['id'], 'old');
  });

  testWidgets('删除挂单失败保留确认弹窗，重试使用相同请求标识', (t) async {
    phone(t);
    api.holdRows.add(hold());
    api.fail = true;
    await t.pumpWidget(const MaterialApp(home: HoldListPage()));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('删除挂单'));
    await t.pumpAndSettle();
    await t.tap(find.text('删除'));
    await t.pumpAndSettle();
    expect(find.text('确认删除？'), findsOneWidget);
    expect(api.holdRows, hasLength(1));
    api.fail = false;
    await t.tap(find.text('删除'));
    await t.pumpAndSettle();
    expect(api.holdRows, isEmpty);
    expect(find.text('确认删除？'), findsNothing);
    expect(api.requests[0]['requestId'], isNotNull);
    expect(api.requests[1]['requestId'], api.requests[0]['requestId']);
  });

  testWidgets('多个挂单列表读取不会互相重载，真实写入后分别刷新一次', (t) async {
    phone(t);
    api.holdRows.add(hold());
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(children: [HoldBoard(), HoldBoard()]),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(api.holdReads, 2);
    final second = hold(id: 'h2');
    api.holdRows.add(second);
    HoldStore.recordSaved(second);
    await t.pumpAndSettle();
    expect(api.holdReads, 4);
    expect(HoldStore.count, 2);
    await t.pump(const Duration(seconds: 2));
    expect(api.holdReads, 4);
  });
  test('缓存读取的旧响应不能覆盖已写入的挂单，只读结果不能被外部修改', () async {
    api.heldRead = Completer<List<Map<String, dynamic>>>();
    final old = HoldStore.load();
    final saved = hold(id: 'new');
    HoldStore.recordSaved(saved);
    (saved['items'] as List).first['qty'] = 99;
    api.heldRead!.complete([]);
    await old;
    expect(HoldStore.count, 1);
    expect(HoldStore.holds!.single['id'], 'new');
    expect((HoldStore.holds!.single['items'] as List).first['qty'], 1);
    expect(() => HoldStore.holds!.clear(), throwsUnsupportedError);
    expect(
      () => HoldStore.holds!.single['status'] = '待施工',
      throwsUnsupportedError,
    );
  });
}
