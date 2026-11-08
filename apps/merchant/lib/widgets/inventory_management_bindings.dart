import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../theme.dart';
import '../pages/inventory_management_page.dart';
import '../pages/inventory_live_page.dart';
import '../pages/product_edit_live_page.dart';
import '../pages/inventory_management_row_templates.dart';
import '../pages/stock_void_bound_template.dart';
import '../pages/stock_out_short_bound_template.dart';
import '../pages/stock_check_input_bound_template.dart';
import '../pages/scan_product_result_bound_template.dart';
import '../pages/scan_product_not_found_bound_template.dart';
import 'inventory_bindings.dart';

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
  String get kind =>
      count?.mode ?? '${document['kind'] ?? ['in', 'out', 'check'][tab]}';
  List<Map<String, dynamic>> get lines =>
      count?.counted ?? maps(document['payload']?['lines']);
  List<Map<String, dynamic>> get snapshots =>
      count?.products ?? maps(document['payload']?['snapshots']);
  Map<String, dynamic> product(Map<String, dynamic> l) =>
      snapshots.where((p) => p['id'] == l['id']).firstOrNull ??
      {'name': '历史商品', 'unit': '', 'stock': 0, 'cost': 0};
  List<Map<String, dynamic>> get movements =>
      maps(document['movements'])
          .where((m) => m['payload']?['kind'] != 'void')
          .toList();
  num delta(Map<String, dynamic> l) => count != null
      ? count!.difference(l)
      : ((movements
                        .where((m) => m['product_id'] == l['id'])
                        .firstOrNull?['after_stock']
                    as num? ??
                l['quantity']) -
            (movements
                        .where((m) => m['product_id'] == l['id'])
                        .firstOrNull?['before_stock']
                    as num? ??
                product(l)['stock'] as num));
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
      '${{'in': 'RK', 'out': 'CK', 'check': 'PD'}[d['kind']]}-${'${d['id']}'.split('-').first}';
  String state(Map<String, dynamic> d) => switch (d['status']) {
    'draft' => '草稿',
    'void' => '已作废',
    _ =>
      d['kind'] == 'in'
          ? '已入库'
          : d['kind'] == 'out'
          ? '已出库'
          : '已盘点',
  };
  num amount(bool gain) => count != null
      ? (count!.quote?['lines'] as Map? ?? {}).entries
            .where((e) => gain ? (e.value as num) > 0 : (e.value as num) < 0)
            .fold<num>(0, (n, e) => n + (e.value as num))
      : movements
            .where(
              (m) => gain
                  ? m['after_stock'] > m['before_stock']
                  : m['after_stock'] < m['before_stock'],
            )
            .fold<num>(0, (n, m) => n + (gain ? 1 : -1) * (m['cost'] as num));
  String text(String v, {Map<String, dynamic>? row}) {
    if (row != null) {
      if (mode == 'categories') {
        return switch (v) {
          '贴膜' => '${row['name']}',
          '42 个商品' => '${row['count']} 个商品',
          _ => v,
        };
      }
      if (mode == 'docs') {
        if (v.startsWith('RK-')) return code(row);
        if (v == '已入库') return state(row);
        if (v.startsWith('蓝盾膜业')) {
          return '${row['payload']?['supplier'] ?? row['payload']?['reason'] ?? ''} · ${maps(row['payload']?['lines']).length} 种商品';
        }
        if (v.startsWith('¥')) return money(row['total'] as num? ?? 0);
      }
      final p = product(row);
      final quantity = row['quantity'] as num? ?? 0;
      if (['隐形车衣 TPU 1.52m', '玻璃镀膜剂 500ml'].contains(v)) return '${p['name']}';
      if (v.startsWith('批次 B') || v.startsWith('FIFO ·')) {
        return kind == 'in'
            ? '单价 ${money(row['cost'] as num? ?? 0)} / ${p['unit']}'
            : '先进先出 · ${row['expires_on'] ?? '无保质期'}';
      }
      if (v.startsWith('×')) return '× ${qty(quantity)} ${p['unit']}';
      if (v.startsWith('系统 3')) {
        return '系统 ${qty(p['stock'] as num? ?? 0)} · 实盘 ${qty(quantity)}';
      }
      if (v == '+1 卷') {
        return '${delta(row) > 0 ? '+' : ''}${qty(delta(row))} ${p['unit']}';
      }
      return v;
    }
    if (mode == 'docs') return v == '已入库' ? ['已入库', '已出库', '已盘点'][tab] : v;
    if (mode == 'count-input') {
      final p = count!.product(activeLine!);
      if (v == '隐形车衣 TPU 1.52m') return '${p['name']}';
      if (v == '卷') return '${p['unit']}';
      if (v.startsWith('系统库存：')) {
        return count!.payload['blind'] == true
            ? '盲盘 · 已录入 ${qty(pendingQuantity ?? 0)} ${p['unit']}'
            : '系统库存：${qty(p['stock'])} ${p['unit']} · 盈亏 ${qty((pendingQuantity ?? 0) - (p['stock'] as num))}';
      }
      return v;
    }
    if (mode == 'shortage') {
      final line = count!.lines
          .where(
            (l) => (l['quantity'] as num) > (count!.product(l)['stock'] as num),
          )
          .firstOrNull;
      if (line == null) return v;
      final p = count!.product(line);
      if (v == '隐形车衣 TPU 1.52m') return '${p['name']}';
      if (v == '需要 3 卷') return '需要 ${qty(line['quantity'])} ${p['unit']}';
      if (v == '2 卷') return '${qty(p['stock'])} ${p['unit']}';
      if (v == '1 卷') {
        return '${qty((line['quantity'] as num) - (p['stock'] as num))} ${p['unit']}';
      }
      return v;
    }
    if (mode == 'scan') {
      if (v.startsWith('没有找到条码')) return '没有找到条码 $lastCode 对应的商品';
      if (v.startsWith('SKU ')) {
        return 'SKU ${scanProduct['sku']} · ${scanProduct['location'] ?? ''}';
      }
      if (v == '低库存') {
        return (scanProduct['stock'] as num? ?? 0) <
                (scanProduct['safe'] as num? ?? 0)
            ? '低库存'
            : scanProduct['active'] == false
            ? '已停用'
            : '库存充足';
      }
      if (v.startsWith('690') || v.startsWith('条码')) return lastCode;
      if (v.contains('隐形车衣') || v.contains('TPU')) {
        return '${scanProduct['name'] ?? ''}';
      }
      if ((v.contains('库存') && v != '查看商品详情') || v == '3 卷') {
        return '库存 ${qty(scanProduct['stock'] as num? ?? 0)} ${scanProduct['unit'] ?? ''}';
      }
      if (v.contains('¥')) return money(scanProduct['cost'] as num? ?? 0);
      if (v.contains('贴膜')) return '${scanProduct['category'] ?? ''}';
      return v;
    }
    if (mode == 'new') {
      if (v == '按分类') {
        return scope == 1 && scopeValue != null ? '$scopeValue' : '按分类';
      }
      if (v == '按货位') {
        return scope == 2 && scopeValue != null ? '$scopeValue' : '按货位';
      }
      if (v.startsWith('共 248')) {
        return '共 ${selectedProducts.length} 项商品，预计盘点 ${(selectedProducts.length / 8).ceil()} 分钟';
      }
    }
    if (v.startsWith('RK-') || v.startsWith('CK-') || v.startsWith('PD-')) {
      return '${count == null ? code(document) : 'PD-${count!.id.split('-').first}'}${v.contains('结果') ? ' · 盘点结果' : ''}';
    }
    if (v == '已入库' || v == '已出库') return state(document);
    if (v.startsWith('今天 ')) {
      return '${document['posted_at'] ?? document['created_at'] ?? ''}';
    }
    if (v == '蓝盾膜业') return '${document['payload']?['supplier'] ?? ''}';
    if (v == '转账') return '${document['payload']?['payment'] ?? ''}';
    if (v == '施工领用') return '${document['payload']?['reason'] ?? ''}';
    if (v == '20261103-0412') {
      return '${document['payload']?['workorder'] ?? '未关联'}';
    }
    if (v == '陈明') return '${document['payload']?['technician'] ?? '店主'}';
    if (v.startsWith('是 ·')) {
      return document['expense'] != null &&
              document['expense']['deleted'] != true
          ? '是 · ${money(document['expense']['amount'])}'
          : '否';
    }
    if (v == '¥3,840.00' || v == '¥146.00') {
      return money(document['total'] as num? ?? 0);
    }
    if (v.startsWith('入库商品 ·') || v.startsWith('出库商品 ·')) {
      return '${kind == 'in' ? '入库' : '出库'}商品 · ${lines.length} 项';
    }
    if (v == '12 项已盘') return '${lines.length} 项已盘';
    if (v == '+3 项') return '+${lines.where((l) => delta(l) > 0).length} 项';
    if (v == '-2 项') return '-${lines.where((l) => delta(l) < 0).length} 项';
    if (count != null &&
        count!.quote == null &&
        ['+¥1,286', '-¥96', '+¥1,190'].contains(v)) {
      return '—';
    }
    if (v == '+¥1,286') return money(amount(true));
    if (v == '-¥96') return money(amount(false));
    if (v == '+¥1,190') return money(amount(true) + amount(false));
    if (v == '作废入库单') {
      return '作废${kind == 'in'
          ? '入库'
          : kind == 'out'
          ? '出库'
          : '盘点'}单';
    }
    if (v.startsWith('作废后，该入库单')) {
      return '作废后恢复该单据之前的库存批次，并撤销关联开支 ${money(document['expense']?['amount'] as num? ?? 0)}。';
    }
    if (v.startsWith('隐形车衣 TPU 已有')) {
      return document['can_void'] == true
          ? '当前单据可作废；作废记录永久保留。'
          : '单据已有后续库存变动或缺少撤销记录，无法作废。';
    }
    if (v == '确认作废' && document['can_void'] != true) return '无法作废';
    if (v == '作废此单' && document['status'] == 'void') return '已作废';
    if (v == '确认提交' && mode == 'document') return state(document);
    return v;
  }

  Widget countField(Widget child, {bool quantity = false}) => TextFormField(
    key: ValueKey('${activeLine?['id']}-$quantity'),
    initialValue: quantity
        ? (pendingQuantity == null ? '' : qty(pendingQuantity!))
        : pendingNote,
    style: child is Text ? child.style : null,
    keyboardType: quantity
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(
      border: InputBorder.none,
      isDense: true,
      hintText: quantity ? '请输入实盘数量' : '如：有 1 卷未拆封',
    ),
    onChanged: (v) {
      if (quantity) {
        pendingQuantity = num.tryParse(v);
      } else {
        pendingNote = v;
      }
      notifyListeners();
    },
  );
  Color choiceBg(String label) {
    final tabs = ['入库单', '出库单', '盘点单'];
    final states = ['全部', '草稿', '已入库', '已作废'];
    return (tabs.contains(label)
            ? tabs.indexOf(label) == tab
            : states.indexOf(label) == status)
        ? C.primarySoft
        : C.chip;
  }

  Widget busyLabel(Widget child) => hBusy(
    'inventory-management',
    child,
    style: child is Text ? child.style : null,
  );
  Widget tap(
    BuildContext context,
    Widget child, {
    String? to,
    bool back = false,
    String? intent,
    Map<String, dynamic>? row,
    VoidCallback? onTap,
    String? label,
  }) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: busy
        ? null
        : () {
            if (back || intent == '再想想' || intent == '返回修改') {
              Navigator.maybePop(context);
              return;
            }
            if (mode == 'document' && to == 'StockVoid') {
              if (document['status'] != 'void') {
                unawaited(
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => ListenableBuilder(
                      listenable: this,
                      builder: (_, _) => StockVoidBoundTemplate(c: this),
                    ),
                  ),
                );
              }
              return;
            }
            if (mode == 'docs') {
              if (row != null) {
                unawaited(
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => row['status'] == 'draft'
                          ? InventoryLivePage(
                              mode: '${row['kind']}',
                              draft: row,
                            )
                          : InventoryManagementPage(
                              mode: 'document',
                              documentId: row['id'],
                            ),
                    ),
                  ),
                );
              } else {
                if (['入库单', '出库单', '盘点单'].contains(intent)) {
                  tab = ['入库单', '出库单', '盘点单'].indexOf(intent!);
                  status = 0;
                } else {
                  status = [
                    '全部',
                    '草稿',
                    '已入库',
                    '已作废',
                  ].indexOf(intent ?? '').clamp(0, 3);
                }
                notifyListeners();
              }
              return;
            }
            unawaited(
              runBusy('inventory-management', () async {
                busy = true;
                notifyListeners();
                try {
                  if (back || intent == '再想想' || intent == '返回修改') {
                    Navigator.maybePop(context);
                    return;
                  }
                  if (mode == 'count-input') {
                    if (intent == '确认并下一项') {
                      if (pendingQuantity == null || pendingQuantity! < 0) {
                        throw const AppError('请输入有效的实盘数量');
                      }
                      activeLine!['quantity'] = pendingQuantity;
                      activeLine!['note'] = pendingNote;
                      count!.changed();
                    }
                    final index = count!.lines.indexOf(activeLine!) + 1;
                    if (index >= count!.lines.length) {
                      Navigator.pop(context);
                      return;
                    }
                    activeLine = count!.lines[index];
                    pendingQuantity = activeLine!['quantity'] as num?;
                    pendingNote = '${activeLine!['note'] ?? ''}';
                    notifyListeners();
                    return;
                  }
                  if (mode == 'shortage') {
                    Navigator.pop(context);
                    if (to == 'StockIn' && context.mounted) {
                      final line = count!.lines
                          .where(
                            (l) =>
                                (l['quantity'] as num) >
                                (count!.product(l)['stock'] as num),
                          )
                          .first;
                      unawaited(
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryLivePage(
                              mode: 'in',
                              productId: line['id'],
                            ),
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (mode == 'categories') {
                    await categoryEdit(context, null);
                    return;
                  }
                  if (mode == 'settings') {
                    await request.send({
                      'action': 'inventory_settings_save',
                      'payload': settings,
                    });
                    dirty = false;
                    inventoryChanged.value++;
                    if (context.mounted) Navigator.pop(context);
                    return;
                  }
                  if (mode == 'new') {
                    await beginCount(context);
                    return;
                  }
                  if (mode == 'result') {
                    await count!.save(context, true, fromPreview: true);
                    return;
                  }
                  if (mode == 'document') {
                    if (to == 'StockVoid' && document['status'] != 'void') {
                      busy = false;
                      notifyListeners();
                      unawaited(
                        showModalBottomSheet<void>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ListenableBuilder(
                            listenable: this,
                            builder: (_, _) => StockVoidBoundTemplate(c: this),
                          ),
                        ),
                      );
                    } else if (intent == '确认作废' &&
                        document['can_void'] == true) {
                      await request.send({
                        'action': 'inventory_void',
                        'payload': {'id': documentId, 'reason': voidReason},
                      });
                      dirty = false;
                      inventoryChanged.value++;
                      if (context.mounted) Navigator.pop(context);
                      await reload?.call();
                    }
                    return;
                  }
                  if (mode == 'scan') {
                    if (intent == '手动输入编码') {
                      await scanner.stop();
                      if (!context.mounted) return;
                      final value = await inputDialog(
                        context,
                        '商品编码',
                        '请输入条码 / SKU',
                        lastCode,
                      );
                      if (value != null &&
                          value.isNotEmpty &&
                          context.mounted) {
                        await lookup(context, value);
                      }
                      if (context.mounted) await scanner.start();
                      return;
                    }
                    if (to == 'ScanProduct') {
                      Navigator.pop(context);
                      return;
                    }
                    if (to == 'ProductEdit') {
                      final p = await Navigator.push<Map<String, dynamic>>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductEditLivePage(initialCode: lastCode),
                        ),
                      );
                      if (p != null && context.mounted) Navigator.pop(context);
                      return;
                    }
                    if (to == 'StockIn') {
                      Navigator.pop(context);
                      if (scanProduct['active'] == false) {
                        throw const AppError('商品已停用，请先启用');
                      }
                      if (returnProduct) {
                        if (context.mounted) {
                          Navigator.pop(context, scanProduct);
                        }
                      } else if (context.mounted) {
                        unawaited(
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InventoryLivePage(
                                mode: 'in',
                                productId: scanProduct['id'],
                              ),
                            ),
                          ),
                        );
                      }
                      return;
                    }
                    if (to == 'ProductDetail') {
                      Navigator.pop(context);
                      if (!context.mounted) return;
                      if (returnProduct) {
                        Navigator.pop(context, scanProduct);
                      } else {
                        unawaited(
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InventoryLivePage(
                                mode: 'detail',
                                productId: scanProduct['id'],
                              ),
                            ),
                          ),
                        );
                      }
                      return;
                    }
                  }
                  onTap?.call();
                } finally {
                  busy = false;
                  if (!disposed) notifyListeners();
                }
              }),
            );
          },
    child: child,
  );
  List<Map<String, dynamic>> get selectedProducts => products
      .where(
        (p) =>
            scope == 0 ||
            (scope == 1
                ? p['category'] == scopeValue
                : p['location'] == scopeValue),
      )
      .toList();
  Future<void> selectScope(BuildContext context, int i) async {
    scope = i;
    scopeValue = null;
    if (i != 0) {
      final values = {
        for (final p in products)
          '${p[i == 1 ? 'category' : 'location'] ?? ''}',
      }..remove('');
      final value = await showModalBottomSheet<String>(
        context: context,
        builder: (ctx) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              if (values.isEmpty) const ListTile(title: Text('还没有可选范围')),
              for (final v in values)
                ListTile(title: Text(v), onTap: () => Navigator.pop(ctx, v)),
            ],
          ),
        ),
      );
      if (disposed) return;
      if (value == null) {
        scope = 0;
      } else {
        scopeValue = value;
      }
    }
    selectionEpoch++;
    changed();
  }

  Future<void> beginCount(BuildContext context) async {
    final existing = (await merchantApi.invoke({
      'action': 'inventory_draft',
      'kind': 'check',
    }))['item'];
    if (!context.mounted) return;
    if (existing != null) {
      unawaited(
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryLivePage(
              mode: 'check',
              draft: Map<String, dynamic>.from(existing),
            ),
          ),
        ),
      );
      return;
    }
    if (selectedProducts.isEmpty) throw const AppError('所选范围没有启用商品');
    final p = {
      'lines': <Map<String, dynamic>>[],
      'product_ids': selectedProducts.map((p) => p['id']).toList(),
      'blind': blind,
      'freeze': freeze,
      'scope': scopeValue ?? '全部商品',
      'date': DateTime.now().toIso8601String().substring(0, 10),
    };
    final r = await request.send({
      'action': 'inventory_document',
      'id': countId,
      'kind': 'check',
      'revision': 0,
      'post': false,
      'payload': p,
    });
    dirty = false;
    if (context.mounted) {
      unawaited(
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => InventoryLivePage(
              mode: 'check',
              draft: Map<String, dynamic>.from(r['item']),
            ),
          ),
        ),
      );
    }
  }

  Widget toggle(BuildContext context, int i) {
    if (mode == 'new') {
      return HSwitchValue(
        value: i == 0 ? blind : freeze,
        onChanged: (_) {
          if (i == 0) {
            blind = !blind;
          } else {
            freeze = !freeze;
          }
          changed();
        },
      );
    }
    final field = [
      'low_enabled',
      'expiry_enabled',
      'home_enabled',
      'message_enabled',
      'wechat_enabled',
    ][i];
    return HSwitchValue(
      value: settings[field] == true,
      onChanged: (_) {
        if (i >= 3) {
          AppToast.show(context, '消息通知渠道尚未接通，请使用首页提醒');
          return;
        }
        settings[field] = settings[field] != true;
        changed();
      },
    );
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
    onTap: () =>
        runBusy('inventory-management', () => categoryEdit(context, row)),
    onLongPress: () => runBusy('inventory-management', () async {
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
              d['kind'] == ['in', 'out', 'check'][tab] &&
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
        onLongPress: () => runBusy('inventory-void-open', () async {
          final result = await merchantApi.invoke({
            'action': 'inventory_document_get',
            'id': d['id'],
          });
          if (!context.mounted) return;
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
              : kind == 'out'
              ? StockOutDetailLineBoundTemplate(c: this, row: l)
              : StockCheckResultLineBoundTemplate(c: this, row: l),
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
    if (!context.mounted) return;
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
        if (context.mounted) await lookup(context, code);
      } catch (e) {
        if (context.mounted) AppToast.error(context, e);
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

class InventoryManagementSelections extends StatelessWidget {
  final InventoryManagementController c;
  final List<(Set<int>, bool)> groups;
  final Widget Function(BuildContext, List<SelCtrl>) builder;
  const InventoryManagementSelections({
    super.key,
    required this.c,
    required this.groups,
    required this.builder,
  });
  @override
  Widget build(BuildContext context) => HSelHolder(
    key: ValueKey(
      '${c.selectionEpoch}-${c.settings['expiry_days']}-${c.voidReason}',
    ),
    groups: [
      (
        {
          c.mode == 'settings'
              ? [7, 15, 30, 60].indexOf(c.settings['expiry_days'] ?? 30)
              : c.mode == 'new'
              ? c.scope
              : ['录错数量', '录错商品', '供应商退货', '其他'].indexOf(c.voidReason),
        },
        false,
      ),
    ],
    onSelect: {
      0: (i) {
        if (c.mode == 'settings') {
          c.settings['expiry_days'] = [7, 15, 30, 60][i];
          c.changed();
        } else if (c.mode == 'new') {
          unawaited(c.selectScope(context, i));
        } else {
          c.voidReason = ['录错数量', '录错商品', '供应商退货', '其他'][i];
          c.changed();
        }
      },
    },
    builder: builder,
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

Future<void> showInventoryCountInput(
  BuildContext context,
  InventoryController inventory,
  Map<String, dynamic> line,
) async {
  final c = InventoryManagementController('count-input', count: inventory)
    ..activeLine = line
    ..pendingQuantity = (line['quantity'] as num?)
    ..pendingNote = '${line['note'] ?? ''}';
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ListenableBuilder(
          listenable: c,
          builder: (_, _) => StockCheckInputBoundTemplate(c: c),
        ),
      ),
    );
  } finally {
    c.dispose();
  }
}
