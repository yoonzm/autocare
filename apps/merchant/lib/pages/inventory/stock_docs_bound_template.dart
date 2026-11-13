import '../../kit/buttons.dart';

// 正式维护源码；保留既有视觉布局。
import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'inventory_management_controller.dart';
import '../../resources/merchant_svgs.dart';

class StockDocsBoundTemplate extends StatelessWidget {
  const StockDocsBoundTemplate({super.key, required this.c});
  final InventoryManagementController c;

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
            child: hcol(
              [
                hrow(
                  [
                    AppIconButton(
                      svg: dk(context, Svgs.s0, Svgs.s1),
                      semanticLabel: "返回",
                      onPressed: c.busy
                          ? null
                          : () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '库存单据',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 44),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.busy ? null : () => c.selectDocumentTab(0),
                            child: hbox(
                              h: 32,
                              bg: c.documentTabBackground(0),
                              radius: BorderRadius.circular(16),
                              shadow: dk(
                                context,
                                [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                [
                                  BoxShadow(
                                    color: Color(0xFF26262B),
                                    offset: Offset(0, 0),
                                    blurRadius: 0,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  '入库单',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.busy ? null : () => c.selectDocumentTab(1),
                            child: hbox(
                              h: 32,
                              radius: BorderRadius.circular(16),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  '出库单',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: UnconstrainedBox(
                          alignment: Alignment.topLeft,
                          constrainedAxis: Axis.horizontal,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: c.busy ? null : () => c.selectDocumentTab(2),
                            child: hbox(
                              h: 32,
                              radius: BorderRadius.circular(16),
                              child: Align(
                                alignment: Alignment(0, 0),
                                widthFactor: 1,
                                child: Text(
                                  '盘点单',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                    intrinsic: true,
                  ),
                ),
                hbox(
                  clip: true,
                  child: hrow(
                    [
                      UnconstrainedBox(
                        alignment: Alignment.topLeft,
                        constrainedAxis: Axis.horizontal,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: c.busy
                              ? null
                              : () => c.selectDocumentStatus(0),
                          child: hbox(
                            h: 34,
                            bg: c.documentStatusBackground(0),
                            radius: BorderRadius.circular(17),
                            border: Border.all(
                              color: Color(0xFF0485F7),
                              width: 1.5,
                            ),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Align(
                              alignment: Alignment(-1, 0),
                              widthFactor: 1,
                              child: Text(
                                '全部',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      UnconstrainedBox(
                        alignment: Alignment.topLeft,
                        constrainedAxis: Axis.horizontal,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: c.busy
                              ? null
                              : () => c.selectDocumentStatus(1),
                          child: hbox(
                            h: 34,
                            bg: c.documentStatusBackground(1),
                            radius: BorderRadius.circular(17),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Align(
                              alignment: Alignment(-1, 0),
                              widthFactor: 1,
                              child: Text(
                                '草稿',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF3F3F46),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      UnconstrainedBox(
                        alignment: Alignment.topLeft,
                        constrainedAxis: Axis.horizontal,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: c.busy
                              ? null
                              : () => c.selectDocumentStatus(2),
                          child: hbox(
                            h: 34,
                            bg: c.documentStatusBackground(2),
                            radius: BorderRadius.circular(17),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Align(
                              alignment: Alignment(-1, 0),
                              widthFactor: 1,
                              child: Text(
                                c.documentState,
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF3F3F46),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      UnconstrainedBox(
                        alignment: Alignment.topLeft,
                        constrainedAxis: Axis.horizontal,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: c.busy
                              ? null
                              : () => c.selectDocumentStatus(3),
                          child: hbox(
                            h: 34,
                            bg: c.documentStatusBackground(3),
                            radius: BorderRadius.circular(17),
                            pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                            child: Align(
                              alignment: Alignment(-1, 0),
                              widthFactor: 1,
                              child: Text(
                                '已作废',
                                style: hts(
                                  13,
                                  dk(
                                    context,
                                    Color(0xFF3F3F46),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                    intrinsic: true,
                  ),
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
