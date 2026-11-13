import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final writes = <Map<String, dynamic>>[];
  final deleted = <String>[];
  Completer<void>? pending;
  bool failSave = false;
  bool failDelete = false;

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
  Future<List<Map<String, dynamic>>> list(String kind) async => [];
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
    final before = t.getSize(
      find
          .ancestor(of: find.text('保存'), matching: find.byType(Container))
          .first,
    );
    final saveCenter = t.getCenter(find.text('保存'));
    await t.tapAt(saveCenter);
    await t.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      t.getSize(find.byType(CircularProgressIndicator)),
      const Size(16, 16),
    );
    final pill = find
        .ancestor(
          of: find.byType(CircularProgressIndicator),
          matching: find.byType(Container),
        )
        .first;
    expect(t.getSize(pill), before);
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
    expect(find.text('90 分钟'), findsOneWidget);
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
}
