import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show ConfirmDiscard;
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/inventory_bindings.dart';

Future<Map<String, dynamic>?> selectInventorySupplier(BuildContext context) =>
    showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .6,
        child: const InventorySupplierPicker(),
      ),
    );

class InventorySupplierPicker extends StatefulWidget {
  const InventorySupplierPicker({super.key});
  @override
  State<InventorySupplierPicker> createState() => _SupplierPickerState();
}

class _SupplierPickerState extends State<InventorySupplierPicker> {
  final key = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  String search = '';
  Map<String, dynamic>? selected;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择供应商', style: ts(22, w: FontWeight.w600)),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: '搜索供应商',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (v) => setState(() => search = v),
        ),
        Expanded(
          child: AsyncView<List<Map<String, dynamic>>>(
            key: key,
            load: () async => maps(
              (await merchantApi.invoke({
                'action': 'inventory_suppliers',
              }))['items'],
            ),
            isEmpty: (_) => false,
            skeleton: const SkeletonList(count: 3),
            empty: (_) => const SizedBox.shrink(),
            builder: (context, rows) => ListView(
              children: [
                if (rows.isEmpty) EmptyView.firstTime(title: '还没有供应商'),
                for (final s in rows.where(
                  (s) => s['name'].toString().contains(search),
                ))
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text('${s['name']}'),
                      subtitle: Text('联系人 ${s['contact']} · ${s['phone']}'),
                      trailing: Icon(
                        selected?['id'] == s['id']
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: C.primary,
                      ),
                      onTap: () => setState(() => selected = s),
                    ),
                  ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final value = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (_) => const InventorySupplierEditor(),
              ),
            );
            if (value != null && mounted) {
              setState(() => selected = value);
              key.currentState?.reload();
            }
          },
          child: const Text('+ 新增供应商'),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ),
            Expanded(
              flex: 2,
              child: LoadingButton(
                label: '确定',
                disabledReason: '请选择供应商',
                onPressed: selected == null
                    ? null
                    : () async => Navigator.pop(context, selected),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    ),
  );
}

class InventorySupplierEditor extends StatefulWidget {
  const InventorySupplierEditor({super.key});
  @override
  State<InventorySupplierEditor> createState() => _SupplierEditorState();
}

class _SupplierEditorState extends State<InventorySupplierEditor> {
  final fields = <String, dynamic>{
    'id': inventoryId(),
    'name': '',
    'contact': '',
    'phone': '',
    'note': '',
  };
  bool busy = false, dirty = false;
  final form = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) => ConfirmDiscard(
    dirty: dirty,
    busy: busy,
    child: Scaffold(
      backgroundColor: C.bg,
      appBar: AppBar(title: const Text('新增供应商'), centerTitle: true),
      body: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                children: [
                  for (final e in {
                    'name': '供应商名称 *',
                    'contact': '联系人',
                    'phone': '联系电话',
                    'note': '备注',
                  }.entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextFormField(
                        enabled: !busy,
                        decoration: InputDecoration(
                          labelText: e.value,
                          hintText: e.key == 'name'
                              ? '如：蓝盾膜业'
                              : e.key == 'note'
                              ? '如结算周期、送货说明'
                              : '选填',
                          filled: true,
                        ),
                        validator: e.key == 'name'
                            ? (v) =>
                                  (v ?? '').trim().isEmpty ? '请填写供应商名称' : null
                            : null,
                        onChanged: (v) {
                          fields[e.key] = v;
                          setState(() => dirty = true);
                        },
                      ),
                    ),
                  Text('仅用于店内联系，不会通知对方', style: ts(12, color: C.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LoadingButton(
            label: '保存',
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              setState(() => busy = true);
              try {
                final result = await merchantApi.invoke({
                  ...fields,
                  'action': 'inventory_supplier_save',
                });
                dirty = false;
                if (context.mounted) {
                  Navigator.pop(
                    context,
                    Map<String, dynamic>.from(result['item']),
                  );
                }
              } finally {
                if (mounted) setState(() => busy = false);
              }
            },
          ),
        ),
      ),
    ),
  );
}
