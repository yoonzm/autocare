import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/keyboard.dart';
import 'package:autocare_merchant/kit/kit.dart';
import 'package:autocare_merchant/mock/app_state.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/home_page.dart';
import 'package:autocare_merchant/pages/login_page.dart';
import 'package:autocare_merchant/pages/settings_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';

import 'appointments_test.dart' show BookingApi, bookingRow;

class StockInteractionApi extends MerchantApi {
  StockInteractionApi({this.signedIn = true});
  final bool signedIn;
  final actions = <String>[];
  num? quotedQuantity;

  @override
  bool get hasSession => signedIn;

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 20),
  }) async {
    actions.add(body['action'] as String);
    switch (body['action']) {
      case 'inventory_list':
        return {
          'items': [
            {
              'id': 'product-1',
              'name': '接口库存商品',
              'stock': 8,
              'safe': 2,
              'unit': '卷',
              'cost': 10,
              'version': 1,
            },
          ],
        };
      case 'inventory_draft':
        return {
          'item': {
            'id': 'draft-0001',
            'revision': 1,
            'payload': {
              'supplier': '',
              'date': '2026-11-03',
              'freight': 0,
              'payment': '现金',
              'note': '',
              'lines': [
                {'id': 'product-1', 'quantity': 2.5, 'cost': 10, 'version': 1},
              ],
            },
          },
        };
      case 'inventory_quote':
        quotedQuantity = body['payload']['lines'][0]['quantity'] as num;
        return {
          'item': {
            'subtotal': quotedQuantity! * 10,
            'total': quotedQuantity! * 10,
          },
        };
      default:
        throw StateError('Unexpected action: ${body['action']}');
    }
  }
}

