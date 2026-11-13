import 'members_test.dart' show row, MemberFakeApi, appFromDetail;
import 'packages_test.dart' show pkgRow;

import 'package:autocare_merchant/backend/merchant_api.dart';

import 'package:autocare_merchant/pages/members/member_route_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:autocare_merchant/routes.dart';

void main() {
  resultCloseTest();
  scanTests();
  pairTests();
  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(390 * 3, 900 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  testWidgets('确认弹窗：取消 / 确定后遮罩完全消失', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(home: ServiceEditPage(initial: {'id': 'service-1'})),
    );
    await t.pumpAndSettle();
    final del = find.text('删除此项目');
    await t.ensureVisible(del);
    await t.tap(del);
    await t.pumpAndSettle();
    expect(find.text('确认删除此项目？'), findsOneWidget);
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(find.text('确认删除此项目？'), findsNothing);
    // 弹窗关闭后只剩页面自己的遮罩（无）
    expect(
      find.byType(ModalBarrier).evaluate().where((e) {
        final b = e.widget as ModalBarrier;
        return b.color != null && b.color != Colors.transparent;
      }),
      isEmpty,
    );
  });

  testWidgets('上传入口：点击弹出“拍照 / 从相册选择”，取消后关闭', (t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(home: Builder(builder: pageBuilders['ProfileEdit']!)),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('更换头像'));
    await t.pumpAndSettle();
    expect(find.text('拍照'), findsOneWidget);
    expect(find.text('从相册选择'), findsOneWidget);
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(find.text('从相册选择'), findsNothing);
  });
}

// 结果页左上角 ✕：回到入口页（结果页禁止侧滑返回，但 ✕ 必须可用）
void resultCloseTest() {
  testWidgets('结果页点左上角关闭回到入口', (t) async {
    t.view.physicalSize = const Size(390 * 3, 900 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    // 测试用字体比真机宽，忽略仅由字体宽度引起的 RenderFlex 溢出
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('入口页'));
          },
        ),
      ),
    );
    openRoute(ctx, 'MemberAddDone', arguments: MemberRouteData(member: row()));
    await t.pumpAndSettle();
    expect(find.text('开卡成功'), findsOneWidget);
    await t.tapAt(const Offset(42, 34));
    await t.pumpAndSettle();
    expect(find.text('开卡成功'), findsNothing);
    expect(find.text('入口页'), findsOneWidget);
  });
}

void scanTests() {
  testWidgets('扫码找会员：只保留车牌识别', (t) async {
    t.view.physicalSize = const Size(390 * 3, 900 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('会员页'));
          },
        ),
      ),
    );
    openRoute(ctx, 'FindScanPlate');
    await t.pumpAndSettle();
    expect(find.text('将车牌对准框内'), findsOneWidget);
    expect(find.text('会员码'), findsNothing);
    expect(find.text('行驶证'), findsNothing);
    expect(find.text('将车牌对准框内'), findsOneWidget);
  });
}

void pairTests() {
  void setup(WidgetTester t) {
    t.view.physicalSize = const Size(390 * 3, 1100 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
  }

  testWidgets('会员充值：储值 / 购买次卡是同一页面的两个 Tab', (t) async {
    setup(t);
    final originalApi = merchantApi;
    final api = MemberFakeApi()..packages.add(pkgRow());
    merchantApi = api;

    addTearDown(() {
      merchantApi = originalApi;
    });
    late BuildContext ctx;
    await t.pumpWidget(
      appFromDetail(
        Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('会员详情'));
          },
        ),
      ),
    );
    openRoute(
      ctx,
      'RechargeCard',
      arguments: MemberRouteData(member: row()),
    ); // 会员详情“购买次卡”：默认选中购买次卡
    await t.pumpAndSettle();
    expect(find.text('选择套餐'), findsOneWidget);
    final depth = navTracker.stack.length;
    await t.tap(find.text('储值充值').first);
    await t.pumpAndSettle();
    expect(navTracker.stack.length, depth); // 没有新开页面
    expect(find.text('自定义金额'), findsOneWidget);
    await t.tap(find.text('购买次卡').first);
    await t.pumpAndSettle();
    expect(find.text('选择套餐'), findsOneWidget);
    expect(navTracker.stack.length, depth);
  });
}
