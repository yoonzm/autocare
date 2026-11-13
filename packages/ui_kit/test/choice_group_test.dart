import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const items = [
  ChoiceItem(value: 0, label: '洗车'),
  ChoiceItem(value: 1, label: '美容'),
  ChoiceItem(value: 2, label: '已停用', enabled: false),
];
void main() {
  testWidgets('单选受控、重复点击不触发、禁用选中值不显示为有效', (t) async {
    int selected = 0;
    var calls = 0;
    await pump(
      t,
      StatefulBuilder(
        builder: (context, setState) => AppChoiceGroup<int>(
          items: items,
          selected: selected,
          onChanged: (v) => setState(() {
            selected = v;
            calls++;
          }),
        ),
      ),
    );
    await t.tap(find.text('洗车'));
    await t.pump();
    expect(calls, 0);
    await t.tap(find.text('美容'));
    await t.pump();
    expect(selected, 1);
    expect(calls, 1);
    await t.tap(find.text('已停用'));
    await t.pump();
    expect(selected, 1);
    expect(calls, 1);
    await pump(
      t,
      AppChoiceGroup<int>(items: items, selected: 2, onChanged: (_) {}),
    );
    expect(
      t
          .widgetList<AppChoiceChip>(find.byType(AppChoiceChip))
          .where((c) => c.selected),
      isEmpty,
    );
  });
  testWidgets('多选可增加与取消、集合不修改、受控刷新不串实例', (t) async {
    final initial = <int>{0};
    Set<int> values = initial;
    await pump(
      t,
      StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            AppChoiceGroup<int>.multiple(
              items: items,
              selectedValues: values,
              onChanged: (v) => setState(() => values = v),
            ),
            AppChoiceGroup<int>.multiple(
              items: const [ChoiceItem(value: 0, label: '独立')],
              selectedValues: const {0},
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );
    await t.tap(find.text('美容'));
    await t.pump();
    expect(values, {0, 1});
    expect(initial, {0});
    await t.tap(find.text('洗车'));
    await t.pump();
    expect(values, {1});
    await t.tap(find.text('已停用'));
    await t.pump();
    expect(values, {1});
    expect(
      t
          .widget<AppChoiceChip>(find.widgetWithText(AppChoiceChip, '独立'))
          .selected,
      isTrue,
    );
    await pump(
      t,
      AppChoiceGroup<int>.multiple(
        items: items,
        selectedValues: const {},
        onChanged: (_) {},
      ),
    );
    expect(
      t
          .widgetList<AppChoiceChip>(find.byType(AppChoiceChip))
          .any((c) => c.selected),
      isFalse,
    );
  });
  for (final dark in [false, true]) {
    testWidgets('三列等宽、换行间距与禁用态 $dark', (t) async {
      await pump(
        t,
        SizedBox(
          width: 320,
          child: AppChoiceGroup<int>(
            kind: ChipKind.tile,
            columns: 3,
            items: [
              ...items,
              const ChoiceItem(value: 3, label: '第四项'),
            ],
            selected: 0,
            onChanged: (_) {},
          ),
        ),
        brightness: dark ? Brightness.dark : Brightness.light,
      );
      final chips = find.byType(AppChoiceChip);
      expect(t.getSize(chips.at(0)).width, closeTo((320 - 16) / 3, 0.01));
      expect(t.getSize(chips.at(0)), t.getSize(chips.at(1)));
      expect(t.getTopLeft(chips.at(3)).dy - t.getTopLeft(chips.at(0)).dy, 52);
      final tokens = dark ? AppTokens.dark : AppTokens.light;
      expect(backgroundBehind(t, '洗车'), tokens.primarySoft);
      expect(t.widget<Text>(find.text('已停用')).style!.color, tokens.inkFaint);
    });
  }
  testWidgets('横向滚动保持单行，末项可点击且不溢出', (t) async {
    int? picked;
    await pump(
      t,
      SizedBox(
        width: 240,
        child: AppChoiceGroup<int>(
          layout: AppChoiceLayout.horizontal,
          items: [
            for (var i = 0; i < 12; i++) ChoiceItem(value: i, label: '分类 $i'),
          ],
          selected: 0,
          onChanged: (v) => picked = v,
        ),
      ),
    );
    expect(t.getSize(find.byType(AppChoiceGroup<int>)).height, 44);
    await t.drag(find.byType(SingleChildScrollView), const Offset(-2000, 0));
    await t.pumpAndSettle();
    await t.tap(find.text('分类 11'));
    expect(picked, 11);
    expect(t.takeException(), isNull);
  });
  testWidgets('横向末尾操作独立于筛选状态，单选与多选语义正确', (t) async {
    var actionCalls = 0;
    var filterCalls = 0;
    final semantics = t.ensureSemantics();
    await pump(
      t,
      AppChoiceGroup<int>(
        layout: AppChoiceLayout.horizontal,
        semanticLabel: '分类',
        items: items,
        selected: 0,
        onChanged: (_) => filterCalls++,
        trailing: TextButton(
          onPressed: () => actionCalls++,
          child: const Text('待回访'),
        ),
      ),
    );
    await t.tap(find.text('待回访'));
    expect(actionCalls, 1);
    expect(filterCalls, 0);
    expect(
      t
          .getSemantics(find.bySemanticsLabel('洗车'))
          .getSemanticsData()
          .flagsCollection
          .isInMutuallyExclusiveGroup,
      isTrue,
    );
    await pump(
      t,
      AppChoiceGroup<int>.multiple(
        items: items,
        selectedValues: const {0},
        onChanged: (_) {},
      ),
    );
    expect(
      t
          .getSemantics(find.bySemanticsLabel('洗车'))
          .getSemanticsData()
          .flagsCollection
          .isInMutuallyExclusiveGroup,
      isFalse,
    );
    semantics.dispose();
  });
  testWidgets('长文案和放大字体在网格内保持单行且不溢出', (t) async {
    await pump(
      t,
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: SizedBox(
          width: 320,
          child: AppChoiceGroup<int>(
            columns: 3,
            items: const [ChoiceItem(value: 0, label: '很长很长的分类名称')],
            selected: 0,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    expect(t.widget<Text>(find.text('很长很长的分类名称')).maxLines, 1);
    expect(t.takeException(), isNull);
  });
}
