import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class RechargePickSheet extends StatelessWidget {
  const RechargePickSheet({super.key});

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
            '选择次卡套餐',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hcol(
            [
              hbox(
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
                                flex: 90,
                                child: Text(
                                  '精致洗车年卡',
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
                                    Color(0xFFFFE1E2),
                                    Color.fromRGBO(255, 56, 60, 0.18),
                                  ),
                                  radius: BorderRadius.circular(9),
                                  pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                  child: Text(
                                    '热卖',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFFA43433),
                                        Color(0xFFFF7B7E),
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
                          Text(
                            '20 次 · 12 个月有效',
                            style: hts(
                              12,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hcol(
                      [
                        Text(
                          '¥1,080',
                          style: hts(
                            16,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          '¥1,360',
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.end,
                      gap: 0,
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(11),
                      child: hrow(
                        [hsvg(Svgs.s309, w: 14, h: 14)],
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
              hbox(
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
                                flex: 116,
                                child: Text(
                                  '精致洗车 10 次卡',
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
                            '10 次 · 6 个月有效',
                            style: hts(
                              12,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hcol(
                      [
                        Text(
                          '¥580',
                          style: hts(
                            16,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          '¥680',
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.end,
                      gap: 0,
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 2),
                        Border.all(color: Color(0xFF3F3F46), width: 2),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
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
                                flex: 138,
                                child: Text(
                                  '内饰深度清洁 6 次卡',
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
                            '6 次 · 12 个月有效',
                            style: hts(
                              12,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hcol(
                      [
                        Text(
                          '¥1,380',
                          style: hts(
                            16,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          '¥1,788',
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.end,
                      gap: 0,
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 2),
                        Border.all(color: Color(0xFF3F3F46), width: 2),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
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
                                flex: 108,
                                child: Text(
                                  '镀晶养护 3 次卡',
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
                            '3 次 · 12 个月有效',
                            style: hts(
                              12,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hcol(
                      [
                        Text(
                          '¥2,980',
                          style: hts(
                            16,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          '¥3,540',
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.end,
                      gap: 0,
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 2),
                        Border.all(color: Color(0xFF3F3F46), width: 2),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(
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
                                flex: 108,
                                child: Text(
                                  '空调杀菌 4 次卡',
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
                            '4 次 · 6 个月有效',
                            style: hts(
                              12,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 17,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                      ),
                    ),
                    hcol(
                      [
                        Text(
                          '¥380',
                          style: hts(
                            16,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                        Text(
                          '¥480',
                          style: hts(
                            11,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.end,
                      gap: 0,
                    ),
                    hbox(
                      w: 22,
                      h: 22,
                      radius: BorderRadius.circular(11),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFD4D4D8), width: 2),
                        Border.all(color: Color(0xFF3F3F46), width: 2),
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
            gap: 8,
          ),
          Text(
            '已下架的套餐不可售卖，不在此列出',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 17,
            ),
          ),
          hTap(
            context,
            hbox(
              h: 48,
              bg: Color(0xFF0485F7),
              radius: BorderRadius.circular(24),
              child: Align(
                alignment: Alignment(0, 0),
                widthFactor: 1,
                child: Text(
                  '确定',
                  style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600),
                ),
              ),
            ),
            to: 'RechargeCard',
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
