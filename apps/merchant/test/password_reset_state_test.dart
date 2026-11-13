import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/password_reset_challenge.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/account/forgot_done_page.dart';
import 'package:autocare_merchant/pages/account/forgot_reset_page.dart';
import 'package:autocare_merchant/pages/account/forgot_verify_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final verifications = <(String, String)>[];
  final resets = <(String, String, String)>[];
  Completer<void>? verifyGate;
  Completer<void>? resetGate;
  bool failReset = false;
  @override
  bool get hasSession => false;
  @override
  Future<void> forgotVerify(String phone, String code) async {
    verifications.add((phone, code));
    await verifyGate?.future;
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    resets.add((phone, code, newPassword));
    await resetGate?.future;
    if (failReset) throw const AppError('重置失败，请重试');
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
    t.view.physicalSize = const Size(1170, 3300);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('登录入口'));
          },
        ),
      ),
    );
    return context;
  }

  void push(BuildContext context, Widget page) => Navigator.of(context)
      .push<void>(
        MaterialPageRoute(
          builder: (_) => page,
          settings: const RouteSettings(name: 'explicit-reset-step'),
        ),
      );
  Future<void> newPassword(WidgetTester t) async {
    await t.enterText(find.byType(TextFormField).at(0), 'NewPass456');
    await t.enterText(find.byType(TextFormField).at(1), 'NewPass456');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  }

  testWidgets('验证手机号期间显示 loading、防重复，并向下一页传递独立校验数据', (t) async {
    final context = await host(t);
    push(context, const ForgotVerifyPage());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '13800001234');
    await t.enterText(find.byType(TextFormField).at(1), '246810');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    api.verifyGate = Completer<void>();
    final point = t.getCenter(find.text('下一步'));
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    await t.tapAt(point);
    await t.pump();
    expect(api.verifications, [('13800001234', '246810')]);
    api.verifyGate!.complete();
    await t.pumpAndSettle();
    final reset = t.widget<ForgotResetPage>(find.byType(ForgotResetPage));
    expect(reset.challenge!.phone, '13800001234');
    expect(reset.challenge!.code, '246810');
    expect(find.text('手机号 138 **** 1234 已验证通过'), findsOneWidget);
  });

  testWidgets('重置失败保留输入，提交防重复，成功后移除包含敏感输入的两个页面', (t) async {
    final context = await host(t);
    push(context, const ForgotVerifyPage());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '13800001234');
    await t.enterText(find.byType(TextFormField).at(1), '246810');
    await t.tap(find.text('下一步'));
    await t.pumpAndSettle();
    await newPassword(t);
    api.resetGate = Completer<void>();
    api.failReset = true;
    final point = t.getCenter(find.text('确认重置'));
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    await t.tapAt(point);
    await t.pump();
    expect(api.resets, hasLength(1));
    api.resetGate!.complete();
    await t.pumpAndSettle();
    expect(find.text('重置失败，请重试'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'NewPass456'), findsNWidgets(2));
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.resetGate = null;
    api.failReset = false;
    await t.tap(find.text('确认重置'));
    await t.pumpAndSettle();
    expect(find.text('密码已重置'), findsOneWidget);
    expect(find.byType(ForgotResetPage, skipOffstage: false), findsNothing);
    expect(find.byType(ForgotVerifyPage, skipOffstage: false), findsNothing);
    expect(api.resets.last, ('13800001234', '246810', 'NewPass456'));
  });

  testWidgets('不同重置页面的验证码与新密码不串用，取消第二个页面保留第一个', (t) async {
    final context = await host(t);
    push(
      context,
      const ForgotResetPage(
        challenge: PasswordResetChallenge(phone: '13800001234', code: '111222'),
      ),
    );
    await t.pumpAndSettle();
    await newPassword(t);
    push(
      t.element(find.byType(ForgotResetPage)),
      const ForgotResetPage(
        challenge: PasswordResetChallenge(phone: '13900005678', code: '333444'),
      ),
    );
    await t.pumpAndSettle();
    final second = find.descendant(
      of: find.byType(ForgotResetPage).last,
      matching: find.byType(TextField),
    );
    expect(
      t.widgetList<TextField>(second).every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
    Navigator.of(t.element(find.byType(ForgotResetPage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, 'NewPass456'), findsNWidgets(2));
    await t.tap(find.text('确认重置'));
    await t.pumpAndSettle();
    expect(api.resets, [('13800001234', '111222', 'NewPass456')]);
  });

  testWidgets('未经验证不展示已验证文案，也不能发起重置或伪造成功页', (t) async {
    final context = await host(t);
    push(context, const ForgotResetPage());
    await t.pumpAndSettle();
    expect(find.textContaining('已验证通过'), findsNothing);
    await newPassword(t);
    await t.tap(find.text('确认重置'));
    await t.pumpAndSettle();
    expect(find.text('请先验证手机号'), findsWidgets);
    expect(api.resets, isEmpty);
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(const MaterialApp(home: ForgotDonePage()));
    await t.pumpAndSettle();
    expect(find.text('密码已重置'), findsNothing);
    expect(find.text('请先完成密码重置'), findsWidgets);
  });
}
