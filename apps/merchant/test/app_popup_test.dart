import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/widgets/app_popup_dialog.dart';

void main() {
  testWidgets('showAppPopupQueue renders multiple notices and dismisses in order', (
    tester,
  ) async {
    final dismissed = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAppPopupQueue(
                  context,
                  items: [
                    {
                      'id': 'p-1',
                      'title': '系统维护通知',
                      'body': '今晚 23:00 进行 10 分钟例行维护',
                      'created_at': '2026-11-26T08:00:00Z',
                    },
                    {
                      'id': 'p-2',
                      'title': '新功能上线',
                      'body': '支持站内信与 iOS 推送同步提醒',
                      'created_at': '2026-11-26T09:00:00Z',
                    },
                  ],
                  onDismiss: (id) async => dismissed.add(id),
                ),
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();

    expect(find.text('系统维护通知'), findsOneWidget);
    expect(find.text('1 / 2'), findsOneWidget);

    await tester.tap(find.text('下一条（1/2）'));
    await tester.pumpAndSettle();

    expect(dismissed, ['p-1']);
    expect(find.text('新功能上线'), findsOneWidget);
    expect(find.text('我知道了'), findsOneWidget);

    await tester.tap(find.text('我知道了'));
    await tester.pumpAndSettle();

    expect(dismissed, ['p-1', 'p-2']);
    expect(find.text('新功能上线'), findsNothing);
  });
}
