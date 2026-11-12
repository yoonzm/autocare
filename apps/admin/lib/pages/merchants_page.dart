import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../ui.dart';
import 'merchant_detail_page.dart';

String expiryText(Merchant m) {
  if (m.daysLeft < 0) return '到期 ${m.expiry.month}.${m.expiry.day}';
  if (m.plan == PlanKind.trial) return '试用剩 ${m.daysLeft} 天';
  return '到期 ${dotted(m.expiry)}';
}

Tone statusTone(MStatus s) => switch (s) {
  MStatus.paid => Tone.ok,
  MStatus.trial => Tone.warn,
  MStatus.expired => Tone.bad,
};

class MerchantsPage extends StatefulWidget {
  const MerchantsPage({super.key});
  @override
  State<MerchantsPage> createState() => _MerchantsPageState();
}

class _MerchantsPageState extends State<MerchantsPage> {
  String keyword = '';
  int tab = 0;
  static const _filters = [null, MStatus.trial, MStatus.paid, MStatus.expired];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final kw = keyword.trim().toLowerCase();
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
          AppSearchBar(
            hint: '商家名 / 手机号',
            onChanged: (text) => setState(() => keyword = text),
          ),
          AppSegmented<int>(
            items: [
              for (final (i, f) in _filters.indexed)
                SegmentItem(
                  value: i,
                  label:
                      '${f?.label.replaceAll('中', '') ?? '全部'} ${store.byStatus(f).length}',
                ),
            ],
            selected: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('没有符合条件的商家')
          else
            AppListGroup(rows: [
              for (final m in list)
                AppListRow(leading: ToneTile(m.tone, Icons.storefront_outlined), title: m.name, subtitle: '${m.city} · ${expiryText(m)}', trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppStatusTag(
                        m.frozen ? '已冻结' : m.status.label,
                        tone: m.frozen ? Tone.bad : statusTone(m.status),
                      ),
                      const SizedBox(height: 4),
                      AppStatusTag(m.plan.label, tone: Tone.off),
                    ],
                  ), onTap: () => go(context, MerchantDetailPage(m))),
            ]),
        ],
      );
    },
  );
}
