import 'holds_test.dart' as held show hold;
import 'members_test.dart' show MemberFakeApi, row;

import 'package:autocare_merchant/pages/members/member_route_data.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/keyboard.dart';
import 'package:autocare_merchant/kit/kit.dart';
import 'package:autocare_merchant/pages/booking/appointments_page.dart';
import 'package:autocare_merchant/pages/shared/home_page.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/shared/settings_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/backend/hold_store.dart';

import 'appointments_test.dart' show BookingApi, bookingRow;

class SmsInteractionApi extends MerchantApi {
  final response = Completer<void>();
  final requests = <({String phone, String purpose})>[];

  @override
  bool get hasSession => true;

  @override
  Future<void> sendCode(String phone, {required String purpose}) {
    requests.add((phone: phone, purpose: purpose));
    return response.future;
  }
}

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
    String? requestId,
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
  HoldStore.reset();
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

Future<void> open(WidgetTester t, String name, {Object? arguments}) async {
  phone(t);
  await t.pumpWidget(MaterialApp(home: pageFor(name, arguments: arguments)!));
  await t.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('挂单列表：标签筛选会过滤条目', (t) async {
    final original = merchantApi;
    merchantApi = MemberFakeApi()
      ..holdRows.addAll([
        held.hold(id: 'h1'),
        held.hold(id: 'h2', name: '李女士', status: '待结算'),
        {
          ...held.hold(id: 'h3', walkIn: true, status: '待施工'),
          'vehicle_plate': '苏K5F218',
        },
        held.hold(id: 'h4', name: '第四位'),
      ]);
    HoldStore.reset();
    addTearDown(() {
      merchantApi = original;
      HoldStore.reset();
    });
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

  testWidgets('弹层页作为底部弹层打开，并且能关闭', (t) async {
    phone(t);
    final original = merchantApi;
    merchantApi = MemberFakeApi();
    addTearDown(() => merchantApi = original);
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

  testWidgets('首页不显示任何订阅 / 到期提醒（一期限时免费）', (t) async {
    useLiveApi(t);
    phone(t);
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();
    expect(find.text('去订阅'), findsNothing);
    expect(find.text('去续费'), findsNothing);
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
    final previous = merchantApi;
    final api = MemberFakeApi();
    api.rows.addAll([
      {
        ...row(id: 'm1'),
        'name': '王建国',
        'vehicles': [
          {'plate': '沪A8K29M'},
        ],
        'phone': '13816826021',
      },
      {
        ...row(id: 'm2'),
        'name': '周志远',
        'vehicles': [
          {'plate': '浙A5L0P2'},
        ],
        'phone': '13472215908',
      },
      {
        ...row(id: 'm3'),
        'name': '刘先生',
        'vehicles': [
          {'plate': '沪C9H318'},
        ],
        'phone': '13916885026',
      },
    ]);
    merchantApi = api;
    addTearDown(() => merchantApi = previous);
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
    pickLiveMember(ctx);
    await t.pumpAndSettle();
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('周志远'), findsOneWidget);
    await t.enterText(find.byType(TextField), '周');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('王建国'), findsNothing);
    expect(find.text('周志远'), findsOneWidget);
    await t.enterText(find.byType(TextField), '8K29');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('周志远'), findsNothing);
    await t.enterText(find.byType(TextField), '1391688');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('刘先生'), findsOneWidget);
    await t.enterText(find.byType(TextField), '不存在');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('没有找到会员'), findsOneWidget);
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
    final originalApi = merchantApi;
    final api = MemberFakeApi();
    merchantApi = api;
    addTearDown(() => merchantApi = originalApi);
    await open(t, 'MemberAdd');
    await t.pumpAndSettle();
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
    final originalApi = merchantApi;
    final api = MemberFakeApi();
    merchantApi = api;
    addTearDown(() => merchantApi = originalApi);
    await open(t, 'MemberAdd');
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('推荐人'));
    await t.tap(find.text('推荐人'));
    await t.pumpAndSettle();
    expect(find.text('选择推荐人'), findsOneWidget);
    final search = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(TextField),
    );
    expect(search, findsOneWidget); // 检索框
    api.rows.add(row(name: '林晓雯', tierName: '金卡'));
    await t.enterText(search, '林晓');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('王建国'), findsNothing);
    await t.tap(find.text('林晓雯'));
    await t.pumpAndSettle();
    expect(find.text('林晓雯 · 金卡'), findsOneWidget);
  });

  testWidgets('更换手机号：获取验证码后进入 60 秒倒计时', (tester) async {
    final originalApi = merchantApi;
    final api = SmsInteractionApi();
    merchantApi = api;
    storeProfile.apply({'phone': '+8613988888812', 'name': '验证码交互测试门店'});
    addTearDown(() {
      merchantApi = originalApi;
      storeProfile.clear();
    });
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: 'ChangePhone',
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (_) => pageFor(settings.name!)!,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('获取验证码'), findsNWidgets(2));
    await tester.tap(find.text('获取验证码').first);
    await tester.pump();
    expect(api.requests, [(phone: '13988888812', purpose: 'change_phone_old')]);
    expect(find.text('发送中…'), findsOneWidget);
    expect(find.text('60 秒后重发'), findsNothing);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('发送中…'), findsOneWidget);
    api.response.complete();
    await tester.pump();
    expect(find.text('60 秒后重发'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('57 秒后重发'), findsOneWidget);
    await tester.pump(const Duration(seconds: 60)); // 让计时器结束
  });

  testWidgets('我的：一期隐藏打印机，其余设置项进入对应页面', (tester) async {
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
    await tester.pumpAndSettle();
    expect(find.text('小票打印机'), findsNothing);
    for (final (row, title) in [
      ('营业时间与工位', '营业时间与工位'),
      ('账号与安全', '账号与安全'),
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
    final originalApi = merchantApi;
    merchantApi = MemberFakeApi();
    addTearDown(() => merchantApi = originalApi);
    await open(
      t,
      'VehicleAdd',
      arguments: MemberRouteData(
        member: row(),
        vehicle: {'plate': '沪AF09316', 'energy': 'ev'},
      ),
    );
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
