import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ServiceEditPage extends StatelessWidget {
  const ServiceEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1200,
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
                      to: 'Services',
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '编辑项目',
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
                      to: 'Services',
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
                                '项目名称',
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
                                value: '全车镀晶 · 9H 陶瓷',
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
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      HStrHolder(
                        initial: '镀晶镀膜',
                        builder: (context, s1) => hTap(
                          context,
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '所属分类',
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
                                  flex: 1,
                                  child: hStr(
                                    s1,
                                    hts(
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
                                hsvg(
                                  dk(context, Svgs.s3, Svgs.s4),
                                  w: 16,
                                  h: 16,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          onTap: () => hPick(context, 'category', '所属分类', s1),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      HStrHolder(
                        initial: '4 小时',
                        builder: (context, s2) => hTap(
                          context,
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '标准工时',
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
                                  flex: 1,
                                  child: hStr(
                                    s2,
                                    hts(
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
                                hsvg(
                                  dk(context, Svgs.s3, Svgs.s4),
                                  w: 16,
                                  h: 16,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          onTap: () => hPick(context, 'duration', '标准工时', s2),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
                      Text(
                        '价格',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hbox(
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(16),
                        pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '门店价',
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
                            Text(
                              '¥',
                              style: hts(
                                18,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w600,
                                lh: 24,
                              ),
                            ),
                            hbox(
                              w: 96,
                              child: HInput(
                                style: hts(
                                  26,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 32,
                                  ls: -0.52,
                                ),
                                value: '1,580',
                                keyboard: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                align: TextAlign.right,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.baseline,
                          gap: 4,
                        ),
                      ),
                      hcol(
                        [
                          hrow(
                            [
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFF34343A),
                                ),
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                child: Text(
                                  '黑金卡',
                                  style: hts(
                                    11,
                                    Color(0xFFF5D78E),
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '9 折',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ),
                              Text(
                                '¥1,422',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFFDEFD6),
                                  Color.fromRGBO(245, 165, 36, 0.16),
                                ),
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                child: Text(
                                  '金卡',
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
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '95 折',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ),
                              Text(
                                '¥1,501',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                child: Text(
                                  '银卡',
                                  style: hts(
                                    11,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '98 折',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ),
                              Text(
                                '¥1,548',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
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
                        gap: 10,
                      ),
                      Text.rich(
                        TextSpan(
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 16,
                          ),
                          children: [
                            TextSpan(
                              text: '会员价按卡种折扣自动计算，',
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
                            TextSpan(
                              text: '去调整卡种折扣',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF1E63AE),
                                  Color(0xFF6AB4FA),
                                ),
                                w: FontWeight.w500,
                                lh: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 14,
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
                      Text(
                        '技师提成',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hbox(
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(18),
                        pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: HSelHolder(
                          groups: [
                            ({0}, false),
                          ],
                          builder: (context, g3) => hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g3[0],
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
                                            color: Color.fromRGBO(
                                              0,
                                              0,
                                              0,
                                              0.08,
                                            ),
                                            offset: Offset(0, 1),
                                            blurRadius: 2,
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
                                          '按实收比例',
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
                                          '按实收比例',
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
                                    ctrl: g3[0],
                                    index: 1,
                                    on: hbox(
                                      h: 32,
                                      radius: BorderRadius.circular(16),
                                      shadow: dk(context, [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.08),
                                          offset: Offset(0, 1),
                                          blurRadius: 2,
                                          spreadRadius: 0,
                                        ),
                                      ], null),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '固定金额',
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
                                          '固定金额',
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
                      ),
                      hrow(
                        [
                          Text(
                            '提成比例',
                            style: hts(
                              14,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 20,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              '约 ¥126 / 单',
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 16,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          hbox(
                            w: 48,
                            h: 36,
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(10),
                            align: Alignment.centerLeft,
                            child: HInput(
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
                              value: '8',
                              keyboard: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              align: TextAlign.center,
                            ),
                          ),
                          Text(
                            '%',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              lh: 20,
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
                              '耗材绑定',
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
                            '完工后自动扣减库存',
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
                            radius: BorderRadius.circular(12),
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s344, Svgs.s345),
                                  w: 18,
                                  h: 18,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '9H 陶瓷镀晶液 50ml',
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
                                  '库存 6 瓶 · 偏低',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF855F2E),
                                      Color(0xFFF0C46A),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 1,
                            ),
                          ),
                          Text(
                            '× 1 瓶',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 12,
                      ),
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
                            radius: BorderRadius.circular(12),
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s346, Svgs.s347),
                                  w: 18,
                                  h: 18,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hcol(
                              [
                                Text(
                                  '超细纤维擦车巾',
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
                                  '库存 86 条',
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
                              gap: 1,
                            ),
                          ),
                          Text(
                            '× 4 条',
                            style: hts(
                              14,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 20,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 12,
                      ),
                      hTap(
                        context,
                        hbox(
                          h: 40,
                          radius: BorderRadius.circular(14),
                          border: dk(
                            context,
                            Border.all(color: Color(0xFFD4D4D8), width: 1.5),
                            Border.all(color: Color(0xFF3F3F46), width: 1.5),
                          ),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s348, Svgs.s349),
                                w: 16,
                                h: 16,
                              ),
                              Flexible(
                                flex: 91,
                                child: Text(
                                  '从库存添加耗材',
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
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 6,
                          ),
                        ),
                        to: 'Inventory',
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
                  pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                  child: hcol(
                    [
                      hbox(
                        minH: 56,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '上架销售',
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
                            HSwitch(initial: true),
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
                        minH: 56,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '支持线上预约',
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
                                  Text(
                                    '客户可在小程序预约此项目',
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
                            HSwitch(initial: false),
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
                hTap(
                  context,
                  hbox(
                    h: 48,
                    radius: BorderRadius.circular(24),
                    child: Align(
                      alignment: Alignment.center,
                      widthFactor: 1,
                      child: Text(
                        '删除此项目',
                        style: hts(
                          15,
                          dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  onTap: () => hConfirmPop(context, '删除此项目'),
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
