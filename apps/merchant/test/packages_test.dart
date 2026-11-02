import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/package_calc.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/card_packages_live_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PkgFakeApi extends MerchantApi {
  final packages = <Map<String, dynamic>>[];
  final services = <Map<String, dynamic>>[
    {'id': 's1', 'name': '精致洗车', 'price': 68, 'category': '洗车', 'active': true},
    {'id': 's2', 'name': '空调杀菌', 'price': 98, 'category': '养护', 'active': true},
    {
      'id': 's3',
      'name': '已停用项目',
      'price': 10,
      'category': '洗车',
      'active': false,
    },
  ];
  final saved = <Map<String, dynamic>>[];
  final deleted = <String>[];
  Object? listError;
  Duration listDelay = Duration.zero;

  @override
  bool get hasSession => true;

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    if (listDelay > Duration.zero) await Future<void>.delayed(listDelay);
    if (listError != null) throw listError!;
    return List<Map<String, dynamic>>.from(
      kind == 'services' ? services : packages,
    );
  }

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    saved.add({'kind': kind, ...values});
    final id = values['id']?.toString() ?? 'pkg-${packages.length + 1}';
    packages
      ..removeWhere((r) => r['id'] == id)
      ..add({'id': id, ...values});
    return {'item': packages.last};
  }

  @override
  Future<void> delete(String kind, String id) async {
    deleted.add('$kind:$id');
    packages.removeWhere((r) => r['id'] == id);
  }
}

