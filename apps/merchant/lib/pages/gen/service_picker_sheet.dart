import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import 'svgs.dart';

class ServicePickerSheet extends StatelessWidget {
  const ServicePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return hbox(
      minH: 740,
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(28),
        topRight: Radius.circular(28),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      child: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: hcol(
              [
                Align(
                  alignment: Alignment.topCenter,
                  child: hbox(
                    w: 36,
                    h: 4,
                    bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
                    radius: BorderRadius.circular(2),
                  ),
                ),
                hbox(
                  h: 48,
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: Text(
                          '选择服务项目',
                          style: hts(
                            17,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 36,
                          h: 36,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(18),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s400, Svgs.s401),
                                w: 18,
                                h: 18,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        back: true,
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 0,
                  ),
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(0, 0, 0, 12),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: hbox(
                              h: 44,
                              bg: dk(
                                context,
                                Color(0xFFF4F4F5),
                                Color(0xFF27272A),
                              ),
                              radius: BorderRadius.circular(22),
                              pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s418, Svgs.s419),
                                    w: 18,
                                    h: 18,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '搜索服务项目',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 10,
                      ),
                      hbox(
                        clip: true,
                        child: HSelHolder(
                          groups: [
                            ({0}, false),
                          ],
                          builder: (context, g1) => SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: hrow(
                              [
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 0,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '全部',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
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
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 1,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '洗车',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '洗车',
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
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 2,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '美容',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '美容',
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
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 3,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '镀晶',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '镀晶',
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
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 4,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '贴膜',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '贴膜',
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
                                UnconstrainedBox(
                                  alignment: Alignment.topLeft,
                                  constrainedAxis: Axis.horizontal,
                                  child: HSel(
                                    ctrl: g1[0],
                                    index: 5,
                                    on: hbox(
                                      h: 34,
                                      bg: dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '维修',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFFAFAFA),
                                              Color(0xFF18181B),
                                            ),
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
                                        Color(0xFFF4F4F5),
                                        Color(0xFF27272A),
                                      ),
                                      radius: BorderRadius.circular(17),
                                      pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        widthFactor: 1,
                                        child: Text(
                                          '维修',
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
                              gap: 8,
                              intrinsic: true,
                            ),
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 10,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 0,
            ),
          ),
          hbox(
            minH: 0,
            pad: EdgeInsets.fromLTRB(20, 4, 20, 0),
            clip: true,
            child: hcol(
              [
                hbox(
                  bg: dk(
                    context,
                    Color(0xFFF3F9FF),
                    Color.fromRGBO(4, 133, 247, 0.1),
                  ),
                  radius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFFBFDDFB), width: 1.5),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '精致洗车',
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
                                '约 30 分钟',
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
                      ),
                      Text(
                        '¥38',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      HHolder(
                        inits: [1],
                        builder: (context, ctrls) {
                          final c2 = ctrls[0];
                          return HNumberStepper(
                            ctrl: c2,
                            step: 1,
                            minus: hbox(
                              w: 32,
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
                                [
                                  hsvg(
                                    dk(context, Svgs.s420, Svgs.s421),
                                    w: 16,
                                    h: 16,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            value: Flexible(
                              flex: 9,
                              child: hbox(
                                minW: 14,
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: hCount(
                                    c2,
                                    hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 22,
                                      tab: true,
                                    ),
                                    0,
                                    '',
                                    false,
                                  ),
                                ),
                              ),
                            ),
                            plus: hbox(
                              w: 32,
                              h: 32,
                              bg: Color(0xFF0485F7),
                              radius: BorderRadius.circular(16),
                              child: hrow(
                                [hsvg(Svgs.s422, w: 16, h: 16)],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          );
                        },
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(18),
                  border: dk(
                    context,
                    Border.all(color: Color(0xFFEFEFF1), width: 1),
                    Border.all(color: Color(0xFF2A2A2E), width: 1),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '标准洗车',
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
                                '约 20 分钟',
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
                      ),
                      Text(
                        '¥25',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(16),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s423, Svgs.s424),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        label: '添加标准洗车',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(
                    context,
                    Color(0xFFF3F9FF),
                    Color.fromRGBO(4, 133, 247, 0.1),
                  ),
                  radius: BorderRadius.circular(18),
                  border: Border.all(color: Color(0xFFBFDDFB), width: 1.5),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '内饰精洗',
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
                                '约 90 分钟',
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
                      ),
                      Text(
                        '¥168',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      HHolder(
                        inits: [1],
                        builder: (context, ctrls) {
                          final c3 = ctrls[0];
                          return HNumberStepper(
                            ctrl: c3,
                            step: 1,
                            minus: hbox(
                              w: 32,
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
                                [
                                  hsvg(
                                    dk(context, Svgs.s420, Svgs.s421),
                                    w: 16,
                                    h: 16,
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            value: Flexible(
                              flex: 9,
                              child: hbox(
                                minW: 14,
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: hCount(
                                    c3,
                                    hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 22,
                                      tab: true,
                                    ),
                                    0,
                                    '',
                                    false,
                                  ),
                                ),
                              ),
                            ),
                            plus: hbox(
                              w: 32,
                              h: 32,
                              bg: Color(0xFF0485F7),
                              radius: BorderRadius.circular(16),
                              child: hrow(
                                [hsvg(Svgs.s422, w: 16, h: 16)],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 0,
                              ),
                            ),
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          );
                        },
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(18),
                  border: dk(
                    context,
                    Border.all(color: Color(0xFFEFEFF1), width: 1),
                    Border.all(color: Color(0xFF2A2A2E), width: 1),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '打蜡养护',
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
                                '约 60 分钟',
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
                      ),
                      Text(
                        '¥128',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(16),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s423, Svgs.s424),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        label: '添加打蜡养护',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(18),
                  border: dk(
                    context,
                    Border.all(color: Color(0xFFEFEFF1), width: 1),
                    Border.all(color: Color(0xFF2A2A2E), width: 1),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '空调杀菌',
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
                                '约 40 分钟',
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
                      ),
                      Text(
                        '¥120',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(16),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s423, Svgs.s424),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        label: '添加空调杀菌',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(18),
                  border: dk(
                    context,
                    Border.all(color: Color(0xFFEFEFF1), width: 1),
                    Border.all(color: Color(0xFF2A2A2E), width: 1),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '镀晶养护',
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
                                '约 4 小时',
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
                      ),
                      Text(
                        '¥1,980',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(16),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s423, Svgs.s424),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        label: '添加镀晶养护',
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 12,
                  ),
                ),
                hbox(
                  bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                  radius: BorderRadius.circular(18),
                  border: dk(
                    context,
                    Border.all(color: Color(0xFFEFEFF1), width: 1),
                    Border.all(color: Color(0xFF2A2A2E), width: 1),
                  ),
                  pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: hrow(
                    [
                      Expanded(
                        flex: 1,
                        child: hbox(
                          minW: 0,
                          child: hcol(
                            [
                              Text(
                                '全车隐形车衣',
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
                                '约 2 天',
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
                      ),
                      Text(
                        '¥12,800 起',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                          tab: true,
                        ),
                      ),
                      hTap(
                        context,
                        hbox(
                          w: 32,
                          h: 32,
                          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
                          radius: BorderRadius.circular(16),
                          child: hrow(
                            [
                              hsvg(
                                dk(context, Svgs.s423, Svgs.s424),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.center,
                            cross: CrossAxisAlignment.center,
                            gap: 0,
                          ),
                        ),
                        label: '添加全车隐形车衣',
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
          ),
          hbox(
            bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
            shadow: dk(
              context,
              [
                BoxShadow(
                  color: Color(0xFFE4E4E7),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
              [
                BoxShadow(
                  color: Color(0xFF3A3A40),
                  offset: Offset(0, -1),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            pad: EdgeInsets.fromLTRB(20, 12, 20, 30),
            child: hrow(
              [
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '已选 2 项',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 17,
                        ),
                      ),
                      Text(
                        '¥206',
                        style: hts(
                          20,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 28,
                          tab: true,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    w: 140,
                    h: 50,
                    bg: Color(0xFF0485F7),
                    radius: BorderRadius.circular(25),
                    align: Alignment(0, 0),
                    child: Text(
                      '确定（2）',
                      style: hts(
                        15,
                        Color(0xFFFFFFFF),
                        w: FontWeight.w600,
                        lh: 22,
                      ),
                    ),
                  ),
                  to: 'Order',
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
    );
  }
}
