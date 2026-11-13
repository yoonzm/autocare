import 'dart:async';

import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/account/store_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

class _Api extends BookingApi {
  Completer<void>? storeGate;
  Object? storeError;
  int reads = 0;
  Map<String, dynamic> store = {
    'id': 'real-store-1',
    'name': '实际门店',
    'phone': '02112345678',
    'city': '上海市',
    'address': '徐汇路1号',
    'hours_line': '08:30–21:00 · 2 工位 · 统一管理',
  };
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    String? requestId,
  }) async {
    if (body['action'] == 'store_media_list' ||
        body['action'] == 'staff_task_photo_list') {
      return {'items': []};
    }
    return super.invoke(body, timeout: timeout, requestId: requestId);
  }

  @override
  Future<Map<String, dynamic>> getStore() async {
    reads++;
    final snapshot = Map<String, dynamic>.from(store);
    await storeGate?.future;
    if (storeError != null) throw storeError!;
    return snapshot;
  }

  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action != 'options') return super.appointment(action, values);
    return {
      'resources': [
        {'id': 'b1', 'kind': 'bay', 'active': true, 'category': '洗车'},
        {'id': 'b2', 'kind': 'bay', 'active': true, 'category': '美容'},
        {'id': 'b3', 'kind': 'bay', 'active': false, 'category': '贴膜'},
        {'id': 't1', 'kind': 'technician', 'active': true, 'category': '贴膜'},
      ],
    };
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
  });
  tearDown(() => merchantApi = original);

  testWidgets('门店资料与工位来自接口，不显示照片数、专业版或示例工位，移除一期二维码入口', (t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: StoreInfoPage()));
    await t.pumpAndSettle();
    for (final text in [
      '实际门店',
      '门店编号 real-store-1',
      '上海市 徐汇路1号',
      '02112345678',
      '08:30–21:00 · 2 工位 · 统一管理',
      '工位配置 · 共 2 个',
      '洗车 1',
      '美容 1',
      '贴膜间 0',
      '限时免费',
    ]) {
      expect(find.text(text), findsOneWidget);
    }
    for (final text in [
      '专业版',
      '共 6 张',
      '工位配置 · 共 6 个',
      '营业中',
      '门店二维码',
      '门店编号 CG-0021',
      '驰光汽车美容 · 徐汇店',
    ]) {
      expect(find.text(text), findsNothing);
    }
  });

  testWidgets('资料读取期间发生工位变更，加载结束后读取新资料', (t) async {
    phone(t);
    api.storeGate = Completer();
    await t.pumpWidget(const MaterialApp(home: StoreInfoPage()));
    await t.pump();
    api.store['name'] = '变更后门店';
    AppointmentFlow.notify();
    api.storeGate!.complete();
    await t.pumpAndSettle();
    expect(api.reads, 2);
    expect(find.text('变更后门店'), findsOneWidget);
    expect(find.text('实际门店'), findsNothing);
  });

  testWidgets('资料读取失败通过统一边界重试，不回退样例', (t) async {
    phone(t);
    api.storeError = const AppError.timeout();
    await t.pumpWidget(const MaterialApp(home: StoreInfoPage()));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsOneWidget);
    expect(find.text('实际门店'), findsNothing);
    api.storeError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('实际门店'), findsOneWidget);
  });
}
