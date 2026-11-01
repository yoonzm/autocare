import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/card_tiers_live_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CatalogFakeApi extends MerchantApi {
  final services = <Map<String, dynamic>>[];
  final cards = <Map<String, dynamic>>[];
  int nextId = 1;
  @override
  bool get hasSession => true;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async =>
      List<Map<String, dynamic>>.from(
        kind == 'services'
            ? services
            : cards.where((r) => r['active'] != false),
      );
  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    final rows = kind == 'services' ? services : cards;
    final id = values['id']?.toString() ?? 'id-${nextId++}';
    final row = <String, dynamic>{'id': id, ...values};
    rows.removeWhere((r) => r['id'] == id);
    rows.add(row);
    return {'item': row};
  }

  @override
  Future<void> delete(String kind, String id) async {
    if (kind == 'services') {
      services.removeWhere((r) => r['id'] == id);
    } else {
      cards.firstWhere((r) => r['id'] == id)['active'] = false;
    }
  }
}

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(390 * 3, 900 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
}

void main() {
  late MerchantApi original;
  late CatalogFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = CatalogFakeApi();
    merchantApi = fake;
    CatalogDraft.current = null;
  });
  tearDown(() {
    merchantApi = original;
    CatalogDraft.current = null;
  });

  testWidgets('服务项目新增、修改、删除通过云函数适配层', (t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () {
                CatalogDraft.begin('services');
                openRoute(context, 'ServiceEdit');
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    final serviceFields = find.byType(TextFormField);
    expect(serviceFields, findsNWidgets(3));
    await t.enterText(serviceFields.at(0), '精致洗车');
    await t.enterText(serviceFields.at(1), '88');
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    expect(fake.services.single['name'], '精致洗车');
    expect(fake.services.single['price'], 88);

    CatalogDraft.begin('services', fake.services.single);
    openRoute(t.element(find.text('open')), 'ServiceEdit');
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '精洗升级');
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    expect(fake.services.single['name'], '精洗升级');

    CatalogDraft.begin('services', fake.services.single);
    openRoute(t.element(find.text('open')), 'ServiceEdit');
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('删除此项目').last,
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await t.tap(find.text('删除此项目').last);
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(fake.services, isEmpty);
  });

  testWidgets('卡种列表展示真实记录，新增、修改、停用可生效', (t) async {
    phone(t);
    fake.cards.add({
      'id': 'card-1',
      'name': '测试卡',
      'discount': 0.8,
      'description': '',
      'active': true,
    });
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: const CardTiersLivePage(),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('测试卡'), findsWidgets);
    expect(find.text('8 折'), findsWidgets);
    await t.tap(find.text('测试卡').last);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '升级卡');
    CatalogDraft.set('cards', 'discount', 0.75);
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    expect(fake.cards.single['name'], '升级卡');
    expect(fake.cards.single['discount'], 0.75);

    CatalogDraft.begin('cards');
    openRoute(t.element(find.byType(CardTiersLivePage)), 'CardTierEdit');
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '新卡');
    CatalogDraft.set('cards', 'discount', 0.95);
    await t.tap(find.text('保存').first);
    await t.pumpAndSettle();
    expect(fake.cards.map((e) => e['name']), contains('新卡'));

    CatalogDraft.begin('cards', fake.cards.last);
    openRoute(t.element(find.byType(CardTiersLivePage)), 'CardTierEdit');
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('停用此卡种').last,
      500,
      scrollable: find.byType(Scrollable).last,
    );
    await t.tap(find.text('停用此卡种').last);
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(fake.cards.last['active'], false);
    expect(
      (await fake.list('cards')).map((e) => e['name']),
      isNot(contains('新卡')),
    );
  });
}
