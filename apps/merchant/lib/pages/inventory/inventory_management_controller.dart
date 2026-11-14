import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../theme.dart';
import 'inventory_management_page.dart';
import 'inventory_live_page.dart';
import 'product_edit_live_page.dart';
import 'inventory_management_row_templates.dart';
import 'stock_void_bound_template.dart';
import 'stock_out_short_bound_template.dart';
import 'scan_product_result_bound_template.dart';
import 'scan_product_not_found_bound_template.dart';
import 'inventory_controller.dart';

class InventoryManagementController extends ChangeNotifier {
  final String mode;
  final String? documentId;
  final InventoryController? count;
  final bool returnProduct;
  Map<String, dynamic>? activeLine;
  num? pendingQuantity;
  String pendingNote = "";
  InventoryManagementController(
    this.mode, {
    this.documentId,
    this.count,
    this.returnProduct = false,
  }) {
    count?.addListener(_countChanged);
  }
  void _countChanged() {
    if (!disposed) notifyListeners();
  }

  bool busy = false,
      dirty = false,
      disposed = false,
      blind = true,
      freeze = false;
  int tab = 0, status = 0, scope = 0, selectionEpoch = 0;
  String? scopeValue;
  Map<String, dynamic> settings = {}, document = {}, scanProduct = {};
  List<Map<String, dynamic>> categories = [], documents = [], products = [];
  final request = InventoryRequest();
  final scanner = MobileScannerController(
    autoStart: true,
    formats: [BarcodeFormat.all],
  );
  Future<void> Function()? reload;
  late final countId = inventoryId();
  final categoryIds = <String, String>{};
  String lastCode = '', voidReason = '录错数量';
  String get kind => count?.mode ?? '${document['kind'] ?? ['in', 'out'][tab]}';
  List<Map<String, dynamic>> get lines =>
      count?.lines ?? maps(document['payload']?['lines']);
  List<Map<String, dynamic>> get snapshots =>
      count?.products ?? maps(document['payload']?['snapshots']);
  Map<String, dynamic> product(Map<String, dynamic> l) =>
      snapshots.where((p) => p['id'] == l['id']).firstOrNull ??
      {'name': '历史商品', 'unit': '', 'stock': 0, 'cost': 0};
  List<Map<String, dynamic>> get movements =>
      maps(document['movements'])
          .where((m) => m['payload']?['kind'] != 'void')
          .toList();
  void apply(Map<String, dynamic> data) {
    if (mode == 'docs') documents = maps(data['items']);
    if (mode == 'document') document = Map<String, dynamic>.from(data['item']);
    if (mode == 'settings' && !dirty) {
      settings = Map<String, dynamic>.from(data['settings']);
    }
    if (data['categories'] != null) categories = maps(data['categories']);
  }

  void changed() {
    dirty = true;
    if (!disposed) notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    count?.removeListener(_countChanged);
    scanner.dispose();
    super.dispose();
  }

