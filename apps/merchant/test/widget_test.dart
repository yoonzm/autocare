import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/main.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/mock/mock_data.dart';
import 'package:autocare_merchant/pages/appointment_add_page.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/member_detail_page.dart';
import 'package:autocare_merchant/pages/order_page.dart';
import 'package:autocare_merchant/pages/services_page.dart';
import 'package:autocare_merchant/pages/settings_page.dart';

import 'members_test.dart' show MemberFakeApi;

void main() {
  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  testWidgets('登录后进入首页，底部 Tab 可切换', (tester) async {
    phone(tester);
    final originalApi = merchantApi;
    merchantApi = _FakeMerchantApi();
    addTearDown(() => merchantApi = originalApi);
    addTearDown(storeProfile.clear);
    await tester.pumpWidget(const QimeiApp());
    expect(find.text('汽美管家'), findsOneWidget);
    await tester.tap(find.text('密码登录'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '13988888812');
    await tester.enterText(find.byType(TextField).last, 'password123');
    await tester.tap(find.text('登录').first);
    await tester.pumpAndSettle();
    expect(find.text('测试门店'), findsOneWidget);
    for (final tab in ['会员', '库存', '统计', '首页']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('二级页面均可无溢出渲染', (tester) async {
    phone(tester);
    final pages = <Widget>[
      const OrderPage(),
      const AppointmentsPage(),
      const AppointmentAddPage(),
      MemberDetailPage(member: members.first),
      const ServicesPage(),
      const SettingsPage(),
    ];
    for (final p in pages) {
      await tester.pumpWidget(MaterialApp(home: p));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: p.runtimeType.toString());
    }
  });

  testWidgets('新建预约后出现在预约列表', (tester) async {
    phone(tester);
    await tester.pumpWidget(const MaterialApp(home: AppointmentsPage()));
    await tester.tap(find.text('新建预约'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认预约'));
    await tester.pumpAndSettle();
    expect(appointmentStore.items.length, 7);
    expect(tester.takeException(), isNull);
  });
}

class _FakeMerchantApi extends MemberFakeApi {
  bool signedIn = false;

  @override
  bool get hasSession => signedIn;

  @override
  Future<Map<String, dynamic>> getStore() async => {'name': '测试门店'};

  @override
  Future<void> loginPassword(String phone, String password) async {
    assert(phone == '13988888812');
    assert(password == 'password123');
    signedIn = true;
  }
}
