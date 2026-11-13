import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/text_input.dart';
import 'package:autocare_merchant/pages/account/change_password_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final requests = <(String, String)>[];
  Completer<void>? gate;
  bool fail = false;
  @override
  bool get hasSession => true;
  @override
  Future<void> changePassword(String current, String next) async {
    requests.add((current, next));
    await gate?.future;
    if (fail) throw const AppError('当前密码错误');
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    busyActions.value = {};
  });
  tearDown(() {
    merchantApi = original;
    busyActions.value = {};
  });

  Future<BuildContext> host(WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2700);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('账号与安全'));
          },
        ),
      ),
    );
    return context;
  }

  Future<bool?> open(BuildContext context) => Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => const ChangePasswordPage(),
      settings: const RouteSettings(name: 'explicit-password-form'),
    ),
  );

  Future<void> fill(WidgetTester t, String current, String next) async {
    await t.enterText(find.byType(TextFormField).at(0), current);
    await t.enterText(find.byType(TextFormField).at(1), next);
    await t.enterText(find.byType(TextFormField).at(2), next);
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  }

  testWidgets('密码可见性显式对应各输入框，不依赖页面名或祖先查找', (t) async {
    final context = await host(t);
    open(context);
    await t.pumpAndSettle();
    List<bool> visibility() => t
        .widgetList<TextField>(find.byType(TextField))
        .map((w) => w.obscureText)
        .toList();
    expect(visibility(), [true, true, true]);
    await t.tap(find.byType(PasswordVisibilityButton).at(1));
    await t.pump();
    expect(visibility(), [true, false, true]);
    await t.tap(find.byType(PasswordVisibilityButton).at(0));
    await t.pump();
    expect(visibility(), [false, false, true]);
    await t.tap(find.byType(PasswordVisibilityButton).at(1));
    await t.pump();
    expect(visibility(), [false, true, true]);
  });

  testWidgets('提交有 loading 且防重复，失败保留输入，重试成功返回', (t) async {
    final context = await host(t);
    final result = open(context);
    await t.pumpAndSettle();
    await fill(t, 'OldPass123', 'NewPass456');
    final button = find
        .ancestor(of: find.text('确认修改'), matching: find.byType(Container))
        .first;
    final before = t.getSize(button);
    final center = t.getCenter(button);
    api.gate = Completer<void>();
    api.fail = true;
    await t.tapAt(center);
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    expect(find.text('提交中…'), findsOneWidget);
    final loadingButton = find
        .ancestor(of: find.byType(AppSpinner), matching: find.byType(Container))
        .first;
    expect(t.getSize(loadingButton), before);
    await t.tapAt(center);
    await t.pump();
    expect(api.requests, hasLength(1));
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('当前密码错误'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'OldPass123'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'NewPass456'), findsNWidgets(2));
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.gate = null;
    api.fail = false;
    await t.tap(find.text('确认修改'));
    await t.pumpAndSettle();
    expect(await result, isTrue);
    expect(api.requests, [
      ('OldPass123', 'NewPass456'),
      ('OldPass123', 'NewPass456'),
    ]);
  });

  testWidgets('两个密码表单互不覆盖，取消不调用修改接口', (t) async {
    final context = await host(t);
    open(context);
    await t.pumpAndSettle();
    await fill(t, 'OldPass123', 'NewPass456');
    open(t.element(find.byType(ChangePasswordPage)));
    await t.pumpAndSettle();
    final second = find.descendant(
      of: find.byType(ChangePasswordPage).last,
      matching: find.byType(TextField),
    );
    expect(
      t.widgetList<TextField>(second).every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
    Navigator.of(t.element(find.byType(ChangePasswordPage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'OldPass123'), findsOneWidget);
    Navigator.of(t.element(find.byType(ChangePasswordPage))).pop();
    await t.pumpAndSettle();
    expect(api.requests, isEmpty);
  });
}
