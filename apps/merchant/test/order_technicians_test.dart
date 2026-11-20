import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/orders/order_page.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_info_template.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'members_test.dart' show MemberFakeApi, phone, row;

class TechnicianApi extends MemberFakeApi {
  List<Map<String, dynamic>> resources = [
    {
      'id': 't1',
      'kind': 'technician',
      'name': '真实技师',
      'category': '精洗',
      'active': true,
    },
    {
      'id': 't2',
      'kind': 'technician',
      'name': '无技能技师',
      'category': '',
      'active': true,
    },
    {'id': 't3', 'kind': 'technician', 'name': '停用技师', 'active': false},
    {'id': 'b1', 'kind': 'bay', 'name': '真实工位', 'active': true},
  ];
  Object? error;
  Completer<void>? gate;
  final staffWorkCalls = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action != 'options') return super.appointment(action, values);
    await gate?.future;
    if (error != null) throw error!;
    return {'resources': resources};
  }

  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    staffWorkCalls.add({'action': action, ...values});
    if (action == 'staff_member_search') {
      return {
        'items': [
          {
            'id': 'm1',
            'name': '王建国',
            'level': '黑金卡',
            'discount': 0.9,
            'balance': 3680,
            'phone_masked': '138****6021',
            'plate': '沪A8K29M',
            'card': {'name': '黑金卡', 'discount': 0.9},
            'vehicles': [
              {'plate': '沪A8K29M'},
            ],
          },
        ],
      };
    }
    if (action == 'staff_member_info') {
      return {
        'id': 'm1',
        'name': '王建国',
        'level': '黑金卡',
        'discount': 0.9,
        'balance': 3680,
        'phone_masked': '138****6021',
        'plate': '沪A8K29M',
        'vehicles': [
          {'plate': '沪A8K29M', 'model': '宝马 5 系', 'color': '黑色'},
        ],
        'packages': [
          {
            'id': 'p1',
            'name': '精致洗车年卡',
            'remaining': 8,
            'total': 10,
            'items': [
              {'service_id': 's1', 'name': '精致洗车', 'remaining': 8},
            ],
          },
        ],
      };
    }
    return super.staffWork(action, values);
  }
}

