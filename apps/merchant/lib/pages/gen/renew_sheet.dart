import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class RenewSheet extends StatelessWidget {
  const RenewSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '续费 · 专业版',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          Text(
            '当前到期日 2027.10.30，续费后顺延',
            style: hts(
              13,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 18,
            ),
          ),
          HSelHolder(
            groups: [
              ({2}, false),
            ],
            builder: (context, g1) => hcol(
              [
                HSel(
                  ctrl: g1[0],
                  index: 0,
                  on: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 43,
                                    child: Text(
                                      '1 个月',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2027.11.30',
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
                          '¥399',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                  off: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 43,
                                    child: Text(
                                      '1 个月',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2027.11.30',
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
                          '¥399',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                ),
                HSel(
                  ctrl: g1[0],
                  index: 1,
                  on: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 43,
                                    child: Text(
                                      '3 个月',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2028.01.30 · 95 折',
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
                          '¥1,137',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                  off: hbox(
                    bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 43,
                                    child: Text(
                                      '3 个月',
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
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2028.01.30 · 95 折',
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
                          '¥1,137',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                ),
                HSel(
                  ctrl: g1[0],
                  index: 2,
                  on: hbox(
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(18),
                    border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 52,
                                    child: Text(
                                      '12 个月',
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
                                        Color(0xFFFDEFD6),
                                        Color.fromRGBO(245, 165, 36, 0.16),
                                      ),
                                      radius: BorderRadius.circular(9),
                                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Text(
                                        '推荐',
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
                                        softWrap: false,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2028.10.30 · 省 ¥798',
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
                          '¥3,990',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                  off: hbox(
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              hrow(
                                [
                                  Flexible(
                                    flex: 52,
                                    child: Text(
                                      '12 个月',
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
                                        Color(0xFFFDEFD6),
                                        Color.fromRGBO(245, 165, 36, 0.16),
                                      ),
                                      radius: BorderRadius.circular(9),
                                      pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                      child: Text(
                                        '推荐',
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
                                        softWrap: false,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                              Text(
                                '到期日顺延至 2028.10.30 · 省 ¥798',
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
                          '¥3,990',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
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
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
          ),
          hbox(
            bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
            radius: BorderRadius.circular(18),
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hrow(
              [
                hbox(
                  w: 36,
                  h: 36,
                  bg: dk(
                    context,
                    Color(0xFFDDF6E7),
                    Color.fromRGBO(23, 201, 100, 0.16),
                  ),
                  radius: BorderRadius.circular(12),
                  child: hrow(
                    [hsvg(dk(context, Svgs.s258, Svgs.s259), w: 18, h: 18)],
                    main: MainAxisAlignment.center,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '微信支付',
                    style: hts(
                      15,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w500,
                    ),
                  ),
                ),
                hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '取消',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'Subscription',
                ),
              ),
              Expanded(
                flex: 2,
                child: hTap(
                  context,
                  hbox(
                    h: 50,
                    bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    radius: BorderRadius.circular(25),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '确认支付 ¥3,990',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'RenewPaid',
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
        gap: 14,
      ),
    );
  }
}
