import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StaffCommissionPage extends StatelessWidget {
  const StaffCommissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
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
                        '提成方案',
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
                      to: 'StaffDetail',
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(22),
                  pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                        radius: BorderRadius.circular(20),
                        align: Alignment(0, 0),
                        child: Text(
                          '李',
                          style: hts(
                            15,
                            dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                            w: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: hcol(
                          [
                            Text(
                              '李国强',
                              style: hts(
                                16,
                                Color(0xFFFAFAFA),
                                w: FontWeight.w600,
                                lh: 22,
                              ),
                            ),
                            Text(
                              '施工技师 · 上月提成 ¥8,640',
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
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hcol(
                  [
                    hbox(
                      bg: Color(0xFFF2F8FE),
                      radius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFF0485F7), width: 1.5),
                      pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '跟随项目设置',
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
                                      '按「服务项目」中各项目设定的提成比例计算',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 17,
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
                          hbox(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFDCEBFB),
                                width: 1,
                              ),
                            ),
                            pad: EdgeInsets.fromLTRB(0, 10, 0, 0),
                            child: hcol(
                              [
                                hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '全车镀晶 · 9H',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '15%',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 8,
                                ),
                                hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '漆面抛光',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '12%',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 8,
                                ),
                                hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '精致洗车',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF52525B),
                                            Color(0xFFA8A8B3),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '8%',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w600,
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
                              gap: 8,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(20),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFE4E4E7), width: 1),
                        Border.all(color: Color(0xFF3A3A40), width: 1),
                      ),
                      pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '统一比例',
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
                                      '所有项目按同一比例，覆盖项目设置',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 17,
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(20),
                      border: dk(
                        context,
                        Border.all(color: Color(0xFFE4E4E7), width: 1),
                        Border.all(color: Color(0xFF3A3A40), width: 1),
                      ),
                      pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: hcol(
                                  [
                                    Text(
                                      '按项目自定义',
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
                                      '仅对该员工单独设置，其余项目仍跟随项目设置',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 17,
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 10,
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Text(
                    '修改后仅对之后完工的订单生效，已完成订单的提成不会重算。',
                    style: hts(
                      12,
                      dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                      lh: 18,
                    ),
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
