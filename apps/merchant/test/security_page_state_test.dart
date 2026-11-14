import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/account/security_page.dart';
import 'package:autocare_merchant/pages/account/terms_page.dart';
import 'package:autocare_merchant/pages/account/legal_web_page.dart';
import 'package:autocare_merchant/pages/account/privacy_page.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'account_tools_test.dart' show ToolsApi;

class _Api extends ToolsApi {
  Completer<void>? gate;
  bool fail = true;
  int exits = 0;
  @override
  Future<void> signOutAll() async {
    exits++;
    await gate?.future;
    if (fail) throw const AppError('退出请求失败');
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    busyActions.value = {};
    storeProfile.clear();
  });
  tearDown(() {
    merchantApi = original;
    busyActions.value = {};
    storeProfile.clear();
  });
  Future<BuildContext> host(WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 4500);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('账号入口'));
          },
        ),
      ),
    );
    return context;
  }

  void push(BuildContext c, Widget page) =>
      Navigator.of(c).push<void>(MaterialPageRoute(builder: (_) => page));
  testWidgets('退出所有设备显示原按钮 loading，防重复，失败可重试，成功清理导航栈', (t) async {
    final c = await host(t);
    push(c, const SecurityPage());
    await t.pumpAndSettle();
    expect(find.text('139 **** 8812'), findsNothing);
    api.gate = Completer<void>();
    final point = t.getCenter(find.text('退出所有设备'));
    final size = t.getSize(
      find
          .ancestor(of: find.text('退出所有设备'), matching: find.byType(Container))
          .first,
    );
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    final loadingSize = t.getSize(
      find
          .ancestor(
            of: find.byType(AppSpinner),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(loadingSize, size);
    await t.tapAt(point);
    await t.pump();
    expect(api.exits, 1);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('退出失败：退出请求失败'), findsWidgets);
    expect(find.byType(SecurityPage), findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.gate = null;
    api.fail = false;
    await t.tap(find.text('退出所有设备'));
    await t.pumpAndSettle();
    expect(api.exits, 2);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(SecurityPage, skipOffstage: false), findsNothing);
    expect(find.text('账号入口', skipOffstage: false), findsNothing);
  });
  testWidgets('协议页使用显式返回回调，不需要路由名识别页面', (t) async {
    legalWebViewBuilder = (url, headers, onLoaded, onError) {
      Future.microtask(onLoaded);
      return const SizedBox();
    };
    addTearDown(() => legalWebViewBuilder = legalNativeWebViewBuilder);
    final c = await host(t);
    for (final page in [const TermsPage(), const PrivacyPage()]) {
      push(c, page);
      await t.pumpAndSettle();
      final control = find
          .descendant(
            of: find.byWidget(page),
            matching: find.byType(GestureDetector),
          )
          .first;
      await t.tap(control);
      await t.pumpAndSettle();
      expect(find.text('账号入口'), findsOneWidget);
    }
    expect(api.exits, 0);
  });
}
