import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/hold_store.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/main.dart';
import 'package:autocare_merchant/pages/shared/home_page.dart';
import 'package:autocare_merchant/pages/shared/shell.dart';

import 'holds_test.dart' show hold;
import 'members_test.dart' show MemberFakeApi, phone;

class RestartApi extends MemberFakeApi {
  Completer<Map<String, dynamic>> profile = Completer();
  final requests = <String>[];
  final storeIds = <String?>[];
  void record(String action) {
    requests.add(action);
    storeIds.add(StoreContext.id);
  }

  @override
  Future<Map<String, dynamic>> getStore() => profile.future;
  @override
  Future<Map<String, dynamic>> homeStats() async {
    record('home_stats');
    return {...await super.homeStats(), 'revenue': 88.88};
  }

  @override
  Future<List<Map<String, dynamic>>> holds() async {
    record('holds');
    return [hold(id: 'second-hold', name: '第二店会员')];
  }

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    record('list:$kind');
    return super.list(kind);
  }

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    record('${body['action']}');
    return {'items': <Map<String, dynamic>>[]};
  }
}

class DelayedHoldsApi extends MemberFakeApi {
  final first = Completer<List<Map<String, dynamic>>>();
  final next = Completer<List<Map<String, dynamic>>>();
  int calls = 0;
  @override
  Future<List<Map<String, dynamic>>> holds() =>
      calls++ == 0 ? first.future : next.future;
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    storeProfile.clear();
    StoreContext.bind(null);
    tabIndex.value = 0;
  });
  tearDown(() {
    storeProfile.clear();
    StoreContext.bind(null);
    merchantApi = original;
    ServiceStore.clear();
  });
  const selected = {'id': 'second', 'name': '第二家店', 'phone': '021-12345678'};

  testWidgets('切到第二店后冷启动：门店恢复之前不发业务请求，恢复后统计和挂单正常显示', (t) async {
    phone(t);
    final api = RestartApi();
    merchantApi = api;
    await t.pumpWidget(const QimeiApp());
    await t.pump(const Duration(milliseconds: 301));
    expect(find.byType(AppSkeleton), findsWidgets);
    expect(find.byType(HomePage), findsNothing);
    expect(api.requests, isEmpty);
    expect(HoldStore.loading, isFalse);
    api.profile.complete(selected);
    await t.pumpAndSettle();
    expect(StoreContext.id, 'second');
    expect(find.text('第二家店'), findsOneWidget);
    expect(find.text('88.88'), findsOneWidget);
    expect(find.text('第二店会员'), findsOneWidget);
    expect(api.requests, containsAll(['home_stats', 'holds']));
    expect(api.storeIds, everyElement('second'));
    expect(HoldStore.loading, isFalse);
    expect(HoldStore.error, isNull);
    expect(HoldStore.holds!.single['id'], 'second-hold');
    expect(find.text('门店已切换，请重新操作'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('启动恢复失败可重试，失败期间不挂起业务请求，也不回退首店', (t) async {
    phone(t);
    final api = RestartApi();
    merchantApi = api;
    await t.pumpWidget(const QimeiApp());
    api.profile.completeError(
      const AppError('恢复门店失败', type: AppErrorType.network),
    );
    await t.pumpAndSettle();
    expect(find.text('重试'), findsOneWidget);
    expect(api.requests, isEmpty);
    expect(HoldStore.loading, isFalse);
    api.profile = Completer()..complete(selected);
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('88.88'), findsOneWidget);
    expect(api.storeIds, everyElement('second'));
    expect(HoldStore.loading, isFalse);
    expect(t.takeException(), isNull);
  });

  test('挂单在门店标识变化后结束：丢弃旧结果，自动读取新店并结束加载', () async {
    final api = DelayedHoldsApi();
    merchantApi = api;
    final previous = HoldStore.load();
    StoreContext.bind('second');
    api.first.complete([
      {'id': 'stale-first-store'},
    ]);
    await previous;
    expect(api.calls, 2);
    expect(HoldStore.holds, isNull);
    api.next.complete([
      {'id': 'second-store'},
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(HoldStore.holds!.single['id'], 'second-store');
    expect(HoldStore.loading, isFalse);
  });

  test('旧请求结束不能释放切店后新请求的加载锁，也不能覆盖新请求', () async {
    final api = DelayedHoldsApi();
    merchantApi = api;
    StoreContext.bind('first');
    final previous = HoldStore.load();
    StoreContext.bind('second');
    HoldStore.reset();
    final current = HoldStore.load();
    api.first.complete([
      {'id': 'first-store'},
    ]);
    await previous;
    expect(HoldStore.loading, isTrue);
    expect(HoldStore.holds, isNull);
    api.next.complete([
      {'id': 'second-store'},
    ]);
    await current;
    expect(HoldStore.loading, isFalse);
    expect(HoldStore.holds!.single['id'], 'second-store');
  });

  test('挂单重置即使没有改变 epoch，也不能被迟到的旧请求回填', () async {
    final api = DelayedHoldsApi();
    merchantApi = api;
    final previous = HoldStore.load();
    HoldStore.reset();
    api.first.complete([
      {'id': 'stale'},
    ]);
    await previous;
    expect(HoldStore.loading, isFalse);
    expect(HoldStore.holds, isNull);
    expect(api.calls, 1);
  });

  test('门店恢复后的挂单请求失败会结束加载并保留可重试错误', () async {
    final api = DelayedHoldsApi();
    merchantApi = api;
    final previous = HoldStore.load();
    StoreContext.bind('second');
    api.first.completeError(const AppError('过期请求', type: AppErrorType.network));
    await previous;
    api.next.completeError(
      const AppError('当前门店网络异常', type: AppErrorType.network),
    );
    await Future<void>.delayed(Duration.zero);
    expect(HoldStore.loading, isFalse);
    expect(HoldStore.error!.message, '当前门店网络异常');
  });
}
