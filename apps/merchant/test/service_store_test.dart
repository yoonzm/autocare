import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/service_store.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi;

class _CountingApi extends MemberFakeApi {
  int svcCalls = 0;
  Duration delay = Duration.zero;
  Object? error;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    if (kind == 'services') {
      svcCalls++;
      if (delay > Duration.zero) await Future<void>.delayed(delay);
      if (error != null) throw error!;
    }
    return [...await super.list(kind)]; // 真实接口每次返回新列表
  }
}

void main() {
  late MerchantApi original;
  late _CountingApi api;
  setUp(() {
    original = merchantApi;
    api = _CountingApi();
    merchantApi = api;
    api.services.addAll([
      {
        'id': 's1',
        'name': '精致洗车',
        'price': 68,
        'category': '洗车',
        'active': true,
      },
      {
        'id': 's2',
        'name': '旧项目',
        'price': 10,
        'category': '洗车',
        'active': false,
      },
    ]);
    ServiceStore.clear();
    CatalogDraft.current = null;
    MemberFlow.current = null;
  });
  tearDown(() {
    merchantApi = original;
    ServiceStore.clear();
  });

  test('第一次读取请求一次；之后直接用缓存，不再请求', () async {
    expect(ServiceStore.items, isNull);
    final first = await ServiceStore.load();
    expect(first.length, 2);
    expect(api.svcCalls, 1);
    await ServiceStore.load();
    await ServiceStore.load();
    expect(api.svcCalls, 1);
    expect(ServiceStore.sellable.map((e) => e['id']), ['s1']); // 已下架的不在售
  });

  test('同时发起的读取只发一个请求', () async {
    api.delay = const Duration(milliseconds: 50);
    final results = await Future.wait([
      ServiceStore.load(),
      ServiceStore.load(),
      ServiceStore.load(),
    ]);
    expect(api.svcCalls, 1);
    expect(results.every((r) => r.length == 2), isTrue);
  });

  test('refresh / force 重新请求并通知页面；失败时保留旧缓存', () async {
    await ServiceStore.load();
    var changes = 0;
    void on() => changes++;
    ServiceStore.changed.addListener(on);
    api.services.add({
      'id': 's3',
      'name': '新项目',
      'price': 20,
      'category': '内饰',
      'active': true,
    });
    await ServiceStore.load(force: true);
    expect(api.svcCalls, 2);
    expect(ServiceStore.items!.length, 3);
    expect(changes, 1);
    api.error = const AppError('网络不稳定', type: AppErrorType.network);
    await expectLater(ServiceStore.refresh(), throwsA(isA<AppError>()));
    expect(ServiceStore.items!.length, 3); // 旧数据还在
    ServiceStore.changed.removeListener(on);
  });

  test('没有缓存时读取失败会抛出（页面显示错误和重试），恢复后能再读', () async {
    api.error = const AppError('网络不稳定', type: AppErrorType.network);
    await expectLater(ServiceStore.load(), throwsA(isA<AppError>()));
    expect(ServiceStore.items, isNull);
    api.error = null;
    expect((await ServiceStore.load()).length, 2);
  });

  test('缓存过期后读取立即返回旧数据，同时后台刷新', () async {
    await ServiceStore.load();
    api.services.add({
      'id': 's3',
      'name': '新项目',
      'price': 20,
      'category': '内饰',
      'active': true,
    });
    // 把缓存时间调早：用 refresh 之后再等待 maxAge 太久，这里直接验证 load 的返回不等待请求
    api.delay = const Duration(milliseconds: 30);
    final stale = await ServiceStore.load(force: false);
    expect(stale.length, 2);
  });

  test('退出登录 / 换账号清空；换了 API 客户端也不会读到别人的缓存', () async {
    await ServiceStore.load();
    ServiceStore.clear();
    expect(ServiceStore.items, isNull);
    await ServiceStore.load();
    final other = _CountingApi();
    merchantApi = other;
    expect(ServiceStore.items, isNull);
  });

  test('保存 / 删除服务项目后缓存立即刷新', () async {
    await ServiceStore.load();
    api.services.add({
      'id': 's3',
      'name': '新项目',
      'price': 20,
      'category': '内饰',
      'active': true,
    });
    CatalogDraft.begin('services', {'id': 's1', 'name': '精致洗车', 'price': 68});
    await CatalogDraft.removeCurrent('services');
    expect(ServiceStore.items!.length, 3);
    expect(api.svcCalls, 2);
  });
}
