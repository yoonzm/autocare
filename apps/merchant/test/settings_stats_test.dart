import 'package:autocare_merchant/pages/members/member_events.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/shared/settings_page.dart';
import 'package:autocare_merchant/theme.dart';

import 'members_test.dart' show phone;

class SettingsApi extends MerchantApi {
  Map<String, dynamic> counts = {'staff': 2, 'services': 1201, 'cards': 3};
  Completer<void>? gate;
  Object? error;
  Object? profileError;
  Completer<void>? profileGate;
  Map<String, dynamic> profile = {
    'name': '真实门店',
    'contact_name': '李华',
    'contact_role': '老板',
    'phone': '02112345678',
    'account_phone': '+8613812345678',
    'hours_line': '08:30–21:00 · 2 工位 · 统一管理',
  };

  @override
  Future<Map<String, dynamic>> getStore() async {
    await profileGate?.future;
    if (profileError != null) throw profileError!;
    return profile;
  }

  @override
  Future<Map<String, dynamic>> identity(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async => {'name': '赵敏', 'role': 'manager', 'phone': '13712345678'};

  @override
  Future<Map<String, dynamic>> settingsStats() async {
    await gate?.future;
    if (error != null) throw error!;
    return counts;
  }
}

void main() {
  late MerchantApi original;
  late SettingsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = SettingsApi();
    storeProfile.clear();
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
    C.dark = false;
  });
  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: SettingsPage()));
    await t.pump();
  }

  testWidgets('个人卡片使用真实联系人及账号手机，不使用门店电话', (t) async {
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('李华'), findsOneWidget);
    expect(find.text('李'), findsOneWidget);
    expect(find.text('老板'), findsOneWidget);
    expect(find.text('138 **** 5678'), findsOneWidget);
    expect(find.text('真实门店'), findsOneWidget);
    expect(find.text('陈明'), findsNothing);
    expect(find.text('139 **** 8812'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('店长显示自己的身份，不能显示老板的姓名手机号', (t) async {
    Access.apply({'role': 'manager'});
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('赵敏'), findsOneWidget);
    expect(find.text('店长'), findsOneWidget);
    expect(find.text('137 **** 5678'), findsOneWidget);
    expect(find.text('李华'), findsNothing);
    expect(find.text('138 **** 5678'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('深色卡片展示无布局溢出', (t) async {
    C.dark = true;
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('李华'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('个人资料延迟加载及失败重试，不回退演示数据', (t) async {
    api.profileGate = Completer<void>();
    await open(t);
    expect(find.text('陈明'), findsNothing);
    expect(find.byType(AppSkeleton), findsNothing);
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.profileError = const AppError('资料读取失败', type: AppErrorType.server);
    api.profileGate!.complete();
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(t.widget<ErrorView>(find.byType(ErrorView)).error.message, '资料读取失败');
    expect(find.text('李华'), findsNothing);
    api.profileError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('李华'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('真实数量、零值及两种业务变更通知', (t) async {
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('2 人'), findsOneWidget);
    expect(find.text('1201 项'), findsOneWidget);
    expect(find.text('3 种'), findsOneWidget);
    expect(find.text('08:30–21:00 · 2 工位'), findsOneWidget);
    api.counts = {'staff': 0, 'services': 0, 'cards': 0};
    memberChanged.value++;
    await t.pumpAndSettle();
    expect(find.text('0 项'), findsOneWidget);
    expect(find.text('0 种'), findsOneWidget);
    api.counts = {'staff': 5, 'services': 0, 'cards': 0};
    api.profile['hours_line'] = '10:00–22:00 · 3 工位 · 统一管理';
    AppointmentFlow.changed.value++;
    await t.pumpAndSettle();
    expect(find.text('5 人'), findsOneWidget);
    expect(find.text('10:00–22:00 · 3 工位'), findsOneWidget);
    expect(find.text('8 人'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('刷新失败保留旧值并提供重试', (t) async {
    await open(t);
    await t.pumpAndSettle();
    api.error = const AppError('网络不太给力', type: AppErrorType.network);
    memberChanged.value++;
    await t.pumpAndSettle();
    expect(find.text('2 人'), findsOneWidget);
    expect(find.text('1201 项'), findsOneWidget);
    expect(find.text('网络不太给力'), findsOneWidget);
    await t.pump(const Duration(seconds: 9));
  });

  testWidgets('延迟骨架、失败重试且不显示示例数量', (t) async {
    api.gate = Completer<void>();
    await open(t);
    expect(find.byType(AppSkeleton), findsNothing);
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.error = const AppError('读取失败', type: AppErrorType.server);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('36 项'), findsNothing);
    api.error = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('1201 项'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
