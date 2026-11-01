import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class MemberFollowUpPage extends StatelessWidget {
  const MemberFollowUpPage({super.key});

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
            child: HSelHolder(
              groups: [
                ({0}, false),
              ],
              builder: (context, g1) => HDyn(
                texts: [
                  '次卡到期3 天后 陈陈浩 · 银卡 · 苏E·3QX18精致洗车次卡剩 3 次，11.03 到期 发送续卡优惠',
                  '养护到期今天 林林晓雯 · 金卡 · 沪AD·61207镀晶已满 3 个月，建议预约复养 帮她预约',
                  '生日11.02 赵赵一鸣 · 金卡 · 沪B·72M51金卡生日礼：赠精致洗车 1 次 发放生日礼',
                  '沉睡客户47 天未到店 周周志远 · 银卡 · 浙A·5L0P2余额 ¥180 未用，上次做的是快速洗车 标记已回访',
                ],
                filter: g1[0],
                labels: ['全部', '次卡到期', '养护到期', '生日', '沉睡'],
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
                            '回访提醒',
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
                      radius: BorderRadius.circular(24),
                      pad: EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                      child: hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '今日待回访',
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
                              ),
                              Text.rich(
                                TextSpan(
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    lh: 18,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '已完成 ',
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
                                    TextSpan(
                                      text: '5',
                                      style: hts(
                                        13,
                                        Color(0xFFFAFAFA),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' / 23',
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
                                  ],
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.baseline,
                            gap: 8,
                          ),
                          Text.rich(
                            TextSpan(
                              style: hts(
                                30,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 36,
                                ls: -0.6,
                              ),
                              children: [
                                TextSpan(
                                  text: '18 ',
                                  style: hts(
                                    30,
                                    Color(0xFFFAFAFA),
                                    w: FontWeight.w600,
                                    lh: 36,
                                    ls: -0.6,
                                  ),
                                ),
                                TextSpan(
                                  text: '位客户',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFFA1A1AA),
                                      Color(0xFF80808A),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 36,
                                    ls: -0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          hbox(
                            h: 6,
                            bg: Color(0xFF3F3F46),
                            radius: BorderRadius.circular(3),
                            child: hcol(
                              [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: hfrac(
                                    0.22,
                                    hbox(
                                      h: 6,
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 0,
                              min: false,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                    NegMargin(
                      top: 0,
                      left: 0,
                      child: hbox(
                        clip: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: hrow(
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
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '全部 18',
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
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFF34343A),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3A3A40),
                                        width: 1,
                                      ),
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '全部 18',
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
                                child: HSel(
                                  ctrl: g1[0],
                                  index: 1,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '次卡到期 5',
                                        style: hts(
                                          13,
                                          Color(0xFFFFFFFF),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3A3A40),
                                        width: 1,
                                      ),
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '次卡到期 5',
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
                                child: HSel(
                                  ctrl: g1[0],
                                  index: 2,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '养护到期 6',
                                        style: hts(
                                          13,
                                          Color(0xFFFFFFFF),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3A3A40),
                                        width: 1,
                                      ),
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '养护到期 6',
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
                                child: HSel(
                                  ctrl: g1[0],
                                  index: 3,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '生日 2',
                                        style: hts(
                                          13,
                                          Color(0xFFFFFFFF),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3A3A40),
                                        width: 1,
                                      ),
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '生日 2',
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
                                child: HSel(
                                  ctrl: g1[0],
                                  index: 4,
                                  on: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '沉睡 5',
                                        style: hts(
                                          13,
                                          Color(0xFFFFFFFF),
                                          w: FontWeight.w500,
                                          lh: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                  off: hbox(
                                    h: 34,
                                    bg: dk(
                                      context,
                                      Color(0xFFFFFFFF),
                                      Color(0xFF18181B),
                                    ),
                                    radius: BorderRadius.circular(17),
                                    border: dk(
                                      context,
                                      Border.all(
                                        color: Color(0xFFE4E4E7),
                                        width: 1,
                                      ),
                                      Border.all(
                                        color: Color(0xFF3A3A40),
                                        width: 1,
                                      ),
                                    ),
                                    pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '沉睡 5',
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFFE1E2),
                                    Color.fromRGBO(255, 56, 60, 0.18),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '次卡到期',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFFA43433),
                                        Color(0xFFFF7B7E),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                Text(
                                  '3 天后',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFFA43433),
                                      Color(0xFFFF7B7E),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hTap(
                              context,
                              hrow(
                                [
                                  hbox(
                                    w: 36,
                                    h: 36,
                                    bg: dk(
                                      context,
                                      Color(0xFFE1F0FE),
                                      Color.fromRGBO(4, 133, 247, 0.18),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    align: Alignment(0, 0),
                                    child: Text(
                                      '陈',
                                      style: hts(
                                        14,
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
                                    child: hcol(
                                      [
                                        Text.rich(
                                          TextSpan(
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '陈浩 ',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  w: FontWeight.w500,
                                                  lh: 22,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '· 银卡 · 苏E·3QX18',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF71717A),
                                                    Color(0xFF9A9AA3),
                                                  ),
                                                  lh: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '精致洗车次卡剩 3 次，11.03 到期',
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
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                              to: 'MemberDetail',
                            ),
                            hrow(
                              [
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s216, Svgs.s217),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '拨打电话',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s218, Svgs.s219),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '发送短信',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 40,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '发送续卡优惠',
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
                                      label: '发送续卡优惠',
                                    ),
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
                          gap: 10,
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFE1F0FE),
                                    Color.fromRGBO(4, 133, 247, 0.18),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '养护到期',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                Text(
                                  '今天',
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
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hTap(
                              context,
                              hrow(
                                [
                                  hbox(
                                    w: 36,
                                    h: 36,
                                    bg: dk(
                                      context,
                                      Color(0xFFFDEFD6),
                                      Color.fromRGBO(245, 165, 36, 0.16),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    align: Alignment(0, 0),
                                    child: Text(
                                      '林',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF855F2E),
                                          Color(0xFFF0C46A),
                                        ),
                                        w: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text.rich(
                                          TextSpan(
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '林晓雯 ',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  w: FontWeight.w500,
                                                  lh: 22,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '· 金卡 · 沪AD·61207',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF71717A),
                                                    Color(0xFF9A9AA3),
                                                  ),
                                                  lh: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '镀晶已满 3 个月，建议预约复养',
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
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                              to: 'MemberDetail',
                            ),
                            hrow(
                              [
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s216, Svgs.s217),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '拨打电话',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s218, Svgs.s219),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '发送短信',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 40,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '帮她预约',
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
                                      label: '帮她预约',
                                    ),
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
                          gap: 10,
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '生日',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                Text(
                                  '11.02',
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
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hTap(
                              context,
                              hrow(
                                [
                                  hbox(
                                    w: 36,
                                    h: 36,
                                    bg: dk(
                                      context,
                                      Color(0xFFDDF6E7),
                                      Color.fromRGBO(23, 201, 100, 0.16),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    align: Alignment(0, 0),
                                    child: Text(
                                      '赵',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF2B7745),
                                          Color(0xFF5FD48C),
                                        ),
                                        w: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text.rich(
                                          TextSpan(
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '赵一鸣 ',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  w: FontWeight.w500,
                                                  lh: 22,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '· 金卡 · 沪B·72M51',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF71717A),
                                                    Color(0xFF9A9AA3),
                                                  ),
                                                  lh: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '金卡生日礼：赠精致洗车 1 次',
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
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                              to: 'MemberDetail',
                            ),
                            hrow(
                              [
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s216, Svgs.s217),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '拨打电话',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s218, Svgs.s219),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '发送短信',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 40,
                                        bg: dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        radius: BorderRadius.circular(20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '发放生日礼',
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
                                      label: '发放生日礼',
                                    ),
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
                          gap: 10,
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
                        pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '沉睡客户',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF3F3F46),
                                        Color(0xFFD4D4D8),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(flex: 1, child: SizedBox.shrink()),
                                Text(
                                  '47 天未到店',
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
                              cross: CrossAxisAlignment.center,
                              gap: 8,
                            ),
                            hTap(
                              context,
                              hrow(
                                [
                                  hbox(
                                    w: 36,
                                    h: 36,
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(18),
                                    align: Alignment(0, 0),
                                    child: Text(
                                      '周',
                                      style: hts(
                                        14,
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
                                    child: hcol(
                                      [
                                        Text.rich(
                                          TextSpan(
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w500,
                                              lh: 22,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: '周志远 ',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  w: FontWeight.w500,
                                                  lh: 22,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '· 银卡 · 浙A·5L0P2',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF71717A),
                                                    Color(0xFF9A9AA3),
                                                  ),
                                                  lh: 22,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '余额 ¥180 未用，上次做的是快速洗车',
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
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 10,
                              ),
                              to: 'MemberDetail',
                            ),
                            hrow(
                              [
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s216, Svgs.s217),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '拨打电话',
                                  ),
                                ),
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: hTap(
                                    context,
                                    hbox(
                                      w: 40,
                                      h: 40,
                                      bg: dk(
                                        context,
                                        Color(0xFFEEEEF0),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(20),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s218, Svgs.s219),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    label: '发送短信',
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: UnconstrainedBox(
                                    alignment: Alignment.topLeft,
                                    constrainedAxis: Axis.horizontal,
                                    child: hTap(
                                      context,
                                      hbox(
                                        h: 40,
                                        bg: dk(
                                          context,
                                          Color(0xFFEEEEF0),
                                          Color(0xFF27272A),
                                        ),
                                        radius: BorderRadius.circular(20),
                                        child: Align(
                                          alignment: Alignment.center,
                                          widthFactor: 1,
                                          child: Text(
                                            '标记已回访',
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
                                      label: '标记已回访',
                                    ),
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
                          gap: 10,
                        ),
                      ),
                    ]),
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
      overlays: [],
    );
  }
}
