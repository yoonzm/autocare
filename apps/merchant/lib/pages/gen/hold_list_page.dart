import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class HoldListPage extends StatelessWidget {
  const HoldListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1370,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: HSelHolder(
              groups: [
                ({0}, false),
              ],
              builder: (context, g1) => HDyn(
                texts: [
                  '王王建国黑金沪A·8K29M施工中镀晶养护 · 内饰精洗¥1,422.00老周 · 3 号工位 · 14:02 挂单 · 预计 17:00 完工备注：客户去开会，17:00 取车取单结算加项',
                  '赵赵先生金卡沪AD·61207施工中全车隐形车衣¥18,800.00张师傅 · 贴膜间 · 预计 明天 18:00 · 昨天 16:20 挂单取单结算加项',
                  '李李女士金卡沪B·2C519待结算全车精洗 · 打蜡¥880.00小陈 · 已完工，等待 25 分钟 · 14:16 挂单取单结算提醒取车',
                  '客散客非会员苏K·5F218待施工基础洗车 · 轮毂清洁¥98.00预约 15:30 到店 · 13:40 挂单取单结算加项',
                ],
                filter: g1[0],
                labels: ['全部', '待施工', '施工中', '待结算'],
                builder: (context, d2) => hcol(
                  [
                    hrow(
                      [
                        hTap(
                          context,
                          hbox(
                            w: 44,
                            h: 44,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                              [
                                hsvg(
                                  dk(context, Svgs.s0, Svgs.s1),
                                  w: 20,
                                  h: 20,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          back: true,
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '挂单',
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
                      bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(28),
                      pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
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
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '挂单待收款',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 18,
                                        ),
                                      ),
                                      hrow(
                                        [
                                          Flexible(
                                            flex: 200,
                                            child: Text(
                                              '¥21,200.00',
                                              style: hts(
                                                36,
                                                Color(0xFFFAFAFA),
                                                w: FontWeight.w600,
                                                lh: 44,
                                                tab: true,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 45,
                                            child: Text(
                                              '共 4 单',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFFA1A1AA),
                                                  Color(0xFF80808A),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.baseline,
                                        gap: 8,
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 4,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 0,
                            ),
                            hbox(
                              bg: Color(0xFF27272A),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(14, 10, 10, 10),
                              child: hrow(
                                [
                                  hrow(
                                    [hsvg(Svgs.s162, w: 18, h: 18)],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.start,
                                    gap: 0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hbox(
                                      minW: 0,
                                      child: Text(
                                        '1 单已完工，等待超 20 分钟',
                                        style: hts(
                                          13,
                                          Color(0xFFF5D78E),
                                          lh: 18,
                                        ),
                                        softWrap: false,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  hTap(
                                    context,
                                    hbox(
                                      h: 30,
                                      bg: Color(0xFFF5D78E),
                                      radius: BorderRadius.circular(15),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '提醒取车',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 18,
                                          ),
                                          softWrap: false,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                    label: '提醒取车',
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 14,
                        ),
                        [],
                        behind: [
                          Positioned(
                            top: -90,
                            right: -90,
                            child: hsvg(
                              dk(context, Svgs.s7, Svgs.s8),
                              w: 240,
                              h: 240,
                            ),
                          ),
                        ],
                      ),
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
                              child: HSel(
                                ctrl: g1[0],
                                index: 0,
                                on: hbox(
                                  h: 32,
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
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
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '全部 4',
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
                                off: hbox(
                                  h: 32,
                                  bg: dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '全部 4',
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
                              child: HSel(
                                ctrl: g1[0],
                                index: 1,
                                on: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  shadow: dk(context, [
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
                                  ], null),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '待施工 1',
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
                                off: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '待施工 1',
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
                              child: HSel(
                                ctrl: g1[0],
                                index: 2,
                                on: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  shadow: dk(context, [
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
                                  ], null),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '施工中 2',
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
                                off: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '施工中 2',
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
                              child: HSel(
                                ctrl: g1[0],
                                index: 3,
                                on: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  shadow: dk(context, [
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
                                  ], null),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '待结算 1',
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
                                off: hbox(
                                  h: 32,
                                  radius: BorderRadius.circular(16),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '待结算 1',
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
                    ...d2.vis([
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
                                hbox(
                                  w: 40,
                                  h: 40,
                                  bg: dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFF34343A),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '王',
                                    style: hts(
                                      16,
                                      Color(0xFFF5D78E),
                                      w: FontWeight.w600,
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
                                              flex: 45,
                                              child: Text(
                                                '王建国',
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
                                            Flexible(
                                              flex: 38,
                                              child: hbox(
                                                bg: dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFF34343A),
                                                ),
                                                radius: BorderRadius.circular(
                                                  9,
                                                ),
                                                pad: EdgeInsets.fromLTRB(
                                                  8,
                                                  0,
                                                  8,
                                                  0,
                                                ),
                                                child: Text(
                                                  '黑金',
                                                  style: hts(
                                                    11,
                                                    Color(0xFFF5D78E),
                                                    w: FontWeight.w600,
                                                    lh: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hbox(
                                            bg: Color(0xFF0B5FD6),
                                            radius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Color(0xFF5B9BF0),
                                              width: 1.5,
                                            ),
                                            pad: EdgeInsets.fromLTRB(
                                              5,
                                              1,
                                              5,
                                              1,
                                            ),
                                            child: Text(
                                              '沪A·8K29M',
                                              style: hts(
                                                11,
                                                Color(0xFFFFFFFF),
                                                w: FontWeight.w600,
                                                lh: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 3,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '施工中',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
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
                                  child: Text(
                                    '镀晶养护 · 内饰精洗',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥1,422.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    tab: true,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                            hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s163, Svgs.s164),
                                  w: 14,
                                  h: 14,
                                ),
                                Flexible(
                                  flex: 261,
                                  child: Text(
                                    '老周 · 3 号工位 · 14:02 挂单 · 预计 17:00 完工',
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
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                            hbox(
                              bg: dk(
                                context,
                                Color(0xFFFDF8EC),
                                Color.fromRGBO(245, 165, 36, 0.1),
                              ),
                              radius: BorderRadius.circular(12),
                              pad: EdgeInsets.fromLTRB(12, 8, 12, 8),
                              child: Text(
                                '备注：客户去开会，17:00 取车',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
                                  lh: 18,
                                ),
                              ),
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 42,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(21),
                                        child: Align(
                                          alignment: Alignment(0, 0),
                                          widthFactor: 1,
                                          child: Text(
                                            '取单结算',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFFFFFFFF),
                                                Color(0xFF18181B),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      to: 'Order',
                                    ),
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                                      child: Align(
                                        alignment: Alignment(0, 0),
                                        widthFactor: 1,
                                        child: Text(
                                          '加项',
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
                                    ),
                                    to: 'Order',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 42,
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s165, Svgs.s166),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    onTap: () => d2.confirmRemove(context, 0),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
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
                            hrow(
                              [
                                hbox(
                                  w: 40,
                                  h: 40,
                                  bg: Color(0xFFF3E2B3),
                                  radius: BorderRadius.circular(20),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '赵',
                                    style: hts(
                                      16,
                                      Color(0xFF3D2B0E),
                                      w: FontWeight.w600,
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
                                              flex: 45,
                                              child: Text(
                                                '赵先生',
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
                                            Flexible(
                                              flex: 38,
                                              child: hbox(
                                                bg: Color(0xFFF5D78E),
                                                radius: BorderRadius.circular(
                                                  9,
                                                ),
                                                pad: EdgeInsets.fromLTRB(
                                                  8,
                                                  0,
                                                  8,
                                                  0,
                                                ),
                                                child: Text(
                                                  '金卡',
                                                  style: hts(
                                                    11,
                                                    dk(
                                                      context,
                                                      Color(0xFF18181B),
                                                      Color(0xFFFAFAFA),
                                                    ),
                                                    w: FontWeight.w600,
                                                    lh: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hbox(
                                            bg: Color(0xFFD7F5E1),
                                            radius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Color(0xFF86D9A4),
                                              width: 1.5,
                                            ),
                                            pad: EdgeInsets.fromLTRB(
                                              5,
                                              1,
                                              5,
                                              1,
                                            ),
                                            child: Text(
                                              '沪AD·61207',
                                              style: hts(
                                                11,
                                                Color(0xFF14532D),
                                                w: FontWeight.w600,
                                                lh: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 3,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '施工中',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
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
                                  child: Text(
                                    '全车隐形车衣',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥18,800.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    tab: true,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                            hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s163, Svgs.s164),
                                  w: 14,
                                  h: 14,
                                ),
                                Flexible(
                                  flex: 290,
                                  child: Text(
                                    '张师傅 · 贴膜间 · 预计 明天 18:00 · 昨天 16:20 挂单',
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
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 42,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(21),
                                        child: Align(
                                          alignment: Alignment(0, 0),
                                          widthFactor: 1,
                                          child: Text(
                                            '取单结算',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFFFFFFFF),
                                                Color(0xFF18181B),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      to: 'Order',
                                    ),
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                                      child: Align(
                                        alignment: Alignment(0, 0),
                                        widthFactor: 1,
                                        child: Text(
                                          '加项',
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
                                    ),
                                    to: 'Order',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 42,
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s165, Svgs.s166),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    onTap: () => d2.confirmRemove(context, 1),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
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
                            hrow(
                              [
                                hbox(
                                  w: 40,
                                  h: 40,
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '李',
                                    style: hts(
                                      16,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
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
                                              flex: 45,
                                              child: Text(
                                                '李女士',
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
                                            Flexible(
                                              flex: 38,
                                              child: hbox(
                                                bg: Color(0xFFF5D78E),
                                                radius: BorderRadius.circular(
                                                  9,
                                                ),
                                                pad: EdgeInsets.fromLTRB(
                                                  8,
                                                  0,
                                                  8,
                                                  0,
                                                ),
                                                child: Text(
                                                  '金卡',
                                                  style: hts(
                                                    11,
                                                    dk(
                                                      context,
                                                      Color(0xFF18181B),
                                                      Color(0xFFFAFAFA),
                                                    ),
                                                    w: FontWeight.w600,
                                                    lh: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hbox(
                                            bg: Color(0xFF0B5FD6),
                                            radius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Color(0xFF5B9BF0),
                                              width: 1.5,
                                            ),
                                            pad: EdgeInsets.fromLTRB(
                                              5,
                                              1,
                                              5,
                                              1,
                                            ),
                                            child: Text(
                                              '沪B·2C519',
                                              style: hts(
                                                11,
                                                Color(0xFFFFFFFF),
                                                w: FontWeight.w600,
                                                lh: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 3,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '待结算',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
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
                                  child: Text(
                                    '全车精洗 · 打蜡',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥880.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    tab: true,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                            hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s163, Svgs.s164),
                                  w: 14,
                                  h: 14,
                                ),
                                Flexible(
                                  flex: 229,
                                  child: Text(
                                    '小陈 · 已完工，等待 25 分钟 · 14:16 挂单',
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
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 42,
                                        bg: Color(0xFF0485F7),
                                        radius: BorderRadius.circular(21),
                                        child: Align(
                                          alignment: Alignment(0, 0),
                                          widthFactor: 1,
                                          child: Text(
                                            '取单结算',
                                            style: hts(
                                              14,
                                              Color(0xFFFFFFFF),
                                              w: FontWeight.w600,
                                              lh: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      to: 'Order',
                                    ),
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                                      child: Align(
                                        alignment: Alignment(0, 0),
                                        widthFactor: 1,
                                        child: Text(
                                          '提醒取车',
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
                                    ),
                                    to: 'Order',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 42,
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s165, Svgs.s166),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    onTap: () => d2.confirmRemove(context, 2),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
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
                            hrow(
                              [
                                hbox(
                                  w: 40,
                                  h: 40,
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(20),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    '客',
                                    style: hts(
                                      16,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w600,
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
                                              flex: 30,
                                              child: Text(
                                                '散客',
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
                                            Flexible(
                                              flex: 49,
                                              child: hbox(
                                                bg: dk(
                                                  context,
                                                  Color(0xFFEEEEF0),
                                                  Color(0xFF27272A),
                                                ),
                                                radius: BorderRadius.circular(
                                                  9,
                                                ),
                                                pad: EdgeInsets.fromLTRB(
                                                  8,
                                                  0,
                                                  8,
                                                  0,
                                                ),
                                                child: Text(
                                                  '非会员',
                                                  style: hts(
                                                    11,
                                                    dk(
                                                      context,
                                                      Color(0xFF52525B),
                                                      Color(0xFFA8A8B3),
                                                    ),
                                                    w: FontWeight.w600,
                                                    lh: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 6,
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: hbox(
                                            bg: Color(0xFF0B5FD6),
                                            radius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: Color(0xFF5B9BF0),
                                              width: 1.5,
                                            ),
                                            pad: EdgeInsets.fromLTRB(
                                              5,
                                              1,
                                              5,
                                              1,
                                            ),
                                            child: Text(
                                              '苏K·5F218',
                                              style: hts(
                                                11,
                                                Color(0xFFFFFFFF),
                                                w: FontWeight.w600,
                                                lh: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 3,
                                    ),
                                  ),
                                ),
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '待施工',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 18,
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
                                  child: Text(
                                    '基础洗车 · 轮毂清洁',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥98.00',
                                  style: hts(
                                    20,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 26,
                                    tab: true,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.end,
                              gap: 12,
                            ),
                            hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s163, Svgs.s164),
                                  w: 14,
                                  h: 14,
                                ),
                                Flexible(
                                  flex: 164,
                                  child: Text(
                                    '预约 15:30 到店 · 13:40 挂单',
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
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 6,
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 42,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(21),
                                        child: Align(
                                          alignment: Alignment(0, 0),
                                          widthFactor: 1,
                                          child: Text(
                                            '取单结算',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFFFFFFFF),
                                                Color(0xFF18181B),
                                              ),
                                              w: FontWeight.w600,
                                              lh: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      to: 'Order',
                                    ),
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                                      child: Align(
                                        alignment: Alignment(0, 0),
                                        widthFactor: 1,
                                        child: Text(
                                          '加项',
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
                                    ),
                                    to: 'Order',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 42,
                                      h: 42,
                                      bg: dk(
                                        context,
                                        Color(0xFFFFE1E2),
                                        Color.fromRGBO(255, 56, 60, 0.18),
                                      ),
                                      radius: BorderRadius.circular(21),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s165, Svgs.s166),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    onTap: () => d2.confirmRemove(context, 3),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 12,
                        ),
                      ),
                    ]),
                    Text(
                      '挂单超过 24 小时未处理，将提醒店长',
                      style: hts(
                        12,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                        lh: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
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
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
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
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hTap(
                    context,
                    hbox(
                      h: 50,
                      bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      radius: BorderRadius.circular(25),
                      child: hrow(
                        [
                          hsvg(dk(context, Svgs.s14, Svgs.s15), w: 18, h: 18),
                          Flexible(
                            flex: 60,
                            child: Text(
                              '新开一单',
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.center,
                        gap: 6,
                      ),
                    ),
                    to: 'Order',
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
    );
  }
}
