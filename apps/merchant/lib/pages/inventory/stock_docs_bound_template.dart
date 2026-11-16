// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, AppSegmented, ChipSurface, ChoiceItem, SegmentItem;

import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import 'inventory_management_controller.dart';

class StockDocsBoundTemplate extends StatelessWidget {
  const StockDocsBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      header: AppPageHeader(title: '库存单据', leadingEnabled: !c.busy),
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
}
