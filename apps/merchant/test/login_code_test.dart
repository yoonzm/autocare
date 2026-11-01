import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/main.dart';

class _FakeApi extends MerchantApi {
  final List<String> calls = [];
  @override
  bool get hasSession => false;
  @override
  Future<String> sendMockCode(String phone) async {
    calls.add('send:$phone');
    return '482910';
  }

  @override
  Future<void> loginCode(String phone, String code) async {
    calls.add('login:$phone:$code');
    if (code != '482910') throw const AppError('验证码错误');
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
  tearDown(() => merchantApi = original);

  Future<void> open(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(const QimeiApp());
  }

  testWidgets('验证码登录：空 / 格式错误不请求后端，错误码提示，正确码进入首页', (t) async {
    await open(t);
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
    await t.pumpAndSettle();
    expect(find.textContaining('验证码错误'), findsOneWidget);
    expect(find.text('驰光汽车美容'), findsNothing);

    await t.ensureVisible(find.text('获取验证码'));
    await t.tap(find.text('获取验证码'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('开发环境验证码：482910'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
    await t.enterText(find.byType(TextField).at(1), '482910');
    await t.ensureVisible(find.text('登录').first);
    await t.tap(find.text('登录').first);
    await t.pumpAndSettle();
    expect(find.text('驰光汽车美容'), findsOneWidget);
    expect(api.calls.last, 'login:13988888812:482910');
  });
}
