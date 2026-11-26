import 'package:autocare_admin/theme.dart';
import 'package:autocare_admin/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpAdPage(
  WidgetTester t, {
  String? title = '商家',
  bool back = false,
  double gap = 16,
  Future<void> Function()? onRefresh,
  required List<Widget> children,
}) async {
  t.view.physicalSize = const Size(390, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      theme: buildTheme(),
      home: AdPage(
        title: title,
        back: back,
        gap: gap,
        onRefresh: onRefresh,
        children: children,
      ),
    ),
  );
}

void main() {
  testWidgets('固定顶栏：内容滚动后顶栏位置不变，滚动时才出现底部分隔线', (t) async {
    await _pumpAdPage(
      t,
      title: '商家',
      children: [
        for (var i = 0; i < 30; i++)
          SizedBox(height: 50, child: Text('商家条目 $i')),
      ],
    );

    final headerTop = t.getTopLeft(find.byType(AppPageHeader));
    BorderSide divider() {
      final box = t.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byType(AppPageHeader),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return ((box.decoration as BoxDecoration).border! as Border).bottom;
    }

    expect(divider().color, Colors.transparent);

    await t.drag(find.byType(ListView), const Offset(0, -300));
    await t.pump();
    expect(t.getTopLeft(find.byType(AppPageHeader)), headerTop);
    expect(divider().color, isNot(Colors.transparent));

    await t.drag(find.byType(ListView), const Offset(0, 300));
    await t.pumpAndSettle();
    expect(t.getTopLeft(find.byType(AppPageHeader)), headerTop);
    expect(divider().color, Colors.transparent);
  });

  testWidgets('静止状态间距：顶栏与首个内容块保持原 gap 间距', (t) async {
    await _pumpAdPage(
      t,
      title: '短信记录',
      gap: 14,
      children: const [SizedBox(key: ValueKey('first'), height: 40)],
    );

    final headerBottom = t.getBottomLeft(find.byType(AppPageHeader)).dy;
    final firstTop = t.getTopLeft(find.byKey(const ValueKey('first'))).dy;
    expect(firstTop - headerBottom, 14);
  });

  testWidgets('无标题页面不渲染 AppPageHeader 且内容正常展示', (t) async {
    await _pumpAdPage(
      t,
      title: null,
      children: const [Text('无标题内容')],
    );

    expect(find.byType(AppPageHeader), findsNothing);
    expect(find.text('无标题内容'), findsOneWidget);
  });

  testWidgets('固定顶栏下下拉刷新仍可正常触发', (t) async {
    var refreshed = 0;
    await _pumpAdPage(
      t,
      title: '概览',
      onRefresh: () async => refreshed++,
      children: const [SizedBox(height: 120, child: Text('概览内容'))],
    );

    await t.drag(find.byType(ListView), const Offset(0, 300));
    await t.pumpAndSettle();
    expect(refreshed, 1);
  });
}
