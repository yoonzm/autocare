import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Widget _app(Widget home, {Brightness brightness = Brightness.light}) => MaterialApp(
  theme: ThemeData(brightness: brightness, extensions: [AppTokens.forBrightness(brightness)]),
  home: home,
);

void main() {
  testWidgets('页面头部：返回 / 关闭、标题居中、右侧入口', (t) async {
    var closed = 0;
    await pump(
      t,
      SizedBox(
        width: 350,
        child: Column(children: [
          AppPageHeader(title: '新增商品', leading: HeaderLeading.close, onLeading: () => closed++, trailing: const Icon(Icons.more_horiz)),
          const AppPageHeader(title: '全部商品'),
        ]),
      ),
    );
    expect(find.text('新增商品'), findsOneWidget);
    expect(find.bySemanticsLabel('返回'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('关闭'));
    expect(closed, 1);
  });

  testWidgets('底部操作栏：次要 : 主要 = 1 : 2，带金额摘要', (t) async {
    var primary = 0;
    var secondary = 0;
    await pump(
      t,
      SizedBox(
        width: 390,
        child: AppBottomBar(
          secondary: AppButton(label: '挂单', kind: AppButtonKind.secondary, onPressed: () => secondary++),
          primary: AppButton(label: '确认收款', onPressed: () => primary++),
        ),
      ),
      size: const Size(390, 844),
    );
    final w1 = t.getSize(find.ancestor(of: find.text('挂单'), matching: find.byType(Container)).first).width;
    final w2 = t.getSize(find.ancestor(of: find.text('确认收款'), matching: find.byType(Container)).first).width;
    expect((w2 / w1 - 2).abs(), lessThan(.2));
    await t.tap(find.text('确认收款'));
    await t.tap(find.text('挂单'));
    expect([primary, secondary], [1, 1]);
    await pump(
      t,
      SizedBox(
        width: 390,
        child: AppBottomBar(
          summary: const AppAmountSummary(caption: '应收 · 已优惠 ¥226', amount: '¥1,422.00'),
          primary: AppButton(label: '确认收款', onPressed: () {}),
        ),
      ),
    );
    expect(find.text('¥1,422.00'), findsOneWidget);
  });

  testWidgets('底部弹层：标题、内容、固定按钮；点按钮关闭并返回值', (t) async {
    String? result;
    await t.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showAppBottomSheet<String>(
          context,
          title: '选择供应商',
          builder: (_) => const Text('蓝盾膜业'),
          actions: [
            AppButton(label: '取消', kind: AppButtonKind.secondary, onPressed: () => Navigator.pop(context)),
            AppButton(label: '确定', onPressed: () => Navigator.pop(context, 'ok')),
          ],
        ),
        child: const Text('打开'),
      ),
    )));
    await t.tap(find.text('打开'));
    await t.pumpAndSettle();
    expect(find.text('选择供应商'), findsOneWidget);
    expect(find.text('蓝盾膜业'), findsOneWidget);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(result, 'ok');
  });

  testWidgets('底部弹层：有未保存内容时先二次确认', (t) async {
    await t.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () => showAppBottomSheet<void>(
          context,
          title: '新建',
          hasUnsavedChanges: () => true,
          builder: (_) => const Text('内容'),
        ),
        child: const Text('打开'),
      ),
    )));
    await t.tap(find.text('打开'));
    await t.pumpAndSettle();
    await t.tapAt(const Offset(20, 20)); // 点遮罩
    await t.pumpAndSettle();
    expect(find.text('放弃未保存的内容？'), findsOneWidget);
    await t.tap(find.text('继续编辑'));
    await t.pumpAndSettle();
    expect(find.text('新建'), findsOneWidget, reason: '继续编辑，弹层还在');
    await t.tapAt(const Offset(20, 20));
    await t.pumpAndSettle();
    await t.tap(find.text('放弃'));
    await t.pumpAndSettle();
    expect(find.text('新建'), findsNothing);
  });

  testWidgets('对话框：宽 280，取消在左；危险操作确认用危险色', (t) async {
    const tokens = AppTokens.light;
    bool? result;
    await t.pumpWidget(_app(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showAppDialog(context, title: '确认停用此商品？', message: '停用后不能再入库出库。', confirmLabel: '停用', cancelLabel: '再想想', danger: true),
        child: const Text('打开'),
      ),
    )));
    await t.tap(find.text('打开'));
    await t.pumpAndSettle();
    expect(find.text('停用后不能再入库出库。'), findsOneWidget);
    expect(t.getSize(find.descendant(of: find.byType(Dialog), matching: find.byType(ConstrainedBox)).first).width, 280);
    expect(t.getTopLeft(find.text('再想想')).dx, lessThan(t.getTopLeft(find.text('停用')).dx));
    final confirm = t.widget<Container>(find.ancestor(of: find.text('停用'), matching: find.byType(Container)).first);
    expect((confirm.decoration! as BoxDecoration).color, tokens.danger.bg);
    await t.tap(find.text('停用'));
    await t.pumpAndSettle();
    expect(result, isTrue);
    await t.tap(find.text('打开'));
    await t.pumpAndSettle();
    await t.tap(find.text('再想想'));
    await t.pumpAndSettle();
    expect(result, isFalse);
  });

  testWidgets('底部导航：4 项 + 中间扫码；当前项主色并有圆点', (t) async {
    var tab = 0;
    var scans = 0;
    await pump(
      t,
      SizedBox(
        width: 390,
        child: StatefulBuilder(
          builder: (context, set) => AppBottomNav(
            current: tab,
            onTap: (i) => set(() => tab = i),
            onScan: () => scans++,
            items: const [
              AppNavItem(label: '首页', icon: Icons.home_rounded),
              AppNavItem(label: '会员', icon: Icons.people_rounded),
              AppNavItem(label: '库存', icon: Icons.inventory_2_rounded),
              AppNavItem(label: '统计', icon: Icons.bar_chart_rounded),
            ],
          ),
        ),
      ),
    );
    const tokens = AppTokens.light;
    expect(t.widget<Text>(find.text('首页')).style!.color, tokens.primary);
    expect(t.widget<Text>(find.text('库存')).style!.color, tokens.inkMute);
    await t.tap(find.text('库存'));
    await t.pump();
    expect(tab, 2);
    expect(t.widget<Text>(find.text('库存')).style!.color, tokens.primary);
    await t.tap(find.bySemanticsLabel('扫码'));
    expect(scans, 1);
  });

  testWidgets('深色模式：容器可渲染', (t) async {
    await pump(
      t,
      SizedBox(
        width: 390,
        child: Column(children: [
          const AppPageHeader(title: '标题'),
          AppBottomBar(primary: AppButton(label: '确认', onPressed: () {})),
        ]),
      ),
      brightness: Brightness.dark,
    );
    expect(t.takeException(), isNull);
  });
}
