import 'package:flutter/material.dart';

import '../backend/merchant_backend.dart';
import '../theme.dart';

/// The live Supabase-backed merchant foundation; legacy prototype screens stay
/// untouched until their individual workflows are migrated.
class MerchantCatalogPage extends StatefulWidget {
  final String kind;
  const MerchantCatalogPage(this.kind, {super.key});

  @override
  State<MerchantCatalogPage> createState() => _MerchantCatalogPageState();
}

class _MerchantCatalogPageState extends State<MerchantCatalogPage> {
  late Future<List<Map<String, dynamic>>> rows;
  String get table => switch (widget.kind) {
    'services' => 'service_items',
    'cards' => 'card_types',
    _ => 'members',
  };
  String get title => switch (widget.kind) {
    'services' => '服务项目与价格',
    'cards' => '会员卡种与权益',
    _ => '会员',
  };

  @override
  void initState() {
    super.initState();
    rows = MerchantBackend.list(table);
  }

  void refresh() => setState(() => rows = MerchantBackend.list(table));

  Future<void> edit([Map<String, dynamic>? row]) async {
    final name = TextEditingController(text: row?['name']?.toString() ?? '');
    final phone = TextEditingController(text: row?['phone']?.toString() ?? '');
    final extra = TextEditingController(
      text: switch (widget.kind) {
        'services' => row?['category']?.toString() ?? '',
        'cards' => row?['description']?.toString() ?? '',
        _ => row?['plate_number']?.toString() ?? '',
      },
    );
    final price = TextEditingController(
      text: switch (widget.kind) {
        'services' => row?['price']?.toString() ?? '',
        'cards' => row?['discount']?.toString() ?? '1',
        _ => '',
      },
    );
    String? selectedCard = row?['card_type_id'] as String?;
    List<Map<String, dynamic>> cards = [];
    if (widget.kind == 'members') {
      try {
        cards = await MerchantBackend.list('card_types');
      } catch (_) {}
    }
    if (!mounted) return;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialog) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(row == null ? '新增$title' : '编辑$title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                if (widget.kind == 'members')
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: '手机号'),
                  ),
                TextField(
                  controller: extra,
                  decoration: InputDecoration(
                    labelText: switch (widget.kind) {
                      'services' => '分类',
                      'cards' => '权益说明',
                      _ => '车牌号',
                    },
                  ),
                ),
                if (widget.kind != 'members')
                  TextField(
                    controller: price,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: widget.kind == 'cards' ? '折扣系数（0～1）' : '价格（元）',
                    ),
                  ),
                if (widget.kind == 'members')
                  DropdownButtonFormField<String?>(
                    initialValue: selectedCard,
                    decoration: const InputDecoration(labelText: '会员卡种'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('无'),
                      ),
                      for (final card in cards)
                        DropdownMenuItem<String?>(
                          value: card['id'] as String,
                          child: Text(card['name'] as String),
                        ),
                    ],
                    onChanged: (value) => setDialog(() => selectedCard = value),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty ||
                    (widget.kind == 'members' && phone.text.trim().isEmpty)) {
                  return;
                }
                final number = double.tryParse(price.text.trim());
                if (widget.kind == 'services' &&
                    (number == null || number < 0)) {
                  return;
                }
                if (widget.kind == 'cards' &&
                    (number == null || number <= 0 || number > 1)) {
                  return;
                }
                final values = switch (widget.kind) {
                  'services' => <String, dynamic>{
                    'name': name.text.trim(),
                    'category': extra.text.trim().isEmpty
                        ? '其他'
                        : extra.text.trim(),
                    'price': number,
                  },
                  'cards' => <String, dynamic>{
                    'name': name.text.trim(),
                    'description': extra.text.trim(),
                    'discount': number,
                  },
                  _ => <String, dynamic>{
                    'name': name.text.trim(),
                    'phone': phone.text.trim(),
                    'plate_number': extra.text.trim(),
                    'card_type_id': selectedCard,
                  },
                };
                try {
                  await MerchantBackend.save(
                    table,
                    values,
                    id: row?['id'] as String?,
                  );
                  if (dialog.mounted) {
                    Navigator.pop(dialog, true);
                  }
                } catch (e) {
                  if (dialog.mounted) {
                    ScaffoldMessenger.of(dialog)
                        .showSnackBar(SnackBar(content: Text('保存失败：$e')));
                  }
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    phone.dispose();
    extra.dispose();
    price.dispose();
    if (saved == true) {
      refresh();
    }
  }

  Future<void> remove(Map<String, dynamic> row) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('确认删除？'),
        content: Text(row['name'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (yes != true) {
      return;
    }
    try {
      await MerchantBackend.delete(table, row['id'] as String);
      refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('删除失败：$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => edit(),
      icon: const Icon(Icons.add),
      label: const Text('新增'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: rows,
      builder: (context, snap) {
        if (!snap.hasData) {
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('加载失败：${snap.error}', textAlign: TextAlign.center),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        final data = snap.data!;
        if (data.isEmpty) {
          return Center(
            child: Text('暂无$title，点击右下角新增', style: ts(14, color: C.muted)),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            refresh();
            await rows;
          },
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
            itemCount: data.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final row = data[i];
              final subtitle = switch (widget.kind) {
                'services' => '${row['category']} · ¥${row['price']}',
                'cards' =>
                  '${row['description']} · ${((num.tryParse(row['discount'].toString()) ?? 1) * 10).toStringAsFixed(1)} 折',
                _ => '${row['phone']}  ${row['plate_number'] ?? ''}',
              };
              return ListTile(
                title: Text(row['name'] as String),
                subtitle: Text(subtitle),
                onTap: () => edit(row),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除',
                  onPressed: () => remove(row),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
