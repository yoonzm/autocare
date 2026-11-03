import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StoreEditPage extends StatelessWidget {
  const StoreEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 980,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: hcol(
              [
                hrow(
                  [
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
                          [hsvg(dk(context, Svgs.s71, Svgs.s72), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      to: 'StoreInfo',
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '编辑门店信息',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hTap(
                      context,
                      hbox(
                        h: 44,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(22),
                        pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                        child: Align(
                          alignment: Alignment(-1, 0),
                          widthFactor: 1,
                          child: Text(
                            '保存',
                            style: hts(
                              14,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ),
                      ),
                      to: 'StoreInfo',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '门店照片',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                          Text(
                            '第一张为封面 · 最多 9 张',
                            style: hts(
                              12,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                              lh: 16,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 0,
                      ),
                      hcol([
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: HImageSlot(
                                imgKey: 'StoreEdit_7',
                                radius: 14,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFE4E4E7),
                                      Color(0xFF3A3A40),
                                    ),
                                    radius: BorderRadius.circular(14),
                                    child: hstack(
                                      hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s366, Svgs.s367),
                                            w: 20,
                                            h: 20,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                      [
                                        Positioned(
                                          left: 6,
                                          bottom: 6,
                                          child: hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFF1F1F23),
                                            ),
                                            radius: BorderRadius.circular(8),
                                            pad: EdgeInsets.fromLTRB(
                                              6,
                                              0,
                                              6,
                                              0,
                                            ),
                                            child: Text(
                                              '封面',
                                              style: hts(
                                                10,
                                                Color(0xFFFFFFFF),
                                                w: FontWeight.w600,
                                                lh: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: HImageSlot(
                                imgKey: 'StoreEdit_8',
                                radius: 14,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFE4E4E7),
                                      Color(0xFF3A3A40),
                                    ),
                                    radius: BorderRadius.circular(14),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s366, Svgs.s367),
                                          w: 20,
                                          h: 20,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: HImageSlot(
                                imgKey: 'StoreEdit_9',
                                radius: 14,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFE4E4E7),
                                      Color(0xFF3A3A40),
                                    ),
                                    radius: BorderRadius.circular(14),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s366, Svgs.s367),
                                          w: 20,
                                          h: 20,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: HImageSlot(
                                imgKey: 'StoreEdit_10',
                                radius: 14,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(14),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFD4D4D8),
                                        width: 1.5,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3F3F46),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s368, Svgs.s369),
                                          w: 22,
                                          h: 22,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 8,
                          intrinsic: true,
                          min: false,
                        ),
                      ], gap: 8),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '基本信息',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
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
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        [
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '门店名称',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '请输入门店名称',
                                    value: '驰光汽车美容 · 徐汇店',
                                    align: TextAlign.right,
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '联系电话',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: HInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '请输入联系电话',
                                    value: '021-[门店电话]',
                                    keyboard: TextInputType.phone,
                                    align: TextAlign.right,
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '门店地址',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: hbox(
                                    minW: 0,
                                    child: HInput(
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                      hint: '请输入门店地址',
                                      value: '上海市徐汇区[详细地址]',
                                      align: TextAlign.right,
                                    ),
                                  ),
                                ),
                                hTap(
                                  context,
                                  hbox(
                                    w: 32,
                                    h: 32,
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(16),
                                    child: hrow(
                                      [
                                        hsvg(
                                          dk(context, Svgs.s370, Svgs.s371),
                                          w: 16,
                                          h: 16,
                                        ),
                                      ],
                                      main: MainAxisAlignment.center,
                                      cross: CrossAxisAlignment.center,
                                      gap: 0,
                                    ),
                                  ),
                                  label: '地图定位',
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
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '营业时间',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '一',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '一',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '二',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '二',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '三',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '三',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '四',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '四',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '五',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '五',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '六',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '六',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(12),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '日',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFFFFFF),
                                              Color(0xFF18181B),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    label: '日',
                                  ),
                                ),
                              ],
                              cross: CrossAxisAlignment.stretch,
                              gap: 6,
                              intrinsic: true,
                              min: false,
                            ),
                          ], gap: 6),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: HStrHolder(
                                  initial: '09:00',
                                  builder: (context, s1) => hTap(
                                    context,
                                    hbox(
                                      h: 48,
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: hcol(
                                        [
                                          Text(
                                            '开门',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 14,
                                            ),
                                          ),
                                          hStr(
                                            s1,
                                            hts(
                                              16,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 0,
                                        min: false,
                                      ),
                                    ),
                                    onTap: () =>
                                        hPick(context, 'time', '开门', s1),
                                  ),
                                ),
                              ),
                              hbox(
                                w: 12,
                                h: 2,
                                bg: Color(0xFFA1A1AA),
                                radius: BorderRadius.circular(1),
                              ),
                              Expanded(
                                flex: 1,
                                child: HStrHolder(
                                  initial: '20:00',
                                  builder: (context, s2) => hTap(
                                    context,
                                    hbox(
                                      h: 48,
                                      bg: dk(
                                        context,
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(14),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: hcol(
                                        [
                                          Text(
                                            '打烊',
                                            style: hts(
                                              11,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 14,
                                            ),
                                          ),
                                          hStr(
                                            s2,
                                            hts(
                                              16,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 22,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.stretch,
                                        gap: 0,
                                        min: false,
                                      ),
                                    ),
                                    onTap: () =>
                                        hPick(context, 'time', '打烊', s2),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '节假日照常营业',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '关闭后春节等假期暂停预约',
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
                                  gap: 0,
                                ),
                              ),
                              HSwitch(initial: true),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '工位设置',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
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
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        [
                          hbox(
                            h: 56,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 10,
                                  h: 10,
                                  bg: Color(0xFF0485F7),
                                  radius: BorderRadius.circular(5),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '洗车工位',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                HHolder(
                                  inits: [2],
                                  builder: (context, ctrls) {
                                    final c3 = ctrls[0];
                                    return HNumberStepper(
                                      ctrl: c3,
                                      step: 1,
                                      minus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFEEEEF0),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '−',
                                          style: hts(
                                            18,
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
                                      value: hbox(
                                        w: 32,
                                        align: Alignment.center,
                                        child: hCount(
                                          c3,
                                          hts(
                                            16,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                          ),
                                          0,
                                          '',
                                          false,
                                        ),
                                      ),
                                      plus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFF34343A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '+',
                                          style: hts(
                                            18,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 4,
                                    );
                                  },
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(38, 0, 0, 0),
                          ),
                          hbox(
                            h: 56,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 10,
                                  h: 10,
                                  bg: Color(0xFF17C964),
                                  radius: BorderRadius.circular(5),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '美容工位',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                HHolder(
                                  inits: [2],
                                  builder: (context, ctrls) {
                                    final c4 = ctrls[0];
                                    return HNumberStepper(
                                      ctrl: c4,
                                      step: 1,
                                      minus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFEEEEF0),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '−',
                                          style: hts(
                                            18,
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
                                      value: hbox(
                                        w: 32,
                                        align: Alignment.center,
                                        child: hCount(
                                          c4,
                                          hts(
                                            16,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                          ),
                                          0,
                                          '',
                                          false,
                                        ),
                                      ),
                                      plus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFF34343A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '+',
                                          style: hts(
                                            18,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 4,
                                    );
                                  },
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(38, 0, 0, 0),
                          ),
                          hbox(
                            h: 56,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 10,
                                  h: 10,
                                  bg: Color(0xFFF5A524),
                                  radius: BorderRadius.circular(5),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '贴膜间',
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                  ),
                                ),
                                HHolder(
                                  inits: [2],
                                  builder: (context, ctrls) {
                                    final c5 = ctrls[0];
                                    return HNumberStepper(
                                      ctrl: c5,
                                      step: 1,
                                      minus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFFEEEEF0),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '−',
                                          style: hts(
                                            18,
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
                                      value: hbox(
                                        w: 32,
                                        align: Alignment.center,
                                        child: hCount(
                                          c5,
                                          hts(
                                            16,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                          ),
                                          0,
                                          '',
                                          false,
                                        ),
                                      ),
                                      plus: hbox(
                                        w: 32,
                                        h: 32,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFF34343A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        align: Alignment.center,
                                        child: Text(
                                          '+',
                                          style: hts(
                                            18,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w500,
                                            lh: 18,
                                          ),
                                        ),
                                      ),
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 4,
                                    );
                                  },
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
                  ],
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
