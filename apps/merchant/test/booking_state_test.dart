import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/appointment_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/booking/booking_settings_controller.dart';
import 'package:autocare_merchant/pages/booking/reschedule_controller.dart';
import 'package:autocare_merchant/pages/booking/appointment_detail_live_page.dart';
import 'package:autocare_merchant/pages/staff/staff_editor_controller.dart';
import 'package:autocare_merchant/pages/staff/staff_editor_page.dart';
import 'package:autocare_merchant/pages/staff/staff_edit_template.dart';
import 'package:autocare_merchant/pages/booking/booking_resources_page.dart';
import 'package:autocare_merchant/pages/booking/bay_edit_template.dart';
import 'package:autocare_merchant/pages/orders/order_page.dart';

import 'appointments_test.dart' show BookingApi, bookingRow;
import 'members_test.dart' show phone;

class ControlledBookingApi extends BookingApi {
  Completer<Map<String, dynamic>>? pendingWrite;
  final detailReads = <Completer<Map<String, dynamic>>>[];
  bool deferDetails = false;
  Completer<Map<String, dynamic>>? memberRead;
  @override
  Future<Map<String, dynamic>> member(String id) =>
      memberRead?.future ?? super.member(id);
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 20),
    String? requestId,
  }) async {
    if (pendingWrite != null) {
      writeRequests.add({'body': body, 'requestId': requestId});
      return pendingWrite!.future;
    }
    return super.invoke(body, timeout: timeout, requestId: requestId);
  }

  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    if (deferDetails && action == 'get') {
      calls.add({'action': action, ...values});
      final c = Completer<Map<String, dynamic>>();
      detailReads.add(c);
      return c.future;
    }
    return super.appointment(action, values);
  }
}