Map<String, dynamic> pkgRow({
  String id = 'p1',
  String name = '精致洗车年卡',
  num price = 1080,
  int validity = 12,
  bool active = true,
  List<Map<String, dynamic>>? items,
}) => {
  'id': id,
  'name': name,
  'price': price,
  'validity_months': validity,
  'purchase_limit': 2,
  'vehicle_scope': '全部车型',
  'show_in_mini': true,
  'active': active,
  'description': '仅限精致洗车',
  'items':
      items ??
      [
        {
          'service_id': 's1',
          'count': 20,
          'position': 0,
          'service': {'name': '精致洗车', 'price': 68, 'active': true},
        },
      ],
};

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(390 * 3, 900 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

Future<void> toastGone(WidgetTester t) async {
  for (var i = 0; i < 5; i++) {
    await t.pump(const Duration(seconds: 1));
  }
}

Widget app(Widget home) =>
    MaterialApp(navigatorObservers: [navTracker], home: home);

void main() {
  late MerchantApi original;
  late PkgFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = PkgFakeApi();
    merchantApi = fake;
    CatalogDraft.current = null;
    CatalogCounts.cards = null;
    CatalogCounts.packages = null;
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    CatalogDraft.current = null;
    navTracker.stack.clear();
  });

  group('计算与草稿', () {
    test('列表行：次数 / 有效期 / 原价 / 划线价', () {
      final info = PackageRowInfo(pkgRow());
      expect(info.subtitle, '20 次 · 12 个月有效');
      expect(info.priceText, '¥1,080');
      expect(info.originalText, '¥1,360');
      expect(info.showOriginal, isTrue);
      expect(PackageRowInfo(pkgRow(validity: 0)).validityText, '永久有效');
      expect(PackageRowInfo(pkgRow(price: 1360)).showOriginal, isFalse);
      expect(PackageRowInfo(pkgRow(active: false)).active, isFalse);
    });

    test('编辑草稿：服务拍平，汇总与设计稿一致（省 ¥280 · 约 7.9 折）', () {
      CatalogDraft.begin('packages', pkgRow());
      expect(CatalogDraft.packageItems.single, {
        'service_id': 's1',
        'name': '精致洗车',
        'price': 68,
        'count': 20,
      });
      expect(PackageCalc.originalText, '¥1,360');
      expect(PackageCalc.perUseText, '相当于单次 ¥54');
      expect(PackageCalc.savingText, '省 ¥280 · 约 7.9 折');
      expect(PackageCalc.summary, '20 次 · 12 个月有效');
      expect(CatalogDraft.packageLimitLabel, '2 份');
    });

    test('新建草稿的默认值', () {
      CatalogDraft.begin('packages');
      expect(CatalogDraft.packageItems, isEmpty);
      expect(CatalogDraft.packageValidityIndex, 2); // 12 个月
      expect(CatalogDraft.packageLimitLabel, '不限');
      expect(CatalogDraft.packageVehicleScope, '全部车型');
      expect(CatalogDraft.packageShowInMini, isTrue);
      expect(CatalogDraft.packageActive, isTrue);
      expect(PackageCalc.savingText, '无优惠');
    });
  });

  group('套餐列表', () {
    testWidgets('加载慢时显示 5 行骨架，之后显示真实套餐与上下架状态', (t) async {
      phone(t);
      fake.listDelay = const Duration(milliseconds: 900);
      fake.packages
        ..add(pkgRow())
        ..add(pkgRow(id: 'p2', name: '新客体验卡', price: 99, active: false));
      await t.pumpWidget(app(const CardPackagesLivePage()));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(t.widget<SkeletonList>(find.byType(SkeletonList)).count, 5);
      await t.pumpAndSettle();
      expect(find.byType(SkeletonList), findsNothing);
      expect(find.text('精致洗车年卡'), findsOneWidget);
      expect(find.text('20 次 · 12 个月有效'), findsNWidgets(2));
      expect(find.text('¥99'), findsOneWidget);
      expect(find.text('¥1,080'), findsOneWidget);
      expect(find.text('¥1,360'), findsNWidgets(2));
      expect(find.text('上架中'), findsOneWidget);
      expect(find.text('已下架'), findsOneWidget);
      // 销量属于其他模块：不显示“已售”
      expect(find.textContaining('已售'), findsNothing);
      expect(find.text('次卡套餐 2'), findsOneWidget);
    });

    testWidgets('没有套餐：空状态引导新建，且不显示概览 / 说明', (t) async {
      phone(t);
      await t.pumpWidget(app(const CardPackagesLivePage()));
      await t.pumpAndSettle();
      expect(find.text('还没有次卡套餐'), findsOneWidget);
      expect(find.text('新建套餐'), findsOneWidget);
      expect(find.text('本月次卡营收'), findsNothing);
      expect(find.textContaining('次卡在开单时'), findsNothing);
    });

    testWidgets('加载失败：显示错误和重试，重试成功后出现内容', (t) async {
      phone(t);
      fake.listError = const AppError('网络异常，请稍后重试', type: AppErrorType.network);
      await t.pumpWidget(app(const CardPackagesLivePage()));
      await t.pumpAndSettle();
      expect(find.text('重试'), findsOneWidget);
      fake
        ..listError = null
        ..packages.add(pkgRow());
      await t.tap(find.text('重试'));
      await t.pumpAndSettle();
      expect(find.text('精致洗车年卡'), findsOneWidget);
    });
  });

  group('套餐编辑', () {
    Future<void> openEdit(WidgetTester t, [Map<String, dynamic>? row]) async {
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  CatalogDraft.begin('packages', row);
                  openRoute(context, 'PackageEdit');
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('新建：没有名称 / 服务 / 售价时给出原因，不请求后端', (t) async {
      phone(t);
      await openEdit(t);
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(find.text('请输入名称'), findsOneWidget);
      expect(fake.saved, isEmpty);
      await toastGone(t);
      await t.enterText(find.byType(TextFormField).at(0), '年卡');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(fake.saved, isEmpty);
      expect(find.textContaining('服务'), findsWidgets);
    });

    testWidgets('已有套餐：回填名称、售价、说明，实时汇总，修改后保存', (t) async {
      phone(t);
      await openEdit(t, pkgRow());
      final fields = find.byType(TextFormField);
      expect(t.widget<TextFormField>(fields.at(0)).initialValue, '精致洗车年卡');
      expect(find.text('省 ¥280 · 约 7.9 折'), findsOneWidget);
      await t.enterText(fields.at(0), '精致洗车半年卡');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(fake.saved.single['name'], '精致洗车半年卡');
      expect(fake.saved.single['id'], 'p1');
      expect(fake.saved.single['validity_months'], 12);
      expect(fake.saved.single['purchase_limit'], 2);
      expect(fake.saved.single['items'], [
        {'service_id': 's1', 'count': 20},
      ]);
    });

    testWidgets('添加服务：选择弹层只列出在售服务，确认后写入草稿并汇总', (t) async {
      phone(t);
      await openEdit(t, pkgRow());
      await t.tap(find.text('添加服务项目'));
      await t.pumpAndSettle();
      expect(find.text('选择包含服务'), findsOneWidget);
      expect(find.text('空调杀菌'), findsOneWidget);
      expect(find.text('已停用项目'), findsNothing);
      // 搜索框有 placeholder
      expect(find.widgetWithText(TextField, ''), findsWidgets);
      await t.tap(find.text('空调杀菌'));
      await t.pumpAndSettle();
      expect(find.text('已选 2 项'), findsOneWidget);
      expect(find.text('合计原价 ¥1,458'), findsOneWidget); // 68×20 + 98×1
      await t.tap(find.text('确认添加'));
      await t.pumpAndSettle();
      expect(CatalogDraft.packageItems.map((e) => e['service_id']), [
        's1',
        's2',
      ]);
      expect(PackageCalc.originalText, '¥1,458');
    });

    testWidgets('删除套餐：确认后调用后端并返回', (t) async {
      phone(t);
      fake.packages.add(pkgRow());
      await openEdit(t, pkgRow());
      await t.ensureVisible(find.text('删除套餐'));
      await t.tap(find.text('删除套餐'));
      await t.pumpAndSettle();
      expect(find.textContaining('确认删除套餐'), findsOneWidget);
      await t.tap(find.text('确定').last);
      await t.pumpAndSettle();
      expect(fake.deleted, ['packages:p1']);
      expect(find.text('已删除'), findsOneWidget);
    });

    testWidgets('未保存的新套餐点删除：提示无需删除', (t) async {
      phone(t);
      await openEdit(t);
      await t.ensureVisible(find.text('删除套餐'));
      await t.tap(find.text('删除套餐'));
      await t.pumpAndSettle();
      expect(find.text('尚未保存，无需删除'), findsOneWidget);
      expect(fake.deleted, isEmpty);
    });
  });
}
