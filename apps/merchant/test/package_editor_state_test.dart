import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/catalog/package_edit_page.dart';
import 'package:autocare_merchant/widgets/package_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'packages_test.dart' show PkgFakeApi, pkgRow;

class _Api extends PkgFakeApi {
  bool failSave = false;
  bool failDelete = false;
  int attempts = 0;
  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    attempts++;
    if (failSave) throw const AppError('套餐保存失败，请重试');
    return super.save(kind, values);
  }

  @override
  Future<void> delete(String kind, String id) async {
    if (failDelete) throw const AppError('套餐删除失败，请重试');
    return super.delete(kind, id);
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
            return const Scaffold(body: Text('套餐列表'));
          },
        ),
      ),
    );
    return context;
  }

  testWidgets('套餐保存失败保留名称与服务次数，修正后可重试', (t) async {
    final context = await host(t);
    openPackageEditor(context, initial: pkgRow());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).first, '半年养护');
    FocusManager.instance.primaryFocus?.unfocus();
    final minus = find.descendant(
      of: find.byType(PackageItems),
      matching: find.bySemanticsLabel('减少'),
    );
    final semantics = t.ensureSemantics();
    await t.tap(minus.first);
    semantics.dispose();
    await t.pumpAndSettle();
    expect(
      t.widget<PackageItems>(find.byType(PackageItems)).items.single['count'],
      19,
    );
    api.failSave = true;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('套餐保存失败，请重试'), findsWidgets);
    expect(find.widgetWithText(TextFormField, '半年养护'), findsOneWidget);
    expect(
      t.widget<PackageItems>(find.byType(PackageItems)).items.single['count'],
      19,
    );
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.failSave = false;
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(api.attempts, 2);
    expect(api.saved.single['name'], '半年养护');
    expect(api.saved.single['items'], [
      {'service_id': 's1', 'count': 19},
    ]);
  });

  testWidgets('服务选择未确认即取消，不修改当前套餐或调用者数据', (t) async {
    final context = await host(t);
    final initial = pkgRow();
    openPackageEditor(context, initial: initial);
    await t.pumpAndSettle();
    await t.tap(find.text('添加服务项目'));
    await t.pumpAndSettle();
    await t.tap(find.text('空调杀菌'));
    await t.pumpAndSettle();
    expect(find.text('已选 2 项'), findsOneWidget);
    Navigator.of(t.element(find.text('选择包含服务'))).pop();
    await t.pumpAndSettle();
    expect(
      t.widget<PackageItems>(find.byType(PackageItems).last).items,
      hasLength(1),
    );
    expect((initial['items'] as List), hasLength(1));
    expect(api.saved, isEmpty);
  });

  testWidgets('套餐实例隔离，第二个编辑页取消后第一个草稿仍在', (t) async {
    final context = await host(t);
    openPackageEditor(context, initial: pkgRow());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).first, '甲套餐草稿');
    FocusManager.instance.primaryFocus?.unfocus();
    openPackageEditor(
      t.element(find.byType(PackageEditPage)),
      initial: {'name': '乙套餐'},
    );
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '乙套餐'), findsOneWidget);
    expect(t.widget<PackageItems>(find.byType(PackageItems).last).items, isEmpty);
    Navigator.of(t.element(find.byType(PackageEditPage).last)).pop();
    await t.pumpAndSettle();
    expect(find.widgetWithText(TextFormField, '甲套餐草稿'), findsOneWidget);
    expect(
      t.widget<PackageItems>(find.byType(PackageItems)).items.single['count'],
      20,
    );
    expect(api.saved, isEmpty);
  });

  testWidgets('非法售价不会让预览崩溃，也不会提交后端', (t) async {
    final context = await host(t);
    openPackageEditor(context, initial: pkgRow());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextFormField).at(1), 'NaN');
    FocusManager.instance.primaryFocus?.unfocus();
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('请输入正确的套餐售价'), findsWidgets);
    expect(api.attempts, 0);
  });

  testWidgets('删除失败保留弹窗，重试成功后返回列表', (t) async {
    final context = await host(t);
    openPackageEditor(context, initial: pkgRow());
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('删除套餐'));
    await t.tap(find.text('删除套餐'));
    await t.pumpAndSettle();
    api.failDelete = true;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('确认删除套餐？'), findsOneWidget);
    expect(find.byType(PackageEditPage), findsOneWidget);
    await t.pump(const Duration(seconds: 6));
    await t.pumpAndSettle();
    api.failDelete = false;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(api.deleted, ['packages:p1']);
    expect(find.byType(PackageEditPage), findsNothing);
  });
}
