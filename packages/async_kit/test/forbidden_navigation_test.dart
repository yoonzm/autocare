import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final inline in [false, true]) {
    testWidgets('403 returns to previous route without login (inline=$inline)', (
      tester,
    ) async {
      var loginCalls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => Scaffold(
                      body: errorView(
                        AppErrorType.forbidden,
                        () => loginCalls++,
                        inline: inline,
                      ),
                    ),
                  ),
                ),
                child: const Text('open inventory'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open inventory'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrorView), findsOneWidget);
      await tester.tap(find.text('返回'));
      await tester.pumpAndSettle();
      expect(loginCalls, 0);
      expect(find.text('open inventory'), findsOneWidget);
      expect(find.byType(ErrorView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('401 still invokes the login callback', (tester) async {
    var loginCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: errorView(AppErrorType.auth, () => loginCalls++),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('重新登录'));
    await tester.pumpAndSettle();
    expect(loginCalls, 1);
  });
}

Widget errorView(
  AppErrorType type,
  VoidCallback onLogin, {
  bool inline = false,
}) => AsyncView<int>(
  inlineError: inline,
  load: () async => throw AppError('request failed', type: type),
  isEmpty: (_) => false,
  skeleton: const SizedBox.shrink(),
  empty: (_) => const SizedBox.shrink(),
  builder: (_, _) => const Text('content'),
  onNext: onLogin,
);
