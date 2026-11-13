import '../expenses/voucher_gallery.dart';

import 'dart:convert';

import 'inventory_management_page.dart';
import 'inventory_management_controller.dart' show showStockShortage;
import 'inventory_pickers.dart';
import 'product_edit_live_page.dart';
import 'inventory_record_templates.dart';

import 'package:flutter/material.dart';

import '../../kit/sheet_route.dart';

import 'dart:async';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../theme.dart';
import 'inventory_live_page.dart';
import 'stock_in_line_template.dart';
import 'stock_out_line_template.dart';

/// Keep the key across ambiguous network failures; editing creates a new intent.
class InventoryRequest {
  String? _body, _id;
  Future<Map<String, dynamic>> send(Map<String, dynamic> body) {
    final encoded = jsonEncode(body);
    if (_body != encoded) {
      _body = encoded;
      _id = MerchantApi.newRequestId();
    }
    return merchantApi.invoke(body, requestId: _id);
  }
}

final inventoryChanged = ValueNotifier(0);
String inventoryId() {
  final s = MerchantApi.newRequestId();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

String qty(num n) => n.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

/// 设计稿的入库日期显示成「今天 10.31」；其他日期显示「10.31」，跨年显示「2025.10.31」。
String dateLabel(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return iso;
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final md = '${two(d.month)}.${two(d.day)}';
  if (d.year == now.year && d.month == now.month && d.day == now.day) {
    return '今天 $md';
  }
  return d.year == now.year ? md : '${d.year}.$md';
}

String money(num n) => '¥${n.toStringAsFixed(2)}';
List<Map<String, dynamic>> maps(dynamic v) =>
    (v as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

class InventoryController extends ChangeNotifier {
  void setBusy(bool value) {
    busy = value;
    if (!disposed) notifyListeners();
  }

  final String mode;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> detail;
  late String id;
  int revision = 0, filter = 0;
  bool busy = false, dirty = false, disposed = false;
  bool _saving = false;
  final mutation = InventoryRequest();
  Map<String, dynamic> payload = {};
  List<Map<String, dynamic>> lines = [];
  Timer? _quoteTimer;
  int _quoteVersion = 0;
  Map<String, dynamic>? quote;
  Object? quoteError;
  bool _quoting = false;
  String quoted(String field) => quoteError != null
      ? '点击重试'
      : quote == null
      ? '—'
      : money(quote![field] as num);
  void scheduleQuote() {
    if (disposed || mode == 'detail' || !merchantApi.hasSession) return;
    quote = null;
    quoteError = null;
    _quoting = false;
    _quoteVersion++;
    _quoteTimer?.cancel();
    _quoteTimer = Timer(const Duration(milliseconds: 300), refreshQuote);
  }

  Future<void> refreshQuote() async {
    if (disposed) return;
    final version = _quoteVersion;
    _quoting = true;
    if (!disposed) notifyListeners();
    try {
      final request = merchantApi.invoke({
        'action': 'inventory_quote',
        'kind': mode,
        'payload': {...payload, 'lines': lines},
      });
      final result =
          (await Future.wait([
                request,
                Future<void>.delayed(kIndicatorMinShow),
              ]))[0]
              as Map<String, dynamic>;
      if (disposed || version != _quoteVersion) return;
      quote = Map<String, dynamic>.from(result['item']);
      quoteError = null;
    } catch (e) {
      if (disposed || version != _quoteVersion) return;
      quoteError = e;
    }
    _quoting = false;
    if (!disposed) notifyListeners();
  }

  Widget amountWidget(BuildContext context, Widget child) => GestureDetector(
    onTap: () {
      if (quoteError != null) AppToast.error(context, quoteError!);
      scheduleQuote();
      if (!disposed) notifyListeners();
    },
    child: _quoting
        ? Stack(
            alignment: Alignment.center,
            children: [
              Opacity(opacity: 0, child: child),
              AppSpinner(
                size: 16,
                color: child is Text ? child.style?.color ?? C.ink : C.ink,
              ),
            ],
          )
        : child,
  );
  InventoryController(
    this.mode,
    List<Map<String, dynamic>> initialProducts,
    Map<String, dynamic> initialDetail,
    Map<String, dynamic>? draft,
    String? selected,
  ) : products = [
        for (final p in initialProducts) {...p},
      ],
      detail = {...initialDetail} {
    id = draft?['id'] as String? ?? inventoryId();
    revision = draft?['revision'] as int? ?? 0;
    payload = draft == null
        ? {
            'supplier': '',
            'date': DateTime.now().toIso8601String().substring(0, 10),
            'freight': 0,
            'payment': '现金',
            'reason': '施工领用',
            'note': '',
          }
        : Map<String, dynamic>.from(draft['payload']);
    lines = maps(payload['lines']);
    if (selected != null &&
        mode != 'detail' &&
        !lines.any((l) => l['id'] == selected)) {
      final p = products.where((p) => p['id'] == selected).firstOrNull;
      if (p != null) {
        lines.add({
          'id': p['id'],
          'quantity': 1,
          'cost': p['cost'],
          'version': p['version'],
        });
      }
    }
    scheduleQuote();
  }
  void replaceProducts(List<Map<String, dynamic>> latest) {
    products
      ..clear()
      ..addAll(latest);
    scheduleQuote();
  }

  void changed() {
    dirty = true;
    scheduleQuote();
    if (!disposed) notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    _quoteTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic> product(Map<String, dynamic> l) =>
      products.firstWhere((p) => p['id'] == l['id']);
  String get supplierLabel =>
      '${mode == 'detail' ? detail['supplier'] : payload['supplier']}'.isEmpty
      ? '请输入供应商'
      : '${mode == 'detail' ? detail['supplier'] : payload['supplier']}';
  String get dateLabelText => dateLabel('${payload['date']}');
  String get freightLabel => money(payload['freight'] as num? ?? 0);
  String get workorderLabel => '${payload['workorder'] ?? '未关联'}';
  String get technicianLabel => '${payload['technician'] ?? '未指定'}';
  String get _unit => '${detail['unit'] ?? ''}';
  num get _monthUsed => detail['month_used'] as num? ?? 0;
  String get receiptCode => 'RK-${id.substring(0, 8)}';
  String get subtotalLabel => quoted('subtotal');
  String get totalLabel => quoted('total');
  String get expenseLabel => '材料采购 · ${quoted('total')}';
  String get payableItemsLabel => '应付 · ${lines.length} 项商品';
  String get outSubtotalLabel => quoted('subtotal');
  String get outCostNote => '记录本次出库成本';
  String get productName => '${detail['name'] ?? ''}';
  String get skuCategoryLabel =>
      'SKU ${detail['sku'] ?? ''} · ${detail['category'] ?? ''}';
  String get stockLabel => qty(detail['stock'] as num? ?? 0);
  String get unitLabel => _unit;
  String get safeStockLabel =>
      '安全库存 ${qty(detail['safe'] as num? ?? 0)} $_unit';
  String get stockStatusLabel =>
      (detail['stock'] as num? ?? 0) < (detail['safe'] as num? ?? 0)
      ? '低于安全库存'
      : '库存充足';
  String get monthUsedLabel => '${qty(_monthUsed)} $_unit';
  String get availableDaysLabel => _monthUsed == 0
      ? '—'
      : '约 ${((detail['stock'] as num? ?? 0) * DateTime.now().day / _monthUsed).floor()} 天';
  String get replenishLabel =>
      '${qty(((detail['safe'] as num? ?? 0) * 2 - (detail['stock'] as num? ?? 0)).clamp(0, 999999999))} $_unit';
  String get specificationLabel => '${detail['specification'] ?? ''}';
  String get unitCostLabel => '${money(detail['cost'] as num? ?? 0)} / $_unit';
  String get stockCostLabel => money(
    maps(
      detail['batches'],
    ).fold<num>(0, (n, b) => n + (b['quantity'] as num) * (b['cost'] as num)),
  );
  String get locationLabel => '${detail['location'] ?? ''}';

  Future<void> save(
    BuildContext context,
    bool post, {
    bool fromPreview = false,
  }) async {
    if (busy || _saving) return;
    _saving = true;
    busy = true;
    notifyListeners();
    try {
      final result = await mutation.send({
        'action': 'inventory_document',
        'id': id,
        'kind': mode,
        'revision': revision,
        'post': post,
        'payload': {...payload, 'lines': lines},
      });
      revision = (result['item'] as Map)['revision'] as int;
      dirty = false;
      busy = false;
      if (!disposed) notifyListeners();
      await WidgetsBinding.instance.endOfFrame;
      inventoryChanged.value++;
      if (context.mounted && !disposed) {
        AppToast.show(context, post ? '已提交' : '草稿已保存');
        if (post) {
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  InventoryManagementPage(mode: 'document', documentId: id),
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mode == 'out' && e.toString().contains('库存不足')) {
        try {
          final result = await merchantApi.invoke({'action': 'inventory_list'});
          products
            ..clear()
            ..addAll(maps(result['items']));
          if (context.mounted && !disposed) {
            await showStockShortage(context, this);
          }
          return;
        } catch (_) {
          /* Preserve the draft and show the original failure. */
        }
      }
      if (context.mounted && !disposed) AppToast.error(context, e);
    } finally {
      _saving = false;
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  double get stockRatio => (detail['safe'] as num? ?? 0) == 0
      ? 1
      : ((detail['stock'] as num) / (detail['safe'] as num) / 2)
            .clamp(0, 1)
            .toDouble();
  Widget busyLabel(String kind, Widget child) => hBusy(
    actionKey(kind),
    child,
    style: child is Text ? child.style : null,
    label: kind == 'submit' ? '提交中…' : null,
  );
  static const payments = ['现金', '微信', '对公转账', '挂账'];
  static const outReasons = ['施工领用', '损耗报废', '退回供应商', '内部使用'];
  int get paymentIndex => payments.indexOf('${payload['payment']}').clamp(0, 3);
  int get reasonIndex => outReasons.indexOf('${payload['reason']}').clamp(0, 3);
  void selectPayment(int index) {
    if (busy) return;
    payload['payment'] = payments[index];
    changed();
  }

  void selectReason(int index) => setOutReason(outReasons[index]);
  void selectFilter(int index) {
    filter = index;
    notifyListeners();
  }

  String actionKey(String action) =>
      'Inventory-${identityHashCode(this)}-$action';
  Future<void> submit(BuildContext context) async {
    if (busy) return;
    await runBusy(actionKey('submit'), () => save(context, true));
  }

  Future<void> saveDraft(BuildContext context) => busy
      ? Future.value()
      : runBusy(actionKey('draft'), () => save(context, false));
  Future<void> selectSupplier(BuildContext context) =>
      runBusy(actionKey('supplier'), () => pick(context, 'supplier', '供应商'));
  void setOutReason(String reason) {
    if (busy) return;
    payload['reason'] = reason;
    changed();
  }

  void openMovement(BuildContext context, String movement) {
    Navigator.of(context).push(
      appSheetRoute<void>(
        page: InventoryLivePage(mode: movement, productId: detail['id']),
      ),
    );
  }

  Future<void> pick(BuildContext context, String key, String label) async {
    if (busy) return;
    try {
      await _pick(context, key, label);
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  }

  Future<void> _pick(BuildContext context, String key, String label) async {
    if (key == 'workorder' || key == 'technician') {
      try {
        final response = await merchantApi.invoke({
          'action': 'inventory_assignments',
        });
        if (!context.mounted || disposed) return;
        final items = maps(
          response[key == 'technician' ? 'technicians' : 'orders'],
        );
        final value = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          builder: (ctx) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: EmptyView.firstTime(title: '还没有可选记录'),
                  ),
                for (final item in items)
                  ListTile(
                    title: Text('${item['label'] ?? item['name']}'),
                    onTap: () => Navigator.pop(ctx, item),
                  ),
              ],
            ),
          ),
        );
        if (value != null) {
          final label = '${value['label'] ?? value['name']}';
          payload[key == 'technician' ? 'technician_id' : 'order_id'] =
              value['id'];
          payload[key == 'technician' ? 'technician' : 'workorder'] = label;
          changed();
        }
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      }
      return;
    }
    if (mode == 'detail') {
      final updated = await editProduct(context, detail);
      if (updated != null && !disposed) {
        detail.addAll(updated);
        notifyListeners();
      }
      return;
    }
    if (key == 'date') {
      final d = await showDatePicker(
        context: context,
        initialDate: DateTime.tryParse('${payload['date']}') ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
      );
      if (d != null) {
        payload['date'] = d.toIso8601String().substring(0, 10);
        changed();
      }
      return;
    }
    if (key == 'supplier' && mode == 'in') {
      final options = await merchantApi.invoke({'action': 'inventory_options'});
      if (!context.mounted || disposed) return;
      final name = await showSupplierPicker(
        context,
        suppliers: maps(options['suppliers'])
            .map((s) => '${s['name']}')
            .toList(),
        current: '${payload['supplier'] ?? ''}',
      );
      if (name != null) {
        payload['supplier'] = name;
        changed();
      }
      return;
    }
    final field = key == 'freight' ? 'freight' : 'supplier';
    final v = await inputDialog(
      context,
      label,
      '请输入$label',
      '${payload[field] ?? ''}',
      numeric: key == 'freight',
    );
    if (v != null) {
      final value = key == 'freight' ? num.tryParse(v) : v;
      if (value == null) return;
      payload[field] = value;
      changed();
    }
  }

  Widget expenseSwitch(BuildContext context) => HSwitchValue(
    value: payload['sync_expense'] == true,
    onChanged: (_) {
      // Posting books the linked expense in the same database transaction.
      payload['sync_expense'] = payload['sync_expense'] != true;
      changed();
    },
  );
  Future<void> scan(BuildContext context) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) =>
            const InventoryManagementPage(mode: 'scan', returnProduct: true),
      ),
    );
    if (result == null) return;
    if (!products.any((p) => p['id'] == result['id'])) products.add(result);
    if (!lines.any((l) => l['id'] == result['id'])) {
      lines.add({
        'id': result['id'],
        'quantity': 1,
        'cost': result['cost'],
        'version': result['version'],
      });
    }
    changed();
  }

  Future<void> add(BuildContext context) async {
    final picked = await showProductPicker(
      context,
      products: products,
      excluded: {for (final l in lines) l['id']},
      onCreate: () => editProduct(context, null),
    );
    if (picked == null || picked.isEmpty) return;
    for (final result in picked) {
      if (!products.any((p) => p['id'] == result['id'])) products.add(result);
      lines.add({
        'id': result['id'],
        'quantity': 1,
        'cost': result['cost'],
        'version': result['version'],
      });
    }
    changed();
  }

  void remove(Map<String, dynamic> line) {
    lines.remove(line);
    changed();
  }

  void adjust(Map<String, dynamic> line, num delta) {
    line['quantity'] = ((line['quantity'] as num? ?? 0) + delta).clamp(
      0,
      999999999,
    );
    changed();
  }

  Widget quantityLabel(BuildContext context, Map<String, dynamic> line) =>
      GestureDetector(
        onTap: () async {
          final v = await inputDialog(
            context,
            '数量',
            '请输入数量',
            '${line['quantity'] ?? ''}',
            numeric: true,
          );
          if (v != null) {
            line['quantity'] = num.tryParse(v);
            changed();
          }
        },
        child: Text(
          qty(line['quantity'] as num? ?? 0),
          style: ts(15, w: FontWeight.w600),
        ),
      );

  String lineName(Map<String, dynamic> l) {
    final p = product(l);
    return '${p['name']}';
  }

  String lineStockLabel(Map<String, dynamic> l) {
    final p = product(l);
    return '当前库存 ${qty(p['stock'])} ${p['unit']}${p['stock'] < p['safe'] ? ' · 低于安全库存' : ''}';
  }

  String lineUnitCostLabel(Map<String, dynamic> l) {
    final p = product(l);
    return '单价 ${money(l['cost'])} / ${p['unit']}';
  }

  String lineBatchLabel(Map<String, dynamic> l) {
    return '批次 自动生成 · ${l['expires_on'] ?? '无保质期'}';
  }

  String lineTotalLabel(Map<String, dynamic> l) {
    return money((l['quantity'] as num? ?? 0) * (l['cost'] as num));
  }

  String lineRemainingLabel(Map<String, dynamic> l) {
    final p = product(l);
    return '出库后 ${qty((p['stock'] as num) - (l['quantity'] as num? ?? 0))} ${p['unit']}';
  }

  Future<void> editLine(
    BuildContext context,
    Map<String, dynamic> l,
    String field,
  ) async {
    if (field == 'cost') {
      final v = await inputDialog(
        context,
        '成本单价',
        '请输入成本单价',
        '${l['cost']}',
        numeric: true,
      );
      if (v != null && num.tryParse(v) != null) {
        l['cost'] = num.parse(v);
        changed();
      }
    } else {
      final v = await inputDialog(
        context,
        '有效期',
        'YYYY-MM-DD，留空表示无保质期',
        '${l[field] ?? ''}',
      );
      if (v != null) {
        l[field] = v;
        changed();
      }
    }
  }

  Widget quantityWidget(BuildContext context, Map<String, dynamic> l) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton(
        onPressed: () {
          l['quantity'] = ((l['quantity'] as num? ?? 0) - 1).clamp(
            0,
            999999999,
          );
          changed();
        },
        icon: const Icon(Icons.remove, size: 14),
      ),
      GestureDetector(
        onTap: () async {
          final v = await inputDialog(
            context,
            '数量',
            '请输入数量',
            '${l['quantity'] ?? ''}',
            numeric: true,
          );
          if (v != null) {
            l['quantity'] = num.tryParse(v);
            changed();
          }
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Text(
              l['quantity'] == null ? '—' : qty(l['quantity']),
              style: ts(15, w: FontWeight.w600),
            ),
          ),
        ),
      ),
      IconButton(
        onPressed: () {
          l['quantity'] = (l['quantity'] as num? ?? 0) + 1;
          changed();
        },
        icon: const Icon(Icons.add, size: 14),
      ),
    ],
  );
  Widget linesWidget(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (lines.isEmpty) const EmptyView.firstTime(title: '还没有选择商品'),
      for (final l in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: mode == 'in'
              ? StockInLineTemplate(c: this, line: l)
              : StockOutLineTemplate(c: this, line: l),
        ),
      mode == 'in' ? StockInAddTemplate(c: this) : StockOutAddTemplate(c: this),
    ],
  );
  String batchCode(Map<String, dynamic> r) =>
      '批次 ${'${r['id']}'.substring(0, 8)}';
  String batchDates(Map<String, dynamic> r) =>
      '入库 ${r['received_on']} · ${r['expires_on'] ?? '无保质期'}';
  String batchQuantity(Map<String, dynamic> r) =>
      '剩 ${qty(r['quantity'])} ${detail['unit']}';
  String recordKind(Map<String, dynamic> r) {
    final payload = Map<String, dynamic>.from(r['payload']);
    if (payload['kind'] == 'void') return '单据作废';
    return payload['kind'] == 'out'
        ? '${payload['reason'] ?? '商品出库'}'
        : payload['kind'] == 'in'
        ? '采购入库'
        : '盘点调整';
  }

  String recordNote(Map<String, dynamic> r) {
    final payload = Map<String, dynamic>.from(r['payload']);
    return '${payload['supplier'] ?? ''} ${payload['note'] ?? ''}'.trim();
  }

  String recordTime(Map<String, dynamic> r) {
    final d = DateTime.tryParse('${r['created_at']}')?.toLocal();
    return d == null ? '' : d.toString().substring(0, 16);
  }

  String recordQuantity(Map<String, dynamic> r) {
    final n = (r['after_stock'] as num) - (r['before_stock'] as num);
    return '${n > 0 ? '+' : ''}${qty(n)} ${detail['unit']}';
  }

  Widget batchesWidget(BuildContext context) => Column(
    children: [
      for (final r in maps(detail['batches']))
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: InventoryBatchTemplate(c: this, record: r),
        ),
      if (maps(detail['batches']).isEmpty)
        const EmptyView.firstTime(title: '还没有批次库存'),
    ],
  );
  Widget historyWidget(BuildContext context) {
    final records = maps(detail['movements'])
        .where(
          (m) =>
              filter == 0 || m['payload']['kind'] == ['', 'in', 'out'][filter],
        )
        .toList();
    return Column(
      children: [
        for (final r in records)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: switch (r['payload']['kind']) {
              'in' => InventoryInRecordTemplate(c: this, record: r),
              'out' => InventoryOutRecordTemplate(c: this, record: r),
              _ => InventoryCheckRecordTemplate(c: this, record: r),
            },
          ),
        if (records.isEmpty) const EmptyView.firstTime(title: '还没有出入库流水'),
      ],
    );
  }
}

