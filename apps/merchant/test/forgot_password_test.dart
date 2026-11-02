import 'package:autocare_merchant/backend/forgot_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart' show AppSpinner;
import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/pages/login_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 忘记密码：登录页和修改密码页两个入口共用 验证手机号 -> 设置新密码 -> 重置成功。
class _Api extends MerchantApi {
  final List<String> calls = [];
  bool signedIn = false;
  Object? verifyError;
  Object? resetError;
  Object? sendError;
  @override
  bool get hasSession => signedIn;
  @override
  Future<String> sendMockCode(String phone) async {
    calls.add('send:$phone');
    if (sendError != null) throw sendError!;
    return '246810';
  }

  @override
  Future<void> forgotVerify(String phone, String code) async {
    calls.add('verify:$phone:$code');
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    calls.add('reset:$phone:$code:$newPassword');
    if (resetError != null) throw resetError!;
  }

  @override
  Future<void> signOut() async => calls.add('signOut');
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    api = _Api();
    merchantApi = api;
    RegistrationDraft.clear();
    forgotFlow.clear();
    storeProfile.clear();
    navTracker.stack.clear(); // 全局路由记录会残留上一个测试的页面
  });
  tearDown(() {
    merchantApi = original;
    forgotFlow.clear();
  });

  Future<void> open(WidgetTester t, String route) async {
    t.view.physicalSize = const Size(390 * 3, 1200 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(const SizedBox()); // 先丢弃上一个测试留下的页面（释放输入框序号）
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        initialRoute: route,
        onGenerateRoute: (s) => MaterialPageRoute(
          settings: s,
          builder: (_) => s.name == 'Login'
              ? const LoginPage()
              : Builder(builder: genRoutes[s.name]!),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Finder input(String hint) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );

  Future<void> tapText(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text));
    await t.tap(find.text(text));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 700)); // loading 至少 500ms
    await t.pumpAndSettle(); // 等页面跳转完成
  }

  Future<void> toVerified(WidgetTester t) async {
    await open(t, 'ForgotVerify');
    await t.enterText(input('请输入手机号'), '13800001234');
    await t.enterText(input('6 位数字'), '246810');
    await tapText(t, '下一步');
  }

  group('第 1 步 · 验证手机号', () {
    testWidgets('从空白开始，设计稿里的示例手机号 / 验证码不会预填', (t) async {
      await open(t, 'ForgotVerify');
      expect(t.widget<TextField>(input('请输入手机号')).controller!.text, isEmpty);
      expect(t.widget<TextField>(input('6 位数字')).controller!.text, isEmpty);
      expect(find.text('获取验证码'), findsOneWidget); // 不是示例里的“42s 后重发”
    });

    testWidgets('获取验证码：手机号不对不请求；正确则发到手动输入的号码并倒计时', (t) async {
      await open(t, 'ForgotVerify');
      await t.enterText(input('请输入手机号'), '123');
      await t.tap(find.text('获取验证码'));
      await t.pump();
      expect(find.text('请输入正确的 11 位手机号'), findsOneWidget);
      expect(api.calls, isEmpty);
      await t.pump(const Duration(seconds: 4));

      await t.enterText(input('请输入手机号'), '13800001234');
      await t.tap(find.text('获取验证码'));
      await t.pump();
      // 点击后立即有加载效果：转圈 + “发送中…”，期间不能再点
      expect(find.text('发送中…'), findsOneWidget);
      expect(find.byType(AppSpinner), findsOneWidget);
      expect(find.text('获取验证码'), findsNothing);
      await t.tap(find.text('发送中…'));
      await t.pump(const Duration(milliseconds: 600));
      await t.pumpAndSettle(); // 等旧提示条退场、新提示条出现
      expect(api.calls, ['send:13800001234']); // 连点只发一次
      expect(find.text('发送中…'), findsNothing);
      expect(find.text('开发环境验证码：246810'), findsOneWidget);
      expect(find.textContaining('秒后重发'), findsOneWidget);
      await t.pump(const Duration(seconds: 61));
    });

    testWidgets('每日限发超限：显示服务端的提示', (t) async {
      api.sendError = const AppError('今日发送次数已达上限');
      await open(t, 'ForgotVerify');
      await t.enterText(input('请输入手机号'), '13800001234');
      await t.tap(find.text('获取验证码'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('今日发送次数已达上限'), findsOneWidget);
      expect(find.text('获取验证码'), findsOneWidget); // 失败立即恢复可点
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('下一步：本地校验不通过时不请求', (t) async {
      await open(t, 'ForgotVerify');
      await tapText(t, '下一步');
      expect(find.text('请输入手机号'), findsWidgets);
      await t.pump(const Duration(seconds: 4));
      await t.enterText(input('请输入手机号'), '13800001234');
      await t.enterText(input('6 位数字'), '12');
      await tapText(t, '下一步');
      expect(find.text('验证码为 6 位数字'), findsOneWidget);
      expect(api.calls, isEmpty);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('服务端拒绝（号码未开通 / 验证码错误）：留在本页并提示', (t) async {
      api.verifyError = const AppError('该手机号尚未开通门店账号');
      await open(t, 'ForgotVerify');
      await t.enterText(input('请输入手机号'), '13800001234');
      await t.enterText(input('6 位数字'), '246810');
      await tapText(t, '下一步');
      expect(find.text('该手机号尚未开通门店账号'), findsOneWidget);
      expect(find.text('设置新密码'), findsNothing);
      expect(forgotFlow.live, isFalse);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('验证通过：进入设置新密码，显示脱敏手机号', (t) async {
      await toVerified(t);
      expect(api.calls, ['verify:13800001234:246810']);
      expect(find.text('手机号 138 **** 1234 已验证通过'), findsOneWidget);
    });
  });

  group('第 2 步 · 设置新密码', () {
    testWidgets('从空白开始；校验规则', (t) async {
      await toVerified(t);
      expect(
        t.widget<TextField>(input('8-20 位，含字母和数字')).controller!.text,
        isEmpty,
      );
      await tapText(t, '确认重置');
      expect(find.text('请输入新密码'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));

      await t.enterText(input('8-20 位，含字母和数字'), 'abc');
      await tapText(t, '确认重置');
      expect(find.text('新密码需 8–20 位'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));

      await t.enterText(input('8-20 位，含字母和数字'), 'ab13800001');
      await t.enterText(input('再次输入新密码'), 'ab13800001');
      await tapText(t, '确认重置');
      expect(find.text('新密码不能包含手机号中的连续数字'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));

      await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
      await t.enterText(input('再次输入新密码'), 'newpass455');
      await tapText(t, '确认重置');
      expect(find.text('两次输入的新密码不一致'), findsOneWidget);
      expect(api.calls.where((c) => c.startsWith('reset')), isEmpty);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('密码小眼睛可以切换明文', (t) async {
      await toVerified(t);
      bool obscured() =>
          t.widget<TextField>(input('8-20 位，含字母和数字')).obscureText;
      expect(obscured(), isTrue);
      await t.tap(find.bySemanticsLabel('显示密码').first);
      await t.pump();
      expect(obscured(), isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('服务端拒绝（验证码已过期等）：留在本页并提示', (t) async {
      api.resetError = const AppError('验证码已过期，请重新获取');
      await toVerified(t);
      await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
      await t.enterText(input('再次输入新密码'), 'newpass456');
      await tapText(t, '确认重置');
      expect(find.text('验证码已过期，请重新获取'), findsOneWidget);
      expect(find.text('密码已重置'), findsNothing);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('重置成功：提交手机号 / 验证码 / 新密码，进入成功页并清空流程状态', (t) async {
      await toVerified(t);
      await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
      await t.enterText(input('再次输入新密码'), 'newpass456');
      await tapText(t, '确认重置');
      expect(api.calls.last, 'reset:13800001234:246810:newpass456');
      expect(find.text('密码已重置'), findsOneWidget);
      expect(find.text('请使用新密码登录。其他设备上的登录状态已失效。'), findsOneWidget);
      expect(forgotFlow.live, isFalse);
      expect(api.calls, isNot(contains('signOut'))); // 本机没登录，不需要退出
    });

    testWidgets('本机已登录时（从修改密码页进入）：重置成功后本机也退出登录', (t) async {
      api.signedIn = true;
      storeProfile.apply({'phone': '+8613800001234', 'name': '蓝鲸养护'});
      await toVerified(t);
      await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
      await t.enterText(input('再次输入新密码'), 'newpass456');
      await tapText(t, '确认重置');
      expect(api.calls, contains('signOut'));
      expect(storeProfile.live, isFalse);
    });

    testWidgets('没验证就到了这一页：提示先验证手机号', (t) async {
      await open(t, 'ForgotReset');
      await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
      await t.enterText(input('再次输入新密码'), 'newpass456');
      await tapText(t, '确认重置');
      expect(find.text('请先验证手机号'), findsOneWidget);
      expect(api.calls, isEmpty);
      await t.pump(const Duration(seconds: 4));
    });
  });

  group('入口', () {
    testWidgets('密码登录页有“忘记密码？”，验证码登录页没有', (t) async {
      await open(t, 'Login');
      expect(find.text('忘记密码？'), findsNothing);
      await t.tap(find.text('密码登录'));
      await t.pump();
      expect(find.text('忘记密码？'), findsOneWidget);
    });

    testWidgets('登录页：点“忘记密码？”进入验证手机号', (t) async {
      await open(t, 'Login');
      await t.tap(find.text('密码登录'));
      await t.pump();
      await t.ensureVisible(find.text('忘记密码？'));
      await t.tap(find.text('忘记密码？'));
      await t.pumpAndSettle();
      expect(find.text('验证手机号'), findsOneWidget);
    });

    testWidgets('修改密码页：“忘记当前密码？用验证码重置”进入同一套页面', (t) async {
      api.signedIn = true;
      await open(t, 'ChangePassword');
      await t.ensureVisible(find.text('忘记当前密码？用验证码重置'));
      await t.tap(find.text('忘记当前密码？用验证码重置'));
      await t.pumpAndSettle();
      expect(find.text('验证手机号'), findsOneWidget);
      // 两个入口都要手动输入手机号
      expect(t.widget<TextField>(input('请输入手机号')).controller!.text, isEmpty);
    });

    testWidgets('重置成功页“去登录”回到密码登录标签', (t) async {
      await open(t, 'ForgotDone');
      await t.tap(find.text('去登录'));
      await t.pumpAndSettle();
      expect(input('请输入登录密码'), findsOneWidget);
      expect(find.text('忘记密码？'), findsOneWidget);
    });
  });

  group('登录页密码框', () {
    testWidgets('有小眼睛，可切换明文；占位文字是“请输入登录密码”', (t) async {
      await open(t, 'Login');
      await t.tap(find.text('密码登录'));
      await t.pump();
      bool obscured() => t.widget<TextField>(input('请输入登录密码')).obscureText;
      expect(obscured(), isTrue);
      await t.ensureVisible(find.bySemanticsLabel('显示密码'));
      await t.tap(find.bySemanticsLabel('显示密码'));
      await t.pump();
      expect(obscured(), isFalse);
      await t.tap(find.bySemanticsLabel('隐藏密码'));
      await t.pump();
      expect(obscured(), isTrue);
    });
  });
}
