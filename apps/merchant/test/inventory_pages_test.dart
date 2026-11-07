import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class _InvApi extends MemberFakeApi {
  Object? failList;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_list') {
      if (failList != null) throw failList!;
      return {
        'items': [
          {
            'id': 'p1',
            'name': '真实镀晶剂',
            'category': '镀晶',
            'unit': '瓶',
            'stock': 2,
            'safe': 5,
            'cost': 68,
            'location': 'B-01',
            'sku': 'DJ-1',
            'expiring': false,
          },
          {
            'id': 'p2',
            'name': '真实玻璃水',
            'category': '洗护',
            'unit': '桶',
            'stock': 9,
            'safe': 3,
            'cost': 12.5,
            'location': '',
            'sku': '',
            'expiring': true,
          },
          {
            'id': 'p3',
            'name': '真实车蜡',
            'category': '洗护',
            'unit': '罐',
            'stock': 20,
            'safe': 3,
            'cost': 30,
            'location': 'C-01',
            'sku': '',
            'expiring': false,
          },
        ],
      };
    }
    return super.invoke(body, requestId: requestId);
  }
}

void main() {
  late MerchantApi original;
  late _InvApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _InvApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  Future<void> openRoute_(WidgetTester t, String route) async {
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

  testWidgets('全部商品：读真实库存，四个筛选带数量，低库存 / 临期来自库存数据，设计稿示例商品不会出现', (t) async {
    await openRoute_(t, 'ProductList');
    expect(find.text('全部商品'), findsOneWidget);
    expect(find.text('低库存 1'), findsOneWidget);
    expect(find.text('全部 3'), findsOneWidget);
    expect(find.text('临期 1'), findsOneWidget);
    expect(find.text('已停用 0'), findsOneWidget);
    expect(find.text('共 1 项低于安全库存'), findsOneWidget);
    expect(find.text('真实镀晶剂'), findsOneWidget);
    expect(find.text('镀晶 · B-01 · 参考成本 ¥68'), findsOneWidget);
    expect(find.text('2 瓶'), findsOneWidget);
    expect(find.text('隐形车衣 TPU 1.52m'), findsNothing);
    expect(find.text('248'), findsNothing);
    await t.tap(find.text('全部 3'));
    await t.pumpAndSettle();
    expect(find.text('共 3 项商品'), findsOneWidget);
    expect(find.text('真实玻璃水'), findsOneWidget);
    expect(find.text('真实车蜡'), findsOneWidget);
    await t.tap(find.text('临期 1'));
    await t.pumpAndSettle();
    expect(find.text('共 1 项 30 天内到期，先到期的排前面'), findsOneWidget);
    expect(find.text('真实玻璃水'), findsOneWidget);
    expect(find.text('真实车蜡'), findsNothing);
  });

  testWidgets('全部商品：搜索按名称 / SKU；已停用暂无数据时说明；搜索框有占位文字', (t) async {
    await openRoute_(t, 'ProductList');
    await t.tap(find.text('全部 3'));
    await t.pumpAndSettle();
    expect(
      t.widget<TextField>(find.byType(TextField)).decoration?.hintText,
      '搜索商品名称 / SKU',
    );
    await t.enterText(find.byType(TextField), 'DJ-1');
    await t.pumpAndSettle();
    expect(find.text('真实镀晶剂'), findsOneWidget);
    expect(find.text('真实车蜡'), findsNothing);
    await t.enterText(find.byType(TextField), '');
    await t.tap(find.text('已停用 0'));
    await t.pumpAndSettle();
    expect(find.text('没有已停用的商品'), findsOneWidget);
  });

  testWidgets('全部商品：读取失败时整页错误并可重试', (t) async {
    api.failList = const AppError.network();
    await openRoute_(t, 'ProductList');
    expect(find.text('重试'), findsOneWidget);
    api.failList = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('真实镀晶剂'), findsOneWidget);
  });

  testWidgets('库存新页面都已登记：商品编辑、分类、预警、单据、详情、盘点和扫码结果', (t) async {
    for (final n in [
      'ProductEdit',
      'ProductEditExist',
      'CategoryManage',
      'StockAlertSettings',
      'SupplierEdit',
      'StockDocs',
      'StockDocsOut',
      'StockDocsCheck',
      'StockInDetail',
      'StockOutDetail',
      'StockCheckNew',
      'StockCheckResult',
      'ScanProduct',
    ]) {
      expect(genRoutes.containsKey(n), isTrue, reason: n);
    }
    for (final n in [
      'ProductPicker',
      'SupplierPicker',
      'StockVoid',
      'StockOutShort',
      'StockCheckInput',
      'ScanProductResult',
      'ScanProductNotFound',
    ]) {
      expect(genSheets.containsKey(n), isTrue, reason: n);
    }
    // 设计稿里的状态页不单独成页
    for (final n in [
      'ProductListAll',
      'ProductListExp',
      'ProductListOff',
      'StockCheckPending',
      'StockCheckDiff',
      'StockOutReturn',
      'StockOutScrap',
    ]) {
      expect(genRoutes.containsKey(n), isFalse, reason: n);
    }
  });

  testWidgets('新增商品保存：后端还不支持，明确提示，不跳到商品详情冒充成功', (t) async {
    await openRoute_(t, 'ProductEdit');
    await t.tap(find.text('保存').first);
    await t.pump();
    expect(find.textContaining('商品保存暂未接通'), findsWidgets);
    expect(navTracker.has('ProductDetail'), isFalse);
    await t.pump(const Duration(seconds: 6));
  });

  testWidgets('库存单据三个页签是同一个页面：点出库单 / 盘点单切换，不叠新页', (t) async {
    await openRoute_(t, 'StockDocs');
    expect(find.text('库存单据'), findsWidgets);
    await t.tap(find.text('出库单'));
    await t.pumpAndSettle();
    await t.tap(find.text('盘点单'));
    await t.pumpAndSettle();
    expect(
      navTracker.stack.where((r) => r.settings.name == 'StockDocs').length,
      lessThanOrEqualTo(1),
    );
  });
}
