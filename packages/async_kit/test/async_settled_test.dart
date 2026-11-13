import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_async_kit/async_kit.dart';

void main() {
  testWidgets(
    'settled clears the loading lock on both errors and success, allowing a queued refresh',
    (t) async {
      final key = GlobalKey<AsyncViewState<int>>();
      var calls = 0, settled = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncView<int>(
              key: key,
              load: () async {
                if (++calls == 1) throw const AppError.network();
                return 42;
              },
              isEmpty: (_) => false,
              skeleton: const Text('loading'),
              empty: (_) => const Text('empty'),
              builder: (_, value) => Text('result:$value'),
              onSettled: () {
                expect(key.currentState!.busy, isFalse);
                settled++;
                if (settled == 1) key.currentState!.reload();
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(calls, 2);
      expect(settled, 2);
      expect(find.text('result:42'), findsOneWidget);
    },
  );

  testWidgets('a disposed async host does not deliver settled callbacks', (
    t,
  ) async {
    final pending = Completer<int>();
    var settled = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AsyncView<int>(
            load: () => pending.future,
            isEmpty: (_) => false,
            skeleton: const Text('loading'),
            empty: (_) => const Text('empty'),
            builder: (_, value) => Text('$value'),
            onSettled: () => settled++,
          ),
        ),
      ),
    );
    await t.pumpWidget(const SizedBox());
    pending.complete(42);
    await t.pumpAndSettle();
    expect(settled, 0);
  });
}
