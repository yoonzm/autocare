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
      await t.pump();
      await t.pump(kIndicatorMinShow);
      await t.pumpAndSettle();
      expect(find.text('loaded'), findsOneWidget);
      pending = Completer<String>();
      final refresh = key.currentState!.reload();
      await t.pump(const Duration(milliseconds: 350));
      expect(find.text('loaded'), findsOneWidget);
      expect(key.currentState!.busy, isTrue);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(t.getSize(find.byType(AsyncView<String>)).height, 80);
      expect(t.takeException(), isNull);
      pending.complete('refreshed');
      // 没有进度条动画时 pumpAndSettle 不会等待最短展示计时器。
      // 先处理请求完成，再显式推进时间，避免依赖持续动画驱动测试时钟。
      await t.pump();
      expect(find.text('loaded'), findsOneWidget);
      await t.pump(kIndicatorMinShow);
      await refresh;
      await t.pumpAndSettle();
      expect(find.text('refreshed'), findsOneWidget);
      expect(key.currentState!.busy, isFalse);
      expect(t.getSize(find.byType(AsyncView<String>)).height, 80);
      expect(t.takeException(), isNull);
    },
  );
}
