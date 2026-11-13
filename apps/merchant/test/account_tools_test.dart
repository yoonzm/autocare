import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/app_cache.dart';
import 'package:autocare_merchant/backend/cache_files_io.dart' as cache_files;
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';
import 'package:autocare_merchant/theme.dart';

class ToolsApi extends MerchantApi {
  bool failDevices = false;
  String? removed;
  @override
  bool get hasSession => true;
  @override
  Future<List<Map<String, dynamic>>> accountDevices() async {
    if (failDevices) throw const AppError('设备读取失败', type: AppErrorType.network);
    return [
      {
        'id': 'one',
        'current': true,
        'name': 'Android',
        'active_at': '2026-11-12T00:01:00Z',
      },
      if (removed == null)
        {
          'id': 'two',
          'current': false,
          'name': 'iOS',
          'active_at': '2026-11-11T00:01:00Z',
        },
    ];
  }

  @override
  Future<void> revokeDevice(String id) async {
    removed = id;
  }

  @override
  Future<Map<String, dynamic>> cancellationCheck() async => {
    'holds': 2,
    'appointments': 1,
    'can_cancel': false,
    'billing_note': '限时免费期间无套餐欠费',
    'data_note': '门店经营数据保留，不会被清除',
  };
  @override
  Future<String> supportPhone() async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MerchantApi original;
  late ToolsApi api;
  late Directory fixture;
  setUp(() async {
    original = merchantApi;
    merchantApi = api = ToolsApi();
    fixture = await Directory.systemTemp.createTemp('autocare-account-test-');
    await Directory('${fixture.path}/cache').create();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => '${fixture.path}/cache',
        );
    PackageInfo.setMockInitialValues(
      appName: '汽美管家',
      packageName: 'com.yoonzm.autocare.merchant',
      version: '1.2.3',
      buildNumber: '42',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({
      'auth_token': 'preserve-me',
      'theme': 'dark',
    });
    storeProfile.apply({'phone': '+8613800138000', 'name': '真实门店'});
  });
  tearDown(() async {
    merchantApi = original;
    storeProfile.clear();
    C.dark = false;
    await fixture.delete(recursive: true);
  });
  Future<void> open(WidgetTester t, String route, {bool dark = false}) async {
    t.view.physicalSize = const Size(390 * 3, 1400 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    C.dark = dark;
    await t.pumpWidget(
      MaterialApp(
        initialRoute: route,
        onGenerateRoute: (s) =>
            MaterialPageRoute(settings: s, builder: pageBuilders[s.name]!),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('设备列表真实展示、移除后刷新，隐藏一期不用的安全入口', (t) async {
    await open(t, 'Security');
    expect(find.text('Android · 本机'), findsOneWidget);
    expect(find.text('iPhone 15 · 本机'), findsNothing);
    expect(find.text('微信绑定'), findsNothing);
    expect(find.text('安全设置'), findsNothing);
    expect(find.text('2026.11.12 08:01 活跃'), findsOneWidget);
    await t.tap(find.text('移除'));
    await t.pumpAndSettle();
    await t.tap(find.text('移除').last);
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    expect(api.removed, 'two');
    expect(find.text('iOS'), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets('设备读取失败可重试，不展示示例设备', (t) async {
    api.failDevices = true;
    await open(t, 'Security', dark: true);
    expect(find.text('Android · 本机'), findsNothing);
    expect(find.text('重试'), findsOneWidget);
    api.failDevices = false;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('Android · 本机'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('注销条件显示真实数量，无示例挂单或已导出声明', (t) async {
    await open(t, 'DeleteAccount');
    expect(find.text('当前 2 笔挂单、1 笔预约未处理'), findsOneWidget);
    expect(find.text('当前 4 笔挂单未处理'), findsNothing);
    expect(find.text('已导出需要保留的经营数据'), findsNothing);
    expect(find.text('限时免费期间无套餐欠费'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('关于页读取安装包版本、隐藏更新入口、客服电话缺失明确阻止', (t) async {
    await open(t, 'AboutApp', dark: true);
    expect(find.text('版本 1.2.3 (42)'), findsOneWidget);
    expect(find.text('检查更新'), findsNothing);
    await t.ensureVisible(find.text('拨打'));
    await t.tap(find.text('拨打'));
    await t.pumpAndSettle();
    expect(find.text('客服热线暂未配置'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  test('缓存按真实文件统计，清理后保留设置、登录信息及缓存目录外文件', () async {
    AppCache.readFiles = cache_files.usage;
    await File('${fixture.path}/cache/photo.jpg')
        .writeAsBytes(List.filled(1024, 1));
    await File('${fixture.path}/cache/temporary.bin')
        .writeAsBytes(List.filled(2048, 2));
    final document = File('${fixture.path}/business.json');
    await document.writeAsString('preserve');
    var usage = await AppCache.usage();
    expect(usage.images, 1024);
    expect(usage.temporary, 2048);
    await AppCache.clear();
    usage = await AppCache.usage();
    expect(usage.total, 0);
    expect(await document.readAsString(), 'preserve');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), 'preserve-me');
    expect(prefs.getString('theme'), 'dark');
  });
}
