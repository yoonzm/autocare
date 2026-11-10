import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/task_flow.dart';
import 'package:autocare_merchant/pages/staff_tabs.dart';
import 'package:autocare_merchant/routes.dart' show navTracker, openRoute;

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

/// 员工工作流（任务 / 进度 / 完工 / 业绩 / 消息 / 今日到店）的假后端。
class WorkApi extends BookingApi {
  Map<String, Map<String, dynamic>> tasks = {
    'w1': task('w1', status: 'waiting', plate: '沪B5X770', item: '内饰深度清洁', hour: 6, stage: 0),
    'a1': task('a1', status: 'arrived', plate: '沪A8K29M', item: '全车镀晶 · 9H 陶瓷', hour: 2, stage: 1),
    'd1': task('d1', status: 'arrived', plate: '沪C7Q221', item: '精致洗车', hour: 1, stage: 4, finished: true),
  };
  List<Map<String, dynamic>> messages = [
    {'id': 'm1', 'kind': 'task', 'title': '新任务派给你', 'body': '沪B5X770 内饰深度清洁', 'link': 'StTaskDetail:w1', 'created_at': '2026-11-01T06:00:00Z', 'read_at': null},
    {'id': 'm2', 'kind': 'arrival', 'title': '车主已到店', 'body': '王建国的沪A8K29M 已到店', 'link': 'StTaskDetail:a1', 'created_at': '2026-11-01T05:00:00Z', 'read_at': null},
    {'id': 'm3', 'kind': 'system', 'title': '提成已更新', 'body': '订单已结算，+¥100 计入本月提成。', 'link': 'StPerf', 'created_at': '2026-11-01T04:00:00Z', 'read_at': '2026-11-01T04:30:00Z'},
  ];
  Object? workError;

  static Map<String, dynamic> task(String id, {required String status, required String plate, required String item, required int hour, required int stage, bool finished = false}) => {
    'id': id,
    'plate': plate,
    'status': status,
    'starts_at': '2026-11-10T0$hour:00:00Z',
    'duration_minutes': 120,
    'customer': '王建国',
    'note': '',
    'items': [
      {'name': item}
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
  Future<Map<String, dynamic>> staffWork(String action, [Map<String, dynamic> values = const {}]) async {
    calls.add({'action': action, ...values});
    if (workError != null && (action == 'staff_task_progress' || action == 'staff_task_finish')) throw workError!;
    switch (action) {
      case 'staff_task_list':
        return {'items': tasks.values.toList()};
      case 'staff_task_detail':
        return {...tasks[values['id']]!};
      case 'staff_task_progress':
        final stage = values['stage'] as int;
        tasks[values['id']] = {...tasks[values['id']]!, 'stage': stage, 'progress': stage * 25 + 12};
        return {...tasks[values['id']]!};
      case 'staff_task_finish':
        tasks[values['id']] = {...tasks[values['id']]!, 'stage': 4, 'progress': 100, 'finished_at': '2026-11-10T08:48:00Z'};
        return {...tasks[values['id']]!, 'today_commission': 544};
      case 'staff_perf':
        return {
          'month': '2026-11',
          'month_commission': 4620,
          'month_orders': 62,
          'month_revenue': 38600,
          'days': [
            for (var i = 0; i < 7; i++) {'day': '2026-11-0${i + 4}', 'amount': i == 6 ? 100 : 0}
          ],
          'rows': [
            {'service': '镀晶', 'plate': '沪A8K29M', 'at': '2026-10-31T08:00:00Z', 'amount': 158},
          ],
        };
      case 'staff_arrivals':
        return {
          'items': [
            {'id': 'a1', 'plate': '沪A8K29M', 'status': 'arrived', 'starts_at': '2026-11-10T02:30:00Z', 'customer': '王建国', 'items': [{'name': '全车镀晶'}], 'level': '黑金会员'},
            {'id': 'w1', 'plate': '沪B5X770', 'status': 'waiting', 'starts_at': '2026-11-10T06:00:00Z', 'customer': '赵磊', 'items': [{'name': '内饰深度清洁'}], 'level': '银卡'},
          ],
        };
      case 'staff_messages':
        return {'items': messages, 'unread': messages.where((m) => m['read_at'] == null).length};
      case 'staff_messages_read':
        messages = [
          for (final m in messages) if (values['id'] == null || m['id'] == values['id']) {...m, 'read_at': '2026-11-10T00:00:00Z'} else m
        ];
        return {'unread': messages.where((m) => m['read_at'] == null).length};
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
    TaskFlow.currentId = null;
    TaskFlow.finished = null;
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });

  Finder text(String s) => find.text(s);
  List<Map<String, dynamic>> calls(String action) => api.calls.where((c) => c['action'] == action).toList();

  Future<void> start(WidgetTester t, String route) async {
    phone(t);
    if (route == 'StTasks') {
      // 任务是技师外壳的底部 Tab：从外壳切换过去
      await t.pumpWidget(const MaterialApp(home: StaffTabs()));
      await t.pumpAndSettle();
      openRoute(t.element(find.byType(StaffTabs)), route);
      await t.pumpAndSettle();
      return;
    }
    late BuildContext ctx;
    await t.pumpWidget(MaterialApp(
      navigatorObservers: [navTracker],
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold();
      }),
    ));
    openRoute(ctx, route);
    await t.pumpAndSettle();
  }

