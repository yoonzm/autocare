import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSwitch;
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final writes = <Map<String, dynamic>>[];
  final deleted = <String>[];
  Completer<void>? pending;
  bool failSave = false;
  bool failDelete = false;
  List<Map<String, dynamic>> cards = [];

  @override
  bool get hasSession => true;

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    expect(kind, 'services');
    writes.add({...values});
    await pending?.future;
    if (failSave) throw const AppError('保存失败，请重试');
    return {
      'item': {'id': 'saved', ...values},
    };
  }

  @override
  Future<void> delete(String kind, String id) async {
    expect(kind, 'services');
    deleted.add(id);
    if (failDelete) throw const AppError('删除失败，请重试');
  }

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async =>
      kind == 'cards' ? cards : [];
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
    busyActions.value = {};
  });
  tearDown(() {
    merchantApi = original;
    busyActions.value = {};
  });

  Future<BuildContext> host(WidgetTester t) async {
    t.view.physicalSize = const Size(1170, 2700);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('服务列表'));
          },
        ),
      ),
    );
    return context;
  }

  Future<void> enter(WidgetTester t, String name, String price) async {
    await t.enterText(find.byType(TextFormField).at(0), name);
    await t.enterText(find.byType(TextFormField).at(1), price);
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
  }

  testWidgets('真实点击保存显示 loading，防止重复写入并返回成功结果', (t) async {
    final context = await host(t);
    final result = openServiceEditor(context);
    await t.pumpAndSettle();
    await enter(t, '精洗', '88');
    api.pending = Completer<void>();
    final saveCenter = t.getCenter(find.text('保存'));
    await t.tapAt(saveCenter);
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(t.getSize(find.byType(AppSpinner)), const Size(20, 20));
    final pill = find
        .ancestor(of: find.byType(AppSpinner), matching: find.byType(Container))
        .first;
    expect(t.getSize(pill), const Size(44, 44));
    await t.tapAt(saveCenter);
    await t.pump();
    expect(api.writes, hasLength(1));
    api.pending!.complete();
    await t.pumpAndSettle();
    expect(await result, isTrue);
    expect(api.writes.single, containsPair('name', '精洗'));
    expect(api.writes.single, containsPair('price', 88));
    expect(find.byType(ServiceEditPage), findsNothing);
  });

  testWidgets('保存失败保留编辑值，可重试且保持原记录 ID 和说明', (t) async {
    final context = await host(t);
    openServiceEditor(
      context,
      initial: {
        'id': 'service-7',
        'name': '原服务',
        'price': 10,
        'description': '服务说明',
        'category': '洗车',
        'duration_minutes': 90,
      },
    );
    await t.pumpAndSettle();
    expect(find.text('1.5 小时'), findsOneWidget);
    await enter(t, '更新服务', '128');
    api.failSave = true;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.byType(ServiceEditPage), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '更新服务'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '128'), findsOneWidget);
    expect(find.text('保存失败，请重试'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.failSave = false;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes, hasLength(2));
    expect(api.writes.last, containsPair('id', 'service-7'));
    expect(api.writes.last, containsPair('description', '服务说明'));
    expect(api.writes.last, containsPair('duration_minutes', 90));
    expect(find.byType(ServiceEditPage), findsNothing);
  });

  testWidgets('不同编辑实例互不覆盖，取消不会发送保存请求', (t) async {
    final context = await host(t);
    openServiceEditor(context, initial: {'id': 'a', 'name': '甲', 'price': 20});
    await t.pumpAndSettle();
    await enter(t, '甲的草稿', '25');
    openServiceEditor(
      t.element(find.byType(ServiceEditPage)),
      initial: {'id': 'b', 'name': '乙', 'price': 30},
    );
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '乙'), findsOneWidget);
    Navigator.of(t.element(find.byType(ServiceEditPage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '甲的草稿'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '25'), findsOneWidget);
    Navigator.of(t.element(find.byType(ServiceEditPage))).pop();
    await t.pumpAndSettle();
    expect(api.writes, isEmpty);
  });

  testWidgets('删除失败保留确认弹窗，重试成功后返回列表', (t) async {
    final context = await host(t);
    openServiceEditor(
      context,
      initial: {'id': 'service-7', 'name': '精洗', 'price': 88},
    );
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('删除此项目'));
    await t.tap(find.text('删除此项目'));
    await t.pumpAndSettle();
    api.failDelete = true;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('确认删除此项目？'), findsOneWidget);
    expect(find.byType(ServiceEditPage), findsOneWidget);
    api.failDelete = false;
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(api.deleted, ['service-7', 'service-7']);
    expect(find.byType(ServiceEditPage), findsNothing);
  });

  testWidgets('一期没有会员端小程序：编辑项目页不显示「支持线上预约」，保留上架销售', (t) async {
    final context = await host(t);
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ServiceEditPage(
            initial: {'id': 'service-1', 'name': '精洗', 'price': 68},
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.scrollUntilVisible(
      find.text('上架销售'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('上架销售'), findsOneWidget);
    expect(find.text('支持线上预约'), findsNothing);
    expect(find.text('客户可在小程序预约此项目'), findsNothing);
  });

  Future<void> openEditor(WidgetTester t, Map<String, dynamic> initial) async {
    final context = await host(t);
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ServiceEditPage(initial: initial),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('所属分类、标准工时的值靠右；门店价带千分位', (t) async {
    await openEditor(t, {
      'id': 's',
      'name': '精洗',
      'price': 1580,
      'category': '洗车',
      'duration_minutes': 240,
    });
    expect(t.widget<Text>(find.text('洗车')).textAlign, TextAlign.right);
    expect(t.widget<Text>(find.text('4 小时')).textAlign, TextAlign.right);
    expect(find.widgetWithText(TextFormField, '1,580'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(1), '12345.678');
    expect(find.widgetWithText(TextFormField, '12,345.67'), findsOneWidget);
  });

  testWidgets('会员价：按本店真实卡种折扣和门店价实时计算，没有折扣的卡种不显示', (t) async {
    api.cards = [
      {'name': '金卡', 'discount': 0.95},
      {'name': '黑金卡', 'discount': 0.9},
      {'name': '普通会员', 'discount': 1},
    ];
    await openEditor(t, {'id': 's', 'name': '镀晶', 'price': 1580});
    expect(find.text('黑金卡'), findsOneWidget);
    expect(find.text('9 折'), findsOneWidget);
    expect(find.text('¥1,422'), findsOneWidget);
    expect(find.text('9.5 折'), findsOneWidget);
    expect(find.text('¥1,501'), findsOneWidget);
    expect(find.text('普通会员'), findsNothing);
    await t.enterText(find.byType(TextFormField).at(1), '1000');
    await t.pump();
    expect(find.text('¥900'), findsOneWidget);
    expect(find.text('¥950'), findsOneWidget);
  });

  testWidgets('技师提成：回填已保存的方式和数值，切换方式，保存带 commission_type / commission_value', (
    t,
  ) async {
    await openEditor(t, {
      'id': 's',
      'name': '镀晶',
      'price': 1580,
      'commission_type': 'fixed',
      'commission_value': 30,
    });
    expect(find.text('提成金额'), findsOneWidget);
    expect(find.text('每单固定'), findsOneWidget);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes.last, containsPair('commission_type', 'fixed'));
    expect(api.writes.last, containsPair('commission_value', 30));
  });

  testWidgets('技师提成按比例：约多少元 / 单随门店价和比例变化；比例超过 100 不能保存', (t) async {
    await openEditor(t, {'id': 's', 'name': '镀晶', 'price': 1580});
    expect(find.text('提成比例'), findsOneWidget);
    expect(find.text('约 ¥126 / 单'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(2), '120');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes, isEmpty);
    expect(find.text('提成比例须为 0–100%'), findsOneWidget);
    await t.pump(const Duration(seconds: 5));
  });

  testWidgets('耗材绑定：显示真实库存和偏低；保存带 consumables；没有耗材时显示空状态', (t) async {
    await openEditor(t, {
      'id': 's',
      'name': '镀晶',
      'price': 10,
      'consumables': [
        {
          'product_id': 'p1',
          'quantity': 2,
          'name': '9H 镀晶液',
          'unit': '瓶',
          'stock': 1,
          'safe': 5,
        },
        {
          'product_id': 'p2',
          'quantity': 0.5,
          'name': '擦车巾',
          'unit': '条',
          'stock': 86,
          'safe': 10,
        },
      ],
    });
    await t.scrollUntilVisible(
      find.text('从库存添加耗材'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('库存 1 瓶 · 偏低'), findsOneWidget);
    expect(find.text('库存 86 条'), findsOneWidget);
    expect(find.text('× 2 瓶'), findsOneWidget);
    expect(find.text('× 0.5 条'), findsOneWidget);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes.last['consumables'], [
      {'product_id': 'p1', 'quantity': 2},
      {'product_id': 'p2', 'quantity': 0.5},
    ]);
  });

  testWidgets('耗材可以移除；没有耗材时说明完工自动出库，保存传空数组清空', (t) async {
    await openEditor(t, {
      'id': 's',
      'name': '镀晶',
      'price': 10,
      'consumables': [
        {
          'product_id': 'p1',
          'quantity': 2,
          'name': '9H 镀晶液',
          'unit': '瓶',
          'stock': 9,
          'safe': 5,
        },
      ],
    });
    await t.scrollUntilVisible(
      find.text('从库存添加耗材'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.text('9H 镀晶液'));
    await t.pumpAndSettle();
    await t.tap(find.text('移除'));
    await t.pumpAndSettle();
    expect(find.text('9H 镀晶液'), findsNothing);
    expect(find.textContaining('还没有绑定耗材'), findsOneWidget);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes.last['consumables'], isEmpty);
  });

  testWidgets('上架销售：默认读取项目状态，关闭后保存 active=false', (t) async {
    await openEditor(t, {'id': 's', 'name': '镀晶', 'price': 10, 'active': true});
    await t.scrollUntilVisible(
      find.text('上架销售'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await t.tap(find.byType(HSwitch));
    await t.pump();
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes.last, containsPair('active', false));
  });

  testWidgets('所属分类：可以新建分类，保存带新分类名', (t) async {
    await openEditor(t, {
      'id': 's',
      'name': '镀晶',
      'price': 10,
      'category': '洗车',
    });
    await t.tap(find.text('洗车'));
    await t.pumpAndSettle();
    await t.tap(find.text('＋ 新建分类'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '打蜡抛光');
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('打蜡抛光'), findsOneWidget);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes.last, containsPair('category', '打蜡抛光'));
  });
}
