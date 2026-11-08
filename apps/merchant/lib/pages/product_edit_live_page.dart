import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../kit/page_header.dart';
import '../theme.dart';
import '../widgets/choice_chip_group.dart';
import '../widgets/inventory_bindings.dart';
import 'gen/svgs.dart';
import 'inventory_pickers.dart';

/// 新增商品 / 编辑商品（设计稿 ProductEdit / ProductEditExist 是同一个页面的两种状态）。
///
/// 真正接通：商品名称、规格型号、SKU、分类（贴膜 / 镀晶 / 清洁用品 / 工具）、计量单位、安全库存、货位、
/// 参考成本价（仅新增）、默认供应商（名称），走 `inventory_create` / `inventory_update`。
///
/// 仍是 mock / TODO（页面可操作，但不会保存，也不假装保存）：
/// - 「其他」分类：后端分类固定为 洗护 / 镀晶 / 贴膜 / 配件，没有对应值。
/// - 「需要管理保质期」「临期提醒」：后端商品表没有保质期开关和提醒天数，预期扩展 inventory_products。
/// - 「停用此商品」：后端没有停用状态，且需要“库存不为 0 时不能停用”的服务端校验。
/// - 编辑时的成本价：后端更新商品不改成本（加权成本由入库批次决定），所以只读。
class ProductEditLivePage extends StatefulWidget {
  /// 为空表示新增；否则是 `inventory_get` 返回的商品。
  final Map<String, dynamic>? product;
  const ProductEditLivePage({super.key, this.product});
  @override
  State<ProductEditLivePage> createState() => _ProductEditState();
}

/// 设计稿的分类 -> 后端分类。
const _categoryToBackend = {'贴膜': '贴膜', '镀晶': '镀晶', '清洁用品': '洗护', '工具': '配件'};
const _units = ['件', '瓶', '卷', '桶', '米', '升', '千克'];

class _ProductEditState extends State<ProductEditLivePage> {
  late final bool editing = widget.product != null;
  late final Map<String, dynamic> p = widget.product ?? {};
  late final name = TextEditingController(text: '${p['name'] ?? ''}');
  late final spec = TextEditingController(text: '${p['specification'] ?? ''}');
  late final sku = TextEditingController(text: '${p['sku'] ?? ''}');
  late final safe = TextEditingController(
    text: editing ? qty((p['safe'] as num?) ?? 0) : '',
  );
  late final location = TextEditingController(text: '${p['location'] ?? ''}');
  late final cost = TextEditingController(
    text: editing
        ? '¥ ${(((p['cost'] as num?) ?? 0).toStringAsFixed(2)).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',')}'
        : '',
  );
  late final expiryDays = TextEditingController(text: '30');
  late String? category = _categoryToBackend.entries
      .where((e) => e.value == p['category'])
      .map((e) => e.key)
      .firstOrNull;
  late String? unit = editing ? '${p['unit']}' : '件';
  late String supplier = '${p['supplier'] ?? ''}';
  bool shelfLife = false; // TODO: 后端没有保质期开关，仅界面状态，不保存。
  bool dirty = false, busy = false;

  @override
  void dispose() {
    for (final c in [name, spec, sku, safe, location, cost, expiryDays]) {
      c.dispose();
    }
    super.dispose();
  }

  void _touch() {
    if (!dirty) setState(() => dirty = true);
  }

  Future<void> _pickSupplier() async {
    List<String> suppliers = [];
    try {
      final r = await merchantApi.invoke({'action': 'inventory_list'});
      suppliers = {
        for (final v in r['items'] as List)
          if ('${(v as Map)['supplier'] ?? ''}'.trim().isNotEmpty)
            '${v['supplier']}'.trim(),
      }.toList();
    } catch (e) {
      if (mounted) AppToast.error(context, e);
      return;
    }
    if (!mounted) return;
    final s = await showSupplierPicker(
      context,
      suppliers: suppliers,
      current: supplier,
    );
    if (s != null) {
      setState(() => supplier = s);
      _touch();
    }
  }

