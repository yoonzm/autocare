import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/sms_code.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_info_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_route_data.dart';
import 'package:autocare_merchant/pages/staff_app/st_order_controller.dart';
import 'package:autocare_merchant/pages/staff_app/st_order_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_cash_queue_template.dart';
import 'package:autocare_merchant/pages/staff_app/staff_tabs.dart'
    show stPageFor;
import 'package:autocare_merchant/pages/scan/scan_page.dart';
import 'package:autocare_merchant/routes.dart' show pageFor;

import 'staff_member_test.dart' show MemberLookupApi;
import 'members_test.dart' show phone;
import 'wallet_state_test.dart' show RecordingApi;

class StaffInputApi extends MemberLookupApi {
  final pending = <Completer<Map<String, dynamic>>>[];
  final writes = <Map<String, dynamic>>[];
  bool defer = false;
  bool deferReturns = false;
  Object? failWrite;
  Completer<Map<String, dynamic>>? write;
  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    if (deferReturns && action == 'staff_order_return') {
      calls.add({'action': action, ...values});
      final c = Completer<Map<String, dynamic>>();
      pending.add(c);
      return c.future;
    }
    if (defer &&
        const [
          'staff_order_quote',
          'staff_member_search',
          'staff_member_info',
        ].contains(action)) {
      calls.add({'action': action, ...values});
      final c = Completer<Map<String, dynamic>>();
      pending.add(c);
      return c.future;
    }
    if (action == 'staff_order_quote') {
      calls.add({'action': action, ...values});
      return Future.value({'payable': 61});
    }
    return super.staffWork(action, values);
  }

  @override
  Future<Map<String, dynamic>> submitStaffOrder(
    Map<String, dynamic> values, {
    String? requestId,
  }) async {
    writes.add({...values, 'requestId': requestId});
    if (write != null) return write!.future;
    if (failWrite != null) throw failWrite!;
    return {'id': 'h1'};
  }
}

const info = {'id': 'm1', 'name': '会员甲', 'level': '会员', 'plate': '沪A12345'};
const services = [
  {'id': 's1', 'name': '精致洗车', 'price': 68, 'active': true},
];

