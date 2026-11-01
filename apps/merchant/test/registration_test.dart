import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/kit/kit.dart' show HCheck;
import 'package:autocare_merchant/pages/gen/gen_routes.dart';

/// 记录调用的假后端。
class _FakeApi extends MerchantApi {
  final List<String> calls = [];
  bool codeValid = true;
  @override
  bool get hasSession => false;
  @override
  Future<void> checkCode(String phone, String code) async {
    calls.add('check:$phone:$code');
    if (!codeValid) throw const AppError('验证码错误');
  }
}

void main() {
  late _FakeApi api;
  late MerchantApi original;

  setUp(() {
    original = merchantApi;
    api = _FakeApi();
    merchantApi = api;
    RegistrationDraft.clear();
  });
  tearDown(() => merchantApi = original);

  Future<void> openReg(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 1200 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        initialRoute: 'RegPhone',
        onGenerateRoute: (s) => MaterialPageRoute(
          settings: s,
          builder: (_) => Builder(builder: genRoutes[s.name]!),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> next(WidgetTester t) async {
    await t.ensureVisible(find.text('下一步'));
    await t.tap(find.text('下一步'));
    await t.pump(); // 弹出提示
    await t.pump(const Duration(milliseconds: 700)); // 异步动作的 loading 至少 500ms
  }

  testWidgets('免费开通第一页：什么都没填不能进入下一步', (t) async {
    await openReg(t);
    await next(t);
    expect(find.text('请输入手机号'), findsWidgets);
    expect(find.text('门店信息'), findsNothing);
    expect(api.calls, isEmpty);
  });

  testWidgets('免费开通第一页：逐项校验手机号 / 验证码 / 密码 / 协议', (t) async {
    await openReg(t);
    Future<void> type(String hint, String v) async => t.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == hint,
      ),
      v,
    );

    await type('请输入手机号', '12345');
    await next(t);
    expect(find.text('请输入正确的 11 位手机号'), findsOneWidget);

    await type('请输入手机号', '13800138000');
    await next(t);
    await t.pump(const Duration(seconds: 4));
    expect(find.text('请输入验证码'), findsOneWidget);

    await type('6 位数字', '123');
    await next(t);
    await t.pump(const Duration(seconds: 4));
    expect(find.text('验证码为 6 位数字'), findsOneWidget);

    await type('6 位数字', '123456');
    await type('8-20 位，含字母和数字', 'abc');
    await next(t);
    await t.pump(const Duration(seconds: 4));
    expect(find.text('密码需 8–20 位'), findsOneWidget);

    await type('8-20 位，含字母和数字', 'abcdefgh');
    await next(t);
    await t.pump(const Duration(seconds: 4));
    expect(find.text('密码需同时包含字母和数字'), findsOneWidget);

    await type('8-20 位，含字母和数字', 'abcd1234');
    // 设计稿里协议默认已勾选；取消勾选后不能继续
    await t.ensureVisible(find.byType(HCheck));
    await t.tap(find.byType(HCheck));
    await t.pump();
    await next(t);
    await t.pump(const Duration(seconds: 4));
    expect(find.text('请先阅读并同意用户服务协议和隐私政策'), findsOneWidget);
    expect(api.calls, isEmpty); // 本地校验未过时不请求后端
  });

  testWidgets('免费开通第一页：表单合法后向后端校验验证码，错误则留在本页', (t) async {
    await openReg(t);
    Future<void> type(String hint, String v) async => t.enterText(
      find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == hint,
      ),
      v,
    );
    await type('请输入手机号', '13800138000');
    await type('6 位数字', '654321');
    await type('8-20 位，含字母和数字', 'abcd1234');
    api.codeValid = false;
    await next(t);
    await t.pump();
    expect(api.calls, ['check:13800138000:654321']);
    expect(find.text('验证码错误'), findsOneWidget);
    expect(find.text('门店信息'), findsNothing);
  });

  testWidgets('密码小眼睛：点击切换明文 / 密文', (t) async {
    await openReg(t);
    final pwd = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '8-20 位，含字母和数字',
    );
    bool obscured() => t.widget<TextField>(pwd).obscureText;
    expect(obscured(), isTrue);
    await t.ensureVisible(find.bySemanticsLabel('显示密码'));
    await t.tap(find.bySemanticsLabel('显示密码'));
    await t.pump();
    expect(obscured(), isFalse);
    await t.tap(find.bySemanticsLabel('隐藏密码'));
    await t.pump();
    expect(obscured(), isTrue);
  });
}
