import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/expenses/expense_controller.dart';
import 'package:autocare_merchant/pages/expenses/expense_live_page.dart';
import 'package:autocare_merchant/pages/expenses/expenses_live_template.dart';

import 'members_test.dart' show MemberFakeApi, phone;

Map<String, dynamic> entry([String id = 'e1']) => {
  'id': id,
  'revision': 0,
  'amount': 42,
  'category': '水电',
  'occurred_on': '2026-11-01',
  'account': '现金',
  'payee': '收款方$id',
  'status': 'paid',
  'note': '备注$id',
  'repeat': false,
  'attachments': ['voucher-a'],
};
Map<String, dynamic> board([num revenue = 1000]) => {
  'items': [entry()],
  'history': [],
  'revenue': revenue,
};

class ExpenseApi extends MemberFakeApi {
  final calls = <Map<String, dynamic>>[];
  Object? fail;
  Completer<Map<String, dynamic>>? write, suggestion;
  bool deferBoards = false, deferEntries = false;
  final boards = <Completer<Map<String, dynamic>>>[],
      entries = <Completer<Map<String, dynamic>>>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 20),
    String? requestId,
  }) async {
    calls.add({'body': body, 'requestId': requestId});
    switch (body['action']) {
      case 'expense_board':
        if (!deferBoards) return {'item': board()};
        final c = Completer<Map<String, dynamic>>();
        boards.add(c);
        return c.future;
      case 'expense_get':
        if (!deferEntries) return {'item': entry('${body['id']}')};
        final c = Completer<Map<String, dynamic>>();
        entries.add(c);
        return c.future;
      case 'expense_suggest':
        if (suggestion != null) return suggestion!.future;
        return {
          'item': {'categories': {}},
        };
      default:
        if (write != null) return write!.future;
        if (fail != null) throw fail!;
        return {
          'item': {...body, 'revision': (body['revision'] as int? ?? 0) + 1},
        };
    }
  }

  List<Map<String, dynamic>> get writes => calls
      .where(
        (c) => const [
          'expense_save',
          'expense_delete',
          'expense_budget_save',
          'expense_budget_adjust',
        ].contains(c['body']['action']),
      )
      .toList();
}

void main() {
  late MerchantApi original;
  late ExpenseApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = ExpenseApi();
  });
  tearDown(() {
    merchantApi = original;
  });

  test('编辑实例深拷贝输入；失败保留金额、凭证，重试沿用请求标识', () async {
    final source = board(), row = entry();
    final a = ExpenseController('add', '2026-11-01', source, entry: row);
    final b = ExpenseController('add', '2026-11-01', source, entry: row);
    a.setEntryAmount('20.50');
    (a.draft['attachments'] as List).add('new-voucher');
    expect(b.draft['amount'], 42);
    expect(row['attachments'], ['voucher-a']);
    api.fail = const AppError.timeout();
    await expectLater(a.persist(), throwsA(isA<AppError>()));
    expect(a.draft['amount'], 20.5);
    expect(a.dirty, isTrue);
    api.fail = null;
    expect(await a.persist(), isNotNull);
    expect(api.writes[0]['requestId'], isNotNull);
    expect(api.writes[0]['requestId'], api.writes[1]['requestId']);
    expect(await a.persist(), isNull);
    expect(a.saveKey, isNot(b.saveKey));
    expect(a.uploadKey, isNot(b.uploadKey));
    a.dispose();
    b.dispose();
  });

  test('提交期间冻结请求体、防重复，释放实例后真实写入仍交付结果但不通知页面', () async {
    final c = ExpenseController('add', '2026-11-01', board(), entry: entry());
    var notifications = 0;
    c.addListener(() => notifications++);
    api.write = Completer<Map<String, dynamic>>();
    final save = c.persist();
    expect(await c.persist(), isNull);
    c.draft['note'] = '后来改动';
    expect(api.writes.single['body']['note'], '备注e1');
    expect(
      () => (api.writes.single['body']['attachments'] as List).add('bad'),
      throwsUnsupportedError,
    );
    c.dispose();
    api.write!.complete({'item': entry()});
    expect(await save, isNotNull);
    expect(notifications, 1);
    expect(api.writes.length, 1);
  });

  testWidgets('删除失败保留确认弹窗；成功重试相同标识后才关闭页面', (t) async {
    phone(t);
    final c = ExpenseController(
      'detail',
      '2026-11-01',
      board(),
      entry: entry(),
    );
    api.fail = const AppError('删除失败');
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => Scaffold(
                    body: Builder(
                      builder: (context) => TextButton(
                        onPressed: () => c.save(context, remove: true),
                        child: const Text('删除记录'),
                      ),
                    ),
                  ),
                ),
              ),
              child: const Text('打开'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('打开'));
    await t.pumpAndSettle();
    await t.tap(find.text('删除记录'));
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(find.text('确认删除这笔开支？'), findsOneWidget);
    expect(find.text('删除记录'), findsOneWidget);
    expect(api.writes.length, 1);
    api.fail = null;
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(api.writes.length, 2);
    expect(api.writes[0]['requestId'], api.writes[1]['requestId']);
    expect(find.text('删除记录'), findsNothing);
    c.dispose();
  });

  testWidgets('详情页切换目标后只接收对应记录，旧响应不覆盖新记录', (t) async {
    phone(t);
    api.deferEntries = true;
    Future<void> show(String id) => t.pumpWidget(
      MaterialApp(
        home: ExpenseLivePage(mode: 'detail', id: id, month: '2026-11-01'),
      ),
    );
    await show('old');
    await t.pump();
    await show('new');
    await t.pump();
    api.entries[1].complete({'item': entry('new')});
    await t.pumpAndSettle();
    expect(find.text('收款方new'), findsOneWidget);
    api.entries[0].complete({'item': entry('old')});
    await t.pumpAndSettle();
    expect(find.text('收款方new'), findsOneWidget);
    expect(find.text('收款方old'), findsNothing);
    expect(
      api.calls.where((c) => c['body']['action'] == 'expense_board').length,
      2,
    );
  });

  testWidgets('刷新期间切月丢弃旧月份，读取结束后处理刷新且不重复拉取', (t) async {
    phone(t);
    api.deferBoards = true;
    await t.pumpWidget(
      const MaterialApp(
        home: ExpenseLivePage(mode: 'list', month: '2026-11-01'),
      ),
    );
    api.boards[0].complete({'item': board()});
    await t.pumpAndSettle();
    final c = t
        .widget<ExpensesLiveTemplate>(find.byType(ExpensesLiveTemplate))
        .c;
    expenseChanged.value++;
    await t.pump();
    c.shiftMonth(1);
    api.boards[1].complete({'item': board(111)});
    await t.pump();
    expect(api.calls.last['body']['month'], '2026-12-01');
    api.boards[2].complete({'item': board(999)});
    await t.pumpAndSettle();
    expect(c.revenue, 999);
    expect(c.month, '2026-12-01');
    expect(api.boards.length, 3);
  });
}
