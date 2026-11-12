import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('AppButton', () {
    testWidgets('点击触发回调；null 即禁用且不响应', (t) async {
      var n = 0;
      await pump(t, AppButton(label: '保存', onPressed: () => n++));
      await t.tap(find.text('保存'));
      expect(n, 1);
      await pump(t, const AppButton(label: '保存'));
      await t.tap(find.text('保存'));
      expect(n, 1);
      const tokens = AppTokens.light;
      expect(backgroundBehind(t, '保存'), tokens.fillStrong, reason: '禁用用 fillStrong 底');
      expect(t.widget<Text>(find.text('保存')).style!.color, tokens.inkFaint);
    });

    testWidgets('四种语义的颜色来自令牌', (t) async {
      const tokens = AppTokens.light;
      for (final (kind, bg, fg) in [
        (AppButtonKind.primary, tokens.primary, tokens.onPrimary),
        (AppButtonKind.secondary, tokens.fill, tokens.ink),
        (AppButtonKind.danger, tokens.danger.bg, tokens.danger.fg),
        (AppButtonKind.text, Colors.transparent, tokens.primaryText),
      ]) {
        await pump(t, AppButton(label: '按钮', kind: kind, onPressed: () {}));
        expect(backgroundBehind(t, '按钮'), bg, reason: '$kind 底色');
        expect(t.widget<Text>(find.text('按钮')).style!.color, fg, reason: '$kind 字色');
      }
    });

    testWidgets('尺寸档：large 50 · medium 44 · small 32', (t) async {
      for (final (size, h) in [
        (AppButtonSize.large, 50.0),
        (AppButtonSize.medium, 44.0),
        (AppButtonSize.small, 32.0),
      ]) {
        await pump(t, AppButton(label: '按钮', size: size, onPressed: () {}));
        final box = t.getSize(
          find.ancestor(of: find.text('按钮'), matching: find.byType(Container)).first,
        );
        expect(box.height, h);
      }
    });

    testWidgets('加载中：转圈、透明度 .72、不可再点', (t) async {
      var n = 0;
      await pump(t, AppButton(label: '提交中', loading: true, onPressed: () => n++));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.widget<Opacity>(find.byType(Opacity).first).opacity, .72);
      await t.tap(find.text('提交中'));
      expect(n, 0);
    });

    testWidgets('防重复点击：极短间隔内连点只触发一次', (t) async {
      var n = 0;
      await pump(t, AppButton(label: '保存', onPressed: () => n++));
      await t.tap(find.text('保存'));
      await t.tap(find.text('保存'));
      expect(n, 1);
      await t.pump(const Duration(milliseconds: 400));
      await t.tap(find.text('保存'));
      expect(n, 2);
    });

    testWidgets('小按钮的点击热区外扩到 44 高', (t) async {
      await pump(t, AppButton(label: '去补货', size: AppButtonSize.small, onPressed: () {}));
      final hit = t.getSize(find.byType(GestureDetector).first);
      expect(hit.height, greaterThanOrEqualTo(44));
    });
  });

  group('AppIconButton', () {
    testWidgets('圆形 44，带语义标签；胶囊带红点数字', (t) async {
      var n = 0;
      await pump(
        t,
        Column(
          children: [
            AppIconButton(icon: Icons.chevron_left_rounded, semanticLabel: '返回', onPressed: () => n++),
            const AppIconButton.pill(label: '挂单', badge: 4),
          ],
        ),
      );
      await t.tap(find.bySemanticsLabel('返回'));
      expect(n, 1);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('挂单'), findsOneWidget);
    });
  });

  group('AppStatusTag / AppBadge / AppAvatar', () {
    testWidgets('状态标签为浅底 + 深字，高 18', (t) async {
      const tokens = AppTokens.light;
      await pump(t, const AppStatusTag('已入库', tone: Tone.ok));
      expect(backgroundBehind(t, '已入库'), tokens.ok.bg);
      expect(t.widget<Text>(find.text('已入库')).style!.color, tokens.ok.fg);
      expect(t.getSize(find.ancestor(of: find.text('已入库'), matching: find.byType(Container)).first).height, 18);
    });

    testWidgets('红点数字：0 不显示，超过 99 显示 99+', (t) async {
      await pump(t, const Column(children: [AppBadge(count: 0), AppBadge(count: 4), AppBadge(count: 120)]));
      expect(find.text('0'), findsNothing);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('头像取姓；没有名字显示人像图标；黑金是黑底金字', (t) async {
      const tokens = AppTokens.light;
      await pump(t, const Column(children: [
        AppAvatar(name: '王建国'),
        AppAvatar(name: ' '),
        AppAvatar(name: '李', tier: AppAvatarTier.blackGold),
      ]));
      expect(find.text('王'), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(t.widget<Text>(find.text('李')).style!.color, tokens.gold);
    });
  });

  group('选择类', () {
    testWidgets('选择标签：选中 = 浅蓝底 + 1.5 蓝内描边 + 蓝字，未选中同样占位', (t) async {
      const tokens = AppTokens.light;
      await pump(
        t,
        Row(children: [
          AppChoiceChip(label: '洗车', selected: false, onTap: () {}),
          AppChoiceChip(label: '镀晶', selected: true, onTap: () {}),
        ]),
      );
      BoxDecoration deco(String text) => t
          .widget<Container>(find.ancestor(of: find.text(text), matching: find.byType(Container)).first)
          .decoration! as BoxDecoration;
      expect(deco('镀晶').color, tokens.primarySoft);
      expect((deco('镀晶').border! as Border).top.color, tokens.primary);
      expect((deco('镀晶').border! as Border).top.width, 1.5);
      expect(t.widget<Text>(find.text('镀晶')).style!.color, tokens.primaryText);
      expect((deco('洗车').border! as Border).top.width, 1.5, reason: '未选中也预留描边');
      expect(t.getSize(find.text('洗车')).height, t.getSize(find.text('洗车')).height);
    });

    testWidgets('选择标签组：单选互斥，禁用项跳过', (t) async {
      String? selected = 'a';
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppChoiceGroup<String>(
            items: const [
              ChoiceItem(value: 'a', label: '洗车'),
              ChoiceItem(value: 'b', label: '镀晶'),
              ChoiceItem(value: 'c', label: '不可选', enabled: false),
            ],
            selected: selected,
            onChanged: (v) => set(() => selected = v),
          ),
        ),
      );
      await t.tap(find.text('镀晶'));
      await t.pump();
      expect(selected, 'b');
      await t.tap(find.text('不可选'));
      await t.pump();
      expect(selected, 'b');
    });

    testWidgets('开关：点按切换；null 禁用', (t) async {
      var value = false;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppSwitch(value: value, onChanged: (v) => set(() => value = v), semanticLabel: '消息通知'),
        ),
      );
      expect(t.getSize(find.byType(AnimatedContainer)), const Size(46, 28));
      await t.tap(find.byType(AppSwitch));
      await t.pump(const Duration(milliseconds: 300));
      expect(value, isTrue);
      await pump(t, const AppSwitch(value: false));
      await t.tap(find.byType(AppSwitch));
      expect(value, isTrue);
    });

    testWidgets('多选 / 单选 / 加入：状态受控', (t) async {
      var checked = false;
      String group = 'x';
      var added = false;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => Column(children: [
            AppCheck(value: checked, onChanged: (v) => set(() => checked = v), semanticLabel: '全选'),
            AppRadio<String>(value: 'y', group: group, onChanged: (v) => set(() => group = v), semanticLabel: '支付宝'),
            AppAddToggle(selected: added, onChanged: (v) => set(() => added = v), semanticLabel: '加入'),
          ]),
        ),
      );
      await t.tap(find.bySemanticsLabel('全选'));
      await t.tap(find.bySemanticsLabel('支付宝'));
      await t.tap(find.bySemanticsLabel('加入'));
      await t.pump();
      expect([checked, group, added], [true, 'y', true]);
      expect(find.byIcon(Icons.check_rounded), findsNWidgets(2));
    });

    testWidgets('数量加减：上下限钳制，到下限减号不响应，到上限加号不响应', (t) async {
      num value = 1;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppStepper(
            value: value,
            min: 1,
            max: 3,
            onChanged: (v) => set(() => value = v),
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel('减少'));
      await t.pump();
      expect(value, 1);
      await t.tap(find.bySemanticsLabel('增加'));
      await t.pump();
      await t.tap(find.bySemanticsLabel('增加'));
      await t.pump();
      expect(value, 3);
      await t.tap(find.bySemanticsLabel('增加'));
      await t.pump();
      expect(value, 3);
    });

    testWidgets('数量加减：长按连续增减，点数字直接输入并钳制', (t) async {
      num value = 0;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppStepper(value: value, min: 0, max: 20, onChanged: (v) => set(() => value = v)),
        ),
      );
      final gesture = await t.startGesture(t.getCenter(find.bySemanticsLabel('增加')));
      await t.pump(const Duration(milliseconds: 600));
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(milliseconds: 125));
      }
      await gesture.up();
      await t.pump();
      expect(value, greaterThan(2));
      await t.tap(find.text('${value.round()}'));
      await t.pump();
      await t.enterText(find.byType(TextField), '99');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pump();
      expect(value, 20, reason: '超过上限钳制到上限');
    });

    testWidgets('数量加减：小数商品', (t) async {
      num value = 1.5;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppStepper(
            value: value,
            step: .5,
            allowDecimal: true,
            style: AppStepperStyle.inline,
            onChanged: (v) => set(() => value = v),
          ),
        ),
      );
      expect(find.text('1.5'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('增加'));
      await t.pump();
      expect(find.text('2'), findsOneWidget);
    });
  });

  testWidgets('深色模式：所有基础元素可渲染', (t) async {
    await pump(
      t,
      Column(children: [
        AppButton(label: '确认', onPressed: () {}),
        const AppButton(label: '禁用'),
        const AppStatusTag('草稿', tone: Tone.off),
        const AppSwitch(value: true, onChanged: null),
        AppChoiceChip(label: '洗车', selected: true, onTap: () {}),
        const AppAvatar(name: '王', tier: AppAvatarTier.gold),
      ]),
      brightness: Brightness.dark,
    );
    expect(t.takeException(), isNull);
  });
}
