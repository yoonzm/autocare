import 'package:flutter/material.dart';

import '../../kit/kit.dart';

/// 由设计稿“AppointmentSchedule”页分段控件之后的内容生成，嵌入同一界面的对应视图。
class AppointmentScheduleBody extends StatelessWidget {
  const AppointmentScheduleBody({super.key});

  @override
  Widget build(BuildContext context) {
    return hcol(
      [
        hbox(
          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
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
          pad: EdgeInsets.fromLTRB(8, 14, 0, 14),
          clip: true,
          child: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(40, 0, 0, 0),
                child: hrow(
                  [
                    hbox(
                      w: 62,
                      child: Text(
                        '1 号',
                        style: hts(
                          12,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(
                      w: 62,
                      child: Text(
                        '2 号',
                        style: hts(
                          12,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(
                      w: 62,
                      child: Text(
                        '3 号',
                        style: hts(
                          12,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(
                      w: 62,
                      child: Text(
                        '4 号',
                        style: hts(
                          12,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(
                      w: 62,
                      child: Text(
                        '贴膜间',
                        style: hts(
                          12,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          w: FontWeight.w600,
                          lh: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.start,
                  gap: 0,
                ),
              ),
              hbox(
                h: 484,
                margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: hstack(
                  hcol(
                    [],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                    min: false,
                  ),
                  [
                    Positioned(
                      left: 0,
                      top: 0,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: -7,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '09:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 44,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 37,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '10:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 88,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 81,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '11:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 132,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 125,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '12:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 176,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 169,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '13:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 220,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 213,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '14:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 264,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 257,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '15:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 308,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 301,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '16:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 352,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 345,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '17:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 396,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 389,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '18:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 440,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 433,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '19:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 484,
                      right: 0,
                      height: 1,
                      child: hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 477,
                      width: 34,
                      child: hbox(
                        w: 34,
                        child: Text(
                          '20:00',
                          style: hts(
                            10,
                            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                            lh: 14,
                            tab: true,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 40,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 102,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 164,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 226,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 288,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 350,
                      top: 0,
                      bottom: 0,
                      width: 1,
                      child: hbox(
                        w: 1,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                      ),
                    ),
                    Positioned(
                      left: 42,
                      top: 24,
                      width: 58,
                      height: 40,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 40,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFA1A1AA),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪B·3D82',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '赵女士',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 42,
                      top: 398,
                      width: 58,
                      height: 62,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 62,
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF0485F7),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪A·6Q55',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '周女士',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 104,
                      top: 90,
                      width: 58,
                      height: 62,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 62,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFA1A1AA),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪A·7L30',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '陈女士',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 104,
                      top: 288,
                      width: 58,
                      height: 62,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 62,
                          bg: dk(
                            context,
                            Color(0xFFDDF6E7),
                            Color.fromRGBO(23, 201, 100, 0.16),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF17C964),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '苏K·5F21',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF2B7745),
                                    Color(0xFF5FD48C),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '散客',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF2B7745),
                                    Color(0xFF5FD48C),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 166,
                      top: 223.3,
                      width: 58,
                      height: 126.7,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 126.7,
                          bg: dk(
                            context,
                            Color(0xFFFDEFD6),
                            Color.fromRGBO(245, 165, 36, 0.16),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFF5A524),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪A·8K29',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '王建国',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 228,
                      top: 332,
                      width: 58,
                      height: 40,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 40,
                          bg: dk(
                            context,
                            Color(0xFFFFE1E2),
                            Color.fromRGBO(255, 56, 60, 0.18),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFFF383C),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪A·2M11',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFFA43433),
                                    Color(0xFFFF7B7E),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '孙先生',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFFA43433),
                                    Color(0xFFFF7B7E),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 228,
                      top: 376,
                      width: 58,
                      height: 62,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 62,
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFF0485F7),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪C·9H31',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '刘先生',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 290,
                      top: 2,
                      width: 58,
                      height: 480,
                      child: hTap(
                        context,
                        hbox(
                          w: 58,
                          h: 480,
                          bg: dk(
                            context,
                            Color(0xFFFDEFD6),
                            Color.fromRGBO(245, 165, 36, 0.16),
                          ),
                          radius: BorderRadius.circular(10),
                          border: Border(
                            left: BorderSide(
                              color: Color(0xFFF5A524),
                              width: 3,
                            ),
                          ),
                          pad: EdgeInsets.fromLTRB(5, 4, 5, 4),
                          clip: true,
                          child: hcol(
                            [
                              Text(
                                '沪AD·6120',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
                                  w: FontWeight.w700,
                                  lh: 13,
                                ),
                              ),
                              Text(
                                '隐形车衣',
                                style: hts(
                                  10,
                                  dk(
                                    context,
                                    Color(0xFF855F2E),
                                    Color(0xFFF0C46A),
                                  ),
                                  lh: 13,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 1,
                            min: false,
                          ),
                        ),
                        to: 'AppointmentDetail',
                      ),
                    ),
                    Positioned(
                      left: 36,
                      top: 342.5,
                      right: 0,
                      height: 2,
                      child: hbox(h: 2, bg: Color(0xFFFF383C)),
                    ),
                    Positioned(
                      left: 32,
                      top: 338.5,
                      width: 8,
                      height: 8,
                      child: hbox(
                        w: 8,
                        h: 8,
                        bg: Color(0xFFFF383C),
                        radius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              hwrap(
                [
                  hrow(
                    [
                      hbox(
                        w: 10,
                        h: 10,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(3),
                      ),
                      Flexible(
                        flex: 33,
                        child: Text(
                          '待到店',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 14,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 5,
                  ),
                  hrow(
                    [
                      hbox(
                        w: 10,
                        h: 10,
                        bg: dk(
                          context,
                          Color(0xFFDDF6E7),
                          Color.fromRGBO(23, 201, 100, 0.16),
                        ),
                        radius: BorderRadius.circular(3),
                      ),
                      Flexible(
                        flex: 33,
                        child: Text(
                          '已到店',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 14,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 5,
                  ),
                  hrow(
                    [
                      hbox(
                        w: 10,
                        h: 10,
                        bg: dk(
                          context,
                          Color(0xFFFDEFD6),
                          Color.fromRGBO(245, 165, 36, 0.16),
                        ),
                        radius: BorderRadius.circular(3),
                      ),
                      Flexible(
                        flex: 33,
                        child: Text(
                          '施工中',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 14,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 5,
                  ),
                  hrow(
                    [
                      hbox(
                        w: 10,
                        h: 10,
                        bg: dk(
                          context,
                          Color(0xFFFFE1E2),
                          Color.fromRGBO(255, 56, 60, 0.18),
                        ),
                        radius: BorderRadius.circular(3),
                      ),
                      Flexible(
                        flex: 44,
                        child: Text(
                          '超时未到',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 14,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 5,
                  ),
                  hrow(
                    [
                      hbox(
                        w: 10,
                        h: 10,
                        bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                        radius: BorderRadius.circular(3),
                      ),
                      Flexible(
                        flex: 33,
                        child: Text(
                          '已完成',
                          style: hts(
                            11,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 14,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 5,
                  ),
                ],
                gap: 0,
                rowGap: 0,
                cross: WrapCrossAlignment.start,
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 8,
          ),
        ),
        Text(
          '共 6 个工位，此处显示 5 个 · 点击色块查看预约',
          style: hts(
            12,
            dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
            lh: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 16,
    );
  }
}
