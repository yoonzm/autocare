import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/appointment_add_page.dart';
import 'package:autocare_merchant/pages/appointment_detail_live_page.dart';
import 'package:autocare_merchant/pages/appointment_settings_live_page.dart';
import 'package:autocare_merchant/pages/appointment_settings_skeleton.dart';
import 'package:autocare_merchant/pages/booking_resources_page.dart';
import 'package:autocare_merchant/pages/gen/member_picker_sheet.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;
import 'package:autocare_merchant/widgets/booking_template_bindings.dart';

import 'members_test.dart' show MemberFakeApi, phone, row;

Map<String, dynamic> bookingRow({
  String id = 'a1',
  String status = 'waiting',
  String name = '真实客户',
}) => {
  'id': id,
  'member_id': null,
  'customer_name': name,
  'phone': '13912345678',
  'vehicle_plate': '苏A12345',
  'starts_at': '${bookingDay(bookingToday)}T17:30:00+08:00',
  'duration_minutes': 30,
  'estimate': 68,
  'status': status,
  'level': '散客',
  'note': '后门有划痕',
  'service_ids': ['s1'],
  'items': [
    {'service_id': 's1', 'name': '真实洗车', 'price': 68, 'minutes': 30},
  ],
  'bay_id': 'b1',
  'technician_id': 't1',
  'bay_name': '真实工位',
  'technician_name': '真实技师',
};

class BookingApi extends MemberFakeApi {
  final bookings = <Map<String, dynamic>>[];
  final calls = <Map<String, dynamic>>[];
  final resources = <Map<String, dynamic>>[
    {
      'id': 'b1',
      'kind': 'bay',
      'name': '真实工位',
      'category': '洗车',
      'phone': '',
      'active': true,
      'position': 0,
      'linked_id': null,
    },
    {
      'id': 't1',
      'kind': 'technician',
      'name': '真实技师',
      'category': '洗车',
      'phone': '13912345678',
      'active': true,
      'position': 0,
      'linked_id': null,
      'joined_on': '2026-01-01',
      'month_orders': 2,
    },
  ];
  Map<String, dynamic> settings = {
    'opens_at': '09:00',
    'closes_at': '20:00',
    'slot_minutes': 30,
    'capacity': 2,
    'lead_hours': 0,
    'advance_days': 30,
    'grace_minutes': 15,
    'closed_days': <int>[],
  };
  Completer<void>? gate;
  Completer<void>? optionsGate;
  Object? readError, writeError;
  BookingApi() {
    services.add({
      'id': 's1',
      'name': '真实洗车',
      'category': '洗车',
      'price': 68.0,
      'duration_minutes': 30,
      'active': true,
    });
  }
  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add({'action': action, ...values});
    if (action == 'options') {
      await optionsGate?.future;
      return {
        'settings': {...settings},
        'resources': [
          for (final r in resources) {...r},
        ],
        'services': services,
      };
    }
    if (action == 'board') {
      if (readError != null) throw readError!;
      return {
        'items': [
          for (final a in bookings)
            if (a['status'] != 'cancelled') {...a},
        ],
      };
    }
    if (action == 'summary') {
      return {
        'count': bookings
            .where((a) => ['waiting', 'late'].contains(a['status']))
            .length,
        'next': bookings.firstOrNull,
      };
    }
    if (action == 'get') {
      return {...bookings.firstWhere((a) => a['id'] == values['id'])};
    }
    if (action == 'slots') {
      return {
        'duration_minutes': 30,
        'slots': [
          {'time': '17:30', 'available': true},
          {'time': '18:00', 'available': false},
        ],
      };
    }
    await gate?.future;
    if (writeError != null) throw writeError!;
    if (action == 'save') {
      final row = values['id'] == null
          ? bookingRow(id: 'saved', name: '散客')
          : bookings.firstWhere((a) => a['id'] == values['id']);
      row.addAll(values);
      if (values['id'] == null) {
        row['id'] = 'saved';
        bookings.add(row);
      }
      return {...row};
    }
    if (action == 'arrive' || action == 'cancel') {
      final row = bookings.firstWhere((a) => a['id'] == values['id']);
      row['status'] = action == 'arrive' ? 'arrived' : 'cancelled';
      return {...row};
    }
    if (action == 'resource_save') {
      final row = {...values, 'id': values['id'] ?? 'new-resource'};
      resources.add(row);
      return row;
    }
    if (action == 'settings_save') {
      settings = {...values};
      return settings;
    }
    if (action == 'checkout') {
      bookings.firstWhere((a) => a['id'] == values['id'])['status'] = 'done';
      return {
        'order_id': 'order1',
        'payable': 68,
        'subtotal': 68,
        'card_off': 0,
        'discount_off': 0,
        'balance_paid': 0,
        'items': '真实洗车',
        'pay_method': values['method'],
        'points_gained': 0,
      };
    }
    throw UnsupportedError(action);
  }
}

