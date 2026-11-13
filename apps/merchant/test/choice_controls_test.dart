import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/widgets/choice_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi;

void main() {
  late MerchantApi original;
  late MemberFakeApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = MemberFakeApi();
    api.tiers
      ..clear()
      ..addAll([
        {'id': 'base', 'name': '普通'},
        {'id': 'silver', 'name': '银卡', 'upgrade_recharge': 2000},
        {'id': 'gold', 'name': '金卡', 'upgrade_recharge': 5000},
        {'id': 'black', 'name': '黑金', 'upgrade_recharge': 10000},
      ]);
  });
  tearDown(() => merchantApi = original);
  tearDown(() => C.dark = false);

  Future<void> openAdd(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 1300 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(const SizedBox()); // 丢弃上一次的 State
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          brightness: C.dark ? Brightness.dark : Brightness.light,
        ),
        home: pageFor('MemberAdd')!,
      ),
    );
    await t.pumpAndSettle();
  }

  /// 文字所在胶囊的底色 / 文字色。
  (Color?, Color?) look(WidgetTester t, String text) {
    final box = t.widget<AnimatedContainer>(
      find
          .ancestor(
            of: find.text(text),
            matching: find.byType(AnimatedContainer),
          )
          .first,
    );
    final style = t.widget<Text>(find.text(text)).style;
    return ((box.decoration as BoxDecoration).color, style?.color);
  }

  (Color?, Color?) sourceLook(WidgetTester t, String text) {
    final box = t.widget<Container>(
      find
          .ancestor(of: find.text(text), matching: find.byType(Container))
          .first,
    );
    return (
      (box.decoration as BoxDecoration).color,
      t.widget<Text>(find.text(text)).style?.color,
    );
  }

  Color? segmentColor(WidgetTester t, String text) {
    final label = find.text(text, findRichText: true);
    final box = t.widget<Container>(
      find.ancestor(of: label, matching: find.byType(Container)).first,
    );
    return (box.decoration as BoxDecoration).color;
  }

  testWidgets('称呼：先生 / 女士 互斥单选，选中项有滑块底色', (t) async {
    await openAdd(t);
    expect(segmentColor(t, '先生'), Colors.white);
    expect(segmentColor(t, '女士'), Colors.transparent);
    await t.tap(find.text('女士'));
    await t.pumpAndSettle();
    expect(segmentColor(t, '女士'), Colors.white);
    expect(segmentColor(t, '先生'), Colors.transparent);
    // 再点一次已选项不会取消选中
    await t.tap(find.text('女士'));
    await t.pumpAndSettle();
    expect(segmentColor(t, '女士'), Colors.white);
  });

  testWidgets('客户来源：单选标签完整蓝色选中态且互斥', (t) async {
    await openAdd(t);
    await t.ensureVisible(find.text('短视频'));
    for (final source in ['到店自然客', '老客推荐', '团购平台', '短视频']) {
      expect(sourceLook(t, source).$1, const Color(0xFFF4F4F5));
    }
    await t.tap(find.text('老客推荐'));
    await t.pumpAndSettle();
    expect(sourceLook(t, '老客推荐').$1, const Color(0xFFE1F0FE));
    expect(sourceLook(t, '老客推荐').$2, const Color(0xFF1E63AE));
    expect(sourceLook(t, '到店自然客').$1, const Color(0xFFF4F4F5));
    await t.tap(find.text('短视频'));
    await t.pumpAndSettle();
    for (final s in ['到店自然客', '老客推荐', '团购平台']) {
      expect(sourceLook(t, s).$1, const Color(0xFFF4F4F5), reason: '$s 应为未选中');
    }
    expect(sourceLook(t, '短视频').$1, const Color(0xFFE1F0FE));
    expect(sourceLook(t, '短视频').$2, const Color(0xFF1E63AE));
    // 任何状态下文字色都不能与底色相同
    for (final s in ['到店自然客', '老客推荐', '团购平台', '短视频']) {
      expect(sourceLook(t, s).$1, isNot(sourceLook(t, s).$2), reason: s);
    }
  });

  testWidgets('客户来源：深色模式下选中项与卡片底色有明显区分', (t) async {
    C.dark = true;
    await openAdd(t);
    await t.ensureVisible(find.text('老客推荐'));
    await t.tap(find.text('老客推荐'));
    await t.pumpAndSettle();
    final on = sourceLook(t, '老客推荐');
    expect(on.$1, const Color(0x2E0485F7));
    expect(on.$1, isNot(C.card));
    expect(on.$2, const Color(0xFF6AB4FA));
    expect(sourceLook(t, '团购平台').$1, const Color(0xFF27272A));
  });

  testWidgets('会员等级：展示真实门槛，点选不伪造服务端开通等级', (t) async {
    await openAdd(t);
    await t.ensureVisible(find.text('金卡'));
    expect(find.text('当前'), findsOneWidget);
    expect(find.textContaining('充值 ¥5,000'), findsOneWidget);
    await t.tap(find.text('金卡'));
    await t.pumpAndSettle();
    expect(find.text('当前'), findsOneWidget);
    final col = find
        .ancestor(of: find.text('金卡'), matching: find.byType(Column))
        .first;
    expect(find.descendant(of: col, matching: find.text('当前')), findsNothing);
    expect(find.textContaining('充值 ¥5,000'), findsOneWidget);
    expect(find.textContaining('充值 ¥2,000'), findsOneWidget);
    expect(find.text('会员等级由后台按门店规则开通与升级'), findsOneWidget);
    expect(api.saved, isEmpty);
    // 品牌配色不随选中变化
    expect(look(t, '金卡').$1, const Color(0xFFF3E2B3));
    expect(look(t, '黑金').$2, C.gold);
  });

  testWidgets('会员等级样式由调用者提供的当前项控制', (t) async {
    var selected = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, setState) => HTierPicker(
              initial: selected,
              labels: const ['普通', '银卡', '金卡', '黑金'],
              rules: const ['', '充值 ¥2,000', '充值 ¥5,000', '充值 ¥10,000'],
              onChanged: (i) => setState(() => selected = i),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('金卡'));
    await t.pumpAndSettle();
    expect(selected, 2);
    final column = find
        .ancestor(of: find.text('金卡'), matching: find.byType(Column))
        .first;
    expect(
      find.descendant(of: column, matching: find.text('当前')),
      findsOneWidget,
    );
    expect(find.textContaining('充值 ¥5,000'), findsNothing);
    expect(look(t, '金卡').$1, const Color(0xFFF3E2B3));
  });

  testWidgets('车身颜色：11 个色块 + 自定义，色值固定，选中环跟随点击（深色模式同样）', (t) async {
    for (final dark in [false, true]) {
      C.dark = dark;
      await openAdd(t);
      final sem = t.ensureSemantics();
      Finder dot(String label) => find.descendant(
        of: find.bySemanticsLabel(label),
        matching: find.byType(AnimatedContainer),
      );
      BoxDecoration deco(String label) =>
          t.widget<AnimatedContainer>(dot(label)).decoration as BoxDecoration;
      await t.ensureVisible(dot('黑色'));
      expect(deco('黑色').boxShadow, isNotNull); // 默认选中黑色
      for (final n in [
        '白色',
        '银色',
        '灰色',
        '红色',
        '蓝色',
        '棕色',
        '香槟金',
        '绿色',
        '橙色',
        '紫色',
      ]) {
        expect(dot(n), findsOneWidget);
        expect(deco(n).boxShadow, isNull);
      }
      await t.tap(find.bySemanticsLabel('红色'));
      await t.pumpAndSettle();
      expect(deco('红色').boxShadow, isNotNull);
      expect(deco('黑色').boxShadow, isNull);
      // 车漆颜色是真实颜色，深色模式下白车仍是白色、黑车仍是黑色
      expect(deco('白色').color, const Color(0xFFFFFFFF));
      expect(deco('黑色').color, const Color(0xFF18181B));
      expect(deco('红色').color, const Color(0xFFC0392B));
      expect(find.bySemanticsLabel('自定义颜色'), findsOneWidget);
      sem.dispose();
    }
    C.dark = false;
  });
}