BookingApi useLiveApi(WidgetTester t) {
  final original = merchantApi;
  final api = BookingApi();
  merchantApi = api;
  HoldFlow.reset();
  addTearDown(() {
    merchantApi = original;
    storeProfile.clear();
    navTracker.stack.clear();
  });
  return api;
}

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(390 * 3, 900 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Future<void> open(WidgetTester t, String name) async {
  phone(t);
  await t.pumpWidget(MaterialApp(home: pageFor(name)!));
  await t.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('挂单列表：标签筛选会过滤条目', (t) async {
    await open(t, 'HoldList');
    expect(find.textContaining('王建国'), findsWidgets);
    expect(find.textContaining('李女士'), findsWidgets);
    await t.tap(find.text('待施工 1'));
    await t.pump();
    expect(find.textContaining('王建国'), findsNothing);
    expect(find.textContaining('李女士'), findsNothing);
    expect(find.textContaining('苏K·5F218'), findsWidgets);
    await t.tap(find.text('全部 4'));
    await t.pump();
    expect(find.textContaining('王建国'), findsWidgets);
  });

  testWidgets('商品入库：接口草稿的小数数量可增减并重新询价', (t) async {
    final original = merchantApi;
    final api = StockInteractionApi();
    merchantApi = api;
    addTearDown(() => merchantApi = original);
    await open(t, 'StockIn');
    await t.pumpAndSettle();
    expect(find.text('接口库存商品'), findsOneWidget);
    expect(find.text('6'), findsNothing);
    expect(find.text('2.5'), findsOneWidget);
    final c = t.getCenter(find.text('2.5'));
    await t.tapAt(c + const Offset(36, 0));
    await t.pump();
    expect(find.text('3.5'), findsOneWidget);
    await t.tapAt(c + const Offset(-36, 0));
    await t.pump();
    await t.tapAt(c + const Offset(-36, 0));
    await t.pump();
    expect(find.text('1.5'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 350));
    await t.pumpAndSettle();
    expect(
      api.actions,
      containsAll(['inventory_list', 'inventory_draft', 'inventory_quote']),
    );
    expect(api.quotedQuantity, 1.5);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('商品入库：未登录引导登录，不显示示例库存或请求接口', (t) async {
    final original = merchantApi;
    final api = StockInteractionApi(signedIn: false);
    merchantApi = api;
    addTearDown(() => merchantApi = original);
    await open(t, 'StockIn');
    await t.pumpAndSettle();
    expect(find.text('重新登录'), findsOneWidget);
    expect(find.text('TPU 隐形车衣 7.5mil'), findsNothing);
    expect(api.actions, isEmpty);
  });

  testWidgets('开关可切换', (t) async {
    await open(t, 'NotifySettings');
    final sw = find.byType(AnimatedContainer).first;
    final before =
        (t.widget<AnimatedContainer>(sw).decoration as BoxDecoration).color;
    await t.tap(sw);
    await t.pump(const Duration(milliseconds: 300));
    final after =
        (t.widget<AnimatedContainer>(sw).decoration as BoxDecoration).color;
    expect(after, isNot(before));
  });

  testWidgets('弹层页作为底部弹层打开，并且能关闭', (t) async {
    phone(t);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: Text('会员列表'));
          },
        ),
      ),
    );
    openRoute(ctx, 'MemberFilter');
    await t.pumpAndSettle();
    expect(find.text('筛选会员'), findsOneWidget);
    expect(find.text('会员列表'), findsOneWidget); // 仍叠在原页面之上
    await t.tapAt(const Offset(195, 20)); // 点遮罩
    await t.pumpAndSettle();
    expect(find.text('筛选会员'), findsNothing);
  });

  testWidgets('首页按订阅状态显示提醒条', (t) async {
    useLiveApi(t);
    phone(t);
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    expect(find.text('去订阅'), findsNothing);
    subState.value = SubState.trialEnding;
    await t.pump();
    expect(find.text('去订阅'), findsOneWidget);
    subState.value = SubState.expiring;
    await t.pump();
    expect(find.text('去续费'), findsOneWidget);
    subState.value = SubState.normal;
  });

  testWidgets('点击输入框以外的区域会收起键盘', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(
                onTapOutside: onTapOutsideDismiss,
                keyboardType: TextInputType.number,
              ),
              Spacer(),
              Text('空白区域'),
            ],
          ),
        ),
      ),
    );
    await t.tap(find.byType(TextField));
    await t.pump();
    expect(focusOf(t), isTrue);
    await t.tapAt(const Offset(195, 400));
    await t.pump();
    expect(focusOf(t), isFalse);
  });

  testWidgets('预约管理：列表 / 工位时间表是同一页面里的标签，不跳转', (t) async {
    useLiveApi(t).bookings.add(bookingRow());
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    phone(t);
    await t.pumpWidget(const MaterialApp(home: AppointmentsPage()));
    await t.pumpAndSettle();
    expect(find.textContaining('待处理 · 现在'), findsOneWidget);
    await t.tap(find.text('工位时间表'));
    await t.pump();
    expect(find.textContaining('待处理 · 现在'), findsNothing);
    expect(find.text('预约管理'), findsOneWidget); // 仍是同一页面（只有一个标题）
    expect(find.textContaining('共 1 个工位'), findsOneWidget);
    await t.tap(find.text('列表'));
    await t.pump();
    expect(find.textContaining('待处理 · 现在'), findsOneWidget);
  });

  testWidgets('客户选择支持按姓名 / 车牌 / 手机号检索', (t) async {
    phone(t);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    pickMember(ctx);
    await t.pumpAndSettle();
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('周志远'), findsOneWidget);
    await t.enterText(find.byType(TextField), '周');
    await t.pump();
    expect(find.text('王建国'), findsNothing);
    expect(find.text('周志远'), findsOneWidget);
    await t.enterText(find.byType(TextField), '8k29');
    await t.pump();
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('周志远'), findsNothing);
    await t.enterText(find.byType(TextField), '1391688');
    await t.pump();
    expect(find.text('刘先生'), findsOneWidget);
    await t.enterText(find.byType(TextField), '不存在');
    await t.pump();
    expect(find.text('没有找到匹配的客户'), findsOneWidget);
  });

  testWidgets('密码登录：密码输入框的占位文字在输入框内垂直居中', (t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: LoginPage()));
    await t.tap(find.text('密码登录'));
    await t.pump();
    final hint = t.getRect(find.text('请输入登录密码')).center;
    final phoneHint = t.getRect(find.text('请输入手机号')).center;
    // 与手机号输入框相同的 48px 高度：占位文字应落在各自输入框的垂直中心
    final box = t.getRect(
      find
          .ancestor(of: find.text('请输入登录密码'), matching: find.byType(Container))
          .first,
    );
    final pbox = t.getRect(
      find
          .ancestor(of: find.text('请输入手机号'), matching: find.byType(Container))
          .first,
    );
    expect((hint.dy - box.center.dy).abs() < 14, isTrue);
    expect((phoneHint.dy - pbox.center.dy).abs() < 14, isTrue);
    expect(
      t.getRect(find.text('请输入登录密码')).left,
      closeTo(54, 1),
    ); // 靠左对齐（左内边距 14）
  });

  testWidgets('新增会员：生日 / 品牌车型 / 城市选择器可用并回写', (t) async {
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await open(t, 'MemberAdd');
    expect(find.text('选填，用于生日礼'), findsOneWidget);
    await t.tap(find.text('生日'));
    await t.pumpAndSettle();
    expect(find.text('选择生日'), findsOneWidget);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('选填，用于生日礼'), findsNothing);
    expect(find.textContaining('1990.06.18'), findsOneWidget);

    await t.tap(find.text('品牌车型'));
    await t.pumpAndSettle();
    expect(find.text('选择品牌车型'), findsOneWidget);
    await t.drag(find.text('宝马').last, const Offset(0, -40));
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('宝马 5系 525Li'), findsNothing);
  });

  testWidgets('日期选择：中文本地化，年月日联动并显示星期 / 年龄', (tester) async {
    phone(tester);
    late BuildContext ctx;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [Locale('zh', 'CN')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold(body: SizedBox());
          },
        ),
      ),
    );
    pickDate(ctx, '选择生日', birthday: true, current: '');
    await tester.pumpAndSettle();
    // 中文：不是 “October / 十月” 之类的英文月份
    expect(find.text('六月'), findsOneWidget);
    expect(find.text('18日'), findsOneWidget);
    expect(find.text('1990年'), findsOneWidget);
    expect(find.text('1990 年 6 月 18 日 · 周一 · 36 岁'), findsOneWidget);
    // 滚动年份列后，下方的完整日期随之联动
    await tester.drag(find.text('1990年'), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(find.text('1990 年 6 月 18 日 · 周一 · 36 岁'), findsNothing);
    expect(find.textContaining('岁'), findsOneWidget);
  });

  testWidgets('推荐人使用带检索的客户选择器', (t) async {
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await open(t, 'MemberAdd');
    await t.ensureVisible(find.text('推荐人'));
    await t.tap(find.text('推荐人'));
    await t.pumpAndSettle();
    expect(find.text('选择推荐人'), findsOneWidget);
    final search = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(search, findsOneWidget); // 检索框
    await t.enterText(search, '林晓');
    await t.pump();
    expect(find.text('王建国'), findsNothing);
    await t.tap(find.text('林晓雯'));
    await t.pumpAndSettle();
    expect(find.text('林晓雯 · 金卡'), findsOneWidget);
  });

  testWidgets('门店营业时间：开门 / 打烊可通过时间选择器修改', (t) async {
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await open(t, 'StoreEdit');
    expect(find.text('09:00'), findsOneWidget);
    await t.ensureVisible(find.text('开门'));
    await t.tap(find.text('开门'));
    await t.pumpAndSettle();
    expect(find.text('选择开门时间'), findsOneWidget);
    await t.drag(find.byType(ListWheelScrollView).first, const Offset(0, -60));
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('09:00'), findsNothing); // 已改成新的时间
    expect(find.text('20:00'), findsOneWidget);
  });

  testWidgets('更换手机号：获取验证码后进入 60 秒倒计时', (tester) async {
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await open(tester, 'ChangePhone');
    expect(find.text('获取验证码'), findsNWidgets(2));
    await tester.tap(find.text('获取验证码').first);
    await tester.pump();
    expect(find.text('60 秒后重发'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('57 秒后重发'), findsOneWidget);
    await tester.pump(const Duration(seconds: 60)); // 让计时器结束
  });

  testWidgets('我的：各设置项都能进入对应页面', (tester) async {
    useLiveApi(tester);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    phone(tester);
    await tester.pumpWidget(
      MaterialApp(navigatorObservers: [navTracker], home: const SettingsPage()),
    );
    for (final (row, title) in [
      ('支付与收款', '支付与收款'),
      ('小票打印机', '小票打印机'),
      ('营业时间与工位', '营业时间与工位'),
      ('账号与安全', '账号与安全'),
      ('数据备份', '数据备份'),
      ('关于汽美管家', '关于汽美管家'),
    ]) {
      await tester.ensureVisible(find.text(row));
      await tester.tap(find.text(row));
      await tester.pumpAndSettle();
      expect(find.text(title), findsWidgets, reason: row);
      expect(find.text('我的'), findsNothing, reason: '$row 应进入新页面');
      Navigator.of(tester.element(find.byType(Scaffold).last)).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('车牌输入：点格子弹出键盘，可输入并切换新能源', (t) async {
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await open(t, 'VehicleAdd');
    expect(find.text('沪'), findsWidgets);
    await t.tap(find.text('6').first); // 最后一格
    await t.pumpAndSettle();
    expect(find.text('输入字母或数字'), findsOneWidget);
    await t.tap(find.text('Z').last);
    await t.pump();
    expect(find.text('Z'), findsWidgets);
    await t.tap(find.text('完成'));
    await t.pumpAndSettle();
    expect(find.text('输入字母或数字'), findsNothing);
    await t.tap(find.text('沪').first);
    await t.pumpAndSettle();
    expect(find.text('选择省份简称'), findsOneWidget);
  });
}

bool focusOf(WidgetTester t) =>
    t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus;
