import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSwitchValue;
import 'package:autocare_merchant/pages/shared/notify_settings_page.dart';

class _FakeNotifyApi extends MerchantApi {
  @override
  bool get hasSession => true;

  final List<Map<String, dynamic>> savedPatches = [];
  bool calledAppointmentSave = false;
  Object? saveError;

  Map<String, dynamic> notifySettings = {
    'notify_consume': true,
    'notify_recharge': true,
    'notify_confirm_default': false,
    'notify_reschedule': true,
    'notify_cancel': true,
    'remind_default': false,
    'notify_manager': false,
  };

  @override
  Future<Map<String, dynamic>> storeSmsOverview() async => {
    'store_name': '测试门店',
    'month_stats': {'total': 12, 'delivered': 10, 'pending': 1, 'failed': 1},
    'notify_settings': {...notifySettings},
    'scenarios': [
      {
        'key': 'order_consume',
        'group': 'transaction',
        'title': '消费结账通知客户',
        'setting_key': 'notify_consume',
        'enabled': notifySettings['notify_consume'],
        'template_preview': '消费通知预览',
      },
      {
        'key': 'appointment_confirm',
        'group': 'booking',
        'title': '预约成功通知客户',
        'setting_key': 'notify_confirm_default',
        'enabled': notifySettings['notify_confirm_default'],
        'template_preview': '预约通知预览',
      },
    ],
  };

  @override
  Future<Map<String, dynamic>> storeNotifySettingsSave(
    Map<String, bool> patch,
  ) async {
    savedPatches.add(Map<String, dynamic>.from(patch));
    if (saveError != null) throw saveError!;
    notifySettings = {...notifySettings, ...patch};
    return {...notifySettings};
  }

  @override
  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'settings_save') {
      calledAppointmentSave = true;
    }
    throw UnsupportedError('Unexpected appointment action: $action');
  }
}

void main() {
  late MerchantApi previousApi;
  late _FakeNotifyApi api;

  setUp(() {
    previousApi = merchantApi;
    api = _FakeNotifyApi();
    merchantApi = api;
  });

  tearDown(() {
    merchantApi = previousApi;
  });

  testWidgets('通知设置页仅通过独立接口局部保存开关，不调用预约设置保存', (t) async {
    await t.pumpWidget(const MaterialApp(home: NotifySettingsPage()));
    await t.pumpAndSettle();

    final switches = find.byType(HSwitchValue);
    expect(switches, findsNWidgets(2));
    expect(t.widget<HSwitchValue>(switches.at(0)).value, isTrue);
    expect(t.widget<HSwitchValue>(switches.at(1)).value, isFalse);

    await t.tap(switches.at(0));
    await t.pumpAndSettle();

    expect(api.calledAppointmentSave, isFalse);
    expect(api.savedPatches, [
      {'notify_consume': false},
    ]);
    expect(t.widget<HSwitchValue>(switches.at(0)).value, isFalse);
    expect(t.widget<HSwitchValue>(switches.at(1)).value, isFalse);
    await t.pump(const Duration(seconds: 1));
  });

  testWidgets('通知开关保存失败时保持原开关状态并提示错误', (t) async {
    api.saveError = const AppError('请先在员工管理中配置已启用的店长，再开启店长通知');
    await t.pumpWidget(const MaterialApp(home: NotifySettingsPage()));
    await t.pumpAndSettle();

    final switches = find.byType(HSwitchValue);
    await t.tap(switches.at(1));
    await t.pumpAndSettle();

    expect(api.savedPatches, [
      {'notify_confirm_default': true},
    ]);
    expect(t.widget<HSwitchValue>(switches.at(1)).value, isFalse);
    expect(find.text('请先在员工管理中配置已启用的店长，再开启店长通知'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });
}
