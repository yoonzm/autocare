import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/subscription_flow.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class SubscriptionApi extends MemberFakeApi {
  String kind = 'pro';
  Object? error;
  Completer<void>? gate;
  final payments = <Map<String, dynamic>>[];
  final plans = <Map<String, dynamic>>[
    {
      'kind': 'basic',
      'name': '真实基础版',
      'version': 1,
      'fee': 60000,
      'monthly_fee': 6000,
      'quarterly_fee': 17100,
      'store_limit': 1,
      'staff_limit': 5,
    },
    {
      'kind': 'pro',
      'name': '真实专业版',
      'version': 1,
      'fee': 120000,
      'monthly_fee': 12000,
      'quarterly_fee': 34200,
      'store_limit': 3,
      'staff_limit': 10,
    },
    {
      'kind': 'flagship',
      'name': '真实旗舰版',
      'version': 1,
      'fee': 700000,
      'monthly_fee': 70000,
      'quarterly_fee': 199500,
      'store_limit': 10,
      'staff_limit': null,
    },
  ];
  @override
  Future<Map<String, dynamic>> subscriptionCatalog() async => {
    'plans': [for (final p in plans) Map<String, dynamic>.from(p)],
    'subscription': {'plan': kind},
    'revision': 'current-revision',
    'simulation': true,
  };
  @override
  Future<Map<String, dynamic>> getStore() async => {
    'id': 'store',
    'name': '真实门店',
    'plan': kind,
    'phone': '13900000001',
    'trial_ends_at': '2031-01-01T00:00:00Z',
    'subscription': plans.firstWhere((p) => p['kind'] == kind),
    'store_count': 1,
  };
  @override
  Future<Map<String, dynamic>> simulateSubscription(
    Map<String, dynamic> body, {
    required String requestId,
  }) async {
    payments.add({...body, 'requestId': requestId});
    await gate?.future;
    if (error != null) throw error!;
    kind = '${body['plan']}';
    final p = plans.firstWhere((p) => p['kind'] == kind);
    final months = body['months'];
    return {
      'id': '123e4567-e89b-42d3-a456-426614174000',
      'plan': kind,
      'name': p['name'],
      'months': months,
      'amount':
          p[months == 1
              ? 'monthly_fee'
              : months == 3
              ? 'quarterly_fee'
              : 'fee'],
      'starts_at': '2030-01-01T00:00:00Z',
      'ends_at': '2031-01-01T00:00:00Z',
      'pay': '模拟支付',
      'simulated': true,
      'store_limit': p['store_limit'],
    };
  }
}

void main() {
  late MerchantApi original;
  late SubscriptionApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = SubscriptionApi();
    subscriptionFlow.reset();
    storeProfile.apply({
      'id': 'store',
      'name': '真实门店',
      'plan': 'pro',
      'phone': '13900000001',
    });
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    subscriptionFlow.reset();
    navTracker.stack.clear();
  });
  Future<void> open(WidgetTester t, String route) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openRoute(context, route),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('套餐真实价格与名额，可选基础版/月付，模拟支付成功后展示真实回执', (t) async {
    await open(t, 'Plans');
    expect(find.text('年付 ¥600.00'), findsOneWidget);
    expect(find.text('1 家门店 · 5 个员工账号'), findsOneWidget);
    await t.ensureVisible(find.text('真实基础版').first);
    await t.tap(find.text('真实基础版').first);
    await t.pump();
    await t.ensureVisible(find.text('月付').first);
    await t.tap(find.text('月付').first);
    await t.pump();
    expect(subscriptionFlow.plan, 'basic');
    expect(subscriptionFlow.months, 1);
    await t.ensureVisible(find.text('立即订阅'));
    await t.tap(find.text('立即订阅'));
    await t.pumpAndSettle();
    expect(find.text('真实基础版'), findsWidgets);
    api.gate = Completer<void>();
    await t.ensureVisible(find.text('立即支付'));
    await t.tap(find.text('立即支付'));
    await t.pump();
    expect(find.text('提交中…'), findsOneWidget);
    expect(api.payments.length, 1);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(navTracker.has('PlanPaid'), true);
    expect(find.text('¥60.00'), findsOneWidget);
    expect(find.text('模拟支付（暂不扣款）'), findsOneWidget);
    expect(find.text('123e4567-e89b-42d3-a456-426614174000'), findsOneWidget);
    expect(api.payments.single['plan'], 'basic');
    expect(api.payments.single['months'], 1);
    expect(storeProfile.plan, 'basic');
    expect(t.takeException(), isNull);
  });
  testWidgets('续费默认当前套餐，选三个月后由后端完成并显示新有效期', (t) async {
    await open(t, 'Renew');
    await t.tap(find.text('3 个月').first);
    await t.pump();
    expect(subscriptionFlow.months, 3);
    await t.ensureVisible(find.text('确认支付 ¥342.00'));
    await t.tap(find.text('确认支付 ¥342.00'));
    await t.pumpAndSettle();
    expect(api.payments.single['mode'], 'renew');
    expect(api.payments.single['months'], 3);
    expect(navTracker.has('RenewPaid'), true);
    expect(find.text('2031.01.01'), findsOneWidget);
  });
  testWidgets('支付失败留在确认页，重试复用编号，未成功不能进入成功页', (t) async {
    await open(t, 'PlanCheckout');
    api.error = const AppError('请求超时', type: AppErrorType.network);
    await t.ensureVisible(find.text('立即支付'));
    await t.tap(find.text('立即支付'));
    await t.pumpAndSettle();
    expect(navTracker.has('PlanPaid'), false);
    api.error = null;
    await t.tap(find.text('立即支付'));
    await t.pumpAndSettle();
    expect(api.payments.length, 2);
    expect(api.payments.first['requestId'], api.payments.last['requestId']);
    expect(navTracker.has('PlanPaid'), true);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('价格更新后刷新报价，用户核对后再提交新版本', (t) async {
    await open(t, 'PlanCheckout');
    api.plans[1]['version'] = 2;
    api.plans[1]['fee'] = 130000;
    api.error = const AppError('套餐价格已更新，请刷新后重试');
    await t.ensureVisible(find.text('立即支付'));
    await t.tap(find.text('立即支付'));
    await t.pumpAndSettle();
    expect(api.payments.single['version'], 1);
    expect(navTracker.has('PlanPaid'), false);
    expect(find.text('套餐或订阅已更新，请核对金额后重新提交'), findsOneWidget);
    api.error = null;
    await t.tap(find.text('立即支付'));
    await t.pumpAndSettle();
    expect(api.payments.last['version'], 2);
    expect(
      api.payments.last['requestId'],
      isNot(api.payments.first['requestId']),
    );
    expect(find.text('¥1300.00'), findsOneWidget);
    await t.pump(const Duration(seconds: 9));
  });
  test('清除登录/门店上下文不保留上个账号的订阅回执', () {
    subscriptionFlow.receipt = {'id': 'old-account-order'};
    storeProfile.clear();
    expect(subscriptionFlow.receipt, isEmpty);
    expect(subscriptionFlow.data, isEmpty);
  });
}
