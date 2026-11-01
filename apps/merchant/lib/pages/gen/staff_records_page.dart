import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class StaffRecordsPage extends StatelessWidget {
  const StaffRecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 893,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
            child: HSelHolder(
              groups: [
                ({0}, false),
              ],
              builder: (context, g1) => HDyn(
                texts: [
                  '本月台次118本月提成¥8,640平均用时1.8 h',
                  '本月记录沪A·8K29M全车镀晶 · 9H今天 11:20提成 待结算进行中沪AF·09316漆面抛光昨天 15:40+¥60已完成苏E·3QX18石墨烯镀膜10.28 10:10+¥214已完成沪B·7K552内饰深度清洁10.27 16:00+¥38已完成沪C·2L801全车精洗10.27 09:30+¥22已完成沪A·5P906车身打蜡10.25 14:20+¥45已完成',
                ],
                filter: g1[0],
                labels: ['本月', '上月', '全部'],
                builder: (context, d2) => hcol(
                  [
                    hrow(
                      [
                        hTap(
                          context,
                          hbox(
                            w: 44,
                            h: 44,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(22),
                            shadow: dk(
                              context,
                              [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.04),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  offset: Offset(0, 0),
                                  blurRadius: 1,
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
                              [
                                hsvg(
                                  dk(context, Svgs.s0, Svgs.s1),
                                  w: 20,
                                  h: 20,
                                ),
                              ],
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
                            '李国强 · 施工记录',
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
                      bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                      radius: BorderRadius.circular(20),
                      pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                      child: hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
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
                                      color: Color.fromRGBO(0, 0, 0, 0.04),
                                      offset: Offset(0, 2),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.06),
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
                                    '本月',
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
                                    '本月',
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
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 1,
                              on: hbox(
                                h: 32,
                                radius: BorderRadius.circular(16),
                                shadow: dk(context, [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                ], null),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '上月',
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
                                    '上月',
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
                          Expanded(
                            flex: 1,
                            child: HSel(
                              ctrl: g1[0],
                              index: 2,
                              on: hbox(
                                h: 32,
                                radius: BorderRadius.circular(16),
                                shadow: dk(context, [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.04),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.06),
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                    spreadRadius: 0,
                                  ),
                                ], null),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text(
                                    '全部',
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
                                    '全部',
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 2,
                        intrinsic: true,
                      ),
                    ),
                    ...d2.vis([
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '本月台次',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '118',
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF1E63AE),
                                        Color(0xFF6AB4FA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '本月提成',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF2B7745),
                                        Color(0xFF5FD48C),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥8,640',
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF2B7745),
                                        Color(0xFF5FD48C),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: hbox(
                              bg: dk(
                                context,
                                Color(0xFFFDEFD6),
                                Color.fromRGBO(245, 165, 36, 0.16),
                              ),
                              radius: BorderRadius.circular(18),
                              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                              child: hcol(
                                [
                                  Text(
                                    '平均用时',
                                    style: hts(
                                      11,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '1.8 h',
                                    style: hts(
                                      18,
                                      dk(
                                        context,
                                        Color(0xFF855F2E),
                                        Color(0xFFF0C46A),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 24,
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
                        gap: 8,
                        intrinsic: true,
                      ),
                      hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Text(
                              '本月记录',
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
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(24),
                            shadow: dk(
                              context,
                              [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.04),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.06),
                                  offset: Offset(0, 0),
                                  blurRadius: 1,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '沪A·8K29M',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '全车镀晶 · 9H',
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
                                              '今天 11:20',
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
                                      hcol(
                                        [
                                          Text(
                                            '提成 待结算',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFE1F0FE),
                                              Color.fromRGBO(4, 133, 247, 0.18),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '进行中',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF1E63AE),
                                                  Color(0xFF6AB4FA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '沪AF·09316',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '漆面抛光',
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
                                              '昨天 15:40',
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
                                      hcol(
                                        [
                                          Text(
                                            '+¥60',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '已完成',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '苏E·3QX18',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '石墨烯镀膜',
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
                                              '10.28 10:10',
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
                                      hcol(
                                        [
                                          Text(
                                            '+¥214',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '已完成',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '沪B·7K552',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '内饰深度清洁',
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
                                              '10.27 16:00',
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
                                      hcol(
                                        [
                                          Text(
                                            '+¥38',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '已完成',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '沪C·2L801',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '全车精洗',
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
                                              '10.27 09:30',
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
                                      hcol(
                                        [
                                          Text(
                                            '+¥22',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '已完成',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                                  minH: 64,
                                  pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
                                  child: hrow(
                                    [
                                      hbox(
                                        bg: Color(0xFF0B5FD6),
                                        radius: BorderRadius.circular(4),
                                        pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                                        child: Text(
                                          '沪A·5P906',
                                          style: hts(
                                            11,
                                            Color(0xFFFFFFFF),
                                            w: FontWeight.w600,
                                            lh: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: hcol(
                                          [
                                            Text(
                                              '车身打蜡',
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
                                              '10.25 14:20',
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
                                      hcol(
                                        [
                                          Text(
                                            '+¥45',
                                            style: hts(
                                              14,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              w: FontWeight.w600,
                                            ),
                                          ),
                                          hbox(
                                            bg: dk(
                                              context,
                                              Color(0xFFEEEEF0),
                                              Color(0xFF27272A),
                                            ),
                                            radius: BorderRadius.circular(9),
                                            pad: EdgeInsets.fromLTRB(
                                              8,
                                              0,
                                              8,
                                              0,
                                            ),
                                            child: Text(
                                              '已完成',
                                              style: hts(
                                                11,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 18,
                                              ),
                                              softWrap: false,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.end,
                                        gap: 2,
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
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 8,
                      ),
                    ]),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
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
