import 'inventory_count_page.dart';
import 'inventory_scan_page.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/inventory_bindings.dart';
import 'inventory_live_page.dart';

const inventoryCategories = ['全部', '贴膜', '镀晶', '清洁用品', '洗护', '工具', '配件', '其他'];

class InventoryCatalogPage extends StatefulWidget {
  final bool lowOnly, picking;
  final Set<String> excluded;
  const InventoryCatalogPage({
    super.key,
    this.lowOnly = false,
    this.picking = false,
    this.excluded = const {},
  });
  @override
  State<InventoryCatalogPage> createState() => _CatalogState();
}

class _CatalogState extends State<InventoryCatalogPage> {
  final key = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  late String filter = widget.lowOnly ? '低库存' : '全部';
  String search = '', category = '全部';
  Timer? timer;
  final selected = <String>{};
  final scanned = <String, Map<String, dynamic>>{};
  @override
  void initState() {
    super.initState();
    inventoryChanged.addListener(reload);
  }

  void reload() => key.currentState?.reload();
  @override
  void dispose() {
    timer?.cancel();
    inventoryChanged.removeListener(reload);
    super.dispose();
  }

  bool low(Map p) => (p['stock'] as num) < (p['safe'] as num);
  bool matches(Map p, String f) => switch (f) {
    '低库存' => low(p) && p['active'] != false,
    '临期' => p['expiring'] == true,
    '已停用' => p['active'] == false,
    _ => true,
  };
  Future<void> create() async {
    await editProduct(context, null);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(
      title: Text(widget.picking ? '选择商品' : '全部商品'),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: '扫码查询',
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            final p = await scanInventory(context);
            if (p == null || !context.mounted) return;
            if (widget.picking) {
              if (p['active'] == false || widget.excluded.contains(p['id'])) {
                AppToast.show(context, '商品已停用或已在单据中');
                return;
              }
              setState(() {
                selected.add(p['id'] as String);
                scanned[p['id'] as String] = p;
              });
              AppToast.show(context, '已选中 ${p['name']}');
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      InventoryLivePage(mode: 'detail', productId: p['id']),
                ),
              );
            }
          },
        ),
        IconButton(onPressed: create, icon: const Icon(Icons.add)),
      ],
    ),
    body: AsyncView<List<Map<String, dynamic>>>(
      key: key,
      load: () async => maps(
        (await merchantApi.invoke({'action': 'inventory_list'}))['items'],
      ),
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 5),
      empty: (_) => const SizedBox.shrink(),
      builder: (context, all) {
        final products = {for (final p in all) p['id'] as String: p, ...scanned}
            .values
            .where(
              (p) =>
                  !widget.excluded.contains(p['id']) &&
                  (!widget.picking || p['active'] != false),
            )
            .toList();
        final rows = products
            .where(
              (p) =>
                  matches(p, filter) &&
                  (category == '全部' || p['category'] == category) &&
                  '${p['name']} ${p['sku']}'.toLowerCase().contains(
                    search.toLowerCase(),
                  ),
            )
            .toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: '搜索商品名称 / SKU',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(28)),
                  ),
                ),
                onChanged: (v) {
                  timer?.cancel();
                  timer = Timer(const Duration(milliseconds: 300), () {
                    if (mounted) setState(() => search = v);
                  });
                },
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final f
                      in widget.picking
                          ? inventoryCategories
                          : ['全部', '低库存', '临期', '已停用'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        showCheckmark: false,
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                        selectedColor: C.primarySoft,
                        backgroundColor: C.card,
                        label: Text(
                          widget.picking
                              ? f
                              : '$f ${products.where((p) => matches(p, f)).length}',
                        ),
                        selected: widget.picking ? category == f : filter == f,
                        onSelected: (_) => setState(() {
                          if (widget.picking) {
                            category = f;
                          } else {
                            filter = f;
                          }
                        }),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  reload();
                },
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (rows.isEmpty)
                      EmptyView.firstTime(
                        title: search.isNotEmpty
                            ? '没有找到“$search”相关结果'
                            : products.isEmpty
                            ? '还没有库存商品'
                            : '当前筛选下没有商品',
                      ),
                    if (rows.isNotEmpty)
                      AppCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (final p in rows)
                              Column(
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                      leading: widget.picking
                                          ? Icon(
                                              selected.contains(p['id'])
                                                  ? Icons.check_circle
                                                  : Icons
                                                        .radio_button_unchecked,
                                              color: C.primary,
                                            )
                                          : Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: C.primarySoft,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.inventory_2_outlined,
                                                color: C.primary,
                                                size: 20,
                                              ),
                                            ),
                                      title: Text(
                                        '${p['name']}${low(p) ? '  · 低库存' : ''}',
                                        style: ts(14, w: FontWeight.w600),
                                      ),
                                      subtitle: Text(
                                        '${p['category']} · ${p['location']} · 参考成本 ${money(p['cost'] as num)}',
                                        style: ts(12, color: C.muted),
                                      ),
                                      trailing: Text(
                                        '${qty(p['stock'] as num)} ${p['unit']}',
                                        style: ts(
                                          14,
                                          color: low(p) ? C.redInk : C.ink,
                                          w: FontWeight.w600,
                                        ),
                                      ),
                                      onTap: () {
                                        if (widget.picking) {
                                          setState(() {
                                            if (!selected.add(
                                              p['id'] as String,
                                            )) {
                                              selected.remove(p['id']);
                                            }
                                          });
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => InventoryLivePage(
                                                mode: 'detail',
                                                productId: p['id'],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  if (p != rows.last)
                                    const Divider(height: 1, indent: 64),
                                ],
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (widget.picking)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingButton(
                  label: '确定 · 添加 ${selected.length} 件',
                  disabledReason: '请选择商品',
                  onPressed: selected.isEmpty
                      ? null
                      : () async => Navigator.pop(
                          context,
                          products
                              .where((p) => selected.contains(p['id']))
                              .toList(),
                        ),
                ),
              ),
            if (!widget.picking && filter == '低库存' && rows.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: LoadingButton(
                  label: '一键补货 · 将 ${rows.length} 项加入入库单',
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InventoryLivePage(
                          mode: 'in',
                          productIds: rows
                              .map((p) => p['id'] as String)
                              .toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}

class InventoryDocumentsPage extends StatefulWidget {
  const InventoryDocumentsPage({super.key});
  @override
  State<InventoryDocumentsPage> createState() => _DocumentsState();
}

class _DocumentsState extends State<InventoryDocumentsPage> {
  final key = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  int kind = 0, page = 0;
  String filter = '全部';
  bool more = true;
  final rows = <Map<String, dynamic>>[];
  Map<String, dynamic> get query => {
    if (filter != '全部' && kind == 1) 'reason': filter,
    if (filter != '全部' && kind != 1)
      'status': filter == '草稿'
          ? 'draft'
          : filter == '已作废'
          ? 'void'
          : 'posted',
  };
  Future<List<Map<String, dynamic>>> load() async {
    final requestedKind = kind;
    final result = maps(
      (await merchantApi.invoke({
        'action': 'inventory_documents',
        'kind': ['in', 'out', 'check'][kind],
        'page': 0,
        ...query,
      }))['items'],
    );
    if (requestedKind != kind) return List.of(rows);
    rows
      ..clear()
      ..addAll(result);
    page = 0;
    more = result.length == 20;
    return List.of(rows);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(title: const Text('库存单据'), centerTitle: true),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Segmented(
            labels: const ['入库单', '出库单', '盘点单'],
            selected: kind,
            onChanged: (i) {
              setState(() {
                kind = i;
                filter = '全部';
              });
              key.currentState?.reload();
            },
          ),
        ),
        if (kind != 2)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f
                    in kind == 1
                        ? ['全部', '施工领用', '损耗报废', '退回供应商', '内部使用']
                        : ['全部', '草稿', '已入库', '已作废'])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      showCheckmark: false,
                      shape: const StadiumBorder(),
                      side: BorderSide.none,
                      selectedColor: C.primarySoft,
                      backgroundColor: C.card,
                      label: Text(kind == 2 && f == '已入库' ? '已盘点' : f),
                      selected: filter == f,
                      onSelected: (_) {
                        setState(() => filter = f);
                        key.currentState?.reload();
                      },
                    ),
                  ),
              ],
            ),
          ),
        Expanded(
          child: kind == 2
              ? const InventoryCountList()
              : AsyncView<List<Map<String, dynamic>>>(
                  key: key,
                  load: load,
                  isEmpty: (_) => false,
                  skeleton: const SkeletonList(count: 5),
                  empty: (_) => const SizedBox.shrink(),
                  builder: (context, data) => ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (rows.isEmpty) EmptyView.firstTime(title: '还没有库存单据'),
                      for (final d in rows.where(
                        (d) =>
                            filter == '全部' ||
                            (kind == 1
                                ? d['payload']['reason'] == filter
                                : d['status'] ==
                                      (filter == '草稿'
                                          ? 'draft'
                                          : filter == '已作废'
                                          ? 'void'
                                          : 'posted')),
                      ))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            padding: EdgeInsets.zero,
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                title: Text(
                                  '${['RK', 'CK', 'PD'][kind]}-${d['id'].toString().substring(0, 8)}  ${d['status'] == 'draft'
                                      ? '草稿'
                                      : d['status'] == 'void'
                                      ? '已作废'
                                      : '已完成'}',
                                  style: ts(14, w: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${d['payload']['date'] ?? ''} · ${d['payload']['supplier'] ?? ''} · ${(d['payload']['lines'] as List).length} 种商品',
                                ),
                                trailing: Text(
                                  d['total'] == null
                                      ? '—'
                                      : money(d['total'] as num),
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          InventoryDocumentPage(id: d['id']),
                                    ),
                                  );
                                  key.currentState?.reload();
                                },
                              ),
                            ),
                          ),
                        ),
                      if (more)
                        LoadingButton(
                          label: '加载更多',
                          onPressed: () async {
                            final requestedKind = kind;
                            final result = maps(
                              (await merchantApi.invoke({
                                'action': 'inventory_documents',
                                'kind': ['in', 'out', 'check'][kind],
                                'page': page + 1,
                                ...query,
                              }))['items'],
                            );
                            if (mounted && requestedKind == kind) {
                              setState(() {
                                rows.addAll(result);
                                page++;
                                more = result.length == 20;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}

class InventoryDocumentPage extends StatelessWidget {
  final String id;
  const InventoryDocumentPage({super.key, required this.id});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('单据详情')),
    body: AsyncView<Map<String, dynamic>>(
      load: () async => Map<String, dynamic>.from(
        (await merchantApi.invoke({
          'action': 'inventory_document_get',
          'id': id,
        }))['item'],
      ),
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 5),
      empty: (_) => const SizedBox.shrink(),
      builder: (context, d) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('单号 $id'),
                Text('日期 ${d['payload']['date'] ?? ''}'),
                Text('供应商 ${d['payload']['supplier'] ?? '—'}'),
                Text(
                  '状态 ${d['status'] == 'draft'
                      ? '草稿'
                      : d['status'] == 'void'
                      ? '已作废'
                      : '已完成'}',
                ),
                Text(
                  '合计 ${d['total'] == null ? '—' : money(d['total'] as num)}',
                ),
                for (final l in maps(d['payload']['lines']))
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(l['name']?.toString() ?? '商品 ${l['id']}'),
                      subtitle: Text(
                        '数量 ${l['quantity']} · 单价 ${l['cost'] ?? '按库存成本'}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (d['status'] == 'draft')
            TextButton(
              child: const Text('作废草稿'),
              onPressed: () async {
                final done = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('作废这张草稿？'),
                    content: const Text('作废后不可继续编辑，不会改变库存。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      LoadingButton(
                        label: '确认作废',
                        onPressed: () async {
                          await merchantApi.invoke({
                            'action': 'inventory_document_void',
                            'id': id,
                            'revision': d['revision'],
                          });
                          if (ctx.mounted) Navigator.pop(ctx, true);
                        },
                      ),
                    ],
                  ),
                );
                if (done == true && context.mounted) Navigator.pop(context);
              },
            ),
          if (d['status'] == 'draft')
            LoadingButton(
              label: '继续编辑',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InventoryLivePage(
                      mode: d['kind'],
                      documentId: id,
                      legacyCheck: d['kind'] == 'check',
                    ),
                  ),
                );
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    ),
  );
}
