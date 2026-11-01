import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'merchant_detail_page.dart';

String expiryText(Merchant m) {
  if (m.daysLeft < 0) return '到期 ${m.expiry.month}.${m.expiry.day}';
  if (m.plan == PlanKind.trial) return '试用剩 ${m.daysLeft} 天';
  return '到期 ${dotted(m.expiry)}';
}

(Color, Color) statusColors(MStatus s) => switch (s) {
  MStatus.paid => (C.greenInk, C.greenSoft),
  MStatus.trial => (C.amberInk, C.amberSoft),
  MStatus.expired => (C.redInk, C.redSoft),
};

class MerchantsPage extends StatefulWidget {
  const MerchantsPage({super.key});
  @override
  State<MerchantsPage> createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  final q = TextEditingController();
  int tab = 0;
  static const _filters = [null, MStatus.trial, MStatus.paid, MStatus.expired];

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final kw = q.text.trim().toLowerCase();
      final list = store.byStatus(_filters[tab]).where((m) {
        if (kw.isEmpty) return true;
        return m.name.toLowerCase().contains(kw) ||
            m.phone.contains(kw) ||
            m.city.contains(kw) ||
            m.owner.contains(kw);
      }).toList();
      return AdPage(
        title: '商家',
        back: false,
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: softShadow,
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, size: 20, color: C.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: q,
                    onChanged: (_) => setState(() {}),
                    style: ts(15, h: 22),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '商家名 / 手机号',
                      hintStyle: ts(15, color: C.faint, h: 22),
                    ),
                  ),
                ),
                if (q.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(q.clear),
                    child: const Icon(Icons.cancel_rounded, size: 18, color: C.faint),
                  ),
              ],
            ),
          ),
          Segmented(
            labels: [
              for (final f in _filters)
                '${f?.label.replaceAll('中', '') ?? '全部'} ${store.byStatus(f).length}',
            ],
            index: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('没有符合条件的商家')
          else
            RowGroup([
              for (final m in list)
                Row1(
                  leading: ToneTile(m.tone, Icons.storefront_outlined),
                  title: m.name,
                  sub: '${m.city} · ${expiryText(m)}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Pill(
                        m.frozen ? '已冻结' : m.status.label,
                        m.frozen ? C.redInk : statusColors(m.status).$1,
                        m.frozen ? C.redSoft : statusColors(m.status).$2,
                      ),
                      const SizedBox(height: 4),
                      Pill(m.plan.label, C.sub, C.chip),
                    ],
                  ),
                  onTap: () => go(context, MerchantDetailPage(m)),
                ),
            ]),
        ],
      );
    },
  );
}
