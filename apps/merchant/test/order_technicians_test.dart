import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/order_page.dart';

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
}

void main() {
  late MerchantApi original;
  late TechnicianApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = TechnicianApi();
    ServiceStore.clear();
    HoldFlow.reset();
    MemberFlow.current = row();
  });
  tearDown(() {
    merchantApi = original;
    MemberFlow.current = null;
    ServiceStore.clear();
    HoldFlow.reset();
  });
  Future<void> open(
    WidgetTester t, {
    Map<String, dynamic>? appointment,
    bool settle = true,
  }) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        home: OrderPage(member: memberFromRow(row()), appointment: appointment),
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
}
