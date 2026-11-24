// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, AppSegmented, ChipSurface, ChoiceItem, SegmentItem;

import '../../backend/merchant_api.dart';
import '../../backend/money_format.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import 'inventory_management_controller.dart';

class StockDocsBoundTemplate extends StatelessWidget {
  const StockDocsBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      header: AppPageHeader(
        title: '库存单据',
        leadingEnabled: !c.busy,
        trailing: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: c.busy ? null : () => _showWorkorderCosts(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Text(
              '工单成本',
              style: ts(14, w: FontWeight.w500, color: C.primaryInk),
            ),
          ),
        ),
      ),
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 130),
            child: hcol(
              [
                AppSegmented<int>(
                  selected: c.tab,
                  onChanged: (i) {
                    if (!c.busy) c.selectDocumentTab(i);
                  },
                  items: const [
                    SegmentItem(value: 0, label: '入库单'),
                    SegmentItem(value: 1, label: '出库单'),
                  ],
                ),
                AppChoiceGroup<int>(
                  surface: ChipSurface.onPage,
                  selected: c.status,
                  onChanged: c.selectDocumentStatus,
                  items: [
                    ChoiceItem(value: 0, label: '全部', enabled: !c.busy),
                    ChoiceItem(value: 1, label: '草稿', enabled: !c.busy),
                    ChoiceItem(
                      value: 2,
                      label: c.documentState,
                      enabled: !c.busy,
                    ),
                    ChoiceItem(value: 3, label: '已作废', enabled: !c.busy),
                  ],
                ),
                hcol(
                  [c.documentRows(context)],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 16,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [],
    );
  }

  Future<void> _showWorkorderCosts(BuildContext context) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: C.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scroll) => Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: C.stroke,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '工单领料成本汇总',
                        style: ts(18, w: FontWeight.w600, h: 24),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Text('关闭', style: ts(14, color: C.muted)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AsyncView<List<Map<String, dynamic>>>(
                  load: () async {
                    final r = await merchantApi.invoke({
                      'action': 'inventory_workorder_costs',
                    });
                    return [
                      for (final x in (r['items'] as List? ?? const []))
                        Map<String, dynamic>.from(x as Map),
                    ];
                  },
                  isEmpty: (items) => items.isEmpty,
                  skeleton: const Padding(
                    padding: EdgeInsets.all(20),
                    child: SkeletonList(count: 3),
                  ),
                  empty: (_) => const EmptyView(
                    title: '暂无工单领料成本',
                    message: '出库单关联工单并过账后，将在这里按工单汇总出库成本',
                    inline: true,
                  ),
                  builder: (_, items) => ListView.separated(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final row = items[i];
                      final docs = row['docs'] ?? 0;
                      final qty = row['total_qty'] ?? 0;
                      final cost = num.tryParse('${row['total_cost']}') ?? 0;
                      final lastAt = '${row['last_at'] ?? ''}';
                      final docItems = [
                        for (final d in (row['items'] as List? ?? const []))
                          Map<String, dynamic>.from(d as Map),
                      ];
                      return AppCard(
                        radius: 18,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${row['workorder'] ?? '工单'}',
                                    style: ts(15, w: FontWeight.w600, h: 22),
                                  ),
                                ),
                                Text(
                                  '¥${money(cost, digits: 2)}',
                                  style: ts(
                                    16,
                                    w: FontWeight.w700,
                                    color: C.primaryInk,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$docs 笔出库 · 共 $qty 件 · 最近 $lastAt',
                              style: ts(12, color: C.muted, h: 16),
                            ),
                            if (docItems.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  for (final d in docItems)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(ctx).pop();
                                        openRoute(
                                          context,
                                          'StockOutDetail',
                                          arguments: '${d['id']}',
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: C.inset,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${d['date']} · ¥${money(num.tryParse('${d['cost']}') ?? 0, digits: 2)}',
                                          style: ts(12, color: C.sub),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
