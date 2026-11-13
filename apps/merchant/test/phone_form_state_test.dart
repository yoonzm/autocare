import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/account/change_phone_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final sms = <(String, String)>[];
  final changes = <(String, String, String)>[];
  Completer<void>? smsGate;
  Completer<void>? changeGate;
  bool failChange = false;
  String phone = '13988888812';
  @override
  bool get hasSession => true;
  @override
  Future<void> sendCode(String phone, {required String purpose}) async {
    sms.add((phone, purpose));
    await smsGate?.future;
  }

  @override
  Future<void> changePhone({
    required String code,
    required String newPhone,
    required String newCode,
  }) async {
    changes.add((code, newPhone, newCode));
    await changeGate?.future;
    if (failChange) throw const AppError('验证码校验失败');
    phone = newPhone;
  }

  @override
  Future<Map<String, dynamic>> getStore() async => {
    'name': '测试门店',
    'phone': phone,
  };
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async => [];
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    storeProfile.apply({'name': '测试门店', 'phone': '13988888812'});
    busyActions.value = {};
  });
  tearDown(() {
    storeProfile.clear();
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
      settings: const RouteSettings(name: 'explicit-phone-form'),
      builder: (_) => const ChangePhonePage(),
    ),
  );

  testWidgets('两次短信发送用途和手机号显式对应，loading、防连点与倒计时互相独立', (t) async {
    final context = await host(t);
    open(context);
    await t.pumpAndSettle();
    api.smsGate = Completer<void>();
    final first = t.getCenter(find.text('获取验证码').first);
    await t.tapAt(first);
    await t.pump();
    expect(find.text('发送中…'), findsOneWidget);
    expect(t.getSize(find.byType(AppSpinner)), const Size(16, 16));
    await t.tapAt(first);
    await t.pump();
    expect(api.sms, [('13988888812', 'change_phone_old')]);
    api.smsGate!.complete();
    await t.pump(const Duration(milliseconds: 700));
    await t.pumpAndSettle();
    expect(find.text('获取验证码'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(1), '13500001111');
    FocusManager.instance.primaryFocus?.unfocus();
    api.smsGate = null;
    await t.tap(find.text('获取验证码'));
    await t.pump(const Duration(milliseconds: 700));
    await t.pumpAndSettle();
    expect(api.sms, [
      ('13988888812', 'change_phone_old'),
      ('13500001111', 'change_phone_new'),
    ]);
    expect(find.textContaining('秒后重发'), findsNWidgets(2));
    Navigator.of(t.element(find.byType(ChangePhonePage))).pop();
    await t.pumpAndSettle();
  });

  testWidgets('短信发送期间离开页面，返回结果不再通知已释放的控制器', (t) async {
    final context = await host(t);
    open(context);
    await t.pumpAndSettle();
    api.smsGate = Completer<void>();
    await t.tap(find.text('获取验证码').first);
    await t.pump();
    Navigator.of(t.element(find.byType(ChangePhonePage))).pop();
    await t.pumpAndSettle();
    api.smsGate!.complete();
    await t.pump(const Duration(milliseconds: 700));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('验证码已发送，请查看短信'), findsNothing);
  });

  testWidgets('变更提交防重复，失败保留三个字段，重试成功刷新手机号', (t) async {
    final context = await host(t);
    final result = open(context);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '111222');
    await t.enterText(find.byType(TextFormField).at(1), '13500001111');
    await t.enterText(find.byType(TextFormField).at(2), '333444');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    api.changeGate = Completer<void>();
    api.failChange = true;
    final center = t.getCenter(find.text('确认更换'));
    await t.tapAt(center);
    await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      t.getSize(find.byType(CircularProgressIndicator)),
      const Size(16, 16),
    );
    await t.tapAt(center);
    await t.pump();
    expect(api.changes, hasLength(1));
    api.changeGate!.complete();
    await t.pumpAndSettle();
    for (final value in ['111222', '13500001111', '333444']) {
      expect(find.widgetWithText(TextFormField, value), findsOneWidget);
    }
    expect(find.text('验证码校验失败'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.changeGate = null;
    api.failChange = false;
    await t.tap(find.text('确认更换'));
    await t.pumpAndSettle();
    expect(await result, isTrue);
    expect(storeProfile.localPhone, '13500001111');
    expect(api.changes.last, ('111222', '13500001111', '333444'));
  });

  testWidgets('手机号表单实例互不覆盖，取消不调用变更接口', (t) async {
    final context = await host(t);
    open(context);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(1), '13500001111');
    FocusManager.instance.primaryFocus?.unfocus();
    open(t.element(find.byType(ChangePhonePage)));
    await t.pumpAndSettle();
    final fields = find.descendant(
      of: find.byType(ChangePhonePage).last,
      matching: find.byType(TextField),
    );
    expect(
      t.widgetList<TextField>(fields).every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
    Navigator.of(t.element(find.byType(ChangePhonePage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '13500001111'), findsOneWidget);
    Navigator.of(t.element(find.byType(ChangePhonePage))).pop();
    await t.pumpAndSettle();
    expect(api.changes, isEmpty);
  });
}
