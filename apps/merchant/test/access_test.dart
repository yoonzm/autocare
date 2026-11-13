import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/account/access_pages.dart';
import 'package:autocare_merchant/pages/staff_app/staff_tabs.dart';
import 'package:autocare_merchant/routes.dart' show navTracker, openRoute;

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

void main() {
  late MerchantApi original;
  late BookingApi api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = merchantApi;
    merchantApi = api = BookingApi();
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });

  Future<void> open(WidgetTester t, Widget page) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(navigatorObservers: [navTracker], home: page),
    );
    await t.pumpAndSettle();
  }

  Finder text(String s) => find.text(s);
  List<Map<String, dynamic>> calls(String action) =>
      api.calls.where((c) => c['action'] == action).toList();

  testWidgets('选择身份：三种身份按设计稿展示，点技师进入技师工作台', (t) async {
    await open(
      t,
      StIdentityLivePage(items: api.identities, phone: '13877127712'),
    );
    expect(text('选择身份'), findsOneWidget);
    expect(find.textContaining('138 **** 7712 在以下门店有身份'), findsOneWidget);
    expect(text('驰光汽车美容 · 徐汇店'), findsOneWidget);
    expect(text('老板'), findsOneWidget);
    expect(text('名下 2 家门店 · 上次使用'), findsOneWidget);
    expect(text('前台收银'), findsOneWidget);
    expect(text('施工技师'), findsOneWidget);
    expect(text('待施工 2'), findsOneWidget);
    await t.tap(text('悦驰汽车装饰 · 松江店'));
    await t.pumpAndSettle();
    expect(calls('identity_select').single['staff_id'], 't1');
    expect(Access.role, 'technician');
    // 技师工作台：问候、今日业绩与任务都来自服务端
    expect(find.textContaining('老周'), findsWidgets);
    expect(text('¥3,860'), findsOneWidget);
    expect(text('¥386'), findsOneWidget);
    expect(text('沪A8K29M'), findsOneWidget);
    expect(text('全车镀晶 · 9H 陶瓷'), findsOneWidget);
    expect(text('3 号工位 · 预计 10:30'), findsNothing); // 预计完工 = 开始 + 标准工时（北京时间）
    expect(text('工作台'), findsWidgets);
  });

  testWidgets('待确认加入的身份：先到「加入门店」，确认后才进入工作台', (t) async {
    api.identityCtx = {...api.identityCtx, 'status': 'pending'};
    await open(
      t,
      StIdentityLivePage(items: [api.identities[2]], phone: '13877127712'),
    );
    await t.tap(text('悦驰汽车装饰 · 松江店'));
    await t.pumpAndSettle();
    expect(find.textContaining('欢迎加入悦驰汽车美容'), findsNothing);
    expect(text('欢迎加入悦驰汽车装饰 · 松江店'), findsOneWidget);
    expect(text('施工技师'), findsWidgets);
    expect(text('138 **** 7712'), findsOneWidget);
    expect(text('查看派给我的任务'), findsOneWidget);
    expect(text('查看门店营业额'), findsOneWidget);
    expect(calls('identity_join'), isEmpty);
    api.identityCtx = {...api.identityCtx, 'status': 'active'};
    await t.tap(text('确认加入并进入工作台'));
    await t.pumpAndSettle();
    expect(calls('identity_join'), hasLength(1));
    expect(text('¥3,860'), findsOneWidget);
  });

  testWidgets('手机号未登记：说明原因，给出免费开通与换手机号', (t) async {
    await open(t, const StAuthFailTemplate(phone: '13911111111'));
    expect(text('该手机号尚未登记'), findsOneWidget);
    expect(text('登录手机号：139 **** 1111'), findsOneWidget);
    expect(text('免费开通门店'), findsOneWidget);
    expect(text('换个手机号'), findsOneWidget);
  });

  testWidgets('员工外壳：技师底部导航四项，「我的」只对多身份账号显示切换身份', (t) async {
    Access.apply(api.identityCtx);
    await open(t, const StaffTabs());
    for (final label in ['工作台', '任务', '会员', '我的']) {
      expect(text(label), findsWidgets);
    }
    Finder nav(String label) => find.descendant(
      of: find.byType(StaffNavBar),
      matching: find.text(label),
    );
    await t.tap(nav('我的'));
    await t.pumpAndSettle();
    expect(text('老周'), findsWidgets);
    expect(text('¥4,620'), findsWidgets);
    expect(text('—'), findsWidgets, reason: '好评率没有数据来源，显示 —');
    expect(text('切换身份'), findsOneWidget);
    expect(find.textContaining('当前：悦驰汽车装饰 · 松江店 · 施工技师'), findsOneWidget);
    // 单身份账号不显示
    Access.apply({...api.identityCtx, 'identity_count': 1});
    await t.pumpAndSettle();
    await t.tap(nav('工作台'));
    await t.pumpAndSettle();
    await t.tap(nav('我的'));
    await t.pumpAndSettle();
    expect(text('切换身份'), findsNothing, reason: '只有一个身份的账号不显示切换身份');
  });

  testWidgets('员工外壳：前台底部是 工作台 · 预约 · 会员 · 我的，工作台只给笔数', (t) async {
    api.identityCtx = {...api.identityCtx, 'role': 'cashier'};
    api.home = {
      'role': 'cashier',
      'name': '小刘',
      'orders_today': 36,
      'waiting': 3,
      'working': 2,
      'upcoming': [
        {
          'id': 'a2',
          'plate': '沪AF09316',
          'status': 'waiting',
          'starts_at': '2026-11-10T05:00:00Z',
          'customer': '李梅',
          'items': [
            {'name': '精致洗车'},
          ],
        },
      ],
    };
    Access.apply(api.identityCtx);
    await open(t, const StaffTabs());
    for (final label in ['工作台', '预约', '会员', '我的']) {
      expect(text(label), findsWidgets);
    }
    expect(text('36 笔'), findsOneWidget);
    expect(find.textContaining('¥'), findsNothing, reason: '前台工作台不显示金额');
    expect(text('即将到店'), findsOneWidget);
    expect(text('沪AF09316 · 精致洗车'), findsOneWidget);
    expect(text('待收银 · 技师提交'), findsNothing, reason: '待收银队列未接通前不展示示例数据');
  });

  testWidgets('直达无权限的页面显示「暂无权限访问」，有权限才打开', (t) async {
    Access.apply({
      ...api.identityCtx,
      'caps': {'order_view_own': true},
    });
    late BuildContext ctx;
    await open(
      t,
      Builder(
        builder: (c) {
          ctx = c;
          return const Scaffold();
        },
      ),
    );
    openRoute(ctx, 'Stats');
    await t.pumpAndSettle();
    expect(text('暂无权限访问'), findsOneWidget);
    expect(find.textContaining('「查看门店营业统计」'), findsOneWidget);
    expect(find.textContaining('请联系店长开通后再试'), findsOneWidget);
  });

  testWidgets('权限判断：老板全开；员工按服务端生效权限', (t) async {
    expect(Access.can('anything'), isTrue);
    Access.apply({...api.identityCtx});
    expect(Access.can('order_view_own'), isTrue);
    expect(Access.can('stats_view_store'), isFalse);
    expect(Access.can('member_view'), isFalse);
    expect(Access.usesStaffShell, isTrue);
    Access.apply({...api.identityCtx, 'role': 'manager'});
    expect(Access.usesStaffShell, isFalse, reason: '店长使用商家外壳');
  });
}
