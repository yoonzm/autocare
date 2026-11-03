import 'package:autocare_merchant/kit/kit.dart' show hConfirm;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('统一确认弹窗淡入缩放、关闭时平滑退出', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) => TextButton(
              onPressed: () => hConfirm(ctx, '确认操作？'),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('打开'));
    await t.pump();
    final scale = find.ancestor(
      of: find.byType(Dialog),
      matching: find.byType(ScaleTransition),
    );
    expect(scale, findsOneWidget);
    await t.pump(const Duration(milliseconds: 80));
    final entering = t.widget<ScaleTransition>(scale).scale.value;
    expect(entering, greaterThan(0.94));
    expect(entering, lessThan(1.02));
    await t.pumpAndSettle();
    expect(t.widget<ScaleTransition>(scale).scale.value, closeTo(1, 0.001));
    await t.tap(find.text('取消'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 60));
    expect(find.byType(Dialog), findsOneWidget);
    expect(t.widget<ScaleTransition>(scale).scale.value, lessThan(1));
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('减少动态效果时确认弹窗不缩放', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Builder(
              builder: (ctx) => TextButton(
                onPressed: () => hConfirm(ctx, '确认操作？'),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('打开'));
    await t.pump();
    expect(find.text('确认操作？'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(Dialog),
        matching: find.byType(ScaleTransition),
      ),
      findsNothing,
    );
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
