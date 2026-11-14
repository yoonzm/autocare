import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/pages/expenses/expense_controller.dart';
import 'package:autocare_merchant/pages/expenses/expenses_live_template.dart';
import 'package:autocare_merchant/pages/expenses/expense_add_live_template.dart';
import 'package:autocare_merchant/pages/expenses/expense_detail_live_template.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:autocare_merchant/kit/async_kit.dart';

void main() {
  setUpAll(() async {
    final f = File('C:/Windows/Fonts/msyh.ttc');
    if (f.existsSync()) {
      final loader = FontLoader('ExpenseTest')
        ..addFont(Future.value(f.readAsBytesSync().buffer.asByteData()));
      await loader.load();
    }
  });
  final entry = <String, dynamic>{
    'id': '10000000-0000-0000-0000-000000000001',
    'revision': 0,
    'category': '水电',
    'amount': 123.45,
    'occurred_on': '2026-11-03',
    'account': '微信',
    'status': 'unpaid',
    'payee': '真实收款方',
    'note': '实际电费',
    'repeat': false,
    'attachments': [],
  };
  Map<String, dynamic> board() => {
    'items': [entry],
    'revenue': 1000,
    'history': [
      {'month': '2026-10-01', 'category': '水电', 'amount': 100},
    ],
  };
  for (final dark in [false, true]) {
    for (final mode in ['list', 'add', 'detail']) {
      testWidgets(
        'expense $mode ${dark ? 'dark' : 'light'} real data and layout',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          C.dark = dark;
          final c = ExpenseController(
            mode,
            '2026-11-01',
            board(),
            entry: mode == 'add' || mode == 'detail' ? entry : null,
          );
          final key = GlobalKey();
          Widget page() => switch (mode) {
            'list' => ExpensesLiveTemplate(c: c),
            'add' => ExpenseAddLiveTemplate(c: c),
            _ => ExpenseDetailLiveTemplate(c: c),
          };
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                fontFamily: 'ExpenseTest',
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              home: Scaffold(
                body: RepaintBoundary(
                  key: key,
                  child: ListenableBuilder(
                    listenable: c,
                    builder: (_, _) => page(),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('167,070.00'), findsNothing);
          expect(find.text('蓝盾膜业'), findsNothing);
          expect(find.text('97.7%'), findsNothing);
          if (mode == 'add') {
            await tester.enterText(find.byType(TextField).first, '29.50');
            await tester.pump();
            expect(c.draft['amount'], 29.5);
            expect(c.dirty, true);
          }
          const out = String.fromEnvironment('EXPENSE_RENDER');
          if (out.isNotEmpty) {
            await tester.runAsync(() async {
              final image =
                  await (key.currentContext!.findRenderObject()
                          as RenderRepaintBoundary)
                      .toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              await Directory(out).create(recursive: true);
              await File('$out/$mode-${dark ? 'dark' : 'light'}.png')
                  .writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          await tester.pumpWidget(const SizedBox());
          c.dispose();
        },
      );
    }
  }
  test('new expense contains no sample form values', () {
    final c = ExpenseController('add', '2026-11-01', board());
    expect(c.draft['amount'], null);
    expect(c.draft['payee'], '');
    expect(c.draft['note'], '');
    expect(c.draft['attachments'], isEmpty);
    c.dispose();
  });
  testWidgets('failed write preserves form, category and identity for retry', (
    tester,
  ) async {
    Map<String, dynamic>? sent;
    final c = ExpenseController(
      'add',
      '2026-11-01',
      board(),
      entry: entry,
      request: (body, {requestId}) async {
        sent = body;
        throw const AppError('预算不足');
      },
    );
    c.setEntryAmount('20.50');
    c.draft['category'] = '人工';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => c.save(context),
              child: const Text('提交'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('提交'));
    await tester.pumpAndSettle();
    expect(sent?['amount'], 20.5);
    expect(sent?['category'], '人工');
    expect(sent?['action'], 'expense_save');
    expect(c.dirty, true);
    expect(c.busy, false);
    expect(c.draft['id'], entry['id']);
    await tester.pumpWidget(const SizedBox());
    c.dispose();
  });
}
