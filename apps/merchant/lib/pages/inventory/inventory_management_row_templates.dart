// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';

class InventoryCategoryRowTemplate extends StatelessWidget {
  final InventoryManagementController c;
  final Map<String, dynamic> row;
  const InventoryCategoryRowTemplate({
    super.key,
    required this.c,
    required this.row,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.categoryName(row),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                lh: 20,
              ),
            ),
            Text(
              c.categoryCount(row),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 16,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 1,
        ),
      ),
      c.categoryAction(
        context,
        row,
        Text(
          '重命名',
          style: hts(
            13,
            dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
            w: FontWeight.w500,
          ),
        ),
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.center,
    gap: 12,
  );
}

class InventoryDocumentRowTemplate extends StatelessWidget {
  final InventoryManagementController c;
  final Map<String, dynamic> row;
  const InventoryDocumentRowTemplate({
    super.key,
    required this.c,
    required this.row,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: c.busy ? null : () => c.openDocument(context, row),
    child: hbox(
      pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: hrow(
        [
          Expanded(
            flex: 1,
            child: hcol(
              [
                hrow(
                  [
                    Flexible(
                      flex: 111,
                      child: Text(
                        c.code(row),
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 20,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 49,
                      child: hbox(
                        bg: dk(
                          context,
                          Color(0xFFDDF6E7),
                          Color.fromRGBO(23, 201, 100, 0.16),
                        ),
                        radius: BorderRadius.circular(9),
                        pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                        child: Text(
                          c.state(row),
                          style: hts(
                            11,
                            dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
                            w: FontWeight.w600,
                            lh: 18,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 6,
                ),
                Text(
                  c.documentRowSummary(row),
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 2,
            ),
          ),
          Text(
            c.documentRowTotal(row),
            style: hts(
              15,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 22,
              tab: true,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    ),
  );
}

class StockInDetailLineBoundTemplate extends StatelessWidget {
  final InventoryManagementController c;
  final Map<String, dynamic> row;
  const StockInDetailLineBoundTemplate({
    super.key,
    required this.c,
    required this.row,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.itemName(row),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.itemBatch(row),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 17,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 0,
        ),
      ),
      Text(
        c.itemQuantity(row),
        style: hts(
          14,
          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
          w: FontWeight.w500,
          lh: 20,
          tab: true,
        ),
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.start,
    gap: 12,
  );
}

class StockOutDetailLineBoundTemplate extends StatelessWidget {
  final InventoryManagementController c;
  final Map<String, dynamic> row;
  const StockOutDetailLineBoundTemplate({
    super.key,
    required this.c,
    required this.row,
  });
  @override
  Widget build(BuildContext context) => hrow(
    [
      Expanded(
        flex: 1,
        child: hcol(
          [
            Text(
              c.itemName(row),
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w500,
                lh: 20,
              ),
            ),
            Text(
              c.itemBatch(row),
              style: hts(
                12,
                dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 17,
              ),
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 0,
        ),
      ),
      Text(
        c.itemQuantity(row),
        style: hts(
          14,
          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
          w: FontWeight.w500,
          lh: 20,
          tab: true,
        ),
      ),
    ],
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.start,
    gap: 12,
  );
}