void main() {
  late MerchantApi original;
  late TechnicianApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = TechnicianApi();
    ServiceStore.clear();
    HoldStore.reset();
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });
  tearDown(() {
    merchantApi = original;
    ServiceStore.clear();
    HoldStore.reset();
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });
  Future<void> open(
    WidgetTester t, {
    Map<String, dynamic>? appointment,
    Map<String, dynamic>? hold,
    bool settle = true,
  }) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        home: OrderPage(
          member: memberFromRow(row()),
          appointment: appointment,
          hold: hold,
        ),
      ),
    );
    if (settle) {
      await t.pumpAndSettle();
    } else {
      await t.pump();
    }
  }

  bool selected(WidgetTester t, String label) => t
      .widgetList<Container>(
        find.ancestor(of: find.text(label), matching: find.byType(Container)),
      )
      .any(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration! as BoxDecoration).border != null,
      );

  testWidgets('真实姓名技能、过滤停用技师和工位，默认不选人', (t) async {
    await open(t);
    expect(find.text('真实技师 · 精洗'), findsOneWidget);
    expect(find.text('无技能技师'), findsOneWidget);
    expect(find.text('停用技师'), findsNothing);
    expect(find.text('真实工位'), findsNothing);
    expect(find.text('李国强 · 镀晶'), findsNothing);
    expect(selected(t, '真实技师 · 精洗'), isFalse);
    await t.ensureVisible(find.text('真实技师 · 精洗'));
    await t.tap(find.text('真实技师 · 精洗'));
    await t.pump();
    expect(selected(t, '真实技师 · 精洗'), isTrue);
    expect(t.takeException(), isNull);
  });

  testWidgets('较长技能名称不撑破技师标签', (t) async {
    api.resources.first['category'] = '洗车 / 内饰清洁 / 镀晶 / 抛光 / 贴膜 / 石墨烯镀膜 / 空调杀菌';
    await open(t);
    await t.ensureVisible(find.textContaining('真实技师 · 洗车'));
    expect(t.takeException(), isNull);
  });

  testWidgets('取单恢复挂单选中的技师，包含后来停用的人员', (t) async {
    api.rows.add(row());
    await open(
      t,
      hold: {
        'id': 'h1',
        'member_id': 'm1',
        'items': [],
        'technician_ids': ['t2', 't3'],
      },
    );
    expect(selected(t, '真实技师 · 精洗'), isFalse);
    expect(selected(t, '无技能技师'), isTrue);
    expect(selected(t, '停用技师'), isTrue);
    await t.ensureVisible(find.text('停用技师'));
    await t.tap(find.text('停用技师'));
    await t.pump();
    expect(find.text('停用技师'), findsNothing);
  });

  testWidgets('挂单发送开单页勾选的所有技师', (t) async {
    api.services.add({
      'id': 's1',
      'name': '精致洗车',
      'price': 68,
      'category': '洗车',
      'active': true,
    });
    await open(t);
    await t.tap(find.text('精致洗车'));
    for (final name in ['真实技师 · 精洗', '无技能技师']) {
      await t.ensureVisible(find.text(name));
      await t.tap(find.text(name));
      await t.pump();
    }
    await t.tap(find.text('挂单').last);
    await t.pumpAndSettle();
    await t.tap(find.text('确认挂单'));
    await t.pumpAndSettle();
    expect(api.heldSaves.single['technician_ids'], ['t1', 't2']);
  });

  testWidgets('预约带入真实技师，刷新停用后移除', (t) async {
    await open(
      t,
      appointment: {
        'id': 'a1',
        'member_id': 'm1',
        'technician_id': 't1',
        'service_ids': [],
      },
    );
    expect(selected(t, '真实技师 · 精洗'), isTrue);
    api.resources = [];
    AppointmentFlow.changed.value++;
    await t.pumpAndSettle();
    expect(find.textContaining('还没有可用技师'), findsOneWidget);
    expect(find.text('真实技师 · 精洗'), findsNothing);
  });

  testWidgets('加载延迟骨架，失败重试，不回退示例人员', (t) async {
    api.gate = Completer<void>();
    await open(t, settle: false);
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.error = const AppError('读取技师失败', type: AppErrorType.server);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('李国强 · 镀晶'), findsNothing);
    api.error = null;
    await t.ensureVisible(find.text('重试'));
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('真实技师 · 精洗'), findsOneWidget);
  });

  testWidgets('刷新失败保留原有技师', (t) async {
    await open(t);
    api.error = const AppError('网络不太给力', type: AppErrorType.network);
    AppointmentFlow.changed.value++;
    await t.pumpAndSettle();
    expect(find.text('真实技师 · 精洗'), findsOneWidget);
    expect(find.text('网络不太给力'), findsOneWidget);
    await t.pump(const Duration(seconds: 9));
  });

  testWidgets('技师身份复用开单页：默认选中当前技师，可取消或加选，走脱敏会员选择与次卡读取', (t) async {
    Access.apply({
      'role': 'technician',
      'staff_id': 'st1',
      'resource_id': 't1',
      'store_id': 's1',
      'caps': {
        'cashier': true,
        'order_submit': true,
        'member_lookup': true,
        'member_view': false,
        'member_edit': false,
      },
    });
    api.services.add({
      'id': 's1',
      'name': '精致洗车',
      'price': 68,
      'category': '洗车',
      'active': true,
    });
    phone(t);
    await t.pumpWidget(const MaterialApp(home: OrderPage()));
    await t.pumpAndSettle();
    // 打开选择会员弹层：技师走脱敏接口且不显示「新增会员」
    await t.tap(find.text('选择会员'));
    await t.pumpAndSettle();
    expect(
      api.staffWorkCalls.where((c) => c['action'] == 'staff_member_search'),
      hasLength(1),
    );
    expect(find.text('新增会员'), findsNothing);
    expect(find.textContaining('138 **** 6021'), findsOneWidget);
    await t.tap(find.text('王建国'));
    await t.pumpAndSettle();
    expect(
      api.staffWorkCalls.where((c) => c['action'] == 'staff_member_info'),
      hasLength(1),
    );
    // 默认选中当前技师 t1，其他技师未选中
    expect(selected(t, '真实技师 · 精洗'), isTrue);
    expect(selected(t, '无技能技师'), isFalse);
    // 可手动加选其他技师
    await t.ensureVisible(find.text('无技能技师'));
    await t.tap(find.text('无技能技师'));
    await t.pump();
    expect(selected(t, '无技能技师'), isTrue);
    // 可取消当前技师
    await t.tap(find.text('真实技师 · 精洗'));
    await t.pump();
    expect(selected(t, '真实技师 · 精洗'), isFalse);
  });

  testWidgets('技师从会员简况点「为他开单」直接进入商家端开单页并默认选中当前技师', (t) async {
    Access.apply({
      'role': 'technician',
      'staff_id': 'st1',
      'resource_id': 't2',
      'store_id': 's1',
      'caps': {
        'cashier': true,
        'order_submit': true,
        'member_lookup': true,
        'member_view': false,
        'member_edit': false,
      },
    });
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: const StMemberInfoLivePage(memberId: 'm1'),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('为他开单'));
    await t.pumpAndSettle();
    expect(find.byType(OrderPage), findsOneWidget);
    expect(find.text('王建国'), findsOneWidget);
    expect(selected(t, '无技能技师'), isTrue);
    expect(selected(t, '真实技师 · 精洗'), isFalse);
  });
}
