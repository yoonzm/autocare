import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ProductPickerSheet extends StatelessWidget {
  const ProductPickerSheet({super.key});

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
            '选择商品',
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
                        flex: 133,
                        child: Text(
                          '搜索商品名称 / SKU',
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
              hTap(
                context,
                hbox(
                  w: 44,
                  h: 44,
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(22),
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
                  child: hrow(
                    [hsvg(dk(context, Svgs.s329, Svgs.s330), w: 20, h: 20)],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                to: 'ScanProduct',
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 8,
          ),
          hbox(
            clip: true,
            child: HSelHolder(
              groups: [
                ({1}, false),
              ],
              builder: (context, g1) => hrow(
                [
                  UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: HSel(
                      ctrl: g1[0],
                      index: 0,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '全部',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '全部',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
                    child: HSel(
                      ctrl: g1[0],
                      index: 1,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '贴膜',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '贴膜',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
                    child: HSel(
                      ctrl: g1[0],
                      index: 2,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '镀晶',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '镀晶',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
                    child: HSel(
                      ctrl: g1[0],
                      index: 3,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '清洁用品',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '清洁用品',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
                    child: HSel(
                      ctrl: g1[0],
                      index: 4,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '工具',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '工具',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
          ),
          hbox(
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
            radius: BorderRadius.circular(20),
            border: dk(
              context,
              Border.all(color: Color(0xFFEFEFF1), width: 1),
              Border.all(color: Color(0xFF2A2A2E), width: 1),
            ),
            clip: true,
            child: hcol(
              [
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
                      hbox(
                        w: 22,
                        h: 22,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(11),
                        child: hrow(
                          [hsvg(Svgs.s11, w: 13, h: 13)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 128,
                                    child: Text(
                                      '隐形车衣 TPU 1.52m',
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
                                  ),
                                  Flexible(
                                    flex: 49,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(9),
                                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Text(
                                        '低库存',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA43433),
                                            Color(0xFFFF7B7E),
                                          ),
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
                                '1.52m × 15m / 卷 · 库存 3 卷',
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
                  margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
                      hbox(
                        w: 22,
                        h: 22,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(11),
                        child: hrow(
                          [hsvg(Svgs.s11, w: 13, h: 13)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 88,
                                    child: Text(
                                      '改色膜 哑光黑',
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
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '1.52m × 18m / 卷 · 库存 5 卷',
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
                  margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
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
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 88,
                                    child: Text(
                                      '窗膜 前挡 70%',
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
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '1.52m × 30m / 卷 · 库存 12 卷',
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
                  margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
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
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 88,
                                    child: Text(
                                      '窗膜 侧后 35%',
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
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '1.52m × 30m / 卷 · 库存 9 卷',
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
                  margin: EdgeInsets.fromLTRB(50, 0, 0, 0),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: hrow(
                    [
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
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 70,
                                    child: Text(
                                      '大灯保护膜',
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
                                  ),
                                  Flexible(
                                    flex: 49,
                                    child: hbox(
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(9),
                                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Text(
                                        '低库存',
                                        style: hts(
                                          11,
                                          dk(
                                            context,
                                            Color(0xFFA43433),
                                            Color(0xFFFF7B7E),
                                          ),
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
                                '30cm × 10m / 卷 · 库存 2 卷',
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
                '找不到？新增商品',
                style: hts(
                  14,
                  dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                  w: FontWeight.w500,
                  lh: 20,
                ),
              ),
              to: 'ProductEdit',
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
                            '确定 · 添加 2 件',
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
