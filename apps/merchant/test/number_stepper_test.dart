import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/kit.dart';

void main() {
  testWidgets('通用数字增减控件按步长变化且不低于零', (t) async {
    final ctrl = ValCtrl(10);
    addTearDown(ctrl.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HNumberStepper(
              ctrl: ctrl,
              step: 10,
              minus: const SizedBox(width: 40, height: 40, child: Text('−')),
              value: hCount(ctrl, const TextStyle(fontSize: 16)),
              plus: const SizedBox(width: 40, height: 40, child: Text('+')),
            ),
          ),
        ),
      ),
    );
    expect(find.text('10'), findsOneWidget);
    await t.tap(find.text('−'));
    await t.pump();
    expect(ctrl.v, 0);
    await t.tap(find.text('−'));
    await t.pump();
    expect(ctrl.v, 0);
    await t.tap(find.text('+'));
    await t.pump();
    expect(ctrl.v, 10);
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('数值格式仍由 hCount 控制', (t) async {
    final ctrl = ValCtrl(75);
    addTearDown(ctrl.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HNumberStepper(
              ctrl: ctrl,
              step: 1,
              minus: const SizedBox(width: 30, height: 30, child: Text('−')),
              value: hCount(ctrl, const TextStyle(), 1, ' 折'),
              plus: const SizedBox(width: 30, height: 30, child: Text('+')),
            ),
          ),
        ),
      ),
    );
    expect(find.text('7.5 折'), findsOneWidget);
    await t.tap(find.text('+'));
    await t.pump();
    expect(find.text('7.6 折'), findsOneWidget);
  });
}
