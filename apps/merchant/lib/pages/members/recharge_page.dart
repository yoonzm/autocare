import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import '../../kit/buttons.dart';
import '../../kit/text_input.dart';
import '../../kit/single_selection.dart';
import 'wallet_controller.dart';
import 'wallet_page.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class RechargePage extends StatelessWidget {
  final WalletController? controller;
  const RechargePage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return const WalletPage(initial: 0);
    final m = c.memberView;
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1060,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: hcol(
              [
                hrow(
                  [
                    AppIconButton(
                      svg: dk(context, Svgs.s0, Svgs.s1),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '会员充值',
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
                AppSegmented<int>(
                  items: const [
                    SegmentItem(value: 0, label: '储值充值'),
                    SegmentItem(value: 1, label: '购买次卡'),
                  ],
                  selected: 0,
                  onChanged: c.selectTab,
                ),
                hcol(
                  [
                    hbox(
                      bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(28),
                      pad: EdgeInsets.fromLTRB(20, 18, 20, 18),
                      clip: true,
                      border: dk(
                        context,
                        null,
                        Border(
                          top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          bottom: BorderSide(
                            color: Color(0xFF2E2E33),
                            width: 1,
                          ),
                          left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                        ),
                      ),
                      child: hstack(
                        hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  w: 36,
                                  h: 36,
                                  bg: Color(0xFFF5D78E),
                                  radius: BorderRadius.circular(18),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    m.avatar,
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '${m.name} ',
                                          style: hts(
                                            15,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w500,
                                            lh: 22,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '· ${m.maskedPhone}',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 22,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: Color(0xFFF5D78E),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    m.levelMember,
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                AppButton(
                                  label: '更换',
                                  kind: AppButtonKind.text,
                                  size: AppButtonSize.medium,
                                  onPressed: () => c.chooseMember(context),
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
                                        '当前余额',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 16,
                                        ),
                                      ),
                                      Text(
                                        m.balanceText,
                                        style: hts(
                                          24,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 30,
                                          tab: true,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 6),
                                  child: hsvg(
                                    dk(context, Svgs.s325, Svgs.s326),
                                    w: 20,
                                    h: 20,
                                  ),
                                ),
                                hcol(
                                  [
                                    Text(
                                      '充值后',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFFA1A1AA),
                                          Color(0xFF80808A),
                                        ),
                                        lh: 16,
                                      ),
                                    ),
                                    Text(
                                      c.afterText,
                                      style: hts(
                                        24,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 30,
                                        tab: true,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.end,
                                  gap: 2,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 14,
                        ),
                        [],
                        behind: [
                          Positioned(
                            right: -100,
                            bottom: -128,
                            child: hsvg(Svgs.s323, w: 220, h: 220),
                          ),
                        ],
                      ),
                    ),
                    SingleSelection(
                      index: c.presetIndex,
                      onChanged: c.selectPreset,
                      builder: (context, selection) => hcol([
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: selection,
                                index: 0,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(0),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(0),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                                off: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
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
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(0),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(0),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: selection,
                                index: 1,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hstack(
                                    hcol(
                                      [
                                        Text(
                                          c.amountLabel(1),
                                          style: hts(
                                            20,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 28,
                                          ),
                                        ),
                                        Text(
                                          c.giftLabel(1),
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 16,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 4,
                                    ),
                                    [
                                      Positioned(
                                        top: -22,
                                        right: -4,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFF1F1F23),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: Text(
                                            '最多人选',
                                            style: hts(
                                              11,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                off: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
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
                                  child: hstack(
                                    hcol(
                                      [
                                        Text(
                                          c.amountLabel(1),
                                          style: hts(
                                            20,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 28,
                                          ),
                                        ),
                                        Text(
                                          c.giftLabel(1),
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFF2B7745),
                                              Color(0xFF5FD48C),
                                            ),
                                            w: FontWeight.w500,
                                            lh: 16,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 4,
                                    ),
                                    [
                                      Positioned(
                                        top: -22,
                                        right: -4,
                                        child: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFF1F1F23),
                                          ),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: Text(
                                            '最多人选',
                                            style: hts(
                                              11,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 18,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: selection,
                                index: 2,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(2),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(2),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                                off: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
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
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(2),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(2),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: HSel(
                                ctrl: selection,
                                index: 3,
                                on: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFF3F9FF),
                                    Color.fromRGBO(4, 133, 247, 0.1),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xFF0485F7),
                                    width: 2,
                                  ),
                                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(3),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(3),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                                off: hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(20),
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
                                  child: hcol(
                                    [
                                      Text(
                                        c.amountLabel(3),
                                        style: hts(
                                          20,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 28,
                                        ),
                                      ),
                                      Text(
                                        c.giftLabel(3),
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFF2B7745),
                                            Color(0xFF5FD48C),
                                          ),
                                          w: FontWeight.w500,
                                          lh: 16,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                        hrow(
                          [
                            Expanded(
                              flex: 2,
                              child: hbox(
                                h: 52,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(20),
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
                                    Text(
                                      '自定义金额',
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
                                    Expanded(
                                      child: AppTextInput(
                                        controller: c.custom,
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 20,
                                        ),
                                        hint: '输入金额，不享赠送',
                                        keyboard:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        align: TextAlign.right,
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
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
                          min: false,
                        ),
                      ], gap: 10),
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
                          Text(
                            '收款方式',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          SingleSelection(
                            index: c.method,
                            onChanged: c.selectMethod,
                            builder: (context, selection) => hcol([
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: selection,
                                      index: 0,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s327, Svgs.s328),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '微信',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFFFAFAFA),
                                                  Color(0xFF18181B),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s328, Svgs.s327),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '微信',
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
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: selection,
                                      index: 1,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s330, Svgs.s329),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '支付宝',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFFFAFAFA),
                                                  Color(0xFF18181B),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s329, Svgs.s330),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '支付宝',
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
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: selection,
                                      index: 2,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s332, Svgs.s331),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '现金',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFFFAFAFA),
                                                  Color(0xFF18181B),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s331, Svgs.s332),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              '现金',
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
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: HSel(
                                      ctrl: selection,
                                      index: 3,
                                      on: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s334, Svgs.s333),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              'POS 刷卡',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFFFAFAFA),
                                                  Color(0xFF18181B),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
                                        ),
                                      ),
                                      off: hbox(
                                        h: 64,
                                        bg: dk(
                                          context,
                                          Color(0xFFF4F4F5),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(16),
                                        child: hcol(
                                          [
                                            hsvg(
                                              dk(context, Svgs.s333, Svgs.s334),
                                              w: 20,
                                              h: 20,
                                            ),
                                            Text(
                                              'POS 刷卡',
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
                                          ],
                                          main: MainAxisAlignment.center,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                          min: false,
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
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '经办人',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                              hLiveText(
                                (p) => p.live ? p.operatorText : '—',
                                hts(
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
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
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.04),
                  offset: Offset(0, -8),
                  blurRadius: 24,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0xFFE8E8EA),
                  offset: Offset(0, -1),
                  blurRadius: 0,
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
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        c.payLine,
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 16,
                        ),
                      ),
                      Text(
                        c.amountText,
                        style: hts(
                          24,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 30,
                          ls: -0.48,
                          tab: true,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                  ),
                ),
                ActionButton(
                  actionKey: c.actionKey,
                  label: '确认收款',
                  kind: AppButtonKind.primary,
                  size: AppButtonSize.large,
                  expanded: false,
                  onPressed: () => c.submit(context, sale: false),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
        ),
      ],
    );
  }
}
