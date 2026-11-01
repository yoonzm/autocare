import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class MemberAddPage extends StatelessWidget {
  const MemberAddPage({super.key});

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
                      to: 'Members',
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '新增会员',
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
                      to: 'MemberAddDone',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hTap(
                  context,
                  hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                    radius: BorderRadius.circular(22),
                    pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: hrow(
                      [
                        hbox(
                          w: 40,
                          h: 40,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(12),
                          child: hrow(
                            [hsvg(Svgs.s206, w: 22, h: 22)],
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
                                '扫描行驶证 / 车牌快速建档',
                                style: hts(
                                  15,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w500,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '自动识别车牌、车型、车架号',
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 2,
                          ),
                        ),
                        hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                  to: 'ScanLicense',
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '客户信息',
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
                                  w: 64,
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
                                          text: '手机号 ',
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
                                    value: '139 1688 5530',
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
                                  w: 64,
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
                                          text: '姓名 ',
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
                                    hint: '请输入客户姓名',
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
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '称呼',
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
                                hbox(
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                  child: hrow(
                                    [
                                      Flexible(
                                        flex: 82,
                                        child: UnconstrainedBox(
                                          alignment: Alignment.topLeft,
                                          constrainedAxis: Axis.horizontal,
                                          child: HToggle(
                                            initial: true,
                                            on: hbox(
                                              h: 28,
                                              bg: dk(
                                                context,
                                                Color(0xFFFFFFFF),
                                                Color(0xFF18181B),
                                              ),
                                              radius: BorderRadius.circular(14),
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
                                              pad: EdgeInsets.fromLTRB(
                                                14,
                                                0,
                                                14,
                                                0,
                                              ),
                                              child: hrow(
                                                [
                                                  Flexible(
                                                    flex: 26,
                                                    child: Text(
                                                      '先生',
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
                                                  Flexible(
                                                    flex: 54,
                                                    child: HToggle(
                                                      initial: false,
                                                      on: hbox(
                                                        h: 28,
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFFFFFFF),
                                                          Color(0xFF18181B),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        shadow: dk(
                                                          context,
                                                          [
                                                            BoxShadow(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.08,
                                                                  ),
                                                              offset: Offset(
                                                                0,
                                                                1,
                                                              ),
                                                              blurRadius: 2,
                                                              spreadRadius: 0,
                                                            ),
                                                          ],
                                                          [
                                                            BoxShadow(
                                                              color: Color(
                                                                0xFF26262B,
                                                              ),
                                                              offset: Offset(
                                                                0,
                                                                0,
                                                              ),
                                                              blurRadius: 0,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              14,
                                                              0,
                                                              14,
                                                              0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '女士',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF18181B,
                                                                ),
                                                                Color(
                                                                  0xFFFAFAFA,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      off: hbox(
                                                        h: 28,
                                                        radius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              14,
                                                              0,
                                                              14,
                                                              0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '女士',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF52525B,
                                                                ),
                                                                Color(
                                                                  0xFFA8A8B3,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
                                              ),
                                            ),
                                            off: hbox(
                                              h: 28,
                                              radius: BorderRadius.circular(14),
                                              pad: EdgeInsets.fromLTRB(
                                                14,
                                                0,
                                                14,
                                                0,
                                              ),
                                              child: hrow(
                                                [
                                                  Flexible(
                                                    flex: 26,
                                                    child: Text(
                                                      '先生',
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
                                                  Flexible(
                                                    flex: 54,
                                                    child: HToggle(
                                                      initial: false,
                                                      on: hbox(
                                                        h: 28,
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFFFFFFF),
                                                          Color(0xFF18181B),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        shadow: dk(
                                                          context,
                                                          [
                                                            BoxShadow(
                                                              color:
                                                                  Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.08,
                                                                  ),
                                                              offset: Offset(
                                                                0,
                                                                1,
                                                              ),
                                                              blurRadius: 2,
                                                              spreadRadius: 0,
                                                            ),
                                                          ],
                                                          [
                                                            BoxShadow(
                                                              color: Color(
                                                                0xFF26262B,
                                                              ),
                                                              offset: Offset(
                                                                0,
                                                                0,
                                                              ),
                                                              blurRadius: 0,
                                                              spreadRadius: 1,
                                                            ),
                                                          ],
                                                        ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              14,
                                                              0,
                                                              14,
                                                              0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '女士',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF18181B,
                                                                ),
                                                                Color(
                                                                  0xFFFAFAFA,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      off: hbox(
                                                        h: 28,
                                                        radius:
                                                            BorderRadius.circular(
                                                              14,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              14,
                                                              0,
                                                              14,
                                                              0,
                                                            ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          widthFactor: 1,
                                                          child: Text(
                                                            '女士',
                                                            style: hts(
                                                              13,
                                                              dk(
                                                                context,
                                                                Color(
                                                                  0xFF52525B,
                                                                ),
                                                                Color(
                                                                  0xFFA8A8B3,
                                                                ),
                                                              ),
                                                              w: FontWeight
                                                                  .w500,
                                                              lh: 18,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                main: MainAxisAlignment.start,
                                                cross:
                                                    CrossAxisAlignment.center,
                                                gap: 6,
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
                          HStrHolder(
                            initial: '选填，用于生日礼',
                            builder: (context, s1) => hTap(
                              context,
                              hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '生日',
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
                                    hStr(
                                      s1,
                                      hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 22,
                                      ),
                                      placeholder: '选填，用于生日礼',
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
                              onTap: () => hPick(context, 'birthday', '生日', s1),
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
                        '车辆信息',
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
                      pad: EdgeInsets.fromLTRB(0, 16, 0, 4),
                      child: hcol(
                        [
                          HPlate(
                            initial: '沪A8K29M',
                            green: false,
                            linked: false,
                          ),
                          hcol(
                            [
                              HStrHolder(
                                initial: '宝马 5系 525Li',
                                builder: (context, s2) => hTap(
                                  context,
                                  hbox(
                                    minH: 54,
                                    pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '品牌车型',
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
                                        hStr(
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
                                  onTap: () =>
                                      hPick(context, 'car', '品牌车型', s2),
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
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '车身颜色',
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
                                    HSelHolder(
                                      groups: [
                                        ({0}, false),
                                      ],
                                      builder: (context, g3) => hrow(
                                        [
                                          UnconstrainedBox(
                                            alignment: Alignment.topLeft,
                                            constrainedAxis: Axis.horizontal,
                                            child: HSel(
                                              ctrl: g3[0],
                                              index: 0,
                                              on: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFF34343A),
                                                ),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                                shadow: dk(
                                                  context,
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFFFFFFFF),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFF18181B),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              off: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFF34343A),
                                                ),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
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
                                              ),
                                            ),
                                          ),
                                          UnconstrainedBox(
                                            alignment: Alignment.topLeft,
                                            constrainedAxis: Axis.horizontal,
                                            child: HSel(
                                              ctrl: g3[0],
                                              index: 1,
                                              on: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: dk(
                                                  context,
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFF18181B),
                                                ),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                                shadow: dk(
                                                  context,
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFFFFFFFF),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFF18181B),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              off: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: dk(
                                                  context,
                                                  Color(0xFFFFFFFF),
                                                  Color(0xFF18181B),
                                                ),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
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
                                              ),
                                            ),
                                          ),
                                          UnconstrainedBox(
                                            alignment: Alignment.topLeft,
                                            constrainedAxis: Axis.horizontal,
                                            child: HSel(
                                              ctrl: g3[0],
                                              index: 2,
                                              on: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFF8E8E93),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                                shadow: dk(
                                                  context,
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFFFFFFFF),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFF18181B),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              off: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFF8E8E93),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          UnconstrainedBox(
                                            alignment: Alignment.topLeft,
                                            constrainedAxis: Axis.horizontal,
                                            child: HSel(
                                              ctrl: g3[0],
                                              index: 3,
                                              on: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFF1E40AF),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                                shadow: dk(
                                                  context,
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFFFFFFFF),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFF18181B),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              off: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFF1E40AF),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                              ),
                                            ),
                                          ),
                                          UnconstrainedBox(
                                            alignment: Alignment.topLeft,
                                            constrainedAxis: Axis.horizontal,
                                            child: HSel(
                                              ctrl: g3[0],
                                              index: 4,
                                              on: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFFB91C1C),
                                                radius: BorderRadius.circular(
                                                  13,
                                                ),
                                                shadow: dk(
                                                  context,
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFFFFFFFF),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                  [
                                                    BoxShadow(
                                                      color: Color(0xFF0485F7),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 4,
                                                    ),
                                                    BoxShadow(
                                                      color: Color(0xFF18181B),
                                                      offset: Offset(0, 0),
                                                      blurRadius: 0,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              off: hbox(
                                                w: 26,
                                                h: 26,
                                                bg: Color(0xFFB91C1C),
                                                radius: BorderRadius.circular(
                                                  13,
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '会员等级',
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
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFDDF6E7),
                              Color.fromRGBO(23, 201, 100, 0.16),
                            ),
                            radius: BorderRadius.circular(10),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              '自动升级',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF2B7745),
                                  Color(0xFF5FD48C),
                                ),
                                w: FontWeight.w600,
                                lh: 20,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 8,
                      ),
                      hstack(
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hbox(
                                    h: 32,
                                    minW: 52,
                                    bg: dk(
                                      context,
                                      Color(0xFFF4F4F5),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(16),
                                    shadow: dk(
                                      context,
                                      [
                                        BoxShadow(
                                          color: Color(0xFF0485F7),
                                          offset: Offset(0, 0),
                                          blurRadius: 0,
                                          spreadRadius: 4,
                                        ),
                                        BoxShadow(
                                          color: Color(0xFFFFFFFF),
                                          offset: Offset(0, 0),
                                          blurRadius: 0,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                      [
                                        BoxShadow(
                                          color: Color(0xFF0485F7),
                                          offset: Offset(0, 0),
                                          blurRadius: 0,
                                          spreadRadius: 4,
                                        ),
                                        BoxShadow(
                                          color: Color(0xFF18181B),
                                          offset: Offset(0, 0),
                                          blurRadius: 0,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '普通',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '当前',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 14,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hbox(
                                    h: 32,
                                    minW: 52,
                                    bg: dk(
                                      context,
                                      Color(0xFFE4E4E7),
                                      Color(0xFF3A3A40),
                                    ),
                                    radius: BorderRadius.circular(16),
                                    pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '银卡',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF27272A),
                                            Color(0xFFD4D4D8),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '充值 ¥2,000\n或消费 ¥3,000',
                                    style: hts(
                                      10,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 14,
                                      ls: -0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hbox(
                                    h: 32,
                                    minW: 52,
                                    bg: Color(0xFFF3E2B3),
                                    radius: BorderRadius.circular(16),
                                    pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '金卡',
                                        style: hts(
                                          13,
                                          Color(0xFF3D2B0E),
                                          w: FontWeight.w600,
                                          lh: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '充值 ¥5,000\n或消费 ¥10,000',
                                    style: hts(
                                      10,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 14,
                                      ls: -0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  hbox(
                                    h: 32,
                                    minW: 52,
                                    bg: dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFF34343A),
                                    ),
                                    radius: BorderRadius.circular(16),
                                    pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      widthFactor: 1,
                                      child: Text(
                                        '黑金',
                                        style: hts(
                                          13,
                                          Color(0xFFF5D78E),
                                          w: FontWeight.w600,
                                          lh: 32,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '充值 ¥10,000\n或消费 ¥30,000',
                                    style: hts(
                                      10,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 14,
                                      ls: -0.2,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.start,
                          gap: 0,
                        ),
                        [],
                        behind: [
                          Positioned(
                            top: 15,
                            height: 2,
                            child: hbox(
                              h: 2,
                              bg: dk(
                                context,
                                Color(0xFFE4E4E7),
                                Color(0xFF3A3A40),
                              ),
                            ),
                          ),
                        ],
                      ),
                      hbox(
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(14),
                        pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Text(
                          '新会员默认为普通会员。单次充值或累计消费达到门槛，立即自动升级；两者同时满足时取最高等级。保存后可在成功页直接充值。',
                          style: hts(
                            12,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 18,
                          ),
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
                        '客户来源',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      HSelHolder(
                        groups: [
                          ({1}, false),
                        ],
                        builder: (context, g4) => hwrap(
                          [
                            HSel(
                              ctrl: g4[0],
                              index: 0,
                              on: hbox(
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '到店自然客',
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
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '到店自然客',
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
                            HSel(
                              ctrl: g4[0],
                              index: 1,
                              on: hbox(
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '老客推荐',
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
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFF34343A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '老客推荐',
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
                            HSel(
                              ctrl: g4[0],
                              index: 2,
                              on: hbox(
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '团购平台',
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
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '团购平台',
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
                            HSel(
                              ctrl: g4[0],
                              index: 3,
                              on: hbox(
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '短视频',
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
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(16),
                                pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '短视频',
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
                          ],
                          gap: 8,
                          rowGap: 8,
                          cross: WrapCrossAlignment.start,
                        ),
                      ),
                      HStrHolder(
                        initial: '王建国 · 黑金',
                        builder: (context, s5) => hTap(
                          context,
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(14),
                            pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '推荐人',
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
                                hStr(
                                  s5,
                                  hts(
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
                                hsvg(
                                  dk(context, Svgs.s207, Svgs.s208),
                                  w: 14,
                                  h: 14,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 10,
                            ),
                          ),
                          onTap: () => hPick(context, 'referrer', '推荐人', s5),
                        ),
                      ),
                      Text(
                        '备注',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                      hbox(
                        minH: 64,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(14),
                        pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: HInput(
                          style: hts(
                            14,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            lh: 20,
                          ),
                          maxLines: 4,
                          hint: '如：车主偏好、车辆旧伤位置',
                        ),
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
