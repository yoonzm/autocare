import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StoreAddPage extends StatelessWidget {
  const StoreAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
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
                      to: 'StoreSwitch',
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '新增门店',
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
                                imgKey: 'StoreAdd_7',
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
                                imgKey: 'StoreAdd_8',
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
                                imgKey: 'StoreAdd_9',
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
                                imgKey: 'StoreAdd_10',
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
                                  child: Text.rich(
                                    TextSpan(
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '门店名称 ',
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
                                        TextSpan(
                                          text: '*',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                      ],
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
                                    hint: '如：驰光汽车美容 · 浦东店',
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
                                    hint: '请输入门店电话',
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
                                  child: Text.rich(
                                    TextSpan(
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                        lh: 20,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '门店地址 ',
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
                                        TextSpan(
                                          text: '*',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                      ],
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
                                      hint: '请选择或输入门店地址',
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
                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: hrow(
                    [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                        child: hsvg(
                          dk(context, Svgs.s456, Svgs.s457),
                          w: 20,
                          h: 20,
                        ),
                      ),
                      Flexible(
                        flex: 746,
                        child: Text(
                          '营业时间默认每天 09:00–20:00，工位默认洗车、美容、贴膜间各 1 个。创建后可在 我的 → 营业设置 → 营业时间与工位 中调整。',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 20,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.start,
                    gap: 10,
                  ),
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
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFE4E4E7),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF3A3A40),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hcol(
              [
                hTap(
                  context,
                  hbox(
                    h: 52,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(26),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: hBusy(
                        'StoreAdd>StoreSwitch',
                        Text(
                          '创建门店',
                          style: hts(
                            16,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        style: hts(
                          16,
                          Color(0xFFFFFFFF),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                        label: '提交中…',
                      ),
                    ),
                  ),
                  to: 'StoreSwitch',
                ),
                hLiveText(
                  (p) => '创建后仍停留在当前门店 · ${p.storeOffer}',
                  hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
          ),
        ),
      ],
    );
  }
}
