import 'package:autocare_ui_kit/autocare_ui_kit.dart';

import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const items = [
  SegmentItem(value: 0, label: '全部', count: 12),
  SegmentItem(value: 1, label: '待处理', count: 0),
  SegmentItem(value: 2, label: '停用', enabled: false),
];
void main() {
  testWidgets('受控切换、重复点击、单项和整组禁用', (t) async {
    var selected = 0;
    var calls = 0;
    await pump(
      t,
      StatefulBuilder(
        builder: (_, set) => AppSegmented<int>(
          items: items,
          selected: selected,
          onChanged: (v) => set(() {
            selected = v;
            calls++;
          }),
        ),
      ),
    );
    await t.tap(find.text('全部 12', findRichText: true));
    expect(calls, 0);
    await t.tap(find.text('待处理 0', findRichText: true));
    await t.pump();
    expect(selected, 1);
    await t.tap(find.text('停用', findRichText: true));
    expect(calls, 1);
    await pump(
      t,
      AppSegmented<int>(
        items: items,
        selected: 1,
        enabled: false,
        onChanged: (_) => calls++,
      ),
    );
    await t.tap(find.text('全部 12', findRichText: true));
    expect(calls, 1);
  });
  testWidgets('数量零可见、告警兼容、读屏含数量和互斥状态', (t) async {
    final semantics = t.ensureSemantics();
    await pump(
      t,
      AppSegmented<int>(
        items: const [
          SegmentItem(value: 0, label: '全部', count: 0),
          SegmentItem(value: 1, label: '异常', badge: 3, enabled: false),
        ],
        selected: 0,
        onChanged: (_) {},
      ),
    );
    expect(find.text('全部 0', findRichText: true), findsOneWidget);
    expect(find.text('异常 3', findRichText: true), findsOneWidget);
    final active = t
        .getSemantics(find.bySemanticsLabel('全部 0'))
        .getSemanticsData();
    expect(active.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
    expect(active.flagsCollection.isSelected, Tristate.isTrue);
    expect(
      t.getSemantics(find.bySemanticsLabel('异常，提醒 3')),
      matchesSemantics(
        label: '异常，提醒 3',
        isButton: true,
        hasEnabledState: true,
        isEnabled: false,
        hasSelectedState: true,
        isInMutuallyExclusiveGroup: true,
      ),
    );
    semantics.dispose();
  });
  testWidgets('五项日期在窄屏完整切换，超过五项拒绝', (t) async {
    var selected = 0;
    const labels = ['今日', '昨日', '本周', '本月', '自定义'];
    await pump(
      t,
      StatefulBuilder(
        builder: (_, set) => AppSegmented<int>(
          items: [
            for (var i = 0; i < labels.length; i++)
              SegmentItem(value: i, label: labels[i]),
          ],
          selected: selected,
          onChanged: (v) => set(() => selected = v),
        ),
      ),
      size: const Size(320, 700),
    );
    await t.tap(find.text('自定义', findRichText: true));
    await t.pump();
    expect(selected, 4);
    expect(t.takeException(), isNull);
    expect(
      () => AppSegmented<int>(
        items: [for (var i = 0; i < 6; i++) SegmentItem(value: i, label: '$i')],
        selected: 0,
        onChanged: (_) {},
      ),
      throwsAssertionError,
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets('等宽与紧凑布局、窄屏大字不溢出 $brightness', (t) async {
      for (final layout in AppSegmentedLayout.values) {
        await pump(
          t,
          MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: AppSegmented<int>(
              layout: layout,
              items: const [
                SegmentItem(value: 0, label: '很长的分类名称', count: 12345),
                SegmentItem(value: 1, label: '另一分类'),
              ],
              selected: 0,
              onChanged: (_) {},
            ),
          ),
          brightness: brightness,
          size: const Size(320, 700),
        );
        expect(t.takeException(), isNull);
        expect(t.getSize(find.byType(AppSegmented<int>)).height, 40);
      }
      await pump(
        t,
        AppSegmented<int>(
          layout: AppSegmentedLayout.compact,
          items: const [
            SegmentItem(value: 0, label: '先生'),
            SegmentItem(value: 1, label: '女士'),
          ],
          selected: 0,
          onChanged: (_) {},
        ),
        brightness: brightness,
      );
      expect(t.getSize(find.byType(AppSegmented<int>)).width, lessThan(250));
    });
  }
}
