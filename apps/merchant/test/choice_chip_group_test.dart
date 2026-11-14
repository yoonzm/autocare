import 'package:autocare_merchant/widgets/choice_chip_group.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSel, SelCtrl, hbox;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('单选标签始终只有一个完整的蓝色选中态，尺寸不变', (t) async {
    int? selected;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ChoiceChipGroup<int>(
              semanticLabel: '新日期',
              kind: ChipKind.pill,
              items: const [
                ChoiceChipItem(value: 0, label: '今天 11.03'),
                ChoiceChipItem(value: 1, label: '明天 11.04'),
              ],
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    BoxDecoration decoration(String label) =>
        (t
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.text(label),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration);
    final size = t.getSize(
      find
          .ancestor(
            of: find.text('今天 11.03'),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(decoration('今天 11.03').color, const Color(0xFFF4F4F5));
    await t.tap(find.text('今天 11.03'));
    await t.pump();
    expect(decoration('今天 11.03').color, const Color(0xFFE1F0FE));
    expect(
      (decoration('今天 11.03').border! as Border).top.color,
      const Color(0xFF0485F7),
    );
    expect(
      t.widget<Text>(find.text('今天 11.03')).style!.color,
      const Color(0xFF1E63AE),
    );
    expect(
      t.getSize(
        find
            .ancestor(
              of: find.text('今天 11.03'),
              matching: find.byType(GestureDetector),
            )
            .first,
      ),
      size,
    );
    await t.tap(find.text('明天 11.04'));
    await t.pump();
    expect(decoration('今天 11.03').color, const Color(0xFFF4F4F5));
    expect(decoration('明天 11.04').color, const Color(0xFFE1F0FE));
    expect(selected, 1);
    expect(size.height, 44);
  });

  testWidgets('原预约时间为灰色，禁用时间有删除线且不可选', (t) async {
    String? selected;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => ChoiceChipGroup<String>(
              semanticLabel: '新时间',
              kind: ChipKind.tile,
              items: const [
                ChoiceChipItem(
                  value: '17:30',
                  label: '17:30',
                  isOriginal: true,
                ),
                ChoiceChipItem(value: '18:00', label: '18:00', disabled: true),
                ChoiceChipItem(value: '18:30', label: '18:30'),
              ],
              selected: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
        ),
      ),
    );
    BoxDecoration decoration(String label) =>
        (t
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.text(label),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration);
    expect(decoration('17:30 原').color, const Color(0xFFEEEEF0));
    expect(
      (decoration('17:30 原').border! as Border).top.color,
      const Color(0xFFC7C7CC),
    );
    expect(
      t.widget<Text>(find.text('18:00')).style!.decoration,
      TextDecoration.lineThrough,
    );
    await t.tap(find.text('18:00'));
    await t.pump();
    expect(selected, isNull);
    await t.tap(find.text('17:30 原'));
    await t.pump();
    expect(selected, '17:30');
    expect(decoration('17:30 原').color, const Color(0xFFE1F0FE));
  });

  testWidgets('既有单选胶囊 HSel 走统一 ChoiceChip 样式', (t) async {
    final ctrl = SelCtrl({0}, false);
    addTearDown(ctrl.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HSel(
            ctrl: ctrl,
            index: 0,
            on: hbox(h: 34, child: const Text('洗车')),
            off: hbox(h: 34, child: const Text('洗车')),
          ),
        ),
      ),
    );
    expect(find.byType(ChoiceChipGroup<int>), findsOneWidget);
    final box = t.widget<Container>(
      find
          .ancestor(of: find.text('洗车'), matching: find.byType(Container))
          .first,
    );
    expect((box.decoration as BoxDecoration).color, const Color(0xFFE1F0FE));
  });
}
