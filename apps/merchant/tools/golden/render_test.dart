// ignore_for_file: avoid_print
// 本地对比用：把生成的页面渲染成 PNG，与 Chromium 里的设计稿截图对照。
// 运行：flutter test tools/golden/render_test.dart --dart-define=OUT=/tmp/out
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/pages/shell.dart';
import 'package:autocare_merchant/pages/settings_page.dart';
import 'package:autocare_merchant/pages/services_page.dart';
import 'package:autocare_merchant/pages/order_page.dart';
import 'package:autocare_merchant/pages/appointments_page.dart';
import 'package:autocare_merchant/pages/appointment_add_page.dart';
import 'package:autocare_merchant/pages/login_page.dart';
import 'package:autocare_merchant/pages/scan_page.dart';
import 'package:autocare_merchant/pages/member_detail_page.dart';
import 'package:autocare_merchant/mock/mock_data.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/pages/theme_sheet.dart';

void main() {
  const out = String.fromEnvironment('OUT', defaultValue: '/tmp/out');
  const dark = bool.fromEnvironment('DARK');
  const forceH = int.fromEnvironment('HEIGHT', defaultValue: 0);
  const only = String.fromEnvironment('ONLY', defaultValue: '');
  final canvas = jsonDecode(
    File('/tmp/claude-0/ref/canvas.json').readAsStringSync(),
  );
  final boards = canvas['boards'] as Map<String, dynamic>;

  setUpAll(() async {
    final loader = FontLoader('Wqy')
      ..addFont(
        Future.value(
          File('/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc')
              .readAsBytesSync()
              .buffer
              .asByteData(),
        ),
      );
    await loader.load();
    Directory(out).createSync(recursive: true);
  });

  final hand = <String, Widget Function()>{
    'Main': () {
      tabIndex.value = 0;
      return const Shell();
    },
    'Stats': () {
      tabIndex.value = 3;
      return const Shell();
    },
    'Members': () {
      tabIndex.value = 1;
      return const Shell();
    },
    'Inventory': () {
      tabIndex.value = 2;
      return const Shell();
    },
    'Settings': () => const SettingsPage(),
    'Services': () => const ServicesPage(),
    'Order': () => const OrderPage(),
    'Appointments': () => const AppointmentsPage(),
    'AppointmentSchedule': () => const AppointmentsPage(initialView: 1),
    'AppointmentAdd': () => const AppointmentAddPage(),
    'Login': () => const LoginPage(),
    'FindScanPlate': () => const ScanPage(ScanKind.findPlate),
    'FindScanCode': () => const ScanPage(ScanKind.findCode),
    'ScanLicense': () => const ScanPage(ScanKind.licenseCard),
    'ScanPlate': () => const ScanPage(ScanKind.plateCard),
    'MemberDetail': () => MemberDetailPage(member: members.first),
  };
  for (final e in <String, WidgetBuilder>{
    ...genRoutes,
    for (final s in genSheets.entries) '${s.key}__sheet': s.value,
    'ThemeSheet__sheet': (_) => const ThemeSheet(),
    for (final h in hand.entries) '${h.key}__hand': (_) => h.value(),
  }.entries) {
    if (only.isNotEmpty && !only.split(',').contains(e.key)) continue;
    testWidgets('render ${e.key}', (tester) async {
      final bk = e.key.replaceAll('__hand', '');
      final h = forceH > 0
          ? forceH.toDouble()
          : (boards['$bk.dc.html']?['h'] ?? 844).toDouble();
      tester.view.physicalSize = Size(390 * 2, h * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      C.dark = dark;
      addTearDown(() => C.dark = false);
      final errs = <String>{};
      final old = FlutterError.onError;
      FlutterError.onError = (d) =>
          errs.add(d.exceptionAsString().split('\n').first);
      addTearDown(() => FlutterError.onError = old);
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
              fontFamily: 'Wqy',
              useMaterial3: true,
            ),
            builder: (c, w) => e.key.endsWith('__hand')
                ? MediaQuery(
                    data: MediaQuery.of(c).copyWith(
                      padding: const EdgeInsets.only(top: 44, bottom: 34),
                    ),
                    child: w!,
                  )
                : w!,
            home: e.key.endsWith('__sheet')
                ? Scaffold(
                    backgroundColor: Colors.black38,
                    body: Align(
                      alignment: Alignment.bottomCenter,
                      child: SingleChildScrollView(
                        child: Builder(builder: e.value),
                      ),
                    ),
                  )
                : Builder(builder: e.value),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      tester.takeException();
      await tester.runAsync(() async {
        final b =
            key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final img = await b.toImage(pixelRatio: 1);
        final data = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/${e.key}${dark ? '_dark' : ''}.png')
            .writeAsBytesSync(data!.buffer.asUint8List());
      });
      if (errs.isNotEmpty) print('ERR ${e.key}: ${errs.take(3).join(' | ')}');
    });
  }
}
