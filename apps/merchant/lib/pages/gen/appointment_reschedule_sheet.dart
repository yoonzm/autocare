import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class AppointmentRescheduleSheet extends StatelessWidget {
  const AppointmentRescheduleSheet({super.key});

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
            '改期 · 刘先生',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          Text(
            '原预约：今天 17:30 · 车身打蜡 · 4 号工位',
            style: hts(
              13,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 18,
            ),
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '新日期',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({0}, false),
                ],
                builder: (context, g1) => hwrap(
                  [
                    HSel(
                      ctrl: g1[0],
                      index: 0,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '今天 10.31',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '今天 10.31',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 1,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '明天 11.01',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '明天 11.01',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 2,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '周一 11.02',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '周一 11.02',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g1[0],
                      index: 3,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '周二 11.03',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '周二 11.03',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text.rich(
                  TextSpan(
                    style: hts(
                      14,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                    children: [
                      TextSpan(
                        text: '新时间 ',
                        style: hts(
                          14,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 20,
                        ),
                      ),
                      TextSpan(
                        text: '· 18:30 – 20:00',
                        style: hts(
                          14,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              hcol([
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                          radius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFFC7C7CC),
                            width: 1.5,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '17:30 原',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                          ),
                        ),
                        label: '17:30 原',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '18:00',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                          ),
                        ),
                        label: '18:00',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF0485F7),
                            width: 1.5,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '18:30',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF1E63AE),
                                  Color(0xFF6AB4FA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                          ),
                        ),
                        label: '18:30',
                      ),
                    ),
                  ],
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                  intrinsic: true,
                  min: false,
                ),
                hrow(
                  [
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '19:00',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                          ),
                        ),
                        label: '19:00',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '19:30',
                              style: hts(
                                14,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 20,
                              ),
                            ),
                          ),
                        ),
                        label: '19:30',
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: hTap(
                        context,
                        hbox(
                          h: 38,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(12),
                          child: Align(
                            alignment: Alignment.center,
                            widthFactor: 1,
                            child: Text(
                              '20:00',
                              style: hts(
                                14,
                                Color(0xFFC4C4C9),
                                w: FontWeight.w500,
                                lh: 20,
                                deco: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                        ),
                        label: '20:00',
                      ),
                    ),
                  ],
                  cross: CrossAxisAlignment.stretch,
                  gap: 8,
                  intrinsic: true,
                  min: false,
                ),
              ], gap: 8),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: hcol(
                  [
                    Text(
                      '改期后通知客户',
                      style: hts(
                        14,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 20,
                      ),
                    ),
                    Text(
                      '微信优先，失败转短信',
                      style: hts(
                        12,
                        dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        lh: 16,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 0,
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
                  to: 'AppointmentDetail',
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
                        '确认改期',
                        style: hts(
                          15,
                          dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                    ),
                  ),
                  to: 'Appointments',
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 10,
            intrinsic: true,
          ),
          hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))),
          hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Text(
                  '或者取消预约',
                  style: hts(
                    14,
                    dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                    w: FontWeight.w600,
                    lh: 20,
                  ),
                ),
              ),
              HSelHolder(
                groups: [
                  ({0}, false),
                ],
                builder: (context, g2) => hwrap(
                  [
                    HSel(
                      ctrl: g2[0],
                      index: 0,
                      on: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '客户有事',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(
                          context,
                          Color(0xFFE1F0FE),
                          Color.fromRGBO(4, 133, 247, 0.18),
                        ),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '客户有事',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 1,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '时间冲突',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '时间冲突',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 2,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '联系不上',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '联系不上',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    HSel(
                      ctrl: g2[0],
                      index: 3,
                      on: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
                        ),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '其他',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                      off: hbox(
                        h: 34,
                        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                        radius: BorderRadius.circular(17),
                        pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '其他',
                            style: hts(
                              13,
                              dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  gap: 8,
                  rowGap: 8,
                  cross: WrapCrossAlignment.start,
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
                Color(0xFFFFE1E2),
                Color.fromRGBO(255, 56, 60, 0.18),
              ),
              radius: BorderRadius.circular(23),
              child: Align(
                alignment: Alignment(0, 0),
                widthFactor: 1,
                child: Text(
                  '取消这个预约',
                  style: hts(
                    15,
                    dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                    w: FontWeight.w600,
                    lh: 22,
                  ),
                ),
              ),
            ),
            to: 'Appointments',
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
