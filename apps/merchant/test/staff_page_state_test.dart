import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/staff_flow.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/staff/staff_detail_template.dart';
import 'package:autocare_merchant/pages/staff/staff_records_template.dart';
import 'package:autocare_merchant/pages/staff/staff_route_data.dart';
import 'package:autocare_merchant/routes.dart';

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

class RecordsApi extends BookingApi {
  final pending = <String, Completer<Map<String, dynamic>>>{};

  @override
  Future<Map<String, dynamic>> staff(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final key = '${values['id']}:${values['range']}';
    if (action == 'records' && pending.containsKey(key)) {
      calls.add({'action': 'staff_records', ...values});
      return pending[key]!.future;
    }
    return super.staff(action, values);
  }
}

void main() {
  late MerchantApi original;
  late RecordsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = RecordsApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  testWidgets('缺少员工参数时阻止请求，不使用之前打开的员工', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(home: StaffDetailLivePage(staffId: 't1')),
    );
    await t.pumpAndSettle();
    expect(find.text('真实技师'), findsOneWidget);
    api.calls.clear();
    await t.pumpWidget(const MaterialApp(home: StaffDetailLivePage()));
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('真实技师'), findsNothing);
    expect(api.calls, isEmpty);
  });

  testWidgets('两个详情实例刷新时各自保留员工 ID', (t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        home: Row(
          children: const [
            Expanded(child: StaffDetailLivePage(staffId: 't1')),
            Expanded(child: StaffDetailLivePage(staffId: 'x1')),
          ],
        ),
      ),
    );
    // 使用宽屏容纳两份原始布局。
    t.view.physicalSize = const Size(1000, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpAndSettle();
    api.calls.clear();
    StaffFlow.notify();
    await t.pumpAndSettle();
    expect(
      api.calls.where((c) => c['action'] == 'staff_get').map((c) => c['id']),
      unorderedEquals(['t1', 'x1']),
    );
    expect(find.text('真实技师'), findsOneWidget);
    expect(find.text('已离职技师'), findsOneWidget);
  });

  testWidgets('员工切换后晚到的旧范围响应不能覆盖新员工记录', (t) async {
    phone(t);
    final selected = ValueNotifier('t1');
    addTearDown(selected.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: selected,
          builder: (_, id, _) => StaffRecordsLivePage(staffId: id),
        ),
      ),
    );
    await t.pumpAndSettle();
    api.pending['t1:last'] = Completer();
    await t.tap(find.text('上月'));
    await t.pump();
    selected.value = 'x1';
    await t.pumpAndSettle();
    expect(
      api.calls.lastWhere((c) => c['action'] == 'staff_records')['id'],
      'x1',
    );
    expect(find.text('沪A12345'), findsOneWidget);
    api.pending['t1:last']!.complete(api.recordsFor('last'));
    await t.pumpAndSettle();
    expect(find.text('沪A12345'), findsOneWidget);
    expect(find.text('暂无施工记录'), findsNothing);
  });

  testWidgets('同名员工路由按参数复用，不同员工独立入栈', (t) async {
    phone(t);
    late BuildContext root;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (context) {
            root = context;
            return const Scaffold();
          },
        ),
      ),
    );
    openRoute(
      root,
      'StaffDetail',
      arguments: const StaffRouteData(staffId: 't1'),
    );
    await t.pumpAndSettle();
    openRoute(
      root,
      'StaffDetail',
      arguments: const StaffRouteData(staffId: 'x1'),
    );
    await t.pumpAndSettle();
    expect(
      navTracker.stack.where((r) => r.settings.name == 'StaffDetail'),
      hasLength(2),
    );
    openRoute(
      root,
      'StaffDetail',
      arguments: const StaffRouteData(staffId: 't1'),
    );
    await t.pumpAndSettle();
    expect(
      navTracker.stack.where((r) => r.settings.name == 'StaffDetail'),
      hasLength(1),
    );
    expect(find.text('真实技师'), findsOneWidget);
  });
}
