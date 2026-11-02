import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/kit/async_kit.dart' show SkeletonList;
import 'package:autocare_merchant/pages/order_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi, phone, row;

/// 开单页的三种状态：未选客户 / 散客 / 会员（设计稿里画成三张图，实际是同一个页面）。
void main() {
  late MerchantApi original;
  late MemberFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = MemberFakeApi();
    merchantApi = fake;
    CatalogDraft.current = null;
    MemberFlow.current = null;
    HoldFlow.reset();
    navTracker.stack.clear();
    fake.services.addAll([
      {
        'id': 's1',
        'name': '精致洗车',
        'price': 68,
        'category': '洗车',
        'active': true,
      },
      {
        'id': 's2',
        'name': '内饰深度清洁',
        'price': 380,
        'category': '内饰',
        'active': true,
      },
    ]);
  });
  tearDown(() {
    merchantApi = original;
    CatalogDraft.current = null;
    MemberFlow.current = null;
    HoldFlow.reset();
    navTracker.stack.clear();
  });

  Future<void> openOrder(WidgetTester t, {bool settle = true}) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        initialRoute: 'Order',
        onGenerateRoute: (s) =>
            MaterialPageRoute(settings: s, builder: (_) => const OrderPage()),
      ),
    );
    if (settle) await t.pumpAndSettle();
  }

  testWidgets('未选客户：选择会员 / 散客开单；服务项目置灰，没有施工安排和结算，收款按钮不可用', (t) async {
    await openOrder(t);
    expect(find.text('选择客户'), findsOneWidget);
    expect(find.text('选择会员'), findsOneWidget);
    expect(find.text('车牌 / 手机号'), findsOneWidget);
    expect(find.text('散客开单'), findsOneWidget);
    expect(find.text('不记会员，无折扣和次卡抵扣'), findsOneWidget);
    expect(find.text('施工安排'), findsNothing);
    expect(find.text('结算'), findsNothing);
    expect(find.text('请先选择客户'), findsOneWidget);
    expect(find.text('确认收款'), findsNothing);
    // 置灰的服务项目点不动
    await t.tap(find.text('精致洗车'), warnIfMissed: false);
    await t.pump();
    expect(find.text('¥0.00'), findsOneWidget);
    await t.tap(find.text('挂单').last, warnIfMissed: false);
    await t.pump();
    expect(find.text('挂单保存'), findsNothing);
  });

  testWidgets('散客：车牌号选填，没有折扣和次卡，只有三种收款方式；只提交选择，不记会员', (t) async {
    await openOrder(t);
    await t.tap(find.text('散客开单'));
    await t.pumpAndSettle();
    expect(find.text('散客'), findsOneWidget);
    expect(find.text('不记会员'), findsOneWidget);
    expect(find.text('无会员折扣与次卡抵扣'), findsOneWidget);
    expect(find.text('选填，便于施工与取车'), findsOneWidget); // placeholder
    expect(find.text('会员余额'), findsNothing);
    expect(find.text('组合支付'), findsNothing);
    expect(find.text('银行卡'), findsOneWidget);
    expect(find.text('POS 刷卡'), findsOneWidget);
    // 选两个项目：没有折扣标签，合计 = 原价
    await t.tap(find.text('精致洗车'));
    await t.pump();
    await t.tap(find.text('内饰深度清洁'));
    await t.pump();
    expect(find.text('¥448.00'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (w) => w is Text && RegExp(r'\d 折').hasMatch(w.data ?? ''),
      ),
      findsNothing,
    );
    expect(find.text('次卡抵扣 1 次'), findsNothing);
    expect(find.textContaining('次卡抵扣 ·'), findsNothing);
    await t.enterText(find.byType(TextField).first, '苏K5F218');
    await t.tap(find.text('银行卡'));
    await t.pump();
    await t.tap(find.text('确认收款'));
    await t.pumpAndSettle();
    final sent = fake.walkIns.single;
    expect(sent['method'], 'POS 刷卡');
    expect(sent['plate'], '苏K5F218');
    expect(sent['lines'], [
      {'service_id': 's1', 'qty': 1},
      {'service_id': 's2', 'qty': 1},
    ]);
    expect(sent.toString().contains('price'), isFalse);
    expect(fake.checkouts, isEmpty); // 没有走会员开单
    expect(find.text('收款成功'), findsOneWidget);
  });

  testWidgets('散客点“更换”回到选择客户，已选项目清空', (t) async {
    await openOrder(t);
    await t.tap(find.text('散客开单'));
    await t.pumpAndSettle();
    await t.tap(find.text('精致洗车'));
    await t.pump();
    await t.tap(find.text('更换'));
    await t.pumpAndSettle();
    expect(find.text('选择客户'), findsOneWidget);
    expect(find.text('请先选择客户'), findsOneWidget);
  });

  testWidgets('选择会员：打开选择会员弹层，选中后进入会员状态（折扣、次卡、余额收款）', (t) async {
    final r = row(tier: 't-gold', tierName: '金卡');
    (r['card'] as Map)['discount'] = 0.95;
    fake.rows.add(r);
    await openOrder(t);
    await t.tap(find.text('选择会员'));
    await t.pumpAndSettle();
    expect(navTracker.has('sheet:MemberPicker'), isTrue);
    await t.tap(find.text('王建国').last);
    await t.pumpAndSettle();
    expect(navTracker.has('sheet:MemberPicker'), isFalse);
    expect(find.text('选择客户'), findsNothing);
    expect(find.text('王建国'), findsWidgets);
    expect(find.text('会员余额'), findsOneWidget);
    expect(find.text('确认收款'), findsOneWidget);
    // 关闭弹层没选人：不会被后面的会员变动影响
    expect(find.text('请先选择客户'), findsNothing);
  });

  testWidgets('选择会员弹层搜索没有结果：给出清除搜索 / 新增会员', (t) async {
    fake.rows.add(row());
    await openOrder(t);
    await t.tap(find.text('选择会员'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '沪Z99999');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('没有找到「沪Z99999」'), findsOneWidget);
    expect(find.text('请检查车牌或手机号，也可以新增为会员'), findsOneWidget);
    expect(find.text('清除搜索'), findsOneWidget);
    expect(find.text('新增会员'), findsWidgets);
    await t.tap(find.text('清除搜索'));
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('没有找到「沪Z99999」'), findsNothing);
    expect(find.text('王建国'), findsWidgets);
    Navigator.of(
      t.element(
        find.text('清除搜索').evaluate().isEmpty
            ? find.text('王建国').first
            : find.text('清除搜索'),
      ),
    ).pop();
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('服务项目走全局缓存：缓存里有时打开开单页不再请求、不闪骨架屏', (t) async {
    await ServiceStore.load(); // 登录后预加载
    final calls = fake.serviceCalls;
    await openOrder(t, settle: false);
    await t.pump();
    expect(find.byType(SkeletonList), findsNothing);
    expect(find.text('精致洗车'), findsOneWidget);
    await t.pumpAndSettle();
    expect(fake.serviceCalls, calls);
  });

  testWidgets('后台刷新服务项目后，开单页已选的项目按 ID 保留，不会选错', (t) async {
    await openOrder(t);
    await t.tap(find.text('散客开单')); // 未选客户时服务项目是置灰的
    await t.pumpAndSettle();
    await t.tap(find.text('内饰深度清洁'));
    await t.pump();
    expect(find.text('¥380.00'), findsWidgets);
    // 门店又新增了一个排在最前面的项目
    fake.services.insert(0, {
      'id': 's0',
      'name': '新增项目',
      'price': 20,
      'category': '洗车',
      'active': true,
    });
    await ServiceStore.refresh();
    await t.pump();
    expect(find.text('新增项目'), findsOneWidget);
    expect(find.text('¥380.00'), findsWidgets); // 选中的还是内饰深度清洁
  });
}
