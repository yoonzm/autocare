import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kit/sheet_route.dart';

import 'package:image_picker/image_picker.dart';

import '../backend/merchant_api.dart';
import '../kit/kit.dart';
import '../kit/async_kit.dart';
import '../theme.dart';
import 'inventory_bindings.dart' show inventoryId, maps, money;
import '../pages/expense_live_page.dart';
import '../pages/expense_entry_template.dart';
import '../pages/expense_category_template.dart';
import '../pages/expense_allocation_template.dart';

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
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>) request;
  final String mode;
  String month, category;
  final Map<String, dynamic> board;
  Map<String, dynamic> draft, budget;
  int filter = 0, allocationMode = 0, adjustSource = 0;
  String sourceCategory = '其他';
  num adjustment = 0;
  String reason = '';
  bool busy = false, dirty = false, disposed = false;
  VoidCallback? reload;
  ExpenseController(
    this.mode,
    this.month,
    this.board, {
    Map<String, dynamic>? entry,
    String? category,
    Future<Map<String, dynamic>> Function(Map<String, dynamic>)? request,
  }) : request = request ?? ((body) => merchantApi.invoke(body)),
       category = category ?? '材料采购',
       draft = entry == null
           ? {
               'id': inventoryId(),
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
           : Map<String, dynamic>.from(entry),
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
    if (!disposed) notifyListeners();
  }

  void setBusy(bool value) {
    busy = value;
    if (!disposed) notifyListeners();
  }

  List<Map<String, dynamic>> get entries => maps(board['items']);
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
    return maps(board['history'])
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

  Future<void> suggest(BuildContext context, String method) =>
      runBusy('Expense-suggest', () async {
        busy = true;
        if (!disposed) notifyListeners();
        try {
          final r = await request({
            'action': 'expense_suggest',
            'month': month,
            'method': method,
            'total': total,
          });
          budget['categories'] = Map<String, dynamic>.from(
            r['item']['categories'],
          );
          changed();
        } catch (e) {
          if (context.mounted) AppToast.error(context, e);
        } finally {
          busy = false;
          if (!disposed) notifyListeners();
        }
      });

  Future<void> save(BuildContext context, {bool remove = false}) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      if (remove &&
          !await hConfirm(
            context,
            mode == 'detail'
                ? (draft['repeat'] == true ? '确认删除这笔开支并停止后续每月重复？' : '确认删除这笔开支？')
                : '确认删除分类预算？',
          )) {
        return;
      }
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
        if (remove) categories.remove(category);
        // Category edits use the unallocated reserve first, then explicitly raise total.
        if (mode == 'category') budget['total'] = math.max(total, allocated);
        body = {...budget, 'month': month, 'action': 'expense_budget_save'};
      }
      await request(body);
      dirty = false;
      busy = false;
      notifyListeners();
      await WidgetsBinding.instance.endOfFrame;
      expenseChanged.value++;
      if (context.mounted) {
        AppToast.show(context, remove ? '已删除' : '已保存');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, e);
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  Widget busyLabel(Widget child) => hBusy(
    'Expense-$mode-save',
    child,
    style: child is Text ? child.style : null,
    label: '提交中…',
  );
  Widget tap(
    BuildContext context,
    Widget child, {
    String? to,
    bool back = false,
    VoidCallback? onTap,
    String? label,
    String? action,
  }) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: busy
        ? null
        : () async {
            if (back || action == '取消') {
              Navigator.of(context).maybePop();
              return;
            }
            if (action == '保存' ||
                action == '保存预算' ||
                action == '确认追加' ||
                action == '删除') {
              await runBusy(
                'Expense-$mode-save',
                () => save(context, remove: action == '删除'),
              );
              return;
            }
            if (mode == 'add' &&
                label != null &&
                expenseCategories.contains(label)) {
              draft['category'] = label;
              changed();
              return;
            }
            if (action == '复制上月预算') {
              if (board['previous_budget'] == null) {
                AppToast.show(context, '上月未设置预算');
                return;
              }
              open(context, 'total', preset: 'previous');
              return;
            }
            if (action == '按营收比例分配') {
              open(context, 'total', preset: 'actual');
              return;
            }
            if (action == '添加分类预算') {
              await selectCategory(context);
              return;
            }
            if (mode == 'detail' && to == 'StockIn') {
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
                            load: () => request({
                              'action': 'expense_source',
                              'id': draft['id'],
                            }),
                            isEmpty: (r) => r['item'] == null,
                            skeleton: const SkeletonList(count: 3),
                            empty: (_) =>
                                const EmptyView.firstTime(title: '来源单据不存在'),
                            builder: (_, r) {
                              final d = r['item'] as Map;
                              final p = d['payload'] as Map;
                              return ListView(
                                children: [
                                  Text('库存单 ${d['id']}'),
                                  const SizedBox(height: 12),
                                  Text(
                                    '状态：${d['status'] == 'posted' ? '已提交' : '草稿'}',
                                  ),
                                  Text('日期：${p['date'] ?? ''}'),
                                  Text('供应商：${p['supplier'] ?? ''}'),
                                  Text('金额：${money(d['total'] as num? ?? 0)}'),
                                  Text('明细：${(p['lines'] as List).length} 项'),
                                  Text('备注：${p['note'] ?? ''}'),
                                ],
                              );
                            },
                          ),
                        ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
              return;
            }
            if (to != null) {
              open(
                context,
                {
                      'Expenses': 'list',
                      'ExpenseAdd': 'add',
                      'ExpenseBudget': 'budget',
                      'BudgetTotal': 'total',
                      'BudgetEdit': 'category',
                      'BudgetAdjust': 'adjust',
                    }[to] ??
                    'list',
                id: to == 'ExpenseAdd' && mode == 'detail' ? draft['id'] : null,
                category: category,
              );
              return;
            }
            onTap?.call();
          },
    child: child,
  );
  String initial(String v) => switch (v) {
    '今天 10.31' => '${draft['occurred_on']}',
    '微信' => '${draft['account']}',
    '市供电局' => '${draft['payee']}'.isEmpty ? '请输入收款方' : '${draft['payee']}',
    '可调剂 ¥2,200' => money(
      math.max(
        0,
        (categories[sourceCategory]?['amount'] as num? ?? 0) -
            spent(sourceCategory),
      ),
    ),
    _ => '',
  };
  Future<void> pick(
    BuildContext context,
    String key,
    String label,
    StrCtrl ctrl,
  ) async {
    if (key == 'date') {
      final d = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(draft['occurred_on']),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (d != null) {
        draft['occurred_on'] = d.toIso8601String().substring(0, 10);
        ctrl.set(draft['occurred_on']);
        changed();
      }
      return;
    }
    if (key == 'account') {
      final v = await pickFromList(context, label, [
        '现金',
        '微信',
        '支付宝',
        '对公转账',
        '其他',
      ], draft['account']);
      if (v != null) {
        draft['account'] = v;
        ctrl.set(v);
        changed();
      }
      return;
    }
    if (key == 'budgetFrom') {
      final v = await pickFromList(
        context,
        '调出分类',
        categories.keys.where((k) => k != category).toList(),
        sourceCategory,
      );
      if (v != null) {
        sourceCategory = v;
        ctrl.set(v);
        changed();
      }
      return;
    }
    final v = await expenseInput(
      context,
      label,
      '请输入$label',
      '${draft['payee']}',
    );
    if (v != null) {
      draft['payee'] = v;
      ctrl.set(v);
      changed();
    }
  }

  String text(String v) {
    final prev = previousSpent();
    final change = prev == 0
        ? '—'
        : '${((spent() - prev) * 100 / prev).toStringAsFixed(1)}%';
    final categoryAmount = cat['amount'] as num;
    final used = spent(category);
    final excess = math.max(0, used - categoryAmount);
    final vals = <String, String>{
      '167,070.00': spent().toStringAsFixed(2),
      '较上月 +3.8%': '较上月 $change',
      '¥328,460': money(revenue),
      '¥161,390': money(revenue - spent()),
      '49.1%': revenue == 0
          ? '—'
          : '${((revenue - spent()) * 100 / revenue).toStringAsFixed(1)}%',
      '预算 97.7%': total == 0
          ? '未设预算'
          : '预算 ${(spent() * 100 / total).toStringAsFixed(1)}%',
      '待付款 1': '待付款 ${entries.where((e) => e['status'] == 'unpaid').length}',
      '¥28,000': money(spent('房租')),
      '¥82,000': money(spent('人工')),
      '¥36,570': money(
        mode == 'category' || mode == 'adjust' ? used : spent('材料采购'),
      ),
      '¥6,200': money(spent('水电')),
      '¥9,800': money(spent('营销推广')),
      '¥4,500': money(spent('其他') + spent('税费') + spent('设备维修') + spent('损耗')),
      '本月总预算 ¥171,000': '本月总预算 ${money(total)}',
      '97.7%': total == 0
          ? '—'
          : '${(spent() * 100 / total).toStringAsFixed(1)}%',
      '¥167,070': money(spent()),
      '¥3,930': money(total - spent()),
      '1 天':
          '${math.max(0, DateTime(DateTime.parse(month).year, DateTime.parse(month).month + 1, 0).day - DateTime.now().day)} 天',
      '材料采购已超支 ¥4,570':
          categories.keys
              .where((k) => spent(k) > (categories[k]['amount'] as num))
              .isEmpty
          ? '当前预算未超支'
          : '${categories.keys.where((k) => spent(k) > (categories[k]['amount'] as num)).join('、')}已超支',
      '材料采购预算': '$category预算',
      '材料采购': mode == 'category' || mode == 'adjust'
          ? category
          : mode == 'detail'
          ? '${draft['category']}'
          : v,
      '变动开支 · 每月预算':
          '${['房租', '人工', '税费'].contains(category) ? '固定' : '变动'}开支 · 每月预算',
      '超支 ¥4,570':
          '${used > categoryAmount ? '超支' : '剩余'} ${money((used - categoryAmount).abs())}',
      '预算 ¥32,000': '预算 ${money(categoryAmount)}',
      '¥32,000': money(categoryAmount),
      '¥4,570': money(excess),
      '上月实际 ¥31,200': '上月实际 ${money(previousSpent(category))}',
      '+10% ¥35,200': '+10% ${money(categoryAmount * 1.1)}',
      '按营收占比 ¥36,130':
          '按上月占比 ${money(prev == 0 ? 0 : total * previousSpent(category) / prev)}',
      '恢复 ¥32,000':
          '恢复 ${money((board['budget']?['categories']?[category]?['amount'] as num?) ?? 0)}',
      '改为 ¥36,000 后，总预算将增加 ¥4,000，需同步调整总预算':
          '保存后总预算为 ${money(math.max(total, allocated))}',
      '预算线 ¥32,000': '预算线 ${money(categoryAmount)}',
      '近 6 个月有 2 个月超出预算，平均支出 ¥32,100，预算可适当上调。':
          '近 6 个月累计支出 ${money(maps(board['history']).where((h) => h['category'] == category).fold<num>(0, (n, h) => n + (h['amount'] as num)))}',
      '共 7 笔': '共 ${entries.where((e) => e['category'] == category).length} 笔',
      '10 月总预算（元）': '${DateTime.parse(month).month} 月总预算（元）',
      '较上月预算 +3.6%':
          '上月预算 ${money(board['previous_budget']?['total'] as num? ?? 0)}',
      '占预计营收 52.1%': revenue == 0
          ? '本月暂无营收'
          : '占本月营收 ${(total * 100 / revenue).toStringAsFixed(1)}%',
      '已分配 ¥171,000 · 未分配 ¥0':
          '已分配 ${money(allocated)} · 未分配 ${money(total - allocated)}',
      '追加预算 · 材料采购': '追加预算 · $category',
      '补齐超支 ¥4,570': '补齐超支 ${money(excess)}',
      '总预算余额 ¥3,930': '总预算余额 ${money(total - allocated)}',
      '从 营销 调剂': '从 $sourceCategory 调剂',
      '−¥16,080.00': '−${money(draft['amount'] as num? ?? 0)}',
      '已付款': mode == 'detail'
          ? (draft['status'] == 'paid' ? '已付款' : '挂账待付')
          : v,
      '2026.10.31 14:55': '${draft['occurred_on']}',
      '对公转账': mode == 'detail' ? '${draft['account']}' : v,
      '蓝盾膜业': '${draft['payee']}',
      '陈明（店长）': '${draft['operator'] ?? '店长'}',
      '入库单 RK-20261031-03': draft['source_document'] == null
          ? '手工记账'
          : '库存单 ${'${draft['source_document']}'.substring(0, 8)}',
      'TPU 车衣 6 卷、镀晶液 10 瓶，含运费 ¥120': '${draft['note'] ?? ''}',
      '适合房租、物业费等固定开支，到期自动生成': '到期自动生成待付款记录，确认付款后可编辑状态',
    };
    if (v.startsWith('占总预算 ')) return total == 0 ? '未分配' : '按实际预算分配';
    return vals[v] ?? v;
  }

  String entryText(Map<String, dynamic> r, String v) => switch (v) {
    '材料采购' => '${r['category']}',
    '来自入库' =>
      r['source_document'] != null
          ? '来自库存'
          : r['status'] == 'unpaid'
          ? '待付款'
          : r['recurrence_id'] != null
          ? '自动'
          : '已付款',
    '蓝盾膜业 · 对公转账' => '${r['payee']} · ${r['account']}',
    '−¥16,080.00' => '−${money(r['amount'])}',
    _ => v,
  };
  String rowText(Map<String, dynamic> r, String v) => switch (v) {
    '房租' => '${r['category']}',
    '100%' =>
      '${r['amount'] == 0 ? 0 : (spent(r['category']) * 100 / (r['amount'] as num)).round()}%',
    '已用 ¥28,000 · 预算 ¥28,000' =>
      '已用 ${money(spent(r['category']))} · 预算 ${money(r['amount'])}',
    '100% 提醒' => '${r['threshold']}% 提醒',
    _ => v,
  };
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
                  '支出 ${money(rows.where((e) => e['occurred_on'] == d).fold<num>(0, (n, e) => n + (e['amount'] as num)))}',
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
    final h = maps(board['history'])
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

  Widget toggle(BuildContext context, int i) {
    final key = mode == 'add'
        ? 'repeat'
        : mode == 'category'
        ? (i == 0 ? 'rollover' : 'repeat')
        : i == 0
        ? 'remind'
        : i == 2
        ? 'carry'
        : 'notify';
    final target = mode == 'add'
        ? draft
        : mode == 'category'
        ? categories[category] as Map<String, dynamic>
        : budget;
    return HSwitchValue(
      value: key == 'notify' ? false : target[key] == true,
      onChanged: (v) async {
        if (mode == 'add' && draft['source_document'] != null) {
          AppToast.show(context, '库存生成的开支不支持重复记账');
          return;
        }
        if (key == 'notify') {
          // TODO: notification provider is not configured; expect an authenticated
          // expense_notification_subscribe endpoint before enabling this switch.
          AppToast.show(context, '手机推送尚未接通');
          return;
        }
        if (busy) return;
        target[key] = v;
        changed();
        if (mode == 'budget') {
          busy = true;
          notifyListeners();
          await runBusy('Expense-budget-save', () async {
            try {
              final result = await request({
                ...budget,
                'month': month,
                'action': 'expense_budget_save',
              });
              budget = Map<String, dynamic>.from(result['item']);
              dirty = false;
              expenseChanged.value++;
            } catch (e) {
              target[key] = !v;
              changed();
              if (context.mounted) AppToast.error(context, e);
            } finally {
              busy = false;
              if (!disposed) notifyListeners();
            }
          });
        }
      },
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

  String inputValue(int i, String hint) {
    if (mode == 'add') {
      return i == 0 ? (draft['amount']?.toString() ?? '') : '${draft['note']}';
    }
    if (mode == 'adjust') {
      return i == 0 ? (adjustment == 0 ? '' : '$adjustment') : reason;
    }
    if (mode == 'category') {
      return '${cat['amount']}';
    }
    if (i == 0) {
      return '$total';
    }
    final k = ['房租', '人工', '材料采购', '水电', '营销推广', '其他'][i - 1];
    return '${categories[k]?['amount'] ?? 0}';
  }

  void input(int i, String v) {
    final n = num.tryParse(v.replaceAll(',', ''));
    if (mode == 'add') {
      draft[i == 0 ? 'amount' : 'note'] = i == 0 ? n : v;
    } else if (mode == 'adjust') {
      if (i == 0) {
        adjustment = n ?? 0;
      } else {
        reason = v;
      }
    } else if (mode == 'category') {
      categories[category]['amount'] = n ?? 0;
    } else if (i == 0) {
      budget['total'] = n ?? 0;
    } else {
      final k = ['房租', '人工', '材料采购', '水电', '营销推广', '其他'][i - 1];
      categories.putIfAbsent(k, categoryDefault);
      categories[k]['amount'] = n ?? 0;
    }
    changed();
  }

  void select(BuildContext context, int group, int i) {
    if (mode == 'list') {
      filter = i;
    } else if (mode == 'add') {
      draft['status'] = i == 0 ? 'paid' : 'unpaid';
    } else if (mode == 'total') {
      if (group == 1) {
        budget['carry'] = i == 1;
      } else {
        allocationMode = i;
        if (i > 0) {
          suggest(context, i == 1 ? 'previous' : 'actual');
        }
      }
    } else if (mode == 'category') {
      if (group == 1) {
        categories[category]['threshold'] = [70, 80, 90, 100][i];
      } else if (group == 2) {
        categories[category]['policy'] = ['warn', 'owner', 'block'][i];
      } else {
        final original =
            board['budget']?['categories']?[category]?['amount'] as num? ?? 0;
        final amount = i == 0
            ? previousSpent(category)
            : i == 1
            ? original * 1.1
            : i == 2
            ? (previousSpent() == 0
                  ? 0
                  : total * previousSpent(category) / previousSpent())
            : original;
        categories[category]['amount'] = (amount * 100).round() / 100;
      }
    } else if (mode == 'adjust') {
      if (group == 1) {
        adjustment = i == 0
            ? math.max(0, spent(category) - (cat['amount'] as num))
            : i == 1
            ? 5000
            : 8000;
      } else if (group == 2) {
        adjustSource = i;
      }
    }
    changed();
  }

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
              IconButton(
                tooltip: '移除凭证',
                onPressed: () {
                  draft['attachments'] = List<String>.from(draft['attachments'])
                    ..remove(path);
                  changed();
                },
                icon: const Icon(Icons.close, size: 18),
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

Future<String?> expenseInput(
  BuildContext context,
  String title,
  String hint,
  String value,
) async {
  final ctrl = TextEditingController(text: value);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
          child: const Text('确定'),
        ),
      ],
    ),
  );
  await Future<void>.delayed(const Duration(milliseconds: 300));
  ctrl.dispose();
  return result;
}

