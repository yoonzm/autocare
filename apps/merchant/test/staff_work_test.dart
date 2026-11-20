import 'dart:async';

import 'package:autocare_merchant/pages/staff_app/task_route_data.dart';
import 'package:autocare_merchant/pages/staff_app/staff_tabs.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/routes.dart' show navTracker, openRoute;

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

/// 员工工作流（任务 / 进度 / 完工 / 业绩 / 今日到店）的假后端。
class WorkApi extends BookingApi {
  bool clearOnSignOut = false;
  Future<void>? signOutGate;
  @override
  Future<void> signOut() async {
    calls.add({'action': 'sign_out'});
    if (clearOnSignOut) {
      StoreContext.bind(null);
      storeProfile.clear();
    }
    await signOutGate;
  }

  Map<String, Map<String, dynamic>> tasks = {
    'w1': task(
      'w1',
      status: 'waiting',
      plate: '沪B5X770',
      item: '内饰深度清洁',
      hour: 6,
      stage: 0,
    ),
    'a1': task(
      'a1',
      status: 'arrived',
      plate: '沪A8K29M',
      item: '全车镀晶 · 9H 陶瓷',
      hour: 2,
      stage: 1,
    ),
    'd1': task(
      'd1',
      status: 'arrived',
      plate: '沪C7Q221',
      item: '精致洗车',
      hour: 1,
      stage: 4,
      finished: true,
    ),
  };
  Object? workError;

  static Map<String, dynamic> task(
    String id, {
    required String status,
    required String plate,
    required String item,
    required int hour,
    required int stage,
    bool finished = false,
  }) => {
    'id': id,
    'plate': plate,
    'status': status,
    'starts_at': '2026-11-10T0$hour:00:00Z',
    'duration_minutes': 120,
    'customer': '王建国',
    'note': '',
    'items': [
      {'name': item},
    ],
    'level': '黑金会员',
    'bay_name': status == 'arrived' ? '3 号工位' : null,
    'stage': stage,
    'progress': stage == 0 ? 0 : (stage >= 4 ? 100 : stage * 25 + 12),
    'finished_at': finished ? '2026-11-10T03:00:00Z' : null,
    'arrived_at': status == 'arrived' ? '2026-11-10T02:42:00Z' : null,
    'est_commission': 100,
  };

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    String? requestId,
  }) async {
    if (body['action'] == 'store_media_list' ||
        body['action'] == 'staff_task_photo_list') {
      calls.add(body);
      return {'items': []};
    }
    return super.invoke(body, timeout: timeout, requestId: requestId);
  }

  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add({'action': action, ...values});
    if (workError != null &&
        (action == 'staff_task_progress' || action == 'staff_task_finish')) {
      throw workError!;
    }
    switch (action) {
      case 'staff_task_list':
        return {'items': tasks.values.toList()};
      case 'staff_task_photo_list':
        return {'items': []};
      case 'staff_task_detail':
        return {...tasks[values['id']]!};
      case 'staff_task_progress':
        final stage = values['stage'] as int;
        tasks[values['id']] = {
          ...tasks[values['id']]!,
          'status': 'arrived',
          'stage': stage,
        };
        return {...tasks[values['id']]!};
      case 'staff_task_finish':
        tasks[values['id']] = {
          ...tasks[values['id']]!,
          'stage': 4,
          'progress': 100,
          'finished_at': '2026-11-10T08:48:00Z',
        };
        return {...tasks[values['id']]!, 'today_commission': 544};
      case 'staff_perf':
        return {
          'month': '2026-11',
          'month_commission': 4620,
          'month_orders': 62,
          'month_revenue': 38600,
          'days': [
            for (var i = 0; i < 7; i++)
              {'day': '2026-11-0${i + 4}', 'amount': i == 6 ? 100 : 0},
          ],
          'rows': [
            {
              'service': '镀晶',
              'plate': '沪A8K29M',
              'at': '2026-10-31T08:00:00Z',
              'amount': 158,
            },
          ],
        };
      case 'staff_arrivals':
        return {
          'items': [
            {
              'id': 'a1',
              'plate': '沪A8K29M',
              'status': 'arrived',
              'starts_at': '2026-11-10T02:30:00Z',
              'customer': '王建国',
              'items': [
                {'name': '全车镀晶'},
              ],
              'level': '黑金会员',
            },
            {
              'id': 'w1',
              'plate': '沪B5X770',
              'status': 'waiting',
              'starts_at': '2026-11-10T06:00:00Z',
              'customer': '赵磊',
              'items': [
                {'name': '内饰深度清洁'},
              ],
              'level': '银卡',
            },
          ],
        };
    }
    throw UnsupportedError(action);
  }
}

