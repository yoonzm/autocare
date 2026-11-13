import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/kit.dart' show HCheck;
import 'package:autocare_merchant/pages/account/delete_account_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final codes = <String>[];
  final sms = <(String, String)>[];
  Completer<void>? deleteGate, smsGate;
  bool failDelete = true, failSms = true;
  int signOuts = 0;
  @override
  bool get hasSession => true;
  @override
  Future<Map<String, dynamic>> cancellationCheck() async => {
    'holds': 0,
    'appointments': 0,
    'can_cancel': true,
    'billing_note': '限时免费',
    'data_note': '保留数据',
  };
  @override
  Future<void> deleteAccount(String code) async {
    codes.add(code);
    await deleteGate?.future;
    if (failDelete) throw const AppError('仍有未处理预约');
  }

  @override
  Future<void> signOut() async {
    signOuts++;
  }

  @override
  Future<void> sendCode(String phone, {required String purpose}) async {
    sms.add((phone, purpose));
    await smsGate?.future;
    if (failSms) throw const AppError('短信发送失败');
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    storeProfile.apply({'phone': '13800001234', 'name': '测试门店'});
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
            return const Scaffold(body: Text('账号入口'));
          },
        ),
      ),
    );
    Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const DeleteAccountPage()));
    await t.pumpAndSettle();
    return context;
  }

  Future<void> fill(WidgetTester t) async {
    await t.enterText(find.byType(TextFormField), '246810');
    await t.tap(find.byType(HCheck));
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  }

  testWidgets('注销请求防重复，后端拒绝保留输入且不能退出，成功才导航登录', (t) async {
    await host(t);
    await fill(t);
    api.deleteGate = Completer<void>();
    final point = t.getCenter(find.text('申请注销'));
    await t.tapAt(point);
    await t.pump();
    expect(
      t.getSize(find.byType(CircularProgressIndicator)),
      const Size(16, 16),
    );
    await t.tapAt(point);
    await t.pump();
    expect(api.codes, ['246810']);
    api.deleteGate!.complete();
    await t.pumpAndSettle();
    expect(find.text('仍有未处理预约'), findsWidgets);
    expect(api.signOuts, 0);
    expect(find.widgetWithText(TextFormField, '246810'), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.deleteGate = null;
    api.failDelete = false;
    await t.tap(find.text('申请注销'));
    await t.pumpAndSettle();
    expect(api.signOuts, 1);
    expect(find.byType(DeleteAccountPage, skipOffstage: false), findsNothing);
  });
  testWidgets('发送验证码防重复，失败不倒计时且可重试，销毁期间完成不更新页面', (t) async {
    final c = await host(t);
    api.smsGate = Completer<void>();
    final point = t.getCenter(find.text('获取验证码'));
    await t.tapAt(point);
    await t.pump();
    expect(find.text('发送中…'), findsOneWidget);
    await t.tapAt(point);
    await t.pump();
    expect(api.sms, [('13800001234', 'delete_account')]);
    api.smsGate!.complete();
    await t.pumpAndSettle();
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.text('短信发送失败'), findsWidgets);
    api.smsGate = Completer<void>();
    api.failSms = false;
    await t.tap(find.text('获取验证码'));
    await t.pump();
    Navigator.of(c).pop();
    await t.pumpAndSettle();
    api.smsGate!.complete();
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(api.sms, hasLength(2));
  });
  testWidgets('不同注销实例不共享验证码和确认勾选', (t) async {
    await host(t);
    await fill(t);
    final c = t.element(find.byType(DeleteAccountPage));
    Navigator.of(
      c,
    ).push<void>(MaterialPageRoute(builder: (_) => const DeleteAccountPage()));
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(t.widget<HCheck>(find.byType(HCheck)).value, isFalse);
    Navigator.of(t.element(find.byType(DeleteAccountPage))).pop();
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      '246810',
    );
    expect(t.widget<HCheck>(find.byType(HCheck)).value, isTrue);
  });
}
