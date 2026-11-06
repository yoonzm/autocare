import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/settings_page.dart';

import 'members_test.dart' show phone;

class SettingsApi extends MerchantApi {
  Map<String, dynamic> counts = {'staff': 2, 'services': 1201, 'cards': 3};
  Completer<void>? gate;
  Object? error;
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
  });
  tearDown(() {
    merchantApi = original;
  });
  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: SettingsPage()));
    await t.pump();
  }

  testWidgets('真实数量、零值及两种业务变更通知', (t) async {
    await open(t);
    await t.pumpAndSettle();
    expect(find.text('2 人'), findsOneWidget);
    expect(find.text('1201 项'), findsOneWidget);
    expect(find.text('3 种'), findsOneWidget);
    api.counts = {'staff': 0, 'services': 0, 'cards': 0};
    CatalogDraft.changed.value++;
    await t.pumpAndSettle();
    expect(find.text('0 项'), findsOneWidget);
    expect(find.text('0 种'), findsOneWidget);
    api.counts = {'staff': 5, 'services': 0, 'cards': 0};
    AppointmentFlow.changed.value++;
    await t.pumpAndSettle();
    expect(find.text('5 人'), findsOneWidget);
    expect(find.text('8 人'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('刷新失败保留旧值并提供重试', (t) async {
    await open(t);
    await t.pumpAndSettle();
    api.error = const AppError('网络不太给力', type: AppErrorType.network);
    CatalogDraft.changed.value++;
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
