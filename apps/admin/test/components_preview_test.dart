import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/pages/components/components_preview_page.dart';
import 'package:autocare_admin/pages/components/preview_common.dart';
import 'package:autocare_admin/pages/components/preview_sections.dart';
import 'package:autocare_admin/pages/mine_page.dart';
import 'package:autocare_admin/theme.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart' show AppTokens;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => previewBrightness.value = null);
  tearDown(() {
    previewBrightness.value = null;
    store = Store();
    C.dark = false;
  });

  Future<void> open(WidgetTester t, Widget page, {Brightness brightness = Brightness.light}) async {
    t.view.physicalSize = const Size(390, 2400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    C.dark = brightness == Brightness.dark;
    await t.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: brightness, splashFactory: NoSplash.splashFactory),
      home: page,
    ));
    // 预览里有加载中的按钮、骨架屏等持续动画，不能 pumpAndSettle。
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
  }

  testWidgets('「我的」里只有超级管理员看得到「组件库」入口', (t) async {
    Account account(Role role) => Account(id: 'me', name: '测试', username: 'tester', role: role);
    store = Store();
    store.me = account(Role.superAdmin);
    await open(t, const MinePage());
    expect(find.text('组件库'), findsOneWidget);
    expect(find.text('基础组件预览 · 仅超级管理员可见'), findsOneWidget);
    store.me = account(Role.ops);
    store.notifyListeners();
    await t.pumpAndSettle();
    expect(find.text('组件库'), findsNothing);
  });

  testWidgets('预览首页列出设计稿里的全部分区，点进去能看到组件', (t) async {
    await open(t, const ComponentsPreviewPage());
    for (final s in previewSections) {
      expect(find.text(s.title), findsOneWidget, reason: s.title);
    }
    expect(previewSections.length, 11);
    await t.tap(find.text('按钮'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('AppButton'), findsOneWidget);
    expect(find.text('确认收款'), findsWidgets);
  });

  for (final dark in [false, true]) {
    testWidgets('每个分区都能渲染，没有异常（${dark ? '深色' : '浅色'}）', (t) async {
      for (final s in previewSections) {
        await open(t, ComponentSectionPage(s.id), brightness: dark ? Brightness.dark : Brightness.light);
        expect(t.takeException(), isNull, reason: '${s.title} 渲染异常');
        expect(find.text(s.title), findsWidgets);
      }
    });
  }

  testWidgets('切换到深色：舞台使用深色令牌，只作用于预览', (t) async {
    await open(t, const ComponentSectionPage('display'));
    BoxDecoration stage() => t
        .widget<Container>(find.descendant(of: find.byType(PreviewStage), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(stage().color, AppTokens.light.bg);
    await t.tap(find.text('深色'));
    await t.pumpAndSettle(const Duration(milliseconds: 300));
    expect(stage().color, AppTokens.dark.bg);
    expect(C.dark, isFalse, reason: '不改变 App 自己的外观');
    await t.tap(find.text('浅色'));
    await t.pumpAndSettle(const Duration(milliseconds: 300));
    expect(stage().color, AppTokens.light.bg);
  });

  testWidgets('选择类预览是可交互的受控示例', (t) async {
    await open(t, const ComponentSectionPage('choice'));
    BoxDecoration deco(String text) => t
        .widget<Container>(find.ancestor(of: find.text(text), matching: find.byType(Container)).first)
        .decoration! as BoxDecoration;
    expect(deco('镀晶镀膜').color, AppTokens.light.inset);
    await t.tap(find.text('镀晶镀膜'));
    await t.pump();
    expect(deco('镀晶镀膜').color, AppTokens.light.primarySoft);
    expect(deco('洗车').color, AppTokens.light.inset, reason: '同组互斥');
  });

  testWidgets('图片上传预览：模拟上传，第 3 张失败可重试；不触发真实选图', (t) async {
    await open(t, const ComponentSectionPage('upload'));
    expect(find.text('1 / 4'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('添加凭证'));
    await t.pump();
    expect(find.text('2 / 4'), findsOneWidget);
    await t.pump(const Duration(seconds: 2));
    await t.tap(find.bySemanticsLabel('添加凭证'));
    await t.pump(const Duration(seconds: 2));
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('重试'), findsWidgets);
  });
}