void main() {
  late MerchantApi original;
  late WorkApi api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = merchantApi;
    merchantApi = api = WorkApi();
    navTracker.stack.clear();
    Access.apply({...api.identityCtx});
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });

  Finder text(String s) => find.text(s);
  List<Map<String, dynamic>> calls(String action) =>
      api.calls.where((c) => c['action'] == action).toList();

  Future<void> start(WidgetTester t, String route, {String? taskId}) async {
    phone(t);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (c) {
            ctx = c;
            return const Scaffold();
          },
        ),
      ),
    );
    openRoute(
      ctx,
      route,
      arguments: taskId == null ? null : TaskRouteData(taskId: taskId),
    );
    await t.pumpAndSettle();
  }

  testWidgets('技师在我的页面进入真实任务列表，前台不显示任务入口', (t) async {
    await start(t, 'StMine');
    expect(text('联系店长'), findsNothing);
    expect(text('共 3 个任务'), findsOneWidget);
    await t.ensureVisible(text('我的任务'));
    await t.tap(text('我的任务'));
    await t.pumpAndSettle();
    expect(calls('staff_task_list'), hasLength(2));
    expect(text('施工中 1'), findsWidgets);

    Access.apply({...api.identityCtx, 'role': 'cashier', 'caps': const {}});
    await start(t, 'StMine');
    expect(text('联系店长'), findsNothing);
    expect(text('我的任务'), findsNothing);
    expect(calls('staff_task_list'), hasLength(2));
  });

  testWidgets('店员退出登录沿用老板端的圆角按钮样式并退出会话', (t) async {
    await start(t, 'StMine');
    final label = text('退出登录');
    await t.ensureVisible(label);
    final button = t.widget<Container>(
      find.ancestor(of: label, matching: find.byType(Container)).first,
    );
    expect(button.constraints?.maxHeight, 50);
    final decoration = button.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(25));
    expect(t.widget<Text>(label).style?.fontWeight, FontWeight.w600);
    await t.tap(label);
    await t.pumpAndSettle();
    expect(calls('sign_out'), hasLength(1));
    expect(Access.role, 'owner');
  });

  testWidgets('退出时旧店员工作台不因身份清理重新发请求', (t) async {
    final gate = Completer<void>();
    addTearDown(() {
      if (!gate.isCompleted) gate.complete();
    });
    api.clearOnSignOut = true;
    api.signOutGate = gate.future;
    phone(t);
    await t.pumpWidget(
      MaterialApp(navigatorObservers: [navTracker], home: const StaffTabs()),
    );
    await t.pumpAndSettle();
    final ctx = t.element(find.byType(StaffTabs));
    openRoute(ctx, 'StMine');
    await t.pumpAndSettle();
    final before = calls('staff_home').length;
    await t.ensureVisible(text('退出登录'));
    await t.tap(text('退出登录'));
    await t.pump();
    await t.pump();
    expect(calls('staff_home'), hasLength(before));
    gate.complete();
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    expect(navTracker.stack, hasLength(1));
  });

  testWidgets('我的任务：三个分组的数量与卡片都来自服务端，切换分组只显示对应任务', (t) async {
    await start(t, 'StTasks');
    expect(text('待施工 1'), findsWidgets);
    expect(text('施工中 1'), findsWidgets);
    expect(text('已完成 1'), findsWidgets);
    // 有施工中的任务时默认停在「施工中」
    expect(text('沪A8K29M'), findsOneWidget);
    expect(text('沪B5X770'), findsNothing);
    await t.tap(text('待施工 1').first);
    await t.pumpAndSettle();
    expect(text('沪B5X770'), findsOneWidget);
    expect(text('内饰深度清洁'), findsOneWidget);
    expect(text('待开工'), findsOneWidget);
    await t.tap(text('已完成 1').first);
    await t.pumpAndSettle();
    expect(text('沪C7Q221'), findsOneWidget);
    expect(text('已完成'), findsWidgets);
  });

  testWidgets('任务详情：极简三态展示，施工中显示提交完工且无细分工序节点', (t) async {
    await start(t, 'StTaskDetail', taskId: 'a1');
    expect(calls('staff_task_detail').single['id'], 'a1');
    expect(text('施工中'), findsOneWidget);
    expect(text('3 号工位'), findsOneWidget);
    expect(text('全车镀晶 · 9H 陶瓷'), findsOneWidget);
    expect(text('施工节点'), findsNothing);
    expect(text('更新进度'), findsNothing);
    expect(text('提交完工'), findsOneWidget);
    expect(text('施工照片'), findsOneWidget);
    expect(calls('staff_task_photo_list').single['target_id'], 'a1');
    expect(find.textContaining('宝马'), findsNothing, reason: '车型没有数据来源，不显示示例车型');
  });

  testWidgets('待施工挂单任务：点击「开始施工」转为施工中并切换为「提交完工」；已完成任务无底部按钮', (t) async {
    await start(t, 'StTaskDetail', taskId: 'w1');
    expect(text('待开工'), findsOneWidget);
    expect(text('开始施工'), findsOneWidget);
    expect(text('提交完工'), findsNothing);
    await t.tap(text('开始施工'));
    await t.pumpAndSettle();
    final c = calls('staff_task_progress').single;
    expect(c['id'], 'w1');
    expect(c['stage'], 1);
    expect(text('施工中'), findsOneWidget);
    expect(text('提交完工'), findsOneWidget);

    await start(t, 'StTaskDetail', taskId: 'd1');
    expect(text('已完成'), findsOneWidget);
    expect(text('开始施工'), findsNothing);
    expect(text('提交完工'), findsNothing);
  });

  testWidgets('开始施工失败：保持待开工状态并提示服务端的原因', (t) async {
    api.workError = const AppError('该任务已提交完工');
    await start(t, 'StTaskDetail', taskId: 'w1');
    await t.tap(text('开始施工'));
    await t.pumpAndSettle();
    expect(find.textContaining('已提交完工'), findsOneWidget);
    expect(text('待开工'), findsOneWidget);
    expect(text('开始施工'), findsOneWidget);
  });

  testWidgets('完工提交：确认后调用服务端，进入完工结果页显示预计提成', (t) async {
    await start(t, 'StFinish', taskId: 'a1');
    expect(text('完工提交'), findsOneWidget);
    expect(text('¥100'), findsOneWidget);
    expect(find.textContaining('6 张'), findsNothing, reason: '完工照片未接通，不展示示例数量');
    expect(text('耗材'), findsNothing);
    await t.tap(text('确认完工'));
    await t.pumpAndSettle();
    expect(calls('staff_task_finish').single['id'], 'a1');
    expect(text('已提交完工'), findsOneWidget);
    expect(text('+¥100'), findsOneWidget);
    expect(text('¥544'), findsOneWidget);
    expect(text('待收银'), findsOneWidget);
  });

  testWidgets('完工提交失败：不进入结果页，提示原因', (t) async {
    api.workError = const AppError('该任务已提交完工');
    await start(t, 'StFinish', taskId: 'a1');
    await t.tap(text('确认完工'));
    await t.pumpAndSettle();
    expect(find.textContaining('已提交完工'), findsOneWidget);
    expect(text('完工提交'), findsOneWidget);
    expect(text('+¥100'), findsNothing);
  });

  testWidgets('业绩提成：本月数据、近 7 天与明细来自服务端', (t) async {
    await start(t, 'StPerf');
    expect(text('2026 年 11 月'), findsOneWidget);
    expect(text('¥4,620'), findsOneWidget);
    expect(text('62'), findsOneWidget);
    expect(text('¥38.6k'), findsOneWidget);
    expect(text('12%'), findsOneWidget);
    expect(text('今天'), findsOneWidget);
    expect(text('镀晶 · 沪A8K29M'), findsOneWidget);
    expect(text('10月31日'), findsOneWidget);
    expect(text('¥158'), findsOneWidget);
  });

  testWidgets('今日到店：统计与每位车主的状态', (t) async {
    Access.apply({
      ...api.identityCtx,
      'role': 'cashier',
      'caps': {'arrivals_today': true},
    });
    await start(t, 'StArrivals');
    expect(text('2 位车主'), findsOneWidget);
    expect(text('已到店 1'), findsOneWidget);
    expect(text('待到店 1'), findsOneWidget);
    expect(text('客户 王建国 · 黑金会员'), findsOneWidget);
    expect(text('客户 赵磊 · 银卡'), findsOneWidget);
    expect(text('沪A8K29M'), findsOneWidget);
  });

  testWidgets('我的页面今日到店数量与真实预约列表一致', (t) async {
    Access.apply({
      ...api.identityCtx,
      'role': 'cashier',
      'caps': {'arrivals_today': true},
    });
    api.home['waiting'] = 5;
    api.home['working'] = 7;
    await start(t, 'StMine');
    expect(text('2 位'), findsOneWidget);
    expect(calls('staff_arrivals'), hasLength(1));
    await t.tap(text('今日到店'));
    await t.pumpAndSettle();
    expect(text('2 位车主'), findsOneWidget);
    expect(calls('staff_arrivals'), hasLength(2));

    Access.apply({...api.identityCtx, 'role': 'cashier', 'caps': const {}});
    await start(t, 'StMine');
    expect(text('今日到店'), findsNothing);
    expect(calls('staff_arrivals'), hasLength(2));
  });
}
