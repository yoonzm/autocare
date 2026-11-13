import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/registration_data.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/account/reg_phone_page.dart';
import 'package:autocare_merchant/pages/account/reg_shop_page.dart';
import 'package:autocare_merchant/pages/account/reg_done_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'region_picker_test.dart' show RegionApi;

class _Api extends RegionApi {
  final checks = <(String, String)>[];
  final registrations = <Map<String, dynamic>>[];
  Completer<void>? checkGate, registerGate;
  bool failRegistration = false, failStore = false;
  _Api() {
    this.fail = false;
  }
  @override
  bool get hasSession => true;
  @override
  Future<void> checkCode(String phone, String code) async {
    checks.add((phone, code));
    await checkGate?.future;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String phone,
    required String code,
    required String password,
    required String storeName,
    Map<String, dynamic> profile = const {},
  }) async {
    registrations.add({
      'phone': phone,
      'code': code,
      'password': password,
      'name': storeName,
      ...profile,
    });
    await registerGate?.future;
    if (failRegistration) throw const AppError('开通请求失败');
    return {'services': 7};
  }

  @override
  Future<void> loginPassword(String phone, String password) async {}
  @override
  Future<Map<String, dynamic>> getStore() async {
    if (failStore) throw const AppError('门店读取失败');
    return {'name': '服务端门店名', 'phone': '13800001234'};
  }

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async => [];
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = merchantApi;
    merchantApi = api = _Api();
    storeProfile.clear();
    busyActions.value = {};
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
    busyActions.value = {};
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
            return const Scaffold(body: Text('登录入口'));
          },
        ),
      ),
    );
    return context;
  }

  void push(BuildContext c, Widget page) =>
      Navigator.of(c).push<void>(MaterialPageRoute(builder: (_) => page));
  Future<void> credentials(
    WidgetTester t, {
    String phone = '13800001234',
  }) async {
    await t.enterText(find.byType(TextFormField).at(0), phone);
    await t.enterText(find.byType(TextFormField).at(1), '246810');
    await t.enterText(find.byType(TextFormField).at(2), 'NewPass456');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  }

  Future<void> shop(WidgetTester t) async {
    await t.enterText(find.byType(TextFormField).at(0), '输入门店名');
    await t.enterText(find.byType(TextFormField).at(1), '真实地址');
    await t.enterText(find.byType(TextFormField).at(2), '联系人');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    await t.tap(find.text('请选择所在城市').first);
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
  }

  testWidgets('验证期间防重复，临时凭据显式传给第二步', (t) async {
    final c = await host(t);
    push(c, const RegPhonePage());
    await t.pumpAndSettle();
    await credentials(t);
    api.checkGate = Completer<void>();
    final point = t.getCenter(find.text('下一步'));
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    await t.tapAt(point);
    await t.pump();
    expect(api.checks, [('13800001234', '246810')]);
    api.checkGate!.complete();
    await t.pumpAndSettle();
    final page = t.widget<RegShopPage>(find.byType(RegShopPage));
    expect(page.credentials!.phone, '13800001234');
    expect(page.credentials!.code, '246810');
    expect(page.credentials!.password, 'NewPass456');
  });
  testWidgets('开通失败保留输入并可重试，成功清除敏感表单，展示真实结果', (t) async {
    final c = await host(t);
    push(c, const RegPhonePage());
    await t.pumpAndSettle();
    await credentials(t);
    await t.tap(find.text('下一步'));
    await t.pumpAndSettle();
    await shop(t);
    api.registerGate = Completer<void>();
    api.failRegistration = true;
    final point = t.getCenter(find.text('免费开通'));
    await t.tapAt(point);
    await t.pump();
    expect(t.getSize(find.byType(AppSpinner)), const Size(18, 18));
    await t.tapAt(point);
    await t.pump();
    expect(api.registrations, hasLength(1));
    api.registerGate!.complete();
    await t.pumpAndSettle();
    expect(find.text('开通失败：开通请求失败'), findsWidgets);
    expect(find.widgetWithText(TextFormField, '输入门店名'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    api.registerGate = null;
    api.failRegistration = false;
    await t.tap(find.text('免费开通'));
    await t.pumpAndSettle();
    expect(api.registrations.last, containsPair('province_code', '330000'));
    expect(api.registrations.last, containsPair('phone', '13800001234'));
    expect(find.text('服务端门店名 · 已为您创建店长账号'), findsOneWidget);
    expect(find.text('已按主营业务生成 7 项'), findsOneWidget);
    expect(find.byType(RegPhonePage, skipOffstage: false), findsNothing);
    expect(find.byType(RegShopPage, skipOffstage: false), findsNothing);
  });
  testWidgets('两个注册实例不串用，取消第二个后第一份输入仍在', (t) async {
    final c = await host(t);
    push(c, const RegPhonePage());
    await t.pumpAndSettle();
    await credentials(t);
    push(t.element(find.byType(RegPhonePage)), const RegPhonePage());
    await t.pumpAndSettle();
    expect(
      t
          .widgetList<TextField>(find.byType(TextField))
          .every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
    await credentials(t, phone: '13900005678');
    Navigator.of(t.element(find.byType(RegPhonePage))).pop();
    await t.pumpAndSettle();
    await t.tap(find.text('下一步'));
    await t.pumpAndSettle();
    expect(
      t.widget<RegShopPage>(find.byType(RegShopPage)).credentials!.phone,
      '13800001234',
    );
  });
  testWidgets('资料读取失败不能展示开通成功，缺少凭据的直接入口不能注册', (t) async {
    final c = await host(t);
    push(
      c,
      const RegShopPage(
        credentials: RegistrationCredentials(
          phone: '13800001234',
          code: '246810',
          password: 'NewPass456',
        ),
      ),
    );
    await t.pumpAndSettle();
    await shop(t);
    api.failStore = true;
    await t.tap(find.text('免费开通'));
    await t.pumpAndSettle();
    expect(find.byType(RegDonePage), findsNothing);
    expect(find.text('开通失败：门店读取失败'), findsWidgets);
    Navigator.of(t.element(find.byType(RegShopPage))).pop();
    await t.pumpAndSettle();
    push(c, const RegShopPage());
    await t.pumpAndSettle();
    await t.tap(find.text('免费开通'));
    await t.pumpAndSettle();
    expect(api.registrations, hasLength(1));
    expect(find.text('请先验证注册手机号'), findsWidgets);
    Navigator.of(t.element(find.byType(RegShopPage))).pop();
    await t.pumpAndSettle();
    push(c, const RegDonePage());
    await t.pumpAndSettle();
    expect(find.text('开通成功'), findsNothing);
    expect(find.text('请先完成注册开通'), findsOneWidget);
  });
}
