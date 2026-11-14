import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/catalog/card_tier_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final writes = <Map<String, dynamic>>[];
  Completer<void>? gate;
  bool fail = false;
  bool failDelete = false;
  @override
  bool get hasSession => true;
  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    expect(kind, 'cards');
    writes.add({...values});
    await gate?.future;
    if (fail) throw const AppError('暂时无法保存卡种');
    return {'item': values};
  }

  @override
  Future<void> delete(String kind, String id) async {
    expect(kind, 'cards');
    expect(id, 'card-a');
    if (failDelete) throw const AppError('暂时无法停用卡种');
  }
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
    t.view.physicalSize = const Size(1170, 4200);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold(body: Text('卡种列表'));
          },
        ),
      ),
    );
    return context;
  }

  testWidgets('卡种实际提交显示 loading、防重复写入并返回成功', (t) async {
    final context = await host(t);
    final result = openCardTierEditor(context, initial: {'name': '测试卡'});
    await t.pumpAndSettle();
    api.gate = Completer<void>();
    final center = t.getCenter(find.text('保存'));
    await t.tapAt(center);
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(t.getSize(find.byType(AppSpinner)), const Size(20, 20));
    final pill = find
        .ancestor(of: find.byType(AppSpinner), matching: find.byType(Container))
        .first;
    expect(t.getSize(pill), const Size(44, 44));
    await t.tapAt(center);
    await t.pump();
    expect(api.writes, hasLength(1));
    api.gate!.complete();
    await t.pumpAndSettle();
    expect(await result, isTrue);
    expect(find.byType(CardTierEditPage), findsNothing);
  });

  testWidgets('卡种失败保留输入，不同实例互不覆盖，取消不写入', (t) async {
    final context = await host(t);
    openCardTierEditor(context, initial: {'id': 'card-a', 'name': '甲卡'});
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(0), '甲卡草稿');
    FocusManager.instance.primaryFocus?.unfocus();
    api.fail = true;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '甲卡草稿'), findsOneWidget);
    expect(find.text('暂时无法保存卡种'), findsWidgets);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    openCardTierEditor(
      t.element(find.byType(CardTierEditPage)),
      initial: {'name': '乙卡'},
    );
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '乙卡'), findsOneWidget);
    Navigator.of(t.element(find.byType(CardTierEditPage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '甲卡草稿'), findsOneWidget);
    api.fail = false;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.writes, hasLength(2));
    expect(api.writes.last['id'], 'card-a');
    expect(api.writes.last['name'], '甲卡草稿');
  });

  testWidgets('停用失败保留确认弹窗，重试成功后返回列表', (t) async {
    final context = await host(t);
    openCardTierEditor(context, initial: {'id': 'card-a', 'name': '甲卡'});
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('停用此卡种'));
    await t.tap(find.text('停用此卡种'));
    await t.pumpAndSettle();
    api.failDelete = true;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('确认停用此卡种？'), findsOneWidget);
    expect(find.byType(CardTierEditPage), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.failDelete = false;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.byType(CardTierEditPage), findsNothing);
  });
}
