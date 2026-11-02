import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/kit.dart' show HCheck;
import 'package:autocare_merchant/pages/gen/gen_routes.dart';

/// 记录调用的假后端（模拟已登录）。
class _FakeApi extends MerchantApi {
  final List<String> calls = [];
  Map<String, dynamic>? registered;
  @override
  bool get hasSession => true;
  // 登录后会预加载服务项目（全局缓存）：这里没有服务项目
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async => const [];
  @override
  Future<String> sendMockCode(String phone) async {
    calls.add('send:$phone');
    return '111222';
  }

  @override
  Future<void> checkCode(String phone, String code) async =>
      calls.add('check:$phone:$code');
  @override
  Future<Map<String, dynamic>> register({
    required String phone,
    required String code,
    required String password,
    required String storeName,
    Map<String, dynamic> profile = const {},
  }) async {
    registered = {
      'phone': phone,
      'code': code,
      'password': password,
      'store_name': storeName,
      ...profile,
    };
    return {'ok': true, 'services': 8, 'cards': 4};
  }

  @override
  Future<void> loginPassword(String phone, String password) async {}
  @override
  Future<Map<String, dynamic>> getStore() async => {
    'name': '蓝鲸养护',
    'phone': '+8613988888812',
    'city': '杭州市 · 西湖区',
    'address': '文三路 1 号',
    'plan': 'trial',
    'trial_ends_at': '2026-11-14T08:00:00Z',
    'business_types': ['洗车美容'],
  };
  @override
  Future<void> changePassword(String o, String n) async =>
      calls.add('pwd:$o:$n');
  @override
  Future<void> changePhone({
    required String code,
    required String newPhone,
    required String newCode,
  }) async => calls.add('phone:$code:$newPhone:$newCode');
  @override
  Future<void> deleteAccount(String code) async => calls.add('delete:$code');
  @override
  Future<void> signOut() async => calls.add('signOut');
  @override
  Future<void> signOutAll() async => calls.add('signOutAll');
}