Future<String?> inputDialog(
  BuildContext context,
  String title,
  String hint,
  String initial, {
  bool numeric = false,
}) async {
  final ctrl = TextEditingController(text: initial);
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
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
  // Dialog transition may still read its controller on dismissal.
  await Future<void>.delayed(const Duration(milliseconds: 300));
  ctrl.dispose();
  return result;
}

/// 新增 / 编辑商品：设计稿的整页（ProductEdit / ProductEditExist），保存成功后返回商品。
Future<Map<String, dynamic>?> editProduct(
  BuildContext context,
  Map<String, dynamic>? original,
) => Navigator.of(context).push<Map<String, dynamic>>(
  MaterialPageRoute(builder: (_) => ProductEditLivePage(product: original)),
);

class InventoryNoteInput extends StatelessWidget {
  final InventoryController c;
  final TextStyle style;
  final String hint;
  final int? maxLines;
  const InventoryNoteInput({
    super.key,
    required this.c,
    required this.style,
    this.hint = '',
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) => TextFormField(
    initialValue: '${c.payload['note'] ?? ''}',
    style: style,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint.isEmpty ? '请输入备注' : hint,
      border: InputBorder.none,
    ),
    onChanged: (v) {
      c.payload['note'] = v;
      c.dirty = true;
    },
  );
}

/// Upload requires a storage policy and attachment API; never retain a local-only
/// image and imply it was attached to a posted document.
class InventoryAttachment extends StatelessWidget {
  final InventoryController c;
  const InventoryAttachment({super.key, required this.c});
  @override
  Widget build(BuildContext context) => VoucherGallery(
    title: '送货单 / 发票',
    helper: '选填',
    max: 6,
    paths: List<String>.from(c.payload['attachments'] ?? []),
    request: (body) =>
        merchantApi.invoke(body, timeout: const Duration(seconds: 60)),
    enabled: !c.busy,
    onBusyChanged: c.setBusy,
    onChanged: (paths) {
      if (c.disposed) return;
      c.payload['attachments'] = paths;
      c.changed();
    },
  );
}
