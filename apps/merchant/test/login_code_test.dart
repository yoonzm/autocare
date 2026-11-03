import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/main.dart';
import 'package:autocare_merchant/backend/store_profile.dart';

import 'members_test.dart' show MemberFakeApi;

class _FakeApi extends MemberFakeApi {
  final List<String> calls = [];
  bool signedIn = false;
  @override
  bool get hasSession => signedIn;
  @override
  Future<Map<String, dynamic>> getStore() async => {'name': '验证码测试门店'};
  @override
  Future<String> sendMockCode(String phone) async {
    calls.add('send:$phone');
    return '482910';
  }

  @override
  Future<void> loginCode(String phone, String code) async {
    calls.add('login:$phone:$code');
    if (code != '482910') throw const AppError('验证码错误');
    signedIn = true;
  }
}

void main() {
  late MerchantApi original;
  late _FakeApi api;
  setUp(() {
    original = merchantApi;
    api = _FakeApi();
    merchantApi = api;
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
  });

  Future<void> open(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const QimeiApp());
  }

  testWidgets('首次打开登录页：手机号为空并显示 placeholder', (t) async {
    await open(t);
    final field = t.widget<TextField>(find.byType(TextField).first);
    expect(field.controller!.text, isEmpty);
    expect(field.decoration!.hintText, '请输入手机号');
    // 手机号为空时点登录：字段下方提示，不请求后端
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pump();
    expect(find.text('请输入手机号'), findsWidgets);
    expect(api.calls, isEmpty);
  });

  testWidgets('验证码登录：空 / 格式错误不请求后端，错误码提示，正确码进入首页', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, '13988888812');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pump();
    expect(find.text('请输入验证码'), findsOneWidget);

    await t.enterText(find.widgetWithText(TextField, '6 位数字'), '12');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pump();
    expect(find.text('验证码为 6 位数字'), findsOneWidget);
    expect(api.calls, isEmpty);

    await t.enterText(find.byType(TextField).at(1), '000000');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    // 不用 pumpAndSettle：它会一直等到提示条自动消失
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    expect(find.textContaining('验证码错误'), findsOneWidget);
    expect(find.text('验证码测试门店'), findsNothing);

    await t.ensureVisible(find.text('获取验证码'));
    await t.tap(find.text('获取验证码'));
    await t.pump();
    expect(find.text('发送中…'), findsOneWidget); // 点击后立即显示加载中
    await t.pump(const Duration(milliseconds: 600));
    await t.pump(const Duration(milliseconds: 300)); // 新提示条滑入
    expect(find.text('开发环境验证码：482910'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
    await t.enterText(find.byType(TextField).at(1), '482910');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pumpAndSettle();
    expect(find.text('验证码测试门店'), findsOneWidget);
    expect(api.calls.last, 'login:13988888812:482910');
  });

  testWidgets('提示条显示在屏幕顶部，不在底部，到时间自动消失', (t) async {
    await open(t);
    await t.enterText(find.byType(TextField).first, '13988888812');
    await t.enterText(find.byType(TextField).at(1), '000000');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pump();
    await t.pump(const Duration(milliseconds: 800));
    final toast = find.textContaining('验证码错误');
    expect(toast, findsOneWidget);
    final y = t.getCenter(toast).dy;
    expect(y, lessThan(120), reason: '屏幕高 844，提示条应在顶部');
    await t.pump(const Duration(seconds: 6)); // 失败提示停留 5 秒
    final left = [
      for (var i = 0; i < toast.evaluate().length; i++)
        t.getCenter(toast.at(i)).dy,
    ];
    expect(left.any((y) => y < 120), isFalse, reason: '到时间后顶部提示条应消失');
  });
}
