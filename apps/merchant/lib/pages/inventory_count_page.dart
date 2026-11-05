import 'inventory_catalog_page.dart' show InventoryDocumentPage;

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show ConfirmDiscard, hConfirm;
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/inventory_bindings.dart';
import 'inventory_scan_page.dart';

String countMoney(num n) =>
    '${n < 0
        ? '-'
        : n > 0
        ? '+'
        : ''}¥${n.abs().toStringAsFixed(2)}';
String countNumber(Map d) =>
    'PD-${d['id'].toString().substring(0, 8).toUpperCase()}';
String countScope(Map d) =>
    d['scope'] == 'all' ? '全部商品' : '${d['scope_value']}';
Future<Map<String, dynamic>> countAction(
  String action,
  String id, [
  Map<String, dynamic> fields = const {},
]) async => Map<String, dynamic>.from(
  (await merchantApi.invoke({
    'action': 'inventory_count_$action',
    'id': id,
    ...fields,
  }))['item'],
);
Widget countCard(String title, List<Widget> children) => Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: ts(16, w: FontWeight.w600)),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  ),
);
Widget countNotice(String text, {bool warning = false}) => Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: warning ? C.amberSoft : C.primarySoft,
    borderRadius: BorderRadius.circular(14),
  ),
  child: Text(text, style: ts(13, color: warning ? C.amberInk : C.primaryInk)),
);

class InventoryCountStartPage extends StatefulWidget {
  const InventoryCountStartPage({super.key});
  @override
  State<InventoryCountStartPage> createState() => _CountStartState();
}

