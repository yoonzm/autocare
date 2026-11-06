import 'package:autocare_admin/data/admin_api.dart';
import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/pages/tickets_pages.dart';
import 'package:autocare_admin/theme.dart';
import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ScreenshotApi extends AdminApi {
  final ids = <String>[];
  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'ticket_attachment') {
      ids.add(values['id'] as String);
      throw const AppError('读取截图失败', type: AppErrorType.server);
    }
    return {};
  }
}

void main() {
  tearDown(() {
    store = Store();
    C.dark = false;
  });
  for (final dark in [false, true]) {
    testWidgets(
      'operator reads feedback metadata and can retry private screenshot ${dark ? 'dark' : 'light'}',
      (t) async {
        C.dark = dark;
        final api = _ScreenshotApi();
        store = Store(api: api);
        final ticket = Ticket.fromJson({
          'id': 'ticket-1',
          'title': '问题报告 · 保存失败',
          'merchant': '实际门店',
          'owner': '店主',
          'time': '2026-11-06T01:00:00Z',
          'status': 'todo',
          'msgs': [
            {
              'from_merchant': true,
              'text': '保存失败\n\n反馈类型：问题报告\n联系方式：owner@example.com',
              'attachments': ['private-id'],
            },
          ],
        });
        store.tickets = [ticket];
        t.view.physicalSize = const Size(390, 844);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.reset);
        final old = FlutterError.onError;
        FlutterError.onError = (details) {
          if (!details.exceptionAsString().contains('overflowed')) {
            old?.call(details);
          }
        };
        addTearDown(() => FlutterError.onError = old);
        await t.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            home: TicketDetailPage(ticket),
          ),
        );
        await t.pumpAndSettle();
        expect(find.textContaining('联系方式：owner@example.com'), findsOneWidget);
        expect(api.ids, ['private-id']);
        expect(find.text('重试'), findsOneWidget);
        await t.ensureVisible(find.text('重试'));
        await t.tap(find.text('重试'));
        await t.pumpAndSettle();
        expect(api.ids, ['private-id', 'private-id']);
        expect(t.takeException(), isNull);
      },
    );
  }
}
