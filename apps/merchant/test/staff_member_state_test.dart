import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/sms_code.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_info_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_route_data.dart';
import 'package:autocare_merchant/pages/staff_app/st_cash_queue_template.dart';
import 'package:autocare_merchant/pages/staff_app/staff_tabs.dart'
    show stPageFor;
import 'package:autocare_merchant/pages/scan/scan_page.dart';
import 'package:autocare_merchant/routes.dart' show pageFor;

import 'staff_member_test.dart' show MemberLookupApi;
import 'members_test.dart' show phone;

class StaffInputApi extends MemberLookupApi {
  final pending = <Completer<Map<String, dynamic>>>[];
  bool defer = false;
  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    if (defer &&
        const ['staff_member_search', 'staff_member_info'].contains(action)) {
      calls.add({'action': action, ...values});
      final c = Completer<Map<String, dynamic>>();
      pending.add(c);
      return c.future;
    }
    return super.staffWork(action, values);
  }
}

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

  test('独立技师开单路由已移除，员工简况显式接受会员目标', () {
    expect(pageFor('StOrder'), isNull);
    expect(
      pageFor('StMemberInfo', arguments: const StMemberRouteData('m1')),
      isA<StMemberInfoLivePage>().having((p) => p.memberId, '会员', 'm1'),
    );
  });

  test('员工扫码明确提供员工会员与开单动作，不依赖全局选择', () {
    final scanner = stPageFor('StVerify') as ScanPage;
    expect(scanner.onViewMember, isNotNull);
    expect(scanner.onOrderMember, isNotNull);
  });

  testWidgets('待收银与今日已收数量来自真实列表，不显示样例数量', (t) async {
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
    expect(find.text('今日已收 0'), findsOneWidget);
    expect(find.text('今日已收 34'), findsNothing);
    await t.tap(find.text('今日已收 0'));
    await t.pumpAndSettle();
    expect(find.text('今日暂无已收银的订单'), findsOneWidget);
    expect(find.text('退回修改'), findsNothing);
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
