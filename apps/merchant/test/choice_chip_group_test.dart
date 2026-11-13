import 'package:autocare_ui_kit/autocare_ui_kit.dart';
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
            builder: (context, setState) => AppChoiceGroup<int>(
              semanticLabel: '新日期',
              kind: ChipKind.pill,
              items: const [
                ChoiceItem(value: 0, label: '今天 11.03'),
                ChoiceItem(value: 1, label: '明天 11.04'),
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

  testWidgets('预约时间不再标原，禁用时间不可选', (t) async {
    String? selected;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppChoiceGroup<String>(
              semanticLabel: '新时间',
              kind: ChipKind.tile,
              columns: 3,
              items: const [
                ChoiceItem(value: '17:30', label: '17:30'),
                ChoiceItem(value: '18:00', label: '18:00', enabled: false),
                ChoiceItem(value: '18:30', label: '18:30'),
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
    expect(decoration('17:30').color, const Color(0xFFF4F4F5));
    expect(
      (decoration('17:30').border! as Border).top.color,
      Colors.transparent,
    );
    expect(
      t.widget<Text>(find.text('18:00')).style!.decoration,
      isNot(TextDecoration.lineThrough),
    );
    await t.tap(find.text('18:00'));
    await t.pump();
    expect(selected, isNull);
    await t.tap(find.text('17:30'));
    await t.pump();
    expect(selected, '17:30');
    expect(decoration('17:30').color, const Color(0xFFE1F0FE));
  });

  testWidgets('保留的 HSel 复杂选择只渲染调用者布局', (t) async {
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
    expect(find.byType(AppChoiceGroup<int>), findsNothing);
    expect(find.text('洗车'), findsOneWidget);
  });
}
