import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class NotifySettingsPage extends StatelessWidget {
  const NotifySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1320,
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
                        '通知与消息',
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
                      bottom: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                    ),
                  ),
                  child: hstack(
                    hcol(
                      [
                        hcol(
                          [
                            Text(
                              '本月已通知会员',
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
                                  flex: 63,
                                  child: Text(
                                    '326',
                                    style: hts(
                                      36,
                                      Color(0xFFFAFAFA),
                                      w: FontWeight.w600,
                                      lh: 44,
                                      ls: -0.5,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 14,
                                  child: Text(
                                    '条',
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
                              gap: 6,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 4,
                        ),
                        hcol(
                          [
                            hbox(
                              h: 8,
                              radius: BorderRadius.circular(4),
                              clip: true,
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 760,
                                    child: hbox(
                                      bg: Color(0xFF17C964),
                                      radius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 240,
                                    child: hbox(
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                                intrinsic: true,
                              ),
                            ),
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 8,
                                        h: 8,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(4),
                                      ),
                                      Flexible(
                                        flex: 101,
                                        child: Text(
                                          '微信 248 条 · 免费',
                                          style: hts(
                                            12,
                                            Color(0xFFD4D4D8),
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 6,
                                  ),
                                ),
                                hrow(
                                  [
                                    hbox(
                                      w: 8,
                                      h: 8,
                                      bg: Color(0xFF0485F7),
                                      radius: BorderRadius.circular(4),
                                    ),
                                    Flexible(
                                      flex: 112,
                                      child: Text(
                                        '短信 78 条 · 约 ¥4.7',
                                        style: hts(
                                          12,
                                          Color(0xFFD4D4D8),
                                          lh: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 6,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
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
                    [],
                    behind: [
                      Positioned(
                        top: -110,
                        right: -110,
                        child: hsvg(Svgs.s7, w: 240, h: 240),
                      ),
                    ],
                  ),
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '发送渠道 · 商家自选',
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
                            minH: 76,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 76,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 40,
                                            h: 40,
                                            bg: dk(
                                              context,
                                              Color(0xFFDDF6E7),
                                              Color.fromRGBO(
                                                23,
                                                201,
                                                100,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(13),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s254,
                                                    Svgs.s255,
                                                  ),
                                                  w: 22,
                                                  h: 22,
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
                                                  '微信模板消息',
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
                                                hrow(
                                                  [
                                                    hbox(
                                                      w: 6,
                                                      h: 6,
                                                      bg: Color(0xFF17C964),
                                                      radius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    Flexible(
                                                      flex: 157,
                                                      child: Text(
                                                        '已授权 · 驰光汽车美容服务号',
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
                                                  cross:
                                                      CrossAxisAlignment.center,
                                                  gap: 5,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 2,
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
                                    to: 'ChannelConfig',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
                          ),
                          hbox(
                            minH: 76,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 76,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 40,
                                            h: 40,
                                            bg: dk(
                                              context,
                                              Color(0xFFE1F0FE),
                                              Color.fromRGBO(4, 133, 247, 0.18),
                                            ),
                                            radius: BorderRadius.circular(13),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s256,
                                                    Svgs.s257,
                                                  ),
                                                  w: 22,
                                                  h: 22,
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
                                                  '短信',
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
                                                hrow(
                                                  [
                                                    hbox(
                                                      w: 6,
                                                      h: 6,
                                                      bg: Color(0xFF17C964),
                                                      radius:
                                                          BorderRadius.circular(
                                                            3,
                                                          ),
                                                    ),
                                                    Flexible(
                                                      flex: 159,
                                                      child: Text(
                                                        '【驰光汽车】· 剩余 1,240 条',
                                                        style: hts(
                                                          12,
                                                          dk(
                                                            context,
                                                            Color(0xFF52525B),
                                                            Color(0xFFA8A8B3),
                                                          ),
                                                          lh: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross:
                                                      CrossAxisAlignment.center,
                                                  gap: 5,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 2,
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
                                    to: 'ChannelConfig',
                                  ),
                                ),
                                HSwitch(initial: true),
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
                        '发送策略',
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
                      child: HSelHolder(
                        groups: [
                          ({0}, false),
                        ],
                        builder: (context, g1) => hcol(
                          [
                            HSel(
                              ctrl: g1[0],
                              index: 0,
                              on: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          hrow(
                                            [
                                              Flexible(
                                                flex: 150,
                                                child: Text(
                                                  '优先微信，失败转短信',
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
                                              ),
                                              Flexible(
                                                flex: 34,
                                                child: hbox(
                                                  bg: dk(
                                                    context,
                                                    Color(0xFFE1F0FE),
                                                    Color.fromRGBO(
                                                      4,
                                                      133,
                                                      247,
                                                      0.18,
                                                    ),
                                                  ),
                                                  radius: BorderRadius.circular(
                                                    8,
                                                  ),
                                                  pad: EdgeInsets.fromLTRB(
                                                    6,
                                                    1,
                                                    6,
                                                    1,
                                                  ),
                                                  child: Text(
                                                    '推荐',
                                                    style: hts(
                                                      11,
                                                      dk(
                                                        context,
                                                        Color(0xFF1E63AE),
                                                        Color(0xFF6AB4FA),
                                                      ),
                                                      w: FontWeight.w600,
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 6,
                                          ),
                                          Text(
                                            '会员已关注公众号走微信，否则自动发短信',
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
                              off: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          hrow(
                                            [
                                              Flexible(
                                                flex: 150,
                                                child: Text(
                                                  '优先微信，失败转短信',
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
                                              ),
                                              Flexible(
                                                flex: 34,
                                                child: hbox(
                                                  bg: dk(
                                                    context,
                                                    Color(0xFFE1F0FE),
                                                    Color.fromRGBO(
                                                      4,
                                                      133,
                                                      247,
                                                      0.18,
                                                    ),
                                                  ),
                                                  radius: BorderRadius.circular(
                                                    8,
                                                  ),
                                                  pad: EdgeInsets.fromLTRB(
                                                    6,
                                                    1,
                                                    6,
                                                    1,
                                                  ),
                                                  child: Text(
                                                    '推荐',
                                                    style: hts(
                                                      11,
                                                      dk(
                                                        context,
                                                        Color(0xFF1E63AE),
                                                        Color(0xFF6AB4FA),
                                                      ),
                                                      w: FontWeight.w600,
                                                      lh: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 6,
                                          ),
                                          Text(
                                            '会员已关注公众号走微信，否则自动发短信',
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
                            HSel(
                              ctrl: g1[0],
                              index: 1,
                              on: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '仅微信',
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
                                          Text(
                                            '不产生费用，未关注公众号的会员收不到',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              off: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '仅微信',
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
                                          Text(
                                            '不产生费用，未关注公众号的会员收不到',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
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
                            HSel(
                              ctrl: g1[0],
                              index: 2,
                              on: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '仅短信',
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
                                          Text(
                                            '所有会员都能收到，按条计费',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              off: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '仅短信',
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
                                          Text(
                                            '所有会员都能收到，按条计费',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
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
                            HSel(
                              ctrl: g1[0],
                              index: 3,
                              on: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '微信 + 短信同时发',
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
                                          Text(
                                            '重要通知双保险，费用最高',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              off: hbox(
                                minH: 60,
                                pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: hcol(
                                        [
                                          Text(
                                            '微信 + 短信同时发',
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
                                          Text(
                                            '重要通知双保险，费用最高',
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
                                      border: dk(
                                        context,
                                        Border.all(
                                          color: Color(0xFFD4D4D8),
                                          width: 2,
                                        ),
                                        Border.all(
                                          color: Color(0xFF3F3F46),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
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
                        '通知场景 · 点击编辑内容',
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
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: dk(
                                              context,
                                              Color(0xFFE1F0FE),
                                              Color.fromRGBO(4, 133, 247, 0.18),
                                            ),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s169,
                                                    Svgs.s170,
                                                  ),
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
                                                  '消费扣款',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFDDF6E7),
                                                          Color.fromRGBO(
                                                            23,
                                                            201,
                                                            100,
                                                            0.16,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '微信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF2B7745),
                                                              Color(0xFF5FD48C),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFE1F0FE),
                                                          Color.fromRGBO(
                                                            4,
                                                            133,
                                                            247,
                                                            0.18,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '短信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF1E63AE),
                                                              Color(0xFF6AB4FA),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: dk(
                                              context,
                                              Color(0xFFDDF6E7),
                                              Color.fromRGBO(
                                                23,
                                                201,
                                                100,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s258,
                                                    Svgs.s259,
                                                  ),
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
                                                  '储值充值',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFDDF6E7),
                                                          Color.fromRGBO(
                                                            23,
                                                            201,
                                                            100,
                                                            0.16,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '微信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF2B7745),
                                                              Color(0xFF5FD48C),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFE1F0FE),
                                                          Color.fromRGBO(
                                                            4,
                                                            133,
                                                            247,
                                                            0.18,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '短信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF1E63AE),
                                                              Color(0xFF6AB4FA),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s260,
                                                    Svgs.s261,
                                                  ),
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
                                                  '次卡核销',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFDDF6E7),
                                                          Color.fromRGBO(
                                                            23,
                                                            201,
                                                            100,
                                                            0.16,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '微信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF2B7745),
                                                              Color(0xFF5FD48C),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: dk(
                                              context,
                                              Color(0xFFFFE1E2),
                                              Color.fromRGBO(255, 56, 60, 0.18),
                                            ),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s262,
                                                    Svgs.s263,
                                                  ),
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
                                                Text.rich(
                                                  TextSpan(
                                                    style: hts(
                                                      15,
                                                      dk(
                                                        context,
                                                        Color(0xFF18181B),
                                                        Color(0xFFFAFAFA),
                                                      ),
                                                      lh: 22,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: '余额不足 ',
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
                                                      TextSpan(
                                                        text: '· 低于 ¥300',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFE1F0FE),
                                                          Color.fromRGBO(
                                                            4,
                                                            133,
                                                            247,
                                                            0.18,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '短信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF1E63AE),
                                                              Color(0xFF6AB4FA),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: dk(
                                              context,
                                              Color(0xFFFDEFD6),
                                              Color.fromRGBO(
                                                245,
                                                165,
                                                36,
                                                0.16,
                                              ),
                                            ),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s264,
                                                    Svgs.s265,
                                                  ),
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
                                                Text.rich(
                                                  TextSpan(
                                                    style: hts(
                                                      15,
                                                      dk(
                                                        context,
                                                        Color(0xFF18181B),
                                                        Color(0xFFFAFAFA),
                                                      ),
                                                      lh: 22,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: '次卡将到期 ',
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
                                                      TextSpan(
                                                        text: '· 提前 7 天',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFDDF6E7),
                                                          Color.fromRGBO(
                                                            23,
                                                            201,
                                                            100,
                                                            0.16,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '微信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF2B7745),
                                                              Color(0xFF5FD48C),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      flex: 34,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFE1F0FE),
                                                          Color.fromRGBO(
                                                            4,
                                                            133,
                                                            247,
                                                            0.18,
                                                          ),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '短信',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF1E63AE),
                                                              Color(0xFF6AB4FA),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hTap(
                                    context,
                                    hbox(
                                      minH: 64,
                                      child: hrow(
                                        [
                                          hbox(
                                            w: 32,
                                            h: 32,
                                            bg: Color(0xFFF5D78E),
                                            radius: BorderRadius.circular(10),
                                            child: hrow(
                                              [
                                                hsvg(
                                                  dk(
                                                    context,
                                                    Svgs.s266,
                                                    Svgs.s267,
                                                  ),
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
                                                Text.rich(
                                                  TextSpan(
                                                    style: hts(
                                                      15,
                                                      dk(
                                                        context,
                                                        Color(0xFF18181B),
                                                        Color(0xFFFAFAFA),
                                                      ),
                                                      lh: 22,
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: '生日祝福 ',
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
                                                      TextSpan(
                                                        text: '· 当天 09:00',
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
                                                hrow(
                                                  [
                                                    Flexible(
                                                      flex: 67,
                                                      child: hbox(
                                                        bg: dk(
                                                          context,
                                                          Color(0xFFEEEEF0),
                                                          Color(0xFF27272A),
                                                        ),
                                                        radius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        pad:
                                                            EdgeInsets.fromLTRB(
                                                              6,
                                                              0,
                                                              6,
                                                              0,
                                                            ),
                                                        child: Text(
                                                          '未选择渠道',
                                                          style: hts(
                                                            11,
                                                            dk(
                                                              context,
                                                              Color(0xFF71717A),
                                                              Color(0xFF9A9AA3),
                                                            ),
                                                            w: FontWeight.w500,
                                                            lh: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  main: MainAxisAlignment.start,
                                                  cross: CrossAxisAlignment
                                                      .stretch,
                                                  gap: 4,
                                                  intrinsic: true,
                                                ),
                                              ],
                                              main: MainAxisAlignment.start,
                                              cross: CrossAxisAlignment.stretch,
                                              gap: 3,
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
                                    to: 'NotifyTemplate',
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
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                ),
                hTap(
                  context,
                  hbox(
                    h: 56,
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
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(10),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s268, Svgs.s269),
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
                          child: Text(
                            '发送记录',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              lh: 22,
                            ),
                          ),
                        ),
                        Text(
                          '今日 12 条 · 1 条失败',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 18,
                          ),
                        ),
                        hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                  to: 'NotifyLog',
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
