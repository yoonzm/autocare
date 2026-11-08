import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/pages/store_switch_live_sheet.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class StoresApi extends MemberFakeApi {
  Object? error;
  Completer<void>? gate;
  Map<String, dynamic> directory = {
    'current_store_id': 'real-id',
    'items': [
      {
        'id': 'real-id',
        'name': '真实金牌洗车',
        'revenue': 372.4,
        'status_label': '当前门店',
      },
    ],
    'can_add': false,
    'add_hint': '当前账号仅支持一家门店',
  };
  @override
  Future<Map<String, dynamic>> stores() async {
    await gate?.future;
    if (error != null) throw error!;
    return directory;
  }
}

void main() {
  late MerchantApi original;
  late StoresApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = StoresApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });
  Future<void> open(WidgetTester t, {bool settle = true}) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openRoute(context, 'StoreSwitch'),
              child: const Text('打开门店'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('打开门店'));
    if (settle) {
      await t.pumpAndSettle();
    } else {
      await t.pump();
    }
  }

  testWidgets('首页/我的共用真实门店弹层：真实门店营业额和当前勾选', (t) async {
    await open(t);
    expect(find.byType(StoreSwitchLiveSheet), findsOneWidget);
    expect(find.text('真实金牌洗车'), findsOneWidget);
    expect(find.text('当前门店 · 今日 ¥372.40'), findsOneWidget);
    expect(find.textContaining('徐汇店'), findsNothing);
    expect(find.textContaining('浦东店'), findsNothing);
    expect(find.textContaining('最多 3 家'), findsNothing);
    await t.tap(find.text('真实金牌洗车'));
    await t.pumpAndSettle();
    expect(navTracker.has('sheet:StoreSwitch'), isFalse);
    expect(t.takeException(), isNull);
  });
  testWidgets('新增门店无创建资格时提示后端返回的限制', (t) async {
    await open(t);
    await t.tap(find.text('新增门店'));
    await t.pumpAndSettle();
    expect(find.text('创建门店'), findsNothing);
    expect(find.text('当前账号仅支持一家门店'), findsWidgets);
    expect(navTracker.has('StoreAdd'), isFalse);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('延迟加载、失败重试，成功显示零营业额', (t) async {
    api.gate = Completer<void>();
    await open(t, settle: false);
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    api.error = const AppError('读取失败', type: AppErrorType.server);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(find.textContaining('徐汇店'), findsNothing);
    api.error = null;
    (api.directory['items'] as List).first['revenue'] = 0;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('当前门店 · 今日 ¥0.00'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
  testWidgets('无门店显示空状态', (t) async {
    api.directory['items'] = [];
    await open(t);
    expect(find.text('当前账号还没有门店'), findsOneWidget);
    expect(find.textContaining('徐汇店'), findsNothing);
  });
  testWidgets('登录失效显示登录引导，不展示示例门店', (t) async {
    api.error = const AppError('请先登录', type: AppErrorType.auth);
    await open(t);
    expect(find.textContaining('徐汇店'), findsNothing);
    expect(find.text('重新登录'), findsOneWidget);
    await t.tap(find.text('重新登录'));
    await t.pumpAndSettle();
    expect(find.byType(StoreSwitchLiveSheet), findsNothing);
    expect(t.takeException(), isNull);
  });
}
