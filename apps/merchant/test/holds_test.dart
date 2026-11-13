import 'package:autocare_merchant/pages/orders/hold_list_page.dart';
import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';

import 'package:autocare_merchant/pages/orders/order_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi, phone, row;

Map<String, dynamic>? fixtureMember;

/// 从有名字的页面进入（真实流程里开单页的路由名就是 Order，取单后会回到它）。
Widget appNamed(String name, Widget home) => MaterialApp(
  navigatorObservers: [navTracker],
  initialRoute: name,
  onGenerateRoute: (s) => MaterialPageRoute(settings: s, builder: (_) => home),
);

Map<String, dynamic> hold({
  String id = 'h1',
  String status = '施工中',
  String name = '王建国',
  String level = '金卡',
  List<String> items = const ['精致洗车', '内饰深度清洁'],
  String note = '',
  num estimate = 342,
  int updatedMinutesAgo = 5,
  String plate = 'A8K29M',
  bool walkIn = false,
}) {
  final at = DateTime.now().subtract(Duration(minutes: updatedMinutesAgo));
  return {
    'id': id,
    'member_id': walkIn ? null : 'm1',
    'status': status,
    'note': note,
    'remind': '完工时',
    'vehicle_plate': plate.isEmpty ? '' : '沪$plate',
    'estimate': estimate,
    'created_at': at.toUtc().toIso8601String(),
    'updated_at': at.toUtc().toIso8601String(),
    'member': walkIn
        ? null
        : {
            'id': 'm1',
            'name': name,
            'card': {'name': level},
          },
    'items': [
      for (var i = 0; i < items.length; i++)
        {'position': i, 'service_id': 's${i + 1}', 'name': items[i], 'qty': 1},
    ],
  };
}

