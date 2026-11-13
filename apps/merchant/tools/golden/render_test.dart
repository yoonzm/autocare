// ignore_for_file: avoid_print
// 测试工具位于 tools/，使用可见性受限的测试夹具固定截图数据。
// ignore_for_file: invalid_use_of_visible_for_testing_member
// 本地视觉回归：将现有页面渲染为 PNG，对比源码迁移前后的界面。
// 运行：flutter test tools/golden/render_test.dart --dart-define=OUT=build/screenshots
// FONT 可传本机中文字体路径；CANVAS 可选，未提供时使用 HEIGHT 或 844。
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:autocare_merchant/backend/app_cache.dart';

import 'package:autocare_merchant/backend/merchant_api.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:autocare_merchant/pages/catalog/card_tier_edit_page.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/pages/catalog/package_edit_page.dart';
import 'package:autocare_merchant/pages/account/forgot_reset_page.dart';
import 'package:autocare_merchant/pages/account/forgot_done_page.dart';
import 'package:autocare_merchant/backend/password_reset_challenge.dart';
import 'package:autocare_merchant/backend/registration_data.dart';
import 'package:autocare_merchant/pages/account/reg_done_page.dart';
import 'package:autocare_merchant/pages/shared/shell.dart';
import 'package:autocare_merchant/pages/shared/settings_page.dart';
import 'package:autocare_merchant/pages/catalog/services_page.dart';
import 'package:autocare_merchant/pages/orders/order_page.dart';
import 'package:autocare_merchant/pages/booking/appointments_page.dart';
import 'package:autocare_merchant/pages/booking/appointment_add_page.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/scan/scan_page.dart';
import 'package:autocare_merchant/pages/members/member_detail_page.dart';

import '../../test/fixtures/preview_member.dart';

import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/pages/shared/theme_sheet.dart';

class _CancellationFixtureApi extends MerchantApi {
  @override
  Future<List<Map<String, dynamic>>> accountDevices() async => [
    {
      'id': 'current',
      'current': true,
      'name': 'Android',
      'active_at': '2026-11-12T00:01:00Z',
    },
    {
      'id': 'other',
      'current': false,
      'name': 'iOS',
      'active_at': '2026-11-11T00:01:00Z',
    },
  ];
  @override
  bool get hasSession => true;
  @override
  Future<Map<String, dynamic>> cancellationCheck() async => {
    'holds': 0,
    'appointments': 0,
    'can_cancel': true,
    'billing_note': '限时免费期间无套餐欠费',
    'data_note': '门店经营数据保留，不会被清除',
  };
}

