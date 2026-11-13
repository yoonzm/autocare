import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_context.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class _Api extends MemberFakeApi {
  final calls = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> getStore() async => {
    'id': 'first',
    'name': '原店',
    'phone': '021-12345678',
    'address': '原地址',
  };
  @override
  Future<Map<String, dynamic>> storeMutation(
    String action,
    Map<String, dynamic> values, {
    String? requestId,
  }) async {
    calls.add({'action': action, ...values, 'requestId': requestId});
    return {'id': values['id']};
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() async {
    original = merchantApi;
    merchantApi = api = _Api();
    StoreContext.bind('first');
    storeProfile.apply(await api.getStore());
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    StoreContext.bind(null);
    storeProfile.clear();
    navTracker.stack.clear();
  });
  Future<void> open(WidgetTester t, String route) async {
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
