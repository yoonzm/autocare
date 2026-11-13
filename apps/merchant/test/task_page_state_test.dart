import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/staff_app/st_done_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_finish_template.dart';
import 'package:autocare_merchant/pages/staff_app/task_route_data.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show phone;
import 'staff_work_test.dart' show WorkApi;

class GatedWorkApi extends WorkApi {
  Completer<void>? finishGate;
  final finishing = <String>[];

  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'staff_task_finish') {
      finishing.add(values['id'] as String);
      await finishGate?.future;
    }
    return super.staffWork(action, values);
  }
}

void main() {
  late MerchantApi original;
  late GatedWorkApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = GatedWorkApi();
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

  testWidgets('不同任务详情独立入栈，返回旧任务后进度弹层仍请求旧任务', (t) async {
    phone(t);
    late BuildContext root;
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (context) {
            root = context;
            return const Scaffold();
          },
        ),
      ),
    );
    openRoute(
      root,
      'StTaskDetail',
      arguments: const TaskRouteData(taskId: 'a1'),
    );
    await t.pumpAndSettle();
    openRoute(
      root,
      'StTaskDetail',
      arguments: const TaskRouteData(taskId: 'w1'),
    );
    await t.pumpAndSettle();
    expect(find.text('沪B5X770'), findsOneWidget);
    openRoute(
      root,
      'StTaskDetail',
      arguments: const TaskRouteData(taskId: 'a1'),
    );
    await t.pumpAndSettle();
    expect(find.text('沪A8K29M'), findsOneWidget);
    await t.tap(find.text('更新进度'));
    await t.pumpAndSettle();
    expect(
      api.calls.lastWhere((c) => c['action'] == 'staff_task_detail')['id'],
      'a1',
    );
  });

  testWidgets('完工页防止重复提交，结果直接使用本次真实回执', (t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: const StFinishLivePage(taskId: 'a1'),
      ),
    );
    await t.pumpAndSettle();
    final gate = api.finishGate = Completer<void>();
    final submit = t.getCenter(find.text('确认完工'));
    await t.tapAt(submit);
    await t.pump();
    expect(api.finishing, ['a1']);
    // 忙碌期间的再次点击不能产生第二次提交。
    await t.tapAt(submit);
    await t.pump();
    expect(api.finishing, ['a1']);
    gate.complete();
    await t.pumpAndSettle();
    expect(find.text('已提交完工'), findsOneWidget);
    expect(find.text('¥544'), findsOneWidget);
    expect(find.text('沪A8K29M'), findsOneWidget);
    await t.pumpWidget(const MaterialApp(key: ValueKey('direct-result'), home: StDoneLivePage()));
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('沪A8K29M'), findsNothing);
    expect(find.text('¥544'), findsNothing);
  });

  testWidgets('完工回执按结果页实例持有，重建不会读取其他任务结果', (t) async {
    phone(t);
    final first = {...api.tasks['a1']!, 'today_commission': 544};
    final second = {...api.tasks['w1']!, 'today_commission': 900};
    await t.pumpWidget(MaterialApp(home: StDoneLivePage(result: first)));
    await t.pumpAndSettle();
    expect(find.text('沪A8K29M'), findsOneWidget);
    await t.pumpWidget(MaterialApp(home: StDoneLivePage(result: second)));
    await t.pumpAndSettle();
    expect(find.text('沪B5X770'), findsOneWidget);
    expect(find.text('¥900'), findsOneWidget);
    await t.pumpWidget(MaterialApp(home: StDoneLivePage(result: first)));
    await t.pumpAndSettle();
    expect(find.text('沪A8K29M'), findsOneWidget);
    expect(find.text('¥544'), findsOneWidget);
  });
}