void main() {
  late _FakeApi api;
  late MerchantApi original;

  setUp(() {
    original = merchantApi;
    api = _FakeApi();
    merchantApi = api;
    RegistrationDraft.clear();
    storeProfile.clear();
    storeProfile.apply({'phone': '+8613988888812', 'name': '蓝鲸养护'});
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
  });

  Future<void> open(WidgetTester t, String route) async {
    t.view.physicalSize = const Size(390 * 3, 1400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        initialRoute: route,
        onGenerateRoute: (s) => MaterialPageRoute(
          settings: s,
          builder: (_) => Builder(builder: genRoutes[s.name]!),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Finder input(String hint, [int index = 0]) => find
      .byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == hint,
      )
      .at(index);

  Future<void> tapText(WidgetTester t, String text) async {
    await t.ensureVisible(find.text(text));
    await t.tap(find.text(text));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    // 异步动作的 loading 至少停留 500ms，等它结束
    await t.pump(const Duration(milliseconds: 700));
  }

  testWidgets('注册第二页：未选城市 / 没填联系人不能提交，选项会随资料提交', (t) async {
    await open(t, 'RegShop');
    // 设计稿的示例文字不应成为默认值
    expect(find.text('驰光汽车美容'), findsNothing);
    expect(find.text('陈明'), findsNothing);
    await tapText(t, '开通并开始试用');
    expect(find.text('请输入门店名称'), findsOneWidget);

    await t.enterText(input('如：驰光汽车美容'), '蓝鲸养护');
    await tapText(t, '开通并开始试用');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('请选择所在城市'), findsWidgets);

    RegistrationDraft.city = '杭州市 · 西湖区'; // 城市选择器是原生滚轮，直接写入选中结果
    await tapText(t, '开通并开始试用');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('请输入联系人姓名'), findsOneWidget);

    await t.enterText(input('您的姓名'), '林');
    await t.enterText(input('街道、门牌号（选填）'), '文三路 1 号');
    await tapText(t, '店长');
    await tapText(t, '7-10 个');
    final p = RegistrationDraft.profile();
    expect(p['contact_name'], '林');
    expect(p['address'], '文三路 1 号');
    expect(p['contact_role'], '店长');
    expect(p['bay_range'], '7-10 个');
    expect(p['business_types'], ['洗车美容', '镀晶镀膜', '隐形车衣']);
    expect(RegistrationDraft.shopStepError(), isNull);
  });

  testWidgets('开通成功页：显示后端返回的门店名 / 手机号 / 试用期', (t) async {
    await storeProfile.load();
    await open(t, 'RegDone');
    expect(find.text('蓝鲸养护 · 已为您创建店长账号'), findsOneWidget);
    expect(find.text('手机号 139 **** 8812'), findsOneWidget);
    expect(find.text('专业版 · 试用'), findsOneWidget);
    expect(find.text(storeProfile.trialEndText), findsOneWidget);
    expect(storeProfile.trialEndText, startsWith('2026.11.'));
  });

  testWidgets('开通门店：成功页显示云函数按主营业务初始化的服务项目数', (t) async {
    await open(t, 'RegShop');
    RegistrationDraft.set('RegPhone', '请输入手机号', '13900000000');
    RegistrationDraft.set('RegPhone', '6 位数字', '123456');
    RegistrationDraft.set('RegPhone', '8-20 位，含字母和数字', 'abcd1234');
    await t.enterText(input('如：驰光汽车美容'), '蓝鲸养护');
    await t.enterText(input('您的姓名'), '林');
    RegistrationDraft.city = '杭州市 · 西湖区';
    await tapText(t, '开通并开始试用');
    await t.pumpAndSettle(); // 等跳转到「开通成功」页
    expect(api.registered!['store_name'], '蓝鲸养护');
    expect(find.text('已按主营业务生成 8 项'), findsOneWidget);
    expect(storeProfile.seededServices, 8);
  });

  testWidgets('账号与安全：手机号来自门店资料；退出所有设备走后端', (t) async {
    await open(t, 'Security');
    expect(find.text('139 **** 8812'), findsOneWidget);
    await tapText(t, '退出所有设备');
    expect(api.calls, ['signOutAll']);
  });

  testWidgets('修改密码：本地校验 + 提交到后端', (t) async {
    await open(t, 'ChangePassword');
    // 设计稿里预填的示例密码不应出现在输入框里
    expect(find.text('Aa123456xy'), findsNothing);
    await tapText(t, '确认修改');
    expect(find.text('请输入当前密码'), findsNWidgets(2)); // 输入框占位 + 提示

    await t.enterText(input('请输入当前密码'), 'oldpass123');
    await t.enterText(input('8-20 位，含字母和数字'), 'oldpass123');
    await t.enterText(input('再次输入新密码'), 'oldpass123');
    await tapText(t, '确认修改');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('新密码不能与当前密码相同'), findsOneWidget);

    await t.enterText(input('8-20 位，含字母和数字'), 'ab13988888');
    await t.enterText(input('再次输入新密码'), 'ab13988888');
    await tapText(t, '确认修改');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('新密码不能包含手机号中的连续数字'), findsOneWidget);

    await t.enterText(input('8-20 位，含字母和数字'), 'newpass456');
    await t.enterText(input('再次输入新密码'), 'newpass455');
    await tapText(t, '确认修改');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('两次输入的新密码不一致'), findsOneWidget);
    expect(api.calls, isEmpty);

    await t.enterText(input('再次输入新密码'), 'newpass456');
    await tapText(t, '确认修改');
    expect(api.calls, ['pwd:oldpass123:newpass456']);
  });

  testWidgets('更换手机号：两个验证码按钮分别发到当前号码 / 新号码，两个验证码都要填', (t) async {
    await open(t, 'ChangePhone');
    await t.tap(find.text('获取验证码').first);
    await t.pump();
    expect(api.calls, ['send:13988888812']);
    await t.pump(const Duration(seconds: 61));

    await t.enterText(input('请输入新手机号'), '13500001111');
    await t.ensureVisible(find.text('获取验证码').last);
    await t.tap(find.text('获取验证码').last);
    await t.pump();
    expect(api.calls.last, 'send:13500001111');
    await t.pump(const Duration(seconds: 61));

    await t.enterText(input('6 位数字', 0), '111222');
    await tapText(t, '确认更换');
    await t.pump(const Duration(seconds: 4));
    expect(find.text('请输入新号码的验证码'), findsOneWidget);

    await t.enterText(input('6 位数字', 1), '333444');
    await tapText(t, '确认更换');
    expect(api.calls.last, 'phone:111222:13500001111:333444');
  });

  testWidgets('注销账号：有“获取验证码”按钮；填好验证码并勾选前按钮置灰，点了说明原因', (t) async {
    await open(t, 'DeleteAccount');
    // 验证码发到当前账号绑定的手机号（页面上的脱敏号码来自门店资料）
    expect(
      find.textContaining('验证码将发送至当前账号绑定的手机号 139 **** 8812'),
      findsOneWidget,
    );
    expect(find.textContaining('138 **** 1234'), findsNothing);
    await t.ensureVisible(find.text('获取验证码'));
    await t.tap(find.text('获取验证码'));
    await t.pump();
    expect(find.text('发送中…'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 700));
    expect(api.calls, ['send:13988888812']);
    await t.pump(const Duration(seconds: 6));

    // 没填验证码：按钮是置灰样式，点一下说明原因，不提交
    await tapText(t, '申请注销');
    expect(find.text('请输入 6 位短信验证码'), findsOneWidget);
    expect(api.calls.where((c) => c.startsWith('delete')), isEmpty);
    await t.pump(const Duration(seconds: 6));

    // 填了验证码但没勾选
    await t.enterText(input('6 位数字'), '111222');
    await tapText(t, '申请注销');
    expect(find.textContaining('请先勾选'), findsOneWidget);
    expect(api.calls.where((c) => c.startsWith('delete')), isEmpty);
    await t.pump(const Duration(seconds: 6));

    // 置灰样式（设计稿）：#E4E4E7；填好并勾选后变成可点的红色样式（#FFE1E2）
    Color? bg() {
      final box = t
          .widgetList<Container>(
            find.ancestor(
              of: find.text('申请注销'),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .whereType<Color>();
      return box.isEmpty ? null : box.first;
    }

    expect(bg(), const Color(0xFFE4E4E7));
    await t.ensureVisible(find.byType(HCheck));
    await t.tap(find.byType(HCheck));
    await t.pump();
    await t.pump();
    expect(bg(), const Color(0xFFFFE1E2));
    await tapText(t, '申请注销');
    expect(api.calls.skip(1), ['delete:111222', 'signOut']);
  });
}
