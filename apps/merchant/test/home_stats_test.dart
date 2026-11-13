import 'package:autocare_merchant/pages/members/member_events.dart';
import 'dart:async';

import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/shared/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class StatsApi extends MemberFakeApi {
  Object? error;
  Completer<void>? wait;
  Map<String, dynamic> stats = {
    'date': '2026-11-03',
    'revenue': 1234.56,
    'orders': 4,
    'new_members': 2,
    'average': 308.64,
    'change_percent': -12.5,
    'daily_revenue': [0, 100, 200, 0, 500, 300, 1234.56],
    'recharge': 600,
  };
  @override
  Future<Map<String, dynamic>> homeStats() async {
    await wait?.future;
    if (error != null) throw error!;
    return stats;
  }
}

void main() {
  late MerchantApi original;
  late StatsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = StatsApi();
    HoldStore.reset();
  });
  tearDown(() {
    merchantApi = original;
    HoldStore.reset();
  });
  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: HomePage()));
  }

  testWidgets('统计金额、计数、同比和充值来自后端，保持卡片尺寸', (t) async {
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('1,234.56'), findsOneWidget);
    expect(find.text('¥308.64'), findsOneWidget);
    expect(find.text('较上周二 -12.5%'), findsOneWidget);
    expect(find.text('今日 ¥600.00'), findsOneWidget);
    expect(find.text('12,860.00'), findsNothing);
    expect(
      t.getSize(find.byKey(const ValueKey('home-revenue-card'))).height,
      197,
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('首次慢请求显示统一骨架，失败后可重试，零值不回退示例', (t) async {
    api.wait = Completer<void>();
    await open(t);
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.error = const AppError('读取失败', type: AppErrorType.server);
    api.wait!.complete();
    await t.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);
    api.error = null;
    api.stats = await MemberFakeApi().homeStats();
    await t.ensureVisible(find.text('重试'));
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('¥0.00'), findsOneWidget);
    expect(find.text('较上周二 —'), findsOneWidget);
    expect(find.text('12,860.00'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('刷新失败保留统计和充值旧值', (t) async {
    await open(t);
    await t.pumpAndSettle();
    api.error = const AppError('网络不稳定', type: AppErrorType.network);
    final refresh = t.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    await refresh.onRefresh();
    await t.pump();
    expect(find.text('1,234.56'), findsOneWidget);
    expect(find.text('今日 ¥600.00'), findsOneWidget);
    expect(find.text('网络不稳定'), findsOneWidget);
    await t.pump(const Duration(seconds: 9));
  });

  testWidgets('已有业务保存通知后自动更新统计', (t) async {
    await open(t);
    await t.pumpAndSettle();
    api.stats = {...api.stats, 'revenue': 2468, 'recharge': 900};
    memberChanged.value++;
    await t.pumpAndSettle();
    expect(find.text('2,468.00'), findsOneWidget);
    expect(find.text('今日 ¥900.00'), findsOneWidget);
  });

  testWidgets('退出首页后丢弃迟到的统计结果', (t) async {
    api.wait = Completer<void>();
    await open(t);
    await t.pump(const Duration(milliseconds: 301));
    await t.pumpWidget(const SizedBox());
    api.wait!.complete();
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
  });
}
