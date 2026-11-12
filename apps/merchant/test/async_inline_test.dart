import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/async_kit.dart';

void main() {
  testWidgets(
    'inline AsyncView takes content height in a scroll view while loading, refreshing and retrying',
    (t) async {
      var pending = Completer<String>();
      final key = GlobalKey<AsyncViewState<String>>();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AsyncView<String>(
                key: key,
                shrinkWrap: true,
                pullToRefresh: false,
                inlineError: true,
                load: () => pending.future,
                isEmpty: (_) => false,
                skeletonScrollable: false,
                skeleton: const SizedBox(
                  height: 40,
                  child: AppSkeleton(height: 40),
                ),
                empty: (_) => const SizedBox.shrink(),
                builder: (_, value) => SizedBox(height: 80, child: Text(value)),
              ),
            ),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 350));
      expect(t.takeException(), isNull);
      pending.complete('loaded');
      await t.pumpAndSettle();
      expect(find.text('loaded'), findsOneWidget);
      pending = Completer<String>();
      unawaited(key.currentState!.reload());
      await t.pump(const Duration(milliseconds: 350));
      expect(find.text('loaded'), findsOneWidget);
      expect(t.takeException(), isNull);
      pending.complete('refreshed');
      await t.pumpAndSettle();
      expect(find.text('refreshed'), findsOneWidget);
    },
  );
}
