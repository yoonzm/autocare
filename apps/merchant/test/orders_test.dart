import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/order_flow.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/order_live_pages.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'members_test.dart' show MemberFakeApi, phone;

String _iso(int h, int m, {int dayOffset = 0}) {
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final d = DateTime.utc(
    now.year,
    now.month,
    now.day,
    h,
    m,
  ).subtract(Duration(days: dayOffset));
  return d.subtract(const Duration(hours: 8)).toIso8601String();
}

class OrderApi extends MemberFakeApi {
  final calls = <Map<String, dynamic>>[];
  @override
  Object? listError;
  Completer<void>? gate;
  bool orderRefunded = false;
  List<Map<String, dynamic>> items = [
    {
      'key': 'consume:c1',
      'kind': 'consume',
      'id': 'c1',
      'at': _iso(12, 5),
      'title': '全车镀晶 · 9H',
      'pay_label': '储值 + 微信',
      'who': '王建国',
      'amount': 1422,
      'cash': 422,
      'status': 'completed',
      'operator': '陈明',
      'order_no': '20261103-0412',
    },
    {
      'key': 'recharge:r1',
      'kind': 'recharge',
      'id': 'r1',
      'at': _iso(10, 20),
      'title': '储值充值 · 送 ¥300',
      'pay_label': '微信',
      'who': '李女士',
      'amount': 2000,
      'cash': 2000,
      'status': 'completed',
      'operator': '陈明',
      'order_no': '20261103-0398',
    },
    {
      'key': 'refund:p1',
      'kind': 'refund',
      'id': 'p1',
      'at': _iso(9, 15),
      'title': '次卡退款',
      'pay_label': '原路退回',
      'who': '陈先生',
      'amount': -432,
      'cash': -432,
      'status': 'completed',
      'operator': '陈明',
      'order_no': '20261103-0390',
    },
    {
      'key': 'consume:c0',
      'kind': 'consume',
      'id': 'c0',
      'at': _iso(17, 20, dayOffset: 1),
      'title': '车身打蜡',
      'pay_label': '微信',
      'who': '沪C·D9981',
      'amount': 198,
      'cash': 198,
      'status': 'completed',
      'operator': '陈明',
      'order_no': '20261102-0301',
    },
  ];

  Map<String, dynamic> get _summary => {
    'received': 2620,
    'refunded': 432,
    'net': 2188,
    'wechat': 2620,
    'alipay': 0,
    'cash_pay': 0,
    'pos': 0,
    'balance': 1000,
  };

  @override
  Future<Map<String, dynamic>> orderCenter(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add({'action': action, ...values});
    await gate?.future;
    if (action == 'list') {
      if (listError != null) throw listError!;
      final type = values['type'] ?? 'all';
      final rows = [
        for (final e in items)
          if (type == 'all' || e['kind'] == type) {...e},
      ];
      return {
        'items': rows,
        'summary': rows.isEmpty && items.isEmpty
            ? {for (final k in _summary.keys) k: 0}
            : _summary,
        'has_more': false,
        'operators': ['陈明', '周强'],
      };
    }
    if (action == 'detail') {
      return {
        'kind': 'consume',
        'id': 'c1',
        'order_no': '20261103-0412',
        'status': orderRefunded ? 'refunded' : 'completed',
        'amount': 1422,
        'at': _iso(12, 5),
        'plate': '沪A8K29M',
        'operator': '陈明',
        'remark': '',
        'member': {'id': 'm1', 'name': '王建国', 'level': '黑金会员'},
        'items': [
          {
            'name': '全车镀晶 · 9H',
            'qty': 1,
            'unit_price': 1380,
            'line_total': 1380,
            'package': null,
          },
          {
            'name': '车内香氛',
            'qty': 1,
            'unit_price': 42,
            'line_total': 42,
            'package': null,
          },
        ],
        'payments': [
          {'label': '储值余额', 'amount': 1000},
          {'label': '微信支付', 'amount': 422},
        ],
        'refund': orderRefunded
            ? {'at': _iso(13, 0), 'reason': '服务问题', 'amount': 1422}
            : null,
        'can_refund': !orderRefunded,
      };
    }
    if (action == 'refund') {
      orderRefunded = true;
      return {'order_id': 'c1', 'refund': 1422};
    }
    throw UnimplementedError(action);
  }
}

