import 'package:flutter/cupertino.dart' show CupertinoSheetRoute;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = MemberFakeApi();


    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => openRoute(context, 'MemberAdd'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  testWidgets('新增会员是 iOS 整页 sheet：顶部露出上一页，页面名仍是 MemberAdd', (t) async {
    await open(t);
    expect(find.text('新增会员'), findsOneWidget);
    expect(navTracker.has('MemberAdd'), isTrue);
    final route = ModalRoute.of(t.element(find.text('新增会员')));
    expect(route, isA<CupertinoSheetRoute<void>>());
    // 上一页仍在树里（露出在 sheet 顶部缩小显示）
    expect(find.text('open', skipOffstage: false), findsOneWidget);
  });

  testWidgets('sheet 打开后下面的上一页不缩放、位置不变', (t) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => openRoute(context, 'MemberAdd'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final before = t.getRect(find.text('open'));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(t.getRect(find.text('open', skipOffstage: false)), before);
  });

  testWidgets('从标题栏处往下拖拽可以关闭 sheet，回到上一页', (t) async {
    await open(t);
    await t.drag(find.text('新增会员'), const Offset(0, 700));
    await t.pumpAndSettle();
    expect(find.text('新增会员'), findsNothing);
    expect(navTracker.has('MemberAdd'), isFalse);
    expect(find.text('open'), findsOneWidget);
  });
}
