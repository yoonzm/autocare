import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class FindResultCodeSheet extends StatelessWidget {
  const FindResultCodeSheet({super.key});

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
          hrow(
            [
              hbox(
                w: 48,
                h: 48,
                bg: Color(0xFF27272A),
                radius: BorderRadius.circular(10),
                child: hrow(
                  [hsvg(Svgs.s161, w: 24, h: 24)],
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
                      '会员码识别成功',
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
                            Color(0xFFDDF6E7),
                            Color.fromRGBO(23, 201, 100, 0.16),
                          ),
                          radius: BorderRadius.circular(10),
                          pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s156, Svgs.s157),
                                w: 12,
                                h: 12,
                              ),
                              Flexible(
                                flex: 48,
                                child: Text(
                                  '识别成功',
                                  style: hts(
                                    12,
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
                            gap: 4,
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
                  gap: 4,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 12,
          ),
          hbox(
            bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
            radius: BorderRadius.circular(20),
            pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: hrow(
              [
                hbox(
                  w: 44,
                  h: 44,
                  bg: Color(0xFFF5D78E),
                  radius: BorderRadius.circular(22),
                  align: Alignment(0, 0),
                  child: Text(
                    '王',
                    style: hts(
                      17,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      hrow(
                        [
                          Flexible(
                            flex: 48,
                            child: Text(
                              '王建国',
                              style: hts(
                                16,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 58,
                            child: hbox(
                              bg: Color(0xFFF5D78E),
                              radius: BorderRadius.circular(9),
                              pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                              child: Text(
                                '黑金会员',
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
                      Text(
                        '138 **** 6021',
                        style: hts(
                          12,
                          dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          lh: 16,
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
                      '储值余额',
                      style: hts(
                        11,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      ),
                    ),
                    Text(
                      '¥3,680',
                      style: hts(
                        17,
                        Color(0xFFFAFAFA),
                        w: FontWeight.w600,
                        lh: 24,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.end,
                  gap: 0,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 12,
            ),
          ),
          hcol(
            [
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '车牌号',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hcol(
                        [
                          hbox(
                            grad: LinearGradient(
                              begin: Alignment(-0, -1),
                              end: Alignment(0, 1),
                              colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)],
                              stops: [0, 1],
                            ),
                            radius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Color.fromRGBO(255, 255, 255, 0.75),
                              width: 1.5,
                            ),
                            pad: EdgeInsets.fromLTRB(9, 2, 9, 2),
                            child: Text(
                              '沪A·8K29M',
                              style: hts(
                                14,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 20,
                                ls: 0.5,
                              ),
                              softWrap: false,
                              maxLines: 1,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                    Text(
                      '蓝牌',
                      style: hts(
                        12,
                        dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '车型',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '宝马 5系 525Li · 黑',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '次卡',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '洗车年卡 8 次 · 内饰清洁 2 次',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 12,
                ),
              ),
              hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
              hbox(
                minH: 50,
                child: hrow(
                  [
                    hbox(
                      w: 64,
                      child: Text(
                        '上次到店',
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 18,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '10.31 · 精致洗车',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                          lh: 22,
                        ),
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
          hbox(
            bg: dk(
              context,
              Color(0xFFE1F0FE),
              Color.fromRGBO(4, 133, 247, 0.18),
            ),
            radius: BorderRadius.circular(14),
            pad: EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: hrow(
              [
                hsvg(dk(context, Svgs.s158, Svgs.s159), w: 16, h: 16),
                Flexible(
                  flex: 261,
                  child: Text(
                    '会员码每 60 秒刷新，过期后请让会员重新出示。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                      lh: 18,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 10,
                child: hTap(
                  context,
                  hbox(
                    h: 48,
                    bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                    radius: BorderRadius.circular(24),
                    child: Align(
                      alignment: Alignment(0, 0),
                      widthFactor: 1,
                      child: Text(
                        '查看会员',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  to: 'MemberDetail',
                ),
              ),
              Expanded(
                flex: 14,
                child: hTap(
                  context,
                  hbox(
                    h: 48,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(24),
                    child: hrow(
                      [
                        hsvg(Svgs.s160, w: 18, h: 18),
                        Flexible(
                          flex: 60,
                          child: Text(
                            '为他开单',
                            style: hts(
                              15,
                              Color(0xFFFFFFFF),
                              w: FontWeight.w600,
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
            cross: CrossAxisAlignment.stretch,
            gap: 10,
            intrinsic: true,
          ),
          Align(
            alignment: Alignment.topCenter,
            child: hTap(
              context,
              Text(
                '识别不对？重新扫描',
                style: hts(
                  13,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 18,
                ),
              ),
              to: 'FindScanCode',
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
