import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/login_page.dart';
import 'package:autocare_merchant/mock/mock_data.dart';
import 'package:autocare_merchant/pages/appointment_add_page.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/member_detail_page.dart';
import 'package:autocare_merchant/pages/order_page.dart';
import 'package:autocare_merchant/pages/services_page.dart';
import 'package:autocare_merchant/pages/settings_page.dart';

void main() {
  void phone(WidgetTester t) {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  testWidgets('登录页校验输入，不会绕过认证进入首页', (tester) async {
    phone(tester);
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('汽美管家'), findsOneWidget);
    await tester.tap(find.text('登录'));
    await tester.pumpAndSettle();
    expect(find.text('请填写有效邮箱和至少 6 位密码'), findsOneWidget);
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
