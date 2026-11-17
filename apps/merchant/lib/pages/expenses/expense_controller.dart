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
import '../../kit/pickers.dart' as pickers;
import '../inventory/inventory_management_page.dart';
import 'payee_sheet.dart';
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
String expenseMoney(num value) => value < 0
    ? '-¥${(-value).toStringAsFixed(2)}'
    : '¥${value.toStringAsFixed(2)}';

/// 列表 / 详情里的金额：支出显示「−¥120.00」；退款（库存单同步的负数开支）显示「+¥80.00」。
String expenseSigned(num amount) =>
    amount < 0 ? '+${expenseMoney(-amount)}' : '−${expenseMoney(amount)}';
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

  /// 当前月份（东八区）；不能翻到还没发生的月份。
  static String get currentMonth =>
      expenseMonth(DateTime.now().toUtc().add(const Duration(hours: 8)));
  bool get canNext => month.compareTo(currentMonth) < 0;

  void shiftMonth(int d) {
    if (d > 0 && !canNext) return;
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

  /// 正在确认付款的记录 id（列表/详情据此显示「处理中…」）。
  final paying = <String>{};

  /// 待付款 → 已付款。先弹确认，避免误点；确认后列表项没有 `repeat` 等保存必需字段，
  /// 所以按 id 取完整记录，只改付款状态再保存。失败时弹层保持打开并提示原因，页面不变。
  Future<void> markPaid(
    BuildContext context,
    Map<String, dynamic> record,
  ) async {
    final id = '${record['id']}';
    if (busy ||
        disposed ||
        paying.contains(id) ||
        record['status'] != 'unpaid') {
      return;
    }
    final payee = '${record['payee'] ?? ''}'.trim();
    final confirmed = await hConfirm(
      context,
      '确认已付款？',
      message:
          '${payee.isEmpty ? record['category'] : payee} · ${expenseMoney(record['amount'] as num)}\n确认后这笔开支会标记为已付款',
      ok: '确认付款',
      danger: false,
      onConfirm: () async {
        paying.add(id);
        setBusy(true);
        try {
          final got = await request({
            'action': 'expense_get',
            'month': month,
            'id': id,
          });
          final item = expenseCopy(
            Map<String, dynamic>.from(got['item'] as Map),
          );
          if (item['status'] == 'unpaid') {
            item['status'] = 'paid';
            await request({...item, 'action': 'expense_save'}, write: true);
          }
        } finally {
          paying.remove(id);
          setBusy(false);
        }
      },
    );
    if (!confirmed) return;
    // 必须在 busy 解除之后再通知：页面在 busy 时会把刷新挂起，且没有别的信号唤醒它。
    expenseChanged.value++;
    if (context.mounted && !disposed) {
      AppToast.show(context, '已确认付款', kind: ToastKind.success);
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

  /// 日期用滚轮选择（年 / 月 / 日）。草稿里存 yyyy-MM-dd。
  Future<void> pickDate(BuildContext context) async {
    final current = '${draft['occurred_on']}'.replaceAll('-', '.');
    final value = await pickers.pickDate(
      context,
      '选择日期',
      birthday: false,
      current: current,
      fullFormat: true,
    );
    if (value == null || disposed || !context.mounted) return;
    draft['occurred_on'] = value.replaceAll('.', '-');
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

  Future<List<PayeeOption>> loadPayees(String query) async {
    final data = await _request({'action': 'expense_payees', 'query': query});
    return [
      for (final item in (data['items'] as List? ?? const []))
        PayeeOption.fromJson(Map<String, dynamic>.from(item as Map)),
    ];
  }

  Future<void> pickPayee(BuildContext context) async {
    final value = await showPayeeSheet(
      context,
      load: loadPayees,
      current: '${draft['payee']}',
    );
    if (value == null || disposed || !context.mounted) return;
    draft['payee'] = value;
    changed();
  }

  bool get hasSourceDocument => draft['source_document'] != null;

  /// 来源是库存单时，进入库存单详情；手工记账没有可跳转的单据。
  void openSource(BuildContext context) {
    final id = draft['source_document'];
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            InventoryManagementPage(mode: 'document', documentId: '$id'),
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
    urls: Map<String, String>.from(draft['attachment_urls'] ?? {}),
    request: request,
  );
}
