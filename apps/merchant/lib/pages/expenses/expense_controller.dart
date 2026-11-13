import '../../kit/buttons.dart';

import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../kit/sheet_route.dart';

import '../../backend/merchant_api.dart';
import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import '../../theme.dart';
import '../../backend/data_snapshot.dart';
import 'expense_widgets.dart';
export 'expense_view.dart';
import 'expense_live_page.dart';
import 'expense_entry_template.dart';
import 'expense_category_template.dart';
import 'expense_allocation_template.dart';

const expenseCategories = [
  '房租',
  '水电',
  '人工',
  '材料采购',
  '设备维修',
  '营销推广',
  '税费',
  '其他',
  '损耗',
];
final expenseChanged = ValueNotifier(0);
String expenseMoney(num value) => '¥${value.toStringAsFixed(2)}';
List<Map<String, dynamic>> expenseMaps(dynamic rows) => [
  for (final row in rows as List? ?? const [])
    Map<String, dynamic>.from(row as Map),
];
String expenseId() {
  final s = MerchantApi.newRequestId();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

Map<String, dynamic> expenseCopy(Map<String, dynamic> value) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
String expenseMonth(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-01';
Map<String, dynamic> categoryDefault() => {
  'amount': 0,
  'threshold': 80,
  'policy': 'warn',
  'rollover': false,
  'repeat': false,
};

class ExpenseController extends ChangeNotifier {
  final Future<Map<String, dynamic>> Function(
    Map<String, dynamic>, {
    String? requestId,
  })
  _request;
  final _instance = 'expense:${UniqueKey()}';
  String get saveKey => '$_instance:save';
  String get uploadKey => '$_instance:upload';
  String get suggestKey => '$_instance:suggest';
  String? _intent, _requestId;
  bool _committed = false;
  bool get locked =>
      busy || isBusy(saveKey) || isBusy(suggestKey) || isBusy(uploadKey);
  final String mode;
  String month, category;
  final Map<String, dynamic> board;
  Map<String, dynamic> draft, budget;
  int filter = 0, allocationMode = 0, adjustSource = 0;
  int categorySuggestion = 0, summaryMetric = 0, adjustmentPreset = 0;
  String sourceCategory = '其他';
  num adjustment = 0;
  String reason = '';
  bool busy = false, dirty = false, disposed = false;
  VoidCallback? reload;
  ExpenseController(
    this.mode,
    this.month,
    Map<String, dynamic> board, {
    Map<String, dynamic>? entry,
    String? category,
    Future<Map<String, dynamic>> Function(
      Map<String, dynamic>, {
      String? requestId,
    })?
    request,
  }) : _request =
           request ??
           ((body, {requestId}) =>
               merchantApi.invoke(body, requestId: requestId)),
       board = expenseCopy(board),
       category = category ?? '材料采购',
       draft = entry == null
           ? {
               'id': expenseId(),
               'revision': 0,
               'amount': null,
               'category': '房租',
               'occurred_on': DateTime.now().toIso8601String().substring(0, 10),
               'account': '微信',
               'payee': '',
               'status': 'paid',
               'note': '',
               'repeat': false,
               'attachments': <String>[],
             }
           : expenseCopy(entry),
       budget = Map<String, dynamic>.from(
         jsonDecode(
           jsonEncode(
             board['budget'] ??
                 {
                   'month': month,
                   'total': 0,
                   'categories': {},
                   'carry': false,
                   'remind': true,
                   'revision': 0,
                 },
           ),
         ),
       ) {
    if (mode == 'category') {
      categories.putIfAbsent(this.category, categoryDefault);
    }
  }
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  void changed() {
    dirty = true;
    _committed = false;
    if (!disposed) notifyListeners();
  }

  void setBusy(bool value) {
    busy = value;
    if (!disposed) notifyListeners();
  }

  Future<Map<String, dynamic>> request(
    Map<String, dynamic> body, {
    bool write = false,
  }) {
    final snapshot = dataSnapshot(body);
    if (write) {
      final intent = jsonEncode(snapshot);
      if (_intent != intent) {
        _intent = intent;
        _requestId = MerchantApi.newRequestId();
      }
    }
    return _request(snapshot, requestId: write ? _requestId : null);
  }

  List<Map<String, dynamic>> get entries => expenseMaps(board['items']);
  Map<String, dynamic> get categories =>
      budget['categories'] as Map<String, dynamic>;
  Map<String, dynamic> get cat =>
      Map<String, dynamic>.from(categories[category] ?? categoryDefault());
  num spent([String? key]) => entries
      .where((e) => key == null || e['category'] == key)
      .fold<num>(0, (n, e) => n + (e['amount'] as num));
  num get revenue => board['revenue'] as num? ?? 0;
  int compositionFlex(String key) => math.max(
    1,
    ((key == '其他'
                ? spent('其他') + spent('设备维修') + spent('税费') + spent('损耗')
                : spent(key)) *
            100)
        .round(),
  );
  Color categoryBackground(String key) =>
      draft['category'] == key ? C.primarySoft : C.chip;
  Border? categoryBorder(String key) => draft['category'] == key
      ? Border.all(color: C.primary, width: 1.5)
      : null;
  double get categoryProgress => (cat['amount'] as num) == 0
      ? 0
      : (spent(category) / (cat['amount'] as num)).clamp(0, 1).toDouble();
  Color get categoryColor =>
      spent(category) > (cat['amount'] as num) ? C.red : C.primary;
  num get total => budget['total'] as num? ?? 0;
  num get allocated =>
      categories.values.fold<num>(0, (n, e) => n + (e['amount'] as num));
  num previousSpent([String? key]) {
    final prev = expenseMonth(
      DateTime.parse(month).copyWith(month: DateTime.parse(month).month - 1),
    );
    return expenseMaps(board['history'])
        .where(
          (e) => e['month'] == prev && (key == null || e['category'] == key),
        )
        .fold<num>(0, (n, e) => n + (e['amount'] as num));
  }

  String get monthLabel =>
      '${DateTime.parse(month).year}年 ${DateTime.parse(month).month}月';
  double get progress =>
      total == 0 ? 0 : (spent() / total).clamp(0, 1).toDouble();
  void shiftMonth(int d) {
    month = expenseMonth(
      DateTime(DateTime.parse(month).year, DateTime.parse(month).month + d),
    );
    reload?.call();
  }

  void open(
    BuildContext context,
    String mode, {
    String? id,
    String? category,
    String? preset,
  }) {
    final page = ExpenseLivePage(
      mode: mode,
      month: month,
      id: id,
      category: category,
      preset: preset,
    );
    if (mode == 'adjust') {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: page,
        ),
      );
    } else {
      // 记一笔 / 编辑预算 / 总预算的左上角是 ✕：整页 sheet；其余（详情、分类）保持原来的推入
      Navigator.of(context).push(
        const {'add', 'budget', 'total'}.contains(mode)
            ? appSheetRoute<void>(page: page)
            : MaterialPageRoute(builder: (_) => page),
      );
    }
  }

  void openDetail(BuildContext context, Map<String, dynamic> e) =>
      open(context, 'detail', id: e['id']);
  void editCategory(BuildContext context, String key) =>
      open(context, 'category', category: key);
  Future<void> selectCategory(BuildContext context) async {
    final k = await pickFromList(context, '选择分类', expenseCategories, category);
    if (k != null && context.mounted) editCategory(context, k);
  }

  Future<void> suggest(BuildContext context, String method) async {
    if (busy || disposed) return;
    await runBusy(suggestKey, () async {
      setBusy(true);
      try {
        final r = await request({
          'action': 'expense_suggest',
          'month': month,
          'method': method,
          'total': total,
        });
        if (disposed) return;
        budget['categories'] = expenseCopy(
          Map<String, dynamic>.from(r['item']['categories']),
        );
        changed();
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      } finally {
        setBusy(false);
      }
    });
  }

  /// Returns the actual service result. A failure leaves every input unchanged.
  Future<Map<String, dynamic>?> persist({bool remove = false}) async {
    if (busy || disposed || _committed) return null;
    setBusy(true);
    try {
      Map<String, dynamic> body;
      if (mode == 'add' || mode == 'detail') {
        body = {...draft, 'action': remove ? 'expense_delete' : 'expense_save'};
      } else if (mode == 'adjust') {
        body = {
          'action': 'expense_budget_adjust',
          'month': month,
          'revision': budget['revision'],
          'category': category,
          'amount': adjustment,
          'source': adjustSource == 0
              ? 'remaining'
              : adjustSource == 2
              ? 'total'
              : sourceCategory,
          'reason': reason,
        };
      } else {
        final proposed = expenseCopy(budget);
        if (remove) (proposed['categories'] as Map).remove(category);
        // Preview allocation is input only; the backend validates the full budget.
        if (mode == 'category') {
          final allocated = (proposed['categories'] as Map).values.fold<num>(
            0,
            (sum, row) => sum + (row['amount'] as num),
          );
          proposed['total'] = math.max(total, allocated);
        }
        body = {...proposed, 'month': month, 'action': 'expense_budget_save'};
      }
      final result = await request(body, write: true);
      _committed = true;
      dirty = false;
      expenseChanged.value++;
      return result;
    } finally {
      setBusy(false);
    }
  }

  Future<void> save(BuildContext context, {bool remove = false}) async {
    if (busy || disposed || _committed || isBusy(saveKey)) return;
    if (remove) {
      final confirmed = await hConfirm(
        context,
        mode == 'detail'
            ? (draft['repeat'] == true ? '确认删除这笔开支并停止后续每月重复？' : '确认删除这笔开支？')
            : '确认删除分类预算？',
        onConfirm: () async {
          await persist(remove: true);
        },
      );
      if (!confirmed || !context.mounted || disposed) return;
    } else {
      var saved = false;
      await runBusy(saveKey, () async {
        try {
          saved = await persist() != null;
        } catch (e) {
          if (context.mounted && !disposed) AppToast.error(context, e);
        }
      });
      if (!saved || !context.mounted || disposed) return;
    }
    AppToast.show(context, remove ? '已删除' : '已保存', kind: ToastKind.success);
    Navigator.of(context).pop();
  }

  Widget busyLabel(Widget child) => hBusy(
    saveKey,
    child,
    style: child is Text ? child.style : null,
    label: '提交中…',
  );

  void setEntryAmount(String value) {
    if (busy) return;
    draft['amount'] = num.tryParse(value.replaceAll(',', ''));
    changed();
  }

  void setEntryNote(String value) {
    if (busy) return;
    draft['note'] = value;
    changed();
  }

  void setEntryCategory(String value) {
    if (busy) return;
    draft['category'] = value;
    changed();
  }

  void setPaymentStatus(String value) {
    if (busy) return;
    draft['status'] = value;
    changed();
  }

  void setTotal(String value) {
    if (busy) return;
    budget['total'] = num.tryParse(value.replaceAll(',', '')) ?? 0;
    changed();
  }

  void setCategoryAmount(String key, String value) {
    if (busy) return;
    categories.putIfAbsent(key, categoryDefault);
    categories[key]['amount'] = num.tryParse(value.replaceAll(',', '')) ?? 0;
    changed();
  }

  void setAdjustment(String value) {
    if (busy) return;
    adjustment = num.tryParse(value.replaceAll(',', '')) ?? 0;
    changed();
  }

  void setReason(String value) {
    if (busy) return;
    reason = value;
    changed();
  }

  void setFilter(int value) {
    filter = value;
    if (!disposed) notifyListeners();
  }

  void setBudgetCarry(bool value) {
    if (busy) return;
    budget['carry'] = value;
    changed();
  }

  void setSummaryMetric(int value) {
    summaryMetric = value;
    if (!disposed) notifyListeners();
  }

  void setAdjustSource(int value) {
    if (busy) return;
    adjustSource = value;
    changed();
  }

  void setCategoryThreshold(int value) {
    if (busy) return;
    categories[category]['threshold'] = value;
    changed();
  }

  void setCategoryPolicy(String value) {
    if (busy) return;
    categories[category]['policy'] = value;
    changed();
  }

  void setCategoryFlag(String key, bool value) {
    if (busy) return;
    categories[category][key] = value;
    changed();
  }

  void chooseAdjustment(int index) {
    if (busy) return;
    adjustmentPreset = index;
    adjustment = index == 0
        ? math.max(0, spent(category) - (cat['amount'] as num))
        : index == 1
        ? 5000
        : 8000;
    changed();
  }

  void chooseCategorySuggestion(int index) {
    if (busy) return;
    categorySuggestion = index;
    final original =
        board['budget']?['categories']?[category]?['amount'] as num? ?? 0;
    final amount = index == 0
        ? previousSpent(category)
        : index == 1
        ? original * 1.1
        : index == 2
        ? (previousSpent() == 0
              ? 0
              : total * previousSpent(category) / previousSpent())
        : original;
    categories[category]['amount'] = (amount * 100).round() / 100;
    changed();
  }

  void chooseAllocation(BuildContext context, int index) {
    if (busy) return;
    if (index == 3) {
      explainRevenueAllocation(context);
      notifyListeners();
      return;
    }
    allocationMode = index;
    changed();
    if (index > 0) suggest(context, index == 1 ? 'previous' : 'actual');
  }

  void explainRevenueAllocation(BuildContext context) {
    // TODO: expense_suggest only supports previous-budget/previous-actual weights.
    // Revenue forecasts and a defined revenue allocation API are not available.
    AppToast.show(context, '按营收比例分配暂未接通');
  }

  void explainPush(BuildContext context) {
    // TODO: notification provider and expense_notification_subscribe are not connected.
    AppToast.show(context, '手机推送尚未接通');
  }

  Future<void> chooseAdjustmentCategory(BuildContext context) async {
    if (categories.isEmpty) {
      AppToast.show(context, '请先设置分类预算');
      return;
    }
    final key = await pickFromList(
      context,
      '追加预算分类',
      categories.keys.toList(),
      category,
    );
    if (key != null && context.mounted && !disposed) {
      open(context, 'adjust', category: key);
    }
  }

  void copyPrevious(BuildContext context) {
    if (board['previous_budget'] == null) {
      AppToast.show(context, '上月未设置预算');
      return;
    }
    open(context, 'total', preset: 'previous');
  }

  void setEntryRepeat(BuildContext context, bool value) {
    if (draft['source_document'] != null) {
      AppToast.show(context, '库存生成的开支不支持重复记账');
      return;
    }
    if (busy) return;
    draft['repeat'] = value;
    changed();
  }

  Future<void> setBudgetFlag(
    BuildContext context,
    String key,
    bool value,
  ) async {
    if (busy || disposed) return;
    final before = budget[key];
    budget[key] = value;
    changed();
    await runBusy(saveKey, () async {
      try {
        final result = await persist();
        if (!disposed && result?['item'] is Map) {
          budget = expenseCopy(Map<String, dynamic>.from(result!['item']));
        }
      } catch (e) {
        if (disposed) return;
        budget[key] = before;
        changed();
        if (context.mounted) AppToast.error(context, e);
      }
    });
  }

  String get sourceAvailableText => expenseMoney(
    math.max(
      0,
      (categories[sourceCategory]?['amount'] as num? ?? 0) -
          spent(sourceCategory),
    ),
  );
  String entryStatus(Map<String, dynamic> record) =>
      record['source_document'] != null
      ? '来自库存'
      : record['status'] == 'unpaid'
      ? '待付款'
      : record['recurrence_id'] != null
      ? '自动'
      : '已付款';

  Future<void> pickDate(BuildContext context) async {
    final value = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(draft['occurred_on']),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value == null || disposed || !context.mounted) return;
    draft['occurred_on'] = value.toIso8601String().substring(0, 10);
    changed();
  }

  Future<void> pickAccount(BuildContext context) async {
    final value = await pickFromList(context, '支付账户', [
      '现金',
      '微信',
      '支付宝',
      '对公转账',
      '其他',
    ], draft['account']);
    if (value == null || disposed || !context.mounted) return;
    draft['account'] = value;
    changed();
  }

  Future<void> pickPayee(BuildContext context) async {
    final value = await expenseInput(
      context,
      '收款方',
      '请输入收款方',
      '${draft['payee']}',
    );
    if (value == null || disposed || !context.mounted) return;
    draft['payee'] = value;
    changed();
  }

  Future<void> pickBudgetSource(BuildContext context) async {
    final value = await pickFromList(
      context,
      '调出分类',
      categories.keys.where((k) => k != category).toList(),
      sourceCategory,
    );
    if (value == null || disposed || !context.mounted) return;
    sourceCategory = value;
    changed();
  }

  Future<void> showSource(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('来源单据'),
        content: draft['source_document'] == null
            ? const Text('手工记账')
            : SizedBox(
                width: 320,
                height: 300,
                child: AsyncView<Map<String, dynamic>>(
                  load: () =>
                      request({'action': 'expense_source', 'id': draft['id']}),
                  isEmpty: (r) => r['item'] == null,
                  skeleton: const SkeletonList(count: 3),
                  empty: (_) => const EmptyView.firstTime(title: '来源单据不存在'),
                  builder: (_, r) {
                    final d = r['item'] as Map;
                    final p = d['payload'] as Map;
                    return ListView(
                      children: [
                        Text('库存单 ${d['id']}'),
                        const SizedBox(height: 12),
                        Text('状态：${d['status'] == 'posted' ? '已提交' : '草稿'}'),
                        Text('日期：${p['date'] ?? ''}'),
                        Text('供应商：${p['supplier'] ?? ''}'),
                        Text('金额：${expenseMoney(d['total'] as num? ?? 0)}'),
                        Text('明细：${(p['lines'] as List).length} 项'),
                        Text('备注：${p['note'] ?? ''}'),
                      ],
                    );
                  },
                ),
              ),
        actions: [
          AppButton(
            label: '关闭',
            kind: AppButtonKind.secondary,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  double rowProgress(Map<String, dynamic> r) => r['amount'] == 0
      ? 0
      : (spent(r['category']) / (r['amount'] as num)).clamp(0, 1).toDouble();
  Widget entriesWidget(BuildContext context) {
    final rows = entries
        .where(
          (e) =>
              filter == 0 ||
              filter == 3 && e['status'] == 'unpaid' ||
              filter == 1 && ['房租', '人工', '税费'].contains(e['category']) ||
              filter == 2 && !['房租', '人工', '税费'].contains(e['category']),
        )
        .toList();
    final dates = rows.map((e) => e['occurred_on']).toSet();
    return Column(
      children: [
        if (rows.isEmpty) const EmptyView.firstTime(title: '当前月份没有开支记录'),
        for (final d in dates) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$d', style: ts(13, color: C.muted)),
                Text(
                  '支出 ${expenseMoney(rows.where((e) => e['occurred_on'] == d).fold<num>(0, (n, e) => n + (e['amount'] as num)))}',
                  style: ts(12, color: C.muted),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                for (final r in rows.where((e) => e['occurred_on'] == d))
                  ExpenseEntryTemplate(c: this, record: r),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget budgetRows(BuildContext context) => Column(
    children: [
      if (categories.isEmpty) const EmptyView.firstTime(title: '尚未设置分类预算'),
      for (final k in categories.keys)
        ExpenseCategoryTemplate(
          c: this,
          record: {...categories[k], 'category': k},
        ),
    ],
  );
  Widget historyChart(BuildContext context) {
    final h = expenseMaps(board['history'])
        .where((r) => r['category'] == category)
        .toList();
    final maxValue = h.fold<num>(1, (n, r) => math.max(n, r['amount'] as num));
    return SizedBox(
      height: 124,
      width: 314,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 6; i >= 1; i--)
            Expanded(
              child: Builder(
                builder: (_) {
                  final m = expenseMonth(
                    DateTime(
                      DateTime.parse(month).year,
                      DateTime.parse(month).month - i,
                    ),
                  );
                  final value = h
                      .where((r) => r['month'] == m)
                      .fold<num>(0, (n, r) => n + (r['amount'] as num));
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 24,
                        height: 90 * value / maxValue,
                        color: C.primary,
                      ),
                      Text(
                        '${DateTime.parse(m).month}月',
                        style: ts(10, color: C.muted),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String allocationText(String key) =>
      '占总预算 ${total == 0 ? 0 : ((categories[key]?['amount'] as num? ?? 0) / total * 100).round()}%';

  Widget allocationRows(BuildContext context) => Column(
    children: [
      for (final key in <String>{
        '房租',
        '人工',
        '材料采购',
        '水电',
        '营销推广',
        '其他',
        ...categories.keys,
      })
        ExpenseAllocationTemplate(c: this, categoryKey: key),
    ],
  );

  Widget vouchers(BuildContext context) => Wrap(
    spacing: 10,
    children: [
      for (final path in List<String>.from(draft['attachments'] as List? ?? []))
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: () => showVoucher(context, path),
              icon: const Icon(Icons.receipt_long),
              label: const Text('查看凭证'),
            ),
            if (mode == 'add')
              AppIconButton(
                icon: Icons.close,
                semanticLabel: '移除凭证',
                onPressed: () {
                  draft['attachments'] = List<String>.from(draft['attachments'])
                    ..remove(path);
                  changed();
                },
              ),
          ],
        ),
      if ((draft['attachments'] as List? ?? []).isEmpty)
        Text('未上传凭证', style: ts(13, color: C.muted)),
    ],
  );
  Future<void> showVoucher(BuildContext context, String path) async {
    final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: SizedBox(
          height: 400,
          child: AsyncView<Map<String, dynamic>>(
            key: key,
            load: () => request({'action': 'expense_voucher', 'path': path}),
            isEmpty: (_) => false,
            skeleton: const SkeletonList(count: 3),
            empty: (_) => const SizedBox(),
            builder: (_, r) => Image.network(
              r['item']['signedUrl'],
              errorBuilder: (_, e, _) => ErrorView(
                error: AppError.from(e),
                onRetry: () async => key.currentState?.reload(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
