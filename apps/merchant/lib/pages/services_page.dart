import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/catalog_draft.dart';
import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/common.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<ServiceItem>? liveServices;
  final Map<ServiceItem, Map<String, dynamic>> liveRows = {};
  String? loadError;
  static const _keys = [null, '镀晶镀膜', '洗车', '贴膜', '内饰'];
  int cat = 0;

  @override
  void initState() {
    super.initState();
    if (merchantApi.hasSession) {
      CatalogDraft.changed.addListener(_load);
      _load();
    }
  }

  @override
  void dispose() {
    CatalogDraft.changed.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final rows = await merchantApi.list('services');
      if (!mounted) return;
      liveRows.clear();
      final items = <ServiceItem>[];
      for (final row in rows) {
        final item = ServiceItem(
          row['category']?.toString() ?? '其他',
          row['name']?.toString() ?? '',
          row['description']?.toString() ?? '',
          num.tryParse(row['price'].toString()) ?? 0,
          offline: row['active'] == false,
        );
        items.add(item);
        liveRows[item] = row;
      }
      setState(() {
        liveServices = items;
        loadError = null;
      });
    } catch (_) {
      if (mounted) setState(() => loadError = '服务项目加载失败，请稍后重试');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Anonymous widget tests keep the original design fixture. A signed-in
    // merchant must never see the sample data as if it were their own.
    final source =
        liveServices ?? (merchantApi.hasSession ? <ServiceItem>[] : services);
    final cats = [
      '全部 ${source.length}',
      for (final key in _keys.skip(1))
        '$key ${source.where((s) => s.category == key).length}',
    ];
    final list = source
        .where((s) => _keys[cat] == null || s.category == _keys[cat])
        .toList();
    final groups = <String, List<ServiceItem>>{};
    for (final s in list) {
      groups.putIfAbsent(s.category, () => []).add(s);
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              '服务项目与价格',
              trailing: Align(
                alignment: Alignment.centerRight,
                child: RoundBtn(
                  'add',
                  label: '新增项目',
                  onTap: () {
                    if (merchantApi.hasSession) CatalogDraft.begin('services');
                    openRoute(context, 'ServiceEdit');
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            ChipTabs(
              labels: cats,
              selected: cat,
              onChanged: (i) => setState(() => cat = i),
            ),
            Expanded(
              child: loadError != null
                  ? Center(child: Text(loadError!))
                  : ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      children: [
                        for (final e in groups.entries) ...[
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 10),
                            child: Text(
                              e.key,
                              style: ts(
                                13,
                                w: FontWeight.w500,
                                color: C.muted,
                                h: 18,
                              ),
                            ),
                          ),
                          AppCard(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Column(
                              children: [
                                for (var i = 0; i < e.value.length; i++) ...[
                                  _row(context, e.value[i]),
                                  if (i < e.value.length - 1)
                                    const Divider1(indent: 16),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, ServiceItem s) {
    final dim = s.offline;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (merchantApi.hasSession) {
          CatalogDraft.begin('services', liveRows[s]);
        }
        openRoute(context, 'ServiceEdit');
      },
      child: Opacity(
        opacity: dim ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.name,
                            style: ts(15, w: FontWeight.w500, h: 22),
                          ),
                        ),
                        if (s.tag.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Pill(
                            s.tag,
                            bg: dim ? C.chip : C.greenSoft,
                            fg: dim ? C.muted : C.greenInk,
                            size: 11,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(s.desc, style: ts(12, color: C.muted, h: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${money(s.price, digits: s.price % 1 == 0 ? 0 : 2)}',
                    style: ts(16, w: FontWeight.w600, h: 22, tabular: true),
                  ),
                  if (s.memberNote.isNotEmpty)
                    Text(s.memberNote, style: ts(11, color: C.amberInk, h: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
