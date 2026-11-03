import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/booking_resources_page.dart';
import 'package:autocare_merchant/pages/staff_skeletons.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;
import 'package:autocare_merchant/widgets/choice_chip_group.dart';

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

void main() {
  late MerchantApi original;
  late BookingApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = BookingApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  Future<void> open(WidgetTester t, Widget page, {bool settle = true}) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(builder: (_) => const Scaffold()),
          MaterialPageRoute(builder: (_) => page),
        ],
      ),
    );
    if (settle) {
      await t.pumpAndSettle();
    } else {
      await t.pump();
    }
  }

  testWidgets('员工列表首次加载：标题栏和角色页签立即显示，骨架贴合列表而不是通用卡片', (t) async {
    api.optionsGate = Completer<void>();
    await open(
      t,
      const BookingResourcesPage(kind: 'technician'),
      settle: false,
    );
    // 300ms 延迟内：只有外壳，没有灰块
    expect(find.text('员工与权限'), findsOneWidget);
    expect(find.text('施工技师'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNothing);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(ResourceSkeleton), findsOneWidget);
    expect(find.byType(AppSkeleton), findsWidgets);
    expect(find.text('员工与权限'), findsOneWidget);
    expect(find.byType(SkeletonDataPage), findsNothing);
    api.optionsGate!.complete();
    await t.pumpAndSettle();
    expect(find.byType(ResourceSkeleton), findsNothing);
    expect(find.textContaining('真实技师'), findsOneWidget);
  });

  testWidgets('员工列表的角色页签是分段条，不套单选标签（ChoiceChip）样式', (t) async {
    await open(t, const BookingResourcesPage(kind: 'technician'));
    expect(find.byType(ChoiceChipGroup<int>), findsNothing);
    await t.tap(find.textContaining('施工技师'));
    await t.pumpAndSettle();
    expect(find.textContaining('真实技师'), findsOneWidget);
  });

  testWidgets('从列表进入新增 / 编辑员工：直接显示表单，不再整页等待或出骨架', (t) async {
    await open(t, const BookingResourcesPage(kind: 'technician'));
    final before = api.calls.where((c) => c['action'] == 'options').length;
    api.optionsGate = Completer<void>(); // 即使再读选项被卡住，也不影响编辑页
    await t.tap(find.textContaining('真实技师'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(ResourceSkeleton), findsNothing);
    expect(find.text('编辑员工'), findsOneWidget);
    expect(find.textContaining('真实技师'), findsWidgets);
    expect(api.calls.where((c) => c['action'] == 'options').length, before);
    api.optionsGate!.complete();
    await t.pumpAndSettle();
  });

  testWidgets('新增员工的入职日期按设计稿显示为 2026.11.01 格式', (t) async {
    await open(t, const BookingResourceEditor(kind: 'technician'));
    final dates = find.byWidgetPredicate(
      (w) =>
          w is TextFormField &&
          RegExp(r'^\d{4}\.\d{2}\.\d{2}$')
              .hasMatch((w.controller?.text ?? w.initialValue ?? '')),
    );
    expect(dates, findsOneWidget);
  });

  testWidgets('直接打开编辑页（没有带入选项）时用与表单同形状的骨架并保留标题栏', (t) async {
    api.optionsGate = Completer<void>();
    await open(
      t,
      const BookingResourceEditor(kind: 'technician'),
      settle: false,
    );
    expect(find.text('新增员工'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byType(ResourceSkeleton), findsOneWidget);
    expect(find.text('新增员工'), findsOneWidget);
    api.optionsGate!.complete();
    await t.pumpAndSettle();
    expect(find.byType(ResourceSkeleton), findsNothing);
  });
}
