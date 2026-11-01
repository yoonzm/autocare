import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ChannelConfigPage extends StatelessWidget {
  const ChannelConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1260,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 40),
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
                          [hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)],
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
                        '渠道配置',
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
                        minW: 44,
                        child: Align(
                          alignment: Alignment(1, 0),
                          widthFactor: 1,
                          child: Text(
                            '保存',
                            style: hts(
                              15,
                              Color(0xFF0485F7),
                              w: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      to: 'NotifySettings',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '微信模板消息',
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
                          hrow(
                            [
                              hbox(
                                w: 44,
                                h: 44,
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(22),
                                align: Alignment(0, 0),
                                child: Text(
                                  '驰',
                                  style: hts(
                                    17,
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
                                    Text(
                                      '驰光汽车美容服务号',
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
                                    hrow(
                                      [
                                        hbox(
                                          w: 6,
                                          h: 6,
                                          bg: Color(0xFF17C964),
                                          radius: BorderRadius.circular(3),
                                        ),
                                        Flexible(
                                          flex: 144,
                                          child: Text(
                                            '已授权 · 2027.03.18 到期',
                                            style: hts(
                                              12,
                                              dk(
                                                context,
                                                Color(0xFF2B7745),
                                                Color(0xFF5FD48C),
                                              ),
                                              lh: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 5,
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 2,
                                ),
                              ),
                              hTap(
                                context,
                                hbox(
                                  h: 32,
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(16),
                                  pad: EdgeInsets.fromLTRB(12, 0, 12, 0),
                                  child: Align(
                                    alignment: Alignment.center,
                                    widthFactor: 1,
                                    child: Text(
                                      '重新授权',
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
                                label: '重新授权',
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(18),
                            pad: EdgeInsets.fromLTRB(14, 14, 14, 14),
                            child: hcol(
                              [
                                hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '会员已关注公众号',
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
                                    Text.rich(
                                      TextSpan(
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
                                        children: [
                                          TextSpan(
                                            text: '412',
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
                                          TextSpan(
                                            text: ' / 1,086 人',
                                            style: hts(
                                              13,
                                              dk(
                                                context,
                                                Color(0xFF71717A),
                                                Color(0xFF9A9AA3),
                                              ),
                                              lh: 28,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.baseline,
                                  gap: 0,
                                ),
                                hbox(
                                  h: 8,
                                  bg: dk(
                                    context,
                                    Color(0xFFE4E4E7),
                                    Color(0xFF3A3A40),
                                  ),
                                  radius: BorderRadius.circular(4),
                                  clip: true,
                                  child: hcol(
                                    [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: hfrac(
                                          0.38,
                                          hbox(
                                            bg: Color(0xFF17C964),
                                            radius: BorderRadius.circular(4),
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
                                Text(
                                  '未关注的 674 位会员将按发送策略转为短信，或收不到通知',
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
                              gap: 8,
                            ),
                          ),
                          hrow(
                            [
                              hbox(
                                w: 96,
                                h: 96,
                                bg: Color(0xFFFFFFFF),
                                radius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Color(0xFFE4E4E7),
                                  width: 1,
                                ),
                                child: hrow(
                                  [hsvg(Svgs.s89, w: 76, h: 76)],
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
                                      '引导会员关注',
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
                                    Text(
                                      '收款成功页会展示此二维码，会员扫码关注后，之后的消费、充值就能收到微信通知',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 18,
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hTap(
                                        context,
                                        hbox(
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          pad: EdgeInsets.fromLTRB(
                                            12,
                                            0,
                                            12,
                                            0,
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '保存到相册',
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
                                        label: '保存到相册',
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 8,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 14,
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hTap(
                            context,
                            hbox(
                              minH: 28,
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '模板消息',
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
                                  ),
                                  Text(
                                    '已启用 5 个模板',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF71717A),
                                        Color(0xFF9A9AA3),
                                      ),
                                      lh: 18,
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
                                gap: 8,
                              ),
                            ),
                            to: 'NotifyTemplate',
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
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '短信',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w500,
                          lh: 18,
                        ),
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(24),
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
                        hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: hcol(
                                [
                                  Text(
                                    '短信余量',
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
                                        flex: 90,
                                        child: Text(
                                          '1,240',
                                          style: hts(
                                            32,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 40,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 82,
                                        child: Text(
                                          '条 · 约够 3 周',
                                          style: hts(
                                            13,
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
                                    gap: 4,
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                        [],
                        behind: [
                          Positioned(
                            top: -80,
                            right: -70,
                            child: hsvg(
                              dk(context, Svgs.s90, Svgs.s91),
                              w: 200,
                              h: 200,
                            ),
                          ),
                        ],
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
                          hcol(
                            [
                              hbox(
                                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                child: Text.rich(
                                  TextSpan(
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
                                    children: [
                                      TextSpan(
                                        text: '充值短信包 ',
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
                                      TextSpan(
                                        text: '· 约 ¥0.05–0.06 / 条',
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
                                    ],
                                  ),
                                ),
                              ),
                              HSelHolder(
                                groups: [
                                  ({1}, false),
                                ],
                                builder: (context, g1) => hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: HSel(
                                        ctrl: g1[0],
                                        index: 0,
                                        on: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Color(0xFF0485F7),
                                            width: 1.5,
                                          ),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '1,000 条',
                                                style: hts(
                                                  16,
                                                  dk(
                                                    context,
                                                    Color(0xFF1E63AE),
                                                    Color(0xFF6AB4FA),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 22,
                                                ),
                                              ),
                                              Text(
                                                '¥60',
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
                                            gap: 2,
                                          ),
                                        ),
                                        off: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '1,000 条',
                                                style: hts(
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
                                              Text(
                                                '¥60',
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
                                            gap: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: HSel(
                                        ctrl: g1[0],
                                        index: 1,
                                        on: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Color(0xFF0485F7),
                                            width: 1.5,
                                          ),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '5,000 条',
                                                style: hts(
                                                  16,
                                                  dk(
                                                    context,
                                                    Color(0xFF1E63AE),
                                                    Color(0xFF6AB4FA),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 22,
                                                ),
                                              ),
                                              Text(
                                                '¥270',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF1E63AE),
                                                    Color(0xFF6AB4FA),
                                                  ),
                                                  lh: 16,
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 2,
                                          ),
                                        ),
                                        off: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '5,000 条',
                                                style: hts(
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
                                              Text(
                                                '¥270',
                                                style: hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  lh: 16,
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: HSel(
                                        ctrl: g1[0],
                                        index: 2,
                                        on: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Color(0xFF0485F7),
                                            width: 1.5,
                                          ),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '2 万条',
                                                style: hts(
                                                  16,
                                                  dk(
                                                    context,
                                                    Color(0xFF1E63AE),
                                                    Color(0xFF6AB4FA),
                                                  ),
                                                  w: FontWeight.w600,
                                                  lh: 22,
                                                ),
                                              ),
                                              Text(
                                                '¥1,000',
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
                                            gap: 2,
                                          ),
                                        ),
                                        off: hbox(
                                          bg: dk(
                                            context,
                                            Color(0xFFF4F4F5),
                                            Color(0xFF27272A),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          pad: EdgeInsets.fromLTRB(
                                            0,
                                            12,
                                            0,
                                            12,
                                          ),
                                          child: hcol(
                                            [
                                              Text(
                                                '2 万条',
                                                style: hts(
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
                                              Text(
                                                '¥1,000',
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
                                            gap: 2,
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
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                          ),
                          hTap(
                            context,
                            hbox(
                              h: 46,
                              bg: dk(
                                context,
                                Color(0xFF18181B),
                                Color(0xFFFAFAFA),
                              ),
                              radius: BorderRadius.circular(23),
                              child: Align(
                                alignment: Alignment.center,
                                widthFactor: 1,
                                child: Text(
                                  '充值 ¥270',
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
                            ),
                            label: '充值 ¥270',
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '短信签名',
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
                                      '显示在短信开头，需运营商审核',
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
                              Text(
                                '【驰光汽车】',
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
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(9),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  '已通过',
                                  style: hts(
                                    11,
                                    dk(
                                      context,
                                      Color(0xFF2B7745),
                                      Color(0xFF5FD48C),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '余量不足提醒',
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
                                      '低于 200 条时通知店长',
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
                              HSwitch(initial: true),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '夜间免打扰',
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
                                      '22:00–08:00 不发送短信，次日早晨补发',
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
                              HSwitch(initial: true),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
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
