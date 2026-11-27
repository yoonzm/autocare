import '../expenses/voucher_gallery.dart';
import 'expiry_sheet.dart';
import '../../widgets/common.dart' show Divider1;

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
import 'stock_in_freight_sheet.dart';
import 'stock_out_pickers.dart';
import 'stock_in_price_sheet.dart' show moneyGrouped, showStockInPriceSheet;
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

/// 单据时间（设计稿「今天 10:36」）：按北京时间显示；今天「今天 10:36」、昨天「昨天 10:36」、
/// 今年其他日期「10.31 10:36」、跨年「2025.10.31 10:36」。无法解析时原样返回。
String documentTime(String iso, {DateTime? now}) {
  final at = DateTime.tryParse(iso);
  if (at == null) return iso;
  DateTime bj(DateTime d) => d.toUtc().add(const Duration(hours: 8));
  final d = bj(at), n = bj(now ?? DateTime.now());
  String two(int v) => v.toString().padLeft(2, '0');
  final hm = '${two(d.hour)}:${two(d.minute)}';
  final day = DateTime.utc(d.year, d.month, d.day);
  final today = DateTime.utc(n.year, n.month, n.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return '今天 $hm';
  if (diff == 1) return '昨天 $hm';
  final md = '${two(d.month)}.${two(d.day)}';
  return d.year == n.year ? '$md $hm' : '${d.year}.$md $hm';
}

String money(num n) => '¥${n.toStringAsFixed(2)}';
List<Map<String, dynamic>> maps(dynamic v) =>
    (v as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

/// 入库单价的默认值：最近一次入库单价；没有入库记录取商品成本价；都没有（或为 0）返回 null，页面显示「请输入」。
num? defaultInboundCost(Map<String, dynamic> product) {
  final last = product['last_cost'];
  if (last is num) return last;
  final cost = product['cost'];
  return cost is num && cost > 0 ? cost : null;
}

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
      // 入库单价或数量还没填完整的行不参与报价（服务端要求每行都有数字）。
      final quoteLines = mode == 'in'
          ? [
              for (final l in lines)
                if (l['cost'] is num && l['quantity'] is num) l,
            ]
          : lines;
      final request = quoteLines.isEmpty && lines.isNotEmpty
          ? Future<Map<String, dynamic>>.value({
              'item': {
                'subtotal': 0,
                'total': (payload['freight'] as num?) ?? 0,
              },
            })
          : merchantApi.invoke({
              'action': 'inventory_quote',
              'kind': mode,
              'payload': {...payload, 'lines': quoteLines},
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
          'cost': defaultInboundCost(p),
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

  /// [requote]：报价只取决于商品行和运费，其余字段（付款方式、日期、供应商、同步开支、附件等）
  /// 变化时传 false，不清空金额、不重新请求报价。
  void changed({bool requote = true}) {
    dirty = true;
    if (requote) scheduleQuote();
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
  String get freightLabel => moneyGrouped(payload['freight'] as num? ?? 0);

  /// 运费是否摊入商品成本（运费行右侧显示「计入成本」）。
  bool get freightToCost =>
      payload['freight_to_cost'] == true &&
      ((payload['freight'] as num? ?? 0) > 0);

  /// 运费弹层（设计稿 StockInFreight）。
  Future<void> editFreight(BuildContext context) async {
    if (busy) return;
    final subtotal = quote?['subtotal'];
    final result = await showStockInFreightSheet(
      context,
      current: payload['freight'] as num? ?? 0,
      toCost: payload['freight_to_cost'] == true,
      goodsTotal: subtotal is num ? subtotal : null,
      loadLast: () async {
        final supplier = '${payload['supplier'] ?? ''}'.trim();
        if (supplier.isEmpty || !merchantApi.hasSession) return null;
        final r = await merchantApi.invoke({
          'action': 'inventory_last_freight',
          'supplier': supplier,
        });
        final v = r['freight'];
        return v is num && v > 0 ? v : null;
      },
    );
    if (result == null || disposed) return;
    payload['freight'] = result.freight;
    payload['freight_to_cost'] = result.toCost;
    changed();
  }

  bool get workorderSet => '${payload['workorder'] ?? ''}'.isNotEmpty;
  bool get technicianSet => '${payload['technician'] ?? ''}'.isNotEmpty;
  String get workorderLabel => workorderSet ? '${payload['workorder']}' : '未关联';
  String get technicianLabel =>
      technicianSet ? '${payload['technician']}' : '未指定';
  String get _unit => '${detail['unit'] ?? ''}';
  num get _monthUsed => detail['month_used'] as num? ?? 0;
  String get receiptCode => 'RK-${id.substring(0, 8)}';
  String get subtotalLabel => quoted('subtotal');
  String get totalLabel => quoted('total');
  String get expenseLabel => '材料采购 · ${quoted('total')}';
  String get payableItemsLabel => '应付 · ${lines.length} 项商品';
  String get outSubtotalLabel => quoted('subtotal');

  /// 设计稿：关联了工单写「将计入该工单的成本核算」，没有关联写「未关联工单，仅记录出库成本」。
  String get outCostNote => workorderSet ? '将计入该工单的成本核算' : '未关联工单，仅记录出库成本';
  String get productName => '${detail['name'] ?? ''}';
  String get skuCategoryLabel =>
      'SKU ${detail['sku'] ?? ''} · ${detail['category'] ?? ''}';
  String get stockLabel => qty(detail['stock'] as num? ?? 0);
  String get unitLabel => _unit;
  String get safeStockLabel =>
      '安全库存 ${qty(detail['safe'] as num? ?? 0)} $_unit';

  /// 库存状态：low 低于安全库存 / ok 库存充足 / unset 没设置安全库存（安全库存为 0）。
  String get stockState {
    final safe = detail['safe'] as num? ?? 0;
    if (safe <= 0) return 'unset';
    return (detail['stock'] as num? ?? 0) < safe ? 'low' : 'ok';
  }

  String get stockStatusLabel => switch (stockState) {
    'low' => '低于安全库存',
    'ok' => '库存充足',
    _ => '未设置安全库存',
  };
  String get monthUsedLabel => '${qty(_monthUsed)} $_unit';
  String get availableDaysLabel => _monthUsed == 0
      ? '—'
      : '约 ${((detail['stock'] as num? ?? 0) * DateTime.now().day / _monthUsed).floor()} 天';

  /// 建议补货：补到安全库存的 2 倍；没设置安全库存时不给建议。
  String get replenishLabel => stockState == 'unset'
      ? '—'
      : '${qty(((detail['safe'] as num? ?? 0) * 2 - (detail['stock'] as num? ?? 0)).clamp(0, 999999999))} $_unit';
  String get specificationLabel => '${detail['specification'] ?? ''}'.isEmpty
      ? '—'
      : '${detail['specification']}';
  String get unitCostLabel =>
      '${moneyGrouped(detail['cost'] as num? ?? 0)} / $_unit';
  String get stockCostLabel => moneyGrouped(
    maps(
      detail['batches'],
    ).fold<num>(0, (n, b) => n + (b['quantity'] as num) * (b['cost'] as num)),
  );
  String get locationLabel =>
      '${detail['location'] ?? ''}'.isEmpty ? '—' : '${detail['location']}';

  Future<void> save(
    BuildContext context,
    bool post, {
    bool fromPreview = false,
  }) async {
    if (busy || _saving) return;
    if (mode == 'out') {
      // 切换过出库类型时，清掉与当前类型无关的字段。
      if (payload['reason'] != '损耗报废') payload.remove('scrap_reason');
      if (payload['reason'] != '退回供应商') {
        payload.remove('refund_amount');
        payload.remove('supplier');
        payload.remove('sync_expense');
      }
    }
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

  /// 进度条长度 = 库存 ÷ 安全库存（设计稿：2/5 画 40%），超过 100% 按满格；没设置安全库存画满格灰条。
  double get stockRatio => (detail['safe'] as num? ?? 0) == 0
      ? 1
      : ((detail['stock'] as num) / (detail['safe'] as num))
            .clamp(0, 1)
            .toDouble();
  Widget busyLabel(String kind, Widget child) => hBusy(
    actionKey(kind),
    child,
    style: child is Text ? child.style : null,
  );
  static const payments = ['现金', '微信', '对公转账', '挂账'];
  static const outReasons = ['施工领用', '损耗报废', '退回供应商', '内部使用'];
  static const scrapReasons = ['过期', '破损', '受潮变质', '其他'];
  int get paymentIndex => payments.indexOf('${payload['payment']}').clamp(0, 3);
  void selectPayment(int index) {
    if (busy) return;
    payload['payment'] = payments[index];
    changed(requote: false);
  }

  void selectFilter(int index) {
    filter = index;
    notifyListeners();
  }

  String actionKey(String action) =>
      'Inventory-${identityHashCode(this)}-$action';
  Future<void> submit(BuildContext context) async {
    if (busy) return;
    if (mode == 'out') {
      final issue = outIssue();
      if (issue != null) {
        AppToast.show(context, issue);
        return;
      }
    }
    if (mode == 'in') {
      final issue = inboundLineIssue();
      if (issue != null) {
        AppToast.show(context, issue);
        return;
      }
      // 启用保质期管理的商品必须填到期日（服务端同样校验）。
      final missing = lines
          .where((l) => lineShelf(l) && lineExpiry(l) == null)
          .firstOrNull;
      if (missing != null) {
        AppToast.show(context, '请填写「${lineName(missing)}」的到期日');
        return;
      }
    }
    await runBusy(actionKey('submit'), () => save(context, true));
  }

  /// 入库明细的单价、数量校验：单价必填（0 表示赠品），数量大于 0、最大 9999，不允许小数的商品只能填整数。
  String? inboundLineIssue({bool draft = false}) {
    for (final l in lines) {
      final name = lineName(l);
      if (!draft && l['cost'] is! num) return '请填写「$name」的入库单价';
      final q = l['quantity'];
      if (q is! num || q <= 0) return '「$name」的入库数量须大于 0';
      if (q > 9999) return '「$name」的入库数量最大 9999';
      if (product(l)['allow_decimal'] == false && q != q.truncate()) {
        return '「$name」只能入库整数数量';
      }
    }
    return null;
  }

  Future<void> saveDraft(BuildContext context) {
    if (busy) return Future.value();
    if (mode == 'in') {
      final issue = inboundLineIssue(draft: true);
      if (issue != null) {
        AppToast.show(context, issue);
        return Future.value();
      }
    }
    return runBusy(actionKey('draft'), () => save(context, false));
  }

  /// 出库页「关联工单」「领用技师」选择器的数据（进行中的工单、技师及其状态）。
  Future<Map<String, dynamic>> _assignments() =>
      merchantApi.invoke({'action': 'inventory_assignments'});

  /// 关联工单（设计稿 WorkOrderPicker）：选中后领用技师自动带入工单的技师，可再改；清除工单不清除技师。
  Future<void> pickWorkorder(BuildContext context) async {
    if (busy) return;
    try {
      Map<String, dynamic>? data;
      await runBusy(actionKey('assignments'), () async {
        data = await _assignments();
      });
      if (data == null || !context.mounted || disposed) return;
      final result = await showWorkOrderPicker(
        context,
        workorders: maps(data!['workorders']),
        selectedId: payload['workorder_id'] as String?,
      );
      if (result == null || disposed) return;
      final w = result.item;
      if (w == null) {
        payload
          ..remove('workorder_id')
          ..remove('order_id')
          ..remove('workorder');
      } else {
        payload['workorder_id'] = w['id'];
        payload.remove('order_id');
        payload['workorder'] = [
          '${w['plate'] ?? ''}',
          '${w['service'] ?? ''}',
        ].where((e) => e.isNotEmpty).join(' ');
        if (w['technician_id'] != null) {
          payload['technician_id'] = w['technician_id'];
          payload['technician'] = w['technician'];
        }
      }
      changed(requote: false);
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  }

  /// 领用技师（设计稿 StaffPicker）。
  Future<void> pickTechnician(BuildContext context) async {
    if (busy) return;
    try {
      Map<String, dynamic>? data;
      await runBusy(actionKey('assignments'), () async {
        data = await _assignments();
      });
      if (data == null || !context.mounted || disposed) return;
      final result = await showStaffPicker(
        context,
        technicians: maps(data!['technicians']),
        selectedId: payload['technician_id'] as String?,
      );
      if (result == null || disposed) return;
      final t = result.item;
      if (t == null) {
        payload
          ..remove('technician_id')
          ..remove('technician');
      } else {
        payload['technician_id'] = t['id'];
        payload['technician'] = t['name'];
      }
      changed(requote: false);
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  }

  Future<void> selectSupplier(BuildContext context) =>
      runBusy(actionKey('supplier'), () => pick(context, 'supplier', '供应商'));
  void setOutReason(String reason) {
    if (busy) return;
    payload['reason'] = reason;
    // 损耗报废默认「破损」（设计稿）；其他类型不带报废原因。
    if (reason == '损耗报废') {
      payload['scrap_reason'] ??= '破损';
    }
    // 退回供应商默认同步退款开支（设计稿：开关默认打开）。
    if (reason == '退回供应商') {
      payload['sync_expense'] ??= true;
    }
    changed(requote: false);
  }

  void setScrapReason(String reason) {
    if (busy) return;
    payload['scrap_reason'] = reason;
    changed(requote: false);
  }

  /// 出库单的类型相关校验：退回供应商要选供应商，损耗报废要有报废原因。
  String? outIssue() {
    final reason = payload['reason'];
    if (reason == '退回供应商' && '${payload['supplier'] ?? ''}'.trim().isEmpty) {
      return '请选择供应商';
    }
    if (reason == '损耗报废' && '${payload['scrap_reason'] ?? ''}'.isEmpty) {
      return '请选择报废原因';
    }
    return null;
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
    if (mode == 'detail') {
      final updated = await editProduct(context, detail);
      if (updated != null && !disposed) {
        detail.addAll(updated);
        notifyListeners();
      }
      return;
    }
    if (key == 'date') {
      // 滚轮选择：只能选今天及之前（最近一年内）；返回 YYYY.MM.DD。
      final picked = await pickDate(
        context,
        '入库日期',
        birthday: false,
        current: '${payload['date'] ?? ''}'.replaceAll('-', '.'),
        pastOnly: true,
        fullFormat: true,
      );
      if (picked != null) {
        payload['date'] = picked.replaceAll('.', '-');
        changed(requote: false);
      }
      return;
    }
    if (key == 'supplier' && (mode == 'in' || mode == 'out')) {
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
        changed(requote: false);
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
      changed(requote: key == 'freight');
    }
  }

  Widget expenseSwitch(BuildContext context) => HSwitchValue(
    value: payload['sync_expense'] == true,
    onChanged: (_) {
      // Posting books the linked expense in the same database transaction.
      payload['sync_expense'] = payload['sync_expense'] != true;
      changed(requote: false);
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
        'cost': defaultInboundCost(result),
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
        'cost': defaultInboundCost(result),
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
      mode == 'in' ? 9999 : 999999999,
    );
    changed();
  }

  Widget quantityLabel(
    BuildContext context,
    Map<String, dynamic> line, {
    double size = 15,
  }) => GestureDetector(
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
      style: ts(size, w: FontWeight.w600),
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

  /// 入库单价显示：没有默认价时显示「请输入」，不显示 ¥0.00。
  String lineCostText(Map<String, dynamic> l) {
    final c = l['cost'];
    return c is num ? moneyGrouped(c) : '请输入';
  }

  String lineUnit(Map<String, dynamic> l) => '${product(l)['unit']}';

  /// 单价为 0 的行按赠品入库。
  bool lineIsGift(Map<String, dynamic> l) => l['cost'] is num && l['cost'] == 0;

  String lineUnitCostLabel(Map<String, dynamic> l) {
    final p = product(l);
    return '单价 ${l['cost'] is num ? money(l['cost'] as num) : '请输入'} / ${p['unit']}';
  }

  String lineBatchLabel(Map<String, dynamic> l) {
    return '自动生成 · ${l['expires_on'] ?? '无保质期'}';
  }

  /// 商品是否启用了保质期管理（入库必须填写到期日）。
  bool lineShelf(Map<String, dynamic> l) => product(l)['shelf_life'] == true;

  /// 到期日显示为 YYYY.MM.DD；还没填返回 null。
  String? lineExpiry(Map<String, dynamic> l) {
    final v = '${l['expires_on'] ?? ''}';
    return v.isEmpty ? null : v.replaceAll('-', '.');
  }

  String lineTotalLabel(Map<String, dynamic> l) {
    final c = l['cost'];
    return c is num ? moneyGrouped((l['quantity'] as num? ?? 0) * c) : '—';
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
      final p = product(l);
      final v = await showStockInPriceSheet(
        context,
        productName: lineName(l),
        unit: '${p['unit']}',
        quantity: l['quantity'] as num? ?? 0,
        current: l['cost'] as num?,
        lastCost: p['last_cost'] as num?,
        productCost: p['cost'] as num?,
      );
      if (v != null) {
        l['cost'] = v;
        changed();
      }
    } else {
      // 到期日只有启用保质期管理的商品才需要填写；日期弹层按入库日期推算。
      final picked = await pickExpiryDate(
        context,
        productName: lineName(l),
        received:
            DateTime.tryParse('${payload['date'] ?? ''}') ?? DateTime.now(),
        current: '${l[field] ?? ''}',
        shelfMonths: (product(l)['shelf_months'] as num?)?.toInt(),
      );
      if (picked != null) {
        l[field] = picked;
        changed(requote: false);
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
      for (final l in lines) ...[
        if (mode == 'in' && l != lines.first) const Divider1(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: mode == 'in' ? 12 : 7),
          child: mode == 'in'
              ? StockInLineTemplate(c: this, line: l)
              : StockOutLineTemplate(c: this, line: l),
        ),
      ],
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
}) => hInputDialog(
  context,
  title: title,
  hintText: hint.trim().isEmpty ? '请输入$title' : hint,
  initial: initial,
  keyboardType: numeric
      ? const TextInputType.numberWithOptions(decimal: true)
      : TextInputType.text,
);

/// 新增 / 编辑商品：设计稿的整页（ProductEdit / ProductEditExist），保存成功后返回商品。
Future<Map<String, dynamic>?> editProduct(
  BuildContext context,
  Map<String, dynamic>? original,
) => Navigator.of(context).push<Map<String, dynamic>>(
  appSheetRoute<Map<String, dynamic>>(
    settings: const RouteSettings(name: 'ProductEdit'),
    page: ProductEditLivePage(product: original),
  ),
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
      c.changed(requote: false);
    },
  );
}
