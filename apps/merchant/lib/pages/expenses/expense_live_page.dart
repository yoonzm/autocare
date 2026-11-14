import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show ConfirmDiscard;
import 'expense_controller.dart';
import '../inventory/inventory_controller.dart' show inventoryChanged;
import '../../routes.dart';
import 'expenses_live_template.dart';
import 'expense_add_live_template.dart';
import 'expense_detail_live_template.dart';

class ExpenseLivePage extends StatefulWidget {
  final String mode;
  final String? month, id;
  const ExpenseLivePage({super.key, required this.mode, this.month, this.id});
  @override
  State<ExpenseLivePage> createState() => _ExpenseLiveState();
}

class _ExpenseLiveState extends State<ExpenseLivePage> {
  var key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  ExpenseController? c;
  int _refreshVersion = 0, _targetVersion = 0;
  bool _refreshPending = false;
  late String month = widget.month ?? expenseMonth(DateTime.now());
  bool get listing => ['list', 'detail'].contains(widget.mode);
  @override
  void initState() {
    super.initState();
    expenseChanged.addListener(refresh);
    inventoryChanged.addListener(refresh);
    busyActions.addListener(_unlocked);
  }

  void refresh() {
    if (!mounted || !listing) return;
    _refreshVersion++;
    if (c?.locked == true || key.currentState?.busy == true) {
      _refreshPending = true;
      return;
    }
    _refreshPending = false;
    key.currentState?.reload();
  }

  void _unlocked() {
    if (_refreshPending &&
        c?.locked != true &&
        key.currentState?.busy != true) {
      refresh();
    }
  }

  @override
  void didUpdateWidget(covariant ExpenseLivePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode ||
        oldWidget.month != widget.month ||
        oldWidget.id != widget.id) {
      _refreshVersion++;
      _targetVersion++;
      _refreshPending = false;
      c?.dispose();
      c = null;
      month = widget.month ?? expenseMonth(DateTime.now());
      key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
    }
  }

  @override
  void dispose() {
    expenseChanged.removeListener(refresh);
    inventoryChanged.removeListener(refresh);
    busyActions.removeListener(_unlocked);
    c?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    final id = widget.id;
    final owner = _targetVersion;
    if (widget.mode == 'detail' && id == null) {
      throw const AppError('请先选择开支记录', type: AppErrorType.notFound);
    }
    while (true) {
      final version = _refreshVersion;
      final requestedMonth = c?.month ?? month;
      final results = await Future.wait([
        merchantApi.invoke({
          'action': 'expense_board',
          'month': requestedMonth,
        }),
        if (id != null)
          merchantApi.invoke({
            'action': 'expense_get',
            'month': requestedMonth,
            'id': id,
          }),
      ]);
      if (mounted && owner == _targetVersion && version != _refreshVersion) {
        _refreshPending = false;
        continue;
      }
      return {
        ...results.first,
        '_month': requestedMonth,
        if (id != null) 'entry': results[1]['item'],
      };
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: content(context));

  Widget content(BuildContext context) => AsyncView<Map<String, dynamic>>(
    key: key,
    load: load,
    pullToRefresh: listing,
    onSettled: _unlocked,
    isEmpty: (_) => false,
    skeletonPadding: EdgeInsets.zero,
    skeleton: SkeletonDataPage(
      title: switch (widget.mode) {
        'list' => '开支管理',
        'add' => '记一笔开支',
        'detail' => '开支详情',
        _ => '开支管理',
      },
      detail: listing,
    ),
    empty: (_) => const SizedBox(),
    onNext: () => merchantApi.hasSession
        ? Navigator.of(context).maybePop()
        : openRoute(context, 'Login'),
    onLoaded: (r) {
      if (c != null &&
          (c!.locked || _refreshPending || c!.month != r['_month'])) {
        _refreshPending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _unlocked();
        });
        return;
      }
      month = r['_month'] as String;
      if (c == null) {
        c = ExpenseController(
          widget.mode,
          month,
          Map<String, dynamic>.from(r['item']),
          entry: r['entry'] == null
              ? null
              : Map<String, dynamic>.from(r['entry']),
        );
      } else {
        c!.board
          ..clear()
          ..addAll(expenseCopy(Map<String, dynamic>.from(r['item'])));
        if (r['entry'] != null) {
          c!.draft = expenseCopy(Map<String, dynamic>.from(r['entry']));
        }
      }
      c!.reload = refresh;
      if (_refreshPending) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _unlocked();
        });
      }
    },
    builder: (_, r) => ListenableBuilder(
      listenable: Listenable.merge([c!, busyActions]),
      builder: (_, _) => ConfirmDiscard(
        dirty: !listing && c!.dirty,
        busy: c!.locked,
        child: AbsorbPointer(
          absorbing: c!.locked,
          child: switch (widget.mode) {
            'add' => ExpenseAddLiveTemplate(c: c!),
            'detail' => ExpenseDetailLiveTemplate(c: c!),
            _ => ExpensesLiveTemplate(c: c!),
          },
        ),
      ),
    ),
  );
}