void main() {
  late MerchantApi original;
  late StaffInputApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = StaffInputApi();
  });
  tearDown(() {
    merchantApi = original;
  });

  test('快速开单请求编号传到实际请求层', () async {
    final transport = RecordingApi();
    await transport.submitStaffOrder({
      'member_id': 'm1',
      'lines': services,
    }, requestId: 'staff-retry');
    expect(transport.requests.single.id, 'staff-retry');
    expect(transport.requests.single.body['action'], 'staff_order_submit');
  });

  test('估价按实例隔离，选择改变后旧估价不能恢复已取消的项目', () async {
    api.defer = true;
    final a = StOrderController(info),
        b = StOrderController({...info, 'id': 'm2'});
    final first = a.toggle('s1'), other = b.toggle('s2');
    await a.toggle('s1');
    api.pending[0].complete({'payable': 999});
    api.pending[1].complete({'payable': 42});
    await Future.wait([first, other]);
    expect(a.quote, isNull);
    expect(a.selected, isEmpty);
    expect(b.quote!['payable'], 42);
    expect(api.calls[1]['member_id'], 'm2');
    a.dispose();
    b.dispose();
  });

  test('估价失败保留选择并阻止提交；重试成功后才提交真实输入', () async {
    api.defer = true;
    final c = StOrderController(info)..note = '车内有物品';
    final first = c.toggle('s1');
    api.pending[0].completeError(const AppError('读取失败'));
    await first;
    await expectLater(c.submit(), throwsA(isA<AppError>()));
    expect(api.writes, isEmpty);
    final retry = c.refreshQuote();
    api.pending[1].complete({'payable': 61});
    await retry;
    expect(await c.submit(), isTrue);
    expect(api.writes.single['lines'], [
      {'service_id': 's1', 'qty': 1},
    ]);
    expect(api.writes.single['note'], '车内有物品');
    expect(api.writes.single['plate'], '沪A12345');
    c.dispose();
  });

  test('明确业务失败可重试并沿用标识；提交锁和成功状态不会影响另一实例', () async {
    final a = StOrderController(info),
        b = StOrderController({...info, 'id': 'm2'});
    await a.toggle('s1');
    await b.toggle('s2');
    api.failWrite = const AppError('项目已下架');
    await expectLater(a.submit(), throwsA(isA<AppError>()));
    expect(a.selected, {'s1'});
    api.failWrite = null;
    api.write = Completer<Map<String, dynamic>>();
    final pending = a.submit();
    expect(await a.submit(), isFalse);
    await a.toggle('s2');
    expect(a.selected, {'s1'});
    api.write!.complete({'id': 'h1'});
    expect(await pending, isTrue);
    expect(await a.submit(), isFalse);
    expect(b.submitted, isFalse);
    expect(api.writes[0]['requestId'], api.writes[1]['requestId']);
    a.dispose();
    b.dispose();
  });

  test('网络结果不明确时保留输入，阻止无幂等保证的重复开单', () async {
    final c = StOrderController(info);
    await c.toggle('s1');
    api.failWrite = const AppError.timeout();
    await expectLater(
      c.submit(),
      throwsA(
        isA<AppError>().having((e) => e.message, '提示核对', contains('前台核对')),
      ),
    );
    api.failWrite = null;
    await expectLater(c.submit(), throwsA(isA<AppError>()));
    expect(api.writes.length, 1);
    expect(c.selected, {'s1'});
    c.dispose();
  });

  test('销毁后旧估价不通知页面；实际写入完成仍保留提交结果', () async {
    api.defer = true;
    final a = StOrderController(info);
    final quote = a.toggle('s1');
    a.dispose();
    api.pending[0].complete({'payable': 61});
    await quote;
    expect(a.quote, isNull);
    api.defer = false;
    final b = StOrderController(info);
    await b.toggle('s1');
    var notified = 0;
    b.addListener(() => notified++);
    api.write = Completer<Map<String, dynamic>>();
    final submit = b.submit();
    b.dispose();
    api.write!.complete({'id': 'h1'});
    expect(await submit, isTrue);
    expect(notified, 1);
  });

  testWidgets('搜索防抖废弃旧响应，错误可在原查询重试', (t) async {
    phone(t);
    api.defer = true;
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StMemberTemplate(initial: [])),
      ),
    );
    await t.enterText(find.byType(TextField), '甲');
    await t.pump(const Duration(milliseconds: 351));
    await t.enterText(find.byType(TextField), '乙');
    api.pending[0].complete({
      'items': [
        {'id': 'old', 'name': '旧会员'},
      ],
    });
    await t.pump();
    expect(find.text('旧会员'), findsNothing);
    await t.pump(const Duration(milliseconds: 351));
    api.pending[1].completeError(
      const AppError('查询失败', type: AppErrorType.network),
    );
    await t.pumpAndSettle();
    expect(find.text('网络不太给力'), findsOneWidget);
    await t.tap(find.text('重试'));
    await t.pump();
    expect(api.calls.last['q'], '乙');
    api.pending[2].complete({
      'items': [
        {'id': 'new', 'name': '新会员', 'phone_masked': '138****1234'},
      ],
    });
    await t.pumpAndSettle();
    expect(find.text('新会员'), findsOneWidget);
  });

  testWidgets('快速开单模板复用到新会员时清空旧选择备注，旧估价不回填', (t) async {
    phone(t);
    api.defer = true;
    Future<void> show(Map<String, dynamic> member) => t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StOrderTemplate(info: member, services: services),
        ),
      ),
    );
    await show(info);
    await t.tap(find.text('精致洗车'));
    await t.pump();
    await show({...info, 'id': 'm2', 'name': '会员乙'});
    api.pending[0].complete({'payable': 999});
    await t.pumpAndSettle();
    expect(find.text('已选 0 项 · 会员价'), findsOneWidget);
    expect(find.text('¥999'), findsNothing);
    await t.tap(find.text('精致洗车'));
    await t.pump();
    expect(api.calls.last['member_id'], 'm2');
    api.pending[1].complete({'payable': 42});
    await t.pumpAndSettle();
  });

  testWidgets('会员简况目标改变后只展示新会员，旧响应不能覆盖', (t) async {
    phone(t);
    api.defer = true;
    final fixture = await MemberLookupApi().staffWork('staff_member_info', {
      'id': 'm1',
    });
    Future<void> show(String id) =>
        t.pumpWidget(MaterialApp(home: StMemberInfoLivePage(memberId: id)));
    await show('m1');
    await t.pump();
    await show('m2');
    await t.pump();
    api.pending[1].complete({...fixture, 'id': 'm2', 'name': '新会员'});
    await t.pumpAndSettle();
    api.pending[0].complete({...fixture, 'name': '旧会员'});
    await t.pumpAndSettle();
    expect(find.text('新会员'), findsOneWidget);
    expect(find.text('旧会员'), findsNothing);
  });

  test('员工路由显式接受会员目标，无目标快速开单先查找会员', () {
    expect(
      pageFor('StOrder'),
      isA<StMemberLivePage>().having((p) => p.forOrder, '开单选择', isTrue),
    );
    expect(
      pageFor('StOrder', arguments: const StMemberRouteData('m2')),
      isA<StOrderLivePage>().having((p) => p.memberId, '会员', 'm2'),
    );
    expect(
      pageFor('StMemberInfo', arguments: const StMemberRouteData('m1')),
      isA<StMemberInfoLivePage>().having((p) => p.memberId, '会员', 'm1'),
    );
  });

  testWidgets('两个待收银列表提交锁隔离，同一列表重复退回只发一次', (t) async {
    phone(t);
    final rows = (await api.staffWork('staff_cash_queue'))['items'] as List;
    final items = [
      for (final row in rows) Map<String, dynamic>.from(row as Map),
    ];
    api.deferReturns = true;
    Future<void> show(int index) => t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IndexedStack(
            index: index,
            children: [
              StCashQueueTemplate(key: const ValueKey('a'), items: items),
              StCashQueueTemplate(key: const ValueKey('b'), items: items),
            ],
          ),
        ),
      ),
    );
    await show(0);
    await t.tap(find.text('退回修改'));
    await t.pump();
    expect(api.pending.length, 1);
    await show(1);
    expect(find.text('退回修改'), findsOneWidget);
    await t.tap(find.text('退回修改'));
    await t.pump();
    expect(api.pending.length, 2);
    api.pending[0].complete({'ok': true});
    api.pending[1].complete({'ok': true});
    await t.pumpAndSettle();
    expect(find.text('退回修改'), findsNothing);
    await show(0);
    expect(find.text('退回修改'), findsNothing);
  });

  test('员工扫码明确提供员工会员与开单动作，不依赖全局选择', () {
    final scanner = stPageFor('StVerify') as ScanPage;
    expect(scanner.onViewMember, isNotNull);
    expect(scanner.onOrderMember, isNotNull);
  });

  testWidgets('待收银数量来自真实列表，已收历史缺少接口明确阻止且不显示样例数量', (t) async {
    phone(t);
    final rows = (await api.staffWork('staff_cash_queue'))['items'] as List;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StCashQueueTemplate(
            items: [
              for (final row in rows) Map<String, dynamic>.from(row as Map),
            ],
          ),
        ),
      ),
    );
    expect(find.text('待收银 1'), findsOneWidget);
    expect(find.text('今日已收 —'), findsOneWidget);
    expect(find.text('今日已收 34'), findsNothing);
    await t.tap(find.text('今日已收 —'));
    await t.pumpAndSettle();
    expect(find.text('今日已收明细暂未接通'), findsWidgets);
    expect(find.text('退回修改'), findsOneWidget);
  });

  testWidgets('短信自定义冷却按秒递减，销毁取消计时且不跨实例', (t) async {
    final a = SmsCodeController(), b = SmsCodeController();
    a.start(seconds: 3);
    await t.pump(const Duration(seconds: 1));
    expect(a.seconds, 2);
    expect(b.seconds, 0);
    a.dispose();
    await t.pump(const Duration(seconds: 4));
    expect(a.seconds, 2);
    b.dispose();
  });
}
