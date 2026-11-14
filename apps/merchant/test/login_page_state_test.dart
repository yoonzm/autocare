import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/account/access_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi;

class _Api extends MemberFakeApi {
  Completer<void>? smsGate, loginGate;
  Object? smsError;
  bool failLogin = true;
  final sent = <(String, String)>[];
  final passwords = <(String, String)>[];
  @override
  bool get hasSession => false;
  @override
  Future<void> sendCode(String phone, {required String purpose}) async {
    sent.add((phone, purpose));
    await smsGate?.future;
    if (smsError != null) throw smsError!;
  }

  @override
  Future<void> loginPassword(String phone, String password) async {
    passwords.add((phone, password));
    await loginGate?.future;
    if (failLogin) throw const AppError('账号或密码错误');
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    storeProfile.clear();
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
  });
  Future<void> open(WidgetTester t, {int tab = 0}) async {
    t.view.physicalSize = const Size(1170, 3600);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: LoginPage(initialTab: tab)));
    await t.pumpAndSettle();
  }

  testWidgets('密码登录防重复并锁定表单，失败保留输入且可重试', (t) async {
    await open(t, tab: 1);
    await t.enterText(find.byType(TextField).at(0), '13800001234');
    await t.enterText(find.byType(TextField).at(1), 'NewPass456');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    api.loginGate = Completer<void>();
    final point = t.getCenter(find.text('登录').first);
    await t.tapAt(point);
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(
      t.widgetList<TextField>(find.byType(TextField)).every((w) => w.readOnly),
      isTrue,
    );
    await t.tapAt(point);
    await t.pump();
    expect(api.passwords, [('13800001234', 'NewPass456')]);
    api.loginGate!.complete();
    await t.pumpAndSettle();
    expect(find.text('账号或密码错误'), findsWidgets);
    expect(find.widgetWithText(TextField, 'NewPass456'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.loginGate = null;
    await t.tap(find.text('登录').first);
    await t.pumpAndSettle();
    expect(api.passwords, hasLength(2));
  });
  testWidgets('验证码请求用途明确且防重复，销毁页面后完成不启动倒计时或回调', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, '13800001234');
    api.smsGate = Completer<void>();
    final point = t.getCenter(find.text('获取验证码'));
    await t.tapAt(point);
    await t.pump();
    expect(find.text('发送中…'), findsOneWidget);
    await t.tapAt(point);
    await t.pump();
    expect(api.sent, [('13800001234', 'login')]);
    await t.pumpWidget(const SizedBox());
    await t.pump();
    api.smsGate!.complete();
    await t.pump(const Duration(seconds: 2));
    expect(t.takeException(), isNull);
  });
  testWidgets('未登记手机号的错误页使用本次发送号码，不被后来输入覆盖', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, '13800001234');
    api.smsGate = Completer<void>();
    api.smsError = const AppError('手机号未登记', code: 'phone_unregistered');
    await t.tap(find.text('获取验证码'));
    await t.pump();
    await t.enterText(find.byType(TextField).first, '13900005678');
    api.smsGate!.complete();
    await t.pumpAndSettle();
    expect(
      t.widget<StAuthFailTemplate>(find.byType(StAuthFailTemplate)).phone,
      '13800001234',
    );
  });
}