  String code(Map<String, dynamic> d) =>
      '${{'in': 'RK', 'out': 'CK'}[d['kind']]}-${'${d['id']}'.split('-').first}';
  String state(Map<String, dynamic> d) => switch (d['status']) {
    'draft' => '草稿',
    'void' => '已作废',
    _ => d['kind'] == 'in' ? '已入库' : '已出库',
  };
  String categoryName(Map<String, dynamic> row) => '${row['name']}';
  String categoryCount(Map<String, dynamic> row) => '${row['count']} 个商品';
  String documentRowSummary(Map<String, dynamic> row) =>
      '${row['payload']?['supplier'] ?? row['payload']?['reason'] ?? ''} · ${maps(row['payload']?['lines']).length} 种商品';
  String documentRowTotal(Map<String, dynamic> row) =>
      money(row['total'] as num? ?? 0);
  String itemName(Map<String, dynamic> row) => '${product(row)['name']}';
  String itemBatch(Map<String, dynamic> row) => kind == 'in'
      ? '单价 ${money(row['cost'] as num? ?? 0)} / ${product(row)['unit']}'
      : '先进先出 · ${row['expires_on'] ?? '无保质期'}';
  String itemQuantity(Map<String, dynamic> row) =>
      '× ${qty(row['quantity'] as num? ?? 0)} ${product(row)['unit']}';
  Map<String, dynamic>? get shortageLine => count!.lines
      .where(
        (l) => (l['quantity'] as num) > (count!.product(l)['stock'] as num),
      )
      .firstOrNull;
  Map<String, dynamic>? get shortageProduct =>
      shortageLine == null ? null : count!.product(shortageLine!);
  String get shortageName => '${shortageProduct?['name'] ?? ''}';
  String get shortageNeeded => shortageLine == null
      ? '—'
      : '需要 ${qty(shortageLine!['quantity'])} ${shortageProduct!['unit']}';
  String get shortageStock => shortageProduct == null
      ? '—'
      : '${qty(shortageProduct!['stock'])} ${shortageProduct!['unit']}';
  String get shortageQuantity => shortageLine == null
      ? '—'
      : '${qty((shortageLine!['quantity'] as num) - (shortageProduct!['stock'] as num))} ${shortageProduct!['unit']}';
  String get missingBarcodeLabel => '没有找到条码 $lastCode 对应的商品';
  String get scanSkuLocation =>
      'SKU ${scanProduct['sku']} · ${scanProduct['location'] ?? ''}';
  String get scanStockState =>
      (scanProduct['stock'] as num? ?? 0) < (scanProduct['safe'] as num? ?? 0)
      ? '低库存'
      : scanProduct['active'] == false
      ? '已停用'
      : '库存充足';
  String get scanName => '${scanProduct['name'] ?? ''}';
  String get scanStock =>
      '库存 ${qty(scanProduct['stock'] as num? ?? 0)} ${scanProduct['unit'] ?? ''}';
  String get categoryScopeLabel =>
      scope == 1 && scopeValue != null ? '$scopeValue' : '按分类';
  String get locationScopeLabel =>
      scope == 2 && scopeValue != null ? '$scopeValue' : '按货位';
  String get documentCode => code(document);
  String get documentState =>
      mode == 'docs' ? ['已入库', '已出库'][tab] : state(document);
  String get documentDate =>
      '${document['posted_at'] ?? document['created_at'] ?? ''}';
  String get documentSupplier => '${document['payload']?['supplier'] ?? ''}';
  String get documentPayment => '${document['payload']?['payment'] ?? ''}';
  String get documentReason => '${document['payload']?['reason'] ?? ''}';
  String get documentWorkorder =>
      '${document['payload']?['workorder'] ?? '未关联'}';
  String get documentOperator =>
      '${document['payload']?['technician'] ?? '店主'}';
  String get documentExpense =>
      document['expense'] != null && document['expense']['deleted'] != true
      ? '是 · ${money(document['expense']['amount'])}'
      : '否';
  String get documentTotal => money(document['total'] as num? ?? 0);
  String get documentItemsTitle =>
      '${kind == 'in' ? '入库' : '出库'}商品 · ${lines.length} 项';
  String get voidTitle => '作废${kind == 'in' ? '入库' : '出库'}单';
  String get voidEffectLabel =>
      '作废后恢复该单据之前的库存批次，并撤销关联开支 ${money(document['expense']?['amount'] as num? ?? 0)}。';
  String get voidAvailabilityLabel => document['can_void'] == true
      ? '当前单据可作废；作废记录永久保留。'
      : '单据已有后续库存变动或缺少撤销记录，无法作废。';
  String get voidConfirmLabel => document['can_void'] == true ? '确认作废' : '无法作废';
  String get voidButtonLabel => document['status'] == 'void' ? '已作废' : '作废此单';
  String get submitLabel => mode == 'document' ? state(document) : '确认提交';

  Color documentTabBackground(int index) =>
      index == tab ? C.primarySoft : C.chip;
  Color documentStatusBackground(int index) =>
      index == status ? C.primarySoft : C.chip;

  Widget busyLabel(Widget child) =>
      hBusy(actionKey, child, style: child is Text ? child.style : null);
  static const expiryDays = [7, 15, 30, 60];
  static const voidReasons = ['录错数量', '录错商品', '供应商退货', '其他'];
  int get expiryIndex => expiryDays.indexOf(settings['expiry_days'] ?? 30);
  int get voidReasonIndex => voidReasons.indexOf(voidReason);
  void selectExpiry(int index) {
    if (busy) return;
    settings['expiry_days'] = expiryDays[index];
    changed();
  }

  void selectVoidReason(int index) {
    if (busy) return;
    voidReason = voidReasons[index];
    changed();
  }

  String get actionKey => 'inventory-management-${identityHashCode(this)}';
  Future<void> _perform(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    if (busy || disposed) return;
    await runBusy(actionKey, () async {
      busy = true;
      notifyListeners();
      try {
        await action();
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      } finally {
        busy = false;
        if (!disposed) notifyListeners();
      }
    });
  }

