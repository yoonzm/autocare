import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/backend/store_flow.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class MultiStoreApi extends MemberFakeApi {
  String current = 'first';
  Map<String, dynamic>? profileOverride;
  @override
  Future<Map<String, dynamic>> subscriptionCatalog() async => {
    'plans': [],
    'subscription': {},
    'revision': 'fixture',
  };
  Object? failure;
  Completer<void>? gate;
  final calls = <Map<String, dynamic>>[];
  final storeRows = <Map<String, dynamic>>[
    {'id': 'first', 'name': '原店', 'status_label': '当前门店', 'revenue': 0},
  ];
  @override
  Future<Map<String, dynamic>> getStore() async =>
      profileOverride ??
      {
        'id': current,
        'name': current == 'first' ? '原店' : '第二家',
        'phone': '021-12345678',
        'account_phone': '13900000001',
        'address': '原地址',
      };
  @override
  Future<Map<String, dynamic>> stores() async => {
    'current_store_id': current,
    'items': storeRows,
    'can_add': storeRows.length < 3,
    'used': storeRows.length,
    'store_limit': 3,
    'add_hint': storeRows.length < 3
        ? '专业版最多 3 家，还可添加 ${3 - storeRows.length} 家'
        : '专业版最多 3 家，已达上限',
  };
  @override
  Future<Map<String, dynamic>> storeMutation(
    String action,
    Map<String, dynamic> values, {
    String? requestId,
  }) async {
    calls.add({'action': action, ...values, 'requestId': requestId});
    await gate?.future;
    if (failure != null) throw failure!;
    if (action == 'create') {
      storeRows.add({
        'id': 'second',
        'name': values['name'],
        'revenue': 0,
        'status_label': '营业额',
      });
    }
    if (action == 'switch') current = '${values['id']}';
    return {'id': action == 'create' ? 'second' : values['id']};
  }
}

void main() {
  late MerchantApi original;
  late MultiStoreApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = MultiStoreApi();
    StoreContext.bind('first');
    StoreFlow.clear();
    RegistrationDraft.clear();
    navTracker.stack.clear();
    storeProfile.apply({
      'id': 'first',
      'name': '原店',
      'phone': '021-12345678',
      'address': '原地址',
    });
  });
  tearDown(() {
    merchantApi = original;
    StoreContext.bind(null);
    StoreFlow.clear();
    navTracker.stack.clear();
  });
  Future<void> open(WidgetTester t, [String route = 'StoreSwitch']) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openRoute(context, route),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
  }

  Future<void> fill(WidgetTester t) async {
    await t.enterText(find.byType(TextFormField).at(0), '第二家');
    await t.enterText(find.byType(TextFormField).at(2), '第二家地址');
  }

  testWidgets('真实创建后返回门店列表，仍停留原店；按钮等待后端且防连点', (t) async {
    await open(t);
    await t.tap(find.text('新增门店'));
    await t.pumpAndSettle();
    expect(find.textContaining('还可添加 2 家'), findsOneWidget);
    await fill(t);
    api.gate = Completer<void>();
    await t.tap(find.text('创建门店'));
    await t.pump();
    expect(find.text('提交中…'), findsOneWidget);
    await t.tap(find.text('提交中…'), warnIfMissed: false);
    await t.pump();
    expect(api.calls.length, 1);
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(api.calls.single['name'], '第二家');
    expect(find.text('第二家'), findsOneWidget);
    expect(StoreContext.id, 'first');
    expect(api.current, 'first');
    expect(find.textContaining('演示门店'), findsNothing);
  });
  testWidgets('失败保留表单，相同内容重试使用相同请求编号', (t) async {
    await open(t, 'StoreAdd');
    await fill(t);
    api.failure = const AppError('网络不太给力', type: AppErrorType.network);
    await t.tap(find.text('创建门店'));
    await t.pumpAndSettle();
    expect(find.text('第二家'), findsOneWidget);
    api.failure = null;
    await t.tap(find.text('创建门店'));
    await t.pumpAndSettle();
    expect(api.calls.length, 2);
    expect(api.calls.first['requestId'], api.calls.last['requestId']);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('名额由接口决定，满额不进入新增页', (t) async {
    api.storeRows.addAll([
      {'id': 'second', 'name': '第二家', 'revenue': 0, 'status_label': '营业额'},
      {'id': 'third', 'name': '第三家', 'revenue': 0, 'status_label': '营业额'},
    ]);
    await open(t);
    await t.ensureVisible(find.text('新增门店'));
    await t.tap(find.text('新增门店'));
    await t.pumpAndSettle();
    expect(find.text('创建门店'), findsNothing);
    expect(api.calls, isEmpty);
    await t.pump(const Duration(seconds: 9));
  });
  testWidgets('切换真实门店后重建首页，清空旧会员及表单状态', (t) async {
    api.storeRows.add({
      'id': 'second',
      'name': '第二家',
      'revenue': 0,
      'status_label': '营业额',
    });
    MemberFlow.current = {'id': 'old-member'};
    await open(t);
    await t.tap(find.text('第二家'));
    await t.pumpAndSettle();
    expect(api.current, 'second');
    expect(StoreContext.id, 'second');
    expect(MemberFlow.current, isNull);
    expect(CatalogDraft.current, isNull);
    expect(find.text('第二家'), findsWidgets);
    expect(find.text('切换门店'), findsNothing);
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
  });

  testWidgets('存在编辑页面时切店先确认，取消不调用切换接口', (t) async {
    api.storeRows.add({
      'id': 'second',
      'name': '第二家',
      'revenue': 0,
      'status_label': '门店',
    });
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        onGenerateRoute: (_) => MaterialPageRoute(
          settings: const RouteSettings(name: 'StoreEdit'),
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => openRoute(context, 'StoreSwitch'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('第二家'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('切换门店将放弃当前未保存的表单，是否继续？'), findsOneWidget);
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(api.calls, isEmpty);
    expect(StoreContext.id, 'first');
  });

  testWidgets('套餐页面显示账号真实套餐、有效期和门店用量', (t) async {
    api.profileOverride = {
      'id': 'first',
      'name': '原店',
      'phone': '021-12345678',
      'trial_ends_at': '2030-01-01T00:00:00Z',
      'store_count': 2,
      'subscription': {'name': '账号专业版', 'store_limit': 3},
    };
    await open(t, 'Subscription');
    expect(find.text('账号专业版'), findsOneWidget);
    expect(find.text('2 / 3', findRichText: true), findsOneWidget);
    expect(find.text('天后到期 · 2030.01.01'), findsOneWidget);
    expect(find.text('365'), findsNothing);
    expect(find.textContaining('3,990'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('编辑回填当前店铺资料，保存带门店 ID，与登录手机号分离', (t) async {
    await open(t, 'StoreEdit');
    expect(
      t.widget<TextFormField>(find.byType(TextFormField).at(0)).initialValue,
      '原店',
    );
    await t.enterText(find.byType(TextFormField).at(0), '新名称');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.calls.single['action'], 'update');
    expect(api.calls.single['id'], 'first');
    expect(api.calls.single['phone'], '021-12345678');
  });
}
