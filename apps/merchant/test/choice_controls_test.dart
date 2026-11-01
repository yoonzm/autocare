import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
      MaterialApp(home: Builder(builder: genRoutes['MemberAdd']!)),
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

  testWidgets('称呼：先生 / 女士 互斥单选，选中项有滑块底色', (t) async {
    await openAdd(t);
    expect(look(t, '先生').$1, Colors.white);
    expect(look(t, '女士').$1, Colors.transparent);
    await t.tap(find.text('女士'));
    await t.pumpAndSettle();
    expect(look(t, '女士').$1, Colors.white);
    expect(look(t, '先生').$1, Colors.transparent);
    // 再点一次已选项不会取消选中
    await t.tap(find.text('女士'));
    await t.pumpAndSettle();
    expect(look(t, '女士').$1, Colors.white);
  });

  testWidgets('客户来源：默认老客推荐，点选后只有一个实心选中，且文字清晰可读', (t) async {
    await openAdd(t);
    await t.ensureVisible(find.text('短视频'));
    expect(look(t, '老客推荐').$1, C.btn);
    expect(look(t, '老客推荐').$2, C.btnFg);
    expect(look(t, '到店自然客').$1, C.inset);
    await t.tap(find.text('短视频'));
    await t.pumpAndSettle();
    for (final s in ['到店自然客', '老客推荐', '团购平台']) {
      expect(look(t, s).$1, C.inset, reason: '$s 应为未选中');
    }
    expect(look(t, '短视频').$1, C.btn);
    expect(look(t, '短视频').$2, C.btnFg);
    // 任何状态下文字色都不能与底色相同
    for (final s in ['到店自然客', '老客推荐', '团购平台', '短视频']) {
      expect(look(t, s).$1, isNot(look(t, s).$2), reason: s);
    }
  });

  testWidgets('客户来源：深色模式下选中项与卡片底色有明显区分', (t) async {
    C.dark = true;
    await openAdd(t);
    await t.ensureVisible(find.text('老客推荐'));
    final on = look(t, '老客推荐');
    expect(on.$1, C.btn); // 反白
    expect(on.$1, isNot(C.card));
    expect(on.$2, C.btnFg);
    expect(look(t, '团购平台').$1, C.inset);
  });

  testWidgets('会员等级：点选后「当前」跟随选中项，其余显示升级门槛', (t) async {
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
    expect(find.descendant(of: col, matching: find.text('当前')), findsOneWidget);
    expect(find.textContaining('充值 ¥5,000'), findsNothing);
    expect(find.textContaining('充值 ¥2,000'), findsOneWidget);
    // 品牌配色不随选中变化
    expect(look(t, '金卡').$1, const Color(0xFFF3E2B3));
    expect(look(t, '黑金').$2, C.gold);
  });

  testWidgets('车身颜色：五色单选，色值固定，选中环跟随点击（深色模式同样）', (t) async {
    for (final dark in [false, true]) {
      C.dark = dark;
      await openAdd(t);
      final dots = find.descendant(
        of: find.ancestor(
          of: find.byType(AnimatedContainer).first,
          matching: find.byType(Scaffold),
        ),
        matching: find.byWidgetPredicate(
          (w) =>
              w is AnimatedContainer &&
              w.constraints?.maxWidth == 26 &&
              w.constraints?.maxHeight == 26,
        ),
      );
      expect(dots, findsNWidgets(5));
      BoxDecoration deco(int i) =>
          t.widget<AnimatedContainer>(dots.at(i)).decoration as BoxDecoration;
      await t.ensureVisible(dots.at(0));
      expect(deco(0).boxShadow, isNotNull);
      for (var i = 1; i < 5; i++) {
        expect(deco(i).boxShadow, isNull);
      }
      await t.tap(dots.at(4));
      await t.pumpAndSettle();
      expect(deco(4).boxShadow, isNotNull);
      expect(deco(0).boxShadow, isNull);
      // 车漆颜色是真实颜色，深色模式下白车仍是白色、黑车仍是黑色
      expect(deco(1).color, const Color(0xFFFFFFFF));
      expect(deco(0).color, const Color(0xFF18181B));
      expect(deco(4).color, const Color(0xFFB91C1C));
    }
  });
}
