import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show ConfirmDiscard;
import '../widgets/expense_bindings.dart';
import '../widgets/inventory_bindings.dart' show inventoryChanged;
import '../routes.dart';
import 'expenses_live_template.dart';
import 'expense_add_live_template.dart';
import 'expense_detail_live_template.dart';
import 'expense_budget_live_template.dart';
import 'budget_total_live_template.dart';
import 'budget_edit_live_template.dart';
import 'budget_adjust_live_template.dart';

class ExpenseLivePage extends StatefulWidget {
  final String mode;
  final String? month, id, category, preset;
  const ExpenseLivePage({
    super.key,
    required this.mode,
    this.month,
    this.id,
    this.category,
    this.preset,
  });
  @override
  State<ExpenseLivePage> createState() => _ExpenseLiveState();
}

class _ExpenseLiveState extends State<ExpenseLivePage> {
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  ExpenseController? c;
  late String month = widget.month ?? expenseMonth(DateTime.now());
  bool get listing => ['list', 'budget', 'detail'].contains(widget.mode);
  @override
  void initState() {
    super.initState();
    expenseChanged.addListener(refresh);
    inventoryChanged.addListener(refresh);
  }

  void refresh() {
    if (listing) key.currentState?.reload();
  }

  @override
  void dispose() {
    expenseChanged.removeListener(refresh);
    inventoryChanged.removeListener(refresh);
    c?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    month = c?.month ?? month;
    final result = await merchantApi.invoke({
      'action': 'expense_board',
      'month': month,
    });
    if (widget.id != null) {
      final entry = await merchantApi.invoke({
        'action': 'expense_get',
        'month': month,
        'id': widget.id,
      });
      result['entry'] = entry['item'];
    }
    if (widget.mode == 'detail' && widget.id == null) {
      throw const AppError('请先选择开支记录', type: AppErrorType.notFound);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => widget.mode == 'adjust'
      ? SizedBox(
          height: MediaQuery.of(context).size.height * .90,
          child: content(context),
        )
      : Scaffold(body: content(context));

  Widget content(BuildContext context) => AsyncView<Map<String, dynamic>>(
    key: key,
    load: load,
    isEmpty: (_) => false,
    skeleton: const SkeletonList(count: 5),
    empty: (_) => const SizedBox(),
    onNext: () => merchantApi.hasSession
        ? Navigator.of(context).maybePop()
        : openRoute(context, 'Login'),
    onLoaded: (r) {
      if (c == null) {
        c = ExpenseController(
          widget.mode,
          month,
          Map<String, dynamic>.from(r['item']),
          entry: r['entry'] == null
              ? null
              : Map<String, dynamic>.from(r['entry']),
          category: widget.category,
        );
        if (widget.preset == 'previous' &&
            c!.board['previous_budget'] != null) {
          c!.budget['total'] = c!.board['previous_budget']['total'];
          c!.budget['categories'] = Map<String, dynamic>.from(
            c!.board['previous_budget']['categories'],
          );
          c!.dirty = true;
        } else if (widget.preset == 'actual') {
          if (c!.total == 0) c!.budget['total'] = c!.previousSpent();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) c!.suggest(context, 'actual');
          });
        }
      } else {
        c!.board
          ..clear()
          ..addAll(Map<String, dynamic>.from(r['item']));
        if (r['entry'] != null) {
          c!.draft = Map<String, dynamic>.from(r['entry']);
        }
        if (widget.mode == 'budget' || widget.mode == 'list') {
          c!.budget = Map<String, dynamic>.from(
            r['item']['budget'] ??
                {
                  'total': 0,
                  'month': month,
                  'categories': {},
                  'revision': 0,
                  'carry': false,
                  'remind': true,
                },
          );
        }
      }
      c!.reload = () => key.currentState?.reload();
    },
    builder: (_, r) => ListenableBuilder(
      listenable: c!,
      builder: (_, _) => ConfirmDiscard(
        dirty: !listing && c!.dirty,
        busy: c!.busy,
        child: AbsorbPointer(
          absorbing: c!.busy,
          child: switch (widget.mode) {
            'list' => ExpensesLiveTemplate(c: c!),
            'add' => ExpenseAddLiveTemplate(c: c!),
            'detail' => ExpenseDetailLiveTemplate(c: c!),
            'budget' => ExpenseBudgetLiveTemplate(c: c!),
            'total' => BudgetTotalLiveTemplate(c: c!),
            'category' => BudgetEditLiveTemplate(c: c!),
            _ => SingleChildScrollView(child: BudgetAdjustLiveTemplate(c: c!)),
          },
        ),
      ),
    ),
  );
}