void main() {
  late MerchantApi original;
  late OrderApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = OrderApi();
    navTracker.stack.clear();
    OrderFlow.reset();
    OrderRef.current = null;
  });
  tearDown(() {
    merchantApi = original;
    OrderFlow.reset();
  });

  Future<void> open(WidgetTester t, Widget page) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(builder: (_) => const Scaffold()),
          MaterialPageRoute(builder: (_) => page),
        ],
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('订单列表：汇总卡片、按天分组、四种类型的订单行都来自后端', (t) async {
    await open(t, const OrderListLivePage());
    expect(find.text('订单'), findsOneWidget);
    expect(find.text('今日收款'), findsOneWidget);
    expect(find.text('¥2,620'), findsWidgets); // 实收
    expect(find.text('¥432'), findsOneWidget); // 退款
    expect(find.text('¥2,188'), findsOneWidget); // 净收入
    expect(find.text('储值抵扣是会员用余额消费，不是新收的钱，不计入实收'), findsOneWidget);
    expect(find.text('全车镀晶 · 9H'), findsOneWidget);
    expect(find.text('12:05 · 储值 + 微信 · 王建国'), findsOneWidget);
    expect(find.text('储值充值 · 送 ¥300'), findsOneWidget);
    expect(find.text('-¥432'), findsOneWidget);
    expect(find.text('次卡退款'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(find.textContaining('昨天'), findsOneWidget);
    expect(find.text('车身打蜡'), findsOneWidget);
    // 设计稿里的示例客户不会混进来
    expect(find.text('周先生'), findsNothing);
    expect(find.text('¥4,182'), findsNothing);
  });

  testWidgets('订单列表：当天分组标题只累加真正收进来的钱（储值抵扣不计入）', (t) async {
    await open(t, const OrderListLivePage());
    // 今天：实收 422 + 2000 = 2,422；退款 432
    expect(find.text('实收 ¥2,422 · 退款 ¥432'), findsOneWidget);
    expect(find.text('实收 ¥198'), findsOneWidget);
  });

  testWidgets('类型标签、时间范围会重新请求；搜索防抖 300ms 后带上关键字', (t) async {
    await open(t, const OrderListLivePage());
    await t.tap(find.text('充值').first);
    await t.pumpAndSettle();
    expect(api.calls.last['type'], 'recharge');
    await t.tap(find.text('昨日'));
    await t.pumpAndSettle();
    expect(api.calls.last['range'], 'yesterday');
    final before = api.calls.length;
    await t.enterText(find.byType(TextField), '沪A8K29M');
    await t.pump(const Duration(milliseconds: 100));
    expect(api.calls.length, before);
    await t.pump(const Duration(milliseconds: 300));
    await t.pumpAndSettle();
    expect(api.calls.last['q'], '沪A8K29M');
  });

  testWidgets('搜索框没值时有占位文字', (t) async {
    await open(t, const OrderListLivePage());
    final field = t.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.hintText, '车牌 / 手机号 / 订单号');
  });

  testWidgets('今天没有订单：汇总为 ¥0，显示空状态和“去开单”，不显示搜索和类型标签', (t) async {
    api.items = [];
    await open(t, const OrderListLivePage());
    expect(find.text('今天还没有订单'), findsOneWidget);
    expect(find.text('开单收款后，订单会出现在这里'), findsOneWidget);
    expect(find.text('去开单'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('¥0'), findsWidgets);
  });

  testWidgets('读取失败：整页错误 + 重试，重试成功后显示订单', (t) async {
    api.listError = const AppError.network();
    await open(t, const OrderListLivePage());
    expect(find.text('重试'), findsOneWidget);
    api.listError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('全车镀晶 · 9H'), findsOneWidget);
  });

  testWidgets('首次加载：先显示标题栏和页签，再出骨架，不闪烁', (t) async {
    api.gate = Completer<void>();
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: const OrderListLivePage(),
      ),
    );
    await t.pump();
    expect(find.text('订单'), findsOneWidget);
    expect(find.text('今日'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 50));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.byType(AppSkeleton), findsNothing);
  });

  testWidgets('点订单行进入详情：项目明细、支付明细（储值 + 微信）、经办人，退款按钮可见', (t) async {
    await open(t, const OrderListLivePage());
    await t.tap(find.text('全车镀晶 · 9H'));
    await t.pumpAndSettle();
    expect(api.calls.last['action'], 'detail');
    expect(api.calls.last['type'], 'consume');
    expect(find.text('订单详情'), findsOneWidget);
    expect(find.text('¥1,422.00'), findsOneWidget);
    expect(find.text('订单号 20261103-0412 · 今天 12:05'), findsOneWidget);
    expect(find.text('王建国 · 黑金会员'), findsOneWidget);
    expect(find.text('项目明细'), findsOneWidget);
    expect(find.text('储值余额'), findsOneWidget);
    expect(find.text('微信支付'), findsOneWidget);
    expect(find.text('实付合计'), findsOneWidget);
    expect(find.text('经办人'), findsOneWidget);
    expect(find.text('退款'), findsOneWidget);
    expect(find.text('补打小票'), findsOneWidget);
  });

  testWidgets('补打小票：打印机没接入，明确提示，不假装成功', (t) async {
    OrderRef.current = (kind: 'consume', id: 'c1');
    await open(t, const OrderDetailLivePage());
    await t.tap(find.text('补打小票'));
    await t.pump();
    expect(find.text('打印机尚未接入，暂不能补打小票'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('退款：全额退款 + 原因提交到云函数，成功后订单显示已退款，退款按钮消失', (t) async {
    OrderRef.current = (kind: 'consume', id: 'c1');
    await open(t, const OrderDetailLivePage());
    await t.tap(find.text('退款'));
    await t.pumpAndSettle();
    expect(find.text('订单退款'), findsOneWidget);
    expect(find.text('全额退款 ¥1,422'), findsOneWidget);
    expect(find.text('退回储值余额'), findsOneWidget);
    expect(find.text('原路退回微信'), findsOneWidget);
    expect(find.text('退款后订单状态变为已退款，操作不能撤销。'), findsOneWidget);
    await t.tap(find.text('会员不再需要'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认退款 ¥1,422'));
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'refund');
    expect(call['id'], 'c1');
    expect(call['reason'], '会员不再需要');
    expect(call.containsKey('amount'), isFalse); // 退款金额由服务端按订单算，客户端不传
    await t.pump(const Duration(seconds: 1));
    expect(find.text('已退款'), findsWidgets);
    expect(find.text('退款信息'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('部分退款没有规则：提示暂未支持，不提交', (t) async {
    OrderRef.current = (kind: 'consume', id: 'c1');
    await open(t, const OrderDetailLivePage());
    await t.tap(find.text('退款'));
    await t.pumpAndSettle();
    await t.tap(find.text('部分退款'));
    await t.pump();
    expect(find.text('部分退款暂未支持，请选择全额退款'), findsWidgets);
    expect(api.calls.where((c) => c['action'] == 'refund'), isEmpty);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('退款失败：保留弹层并说明原因，可再次提交', (t) async {
    OrderRef.current = (kind: 'consume', id: 'c1');
    await open(t, const OrderDetailLivePage());
    await t.tap(find.text('退款'));
    await t.pumpAndSettle();
    api.orderRefunded = false;
    final orig = merchantApi;
    merchantApi = _FailingRefund(api);
    await t.tap(find.text('确认退款 ¥1,422'));
    await t.pumpAndSettle();
    expect(find.text('订单退款'), findsOneWidget);
    expect(find.textContaining('已经退款'), findsWidgets);
    merchantApi = orig;
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('充值订单详情：入账明细，没有退款按钮', (t) async {
    final recharge = _RechargeDetail(api);
    merchantApi = recharge;
    OrderRef.current = (kind: 'recharge', id: 'r1');
    await open(t, const OrderDetailLivePage());
    expect(find.text('入账明细'), findsOneWidget);
    expect(find.text('+¥2,000'), findsOneWidget);
    expect(find.text('+¥300'), findsOneWidget);
    expect(find.text('入账后余额'), findsOneWidget);
    expect(find.text('退款'), findsNothing);
    expect(find.text('补打小票'), findsOneWidget);
  });

  test('金额与日期文字：千分位、整数不带小数、负数、日期分组标题', () {
    expect(OrderFlow.money(1422), '¥1,422');
    expect(OrderFlow.money(68.5), '¥68.50');
    expect(OrderFlow.money(-432), '-¥432');
    expect(OrderFlow.money2(1422), '¥1,422.00');
    final now = DateTime.utc(2026, 11, 3, 4); // 北京时间 11-03 12:00
    expect(OrderFlow.dayTitle('2026-11-03T02:00:00Z', now: now), '今天');
    expect(OrderFlow.dayTitle('2026-11-02T02:00:00Z', now: now), '昨天 11.02');
    expect(OrderFlow.dayTitle('2026-10-31T02:00:00Z', now: now), '10.31 周六');
  });
}

class _FailingRefund extends OrderApi {
  _FailingRefund(OrderApi base) {
    items = base.items;
  }
  @override
  Future<Map<String, dynamic>> orderCenter(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'refund') throw const AppError('这笔订单已经退款，不能重复退款');
    return super.orderCenter(action, values);
  }
}

class _RechargeDetail extends OrderApi {
  _RechargeDetail(OrderApi base) {
    items = base.items;
  }
  @override
  Future<Map<String, dynamic>> orderCenter(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'detail') {
      return {
        'kind': 'recharge',
        'id': 'r1',
        'order_no': '20261103-0398',
        'status': 'completed',
        'amount': 2000,
        'gift': 300,
        'balance_after': 3420,
        'at': _iso(10, 20),
        'operator': '陈明',
        'remark': '',
        'member': {'id': 'm2', 'name': '李女士', 'level': '金卡', 'balance': 3420},
        'items': [],
        'payments': [
          {'label': '微信支付', 'amount': 2000},
        ],
        'can_refund': false,
      };
    }
    return super.orderCenter(action, values);
  }
}
