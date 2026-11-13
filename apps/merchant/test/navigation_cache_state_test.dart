import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/navigation/catalog_route.dart';
import 'package:autocare_merchant/pages/account/login_page.dart';
import 'package:autocare_merchant/pages/inventory/inventory_pickers.dart';
import 'package:autocare_merchant/pages/catalog/card_tiers_live_page.dart';
import 'package:autocare_merchant/pages/catalog/card_packages_live_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi, phone;
import 'packages_test.dart' show PkgFakeApi;

class _CacheApi extends MemberFakeApi {
  final pending = <Completer<List<Map<String, dynamic>>>>[];
  int reads = 0;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) =>
      pending[reads++].future;
}

class _ProfileApi extends MemberFakeApi {
  final pending = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> getStore() => pending.future;
}

class _LoginApi extends MemberFakeApi {
  bool signedIn = false;
  Object? profileError = const AppError.timeout();
  int businessReads = 0;
  @override
  bool get hasSession => signedIn;
  @override
  Future<void> loginPassword(String phone, String password) async =>
      signedIn = true;
  @override
  Future<Map<String, dynamic>> getStore() async {
    if (profileError != null) throw profileError!;
    return {'id': 'signed-store', 'name': '登录门店'};
  }

  @override
  Future<Map<String, dynamic>> homeStats() {
    businessReads++;
    return super.homeStats();
  }
}

class _CatalogApi extends PkgFakeApi {
  @override
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async =>
      (autoUpgrade: true, balanceRefundable: false);
}

class _SupplierApi extends MemberFakeApi {
  final response = Completer<Map<String, dynamic>>();
  final requests = <Map<String, dynamic>>[];
  final ids = <String?>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) {
    requests.add(body);
    ids.add(requestId);
    return response.future;
  }
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    storeProfile.clear();
    navTracker.stack.clear();
  });
  tearDown(() {
    storeProfile.clear();
    merchantApi = original;
    navTracker.stack.clear();
  });

  test('服务缓存是独立的深只读快照', () async {
    final api = _CacheApi()..pending.add(Completer());
    merchantApi = api;
    final raw = {
      'id': 's',
      'materials': [
        {'quantity': 1},
      ],
    };
    final read = ServiceStore.load();
    api.pending.single.complete([raw]);
    final rows = await read;
    (raw['materials'] as List).first['quantity'] = 9;
    expect((rows.single['materials'] as List).first['quantity'], 1);
    expect(() => rows.clear(), throwsUnsupportedError);
    expect(() => rows.single['id'] = 'changed', throwsUnsupportedError);
    expect(
      () => (rows.single['materials'] as List).first['quantity'] = 2,
      throwsUnsupportedError,
    );
  });

  for (final changeOwner in [false, true]) {
    test('旧服务请求不能回填或释放新请求：${changeOwner ? '更换API' : '同API清空'}', () async {
      final first = _CacheApi()..pending.add(Completer());
      merchantApi = first;
      final oldRead = ServiceStore.load();
      final next = changeOwner ? _CacheApi() : first;
      next.pending.add(Completer());
      if (changeOwner) {
        merchantApi = next;
      } else {
        ServiceStore.clear();
      }
      final current = ServiceStore.load();
      first.pending.first.complete([
        {'id': 'old'},
      ]);
      await oldRead;
      expect(ServiceStore.items, isNull);
      expect(identical(ServiceStore.load(), current), isTrue);
      next.pending.last.complete([
        {'id': 'new'},
      ]);
      await current;
      expect(ServiceStore.items!.single['id'], 'new');
      expect(next.reads, changeOwner ? 1 : 2);
    });
  }

  test('门店epoch变化自动使服务缓存失效，无需调用者先清空', () async {
    final api = _CacheApi()..pending.add(Completer());
    merchantApi = api;
    final old = ServiceStore.load();
    api.pending.single.complete([
      {'id': 'old'},
    ]);
    await old;
    StoreContext.bind('another-store');
    expect(ServiceStore.items, isNull);
  });

  test('门店缓存清空或被新资料替代后，旧读取不能复活或覆盖', () async {
    final api = _ProfileApi();
    merchantApi = api;
    final old = storeProfile.load();
    storeProfile.clear();
    storeProfile.apply({'id': 'new-store', 'name': '新资料'});
    api.pending.complete({'id': 'old-store', 'name': '旧资料'});
    await old;
    expect(storeProfile.name, '新资料');
    expect(StoreContext.id, 'new-store');
  });

  testWidgets('卡种与次卡复用同一路由，返回时只切换该实例的页签', (t) async {
    phone(t);
    merchantApi = _CatalogApi();
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () => openRoute(ctx, 'CardTiers'),
              child: const Text('目录'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('目录'));
    await t.pumpAndSettle();
    final route = navTracker.stack.whereType<CatalogRoute>().single;
    expect(route.selected, CatalogTab.tiers);
    openRoute(t.element(find.byType(CardTiersLivePage)), 'CardPackages');
    await t.pumpAndSettle();
    expect(route.selected, CatalogTab.packages);
    expect(navTracker.stack.whereType<CatalogRoute>(), hasLength(1));
    final ctx = t.element(find.byType(CardPackagesLivePage));
    Navigator.of(ctx).push(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          body: TextButton(
            onPressed: () => openRoute(ctx, 'CardTiers'),
            child: const Text('返回卡种'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('返回卡种'));
    await t.pumpAndSettle();
    expect(navTracker.stack.last, same(route));
    expect(route.selected, CatalogTab.tiers);
  });

  testWidgets('登录成功但门店恢复失败时先重试资料，不向业务页发请求', (t) async {
    phone(t);
    final api = _LoginApi();
    merchantApi = api;
    await t.pumpWidget(const MaterialApp(home: LoginPage(initialTab: 1)));
    await t.enterText(find.byType(TextField).first, '13911112222');
    await t.enterText(find.byType(TextField).last, 'password123');
    await t.tap(find.text('登录'));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsOneWidget);
    expect(api.businessReads, 0);
    api.profileError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(storeProfile.name, '登录门店');
    expect(api.businessReads, greaterThan(0));
    expect(find.text('请求超时'), findsNothing);
  });

  testWidgets('供应商保存锁属于表单实例，失败显示错误并保留输入', (t) async {
    phone(t);
    final api = _SupplierApi();
    merchantApi = api;
    await t.pumpWidget(const MaterialApp(home: SupplierEditPage()));
    await t.enterText(find.byType(TextField).first, '供应商一');
    await t.pump();
    await t.tap(find.text('保存'));
    await t.pump();
    await t.tap(find.text('保存'), warnIfMissed: false);
    expect(api.requests, hasLength(1));
    await t.pumpWidget(
      const MaterialApp(home: SupplierEditPage(key: ValueKey('second'))),
    );
    await t.enterText(find.byType(TextField).first, '供应商二');
    await t.pump();
    await t.tap(find.text('保存'));
    await t.pump();
    expect(api.requests, hasLength(2));
    expect(api.requests[0]['payload']['name'], '供应商一');
    expect(api.requests[1]['payload']['name'], '供应商二');
    expect(
      api.requests[0]['payload']['id'],
      isNot(api.requests[1]['payload']['id']),
    );
    api.response.completeError(const AppError.timeout());
    await t.pumpAndSettle();
    expect(find.text('供应商二'), findsOneWidget);
    expect(find.textContaining('请求超时'), findsWidgets);
    expect(t.takeException(), isNull);
  });
}