void main() {
  late MerchantApi original;
  late ControlledBookingApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = ControlledBookingApi();
    api.bookings.add(bookingRow());
  });
  tearDown(() {
    merchantApi = original;
  });

  test('设置实例与输入快照隔离，失败保留输入且重试沿用请求标识', () async {
    final options = await api.appointment('options');
    final a = BookingSettingsController(options, 'settings'),
        b = BookingSettingsController(options, 'settings');
    a.setSetting('capacity', 5);
    expect(b.settings['capacity'], 2);
    expect(options['settings']['capacity'], 2);
    api.writeError = const AppError('保存失败');
    await expectLater(a.persist(), throwsA(isA<AppError>()));
    expect(a.settings['capacity'], 5);
    expect(a.dirty, isTrue);
    api.writeError = null;
    expect(await a.persist(), isNotNull);
    expect(await a.persist(), isNull);
    expect(api.writeRequests[0]['requestId'], isNotNull);
    expect(
      api.writeRequests[0]['requestId'],
      api.writeRequests[1]['requestId'],
    );
    a.setSetting('capacity', 6);
    await a.persist();
    expect(
      api.writeRequests.last['requestId'],
      isNot(api.writeRequests[1]['requestId']),
    );
    expect(a.actionKey, isNot(b.actionKey));
    a.dispose();
    b.dispose();
  });

  test('员工草稿使用真实skills与bay_id，不借用category/linked_id；失败重试保持同一目标', () async {
    final options = await api.staff('list');
    final c = StaffEditorController(
      options,
      row: {
        'id': 'staff1',
        'name': '王师傅',
        'phone': '13800000000',
        'role': 'technician',
        'skills': '洗车',
        'bay_id': 'b1',
        'joined_on': '2026-01-01',
      },
    );
    c.setDraft('skills', '洗车 / 镀晶');
    c.setDraft('bay_id', 'b2');
    api.writeError = const AppError('保存失败');
    await expectLater(c.persist(), throwsA(isA<AppError>()));
    final sent = api.writeRequests.single['body'];
    expect(sent['skills'], '洗车 / 镀晶');
    expect(sent['bay_id'], 'b2');
    expect(sent.containsKey('category'), isFalse);
    expect(sent.containsKey('linked_id'), isFalse);
    // Use the controlled transport for a successful canonical response independent of fixture staff IDs.
    api.pendingWrite = Completer<Map<String, dynamic>>();
    final retry = c.persist();
    api.pendingWrite!.complete({
      'item': {'id': 'staff1'},
    });
    await retry;
    expect(
      api.writeRequests[0]['requestId'],
      api.writeRequests[1]['requestId'],
    );
    expect(c.dirty, isFalse);
    c.dispose();
  });

  test('无创建幂等契约的新增工位/员工遇到不明结果时阻止盲目重试', () async {
    final options = await api.appointment('options'),
        staffOptions = await api.staff('list');
    final bay = BookingSettingsController(options, 'bay');
    bay.setDraft('name', '新工位');
    final staff = StaffEditorController(staffOptions);
    staff.setDraft('name', '新员工');
    api.writeError = const AppError.timeout();
    await expectLater(bay.persist(), throwsA(isA<AppError>()));
    await expectLater(staff.persist(), throwsA(isA<AppError>()));
    final count = api.writeRequests.length;
    api.writeError = null;
    await expectLater(
      bay.persist(),
      throwsA(isA<AppError>().having((e) => e.message, '核对提示', contains('核对'))),
    );
    await expectLater(staff.persist(), throwsA(isA<AppError>()));
    expect(api.writeRequests.length, count);
    expect(bay.draft['name'], '新工位');
    expect(staff.draft['name'], '新员工');
    bay.dispose();
    staff.dispose();
  });

  test('改期失败保留原预约、日期、工位和技师；新输入使用新请求标识', () async {
    final row = Map<String, dynamic>.from(api.bookings.first);
    final a = RescheduleController(Appointment(row)),
        b = RescheduleController(Appointment({...row, 'id': 'other'}));
    a.rescheduleDay = 1;
    a.selectedTime = '10:00';
    a.edited();
    api.writeError = const AppError('时段已占用');
    await expectLater(a.persist(), throwsA(isA<AppError>()));
    expect(a.selectedTime, '10:00');
    expect(a.rescheduleDay, 1);
    expect(b.selectedTime, isEmpty);
    final first = api.writeRequests.single;
    expect(first['body']['bay_id'], row['bay_id']);
    expect(first['body']['technician_id'], row['technician_id']);
    api.writeError = null;
    await a.persist();
    expect(
      api.writeRequests[0]['requestId'],
      api.writeRequests[1]['requestId'],
    );
    a.selectedTime = '11:00';
    a.edited();
    await a.persist();
    expect(api.writeRequests.last['requestId'], isNot(first['requestId']));
    expect(a.actionKey, isNot(b.actionKey));
    a.dispose();
    b.dispose();
  });

  test('写入防重复且冻结请求体，销毁后成功仍交付结果但不通知旧表单', () async {
    final c = BookingSettingsController(
      await api.appointment('options'),
      'settings',
    );
    var notified = 0;
    c.addListener(() => notified++);
    api.pendingWrite = Completer<Map<String, dynamic>>();
    final future = c.persist();
    expect(await c.persist(), isNull);
    c.settings['capacity'] = 99;
    expect(api.writeRequests.single['body']['capacity'], 2);
    expect(
      () => (api.writeRequests.single['body']['closed_days'] as List).add(3),
      throwsUnsupportedError,
    );
    c.dispose();
    api.pendingWrite!.complete({
      'item': {'capacity': 2},
    });
    expect(await future, isNotNull);
    expect(notified, 1);
  });

  test('权限展示直接使用后端数据，不因角色名假设全选', () async {
    final options = await api.staff('list');
    options['permissions'] = {
      'manager': {'cashier': false},
    };
    final c = StaffEditorController(options);
    expect(c.roleCan('manager', 'cashier'), isFalse);
    c.dispose();
  });

  testWidgets('读取开单会员期间目标失效时不再导航旧预约', (t) async {
    phone(t);
    var current = true;
    api.memberRead = Completer<Map<String, dynamic>>();
    final a = Appointment({...bookingRow(), 'member_id': 'm1'});
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () =>
                  openAppointmentOrder(context, a, isCurrent: () => current),
              child: const Text('打开开单'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('打开开单'));
    await t.pump();
    current = false;
    api.memberRead!.complete({'id': 'm1'});
    await t.pumpAndSettle();
    expect(find.byType(OrderPage), findsNothing);
    expect(find.text('打开开单'), findsOneWidget);
  });

  testWidgets('默认技师选择返回记录标识，同名技师不会误选第一个', (t) async {
    phone(t);
    final options = await api.appointment('options');
    options['resources'] = [
      {'id': 't1', 'kind': 'technician', 'name': '同名技师', 'active': true},
      {'id': 't2', 'kind': 'technician', 'name': '同名技师', 'active': true},
    ];
    final c = BookingSettingsController(options, 'bay');
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => c.pickLinked(context),
              child: const Text('选择技师'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('选择技师'));
    await t.pumpAndSettle();
    expect(find.text('同名技师'), findsNWidgets(2));
    await t.tap(find.text('同名技师').last);
    await t.pumpAndSettle();
    expect(c.draft['linked_id'], 't2');
    c.dispose();
  });

  testWidgets('预加载员工编辑器切换目标会释放旧输入，保留各自原始字段', (t) async {
    phone(t);
    final options = await api.staff('list');
    Map<String, dynamic> employee(String id, String name) => {
      'id': id,
      'name': name,
      'phone': '13800000000',
      'role': 'technician',
      'skills': '洗车',
      'bay_id': 'b1',
      'joined_on': '2026-01-01',
      'status': 'active',
    };
    Future<void> show(String id, String name) => t.pumpWidget(
      MaterialApp(
        home: StaffEditorPage(row: employee(id, name), options: options),
      ),
    );
    await show('a', '甲');
    await t.enterText(find.byType(TextFormField).first, '甲的修改');
    await t.pump();
    await show('b', '乙');
    await t.pumpAndSettle();
    expect(find.text('甲的修改'), findsNothing);
    expect(find.text('乙'), findsWidgets);
    final c = t.widget<StaffEditTemplate>(find.byType(StaffEditTemplate)).c;
    expect(c.draft['id'], 'b');
    expect(c.draft['name'], '乙');
  });

  testWidgets('预加载工位编辑器切换目标不继承旧名称与提交状态', (t) async {
    phone(t);
    final options = await api.appointment('options');
    Future<void> show(String id, String name) => t.pumpWidget(
      MaterialApp(
        home: BayEditorPage(
          row: {
            'id': id,
            'name': name,
            'category': '洗车',
            'position': 0,
            'active': true,
          },
          options: options,
        ),
      ),
    );
    await show('a', '工位甲');
    await t.enterText(find.byType(TextFormField).first, '修改甲');
    await t.pump();
    await show('b', '工位乙');
    await t.pumpAndSettle();
    expect(find.text('修改甲'), findsNothing);
    expect(
      t.widget<BayEditorTemplate>(find.byType(BayEditorTemplate)).c.draft['id'],
      'b',
    );
    expect(find.text('工位乙'), findsOneWidget);
  });

  testWidgets('预约详情切换ID后旧读取不覆盖新目标', (t) async {
    phone(t);
    final row = Map<String, dynamic>.from(api.bookings.first);
    api.deferDetails = true;
    Future<void> show(String id) =>
        t.pumpWidget(MaterialApp(home: AppointmentDetailLivePage(id: id)));
    await show('old');
    await t.pump();
    await show('new');
    await t.pump();
    api.detailReads[1].complete({...row, 'id': 'new', 'customer_name': '新客户'});
    await t.pumpAndSettle();
    api.detailReads[0].complete({...row, 'id': 'old', 'customer_name': '旧客户'});
    await t.pumpAndSettle();
    expect(find.text('新客户'), findsOneWidget);
    expect(find.text('旧客户'), findsNothing);
  });
}
