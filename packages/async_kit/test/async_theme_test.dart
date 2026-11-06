import 'dart:async';

import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'two independently themed hosts do not share brightness or colors',
    (tester) async {
      final dark = ValueNotifier(false);
      addTearDown(dark.dispose);
      const first = ValueKey('first-skeleton');
      const second = ValueKey('second-skeleton');
      Widget skeleton(Key key) => MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: AppSkeleton(key: key, width: 90, height: 18),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: dark,
                builder: (_, value, _) => Theme(
                  data: ThemeData(
                    brightness: value ? Brightness.dark : Brightness.light,
                  ),
                  child: skeleton(first),
                ),
              ),
              Theme(
                data: ThemeData(
                  extensions: [
                    AsyncKitTheme.standard(Brightness.light)
                        .copyWith(skeletonBase: Colors.purple),
                  ],
                ),
                child: skeleton(second),
              ),
            ],
          ),
        ),
      );
      Color? color(Key key) =>
          (tester
                      .widget<Container>(
                        find.descendant(
                          of: find.byKey(key),
                          matching: find.byType(Container),
                        ),
                      )
                      .decoration
                  as BoxDecoration)
              .color;
      expect(color(first), const Color(0xFFE4E4E7));
      expect(color(second), Colors.purple);
      dark.value = true;
      await tester.pump();
      expect(color(first), const Color(0xFF2A2A2E));
      expect(color(second), Colors.purple);
    },
  );

  testWidgets('permission copy is supplied by the host theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            AsyncKitTheme.standard(
              Brightness.light,
              permissionHint: 'Contact this host administrator',
            ),
          ],
        ),
        home: const Scaffold(
          body: ErrorView(
            error: AppError('forbidden', type: AppErrorType.forbidden),
          ),
        ),
      ),
    );
    expect(find.text('Contact this host administrator'), findsOneWidget);
    expect(find.textContaining('店主'), findsNothing);
  });

  testWidgets('button loading honors contextual tokens and keeps its size', (
    tester,
  ) async {
    final pending = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          extensions: [
            AsyncKitTheme.standard(Brightness.light)
                .copyWith(primary: Colors.teal),
          ],
        ),
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: LoadingButton(
              label: 'Save',
              onPressed: () => pending.future,
            ),
          ),
        ),
      ),
    );
    final before = tester.getSize(find.byType(LoadingButton));
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(LoadingButton),
        matching: find.byType(Container),
      ),
    );
    expect((box.decoration as BoxDecoration).color, Colors.teal);
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    expect(tester.getSize(find.byType(LoadingButton)), before);
    pending.complete();
    await tester.pumpAndSettle();
  });

  test(
    'theme extension preserves custom tokens during copy and interpolation',
    () {
      final light = AsyncKitTheme.standard(Brightness.light);
      final dark = AsyncKitTheme.standard(Brightness.dark);
      expect(light.copyWith(primary: Colors.orange).primary, Colors.orange);
      expect(
        light.copyWith(primary: Colors.orange).skeletonGlow,
        light.skeletonGlow,
      );
      expect(light.lerp(dark, .5).card, Color.lerp(light.card, dark.card, .5));
      expect(light.lerp(null, .5), same(light));
    },
  );
}