  testWidgets('我的任务：三个分组的数量与卡片都来自服务端，切换分组只显示对应任务', (t) async {
    await start(t, 'StTasks');
    expect(text('待施工 1'), findsWidgets);
    expect(text('施工中 1'), findsWidgets);
    expect(text('已完成 1'), findsWidgets);
    // 有施工中的任务时默认停在「施工中」
    expect(text('沪A8K29M'), findsOneWidget);
    expect(text('37%'), findsOneWidget);
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

  testWidgets('任务详情：节点按进度显示，施工中才有更新进度 / 提交完工', (t) async {
    TaskFlow.currentId = 'a1';
    await start(t, 'StTaskDetail');
    expect(calls('staff_task_detail').single['id'], 'a1');
    expect(text('施工中'), findsOneWidget);
    expect(text('3 号工位'), findsOneWidget);
    expect(text('全车镀晶 · 9H 陶瓷'), findsOneWidget);
    expect(text('全车镀晶 · 9H 陶瓷 施工'), findsOneWidget);
    expect(text('清洗 · 打磨'), findsOneWidget);
    expect(text('进行中'), findsOneWidget);
    expect(text('37%'), findsOneWidget);
    expect(text('更新进度'), findsOneWidget);
    expect(text('提交完工'), findsOneWidget);
    expect(text('施工照片 · 0 张'), findsOneWidget);
    expect(find.textContaining('宝马'), findsNothing, reason: '车型没有数据来源，不显示示例车型');
  });

  testWidgets('待开工的任务只能查看，不显示更新进度 / 提交完工', (t) async {
    TaskFlow.currentId = 'w1';
    await start(t, 'StTaskDetail');
    expect(text('待开工'), findsOneWidget);
    expect(text('更新进度'), findsNothing);
    expect(text('提交完工'), findsNothing);
  });

  testWidgets('更新进度：选择阶段后保存，向服务端提交已完成的节点数', (t) async {
    TaskFlow.currentId = 'a1';
    await start(t, 'StTaskDetail');
    await t.tap(text('更新进度'));
    await t.pumpAndSettle();
    expect(text('取消'), findsOneWidget);
    await t.tap(find.text('固化 · 质检').last);
    await t.pumpAndSettle();
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    final c = calls('staff_task_progress').single;
    expect(c['id'], 'a1');
    expect(c['stage'], 3);
    expect(text('保存'), findsNothing, reason: '保存后关闭弹层');
    expect(text('87%'), findsOneWidget, reason: '详情页刷新为新进度');
  });

  testWidgets('更新进度失败：保持弹层并提示服务端的原因', (t) async {
    TaskFlow.currentId = 'a1';
    api.workError = const AppError('施工进度不能倒退');
    await start(t, 'StTaskDetail');
    await t.tap(text('更新进度'));
    await t.pumpAndSettle();
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    expect(find.textContaining('不能倒退'), findsOneWidget);
    expect(text('保存'), findsOneWidget);
  });

  testWidgets('完工提交：确认后调用服务端，进入完工结果页显示预计提成', (t) async {
    TaskFlow.currentId = 'a1';
    await start(t, 'StFinish');
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
    TaskFlow.currentId = 'a1';
    api.workError = const AppError('该任务已提交完工');
    await start(t, 'StFinish');
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
    Access.apply({...api.identityCtx, 'role': 'cashier', 'caps': {'arrivals_today': true}});
    await start(t, 'StArrivals');
    expect(text('2 位车主'), findsOneWidget);
    expect(text('已到店 1'), findsOneWidget);
    expect(text('待到店 1'), findsOneWidget);
    expect(text('客户 王建国 · 黑金会员'), findsOneWidget);
    expect(text('客户 赵磊 · 银卡'), findsOneWidget);
    expect(text('沪A8K29M'), findsOneWidget);
  });

  testWidgets('消息：按类型筛选，点开跳转并标记已读，全部已读', (t) async {
    await start(t, 'StMsgs');
    expect(text('新任务派给你'), findsOneWidget);
    expect(text('车主已到店'), findsOneWidget);
    expect(text('提成已更新'), findsOneWidget);
    await t.tap(text('到店').first);
    await t.pumpAndSettle();
    expect(text('新任务派给你'), findsNothing);
    expect(text('车主已到店'), findsOneWidget);
    await t.tap(text('全部').first);
    await t.pumpAndSettle();
    await t.tap(text('新任务派给你'));
    await t.pumpAndSettle();
    expect(calls('staff_messages_read').single['id'], 'm1');
    expect(TaskFlow.currentId, 'w1');
    expect(text('任务详情'), findsOneWidget);
  });

  testWidgets('消息：全部已读调用服务端，没有消息时显示空态', (t) async {
    await start(t, 'StMsgs');
    await t.tap(text('全部已读'));
    await t.pumpAndSettle();
    await t.pump(const Duration(seconds: 1));
    final c = calls('staff_messages_read').single;
    expect(c.containsKey('id'), isFalse);
    api.messages = [];
    TaskFlow.notify();
    await t.pumpAndSettle();
    expect(text('暂无消息'), findsOneWidget);
  });
}
