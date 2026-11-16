import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/expenses/expense_controller.dart';
import 'package:autocare_merchant/pages/expenses/expense_widgets.dart';
import 'package:autocare_merchant/pages/inventory/inventory_management_page.dart';
import 'package:autocare_merchant/pages/expenses/expense_live_page.dart';
import 'package:autocare_merchant/pages/expenses/expenses_live_template.dart';
import 'package:autocare_merchant/pages/expenses/expense_detail_live_template.dart';

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
  Map<String, dynamic>? getOverride;
  bool unpaidBoard = false;
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
        if (!deferBoards) {
          return {
            'item': unpaidBoard
                ? {
                    ...board(),
                    'items': [
                      {...entry('u1'), 'status': 'unpaid'},
                    ],
                  }
                : board(),
          };
        }
        final c = Completer<Map<String, dynamic>>();
        boards.add(c);
        return c.future;
      case 'expense_get':
        if (!deferEntries) {
          return {'item': getOverride ?? entry('${body['id']}')};
        }
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
        home: ExpenseLivePage(mode: 'list', month: '2020-11-01'),
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
    expect(api.calls.last['body']['month'], '2020-12-01');
    api.boards[2].complete({'item': board(999)});
    await t.pumpAndSettle();
    expect(c.revenue, 999);
    expect(c.month, '2020-12-01');
    expect(api.boards.length, 3);
  });

  test('月份切换：本月不能再往后翻，往前翻后可以回到本月', () {
    var reloads = 0;
    final c = ExpenseController('list', ExpenseController.currentMonth, {
      'items': [],
      'revenue': 0,
      'history': [],
    })..reload = () => reloads++;
    expect(c.canNext, false);
    c.shiftMonth(1);
    expect(c.month, ExpenseController.currentMonth);
    expect(reloads, 0);
    c.shiftMonth(-1);
    expect(c.canNext, true);
    expect(reloads, 1);
    c.shiftMonth(1);
    expect(c.month, ExpenseController.currentMonth);
    expect(c.canNext, false);
    expect(reloads, 2);
  });

  testWidgets('开支来源是库存单时进入库存单详情，手工记账不跳转', (t) async {
    phone(t);
    final manual = ExpenseController('detail', '2026-11-01', {
      'items': [],
    }, entry: entry());
    final stock = ExpenseController(
      'detail',
      '2026-11-01',
      {'items': []},
      entry: {...entry(), 'source_document': 'doc-1'},
    );
    expect(manual.hasSourceDocument, false);
    expect(stock.hasSourceDocument, true);
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );
    manual.openSource(ctx);
    await t.pump();
    expect(find.byType(InventoryManagementPage), findsNothing);
    stock.openSource(ctx);
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    final page = t.widget<InventoryManagementPage>(
      find.byType(InventoryManagementPage),
    );
    expect(page.mode, 'document');
    expect(page.documentId, 'doc-1');
  });

  testWidgets('开支日期用滚轮选择，确认后仍以 yyyy-MM-dd 保存，旧日期不会让滚轮报错', (t) async {
    phone(t);
    final c = ExpenseController(
      'detail',
      '2026-11-01',
      {'items': []},
      entry: {...entry(), 'occurred_on': '2020-03-05'},
    );
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            ctx = context;
            return const SizedBox();
          },
        ),
      ),
    );
    final future = c.pickDate(ctx);
    await t.pumpAndSettle();
    expect(find.text('选择日期'), findsOneWidget);
    expect(find.byType(CupertinoDatePicker), findsOneWidget);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    await future;
    expect(c.draft['occurred_on'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
  });

  testWidgets('占位文字样式独立于输入样式：金额框占位为浅灰常规粗细', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseInput(
            value: '',
            hint: '0.00',
            onChanged: (_) {},
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
            hintStyle: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w400,
              color: Color(0xFFA1A1AA),
            ),
          ),
        ),
      ),
    );
    final field = t.widget<TextField>(find.byType(TextField));
    expect(field.decoration!.hintText, '0.00');
    expect(field.decoration!.hintStyle!.fontWeight, FontWeight.w400);
    expect(field.decoration!.hintStyle!.color, const Color(0xFFA1A1AA));
    expect(field.style!.fontWeight, FontWeight.w600);
  });

  testWidgets('分类图标跟随分类：各分类不同，未收录分类沿用「其他」', (t) async {
    late BuildContext ctx;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
    );
    final icons = {
      for (final k in ['房租', '水电', '人工', '材料采购', '设备维修', '营销推广', '税费', '其他'])
        k: expenseCategorySvg(ctx, k),
    };
    expect(icons.values.toSet().length, icons.length);
    expect(expenseCategorySvg(ctx, '损耗'), icons['其他']);
    expect(expenseCategorySvg(ctx, null), icons['其他']);
  });

  testWidgets('待付款记录才有「确认付款」；点击后取完整记录，只把状态改为已付款再保存', (t) async {
    phone(t);
    api.getOverride = {...entry('u1'), 'status': 'unpaid', 'repeat': true};
    final c = ExpenseController('list', '2026-11-01', {
      'items': [
        {...entry('u1'), 'status': 'unpaid'},
        entry('p1'),
      ],
      'history': [],
      'revenue': 1000,
    });
    var changed = 0;
    void on() => changed++;
    expenseChanged.addListener(on);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpensesLiveTemplate(c: c)),
      ),
    );
    await t.pump();
    expect(find.text('确认付款'), findsOneWidget);
    await t.tap(find.text('确认付款'));
    await t.pump(const Duration(milliseconds: 400));
    expect(api.writes, isEmpty, reason: '点列表上的按钮只弹确认，不直接付款');
    expect(find.text('确认已付款？'), findsOneWidget);
    await t.tap(find.text('确认付款').last);
    await t.pump();
    await t.pumpAndSettle(const Duration(seconds: 1));
    final body = api.writes.single['body'] as Map;
    expect(body['status'], 'paid');
    expect(body['repeat'], true);
    expect(body['amount'], 42);
    expect(body['attachments'], ['voucher-a']);
    expect(api.writes.single['requestId'], isNotNull);
    expect(changed, 1);
    expect(c.paying, isEmpty);
    expect(c.busy, isFalse);
    expenseChanged.removeListener(on);
    c.dispose();
    await t.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('确认付款失败：不通知刷新，状态与按钮保持可重试', (t) async {
    phone(t);
    api.getOverride = {...entry('u1'), 'status': 'unpaid'};
    api.fail = const AppError.timeout();
    final c = ExpenseController('list', '2026-11-01', {
      'items': [
        {...entry('u1'), 'status': 'unpaid'},
      ],
      'history': [],
      'revenue': 1000,
    });
    var changed = 0;
    void on() => changed++;
    expenseChanged.addListener(on);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpensesLiveTemplate(c: c)),
      ),
    );
    await t.pump();
    await t.tap(find.text('确认付款'));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('确认付款').last);
    await t.pump();
    await t.pump(const Duration(seconds: 2));
    expect(changed, 0);
    expect(c.paying, isEmpty);
    expect(c.busy, isFalse);
    expect(find.text('确认已付款？'), findsOneWidget, reason: '失败时弹层保持打开可重试');
    await t.tap(find.text('取消'));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expenseChanged.removeListener(on);
    c.dispose();
    await t.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('详情页：仅待付款显示「确认付款」，付款后按钮消失', (t) async {
    phone(t);
    for (final status in ['unpaid', 'paid']) {
      final c = ExpenseController(
        'detail',
        '2026-11-01',
        board(),
        entry: {...entry(), 'status': status},
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ExpenseDetailLiveTemplate(c: c)),
        ),
      );
      await t.pump();
      expect(
        find.text('确认付款'),
        status == 'unpaid' ? findsOneWidget : findsNothing,
      );
      expect(find.text('编辑'), findsOneWidget);
      expect(find.text('删除这笔开支'), findsOneWidget, reason: '删除放在内容底部，不占底部按钮栏');
      expect(find.text('删除'), findsNothing);
      c.dispose();
    }
  });

  testWidgets('开支列表：滚动后标题栏固定不动，下面的内容随之滚走', (t) async {
    phone(t);
    final c = ExpenseController('list', '2026-11-01', {
      'items': [for (var i = 0; i < 30; i++) entry('r$i')],
      'history': [],
      'revenue': 1000,
    });
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExpensesLiveTemplate(c: c)),
      ),
    );
    await t.pump();
    final title = t.getTopLeft(find.text('开支管理'));
    final month = t.getTopLeft(find.text(c.monthLabel));
    await t.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -400),
    );
    await t.pump();
    expect(t.getTopLeft(find.text('开支管理')), title);
    expect(t.getTopLeft(find.text(c.monthLabel)).dy, lessThan(month.dy));
    c.dispose();
  });

  testWidgets('确认付款：点取消不请求；确认成功后列表立即重新读取', (t) async {
    phone(t);
    api.getOverride = {...entry('u1'), 'status': 'unpaid'};
    api.unpaidBoard = true;
    await t.pumpWidget(
      MaterialApp(
        home: ExpenseLivePage(mode: 'list', month: '2026-11-01'),
      ),
    );
    await t.pumpAndSettle(const Duration(seconds: 1));
    int boards() =>
        api.calls.where((x) => x['body']['action'] == 'expense_board').length;
    final before = boards();
    await t.tap(find.text('确认付款'));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('取消'));
    await t.pump(const Duration(milliseconds: 400));
    expect(api.writes, isEmpty);
    expect(boards(), before);
    await t.tap(find.text('确认付款'));
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('确认付款').last);
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle(const Duration(seconds: 1));
    expect(api.writes.single['body']['status'], 'paid');
    expect(boards(), greaterThan(before), reason: '确认成功后列表要重新读取');
  });
}