void main() {
  late MerchantApi original;
  late BookingApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = BookingApi();
    HoldFlow.reset();
    ServiceStore.clear();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    HoldFlow.reset();
    ServiceStore.clear();
    navTracker.stack.clear();
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

  testWidgets('预约列表和工位时间表都来自同一真实记录，不出现示例客户', (t) async {
    api.bookings.add(bookingRow());
    await open(t, const AppointmentsPage());
    expect(find.text('真实客户'), findsOneWidget);
    expect(find.text('真实洗车'), findsOneWidget);
    expect(find.text('刘先生'), findsNothing);
    expect(find.text('4 号工位 · 老周'), findsNothing);
    await t.tap(find.text('工位时间表'));
    await t.pumpAndSettle();
    expect(find.text('真实工位'), findsOneWidget);
    expect(find.textContaining('真实客户'), findsOneWidget);
    expect(find.text('沪B·3D82'), findsNothing); // 旧设计稿的静态假预约不能混进真实时间表
    expect(find.text('赵女士'), findsNothing);
  });

  testWidgets('预约列表时间保持单行，无车牌时不出现空蓝框', (t) async {
    api.bookings.add({
      ...bookingRow(),
      'starts_at': '${bookingDay(bookingToday)}T09:00:00+08:00',
      'vehicle_plate': '',
    });
    await open(t, const AppointmentsPage());
    final time = t.widget<Text>(find.text('09:00'));
    expect(time.maxLines, 1);
    expect(t.getSize(find.text('09:00')).height, lessThanOrEqualTo(24));
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == const Color(0xFF0B5FD6),
      ),
      findsNothing,
    );
  });
  testWidgets('预约读取失败可重试，成功为空显示引导新建', (t) async {
    api.readError = const AppError('网络错误', type: AppErrorType.network);
    await open(t, const AppointmentsPage());
    expect(find.text('重试'), findsOneWidget);
    api.readError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('当天还没有预约'), findsOneWidget);
    expect(find.text('新建预约'), findsOneWidget);
  });
  testWidgets('新建预约立即显示客户与缓存服务，只在时段区等待预约选项', (t) async {
    phone(t);
    await ServiceStore.refresh();
    api.optionsGate = Completer<void>();
    await t.pumpWidget(const MaterialApp(home: AppointmentAddPage()));
    expect(find.text('客户'), findsOneWidget);
    expect(find.text('真实洗车 ¥68.0'), findsOneWidget);
    expect(find.byType(SkeletonFormFields), findsNothing);
    expect(find.byType(AppSkeleton), findsNothing);
    await t.pump(const Duration(milliseconds: 350));
    expect(find.text('客户'), findsOneWidget);
    expect(find.text('真实洗车 ¥68.0'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsOneWidget);
    api.optionsGate!.complete();
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    expect(find.byType(AppSkeleton), findsNothing);
  });
  testWidgets('新建预约选择客户复用结账和充值的会员选择弹层', (t) async {
    api.rows.add(row());
    MemberFlow.current = null;
    await open(t, const AppointmentAddPage());
    await t.tap(find.text('请选择会员'));
    await t.pumpAndSettle();
    expect(find.byType(MemberPickerSheet), findsOneWidget);
    await t.tap(find.text('王建国').last);
    await t.pumpAndSettle();
    expect(find.byType(MemberPickerSheet), findsNothing);
    expect(find.text('王建国'), findsWidgets);
  });
  testWidgets('到店按钮等待后端响应，不提前修改状态，失败保留预约', (t) async {
    api.bookings.add(bookingRow());
    api.gate = Completer<void>();
    await open(t, const AppointmentsPage());
    await t.tap(find.text('客户到店'));
    await t.pump();
    expect(api.bookings.single['status'], 'waiting');
    expect(find.byType(AppSpinner), findsWidgets);
    expect(find.text('提交中…'), findsOneWidget);
    await t.tap(find.text('提交中…'));
    await t.pump();
    expect(api.calls.where((c) => c['action'] == 'arrive').length, 1);
    api.writeError = const AppError('该预约已变化');
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(api.bookings.single['status'], 'waiting');
    expect(find.text('真实客户'), findsOneWidget);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('散客新建预约只发送服务 ID、时间和备注，提交失败保留输入', (t) async {
    api.writeError = const AppError('时段已约满');
    await open(t, const AppointmentAddPage());
    await t.tap(find.text('散客'));
    await t.pumpAndSettle();
    await t.tap(find.text('真实洗车 ¥68.0'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('17:30'));
    await t.tap(find.text('17:30'));
    await t.pumpAndSettle();
    final note = find.byType(TextField).last;
    await t.ensureVisible(note);
    await t.enterText(note, '车身检查');
    await t.tap(find.text('确认预约'));
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'save');
    expect(call['service_ids'], ['s1']);
    expect(call['member_id'], isNull);
    expect(call['note'], '车身检查');
    expect(call.containsKey('estimate'), isFalse);
    expect(call.containsKey('duration_minutes'), isFalse);
    expect(find.text('车身检查'), findsOneWidget);
    expect(api.bookings, isEmpty);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('预约详情使用真实字段，通知不会伪装已送达', (t) async {
    api.bookings.add(bookingRow());
    await open(t, const AppointmentDetailLivePage(id: 'a1'));
    expect(find.text('真实客户'), findsOneWidget);
    expect(find.text('后门有划痕'), findsOneWidget);
    expect(find.text('已送达'), findsNothing);
    expect(find.text('刘先生'), findsNothing);
  });
  testWidgets('预约详情仅保留底部改期取消入口', (t) async {
    api.bookings.add(bookingRow());
    await open(t, const AppointmentDetailLivePage(id: 'a1'));
    final title = t.getCenter(find.text('预约详情'));
    await t.tapAt(
      Offset(
        t.view.physicalSize.width / t.view.devicePixelRatio - 42,
        title.dy,
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('确认改期'), findsNothing);
    await t.tap(find.text('改期 / 取消'));
    await t.pumpAndSettle();
    expect(find.text('确认改期'), findsOneWidget);
  });
  testWidgets('预约详情到店按钮加载时保持尺寸并防重复提交', (t) async {
    api.bookings.add(bookingRow());
    api.gate = Completer<void>();
    await open(t, const AppointmentDetailLivePage(id: 'a1'));
    final button = find
        .ancestor(of: find.text('客户到店 · 开单'), matching: find.byType(Expanded))
        .last;
    final size = t.getSize(button);
    await t.tap(find.text('客户到店 · 开单'));
    await t.pump();
    expect(t.getSize(button), size);
    expect(find.text('提交中…'), findsOneWidget);
    expect(find.byType(AppSpinner), findsWidgets);
    await t.tap(find.text('提交中…'));
    await t.pump();
    expect(api.calls.where((c) => c['action'] == 'arrive').length, 1);
    api.writeError = const AppError('该预约已变化');
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('客户到店 · 开单'), findsOneWidget);
  });
  testWidgets('新建工位保存真实名称，技师资料不会预填示例姓名', (t) async {
    await open(t, const BookingResourceEditor(kind: 'bay'));
    final input = find.byType(TextFormField).first;
    await t.enterText(input, '新工位');
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'resource_save');
    expect(call['name'], '新工位');
    expect(call['kind'], 'bay');
    await t.pumpWidget(const SizedBox());
    await open(t, const BookingResourceEditor(kind: 'technician'));
    expect(find.text('李国强'), findsNothing);
    expect(find.text('员工姓名'), findsOneWidget);
  });
  testWidgets('预约设置数字来自后端且保存时包含接待规则', (t) async {
    await open(t, const AppointmentSettingsLivePage());
    await t.ensureVisible(find.text('时间间隔'));
    await t.pumpAndSettle();
    final fifteen = t.getCenter(find.text('15 分钟'));
    final thirty = t.getCenter(find.text('30 分钟'));
    final sixty = t.getCenter(find.text('60 分钟'));
    expect(fifteen.dx, lessThan(thirty.dx));
    expect(thirty.dx, lessThan(sixty.dx));
    expect((fifteen.dy - thirty.dy).abs(), lessThan(2));
    expect((thirty.dy - sixty.dy).abs(), lessThan(2));
    expect(find.text('保存'), findsNothing);
    expect(find.text('保存设置'), findsOneWidget);
    final number = find.byWidgetPredicate(
      (w) => w is BookingNumber && w.field == 'capacity',
    );
    expect(
      find.descendant(of: number, matching: find.text('2')),
      findsOneWidget,
    );
    await t.tap(find.text('保存设置'));
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'settings_save');
    expect(call['capacity'], 2);
    expect(call['slot_minutes'], 30);
  });
  testWidgets('预约设置保存加载时保持按钮尺寸与单次请求', (t) async {
    await open(t, const AppointmentSettingsLivePage());
    api.gate = Completer<void>();
    final button = find
        .ancestor(of: find.text('保存设置'), matching: find.byType(Expanded))
        .last;
    final size = t.getSize(button);
    await t.tap(find.text('保存设置'));
    await t.pump();
    final busyButton = find
        .ancestor(of: find.text('提交中…'), matching: find.byType(Expanded))
        .last;
    expect(t.getSize(busyButton), size);
    expect(find.text('提交中…'), findsOneWidget);
    expect(find.byType(AppSpinner), findsWidgets);
    expect(api.calls.where((c) => c['action'] == 'settings_save').length, 1);
    api.writeError = const AppError('保存失败');
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.text('保存设置'), findsOneWidget);
  });

  testWidgets('预约设置首次加载保留标题和底栏，延迟后只在内容区显示匹配骨架', (t) async {
    phone(t);
    api.optionsGate = Completer<void>();
    await t.pumpWidget(const MaterialApp(home: AppointmentSettingsLivePage()));
    expect(find.text('预约设置'), findsOneWidget);
    expect(find.text('保存设置'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsNothing);
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byType(AppointmentSettingsSkeleton), findsOneWidget);
    expect(find.text('在线预约'), findsOneWidget);
    expect(find.text('可预约时间'), findsOneWidget);
    expect(find.text('接待规则'), findsOneWidget);
    expect(find.byType(AppSkeleton), findsWidgets);
    final sectionTops = {
      for (final title in ['在线预约', '可预约时间', '接待规则', '预约通知'])
        title: t.getTopLeft(find.text(title)).dy,
    };
    await t.tap(find.text('保存设置'));
    expect(api.calls.where((c) => c['action'] == 'settings_save'), isEmpty);
    api.optionsGate!.complete();
    await t.pumpAndSettle();
    expect(find.byType(AppointmentSettingsSkeleton), findsNothing);
    expect(find.text('预约设置'), findsOneWidget);
    for (final entry in sectionTops.entries) {
      expect(t.getTopLeft(find.text(entry.key)).dy, entry.value);
    }
  });
  testWidgets('改期使用真实预约 ID、可用时段与保留的工位技师', (t) async {
    api.bookings.add(bookingRow());
    await open(
      t,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showAppointmentReschedule(
              ctx,
              Appointment(api.bookings.single),
            ),
            child: const Text('改期入口'),
          ),
        ),
      ),
    );
    await t.tap(find.text('改期入口'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('今天 '));
    await t.pumpAndSettle();
    await t.tap(find.text('17:30 原'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认改期'));
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'save');
    expect(call['id'], 'a1');
    expect(call['bay_id'], 'b1');
    expect(call['technician_id'], 't1');
    expect(find.text('改期 · 真实客户'), findsNothing);
  });

  testWidgets('改期初始不预选，切换日期清空时间并重新请求时段', (t) async {
    api.bookings.add(bookingRow());
    await open(
      t,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showAppointmentReschedule(
              ctx,
              Appointment(api.bookings.single),
            ),
            child: const Text('改期入口'),
          ),
        ),
      ),
    );
    await t.tap(find.text('改期入口'));
    await t.pumpAndSettle();
    expect(api.calls.where((c) => c['action'] == 'slots'), isEmpty);
    expect(find.text('请先选择新日期'), findsOneWidget);
    await t.tap(find.text('确认改期'));
    await t.tap(find.text('取消这个预约'));
    await t.pumpAndSettle();
    expect(api.calls.where((c) => c['action'] == 'save'), isEmpty);
    expect(find.text('确认取消预约？'), findsNothing);
    await t.tap(find.textContaining('今天 '));
    await t.pumpAndSettle();
    expect(api.calls.where((c) => c['action'] == 'slots'), hasLength(1));
    expect(find.text('17:30 原'), findsOneWidget);
    await t.tap(find.text('17:30 原'));
    await t.pumpAndSettle();
    expect(find.text('新时间 · 17:30'), findsOneWidget);
    await t.tap(find.textContaining('明天 '));
    await t.pumpAndSettle();
    expect(api.calls.where((c) => c['action'] == 'slots'), hasLength(2));
    expect(find.text('17:30 原'), findsNothing);
    expect(find.textContaining('请选择时间'), findsOneWidget);
    await t.tap(find.text('确认改期'));
    await t.pump();
    expect(api.calls.where((c) => c['action'] == 'save'), isEmpty);
  });

  testWidgets('确认改期加载时按钮不缩形，显示转圈和提交中且不可重复提交', (t) async {
    api.bookings.add(bookingRow());
    api.gate = Completer<void>();
    await open(
      t,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showAppointmentReschedule(
              ctx,
              Appointment(api.bookings.single),
            ),
            child: const Text('改期入口'),
          ),
        ),
      ),
    );
    await t.tap(find.text('改期入口'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('今天 '));
    await t.pumpAndSettle();
    await t.tap(find.text('17:30 原'));
    await t.pumpAndSettle();
    final button = find.byKey(const ValueKey('reschedule-confirm-button'));
    final before = t.getSize(button);
    await t.tap(find.text('确认改期'));
    await t.pump();
    expect(t.getSize(button), before);
    expect(
      find.descendant(of: button, matching: find.text('提交中…')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: button, matching: find.byType(AppSpinner)),
      findsOneWidget,
    );
    expect(find.text('确认改期'), findsNothing);
    expect(find.text('取消'), findsOneWidget);
    await t.tapAt(t.getCenter(button));
    await t.pump();
    expect(api.calls.where((c) => c['action'] == 'save'), hasLength(1));
    api.gate!.complete();
    await t.pumpAndSettle();
  });

  testWidgets('日期条左右滑动切周，按新的周起始日期请求后端', (t) async {
    await open(t, const AppointmentsPage());
    final first = DateTime.parse(
      api.calls.firstWhere((c) => c['action'] == 'board')['day'] as String,
    );
    await t.drag(
      find.byKey(const ValueKey('appointment-week')),
      const Offset(-200, 0),
    );
    await t.pumpAndSettle();
    expect(
      api.calls.lastWhere((c) => c['action'] == 'board')['day'],
      bookingDay(first.add(const Duration(days: 7))),
    );
    await t.drag(
      find.byKey(const ValueKey('appointment-week')),
      const Offset(200, 0),
    );
    await t.pumpAndSettle();
    expect(
      api.calls.lastWhere((c) => c['action'] == 'board')['day'],
      bookingDay(first),
    );
  });

  testWidgets('日期条跟手滑动并在松手后衔接到相邻周', (t) async {
    await open(t, const AppointmentsPage());
    final pager = t.widget<PageView>(find.byType(PageView));
    final controller = pager.controller!;
    final start = controller.page!;
    final gesture = await t.startGesture(
      t.getCenter(find.byKey(const ValueKey('appointment-week'))),
    );
    await gesture.moveBy(const Offset(-40, 0));
    await t.pump();
    await gesture.moveBy(const Offset(-120, 0));
    await t.pump();
    expect(controller.page, greaterThan(start));
    expect(controller.page, lessThan(start + 1));
    await gesture.moveBy(const Offset(-400, 0));
    await t.pump();
    await gesture.up();
    await t.pumpAndSettle();
    expect(controller.page, start + 1);
  });

  testWidgets('切周请求失败时日期条回到上次成功加载的周', (t) async {
    await open(t, const AppointmentsPage());
    api.readError = const AppError('读取失败');
    await t.drag(
      find.byKey(const ValueKey('appointment-week')),
      const Offset(-200, 0),
    );
    await t.pumpAndSettle();
    final pager = t.widget<PageView>(find.byType(PageView));
    expect(pager.controller!.page, 10000);
  });

  testWidgets('切周加载中继续滑动，以最后停留的周请求并展示数据', (t) async {
    await open(t, const AppointmentsPage());
    final first = DateTime.parse(
      api.calls.firstWhere((c) => c['action'] == 'board')['day'] as String,
    );
    api.optionsGate = Completer<void>();
    await t.drag(
      find.byKey(const ValueKey('appointment-week')),
      const Offset(-600, 0),
    );
    await t.pump(const Duration(milliseconds: 300));
    await t.drag(
      find.byKey(const ValueKey('appointment-week')),
      const Offset(-600, 0),
    );
    await t.pump(const Duration(milliseconds: 300));
    api.optionsGate!.complete();
    await t.pumpAndSettle();
    final page = t.widget<PageView>(find.byType(PageView)).controller!.page!;
    expect(page, greaterThanOrEqualTo(10002));
    expect(
      api.calls.lastWhere((c) => c['action'] == 'board')['day'],
      bookingDay(first.add(Duration(days: (page.toInt() - 10000) * 7))),
    );
  });

  testWidgets('取消预约等待确认请求完成才关闭弹层并释放预约', (t) async {
    api.bookings.add(bookingRow());
    api.gate = Completer<void>();
    await open(
      t,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => showAppointmentReschedule(
              ctx,
              Appointment(api.bookings.single),
            ),
            child: const Text('取消入口'),
          ),
        ),
      ),
    );
    await t.tap(find.text('取消入口'));
    await t.pumpAndSettle();
    await t.tap(find.text('客户有事'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('取消这个预约'));
    await t.tap(find.text('取消这个预约'));
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pump(const Duration(milliseconds: 100));
    expect(api.bookings.single['status'], 'waiting');
    expect(find.text('确认取消预约？'), findsOneWidget);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(api.bookings.single['status'], 'cancelled');
    expect(find.text('改期 · 真实客户'), findsNothing);
  });

  testWidgets('已到店预约带入服务开单，收款调用预约结算接口', (t) async {
    api.bookings.add(bookingRow(status: 'arrived'));
    await open(
      t,
      Builder(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () =>
                openAppointmentOrder(ctx, Appointment(api.bookings.single)),
            child: const Text('开单入口'),
          ),
        ),
      ),
    );
    await t.tap(find.text('开单入口'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认收款'));
    await t.pumpAndSettle();
    await t.tap(find.text('微信').last);
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'checkout');
    expect(call['id'], 'a1');
    expect((call['lines'] as List).single['service_id'], 's1');
    expect(api.bookings.single['status'], 'done');
  });
}
