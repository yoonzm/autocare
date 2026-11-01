import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> login(WidgetTester t, {String email = 'ops@chiguang.example'}) async {
  t.view.physicalSize = const Size(390 * 3, 844 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  store.reset();
  await t.pumpWidget(const AdminApp());
  await t.enterText(find.byType(TextField).at(0), email);
  await t.enterText(find.byType(TextField).at(1), Store.demoPassword);
  await t.tap(find.text('登录').last);
  await t.pumpAndSettle();
  await t.enterText(find.byType(TextField).last, Store.demoCode);
  await t.tap(find.text('验证并登录'));
  await t.pumpAndSettle();
}

Future<void> tab(WidgetTester t, String label) async {
  const names = ['概览', '商家', '订阅', '我的'];
  await t.tap(find.byKey(ValueKey('nav-${names.indexOf(label)}')));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('登录校验：错误密码、禁用账号、验证码错误', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    store.reset();
    await t.pumpWidget(const AdminApp());
    await t.enterText(find.byType(TextField).at(1), 'bad');
    await t.tap(find.text('登录').last);
    await t.pumpAndSettle();
    expect(find.text('邮箱或密码错误'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), 'zhang@chiguang.example');
    await t.enterText(find.byType(TextField).at(1), Store.demoPassword);
    await t.tap(find.text('登录').last);
    await t.pumpAndSettle();
    expect(find.text('该账号已被禁用，请联系超级管理员'), findsOneWidget);

    await t.enterText(find.byType(TextField).at(0), 'ops@chiguang.example');
    await t.tap(find.text('登录').last);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '000000');
    await t.tap(find.text('验证并登录'));
    await t.pumpAndSettle();
    expect(find.text('验证码错误，请重试'), findsOneWidget);
  });

  testWidgets('登录后进入概览，四个 Tab 可切换', (t) async {
    await login(t);
    expect(find.text('本月 MRR（元）'), findsOneWidget);
    expect(find.text('待办'), findsOneWidget);
    await tab(t, '商家');
    expect(find.text('驰光汽车美容 · 徐汇店'), findsOneWidget);
    await tab(t, '订阅');
    expect(find.text('本月收入（元）'), findsOneWidget);
    await tab(t, '我的');
    expect(find.text('运营小李'), findsOneWidget);
  });

  testWidgets('商家搜索与筛选', (t) async {
    await login(t);
    await tab(t, '商家');
    await t.tap(find.textContaining('已到期 3'));
    await t.pumpAndSettle();
    expect(find.text('车安心养护'), findsOneWidget);
    expect(find.text('驰光汽车美容 · 徐汇店'), findsNothing);
    await t.tap(find.textContaining('全部'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '蓝鲸');
    await t.pumpAndSettle();
    expect(find.text('蓝鲸汽车美容'), findsOneWidget);
    expect(find.text('车安心养护'), findsNothing);
    await t.enterText(find.byType(TextField), '不存在');
    await t.pumpAndSettle();
    expect(find.text('没有符合条件的商家'), findsOneWidget);
  });

  testWidgets('商家详情：延长 7 天、冻结账号', (t) async {
    await login(t);
    await tab(t, '商家');
    await t.tap(find.text('蓝鲸汽车美容'));
    await t.pumpAndSettle();
    final m = store.merchants.firstWhere((m) => m.name == '蓝鲸汽车美容');
    final before = m.expiry;
    await t.tap(find.text('延长期限 / 调整套餐'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认'));
    await t.pumpAndSettle();
    expect(m.expiry, before.add(const Duration(days: 7)));

    await t.scrollUntilVisible(find.text('账号处理'), 200, scrollable: find.byType(Scrollable).first);
    await t.tap(find.text('账号处理'));
    await t.pumpAndSettle();
    await t.tap(find.text('冻结商家账号'));
    await t.tap(find.text('确认'));
    await t.pumpAndSettle();
    expect(m.frozen, isTrue);
    expect(find.text('已冻结'), findsOneWidget);
  });

  testWidgets('开通审核：通过后商家出现在列表，驳回记录原因', (t) async {
    await login(t);
    final before = store.merchants.length;
    await t.tap(find.text('开通审核'));
    await t.pumpAndSettle();
    await t.tap(find.text('极速洗护 · 闵行店'));
    await t.pumpAndSettle();
    await t.tap(find.text('通过并开通').last);
    await t.pumpAndSettle();
    await t.tap(find.text('通过并开通').last);
    await t.pumpAndSettle();
    expect(store.merchants.length, before + 1);
    expect(store.pendingReviews, 2);

    await t.tap(find.text('蓝鲸汽车美容 · 西湖店'));
    await t.pumpAndSettle();
    await t.tap(find.text('驳回'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认驳回'));
    await t.pumpAndSettle();
    expect(store.reviews.firstWhere((r) => r.id == 'r2').status, RStatus.rejected);
    expect(store.pendingReviews, 1);
  });

  testWidgets('到期跟进：保存跟进记录', (t) async {
    await login(t);
    await t.tap(find.text('到期跟进').first);
    await t.pumpAndSettle();
    await t.tap(find.textContaining('已到期 3'));
    await t.pumpAndSettle();
    await t.tap(find.text('车安心养护'));
    await t.pumpAndSettle();
    await t.tap(find.text('保存记录'));
    await t.pumpAndSettle();
    expect(find.text('请填写沟通内容'), findsOneWidget);
    await t.enterText(find.byType(TextField), '已发送续费链接');
    await t.tap(find.text('保存记录'));
    await t.pumpAndSettle();
    expect(find.text('已发送续费链接'), findsOneWidget);
    expect(store.merchants.firstWhere((m) => m.name == '车安心养护').logs.length, 3);
  });

  testWidgets('工单：回复后进入处理中，标记已解决', (t) async {
    await login(t);
    await t.tap(find.text('工单').first);
    await t.pumpAndSettle();
    await t.tap(find.text('无法登录商家端'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '请尝试换用网络后重试');
    await t.tap(find.text('发送'));
    await t.pumpAndSettle();
    final tk = store.tickets.first;
    expect(tk.status, TStatus.doing);
    expect(find.text('请尝试换用网络后重试'), findsOneWidget);
    await t.tap(find.text('已解决'));
    await t.pumpAndSettle();
    await t.tap(find.text('已解决').last);
    await t.pumpAndSettle();
    expect(tk.status, TStatus.done);
  });

  testWidgets('权限：运营不能退款/改套餐/管理账号，超级管理员可以', (t) async {
    await login(t);
    await tab(t, '订阅');
    await t.tap(find.text('驰光汽车美容 · 徐汇店').first);
    await t.pumpAndSettle();
    await t.tap(find.text('退款'));
    await t.pumpAndSettle();
    expect(find.text('退款需要超级管理员权限'), findsOneWidget);
    expect(find.text('订单退款'), findsNothing);
    await t.tap(find.byIcon(Icons.chevron_left_rounded));
    await t.pumpAndSettle();
    await tab(t, '我的');
    await t.tap(find.text('运营账号'));
    await t.pumpAndSettle();
    expect(find.text('仅超级管理员可管理运营账号'), findsOneWidget);
  });

  testWidgets('超级管理员：退款金额校验与生效', (t) async {
    await login(t, email: 'wang@chiguang.example');
    await tab(t, '订阅');
    final total = store.monthRevenue;
    await t.tap(find.text('驰光汽车美容 · 徐汇店').first);
    await t.pumpAndSettle();
    await t.tap(find.text('退款'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '5000');
    await t.tap(find.text('确认退款'));
    await t.pumpAndSettle();
    expect(find.textContaining('不能超过实付'), findsOneWidget);
    await t.enterText(find.byType(TextField), '1000');
    await t.tap(find.text('确认退款'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认退款').last);
    await t.pumpAndSettle();
    expect(store.orders.first.refunded, 1000);
    expect(store.monthRevenue, total - 1000);
  });

  testWidgets('超级管理员：新增账号校验、禁用与不能禁用自己', (t) async {
    await login(t, email: 'wang@chiguang.example');
    await tab(t, '我的');
    await t.tap(find.text('运营账号'));
    await t.pumpAndSettle();
    expect(find.text('王主管（我）'), findsOneWidget);
    await t.tap(find.byKey(const ValueKey('add-account')));
    await t.pumpAndSettle();
    await t.tap(find.text('创建账号'));
    await t.pumpAndSettle();
    expect(find.text('请输入姓名'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(0), '陈运营');
    await t.enterText(find.byType(TextField).at(1), 'ops@chiguang.example');
    await t.tap(find.text('创建账号'));
    await t.pumpAndSettle();
    expect(find.text('该邮箱已存在账号'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(1), 'chen@chiguang.example');
    await t.tap(find.text('创建账号'));
    await t.pumpAndSettle();
    expect(store.accounts.length, 5);

    await t.tap(find.text('王主管（我）'));
    await t.pumpAndSettle();
    await t.tap(find.text('禁用账号'));
    await t.tap(find.text('确认'));
    await t.pumpAndSettle();
    expect(store.me!.enabled, isTrue);
    await t.tap(find.text('赵运营'));
    await t.pumpAndSettle();
    await t.tap(find.text('禁用账号'));
    await t.tap(find.text('确认'));
    await t.pumpAndSettle();
    expect(store.accounts.firstWhere((a) => a.name == '赵运营').enabled, isFalse);
  });

  testWidgets('套餐编辑：超级管理员保存，校验空名称', (t) async {
    await login(t, email: 'wang@chiguang.example');
    await tab(t, '我的');
    await t.tap(find.text('套餐管理'));
    await t.pumpAndSettle();
    await t.tap(find.text('基础版').first);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), '');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('请输入套餐名称'), findsOneWidget);
    await t.enterText(find.byType(TextField).at(0), '基础版');
    await t.enterText(find.byType(TextField).at(1), '699');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(store.plans[1].fee, 699);
    expect(find.text('¥699 / 年'), findsOneWidget);
  });

  testWidgets('退出登录回到登录页', (t) async {
    await login(t);
    await tab(t, '我的');
    await t.tap(find.text('退出登录').first);
    await t.pumpAndSettle();
    await t.tap(find.text('退出登录').last);
    await t.pumpAndSettle();
    expect(find.text('汽美管家 · 运营后台'), findsOneWidget);
    expect(store.me, isNull);
  });
}
