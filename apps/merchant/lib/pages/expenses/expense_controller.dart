import 'voucher_gallery.dart';

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
  String month;
  final Map<String, dynamic> board;
  Map<String, dynamic> draft;
  int filter = 0, summaryMetric = 0;
  bool busy = false, dirty = false, disposed = false;
  VoidCallback? reload;
  ExpenseController(
    this.mode,
    this.month,
    Map<String, dynamic> board, {
    Map<String, dynamic>? entry,
    Future<Map<String, dynamic>> Function(
      Map<String, dynamic>, {
      String? requestId,
    })?
    request,
  }) : _request =
           request ??
           ((body, {requestId}) => merchantApi.invoke(
             body,
             requestId: requestId,
             timeout: body['action'] == 'expense_upload'
                 ? const Duration(seconds: 60)
                 : kRequestTimeout,
           )),
       board = expenseCopy(board),
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
           : expenseCopy(entry);
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
  void shiftMonth(int d) {
    month = expenseMonth(
      DateTime(DateTime.parse(month).year, DateTime.parse(month).month + d),
    );
    reload?.call();
  }

  void open(BuildContext context, String mode, {String? id}) {
    final page = ExpenseLivePage(mode: mode, month: month, id: id);
    // 记一笔的左上角是 ✕：整页 sheet；其余（详情）保持原来的推入
    Navigator.of(context).push(
      mode == 'add'
          ? appSheetRoute<void>(page: page)
          : MaterialPageRoute(builder: (_) => page),
    );
  }

  void openDetail(BuildContext context, Map<String, dynamic> e) =>
      open(context, 'detail', id: e['id']);

  /// Returns the actual service result. A failure leaves every input unchanged.
  Future<Map<String, dynamic>?> persist({bool remove = false}) async {
    if (busy || disposed || _committed) return null;
    setBusy(true);
    try {
      final body = {
        ...draft,
        'action': remove ? 'expense_delete' : 'expense_save',
      };
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
        draft['repeat'] == true ? '确认删除这笔开支并停止后续每月重复？' : '确认删除这笔开支？',
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

  void setFilter(int value) {
    filter = value;
    if (!disposed) notifyListeners();
  }

  void setSummaryMetric(int value) {
    summaryMetric = value;
    if (!disposed) notifyListeners();
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

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

  Widget vouchers(BuildContext context) => VoucherGallery(
    title: '凭证',
    paths: List<String>.from(draft['attachments'] ?? []),
    request: request,
  );
}
