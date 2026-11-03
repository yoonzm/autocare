import '../pages/inventory_record_templates.dart';

import 'package:flutter/material.dart';

import 'dart:async';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../theme.dart';
import '../pages/inventory_live_page.dart';
import '../pages/stock_in_line_template.dart';
import '../pages/stock_out_line_template.dart';
import '../pages/stock_check_line_template.dart';

final inventoryChanged = ValueNotifier(0);
String inventoryId() {
  final s = MerchantApi.newRequestId();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

String qty(num n) => n.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
String money(num n) => '¥${n.toStringAsFixed(2)}';
List<Map<String, dynamic>> maps(dynamic v) =>
    (v as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();

class InventoryController extends ChangeNotifier {
  final String mode;
  final List<Map<String, dynamic>> products;
  final Map<String, dynamic> detail;
  late String id;
  int revision = 0, filter = 0;
  bool busy = false, dirty = false, disposed = false;
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
    if (mode == 'detail' || !merchantApi.hasSession) return;
    quote = null;
    quoteError = null;
    _quoting = false;
    _quoteVersion++;
    _quoteTimer?.cancel();
    _quoteTimer = Timer(const Duration(milliseconds: 300), refreshQuote);
  }

  Future<void> refreshQuote() async {
    final version = _quoteVersion;
    _quoting = true;
    if (!disposed) notifyListeners();
    try {
      final request = merchantApi.invoke({
        'action': 'inventory_quote',
        'kind': mode,
        'payload': {...payload, 'lines': mode == 'check' ? counted : lines},
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
    this.products,
    this.detail,
    Map<String, dynamic>? draft,
    String? selected,
  ) {
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
    if (draft != null && mode == 'check') {
      for (final p in products) {
        if (!lines.any((l) => l['id'] == p['id'])) {
          lines.add({'id': p['id'], 'quantity': null, 'version': p['version']});
        }
      }
    }
    if (draft == null && mode == 'check') {
      lines = products
          .map(
            (p) => {'id': p['id'], 'quantity': null, 'version': p['version']},
          )
          .toList();
    } else if (selected != null &&
        mode != 'detail' &&
        mode != 'check' &&
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
  List<Map<String, dynamic>> get counted =>
      lines.where((l) => l['quantity'] != null).toList();
  num difference(Map<String, dynamic> l) =>
      (l['quantity'] as num? ?? product(l)['stock'] as num) -
      (product(l)['stock'] as num);
  String initial(String sample) => switch (sample) {
    '蓝盾膜业' =>
      '${mode == 'detail' ? detail['supplier'] : payload['supplier']}'.isEmpty
          ? '请输入供应商'
          : '${mode == 'detail' ? detail['supplier'] : payload['supplier']}',
    '今天 10.31' => '${payload['date']}',
    '¥120.00' => money(payload['freight'] as num? ?? 0),
    '沪A·8K29M 镀晶养护' => '${payload['workorder'] ?? '未关联'}',
    '老周' => '${payload['technician'] ?? '未指定'}',
    _ => '',
  };
  String text(String v) {
    final p = detail;
    final unit = '${p['unit'] ?? ''}';
    final movements = maps(p['movements']);
    final now = DateTime.now();
    final used = movements
        .where(
          (m) =>
              '${m['created_at']}'.startsWith(
                '${now.year}-${now.month.toString().padLeft(2, '0')}',
              ) &&
              (m['after_stock'] as num) < (m['before_stock'] as num),
        )
        .fold<num>(
          0,
          (n, m) => n + (m['before_stock'] as num) - (m['after_stock'] as num),
        );
    final values = <String, String>{
      'RK-20261031-03': 'RK-${id.substring(0, 8)}',
      '¥15,960.00': quoted('subtotal'),
      '¥16,080.00': quoted('total'),
      '材料采购 · ¥16,080.00': '材料采购 · ${quoted('total')}',
      '应付 · 16 件商品': '应付 · ${lines.length} 项商品',
      '¥1,358.00': quoted('subtotal'),
      '将计入该工单的成本核算': '记录本次出库成本',
      '盘点单 PD-1031 · 全部仓库': '盘点单 PD-${id.substring(0, 8)} · 全部仓库',
      '12': '${counted.length}',
      '/ 248 已盘点': '/ ${lines.length} 已盘点',
      '1 项 · +4':
          '${counted.where((l) => difference(l) > 0).length} 项 · +${qty(counted.where((l) => difference(l) > 0).fold<num>(0, (n, l) => n + difference(l)))}',
      '2 项 · −3':
          '${counted.where((l) => difference(l) < 0).length} 项 · ${qty(counted.where((l) => difference(l) < 0).fold<num>(0, (n, l) => n + difference(l)))}',
      '−¥392': quoted('subtotal'),
      '提交盘点（已盘 12 项）': '提交盘点（已盘 ${counted.length} 项）',
      '提交后将生成盘盈 / 盘亏调整单，盘亏成本 ¥392 自动计入"损耗"开支。': '提交后将生成盘盈 / 盘亏调整单并记录差异成本。',
      'TPU 隐形车衣 7.5mil': '${p['name'] ?? ''}',
      'SKU TPU-75-152 · 贴膜': 'SKU ${p['sku'] ?? ''} · ${p['category'] ?? ''}',
      '2': qty(p['stock'] as num? ?? 0),
      '卷': unit,
      '安全库存 5 卷': '安全库存 ${qty(p['safe'] as num? ?? 0)} $unit',
      '低于安全库存': (p['stock'] as num? ?? 0) < (p['safe'] as num? ?? 0)
          ? '低于安全库存'
          : '库存充足',
      '4.2 卷': '${qty(used)} $unit',
      '约 9 天': used == 0
          ? '—'
          : '约 ${((p['stock'] as num? ?? 0) * now.day / used).floor()} 天',
      '6 卷':
          '${qty(((p['safe'] as num? ?? 0) * 2 - (p['stock'] as num? ?? 0)).clamp(0, 999999999))} $unit',
      '1.52m × 15m / 卷': '${p['specification'] ?? ''}',
      '¥2,380.00 / 卷': '${money(p['cost'] as num? ?? 0)} / $unit',
      '¥4,760.00': money(
        maps(p['batches']).fold<num>(
          0,
          (n, b) => n + (b['quantity'] as num) * (b['cost'] as num),
        ),
      ),
      'A-02 · 贴膜架': '${p['location'] ?? ''}',
    };
    return values[v] ?? v;
  }

  Future<void> save(BuildContext context, bool post) async {
    if (busy) return;
    busy = true;
    notifyListeners();
    try {
      final result = await merchantApi.invoke({
        'action': 'inventory_document',
        'id': id,
        'kind': mode,
        'revision': revision,
        'post': post,
        'payload': {...payload, 'lines': mode == 'check' ? counted : lines},
      });
      revision = (result['item'] as Map)['revision'] as int;
      dirty = false;
      busy = false;
      if (!disposed) notifyListeners();
      await WidgetsBinding.instance.endOfFrame;
      inventoryChanged.value++;
      if (context.mounted) {
        AppToast.show(context, post ? '已提交' : '草稿已保存');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mode == 'check' && e.toString().contains('库存已变化')) {
        try {
          final latest = maps(
            (await merchantApi.invoke({'action': 'inventory_list'}))['items'],
          );
          for (final l in lines) {
            final p = latest.where((p) => p['id'] == l['id']).firstOrNull;
            if (p != null && p['version'] != l['version']) {
              l['version'] = p['version'];
              l['quantity'] = null;
            }
          }
          products
            ..clear()
            ..addAll(latest);
          scheduleQuote();
        } catch (_) {
          /* Keep the draft and original conflict for retry. */
        }
      }
      if (context.mounted) AppToast.error(context, e);
    } finally {
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
    'Inventory-$mode-$kind',
    child,
    style: child is Text ? child.style : null,
    label: kind == 'submit' ? '提交中…' : null,
  );
  Widget tap(
    BuildContext context,
    Widget child, {
    String? to,
    bool back = false,
    VoidCallback? onTap,
    String? label,
    String? action,
  }) {
    final submit =
        action != null && (action.startsWith('确认') || action == '提交盘点');
    final draft = action == '草稿' || action == '暂存';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy
          ? null
          : () {
              if (submit || draft) {
                runBusy(
                  'Inventory-$mode-${submit ? 'submit' : 'draft'}',
                  () => save(context, submit),
                );
                return;
              }
              if (back || action == '取消') {
                Navigator.of(context).maybePop();
                return;
              }
              if (label == '添加商品' || action == '添加商品') {
                add(context);
                return;
              }
              if (label == '扫码添加' || action == '扫码添加') {
                AppToast.show(context, '扫码设备尚未接入，请手动添加商品');
                return;
              }
              if (mode == 'detail' && to != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InventoryLivePage(
                      mode: to == 'StockOut'
                          ? 'out'
                          : to == 'StockIn'
                          ? 'in'
                          : 'check',
                      productId: detail['id'],
                    ),
                  ),
                );
                return;
              }
              onTap?.call();
            },
      child: child,
    );
  }

  Future<void> pick(
    BuildContext context,
    String key,
    String label,
    StrCtrl ctrl,
  ) async {
    if (key == 'workorder' || key == 'tech') {
      // TODO: stock document foreign keys require order material consumption and staff authorization contracts.
      AppToast.show(context, '工单成本关联与技师领料授权尚未接通');
      return;
    }
    if (mode == 'detail') {
      final updated = await editProduct(context, detail);
      if (updated != null) ctrl.set('${updated['supplier']}');
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
        ctrl.set('${payload['date']}');
        changed();
      }
      return;
    }
    final field = key == 'amount' ? 'freight' : 'supplier';
    final v = await inputDialog(
      context,
      label,
      '请输入$label',
      '${payload[field] ?? ''}',
      numeric: key == 'amount',
    );
    if (v != null) {
      final value = key == 'amount' ? num.tryParse(v) : v;
      if (value == null) return;
      payload[field] = value;
      ctrl.set(key == 'amount' ? money(value as num) : v);
      changed();
    }
  }

  Widget expenseSwitch(BuildContext context) => HSwitchValue(
    value: false,
    onChanged: (_) {
      // TODO: expense_create is outside inventory. A disabled integration must never report success.
      AppToast.show(context, '开支模块尚未接通，本次只记录库存单据');
    },
  );
  Future<void> add(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .65,
          child: Column(
            children: [
              ListTile(
                title: const Text('添加商品'),
                trailing: TextButton(
                  onPressed: () async {
                    final p = await editProduct(ctx, null);
                    if (p != null && ctx.mounted) Navigator.pop(ctx, p);
                  },
                  child: const Text('新增商品'),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final p in products.where(
                      (p) => !lines.any((l) => l['id'] == p['id']),
                    ))
                      ListTile(
                        title: Text('${p['name']}'),
                        subtitle: Text('${p['stock']} ${p['unit']}'),
                        onTap: () => Navigator.pop(ctx, p),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result != null) {
      if (!products.any((p) => p['id'] == result['id'])) products.add(result);
      lines.add({
        'id': result['id'],
        'quantity': 1,
        'cost': result['cost'],
        'version': result['version'],
      });
      changed();
    }
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

  Color checkBackground(Map<String, dynamic> line) => line['quantity'] == null
      ? C.chip
      : difference(line) < 0
      ? C.redSoft
      : C.greenSoft;
  Color checkInk(Map<String, dynamic> line) => line['quantity'] == null
      ? C.muted
      : difference(line) < 0
      ? C.redInk
      : C.greenInk;

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

  String lineText(Map<String, dynamic> l, String v) {
    final p = product(l);
    return switch (v) {
      'TPU 隐形车衣 7.5mil' => '${p['name']}',
      '当前库存 2 卷 · 低于安全库存' =>
        '当前库存 ${qty(p['stock'])} ${p['unit']}${p['stock'] < p['safe'] ? ' · 低于安全库存' : ''}',
      '单价 ¥2,380.00 / 卷' => '单价 ${money(l['cost'])} / ${p['unit']}',
      '批次 自动生成 · 无保质期' => '批次 自动生成 · ${l['expires_on'] ?? '无保质期'}',
      '¥14,280.00' => money((l['quantity'] as num? ?? 0) * (l['cost'] as num)),
      '出库后 1.5 卷，低于安全库存' =>
        '出库后 ${qty((p['stock'] as num) - (l['quantity'] as num? ?? 0))} ${p['unit']}',
      'A-02 · 系统 2 卷' =>
        '${p['location']} · 系统 ${qty(p['stock'])} ${p['unit']}',
      '一致' =>
        l['quantity'] == null
            ? '未盘'
            : difference(l) == 0
            ? '一致'
            : '${difference(l) > 0 ? '盘盈' : '盘亏'} ${qty(difference(l))}',
      _ => v,
    };
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

  Widget quantityWidget(BuildContext context, Map<String, dynamic> l) =>
      mode == 'check'
      ? TextFormField(
          key: ValueKey('${l['id']}-${l['version']}'),
          initialValue: l['quantity'] == null ? '' : qty(l['quantity']),
          textAlign: TextAlign.center,
          style: ts(16, w: FontWeight.w600),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            hintText: '—',
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (v) {
            l['quantity'] = num.tryParse(v);
            changed();
          },
        )
      : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (mode != 'check')
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
                  mode == 'check' ? '实盘数量' : '数量',
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
            if (mode != 'check')
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
      for (final l in lines.where(
        (l) =>
            mode != 'check' ||
            filter == 0 ||
            (filter == 1
                ? l['quantity'] == null
                : l['quantity'] != null && difference(l) != 0),
      ))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: switch (mode) {
            'in' => StockInLineTemplate(c: this, line: l),
            'out' => StockOutLineTemplate(c: this, line: l),
            _ => StockCheckLineTemplate(c: this, line: l),
          },
        ),
      if (mode != 'check')
        (mode == 'in'
            ? StockInAddTemplate(c: this)
            : StockOutAddTemplate(c: this)),
    ],
  );
  String batchText(Map<String, dynamic> r, String v) => switch (v) {
    '批次 B1008' => '批次 ${'${r['id']}'.substring(0, 8)}',
    '入库 2026.09.12' => '入库 ${r['received_on']} · ${r['expires_on'] ?? '无保质期'}',
    '剩 1 卷' => '剩 ${qty(r['quantity'])} ${detail['unit']}',
    _ => v,
  };
  String recordText(Map<String, dynamic> r, String v) {
    final payload = Map<String, dynamic>.from(r['payload']);
    if (['施工领用', '采购入库', '盘点调整'].contains(v)) {
      return payload['kind'] == 'out'
          ? '${payload['reason'] ?? '商品出库'}'
          : payload['kind'] == 'in'
          ? '采购入库'
          : '盘点调整';
    }
    if (v.startsWith('沪A') || v.startsWith('蓝盾') || v.startsWith('盘亏 ·')) {
      return '${payload['supplier'] ?? ''} ${payload['note'] ?? ''}'.trim();
    }
    if (v.startsWith('10.')) {
      final d = DateTime.tryParse('${r['created_at']}')?.toLocal();
      return d == null ? '' : d.toString().substring(0, 16);
    }
    if (v.endsWith(' 卷')) {
      final n = (r['after_stock'] as num) - (r['before_stock'] as num);
      return '${n > 0 ? '+' : ''}${qty(n)} ${detail['unit']}';
    }
    return v;
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
              filter == 0 ||
              m['payload']['kind'] == ['', 'in', 'out', 'check'][filter],
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

Future<Map<String, dynamic>?> editProduct(
  BuildContext context,
  Map<String, dynamic>? original,
) => showModalBottomSheet<Map<String, dynamic>>(
  context: context,
  isScrollControlled: true,
  builder: (_) => InventoryProductEditor(original: original),
);

class InventoryProductEditor extends StatefulWidget {
  final Map<String, dynamic>? original;
  const InventoryProductEditor({super.key, this.original});
  @override
  State<InventoryProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<InventoryProductEditor> {
  late final Map<String, dynamic> fields = {
    'id': inventoryId(),
    'name': '',
    'unit': '',
    'category': '洗护',
    'safe': 0,
    'cost': 0,
    'sku': '',
    'specification': '',
    'location': '',
    'supplier': '',
    ...?widget.original,
  };
  bool busy = false;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.original == null ? '新增商品' : '商品资料',
              style: ts(18, w: FontWeight.w600),
            ),
            for (final e in {
              'name': '商品名称',
              'unit': '单位',
              'sku': 'SKU',
              'specification': '规格',
              'location': '货位',
              'supplier': '供应商',
              'safe': '安全库存',
              'cost': '成本单价',
            }.entries)
              if (e.key != 'cost' || widget.original == null)
                TextFormField(
                  enabled: !busy,
                  initialValue: '${fields[e.key]}',
                  decoration: InputDecoration(
                    labelText: e.value,
                    hintText: '请输入${e.value}',
                  ),
                  keyboardType: ['safe', 'cost'].contains(e.key)
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  onChanged: (v) => fields[e.key] =
                      ['safe', 'cost'].contains(e.key) ? num.tryParse(v) : v,
                ),
            DropdownButtonFormField<String>(
              initialValue: fields['category'] as String,
              items: [
                for (final v in ['洗护', '镀晶', '贴膜', '配件'])
                  DropdownMenuItem(value: v, child: Text(v)),
              ],
              onChanged: busy ? null : (v) => fields['category'] = v,
            ),
            const SizedBox(height: 16),
            LoadingButton(
              label: '保存',
              onPressed: () async {
                setState(() => busy = true);
                try {
                  final r = await merchantApi.invoke({
                    ...fields,
                    'action': widget.original == null
                        ? 'inventory_create'
                        : 'inventory_update',
                  });
                  inventoryChanged.value++;
                  if (context.mounted) {
                    Navigator.pop(
                      context,
                      Map<String, dynamic>.from(r['item'] as Map),
                    );
                  }
                } finally {
                  if (mounted) setState(() => busy = false);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class InventoryInput extends StatelessWidget {
  final InventoryController c;
  final TextStyle style;
  final String hint, value;
  final TextInputType? keyboard;
  final bool obscure;
  final int? maxLines;
  final TextAlign align;
  final Color hintColor;
  const InventoryInput({
    super.key,
    required this.c,
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

class InventorySelections extends StatelessWidget {
  final InventoryController c;
  final List<(Set<int>, bool)> groups;
  final Widget Function(BuildContext, List<SelCtrl>) builder;
  const InventorySelections({
    super.key,
    required this.c,
    required this.groups,
    required this.builder,
  });
  @override
  Widget build(BuildContext context) => HSelHolder(
    groups: [
      (
        {
          c.mode == 'in'
              ? [
                  '现金',
                  '微信',
                  '对公转账',
                  '挂账',
                ].indexOf('${c.payload['payment']}').clamp(0, 3)
              : c.mode == 'out'
              ? [
                  '施工领用',
                  '损耗报废',
                  '退回供应商',
                  '内部使用',
                ].indexOf('${c.payload['reason']}').clamp(0, 3)
              : c.filter,
        },
        false,
      ),
    ],
    onSelect: {
      0: (i) {
        if (c.mode == 'in') {
          c.payload['payment'] = ['现金', '微信', '对公转账', '挂账'][i];
        } else if (c.mode == 'out') {
          c.payload['reason'] = ['施工领用', '损耗报废', '退回供应商', '内部使用'][i];
        } else {
          c.filter = i;
        }
        c.changed();
      },
    },
    builder: builder,
  );
}

/// Upload requires a storage policy and attachment API; never retain a local-only
/// image and imply it was attached to a posted document.
class InventoryAttachment extends StatelessWidget {
  final String imgKey;
  final double size, radius;
  final Widget child;
  const InventoryAttachment({
    super.key,
    required this.imgKey,
    required this.size,
    required this.radius,
    required this.child,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => AppToast.show(context, '附件上传尚未接通'),
    child: child,
  );
}
