import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/registration_draft.dart';
import 'package:autocare_merchant/mock/store_state.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class _StoresApi extends MemberFakeApi {
  @override
  Future<Map<String, dynamic>> stores() async => {
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
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = _StoresApi();
    MockStores.reset();
    RegistrationDraft.clear();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    MockStores.reset();
    navTracker.stack.clear();
  });

  Future<void> open(WidgetTester t, String route) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
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

  testWidgets('新增门店：名称和地址必填，创建后回到切换门店弹层并出现演示门店', (t) async {
    await open(t, 'StoreSwitch');
    await t.tap(find.text('新增门店'));
    await t.pumpAndSettle();
    expect(find.text('创建门店'), findsOneWidget);
    expect(find.text('创建后仍停留在当前门店 · 专业版最多 3 家'), findsOneWidget);
    // 所有输入框没值时有占位文字
    expect(find.text('如：驰光汽车美容 · 浦东店'), findsOneWidget);
    expect(find.text('请输入门店电话'), findsOneWidget);
    expect(find.text('请选择或输入门店地址'), findsOneWidget);
    await t.tap(find.text('创建门店'));
    await t.pump();
    expect(find.text('请输入门店名称'), findsWidgets);
    await t.pump(const Duration(seconds: 4));
    await t.enterText(find.byType(TextField).at(0), '驰光汽车美容 · 浦东店');
    await t.tap(find.text('创建门店'));
    await t.pump();
    expect(find.text('请选择或输入门店地址'), findsWidgets);
    await t.pump(const Duration(seconds: 4));
    await t.enterText(find.byType(TextField).at(2), '上海市浦东新区世纪大道 1 号');
    await t.tap(find.text('创建门店'));
    await t.pumpAndSettle();
    expect(MockStores.extra.value, ['驰光汽车美容 · 浦东店']);
    expect(find.text('切换门店'), findsOneWidget);
    expect(find.text('驰光汽车美容 · 浦东店'), findsOneWidget);
    expect(find.text('演示门店 · 仅本机可见'), findsOneWidget);
    expect(find.text('专业版最多 3 家，还可添加 1 家'), findsOneWidget);
    await t.pump(const Duration(seconds: 4));
  });

  testWidgets('演示门店不能切换过去，明确提示', (t) async {
    MockStores.extra.value = ['二店'];
    await open(t, 'StoreSwitch');
    await t.tap(find.text('二店'));
    await t.pump();
    expect(find.text('演示门店，跨门店切换暂未开通'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('达到套餐上限后不能再新增，并说明原因', (t) async {
    MockStores.extra.value = ['二店', '三店'];
    await open(t, 'StoreSwitch');
    expect(find.text('专业版最多 3 家，已达上限'), findsOneWidget);
    await t.tap(find.text('新增门店'));
    await t.pump();
    expect(find.text('专业版最多 3 家门店，已达上限'), findsWidgets);
    expect(find.text('创建门店'), findsNothing);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('新增门店左上角 ✕ 返回，不创建', (t) async {
    await open(t, 'StoreSwitch');
    await t.tap(find.text('新增门店'));
    await t.pumpAndSettle();
    await t.tap(find.byType(GestureDetector).at(1));
    await t.pumpAndSettle();
    expect(MockStores.extra.value, isEmpty);
  });

  test('创建门店的校验：同名、电话格式、数量上限（含真实门店）', () {
    expect(MockStores.create(name: ' ', phone: '', address: 'x'), '请输入门店名称');
    expect(MockStores.create(name: 'A', phone: '', address: ''), '请选择或输入门店地址');
    expect(
      MockStores.create(name: 'A', phone: 'abc', address: 'x'),
      '请输入正确的门店电话',
    );
    expect(
      MockStores.create(name: 'A', phone: '021-12345678', address: 'x'),
      isNull,
    );
    expect(MockStores.create(name: 'A', phone: '', address: 'x'), '已有同名门店');
    expect(MockStores.create(name: 'B', phone: '', address: 'x'), isNull);
    expect(
      MockStores.create(name: 'C', phone: '', address: 'x'),
      '专业版最多 3 家门店',
    );
  });

  testWidgets('编辑门店信息：有“营业时间与工位”入口，点击进入营业时间与工位', (t) async {
    await open(t, 'StoreEdit');
    expect(find.text('编辑门店信息'), findsOneWidget);
    expect(find.text('营业时间与工位'), findsOneWidget);
    await t.tap(find.text('营业时间与工位'));
    await t.pump();
    expect(navTracker.has('BusinessHours'), isTrue);
  });
}