void main() {
  const out = String.fromEnvironment('OUT', defaultValue: 'build/screenshots');
  const requestedDark = bool.fromEnvironment('DARK');
  const both = bool.fromEnvironment('BOTH');
  const named = bool.fromEnvironment('NAMED');
  const forceH = int.fromEnvironment('HEIGHT', defaultValue: 0);
  const only = String.fromEnvironment('ONLY', defaultValue: '');
  const canvasPath = String.fromEnvironment('CANVAS');
  const fontPath = String.fromEnvironment('FONT');
  final boards = canvasPath.isEmpty
      ? <String, dynamic>{}
      : (jsonDecode(File(canvasPath).readAsStringSync())['boards']
            as Map<String, dynamic>);

  if (only
      .split(',')
      .any((name) => name == 'StoreEdit' || name == 'StoreAdd')) {
    storeProfile.apply({
      'name': '驰光汽车美容',
      'phone': '02188889999',
      'address': '文三路 1 号',
      'plan': 'trial',
    });
  }
  if (only.split(',').contains('ProfileEdit')) {
    storeProfile.apply({
      'name': '驰光汽车美容',
      'account_phone': '13900008812',
      'profile': {
        'name': '陈明',
        'email': 'old@example.com',
        'role': 'owner',
        'phone': '+8613900008812',
        'joined_on': '2022-01-05',
      },
    });
  }
  if (only
      .split(',')
      .any((name) => name == 'AboutApp' || name == 'ClearCache__sheet')) {
    AppCache.readFiles = () async => (images: 1048576, temporary: 2097152);
    PackageInfo.setMockInitialValues(
      appName: '汽美管家',
      packageName: 'com.yoonzm.autocare.merchant',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
  }
  if (only
      .split(',')
      .any((name) => name == 'DeleteAccount' || name == 'Security')) {
    merchantApi = _CancellationFixtureApi();
    storeProfile.apply({'name': '驰光汽车美容', 'phone': '+8613988888812'});
  }
  if (only.split(',').contains('ChangePhone')) {
    storeProfile.apply({'name': '驰光汽车美容', 'phone': '+8613988888812'});
  }
  if (only.split(',').contains('RegDone')) {
    storeProfile.apply({'name': '驰光汽车美容', 'phone': '+8613988888812'});
  }

  if (only.split(',').contains('CardTierEdit')) {
    // 截图测试固定输入；真实页面不得使用这些样例作为数据回退。
    storeProfile.live = true;
    storeProfile.name = '驰光汽车美容';
  }
  if (only.split(',').contains('PackageEdit')) {
    storeProfile.live = true;
    storeProfile.name = '驰光汽车美容';
  }

  setUpAll(() async {
    if (fontPath.isNotEmpty) {
      final loader = FontLoader('Wqy')
        ..addFont(
          Future.value(File(fontPath).readAsBytesSync().buffer.asByteData()),
        );
      await loader.load();
    }
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
    'LoginPwd': () => const LoginPage(initialTab: 1),
    'FindScanPlate': () => const ScanPage(ScanKind.findPlate),
    'ScanPlate': () => const ScanPage(ScanKind.plateCard),
    'MemberDetail': () => MemberDetailPage(member: previewMember),
  };
  for (final e in <String, WidgetBuilder>{
    ...pageBuilders,
    'RegDone': (_) => const RegDonePage(
      receipt: RegistrationReceipt(
        storeName: '驰光汽车美容',
        maskedPhone: '139 **** 8812',
        seededServices: 12,
      ),
    ),
    'ForgotReset': (_) => const ForgotResetPage(
      challenge: PasswordResetChallenge(phone: '13800001234', code: '246810'),
    ),
    'ForgotDone': (_) => const ForgotDonePage(completed: true),
    'PackageEdit': (_) => const PackageEditPage(
      initial: {
        'name': '精致洗车年卡',
        'price': '1,080',
        'validity_months': 12,
        'purchase_limit': 2,
        'vehicle_scope': '全部车型',
        'show_in_mini': true,
        'active': true,
        'items': [
          {
            'service_id': 'wash',
            'count': 20,
            'service': {'name': '精致洗车', 'price': 68},
          },
        ],
      },
    ),
    'CardTierEdit': (_) => const CardTierEditPage(
      initial: {
        'name': '黑金卡',
        'discount': 0.9,
        'color': 'black',
        'upgrade_recharge': '10,000',
        'upgrade_cumulative': '30,000',
        'points_multiplier': 2,
        'birthday_gift': '赠精致洗车 2 次',
        'priority_booking': true,
        'validity': 'forever',
      },
    ),
    // 源码迁移视觉基线使用与旧页面一致的固定输入；仅用于此截图测试。
    'ServiceEdit': (_) => const ServiceEditPage(
      initial: {
        'name': '全车镀晶 · 9H 陶瓷',
        'price': '1,580',
        'category': '镀晶镀膜',
        'duration_minutes': 240,
      },
    ),
    for (final s in sheetBuilders.entries) '${s.key}__sheet': s.value,
    'ThemeSheet__sheet': (_) => const ThemeSheet(),
    for (final h in hand.entries) '${h.key}__hand': (_) => h.value(),
  }.entries) {
    if (only.isNotEmpty && !only.split(',').contains(e.key)) continue;
    for (final dark in both ? [false, true] : [requestedDark]) {
      testWidgets('render ${e.key} ${dark ? 'dark' : 'light'}', (tester) async {
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
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: named
                    ? RouteSettings(
                        name: e.key.endsWith('__sheet')
                            ? 'sheet:${e.key.replaceAll('__sheet', '')}'
                            : e.key.replaceAll('__hand', ''),
                      )
                    : settings,
                builder: (_) => e.key.endsWith('__sheet')
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
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        if (const bool.fromEnvironment('SETTLE')) await tester.pumpAndSettle();
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
}
