import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceChip, AppSegmented;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory/inventory_page.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

class _InvApi extends MemberFakeApi {
  Object? failList;
  bool allSafe = false;
  final values = <String, num>{};
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_documents') return {'items': []};
    if (body['action'] == 'inventory_list') {
      if (failList != null) throw failList!;
      return {
        'items': [
          if (!allSafe)
            {
              'id': 'p1',
              'name': '真实镀晶剂',
              'category': '镀晶',
              'unit': '瓶',
              'stock': 2,
              'safe': 5,
              'low': true,
              'cost': 68,
              'stock_value': values['p1'] ?? 100,
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
            'stock_value': values['p2'] ?? 100,
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
            'stock_value': values['p3'] ?? 100,
            'location': 'C-01',
            'sku': '',
            'expiring': false,
            'low': false,
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

  testWidgets('库存新页面都已登记：商品编辑、分类、预警、单据、详情和扫码结果', (t) async {
    for (final n in [
      'CategoryManage',
      'StockAlertSettings',
      'SupplierEdit',
      'StockDocs',
      'StockDocsOut',
      'StockInDetail',
      'StockOutDetail',
      'ScanProduct',
    ]) {
      expect(pageFor(n), isNotNull, reason: n);
    }
    // 新增 / 编辑商品是手写的真实页面（test/product_edit_test.dart）。
    expect(pageFor('ProductEdit'), isNotNull);
    for (final n in [
      'ProductPicker',
      'SupplierPicker',
      'StockVoid',
      'StockOutShort',
      'ScanProductResult',
      'ScanProductNotFound',
    ]) {
      expect(sheetRoutes.containsKey(n), isTrue, reason: n);
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
      expect(pageFor(n), isNull, reason: n);
    }
  });

  testWidgets('库存单据两个页签是同一个页面：点出库单切换，不叠新页', (t) async {
    await openRoute_(t, 'StockDocs');
    expect(find.text('库存单据'), findsWidgets);
    await t.tap(find.text('出库单'));
    await t.pumpAndSettle();
    expect(find.text('已出库'), findsOneWidget);
    expect(
      navTracker.stack.where((r) => r.settings.name == 'StockDocs').length,
      lessThanOrEqualTo(1),
    );
  });

  testWidgets('库存首页：有低于安全库存的商品才显示预警卡片', (t) async {
    phone(t);
    await t.pumpWidget(app(const InventoryPage()));
    await t.pumpAndSettle();
    expect(find.text('1 项低于安全库存'), findsOneWidget);
    expect(find.text('去补货'), findsOneWidget);
    // 一期（无盘点）设计：头部是扫码、出库、入库；库存单据在总览卡片底部；全部商品是列表末尾的链接。
    expect(find.text('出库'), findsOneWidget);
    expect(find.text('入库'), findsOneWidget);
    expect(find.text('库存单据'), findsOneWidget);
    expect(find.text('入库 / 出库记录'), findsOneWidget);
    expect(find.textContaining('查看全部商品 · 3 项'), findsOneWidget);
    expect(find.text('全部商品'), findsNothing, reason: '不再有单独的全部商品卡片');
    expect(find.text('入库 / 出库'), findsNothing, reason: '不再有并排的入口卡片');
  });

  testWidgets('库存首页：没有低于安全库存的商品时不显示预警卡片', (t) async {
    api.allSafe = true;
    phone(t);
    await t.pumpWidget(app(const InventoryPage()));
    await t.pumpAndSettle();
    expect(find.textContaining('项低于安全库存'), findsNothing);
    expect(find.text('去补货'), findsNothing);
  });

  testWidgets('库存单据：分段与状态标签用组件库，点击后选中项切换', (t) async {
    await openRoute_(t, 'StockDocs');
    expect(find.byType(AppSegmented<int>), findsOneWidget);
    bool selected(String label) => t
        .widget<AppChoiceChip>(find.widgetWithText(AppChoiceChip, label))
        .selected;
    expect(selected('全部'), isTrue);
    await t.tap(find.text('草稿'));
    await t.pumpAndSettle();
    expect(selected('草稿'), isTrue);
    expect(selected('全部'), isFalse);
    await t.tap(find.text('出库单'));
    await t.pumpAndSettle();
    expect(selected('全部'), isTrue, reason: '切换单据类型后状态回到全部');
  });

  testWidgets('库存价值构成：占比相加正好是 100%，价值为 0 的分类 0%，很小的分类至少 1%', (t) async {
    phone(t);
    api.values.addAll({'p1': 1, 'p2': 1, 'p3': 1});
    await t.pumpWidget(app(InventoryPage(key: UniqueKey())));
    await t.pumpAndSettle();
    // 三个分类里镀晶 1 份、洗护 2 份 → 33% + 67%
    expect(find.text('镀晶 33%'), findsOneWidget);
    expect(find.text('洗护 67%'), findsOneWidget);

    api.values.addAll({'p1': 0, 'p2': 1, 'p3': 0});
    await t.pumpWidget(app(InventoryPage(key: UniqueKey())));
    await t.pumpAndSettle();
    expect(find.text('镀晶 0%'), findsOneWidget);
    expect(find.text('洗护 100%'), findsOneWidget);

    api.values.addAll({'p1': 1, 'p2': 10000, 'p3': 0});
    await t.pumpWidget(app(InventoryPage(key: UniqueKey())));
    await t.pumpAndSettle();
    expect(find.text('镀晶 1%'), findsOneWidget); // 0.01% 也至少显示 1%
    expect(find.text('洗护 99%'), findsOneWidget);
  });

  testWidgets('库存总览是深色渐变卡：总值（千分位）、SKU 小标签、价值构成、库存单据入口', (t) async {
    phone(t);
    api.values.addAll({'p1': 1200, 'p2': 300, 'p3': 0});
    await t.pumpWidget(app(InventoryPage(key: UniqueKey())));
    await t.pumpAndSettle();
    expect(find.text('库存总值（元）'), findsOneWidget);
    expect(find.text('1,500'), findsOneWidget);
    expect(find.text('3 个 SKU'), findsOneWidget);
    expect(find.text('镀晶 80%'), findsOneWidget);
    expect(find.text('洗护 20%'), findsOneWidget);
    expect(find.text('库存单据'), findsOneWidget);
    expect(find.text('入库 / 出库记录'), findsOneWidget);
  });
}