class ExpenseInput extends StatefulWidget {
  final ExpenseController c;
  final String? field;
  final int index;
  final TextStyle style;
  final String hint, value;
  final TextInputType? keyboard;
  final bool obscure;
  final int? maxLines;
  final TextAlign align;
  final Color hintColor;
  const ExpenseInput({
    super.key,
    required this.c,
    this.field,
    required this.index,
    required this.style,
    this.hint = '',
    this.value = '',
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.align = TextAlign.start,
    this.hintColor = const Color(0xFF71717A),
  });
  @override
  State<ExpenseInput> createState() => _ExpenseInputState();
}

class _ExpenseInputState extends State<ExpenseInput> {
  String get currentValue => widget.field == null
      ? widget.c.inputValue(widget.index, widget.hint)
      : '${widget.c.categories[widget.field]?['amount'] ?? 0}';
  late final ctrl = TextEditingController(text: currentValue);
  late String last = ctrl.text;
  @override
  void didUpdateWidget(ExpenseInput old) {
    super.didUpdateWidget(old);
    final v = currentValue;
    if (v != last) {
      ctrl.text = v;
      last = v;
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    style: widget.style,
    textAlign: widget.align,
    keyboardType: widget.index == 0
        ? const TextInputType.numberWithOptions(decimal: true)
        : widget.keyboard,
    maxLines: widget.maxLines,
    decoration: InputDecoration(
      hintText: widget.hint.isEmpty ? '请输入内容' : widget.hint,
      border: InputBorder.none,
      isDense: true,
      contentPadding: EdgeInsets.zero,
    ),
    onChanged: (v) {
      if (widget.field == null) {
        widget.c.input(widget.index, v);
      } else {
        widget.c.categories.putIfAbsent(widget.field!, categoryDefault);
        widget.c.categories[widget.field]['amount'] = num.tryParse(v) ?? 0;
        widget.c.changed();
      }
      last = currentValue;
    },
  );
}

class ExpenseSelections extends StatelessWidget {
  final ExpenseController c;
  final int index;
  final List<(Set<int>, bool)> groups;
  final Widget Function(BuildContext, List<SelCtrl>) builder;
  const ExpenseSelections({
    super.key,
    required this.c,
    required this.index,
    required this.groups,
    required this.builder,
  });
  @override
  Widget build(BuildContext context) => HSelHolder(
    groups: [
      (
        {
          c.mode == 'add'
              ? (c.draft['status'] == 'paid' ? 0 : 1)
              : c.mode == 'category' && index == 1
              ? [70, 80, 90, 100].indexOf(c.cat['threshold'])
              : c.mode == 'category' && index == 2
              ? ['warn', 'owner', 'block'].indexOf(c.cat['policy'])
              : c.mode == 'total' && index == 1
              ? (c.budget['carry'] == true ? 1 : 0)
              : 0,
        },
        false,
      ),
    ],
    onSelect: {0: (i) => c.select(context, index, i)},
    builder: (context, ctrls) =>
        hBusy('Expense-suggest', builder(context, ctrls)),
  );
}

class ExpenseAttachment extends StatelessWidget {
  final ExpenseController c;
  final String imgKey;
  final double size, radius;
  final int max;
  final Widget child;
  const ExpenseAttachment({
    super.key,
    required this.c,
    required this.imgKey,
    required this.size,
    required this.radius,
    this.max = 5,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      c.vouchers(context),
      GestureDetector(
        onTap: () => runBusy('expense-upload', () async {
          c.setBusy(true);
          try {
            if ((c.draft['attachments'] as List).length >= 5) {
              throw const AppError('最多上传五张凭证');
            }
            final source = await showModalBottomSheet<ImageSource>(
              context: context,
              builder: (ctx) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('拍照'),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                    ListTile(
                      title: const Text('从相册选择'),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                  ],
                ),
              ),
            );
            if (source == null) return;
            final f = await ImagePicker().pickImage(
              source: source,
              maxWidth: 1600,
              imageQuality: 85,
            );
            if (f == null) return;
            final r = await merchantApi.invoke({
              'action': 'expense_upload',
              'data': base64Encode(await f.readAsBytes()),
            }, timeout: const Duration(seconds: 60));
            final a = List<String>.from(c.draft['attachments']);
            if (a.length >= 5) throw const AppError('最多上传五张凭证');
            a.add(r['item']['path']);
            c.draft['attachments'] = a;
            c.changed();
          } catch (e) {
            if (context.mounted) AppToast.error(context, e);
          } finally {
            c.setBusy(false);
          }
        }),
        child: hBusy('expense-upload', child, icon: true),
      ),
    ],
  );
}
