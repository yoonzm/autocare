import '../../kit/buttons.dart';
import '../../backend/merchant_api.dart';
import 'inventory_controller.dart';
import 'inventory_management_page.dart';

import 'package:flutter/material.dart';

import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../kit/sheet_frame.dart';
import '../../theme.dart';
import '../../resources/merchant_svgs.dart';

/// 入库 / 出库页的「选择商品」「选择供应商」底部弹层，以及「新增供应商」页。
/// 版式取自设计稿 ProductPicker / SupplierPicker / SupplierEdit；数据来自库存接口，不在这里造假。

List<BoxShadow> _cardShadow(BuildContext context) => dk(
  context,
  const [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 1),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ],
  const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)],
);

Widget _searchPill(
  BuildContext context,
  String hint,
  ValueChanged<String> onChanged,
) => hbox(
  minH: 44,
  bg: C.card,
  radius: BorderRadius.circular(24),
  shadow: _cardShadow(context),
  pad: const EdgeInsets.symmetric(horizontal: 16),
  child: Row(
    children: [
      hsvg(dk(context, Svgs.s418, Svgs.s419), w: 18, h: 18),
      const SizedBox(width: 10),
      Expanded(
        child: TextField(
          onChanged: onChanged,
          style: ts(15, h: 22),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ts(15, color: C.muted, h: 22),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    ],
  ),
);

Widget _pillButton(
  String label, {
  required bool primary,
  required VoidCallback? onTap,
}) => AppButton(
  label: label,
  kind: AppButtonKind.primary,
  size: AppButtonSize.large,
  expanded: false,
  onPressed: onTap,
);

Widget _footer(
  BuildContext context, {
  required String confirm,
  required VoidCallback? onConfirm,
}) => Padding(
  padding: const EdgeInsets.only(top: 4),
  child: Row(
    children: [
      Expanded(
        child: _pillButton(
          '取消',
          primary: false,
          onTap: () => Navigator.pop(context),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 2,
        child: _pillButton(confirm, primary: true, onTap: onConfirm),
      ),
    ],
  ),
);

Widget _link(BuildContext context, String text, VoidCallback onTap) => Align(
  alignment: Alignment.centerLeft,
  child: AppButton(
    label: text,
    kind: AppButtonKind.text,
    size: AppButtonSize.medium,
    expanded: false,
    onPressed: onTap,
  ),
);

/// 选择商品（可多选）。返回选中的商品；点「找不到？新增商品」时交给 [onCreate]，新建成功后一并带回。
Future<List<Map<String, dynamic>>?> showProductPicker(
  BuildContext context, {
  required List<Map<String, dynamic>> products,
  required Set<Object?> excluded,
  required Future<Map<String, dynamic>?> Function() onCreate,
}) => showModalBottomSheet<List<Map<String, dynamic>>>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _ProductPickerSheet(
    products: products,
    excluded: excluded,
    onCreate: onCreate,
  ),
);

class _ProductPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Set<Object?> excluded;
  final Future<Map<String, dynamic>?> Function() onCreate;
  const _ProductPickerSheet({
    required this.products,
    required this.excluded,
    required this.onCreate,
  });
  @override
  State<_ProductPickerSheet> createState() => _ProductPickerState();
}

class _ProductPickerState extends State<_ProductPickerSheet> {
  final selected = <Object?>[];
  late final List<Map<String, dynamic>> all = [...widget.products];
  late final _categories = [
    '全部',
    ...{for (final p in all) '${p['category']}'},
  ];
  int cat = 0;
  String q = '';

  List<Map<String, dynamic>> get visible => [
    for (final p in all)
      if (p['active'] != false &&
          !widget.excluded.contains(p['id']) &&
          (cat == 0 || p['category'] == _categories[cat]) &&
          (q.isEmpty ||
              '${p['name']}'.toLowerCase().contains(q) ||
              '${p['sku'] ?? ''}'.toLowerCase().contains(q)))
        p,
  ];

  String _sub(Map<String, dynamic> p) {
    final spec = '${p['specification'] ?? ''}'.trim();
    return '${spec.isEmpty ? '' : '$spec · '}库存 ${_n(p['stock'])} ${p['unit']}';
  }

  String _n(Object? v) =>
      v is num && v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  @override
  Widget build(BuildContext context) {
    final list = visible;
    final maxH = MediaQuery.sizeOf(context).height * .6;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppSheetFrame(
        title: '选择商品',
        children: [
          Row(
            children: [
              Expanded(
                child: _searchPill(
                  context,
                  '搜索商品名称 / SKU',
                  (v) => setState(() => q = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 8),
              AppIconButton(
                svg: dk(context, Svgs.s329, Svgs.s330),
                semanticLabel: '扫码添加商品',
                onPressed: () async {
                  final p = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => const InventoryManagementPage(
                            mode: 'scan',
                            returnProduct: true,
                          ),
                        ),
                      );
                  if (p != null &&
                      mounted &&
                      !widget.excluded.contains(p['id'])) {
                    setState(() {
                      if (!all.any((v) => v['id'] == p['id'])) all.add(p);
                      if (!selected.contains(p['id'])) selected.add(p['id']);
                    });
                  }
                },
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < _categories.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => cat = i),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i == cat ? C.primarySoft : C.inset,
                        borderRadius: BorderRadius.circular(17),
                        border: i == cat
                            ? Border.all(color: C.primary, width: 1.5)
                            : null,
                      ),
                      child: Text(
                        _categories[i],
                        style: ts(
                          13,
                          w: FontWeight.w500,
                          color: i == cat ? C.primaryInk : C.sub,
                          h: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            constraints: BoxConstraints(maxHeight: maxH * .6),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: C.line),
            ),
            child: list.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        all.isEmpty ? '还没有商品，先新增一个吧' : '没有符合条件的商品',
                        style: ts(13, color: C.muted, h: 18),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: list.length,
                    separatorBuilder: (_, _) => Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 50),
                      color: C.line,
                    ),
                    itemBuilder: (_, i) => _row(list[i]),
                  ),
          ),
          _link(context, '找不到？新增商品', () async {
            final p = await widget.onCreate();
            if (p == null || !mounted) return;
            setState(() {
              all.add(p);
              selected.add(p['id']);
            });
          }),
          _footer(
            context,
            confirm: selected.isEmpty ? '确定' : '确定 · 添加 ${selected.length} 件',
            onConfirm: selected.isEmpty
                ? null
                : () => Navigator.pop(context, [
                    for (final id in selected)
                      all.firstWhere((p) => p['id'] == id),
                  ]),
          ),
        ],
      ),
    );
  }

  Widget _row(Map<String, dynamic> p) {
    final on = selected.contains(p['id']);
    final low =
        p['stock'] is num &&
        p['safe'] is num &&
        (p['stock'] as num) < (p['safe'] as num);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() {
        on ? selected.remove(p['id']) : selected.add(p['id']);
      }),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            on
                ? Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: C.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: hsvg(Svgs.s11, w: 13, h: 13)),
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC7C7CC),
                        width: 1.5,
                      ),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${p['name']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(14, w: FontWeight.w500, h: 20),
                        ),
                      ),
                      if (low) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: C.redSoft,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '低库存',
                            softWrap: false,
                            maxLines: 1,
                            style: ts(
                              11,
                              w: FontWeight.w600,
                              color: C.redInk,
                              h: 18,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_sub(p), style: ts(12, color: C.muted, h: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选择供应商（单选）。返回选中的供应商名称；「+ 新增供应商」进入 [SupplierEditPage]，保存后直接选中。
Future<String?> showSupplierPicker(
  BuildContext context, {
  required List<String> suppliers,
  required String current,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => _SupplierPickerSheet(suppliers: suppliers, current: current),
);

class _SupplierPickerSheet extends StatefulWidget {
  final List<String> suppliers;
  final String current;
  const _SupplierPickerSheet({required this.suppliers, required this.current});
  @override
  State<_SupplierPickerSheet> createState() => _SupplierPickerState();
}

class _SupplierPickerState extends State<_SupplierPickerSheet> {
  List<Map<String, dynamic>> records = [];
  List<String> all = [];
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  Future<Map<String, dynamic>> load() async {
    final r = await merchantApi.invoke({'action': 'inventory_options'});
    records = maps(r['suppliers']);
    all = records.map((s) => '${s['name']}').toList();
    return r;
  }

  late String selected = widget.current;
  String q = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: AppSheetFrame(
        title: '选择供应商',
        children: [
          _searchPill(context, '搜索供应商', (v) => setState(() => q = v.trim())),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .36,
            child: AsyncView<Map<String, dynamic>>(
              key: key,
              load: load,
              isEmpty: (_) => false,
              skeleton: const SkeletonList(count: 3),
              empty: (_) => const SizedBox.shrink(),
              builder: (_, data) => Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .36,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: dk(
                    context,
                    const Color(0xFFF4F4F5),
                    const Color(0xFF27272A),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: all.where((s) => s.contains(q)).isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            all.isEmpty ? '还没有供应商，先新增一个吧' : '没有符合条件的供应商',
                            style: ts(13, color: C.muted, h: 18),
                          ),
                        ),
                      )
                    : ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [
                          for (final s in all.where((s) => s.contains(q)))
                            _row(s),
                        ],
                      ),
              ),
            ),
          ),
          _link(context, '+ 新增供应商', () async {
            final name = await Navigator.of(context).push<String>(
              MaterialPageRoute(builder: (_) => const SupplierEditPage()),
            );
            if (name == null || !mounted) return;
            setState(() {
              if (!all.contains(name)) all.add(name);
              selected = name;
            });
            key.currentState?.reload();
          }),
          _footer(
            context,
            confirm: '确定',
            onConfirm: selected.isEmpty
                ? null
                : () => Navigator.pop(context, selected),
          ),
        ],
      ),
    );
  }

  Widget _row(String s) {
    final on = s == selected;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => selected = s),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: on ? C.primary : null,
                border: on
                    ? null
                    : Border.all(color: const Color(0xFFC7C7CC), width: 1.5),
              ),
              child: on
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s, style: ts(15, w: FontWeight.w500, h: 22)),
                  if (records.any((r) => r['name'] == s))
                    Text(
                      records
                          .where((r) => r['name'] == s)
                          .map((r) => '${r['contact']} · ${r['phone']}')
                          .first,
                      style: ts(12, color: C.muted, h: 18),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 新增供应商（设计稿 SupplierEdit）：名称必填，填写后「保存」才可点。
///
class SupplierEditPage extends StatefulWidget {
  const SupplierEditPage({super.key});
  @override
  State<SupplierEditPage> createState() => _SupplierEditState();
}

class _SupplierEditState extends State<SupplierEditPage> {
  final request = InventoryRequest();
  late final _saveKey = 'supplier-save-${identityHashCode(this)}';
  late final id = inventoryId();
  bool busy = false;
  Future<void> save() async {
    if (busy || !mounted) return;
    setState(() => busy = true);
    try {
      final r = await request.send({
        'action': 'inventory_supplier_save',
        'payload': {
          'id': id,
          'name': name.text.trim(),
          'contact': contact.text.trim(),
          'phone': phone.text.trim(),
          'note': note.text.trim(),
        },
      });
      if (mounted) Navigator.pop(context, r['item']['name']);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  final name = TextEditingController(),
      contact = TextEditingController(),
      phone = TextEditingController(),
      note = TextEditingController();

  @override
  void dispose() {
    for (final c in [name, contact, phone, note]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _field(
    String label,
    String hint,
    TextEditingController c, {
    bool required = false,
    TextInputType? keyboard,
    String? foot,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text.rich(
        TextSpan(
          style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
          children: [
            TextSpan(text: label),
            if (required)
              TextSpan(
                text: ' *',
                style: ts(13, w: FontWeight.w500, color: C.red, h: 18),
              ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: C.inset,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextField(
          controller: c,
          keyboardType: keyboard,
          onChanged: (_) => setState(() {}),
          style: ts(15, h: 22),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ts(15, color: C.muted, h: 22),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      if (foot != null) ...[
        const SizedBox(height: 6),
        Text(foot, style: ts(12, color: C.muted, h: 16)),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    final ready = name.text.trim().isNotEmpty && !busy;
    return AsyncActionScope(
      actionKey: _saveKey,
      child: Scaffold(
        backgroundColor: C.bg,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppPageHeader(title: '新增供应商'),
                    const SizedBox(height: 14),
                    hbox(
                      bg: C.card,
                      radius: BorderRadius.circular(24),
                      shadow: _cardShadow(context),
                      pad: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _field('供应商名称', '如：蓝盾膜业', name, required: true),
                          const SizedBox(height: 14),
                          _field('联系人', '选填', contact),
                          const SizedBox(height: 14),
                          _field(
                            '联系电话',
                            '选填',
                            phone,
                            keyboard: TextInputType.phone,
                            foot: '仅用于店内联系，不会通知对方',
                          ),
                          const SizedBox(height: 14),
                          _field('备注', '如结算周期、送货说明', note),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: C.bg,
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
              child: ActionButton(
                actionKey: _saveKey,
                label: '保存',
                kind: AppButtonKind.primary,
                size: AppButtonSize.large,
                expanded: true,
                onPressed: ready ? () => runBusy(_saveKey, save) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