  void selectDocumentTab(int index) {
    tab = index;
    status = 0;
    notifyListeners();
  }

  void selectDocumentStatus(int index) {
    status = index;
    notifyListeners();
  }

  void openDocument(BuildContext context, Map<String, dynamic> row) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => row['status'] == 'draft'
            ? InventoryLivePage(mode: '${row['kind']}', draft: row)
            : InventoryManagementPage(mode: 'document', documentId: row['id']),
      ),
    );
  }

  void openVoid(BuildContext context) {
    if (busy || document['status'] == 'void') return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ListenableBuilder(
        listenable: this,
        builder: (_, _) => StockVoidBoundTemplate(c: this),
      ),
    );
  }

  Future<void> confirmVoid(BuildContext context) => _perform(context, () async {
    if (document['can_void'] != true) throw const AppError('当前单据无法作废');
    await request.send({
      'action': 'inventory_void',
      'payload': {'id': documentId, 'reason': voidReason},
    });
    dirty = false;
    inventoryChanged.value++;
    if (context.mounted && !disposed) Navigator.pop(context);
    await reload?.call();
  });
  Future<void> addCategory(BuildContext context) =>
      _perform(context, () => categoryEdit(context, null));
  Future<void> saveSettings(BuildContext context) =>
      _perform(context, () async {
        await request.send({
          'action': 'inventory_settings_save',
          'payload': settings,
        });
        dirty = false;
        inventoryChanged.value++;
        if (context.mounted && !disposed) Navigator.pop(context);
      });
  void replenishShortage(BuildContext context) {
    final line = shortageLine;
    final nav = Navigator.of(context);
    nav.pop();
    if (line != null) {
      nav.push(
        MaterialPageRoute(
          builder: (_) => InventoryLivePage(mode: 'in', productId: line['id']),
        ),
      );
    }
  }

  Future<void> enterBarcode(BuildContext context) => _perform(
    context,
    () async {
      await scanner.stop();
      if (!context.mounted || disposed) return;
      final value = await inputDialog(context, '商品编码', '请输入条码 / SKU', lastCode);
      if (value != null && value.isNotEmpty && context.mounted && !disposed) {
        await lookup(context, value);
      }
      if (context.mounted && !disposed) await scanner.start();
    },
  );
  Future<void> createScannedProduct(BuildContext context) =>
      _perform(context, () async {
        final p = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (_) => ProductEditLivePage(initialCode: lastCode),
          ),
        );
        if (p != null && context.mounted && !disposed) Navigator.pop(context);
      });
  Future<void> openScannedProduct(
    BuildContext context, {
    required bool replenish,
  }) => _perform(context, () async {
    if (replenish && scanProduct['active'] == false) {
      throw const AppError('商品已停用，请先启用');
    }
    final nav = Navigator.of(context);
    nav.pop();
    if (returnProduct) {
      nav.pop(scanProduct);
    } else {
      unawaited(
        nav.push(
          MaterialPageRoute(
            builder: (_) => InventoryLivePage(
              mode: replenish ? 'in' : 'detail',
              productId: scanProduct['id'],
            ),
          ),
        ),
      );
    }
  });

  void setAlert(BuildContext context, String field, bool value) {
    if (busy) return;
    if (field == 'message_enabled' || field == 'wechat_enabled') {
      // TODO: 缺少真实消息/微信通知渠道；预期接口 inventory_settings_save 配套渠道适配。
      AppToast.show(context, '消息通知渠道尚未接通，请使用首页提醒');
      return;
    }
    settings[field] = value;
    changed();
  }

  Widget categoryRows(BuildContext context) => Column(
    children: [
      for (final row in categories)
        InventoryCategoryRowTemplate(c: this, row: row),
    ],
  );
  Widget categoryAction(
    BuildContext context,
    Map<String, dynamic> row,
    Widget child,
  ) => GestureDetector(
    onTap: () => _perform(context, () => categoryEdit(context, row)),
    onLongPress: () => _perform(context, () async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('删除分类「${row['name']}」？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await request.send({
          'action': 'inventory_category_delete',
          'payload': {'id': row['id']},
        });
        inventoryChanged.value++;
        await reload?.call();
      }
    }),
    child: child,
  );
  Future<void> categoryEdit(
    BuildContext context,
    Map<String, dynamic>? row,
  ) async {
    final name = await inputDialog(
      context,
      row == null ? '新增分类' : '重命名分类',
      '请输入分类名称',
      '${row?['name'] ?? ''}',
    );
    if (name == null || name.isEmpty) return;
    await request.send({
      'action': 'inventory_category_save',
      'payload': {
        'id': row?['id'] ?? categoryIds.putIfAbsent(name, inventoryId),
        'name': name,
        'previous_name': row?['name'],
      },
    });
    inventoryChanged.value++;
    await reload?.call();
  }

  String documentDay(Map<String, dynamic> d) =>
      (DateTime.tryParse('${d['created_at']}')?.toLocal().toIso8601String() ??
              '${d['created_at']}')
          .split('T')
          .first;
  Widget documentRows(BuildContext context) {
    final visible = documents
        .where(
          (d) =>
              d['kind'] == ['in', 'out'][tab] &&
              (status == 0 ||
                  d['status'] == ['', 'draft', 'posted', 'void'][status]),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: EmptyView.firstTime(title: '当前筛选下还没有单据'),
          ),
        for (final day in {for (final d in visible) documentDay(d)}) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(dateLabel(day), style: ts(12, color: C.muted)),
          ),
          Container(
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: softShadow,
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final d in visible.where((d) => documentDay(d) == day))
                  _documentRow(context, d),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _documentRow(BuildContext context, Map<String, dynamic> d) =>
      GestureDetector(
        onLongPress: () => _perform(context, () async {
          final result = await merchantApi.invoke({
            'action': 'inventory_document_get',
            'id': d['id'],
          });
          if (!context.mounted || disposed) return;
          final controller =
              InventoryManagementController('document', documentId: d['id'])
                ..apply(result)
                ..reload = reload;
          try {
            await showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => ListenableBuilder(
                listenable: controller,
                builder: (_, _) => StockVoidBoundTemplate(c: controller),
              ),
            );
          } finally {
            controller.dispose();
          }
        }),
        child: InventoryDocumentRowTemplate(c: this, row: d),
      );

  Widget detailLines(BuildContext context) => Column(
    children: [
      for (final l in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: kind == 'in'
              ? StockInDetailLineBoundTemplate(c: this, row: l)
              : StockOutDetailLineBoundTemplate(c: this, row: l),
        ),
      if (mode == 'document') ...[
        if ('${document['payload']?['note'] ?? ''}'.isNotEmpty)
          Text('${document['payload']['note']}'),
        for (final path in List<String>.from(
          document['payload']?['attachments'] ?? [],
        ))
          TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => Dialog(
                child: SizedBox(
                  height: 400,
                  child: AsyncView<Map<String, dynamic>>(
                    load: () => merchantApi.invoke({
                      'action': 'expense_voucher',
                      'path': path,
                    }),
                    isEmpty: (_) => false,
                    skeleton: const SkeletonList(count: 2),
                    empty: (_) => const SizedBox.shrink(),
                    builder: (_, data) =>
                        Image.network(data['item']['signedUrl']),
                  ),
                ),
              ),
            ),
            child: const Text('查看附件'),
          ),
      ],
    ],
  );
  Future<void> lookup(BuildContext context, String value) async {
    lastCode = value;
    final r = await merchantApi.invoke({
      'action': 'inventory_lookup',
      'code': value,
    });
    if (!context.mounted || disposed) return;
    scanProduct = r['item'] == null ? {} : Map<String, dynamic>.from(r['item']);
    busy = false;
    notifyListeners();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => scanProduct.isEmpty
          ? ScanProductNotFoundBoundTemplate(c: this)
          : ScanProductResultBoundTemplate(c: this),
    );
  }

  Widget camera(BuildContext context) => MobileScanner(
    controller: scanner,
    onDetect: (capture) async {
      final code = capture.barcodes.firstOrNull?.rawValue;
      if (busy || code == null) return;
      busy = true;
      notifyListeners();
      try {
        await scanner.stop();
        if (context.mounted && !disposed) await lookup(context, code);
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      } finally {
        busy = false;
        if (!disposed) {
          notifyListeners();
          await scanner.start();
        }
      }
    },
    errorBuilder: (_, error) => ErrorView(
      error: const AppError('无法打开相机，请检查相机权限或手动输入编码'),
      onRetry: () => scanner.start(),
    ),
  );
}

Future<void> showStockShortage(
  BuildContext context,
  InventoryController inventory,
) async {
  final c = InventoryManagementController('shortage', count: inventory);
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StockOutShortBoundTemplate(c: c),
    );
  } finally {
    c.dispose();
  }
}
