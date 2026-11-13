import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/catalog/services_page.dart';
import 'package:autocare_merchant/pages/catalog/card_packages_live_page.dart';
import 'package:autocare_merchant/pages/catalog/card_tiers_live_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'packages_test.dart' show PkgFakeApi;

class _PendingPackages extends PkgFakeApi {
  final response = Completer<List<Map<String, dynamic>>>();
  @override
  Future<List<Map<String, dynamic>>> list(String kind) => response.future;
}

void main() {
  late MerchantApi original;
  setUp(() => original = merchantApi);
  tearDown(() => merchantApi = original);

  testWidgets('服务、卡种与套餐未登录时引导登录，不展示示例数据或空白加载', (t) async {
    merchantApi = MerchantApi();
    for (final page in const [
      ServicesPage(),
      CardTiersLivePage(),
      CardPackagesLivePage(),
    ]) {
      await t.pumpWidget(MaterialApp(home: page));
      await t.pumpAndSettle();
      expect(find.text('重新登录'), findsOneWidget);
      expect(find.text('全车镀晶 · 9H 陶瓷'), findsNothing);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('套餐列表销毁后取消延迟骨架，不处理晚到响应', (t) async {
    final api = _PendingPackages();
    merchantApi = api;
    await t.pumpWidget(const MaterialApp(home: CardPackagesLivePage()));
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    api.response.complete([]);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
}
