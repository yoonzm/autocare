import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/appointment_add_page.dart';
import 'package:autocare_merchant/pages/appointment_detail_live_page.dart';
import 'package:autocare_merchant/pages/appointment_settings_live_page.dart';
import 'package:autocare_merchant/pages/booking_resources_page.dart';
import 'package:autocare_merchant/widgets/booking_template_bindings.dart';

import 'members_test.dart' show MemberFakeApi, phone;

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
  });
  tearDown(() {
    merchantApi = original;
    HoldFlow.reset();
    ServiceStore.clear();
  });
  Future<void> open(WidgetTester t, Widget page) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
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
  testWidgets('到店按钮等待后端响应，不提前修改状态，失败保留预约', (t) async {
    api.bookings.add(bookingRow());
    api.gate = Completer<void>();
    await open(t, const AppointmentsPage());
    await t.tap(find.text('客户到店'));
    await t.pump();
    expect(api.bookings.single['status'], 'waiting');
    expect(find.byType(AppSpinner), findsWidgets);
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
    final number = find.byWidgetPredicate(
      (w) => w is BookingNumber && w.field == 'capacity',
    );
    expect(
      find.descendant(of: number, matching: find.text('2')),
      findsOneWidget,
    );
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'settings_save');
    expect(call['capacity'], 2);
    expect(call['slot_minutes'], 30);
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
    await t.tap(find.text('17:30'));
    await t.pumpAndSettle();
    await t.tap(find.text('确认改期'));
    await t.pumpAndSettle();
    final call = api.calls.lastWhere((c) => c['action'] == 'save');
    expect(call['id'], 'a1');
    expect(call['bay_id'], 'b1');
    expect(call['technician_id'], 't1');
    expect(find.text('改期 · 真实客户'), findsNothing);
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
