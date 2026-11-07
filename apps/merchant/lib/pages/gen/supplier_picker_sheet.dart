import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class SupplierPickerSheet extends StatelessWidget {
  const SupplierPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '选择供应商',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: hbox(
                  minH: 44,
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(24),
                  shadow: dk(
                    context,
                    [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 0),
                        blurRadius: 1,
                        spreadRadius: 0,
                      ),
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
                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: hrow(
                    [
                      hsvg(dk(context, Svgs.s418, Svgs.s419), w: 18, h: 18),
                      Flexible(
                        flex: 75,
                        child: Text(
                          '搜索供应商',
                          style: hts(
                            15,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 22,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 10,
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 8,
          ),
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(20),
            child: hcol(
              [
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '蓝盾膜业',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                            Text(
                              '联系人 刘经理 · 138****2201',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 2,
                        ),
                      ),
                      hbox(
                        w: 22,
                        h: 22,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(11),
                        child: hrow(
                          [
                            hbox(
                              w: 8,
                              h: 8,
                              bg: dk(
                                context,
                                Color(0xFFFFFFFF),
                                Color(0xFF18181B),
                              ),
                              radius: BorderRadius.circular(4),
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  h: 1,
                  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                  margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '速洁化工',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                            Text(
                              '联系人 黄先生 · 139****7788',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 2,
                        ),
                      ),
                      hbox(
                        w: 22,
                        h: 22,
                        radius: BorderRadius.circular(11),
                        border: Border(
                          top: BorderSide(color: Color(0xFFC7C7CC), width: 1.5),
                          right: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                          left: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  h: 1,
                  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                  margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '驭光配件',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                            Text(
                              '联系人 陈小姐 · 136****0419',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 16,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 2,
                        ),
                      ),
                      hbox(
                        w: 22,
                        h: 22,
                        radius: BorderRadius.circular(11),
                        border: Border(
                          top: BorderSide(color: Color(0xFFC7C7CC), width: 1.5),
                          right: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                          bottom: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                          left: BorderSide(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: hTap(
              context,
              Text(
                '+ 新增供应商',
                style: hts(
                  14,
                  dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                  w: FontWeight.w500,
                  lh: 20,
                ),
              ),
              to: 'SupplierEdit',
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: hTap(
                      context,
                      hbox(
                        h: 50,
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: Text(
                            '取消',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w500,
                              lh: 22,
                            ),
                          ),
                        ),
                      ),
                      to: 'StockIn',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: hTap(
                      context,
                      hbox(
                        h: 50,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(25),
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1,
                          child: Text(
                            '确定',
                            style: hts(
                              15,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                        ),
                      ),
                      to: 'StockIn',
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
