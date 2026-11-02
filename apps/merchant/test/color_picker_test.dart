import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/color_picker.dart';
import 'package:autocare_merchant/pages/member_add_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/widgets/card_face.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'members_test.dart' show MemberFakeApi, phone;

/// 通用颜色选择组件：色块单选 + 自定义选色器 + 最近使用。
void main() {
  late MerchantApi original;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RecentColors.clearMemory();
    original = merchantApi;
    merchantApi = MemberFakeApi();
    CatalogDraft.current = null;
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    CatalogDraft.current = null;
    RecentColors.clearMemory();
    navTracker.stack.clear();
  });

  test('色值转换：#RRGGBB 大写，6 位十六进制才有效', () {
    expect(hexOf(const Color(0xFF7A4B2A)), '#7A4B2A');
    expect(colorFromHex('7a4b2a'), const Color(0xFF7A4B2A));
    expect(colorFromHex('#7A4B2A'), const Color(0xFF7A4B2A));
    expect(colorFromHex('#FFF'), isNull);
    expect(colorFromHex('GGGGGG'), isNull);
  });

  /// 打开选色器的测试入口：把弹层返回值存起来。
  Future<ValueNotifier<PickedColor?>> openPicker(
    WidgetTester t, {
    bool withName = false,
    Color initial = const Color(0xFF7A4B2A),
  }) async {
    phone(t);
    final result = ValueNotifier<PickedColor?>(null);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result.value = await showColorPicker(
                    ctx,
                    title: '自定义车身颜色',
                    initial: initial,
                    withName: withName,
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    return result;
  }

  testWidgets('选色器：设计稿的各部分都在，输入色值后点确定返回该颜色', (t) async {
    final result = await openPicker(t, withName: true);
    expect(find.text('自定义车身颜色'), findsOneWidget);
    expect(find.text('名称，选填'), findsOneWidget); // placeholder
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('最近使用'), findsNothing); // 还没有使用记录
    final hex = find.byType(TextField).first;
    expect(t.widget<TextField>(hex).controller!.text, '7A4B2A'); // 初始颜色
    await t.enterText(hex, 'ff0000');
    await t.enterText(find.byType(TextField).last, '玫红');
    await t.pump();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(result.value!.color, const Color(0xFFFF0000));
    expect(result.value!.hex, '#FF0000');
    expect(result.value!.name, '玫红');
    expect(navTracker.has('sheet:ColorPicker'), isFalse);
  });

  testWidgets('取消 / 关闭不返回颜色；输入框只接受 6 位十六进制', (t) async {
    final result = await openPicker(t);
    final hex = find.byType(TextField).first;
    await t.enterText(hex, 'zz12');
    await t.pump();
    expect(t.widget<TextField>(hex).controller!.text, '12'); // 非十六进制字符被过滤
    await t.enterText(hex, '1234567');
    await t.pump();
    expect(t.widget<TextField>(hex).controller!.text, '123456'); // 最多 6 位
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(result.value, isNull);
  });

  testWidgets('点 / 拖动色板和色相条改变颜色，色值同步', (t) async {
    await openPicker(t, initial: const Color(0xFFFF0000));
    final sem = t.ensureSemantics();
    final hex = find.byType(TextField).first;
    String text() => t.widget<TextField>(hex).controller!.text;
    expect(text(), 'FF0000');
    final panel = t.getRect(find.bySemanticsLabel('饱和度与明度'));
    // 色板左上角：白色（饱和度 0、明度 1）；右下角：黑色
    await t.tapAt(panel.topLeft + const Offset(.1, .1));
    await t.pump();
    expect(text(), 'FFFFFF');
    await t.tapAt(panel.bottomRight - const Offset(.1, .1));
    await t.pump();
    expect(text(), '000000');
    // 右上角：当前色相的纯色；拖动色相条到 1/3 处（绿色）后色板右上角变成绿色
    await t.tapAt(panel.topRight + const Offset(-.1, .1));
    await t.pump();
    final hue = t.getRect(find.bySemanticsLabel('色相'));
    await t.tapAt(Offset(hue.left + hue.width / 3, hue.center.dy));
    await t.pump();
    expect(text(), '00FF00');
    sem.dispose();
  });

  testWidgets('确定后记入“最近使用”（最多 5 个，去重，最新在前），再次打开可以一键使用', (t) async {
    await openPicker(t);
    for (final h in [
      '111111',
      '222222',
      '333333',
      '444444',
      '555555',
      '666666',
      '333333',
    ]) {
      await t.enterText(find.byType(TextField).first, h);
      await t.pump();
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }
    expect(
      [for (final c in RecentColors.list.value) hexOf(c)],
      ['#333333', '#666666', '#555555', '#444444', '#222222'],
    );
    expect(find.text('最近使用'), findsOneWidget);
    final sem = t.ensureSemantics();
    await t.tap(find.bySemanticsLabel('使用 #222222'));
    await t.pump();
    expect(
      t.widget<TextField>(find.byType(TextField).first).controller!.text,
      '222222',
    );
    sem.dispose();
    // 持久化在本机
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('recent_custom_colors')!.first, '#333333');
  });

  testWidgets('新增会员的车身颜色：自定义颜色带名称时存名称，不带名称时存色值', (t) async {
    phone(t);
    CatalogDraft.current = null;
    MemberFlow.beginAdd();
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        initialRoute: 'MemberAdd',
        onGenerateRoute: (s) => MaterialPageRoute(
          settings: s,
          builder: (_) => const MemberAddPage(),
        ),
      ),
    );
    await t.pumpAndSettle();
    final sem = t.ensureSemantics();
    await t.ensureVisible(find.bySemanticsLabel('自定义颜色'));
    expect(find.text('黑色'), findsWidgets); // 标题行显示当前颜色名
    await t.tap(find.bySemanticsLabel('自定义颜色'));
    await t.pumpAndSettle();
    expect(find.text('自定义车身颜色'), findsOneWidget);
    final sheetFields = find.descendant(
      of: find.byType(ColorPickerSheet),
      matching: find.byType(TextField),
    );
    await t.enterText(sheetFields.at(0), '8B1E3F');
    await t.enterText(sheetFields.at(1), '酒红');
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(CatalogDraft.current!.fields['color'], '酒红');
    expect(find.text('酒红'), findsOneWidget);
    // 再选一个预设：回到预设名；再自定义不填名称：存色值
    await t.tap(find.bySemanticsLabel('蓝色'));
    await t.pumpAndSettle();
    expect(CatalogDraft.current!.fields['color'], '蓝色');
    await t.tap(find.bySemanticsLabel('自定义颜色'));
    await t.pumpAndSettle();
    await t.enterText(sheetFields.at(0), '2F4F4F');
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(CatalogDraft.current!.fields['color'], '#2F4F4F');
    sem.dispose();
  });

  testWidgets('自定义卡面颜色：文字颜色按底色深浅自动调整', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final dark = cardPalette(ctx, '#2F4F4F');
    expect(dark.bg, const Color(0xFF2F4F4F));
    expect(dark.title, const Color(0xFFFFFFFF));
    final light = cardPalette(ctx, '#D9B382');
    expect(light.bg, const Color(0xFFD9B382));
    expect(light.title, const Color(0xFF18181B));
    final nearWhite = cardPalette(ctx, '#FAFAFA');
    expect(nearWhite.shadow, isTrue);
    // 预设颜色不受影响
    expect(cardPalette(ctx, 'champagne').bg, const Color(0xFFF3E2B3));
    expect(CatalogDraft.customCardColor('#7A4B2A'), const Color(0xFF7A4B2A));
    expect(CatalogDraft.customCardColor('black'), isNull);
  });
}