void main() {
  late MerchantApi original;
  late MemberFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = MemberFakeApi();
    merchantApi = fake;

    fixtureMember = null;
    HoldStore.reset();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;

    fixtureMember = null;
    HoldStore.reset();
    navTracker.stack.clear();
  });

  void seedOrder() {
    final r = row(
      vehicles: [
        {'plate': '沪A8K29M', 'energy': 'fuel', 'brand_model': '宝马 5系'},
      ],
    );
    (r['card'] as Map)['discount'] = 0.95;
    fake.rows.add(r);
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
    fixtureMember = r;
  }

  Future<void> openOrder(WidgetTester t) async {
    seedOrder();
    await t.pumpWidget(
      appNamed('Order', OrderPage(member: memberFromRow(fixtureMember!))),
    );
    await t.pumpAndSettle();
  }

  Future<void> openList(WidgetTester t) async {
    await t.pumpWidget(appNamed('HoldList', pageFor('HoldList')!));
    await t.pumpAndSettle();
  }

  group('挂起', () {
    testWidgets('没选项目不能挂单，也不会弹出挂单保存', (t) async {
      phone(t);
      await openOrder(t);
      await t.tap(find.text('挂单').last);
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('请先选择服务项目'), findsOneWidget);
      expect(find.text('挂单保存'), findsNothing);
      expect(fake.heldSaves, isEmpty);
    });

    testWidgets('挂单保存：弹层显示会员和项目数；只提交选择，成功后开单页清空并进入挂单列表', (t) async {
      phone(t);
      await openOrder(t);
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('内饰深度清洁'));
      await t.pump();
      await t.tap(find.text('挂单').last);
      await t.pumpAndSettle();
      expect(find.text('挂单保存'), findsOneWidget);
      expect(find.text('2 项服务'), findsOneWidget);
      expect(find.text('沪A·8K29M'), findsWidgets);
      await t.enterText(find.byType(TextFormField), '客户去开会，17:00 取车');
      await t.tap(find.text('待结算'));
      await t.pump();
      await t.tap(find.text('1 小时'));
      await t.pump();
      await t.tap(find.text('确认挂单'));
      await t.pumpAndSettle();
      final sent = fake.heldSaves.single;
      expect(sent['hold'], isNull);
      expect(sent['member'], 'm1');
      expect(sent['status'], '待结算');
      expect(sent['remind'], '1 小时');
      expect(sent['note'], '客户去开会，17:00 取车');
      expect(sent['plate'], '沪A8K29M');
      expect(sent['lines'], [
        {'service_id': 's1', 'qty': 1},
        {'service_id': 's2', 'qty': 1},
      ]);
      // 客户端不上传价格 / 折扣 / 估价
      expect(sent.toString().contains('price'), isFalse);
      expect(find.text('挂单待收款'), findsOneWidget);
      expect(find.text('共 1 单'), findsOneWidget);
      expect(find.text('¥342.00'), findsWidgets); // 云函数估的价
      Navigator.of(t.element(find.byType(HoldListPage))).pop();
      await t.pumpAndSettle();
      expect(find.text('¥0.00'), findsWidgets);
    });

    testWidgets('默认状态是“施工中”、提醒是“完工时”（和设计稿一致）', (t) async {
      phone(t);
      await openOrder(t);
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('挂单').last);
      await t.pumpAndSettle();
      await t.tap(find.text('确认挂单'));
      await t.pumpAndSettle();
      expect(fake.heldSaves.single['status'], '施工中');
      expect(fake.heldSaves.single['remind'], '完工时');
      expect(fake.heldSaves.single['note'], '');
    });

    testWidgets('保存失败时说明原因，留在弹层里，开单页的选择不丢', (t) async {
      phone(t);
      await openOrder(t);
      fake.holdSaveError = const AppError('服务项目不存在或已下架');
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('挂单').last);
      await t.pumpAndSettle();
      await t.tap(find.text('确认挂单'));
      await t.pumpAndSettle();
      expect(find.text('服务项目不存在或已下架'), findsOneWidget);
      expect(find.text('挂单保存'), findsOneWidget);
      expect(fake.heldSaves, isEmpty);
    });

    testWidgets('开单页的“挂单”数量来自后端，没有挂单时不显示数字', (t) async {
      phone(t);
      await openOrder(t);
      expect(find.text('4'), findsNothing);
      expect(find.text('0'), findsNothing);
      fake.holdRows.addAll([hold(), hold(id: 'h2')]);
      await HoldStore.load();
      await t.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('挂单列表', () {
    testWidgets('概况、页签数量和卡片来自后端；页签按状态筛选', (t) async {
      phone(t);
      fake.holdRows.addAll([
        hold(note: '客户去开会，17:00 取车'),
        hold(
          id: 'h2',
          status: '待结算',
          name: '李女士',
          estimate: 880,
          updatedMinutesAgo: 30,
        ),
        hold(
          id: 'h3',
          status: '待施工',
          name: '赵先生',
          items: ['基础洗车'],
          estimate: 98,
        ),
      ]);
      await openList(t);
      expect(find.text('¥1,320.00'), findsOneWidget);
      expect(find.text('共 3 单'), findsOneWidget);
      expect(find.text('全部 3'), findsOneWidget);
      expect(find.text('待施工 1'), findsOneWidget);
      expect(find.text('施工中 1'), findsOneWidget);
      expect(find.text('待结算 1'), findsOneWidget);
      expect(find.text('精致洗车 · 内饰深度清洁'), findsNWidgets(2));
      expect(find.text('备注：客户去开会，17:00 取车'), findsOneWidget);
      expect(find.text('1 单已完工，等待超 20 分钟'), findsOneWidget);
      // 设计稿里的示例不再出现
      expect(find.textContaining('老周'), findsNothing);
      await t.tap(find.text('待施工 1'));
      await t.pump();
      expect(find.text('赵先生'), findsOneWidget);
      expect(find.text('李女士'), findsNothing);
      await t.tap(find.text('待结算 1'));
      await t.pump();
      expect(find.text('李女士'), findsOneWidget);
      expect(find.text('提醒取车'), findsWidgets);
    });

    testWidgets('没有挂单时是空状态；读取失败时可以重试', (t) async {
      phone(t);
      await openList(t);
      expect(find.text('暂无挂单'), findsOneWidget);
      expect(find.text('共 0 单'), findsOneWidget);

      await t.pumpWidget(const SizedBox());
      HoldStore.reset();
      fake.holdsError = const AppError('网络不稳定', type: AppErrorType.network);
      await openList(t);
      expect(find.text('重试'), findsOneWidget);
      fake.holdsError = null;
      fake.holdRows.add(hold());
      await t.tap(find.text('重试'));
      await t.pumpAndSettle();
      expect(find.text('共 1 单'), findsOneWidget);
    });

    testWidgets('提醒取车依赖消息通知模块：明确提示未接通，不假装已发送', (t) async {
      phone(t);
      fake.holdRows.add(hold(status: '待结算', updatedMinutesAgo: 40));
      await openList(t);
      await t.tap(find.text('提醒取车').first);
      await t.pump();
      expect(find.textContaining('暂未接通'), findsOneWidget);
    });

    testWidgets('删除：先确认，再由后端删除，成功后卡片局部移除', (t) async {
      phone(t);
      fake.holdRows.addAll([hold(), hold(id: 'h2', name: '赵先生')]);
      await openList(t);
      await t.tap(
        find
            .byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == '删除挂单',
            )
            .first,
      );
      await t.pumpAndSettle();
      expect(find.text('确认删除？'), findsOneWidget);
      await t.tap(find.text('取消'));
      await t.pumpAndSettle();
      expect(fake.heldCancelled, isEmpty);
      await t.tap(
        find
            .byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == '删除挂单',
            )
            .first,
      );
      await t.pumpAndSettle();
      await t.tap(find.text('删除'));
      await t.pumpAndSettle();
      expect(fake.heldCancelled, ['h1']);
      expect(find.text('王建国'), findsNothing);
      expect(find.text('赵先生'), findsOneWidget);
      expect(find.text('共 1 单'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(seconds: 1)); // 等“已删除挂单”提示消失
      }
    });
  });

  group('取单结算', () {
    testWidgets('取单：项目放回开单页；确认收款带着挂单 ID，结清后挂单消失', (t) async {
      phone(t);
      fake.holdRows.add(hold(note: '客户去开会'));
      await openOrder(t);
      // 开单页 → 挂单列表 → 取单结算
      await t.tap(find.text('挂单').first);
      await t.pumpAndSettle();
      expect(find.text('挂单待收款'), findsOneWidget);
      await t.tap(find.text('取单结算'));
      await t.pumpAndSettle();
      expect(find.text('开单收银'), findsOneWidget);
      expect(find.text('¥425.60'), findsWidgets); // 开单页按当前价格重新算（金卡 9.5 折）
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      final sent = fake.checkouts.single;
      expect(sent['hold'], 'h1');
      expect(sent['lines'], [
        {'service_id': 's1', 'qty': 1},
        {'service_id': 's2', 'qty': 1},
      ]);
      expect(fake.holdRows, isEmpty);
      expect(HoldStore.count, 0);
    });

    testWidgets('取回来再挂单：更新同一张挂单，而不是新建', (t) async {
      phone(t);
      fake.holdRows.add(hold(note: '客户去开会'));
      await openOrder(t);
      await t.tap(find.text('挂单').first);
      await t.pumpAndSettle();
      await t.tap(find.text('加项'));
      await t.pumpAndSettle();
      await t.tap(find.text('挂单').last);
      await t.pumpAndSettle();
      await t.tap(find.text('确认挂单'));
      await t.pumpAndSettle();
      expect(fake.heldSaves.single['hold'], 'h1');
      expect(fake.holdRows.length, 1);
    });

    testWidgets('新开一单：开单页回到空白，不再带着之前取出的挂单', (t) async {
      phone(t);
      fake.holdRows.add(hold());
      await openOrder(t);
      await t.tap(find.text('挂单').first);
      await t.pumpAndSettle();
      await t.tap(find.text('取单结算'));
      await t.pumpAndSettle();
      await t.tap(find.text('挂单').first);
      await t.pumpAndSettle();
      await t.tap(find.text('新开一单'));
      await t.pumpAndSettle();
      await t.tap(find.text('确认收款'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('请先选择服务项目'), findsOneWidget);
      expect(fake.checkouts, isEmpty);
    });
  });

  group('散客挂单', () {
    testWidgets('散客挂单：只提交选择（不带会员、次卡、价格），列表里显示“散客 · 非会员”', (t) async {
      phone(t);
      seedOrder();
      fixtureMember = null;
      await t.pumpWidget(appNamed('Order', const OrderPage()));
      await t.pumpAndSettle();
      await t.tap(find.text('散客开单'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).first, '苏K5F218');
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('挂单').last);
      await t.pumpAndSettle();
      expect(find.text('挂单保存'), findsOneWidget);
      expect(find.text('散客'), findsWidgets);
      expect(find.text('客'), findsOneWidget);
      expect(find.text('苏K5F218'), findsWidgets);
      await t.tap(find.text('确认挂单'));
      await t.pumpAndSettle();
      final sent = fake.heldSaves.single;
      expect(sent['member'], isNull);
      expect(sent['plate'], '苏K5F218');
      expect(sent['lines'], [
        {'service_id': 's1', 'qty': 1},
      ]);
      expect(sent.toString().contains('price'), isFalse);
      expect(find.text('挂单待收款'), findsOneWidget);
      expect(find.text('散客'), findsOneWidget);
      expect(find.text('非会员'), findsOneWidget);
      expect(find.text('苏K·5F218'), findsOneWidget);
    });

    testWidgets('取单结算散客挂单：回到散客状态（含车牌、项目），收款带着挂单 ID 走散客收款', (t) async {
      phone(t);
      fake.holdRows.add(hold(walkIn: true, items: ['精致洗车'], plate: 'K5F218'));
      seedOrder();
      fixtureMember = null;
      await t.pumpWidget(appNamed('Order', const OrderPage()));
      await t.pumpAndSettle();
      await t.tap(find.text('挂单').first);
      await t.pumpAndSettle();
      expect(find.text('散客'), findsOneWidget);
      await t.tap(find.text('取单结算'));
      await t.pumpAndSettle();
      expect(find.text('开单收银'), findsOneWidget);
      expect(find.text('不记会员'), findsOneWidget);
      expect(find.text('¥68.00'), findsWidgets); // 原价，没有折扣
      await t.tap(find.text('现金'));
      await t.pump();
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      final sent = fake.walkIns.single;
      expect(sent['hold'], 'h1');
      expect(sent['method'], '现金');
      expect(fake.checkouts, isEmpty);
      expect(fake.holdRows, isEmpty);
    });
  });

  testWidgets('未登录的挂单列表引导登录，不显示示例数据', (t) async {
    phone(t);
    merchantApi = original;
    await t.pumpWidget(appNamed('HoldList', pageFor('HoldList')!));
    await t.pumpAndSettle();
    expect(find.text('重新登录'), findsOneWidget);
    expect(find.text('¥21,200.00'), findsNothing);
    expect(find.text('全部 4'), findsNothing);
    expect(find.textContaining('老周 · 3 号工位'), findsNothing);
  });
}