class _CountStartState extends State<InventoryCountStartPage> {
  String scope = 'all', value = '';
  bool blind = true, freeze = false, busy = false;
  final id = inventoryId();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(title: const Text('新建盘点'), centerTitle: true),
    body: AsyncView<Map<String, dynamic>>(
      load: () async {
        final r = await Future.wait([
          merchantApi.invoke({'action': 'inventory_list'}),
          merchantApi.invoke({'action': 'inventory_count_list'}),
        ]);
        return {'products': r[0]['items'], 'active': r[1]['active']};
      },
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 3),
      empty: (_) => const SizedBox.shrink(),
      builder: (context, data) {
        final products = maps(data['products'])
            .where((p) => p['active'] != false)
            .toList();
        final active = maps(data['active']);
        final options =
            products
                .map(
                  (p) => '${p[scope == 'category' ? 'category' : 'location']}',
                )
                .where((s) => s.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
        final total = products
            .where(
              (p) =>
                  scope == 'all' ||
                  p[scope == 'category' ? 'category' : 'location'] == value,
            )
            .length;
        return AbsorbPointer(
          absorbing: busy,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (active.isNotEmpty)
                      countCard('进行中的盘点', [
                        Text(
                          '${countNumber(active.first)} · 已盘 ${active.first['counted']} / ${active.first['total']} 项',
                        ),
                        const SizedBox(height: 12),
                        LoadingButton(
                          label: '继续盘点',
                          onPressed: () async {
                            await Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => active.first['legacy'] == true
                                    ? InventoryDocumentPage(
                                        id: active.first['id'],
                                      )
                                    : InventoryCountPage(
                                        id: active.first['id'],
                                      ),
                              ),
                            );
                          },
                        ),
                      ]),
                    countCard('盘点范围', [
                      Text('范围', style: ts(13, color: C.sub)),
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final e in {
                            'all': '全部商品',
                            'category': '按分类',
                            'location': '按货位',
                          }.entries)
                            ChoiceChip(
                              showCheckmark: false,
                              shape: const StadiumBorder(),
                              selectedColor: C.primarySoft,
                              label: Text(e.value),
                              selected: scope == e.key,
                              onSelected: (_) => setState(() {
                                scope = e.key;
                                value = '';
                              }),
                            ),
                        ],
                      ),
                      if (scope != 'all')
                        DropdownButtonFormField<String>(
                          key: ValueKey(scope),
                          hint: Text(scope == 'category' ? '请选择分类' : '请选择货位'),
                          items: options
                              .map(
                                (v) =>
                                    DropdownMenuItem(value: v, child: Text(v)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => value = v ?? ''),
                        ),
                      const SizedBox(height: 12),
                      Text(
                        '共 $total 项商品，预计盘点 ${(total / 8).ceil()} 分钟',
                        style: ts(12, color: C.muted),
                      ),
                    ]),
                    countCard('盘点方式', [
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          activeTrackColor: C.primary,
                          activeThumbColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('盲盘'),
                          subtitle: const Text('开启后录入时不显示系统库存，避免照抄'),
                          value: blind,
                          onChanged: (v) => setState(() => blind = v),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          activeTrackColor: C.primary,
                          activeThumbColor: Colors.white,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('盘点期间暂停出入库'),
                          subtitle: const Text('开启后，其他出入库只能暂存，结束盘点后再提交'),
                          value: freeze,
                          onChanged: (v) => setState(() => freeze = v),
                        ),
                      ),
                    ]),
                    countNotice('同一时间只能有一张进行中的盘点单，提交或取消后才能新建下一张。'),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LoadingButton(
                    label: '开始盘点',
                    disabledReason: active.isNotEmpty
                        ? '请先结束进行中的盘点'
                        : '请选择有商品的盘点范围',
                    onPressed: active.isNotEmpty || total == 0
                        ? null
                        : () async {
                            setState(() => busy = true);
                            try {
                              final d = await countAction('start', id, {
                                'scope': scope,
                                'value': value,
                                'blind': blind,
                                'freeze': freeze,
                              });
                              if (context.mounted) {
                                await Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InventoryCountPage(id: d['id']),
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => busy = false);
                            }
                          },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class InventoryCountPage extends StatefulWidget {
  final String id;
  const InventoryCountPage({super.key, required this.id});
  @override
  State<InventoryCountPage> createState() => _CountPageState();
}

class _CountPageState extends State<InventoryCountPage> {
  Map<String, dynamic>? doc;
  List<Map<String, dynamic>> lines = [];
  bool busy = false, dirty = false, conflict = false;
  int filter = 0, epoch = 0;
  String? scanId;
  final form = GlobalKey<FormState>();
  void accept(Map<String, dynamic> d) {
    doc = d;
    lines = maps(d['lines']);
    dirty = false;
    epoch++;
  }

  Future<void> persist() async {
    if (!form.currentState!.validate()) throw const AppError('请检查实盘数量');
    final d = await countAction('save', widget.id, {
      'revision': doc!['revision'],
      'lines': lines
          .map((l) => {'id': l['id'], 'quantity': l['quantity']})
          .toList(),
    });
    if (mounted) setState(() => accept(d));
  }

  Future<void> act(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted && e.toString().contains('库存已变化')) {
        setState(() => conflict = true);
      }
      rethrow;
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> review() async {
    await persist();
    final d = await countAction('review', widget.id, {
      'revision': doc!['revision'],
    });
    if (!mounted) return;
    final posted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => InventoryCountResultPage(doc: d)),
    );
    if (posted == true && mounted) {
      setState(() {
        dirty = false;
        busy = false;
      });
      inventoryChanged.value++;
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => ConfirmDiscard(
    dirty: dirty,
    busy: busy,
    child: Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(
        title: const Text('库存盘点'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: doc?['status'] != 'active' || busy
                  ? null
                  : () async {
                      try {
                        await runBusy(
                          'InventoryCount-draft',
                          () => act(() async {
                            await persist();
                            if (context.mounted) {
                              AppToast.show(context, '盘点已暂存');
                            }
                          }),
                        );
                      } catch (e) {
                        if (context.mounted) AppToast.error(context, e);
                      }
                    },
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: hBusy(
                  'InventoryCount-draft',
                  Text('暂存', style: ts(14, w: FontWeight.w600)),
                  round: true,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: '扫码定位商品',
            onPressed: busy
                ? null
                : () async {
                    final p = await scanInventory(context);
                    if (p == null || !context.mounted) return;
                    if (!lines.any((l) => l['id'] == p['id'])) {
                      AppToast.show(context, '该商品不在本次盘点范围内');
                      return;
                    }
                    setState(() {
                      scanId = p['id'];
                      filter = 0;
                    });
                  },
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      body: AsyncView<Map<String, dynamic>>(
        load: () => countAction('get', widget.id),
        isEmpty: (_) => false,
        onLoaded: accept,
        skeleton: const SkeletonList(count: 5),
        empty: (_) => const SizedBox.shrink(),
        builder: (context, data) {
          final d = doc!;
          if (d['status'] != 'active') return InventoryCountResultBody(doc: d);
          final counted = lines.where((l) => l['quantity'] is num).length;
          final blind = d['blind'] == true;
          final visible = lines
              .where(
                (l) =>
                    (scanId == null || l['id'] == scanId) &&
                    (filter == 0 ||
                        (filter == 1 && l['quantity'] == null) ||
                        (filter == 2 &&
                            l['quantity'] is num &&
                            l['quantity'] != l['stock'])),
              )
              .toList();
          return AbsorbPointer(
            absorbing: busy,
            child: Column(
              children: [
                Expanded(
                  child: Form(
                    key: form,
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        AppCard(
                          color: const Color(0xff18181b),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${countNumber(d)} · ${countScope(d)}',
                                style: ts(12, color: Colors.white60),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '$counted / ${lines.length} 已盘点',
                                style: ts(
                                  26,
                                  color: Colors.white,
                                  w: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: lines.isEmpty
                                    ? 0
                                    : counted / lines.length,
                                color: C.primary,
                                backgroundColor: Colors.white12,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                blind
                                    ? '盲盘中 · 系统库存与差异将在结果确认页展示'
                                    : '已录入 $counted 项，提交前查看差异金额',
                                style: ts(12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Segmented(
                          labels: blind
                              ? const ['全部', '未盘点']
                              : const ['全部', '未盘点', '有差异'],
                          selected: filter,
                          onChanged: (v) => setState(() => filter = v),
                        ),
                        const SizedBox(height: 16),
                        if (scanId != null)
                          TextButton(
                            onPressed: () => setState(() => scanId = null),
                            child: const Text('清除扫码定位 · 显示全部商品'),
                          ),
                        if (conflict)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              children: [
                                countNotice(
                                  '库存已变化，刷新快照会清除受影响商品的实盘数，请重新盘点。',
                                  warning: true,
                                ),
                                LoadingButton(
                                  label: '刷新盘点快照',
                                  onPressed: () => act(() async {
                                    final d = await countAction(
                                      'rebase',
                                      widget.id,
                                      {'revision': doc!['revision']},
                                    );
                                    if (mounted) {
                                      setState(() {
                                        accept(d);
                                        conflict = false;
                                      });
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                        if (visible.isEmpty)
                          EmptyView.firstTime(title: '当前筛选下没有商品'),
                        AppCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              for (final l in visible)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${l['name']}',
                                              style: ts(14, w: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              blind
                                                  ? '${l['location']} · ${l['unit']}'
                                                  : '${l['location']} · 系统 ${qty(l['stock'] as num)} ${l['unit']}',
                                              style: ts(12, color: C.muted),
                                            ),
                                            if (!blind && l['quantity'] is num)
                                              Text(
                                                l['quantity'] == l['stock']
                                                    ? '一致'
                                                    : '${(l['quantity'] as num) > (l['stock'] as num) ? '盘盈' : '盘亏'} ${qty((l['quantity'] as num) - (l['stock'] as num))}',
                                                style: ts(
                                                  11,
                                                  color:
                                                      (l['quantity'] as num) <
                                                          (l['stock'] as num)
                                                      ? C.redInk
                                                      : C.greenInk,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      SizedBox(
                                        width: 80,
                                        child: TextFormField(
                                          key: ValueKey('${l['id']}-$epoch'),
                                          initialValue: l['quantity'] == null
                                              ? ''
                                              : '${l['quantity']}',
                                          textAlign: TextAlign.center,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: true,
                                              ),
                                          decoration: InputDecoration(
                                            hintText: '—',
                                            filled: true,
                                            fillColor: C.bg,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          validator: (v) {
                                            if ((v ?? '').isEmpty) return null;
                                            final n = num.tryParse(v!);
                                            return n == null ||
                                                    !n.isFinite ||
                                                    n < 0 ||
                                                    n > 999999999 ||
                                                    (l['allow_decimal'] ==
                                                            false &&
                                                        n != n.round())
                                                ? '数量无效'
                                                : null;
                                          },
                                          onChanged: (v) => setState(() {
                                            l['quantity'] = v.isEmpty
                                                ? null
                                                : num.tryParse(v) ?? v;
                                            dirty = true;
                                          }),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        countNotice(
                          '提交后生成盘盈 / 盘亏调整单，盘亏成本自动计入损耗开支。未盘商品保持原库存。',
                          warning: true,
                        ),
                        TextButton(
                          onPressed: () async {
                            final ok = await hConfirm(
                              context,
                              '取消本次盘点？',
                              ok: '确认取消',
                              message: '已暂存数量保留为取消记录，未保存修改将丢弃。库存不变，并解除暂停出入库。',
                              onConfirm: () async {
                                await countAction('cancel', widget.id, {
                                  'revision': doc!['revision'],
                                });
                              },
                            );
                            if (ok && mounted) {
                              setState(() => dirty = false);
                              await WidgetsBinding.instance.endOfFrame;
                              if (context.mounted) Navigator.pop(context);
                            }
                          },
                          child: const Text('取消本次盘点'),
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: LoadingButton(
                        label: '提交盘点（已盘 $counted 项）',
                        disabledReason: '请至少录入一项数量',
                        onPressed: counted == 0 ? null : () => act(review),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}

class InventoryCountResultPage extends StatefulWidget {
  final Map<String, dynamic> doc;
  const InventoryCountResultPage({super.key, required this.doc});
  @override
  State<InventoryCountResultPage> createState() => _CountResultState();
}

class _CountResultState extends State<InventoryCountResultPage> {
  bool busy = false;
  Map<String, dynamic> get doc => widget.doc;
  Future<void> submit() async {
    setState(() => busy = true);
    try {
      await countAction('post', doc['id'], {'revision': doc['revision']});
      inventoryChanged.value++;
      if (!mounted) return;
      setState(() => busy = false);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !busy,
    child: Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('盘点结果'), centerTitle: true),
      body: InventoryCountResultBody(doc: doc),
      bottomNavigationBar: doc['status'] == 'active'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('返回修改'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: LoadingButton(
                        label: '确认提交',
                        onPressed: busy ? null : submit,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    ),
  );
}

class InventoryCountResultBody extends StatelessWidget {
  final Map<String, dynamic> doc;
  const InventoryCountResultBody({super.key, required this.doc});
  @override
  Widget build(BuildContext context) {
    if (doc['status'] == 'void') {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          countCard('${countNumber(doc)} · 已取消', [
            Text(
              '${countScope(doc)} · 已录入 ${maps(doc['lines']).where((l) => l['quantity'] != null).length} 项',
            ),
          ]),
          countNotice('本次盘点未提交，库存未调整，暂停出入库已解除。'),
        ],
      );
    }
    final r = Map<String, dynamic>.from(doc['result'] ?? {});
    final differences = maps(r['differences']);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AppCard(
          color: const Color(0xff18181b),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${countNumber(doc)} · ${doc['status'] == 'void' ? '已取消' : '盘点结果'}',
                style: ts(12, color: Colors.white60),
              ),
              const SizedBox(height: 16),
              Text(
                '${r['counted'] ?? maps(doc['lines']).where((l) => l['quantity'] != null).length} 项已盘',
                style: ts(28, color: Colors.white, w: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '盘盈\n+${differences.where((l) => (l['difference'] as num) > 0).length} 项',
                      style: ts(16, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '盘亏\n-${differences.where((l) => (l['difference'] as num) < 0).length} 项',
                      style: ts(16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        countCard('差异明细', [
          Text('按实盘数量调整库存，未盘商品保持不变', style: ts(12, color: C.muted)),
          if (differences.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('没有库存差异'),
            ),
          for (final l in differences)
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l['name']}', style: ts(14, w: FontWeight.w600)),
                        Text(
                          '系统 ${qty(l['stock'] as num)} · 实盘 ${qty(l['quantity'] as num)}',
                          style: ts(12, color: C.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(l['difference'] as num) > 0 ? '+' : ''}${qty(l['difference'] as num)} ${l['unit']}',
                  ),
                ],
              ),
            ),
        ]),
        countCard('差异金额（库存成本）', [
          for (final e in {
            'positive': '盘盈',
            'negative': '盘亏',
            'net': '净差异',
          }.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(e.value)),
                  Text(
                    countMoney(r[e.key] as num? ?? 0),
                    style: ts(16, w: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ]),
        countNotice(
          doc['status'] == 'active'
              ? '提交后不能修改，如有误请新建盘点单更正。'
              : '本次盘点已结束，记录不可修改。',
          warning: true,
        ),
      ],
    );
  }
}

class InventoryCountList extends StatefulWidget {
  const InventoryCountList({super.key});
  @override
  State<InventoryCountList> createState() => _CountListState();
}

class _CountListState extends State<InventoryCountList> {
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  int page = 0;
  bool more = false;
  List<Map<String, dynamic>> history = [];
  @override
  Widget build(BuildContext context) => AsyncView<Map<String, dynamic>>(
    key: key,
    load: () async {
      final d = await merchantApi.invoke({'action': 'inventory_count_list'});
      history = maps(d['items']);
      page = 0;
      more = history.length == 20;
      return d;
    },
    isEmpty: (_) => false,
    skeleton: const SkeletonList(count: 4),
    empty: (_) => const SizedBox.shrink(),
    builder: (context, d) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final section in {
          '进行中': maps(d['active']),
          '历史': history,
        }.entries) ...[
          Text(section.key, style: ts(13, color: C.sub)),
          const SizedBox(height: 12),
          if (section.value.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                section.key == '进行中' ? '没有进行中的盘点' : '还没有历史盘点记录',
                style: ts(13, color: C.muted),
              ),
            ),
          for (final c in section.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => c['legacy'] == true
                          ? InventoryDocumentPage(id: c['id'])
                          : InventoryCountPage(id: c['id']),
                    ),
                  );
                  key.currentState?.reload();
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${countNumber(c)}  ${c['status'] == 'active'
                                ? '盘点中'
                                : c['status'] == 'posted'
                                ? '已提交'
                                : '已取消'}',
                            style: ts(15, w: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${countScope(c)} · 已盘 ${c['counted']} / ${c['total']} 项',
                            style: ts(12, color: C.muted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      c['result'] == null
                          ? '—'
                          : countMoney(c['result']['net'] as num),
                      style: ts(16, w: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (more)
          LoadingButton(
            label: '加载更多',
            onPressed: () async {
              final d = await merchantApi.invoke({
                'action': 'inventory_count_list',
                'page': page + 1,
              });
              if (mounted) {
                setState(() {
                  final next = maps(d['items']);
                  history.addAll(next);
                  page++;
                  more = next.length == 20;
                });
              }
            },
          ),
        LoadingButton(
          label: '新建盘点',
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InventoryCountStartPage(),
              ),
            );
            key.currentState?.reload();
          },
        ),
      ],
    ),
  );
}
