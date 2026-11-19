import 'dart:async';

import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/shared/shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_stats_test.dart' show StatsApi;
import 'members_test.dart' show phone, row;

class _Api extends StatsApi {
  int homeCalls = 0, appointmentCalls = 0, inventoryCalls = 0, holdCalls = 0;

  @override
  Future<Map<String, dynamic>> homeStats() {
    homeCalls++;
    return super.homeStats();
  }

  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    if (action == 'summary') appointmentCalls++;
    return super.appointment(action, values);
  }

  @override
  Future<List<Map<String, dynamic>>> holds() {
    holdCalls++;
    return super.holds();
  }

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_list') {
      inventoryCalls++;
      return {'items': []};
    }
    return super.invoke(body, requestId: requestId);
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    tabIndex.value = 0;
    HoldStore.reset();
  });
  tearDown(() {
    merchantApi = original;
    HoldStore.reset();
    tabIndex.value = 0;
  });

  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: Shell()));
    await t.pumpAndSettle();
  }

  Future<void> select(WidgetTester t, int index) async {
    tabIndex.value = index;
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  testWidgets('四个 Tab 每次激活刷新各自数据，首次加载和重复点击不额外请求', (t) async {
    await open(t);
    expect(api.homeCalls, 1);
    expect(api.listCalls.length, 1);
    expect(api.inventoryCalls, 1);
    expect(api.businessCalls.length, 1);
    await t.tap(find.text('会员').last);
    await t.pumpAndSettle();
    expect(api.listCalls.length, 2);
    expect(api.homeCalls, 1);
    await t.tap(find.text('会员').last);
    await t.pumpAndSettle();
    expect(api.listCalls.length, 2);
    await select(t, 2);
    expect(api.inventoryCalls, 2);
    await select(t, 3);
    expect(api.businessCalls.length, 2);
    await select(t, 0);
    expect(api.homeCalls, 2);
    expect(api.appointmentCalls, 2);
    expect(api.holdCalls, 2);
    await select(t, 1);
    expect(api.listCalls.length, 3);
    expect(find.text('已更新'), findsNothing);
  });

  testWidgets('重新激活保留会员搜索和统计时段', (t) async {
    api.rows.add(row());
    await open(t);
    await select(t, 1);
    await t.enterText(find.byType(TextField), '王');
    await t.pump(const Duration(milliseconds: 350));
    await t.pumpAndSettle();
    await select(t, 3);
    await t.tap(find.text('今日'));
    await t.pumpAndSettle();
    expect(api.businessCalls.last.range, 'today');
    await select(t, 1);
    expect(api.listCalls.last.q, '王');
    expect(t.widget<TextField>(find.byType(TextField)).controller!.text, '王');
    await select(t, 3);
    expect(api.businessCalls.last.range, 'today');
  });

  testWidgets('激活仍在加载的 Tab 不重复请求，快速切换也不叠加请求', (t) async {
    api.businessWait = Completer<void>();
    phone(t);
    await t.pumpWidget(const MaterialApp(home: Shell()));
    await t.pump(const Duration(milliseconds: 100));
    expect(api.businessCalls.length, 1);
    tabIndex.value = 3;
    await t.pump();
    tabIndex.value = 0;
    await t.pump();
    tabIndex.value = 3;
    await t.pump();
    expect(api.businessCalls.length, 1);
    api.businessWait!.complete();
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(api.businessCalls.length, 1);
  });
}
