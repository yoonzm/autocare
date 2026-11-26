import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/staff_app/st_front_home_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_home_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_tasks_template.dart';

void main() {
  testWidgets('技师首页空任务展示空状态并支持下拉刷新', (tester) async {
    var refreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StHomeTemplate(
          d: const {
            'name': '张师傅',
            'revenue_today': 0,
            'done_today': 0,
            'commission_today': 0,
            'waiting': 0,
            'tasks': <Map<String, dynamic>>[],
          },
          onRefresh: () async {
            refreshed++;
          },
        ),
      ),
    );

    expect(find.text('我的任务'), findsOneWidget);
    expect(find.text('暂无待办任务'), findsOneWidget);
    expect(find.text('新派工的任务会显示在这里'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(refreshed, 1);
  });

  testWidgets('前台首页支持下拉刷新', (tester) async {
    var refreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StFrontHomeTemplate(
          d: const {
            'name': '李前台',
            'orders_today': 0,
            'waiting': 0,
            'working': 0,
            'upcoming': <Map<String, dynamic>>[],
            'queue': <Map<String, dynamic>>[],
          },
          onRefresh: () async {
            refreshed++;
          },
        ),
      ),
    );

    expect(find.byType(RefreshIndicator), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(refreshed, 1);
  });

  testWidgets('我的任务页无任务时默认待施工并展示空状态，支持下拉刷新', (tester) async {
    var refreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StTasksTemplate(
          d: const {'items': <Map<String, dynamic>>[]},
          onRefresh: () async {
            refreshed++;
          },
        ),
      ),
    );

    expect(find.text('暂无待施工任务'), findsOneWidget);
    expect(find.byType(RefreshIndicator), findsOneWidget);

    await tester.tap(find.text('施工中 0'));
    await tester.pumpAndSettle();
    expect(find.text('暂无施工中任务'), findsOneWidget);

    await tester.tap(find.text('已完成 0'));
    await tester.pumpAndSettle();
    expect(find.text('今日暂无已完成任务'), findsOneWidget);

    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await tester.pumpAndSettle();
    expect(refreshed, 1);
  });
}
