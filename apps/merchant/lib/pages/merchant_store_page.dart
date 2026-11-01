import 'package:flutter/material.dart';

import '../backend/merchant_backend.dart';

class MerchantStorePage extends StatefulWidget {
  const MerchantStorePage({super.key});

  @override
  State<MerchantStorePage> createState() => _MerchantStorePageState();
}

class _MerchantStorePageState extends State<MerchantStorePage> {
  late Future<Map<String, dynamic>> store;

  @override
  void initState() {
    super.initState();
    store = load();
  }

  Future<Map<String, dynamic>> load() async {
    final id = await MerchantBackend.storeId();
    return MerchantBackend.client.from('stores').select().eq('id', id).single();
  }

  Future<void> edit(Map<String, dynamic> row) async {
    final name = TextEditingController(text: row['name'] as String?);
    final phone = TextEditingController(text: row['phone'] as String?);
    final address = TextEditingController(text: row['address'] as String?);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('编辑门店信息'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: '门店名称'),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: '门店电话'),
              ),
              TextField(
                controller: address,
                decoration: const InputDecoration(labelText: '地址'),
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
              if (name.text.trim().isEmpty) return;
              try {
                await MerchantBackend.client
                    .from('stores')
                    .update({
                      'name': name.text.trim(),
                      'phone': phone.text.trim(),
                      'address': address.text.trim(),
                    })
                    .eq('id', row['id'] as String);
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
    );
    name.dispose();
    phone.dispose();
    address.dispose();
    if (saved == true) setState(() => store = load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('门店信息')),
    body: FutureBuilder<Map<String, dynamic>>(
      future: store,
      builder: (context, snap) {
        if (!snap.hasData) {
          return Center(
            child: snap.hasError
                ? Text('加载失败：${snap.error}')
                : const CircularProgressIndicator(),
          );
        }
        final row = snap.data!;
        return ListView(
          children: [
            ListTile(
              title: const Text('门店名称'),
              subtitle: Text(row['name'] as String),
            ),
            ListTile(
              title: const Text('门店电话'),
              subtitle: Text(row['phone']?.toString() ?? '未填写'),
            ),
            ListTile(
              title: const Text('地址'),
              subtitle: Text(row['address']?.toString() ?? '未填写'),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: FilledButton(
                onPressed: () => edit(row),
                child: const Text('编辑门店'),
              ),
            ),
          ],
        );
      },
    ),
  );
}
