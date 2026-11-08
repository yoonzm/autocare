import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 959,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
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
                        '套餐与订阅',
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
                        hrow(
                          [
                            hLiveText(
                              (p) => p.subscriptionName,
                              hts(
                                20,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 28,
                              ),
                            ),
                            hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: hLiveText(
                                (p) => p.plan == 'trial' ? '试用' : '账号订阅',
                                hts(
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
                            Expanded(flex: 1, child: SizedBox.shrink()),
                            hbox(
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                              child: hLiveText(
                                (p) => p.subscriptionDays > 0 ? '使用中' : '已到期',
                                hts(
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
                          gap: 8,
                        ),
                        hrow(
                          [
                            Flexible(
                              flex: 70,
                              child: hLiveText(
                                (p) => p.subscriptionDays.toString(),
                                hts(
                                  40,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w600,
                                  lh: 44,
                                  ls: -1,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 150,
                              child: hLiveText(
                                (p) => '天后到期 · ${p.trialEndText}',
                                hts(
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
                        hbox(
                          h: 6,
                          bg: Color(0xFF27272A),
                          radius: BorderRadius.circular(3),
                          child: hcol(
                            [
                              hbox(
                                h: 6,
                                bg: Color(0xFFF5D78E),
                                radius: BorderRadius.circular(3),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                            min: false,
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
                                    h: 44,
                                    bg: Color(0xFFF5D78E),
                                    radius: BorderRadius.circular(22),
                                    child: Align(
                                      alignment: Alignment(0, 0),
                                      widthFactor: 1,
                                      child: Text(
                                        '续费',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  to: 'Renew',
                                ),
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
                                    h: 44,
                                    bg: Color(0xFF27272A),
                                    radius: BorderRadius.circular(22),
                                    child: Align(
                                      alignment: Alignment(0, 0),
                                      widthFactor: 1,
                                      child: Text(
                                        '升级套餐',
                                        style: hts(
                                          15,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  to: 'Plans',
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 10,
                          intrinsic: true,
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
                        '用量 · 本订阅周期',
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
                          hcol(
                            [
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '员工账号',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  hSubscriptionUsage(
                                    'staff',
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.baseline,
                                gap: 0,
                              ),
                              hbox(
                                h: 6,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(3),
                                clip: true,
                                child: hcol(
                                  [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hSubscriptionFraction(
                                        'staff',
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
                            gap: 8,
                          ),
                          hcol(
                            [
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '门店数量',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  hSubscriptionUsage(
                                    'stores',
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.baseline,
                                gap: 0,
                              ),
                              hbox(
                                h: 6,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(3),
                                clip: true,
                                child: hcol(
                                  [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hSubscriptionFraction(
                                        'stores',
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
                            gap: 8,
                          ),
                          hcol(
                            [
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '本月套餐内短信',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  hSubscriptionUsage(
                                    'sms',
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                    ),
                                    hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFFA1A1AA),
                                        Color(0xFF80808A),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.baseline,
                                gap: 0,
                              ),
                              hbox(
                                h: 6,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(3),
                                clip: true,
                                child: hcol(
                                  [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: hfrac(
                                        0.08,
                                        hbox(
                                          h: 6,
                                          bg: Color(0xFF17C964),
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
                  gap: 8,
                ),
                hcol(
                  [
                    hbox(
                      pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                      child: Text(
                        '订阅管理',
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
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '自动续费',
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
                                      hLiveText(
                                        (p) => '自动续费尚未开通',
                                        hts(
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
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hTap(
                            context,
                            hbox(
                              minH: 54,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '支付方式',
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
                                  hLiveText(
                                    (p) => '尚未绑定',
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
                            to: 'PayMethod',
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
                          hTap(
                            context,
                            hbox(
                              minH: 54,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '账单与发票',
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
                                  hLiveText(
                                    (p) => '查看账单',
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
                            to: 'Invoices',
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
                                  child: hcol(
                                    [
                                      Text(
                                        '到期提醒',
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
                                        '提前 30、7、3 天通知店长',
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
                hTap(
                  context,
                  Text(
                    '查看全部套餐与功能对比',
                    style: hts(
                      14,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      w: FontWeight.w500,
                      lh: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  to: 'Plans',
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
