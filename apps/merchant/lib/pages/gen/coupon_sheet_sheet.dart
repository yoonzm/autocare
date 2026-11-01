import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class CouponSheetSheet extends StatelessWidget {
  const CouponSheetSheet({super.key});

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
            '选择优惠券',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          hcol(
            [
              HToggle(
                initial: true,
                on: hbox(
                  bg: dk(
                    context,
                    Color(0xFFE1F0FE),
                    Color.fromRGBO(4, 133, 247, 0.18),
                  ),
                  radius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                  clip: true,
                  opacity: 1,
                  child: hrow(
                    [
                      hbox(
                        w: 88,
                        bg: Color(0xFF0485F7),
                        pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                        child: hcol(
                          [
                            Text(
                              '-¥200',
                              style: hts(
                                22,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 26,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: hcol(
                            [
                              Text(
                                '新店首购券',
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
                              Text(
                                '订阅任意年付套餐可用 · 有效期至 11.30',
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                    intrinsic: true,
                  ),
                ),
                off: hbox(
                  h: 34,
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(17),
                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: hcol(
                    [
                      Align(
                        alignment: Alignment.topLeft,
                        child: hbox(
                          w: 88,
                          bg: Color(0xFF0485F7),
                          pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                          child: hcol(
                            [
                              Text(
                                '-¥200',
                                style: hts(
                                  22,
                                  Color(0xFFFFFFFF),
                                  w: FontWeight.w600,
                                  lh: 26,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: hcol(
                            [
                              Text(
                                '新店首购券',
                                style: hts(
                                  15,
                                  dk(
                                    context,
                                    Color(0xFF3F3F46),
                                    Color(0xFFD4D4D8),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '订阅任意年付套餐可用 · 有效期至 11.30',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  w: FontWeight.w500,
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 2,
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
              ),
              hTap(
                context,
                hbox(
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(18),
                  clip: true,
                  opacity: .5,
                  child: hrow(
                    [
                      hbox(
                        w: 88,
                        bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                        pad: EdgeInsets.fromLTRB(0, 14, 0, 14),
                        child: hcol(
                          [
                            Text(
                              '-¥150',
                              style: hts(
                                22,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 26,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hbox(
                          pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                          child: hcol(
                            [
                              Text(
                                '续费满减券',
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
                              Text(
                                '续费满 ¥3,000 可用 · 本单不满足',
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                    intrinsic: true,
                  ),
                ),
                label: '-¥150续费满减券续费满 ',
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: hbox(
                  minH: 44,
                  bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                  radius: BorderRadius.circular(14),
                  pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: hrow(
                    [
                      Expanded(
                        child: HInput(
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            lh: 22,
                          ),
                          hint: '输入兑换码',
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
              ),
              hTap(
                context,
                hbox(
                  h: 44,
                  bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                  radius: BorderRadius.circular(22),
                  pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1,
                    child: Text(
                      '兑换',
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        w: FontWeight.w500,
                        lh: 20,
                      ),
                    ),
                  ),
                ),
                label: '兑换',
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 8,
            intrinsic: true,
          ),
          hrow(
            [
              Expanded(
                flex: 10,
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
                        '不使用优惠券',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'PlanCheckout',
                ),
              ),
              Expanded(
                flex: 16,
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
                        '确定 · 减 ¥200',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'PlanCheckout',
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
