import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures/preview_member.dart';

import 'package:autocare_merchant/pages/booking/appointment_add_page.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';
import 'package:autocare_merchant/pages/account/legal_web_page.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/members/member_detail_page.dart';
import 'package:autocare_merchant/pages/orders/order_page.dart';

/// 规范：所有表单输入框没值时都必须有 placeholder（docs/frontend-guidelines.md）。
/// 这里把每个页面里的输入框找出来检查 hintText；已有默认值的输入框也要有，
/// 因为用户清空后看到的就是 placeholder。
void main() {
  legalWebViewBuilder = (url, headers, onLoaded, onError) {
    Future.microtask(onLoaded);
    return const SizedBox();
  };
  Future<List<String>> missing(
    WidgetTester t,
    Widget page, {
    bool sheet = false,
  }) async {
    t.view.physicalSize = const Size(390 * 3, 1600 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    // 测试字体会让文字溢出，与本规范无关，忽略（page_registry_test 同样处理）
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(
      MaterialApp(
        home: sheet ? Scaffold(body: SingleChildScrollView(child: page)) : page,
      ),
    );
    await t.pump(const Duration(milliseconds: 300));
    final bad = <String>[];
    for (final f in t.widgetList<TextField>(find.byType(TextField))) {
      final hint = f.decoration?.hintText;
      if (hint == null || hint.trim().isEmpty) {
        bad.add('初始值“${f.controller?.text ?? ''}”');
      }
    }
    return bad;
  }

  for (final e in pageBuilders.entries) {
    testWidgets('输入框都有 placeholder · ${e.key}', (t) async {
      final bad = await missing(t, Builder(builder: e.value));
      expect(bad, isEmpty, reason: '${e.key} 有输入框缺少 placeholder：$bad');
    });
  }
  for (final e in sheetBuilders.entries) {
    testWidgets('输入框都有 placeholder · 弹层 ${e.key}', (t) async {
      final bad = await missing(t, Builder(builder: e.value), sheet: true);
      expect(bad, isEmpty, reason: '弹层 ${e.key} 有输入框缺少 placeholder：$bad');
    });
  }

  final handWritten = <String, Widget Function()>{
    'Login': () => const LoginPage(),
    'Order': () => const OrderPage(),
    'AppointmentAdd': () => const AppointmentAddPage(),
    'MemberDetail': () => MemberDetailPage(member: previewMember),
  };
  for (final e in handWritten.entries) {
    testWidgets('输入框都有 placeholder · 手写页 ${e.key}', (t) async {
      final bad = await missing(t, e.value());
      expect(bad, isEmpty, reason: '${e.key} 有输入框缺少 placeholder：$bad');
    });
  }
}