  Future<void> _save() async {
    String? error;
    final safeValue = editing ? num.tryParse(safe.text.trim()) : 0;
    final costValue = editing ? p['cost'] : num.tryParse(cost.text.trim());
    if (name.text.trim().isEmpty) {
      error = '请填写商品名称';
    } else if (category == null) {
      error = '请选择分类';
    } else if (unit == null) {
      error = '请选择计量单位';
    } else if (safeValue == null || safeValue < 0) {
      error = '请填写正确的安全库存';
    } else if (costValue == null || costValue < 0) {
      error = '请填写参考成本价';
    }
    if (error != null) {
      AppToast.show(context, error);
      return;
    }
    setState(() => busy = true);
    try {
      final r = await merchantApi.invoke({
        'action': editing ? 'inventory_update' : 'inventory_create',
        'id': editing ? p['id'] : inventoryId(),
        'name': name.text.trim(),
        'specification': spec.text.trim(),
        'sku': sku.text.trim(),
        'category': _categoryToBackend[category],
        'unit': unit,
        'safe': safeValue,
        'location': location.text.trim(),
        'cost': costValue,
        'supplier': supplier,
      });
      inventoryChanged.value++;
      if (!mounted) return;
      dirty = false;
      Navigator.of(context).pop(Map<String, dynamic>.from(r['item'] as Map));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  // ───────── 控件（样式取自设计稿） ─────────
  Widget _card(String title, List<Widget> children) => hbox(
    bg: C.card,
    radius: BorderRadius.circular(24),
    shadow: softShadow,
    pad: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: ts(16, w: FontWeight.w500, h: 22)),
        for (final c in children) ...[const SizedBox(height: 14), c],
      ],
    ),
  );

  Widget _label(String text, {bool required = false}) => Text.rich(
    TextSpan(
      style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
      children: [
        TextSpan(text: text),
        if (required)
          TextSpan(
            text: ' *',
            style: ts(13, w: FontWeight.w500, color: C.red, h: 18),
          ),
      ],
    ),
  );

  Widget _foot(String text) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(text, style: ts(12, color: C.muted, h: 16)),
  );

  Widget _box({required Widget child, VoidCallback? onTap}) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: C.inset,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerLeft,
      child: child,
    ),
  );

  Widget _input(
    TextEditingController c,
    String hint, {
    String? suffix,
    TextInputType? keyboard,
    bool readOnly = false,
    VoidCallback? onTapReadOnly,
  }) => _box(
    onTap: readOnly ? onTapReadOnly : null,
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: c,
            readOnly: readOnly || busy,
            enabled: !readOnly,
            keyboardType: keyboard,
            onChanged: (_) => _touch(),
            style: ts(15, h: 22, color: readOnly ? C.sub : null),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: ts(15, color: C.muted, h: 22),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        if (suffix != null) Text(suffix, style: ts(14, color: C.muted, h: 20)),
      ],
    ),
  );

  Widget _field(
    String label,
    Widget input, {
    bool required = false,
    String? foot,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _label(label, required: required),
      const SizedBox(height: 8),
      input,
      if (foot != null) _foot(foot),
    ],
  );

  Widget _chips(
    List<String> items,
    String? selected,
    ValueChanged<String> onChanged,
    String semantic,
  ) => ChoiceChipGroup<String>(
    items: [for (final v in items) ChoiceChipItem(value: v, label: v)],
    selected: selected,
    onChanged: (v) {
      if (busy) return;
      onChanged(v);
      _touch();
    },
    kind: ChipKind.pill,
    runSpacing: 8,
    semanticLabel: semantic,
  );

  Widget _switchRow(String title, String sub, bool value, VoidCallback onTap) =>
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ts(15, w: FontWeight.w500, h: 20)),
                Text(sub, style: ts(12, color: C.muted, h: 16)),
              ],
            ),
          ),
          HSwitchValue(value: value, onChanged: (_) => onTap()),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final units = [
      ..._units,
      if (unit != null && !_units.contains(unit)) unit!,
    ];
    final unitLabel = unit ?? '';
    return ConfirmDiscard(
      dirty: dirty,
      busy: busy,
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
                    AppPageHeader(title: editing ? '编辑商品' : '新增商品'),
                    const SizedBox(height: 14),
                    _card('基本信息', [
                      _field(
                        '商品名称',
                        _input(name, '如：隐形车衣 TPU'),
                        required: true,
                      ),
                      _field('规格型号', _input(spec, '如：1.52m × 15m / 卷')),
                      _field(
                        'SKU 编码',
                        _input(sku, '不填则系统自动生成'),
                        foot: '盘点和扫码用，同一门店内不能重复',
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('分类', required: true),
                          const SizedBox(height: 8),
                          _chips(['贴膜', '镀晶', '清洁用品', '工具', '其他'], category, (
                            v,
                          ) {
                            if (v == '其他') {
                              // TODO: 后端分类固定为 洗护 / 镀晶 / 贴膜 / 配件，「其他」需要扩展分类后再开放。
                              AppToast.show(context, '「其他」分类暂未接通，请先选择其他分类');
                              return;
                            }
                            setState(() => category = v);
                          }, '分类'),
                        ],
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _card('单位与库存', [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('计量单位', required: true),
                          const SizedBox(height: 8),
                          _chips(
                            units,
                            unit,
                            (v) => setState(() => unit = v),
                            '计量单位',
                          ),
                        ],
                      ),
                      if (editing)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _field(
                                '安全库存',
                                _input(
                                  safe,
                                  '0',
                                  suffix: unitLabel,
                                  keyboard:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                                required: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _field('货位', _input(location, '如 A-02')),
                            ),
                          ],
                        ),
                      Text(
                        '库存低于安全库存时，会出现在「低库存」预警里',
                        style: ts(12, color: C.muted, h: 16),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _card('成本与供应商', [
                      _field(
                        '参考成本价',
                        _input(
                          cost,
                          '0.00',
                          suffix: '元 / $unitLabel',
                          keyboard: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          readOnly: editing,
                          onTapReadOnly: () =>
                              AppToast.show(context, '成本由每次入库的批次决定，这里不能直接修改'),
                        ),
                        required: true,
                        foot: '仅作入库时的默认值，实际成本以每次入库的批次为准',
                      ),
                      _field(
                        '默认供应商',
                        _box(
                          onTap: busy ? null : _pickSupplier,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  supplier.isEmpty ? '选择供应商' : supplier,
                                  style: ts(
                                    15,
                                    h: 22,
                                    color: supplier.isEmpty ? C.muted : C.ink,
                                  ),
                                ),
                              ),
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _card('保质期', [
                      // TODO: 保质期开关 / 临期提醒天数后端商品表没有对应字段，预期扩展 inventory_products；
                      // 目前只是页面上的状态，不会保存。
                      _switchRow(
                        '需要管理保质期',
                        '开启后入库时必须填写生产日期或到期日',
                        shelfLife,
                        () {
                          setState(() => shelfLife = !shelfLife);
                          _touch();
                        },
                      ),
                      if (editing && shelfLife)
                        _field(
                          '临期提醒',
                          _input(
                            expiryDays,
                            '30',
                            suffix: '天前',
                            keyboard: TextInputType.number,
                          ),
                          foot: '到期前多少天开始在首页和库存里提醒',
                        ),
                    ]),
                    if (editing) ...[
                      const SizedBox(height: 16),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            // TODO: 后端没有商品停用状态；需要云函数校验“库存不为 0 时不能停用”。
                            AppToast.show(context, '商品停用暂未接通'),
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: C.redSoft,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            '停用此商品',
                            style: ts(
                              15,
                              w: FontWeight.w500,
                              color: C.redInk,
                              h: 22,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(2, 10, 2, 0),
                        child: Text(
                          '停用后不能再入库出库，历史记录保留；库存不为 0 时不能停用',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: C.bg,
                border: Border(top: BorderSide(color: C.line)),
              ),
              padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
              child: Row(
                children: [
                  if (editing) ...[
                    Expanded(
                      child: LoadingButton(
                        label: '取消',
                        style: LoadingButtonStyle.secondary,
                        onPressed: busy
                            ? null
                            : () async => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: editing ? 2 : 1,
                    child: LoadingButton(
                      label: editing ? '保存修改' : '保存',
                      loadingLabel: '提交中…',
                      onPressed: _save,
                    ),
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
