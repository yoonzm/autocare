import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/service_store.dart';

class PendingApi extends MerchantApi {
  final pending = Completer<Map<String, dynamic>>();
  @override
  Future<Map<String, dynamic>> performRequest(
    Map<String, dynamic> body,
    Duration timeout,
    String? requestId,
  ) => pending.future;
}

class CacheApi extends MerchantApi {
  final old = Completer<List<Map<String, dynamic>>>();
  int count = 0;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) => count++ == 0
      ? old.future
      : Future.value([
          {'id': 'new-store-service'},
        ]);
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    StoreContext.bind('old');
    ServiceStore.clear();
  });
  tearDown(() {
    merchantApi = original;
    StoreContext.bind(null);
    ServiceStore.clear();
  });
  test('切店前发出的请求，即使 HTTP 成功也不能回填', () async {
    final api = PendingApi();
    final pending = api.invoke({'action': 'list', 'kind': 'members'});
    final expectation = expectLater(pending, throwsA(isA<AppError>()));
    StoreContext.bind('new');
    api.pending.complete({
      'items': [
        {'id': 'old-member'},
      ],
    });
    await expectation;
  });
  test('旧店服务缓存迟到不能覆盖新店，也不能清除新店进行中的请求', () async {
    final api = CacheApi();
    merchantApi = api;
    final old = ServiceStore.load();
    StoreContext.bind('new');
    ServiceStore.clear();
    await ServiceStore.load();
    api.old.complete([
      {'id': 'old-store-service'},
    ]);
    await old;
    expect(ServiceStore.items!.single['id'], 'new-store-service');
  });
}
