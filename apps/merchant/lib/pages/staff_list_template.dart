// 从既有设计模板派生，仅绑定数据和事件；不手工修改 gen/。
import 'package:flutter/material.dart';

import '../kit/kit.dart';
import '../kit/async_kit.dart';
import '../backend/staff_flow.dart';
import '../routes.dart' show openRoute;
import '../widgets/booking_template_bindings.dart';
import 'gen/svgs.dart';

class StaffListTemplate extends StatelessWidget {
  final BookingTemplateController c;
  const StaffListTemplate({super.key, required this.c});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 0),
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
                        '员工与权限',
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
                        w: 44,
                        h: 44,
                        bg: Color(0xFF0485F7),
                        radius: BorderRadius.circular(22),
                        child: hrow(
                          [hsvg(Svgs.s81, w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      onTap: () => c.editResource(context, null),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(20),
                  pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                  child: BookingSelections(
                    c: c,
                    field: 'staff_filter',
                    groups: [
                      ({3}, false),
                    ],
                    builder: (context, g1) => hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 0,
                              segment: true,
                              on: hbox(
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                shadow: dk(
                                  context,
                                  [
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
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '全部 ',
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
                                        TextSpan(
                                          text: '${c.count(0)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '全部 ',
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
                                        TextSpan(
                                          text: '${c.count(0)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 1,
                              segment: true,
                              on: hbox(
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                shadow: dk(
                                  context,
                                  [
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
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '店长 ',
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
                                        TextSpan(
                                          text: '${c.count(1)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '店长 ',
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
                                        TextSpan(
                                          text: '${c.count(1)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 2,
                              segment: true,
                              on: hbox(
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                shadow: dk(
                                  context,
                                  [
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
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '前台收银 ',
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
                                        TextSpan(
                                          text: '${c.count(2)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '前台收银 ',
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
                                        TextSpan(
                                          text: '${c.count(2)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFFA1A1AA),
                                              Color(0xFF80808A),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: g1[0],
                              index: 3,
                              segment: true,
                              on: hbox(
                                h: 34,
                                bg: dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
                                radius: BorderRadius.circular(17),
                                shadow: dk(
                                  context,
                                  [
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
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '施工技师 ',
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
                                        TextSpan(
                                          text: '${c.count(3)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF71717A),
                                              Color(0xFF9A9AA3),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              off: hbox(
                                h: 34,
                                radius: BorderRadius.circular(17),
                                child: Align(
                                  alignment: Alignment.center,
                                  widthFactor: 1,
                                  child: Text.rich(
                                    TextSpan(
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
                                      children: [
                                        TextSpan(
                                          text: '施工技师 ',
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
                                        TextSpan(
                                          text: '${c.count(3)}',
                                          style: hts(
                                            13,
                                            dk(
                                              context,
                                              Color(0xFF71717A),
                                              Color(0xFF9A9AA3),
                                            ),
                                            lh: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    softWrap: false,
                                    maxLines: 1,
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
                      if (c.visibleStaff.isEmpty)
                        EmptyView(
                          title: c.filter == 1 || c.filter == 2
                              ? '当前角色没有员工'
                              : c.filter == 3
                              ? '还没有技师'
                              : '还没有员工',
                          message: '点击右上角添加员工',
                          inline: true,
                        ),
                      for (var i = 0; i < c.visibleStaff.length; i++) ...[
                        if (i > 0) _staffDivider(context),
                        _staffRow(context, c, c.visibleStaff[i], i),
                      ],
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
                  ),
                ),
                hTap(
                  context,
                  hbox(
                    h: 56,
                    bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                    radius: BorderRadius.circular(20),
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
                    pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: Text(
                            '已停用账号',
                            style: hts(
                              15,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              lh: 22,
                            ),
                          ),
                        ),
                        Text(
                          '${c.inactiveStaff.length} 人',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          ),
                        ),
                        hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                  onTap: () {
                    final off = c.inactiveStaff;
                    if (off.length == 1) {
                      // 设计稿：只有一位停用员工时直接进入他的详情
                      StaffFlow.currentId = off.first['id'] as String;
                      openRoute(context, 'StaffDetailOff');
                      return;
                    }
                    c.showInactive = !c.showInactive;
                    c.changed();
                  },
                ),
                if (c.showInactive && c.inactiveStaff.isNotEmpty)
                  _staffCard(context, [
                    for (var i = 0; i < c.inactiveStaff.length; i++) ...[
                      if (i > 0) _staffDivider(context),
                      _staffRow(context, c, c.inactiveStaff[i], i, off: true),
                    ],
                  ]),
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
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '技师可以',
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
                          hTap(
                            context,
                            Text(
                              '编辑权限',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF1E63AE),
                                  Color(0xFF6AB4FA),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                            ),
                            onTap: () {
                              StaffFlow.permissionRole = 'technician';
                              openRoute(context, 'RolePermission');
                            },
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.center,
                        gap: 0,
                      ),
                      _permissionGrid(context, c),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
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

Widget _staffDivider(BuildContext context) => hbox(
  h: 1,
  bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
  margin: EdgeInsets.fromLTRB(68, 0, 0, 0),
);

Widget _staffCard(BuildContext context, List<Widget> rows) => hbox(
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
    rows,
    main: MainAxisAlignment.start,
    cross: CrossAxisAlignment.stretch,
    gap: 0,
  ),
);

/// 设计稿里的头像底色：按行轮换（蓝 / 黄 / 绿 / 灰）。
const _avatarPalette = <(Color, Color, Color, Color)>[
  (Color(0xFFE1F0FE), Color(0x2E0485F7), Color(0xFF1E63AE), Color(0xFF6AB4FA)),
  (Color(0xFFFDEFD6), Color(0x29F5A524), Color(0xFF855F2E), Color(0xFFF0C46A)),
  (Color(0xFFDDF6E7), Color(0x2917C964), Color(0xFF2B7745), Color(0xFF5FD48C)),
  (Color(0xFFEEEEF0), Color(0xFF27272A), Color(0xFF3F3F46), Color(0xFFD4D4D8)),
];

/// 一行员工：头像 + 姓名 / 擅长 + 本月台次 + 状态标签（样式取自设计稿 Staff）。
Widget _staffRow(
  BuildContext context,
  BookingTemplateController c,
  Map<String, dynamic> r,
  int index, {
  bool off = false,
}) {
  final pal = _avatarPalette[off ? 3 : index % _avatarPalette.length];
  final muted = dk(context, Color(0xFF71717A), Color(0xFF9A9AA3));
  final name = '${r['name']}';
  final busy = r['busy'] == true;
  final pending = r['status'] == 'pending';
  final technician = r['role'] == 'technician';
  final invite = r['invite'] as Map?;
  final (chipLabel, chipBg, chipDot, chipFg) = off
      ? (
          '已停用',
          dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
          null,
          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
        )
      : pending
      ? (
          '待激活',
          dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16)),
          null,
          dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)),
        )
      : busy
      ? (
          '施工中',
          dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)),
          Color(0xFF0485F7),
          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
        )
      : (
          '空闲',
          dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16)),
          Color(0xFF17C964),
          dk(context, Color(0xFF2B7745), Color(0xFF5FD48C)),
        );
  return hTap(
    context,
    hbox(
      pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: hrow(
        [
          hbox(
            w: 40,
            h: 40,
            bg: dk(context, pal.$1, pal.$2),
            radius: BorderRadius.circular(20),
            align: Alignment(0, 0),
            child: Text(
              name.isEmpty ? '' : name.substring(0, 1),
              style: hts(15, dk(context, pal.$3, pal.$4), w: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 1,
            child: hcol(
              [
                Text.rich(
                  TextSpan(
                    style: hts(
                      15,
                      dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                      w: FontWeight.w500,
                      lh: 22,
                    ),
                    children: [
                      TextSpan(text: '$name '),
                      if (technician && '${r['skills'] ?? ''}'.isNotEmpty)
                        TextSpan(
                          text: '· ${r['skills']}',
                          style: hts(12, muted, lh: 22),
                        )
                      else if (!technician)
                        TextSpan(
                          text: '· ${StaffFlow.roleName(r['role'])}',
                          style: hts(12, muted, lh: 22),
                        ),
                    ],
                  ),
                ),
                Text(
                  pending
                      ? (invite == null
                            ? '尚未发送邀请'
                            : invite['expired'] == true
                            ? '邀请已过期，可在员工详情中重新发送'
                            : '邀请已发送，等待员工登录')
                      : technician
                      ? '本月 ${r['month_orders'] ?? 0} 台次'
                      : StaffFlow.maskedPhone(r['phone']),
                  style: hts(12, muted, lh: 16),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 2,
            ),
          ),
          hbox(
            bg: chipBg,
            radius: BorderRadius.circular(10),
            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: hrow(
              [
                if (chipDot != null)
                  hbox(
                    w: 6,
                    h: 6,
                    bg: chipDot,
                    radius: BorderRadius.circular(3),
                  ),
                Text(
                  chipLabel,
                  style: hts(12, chipFg, w: FontWeight.w500, lh: 20),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 5,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    ),
    onTap: () {
      StaffFlow.currentId = r['id'] as String;
      openRoute(context, off ? 'StaffDetailOff' : 'StaffDetail');
    },
  );
}

/// 技师权限：来自本店保存的角色权限（设计稿 Staff「技师可以」）。
Widget _permissionGrid(BuildContext context, BookingTemplateController c) {
  const items = <(String, String)>[
    ('order_view_own', '查看派给我的工单'),
    ('progress_update', '更新施工进度'),
    ('stock_use', '领用耗材'),
    ('perf_view_own', '查看个人业绩'),
    ('stats_view_store', '查看门店营业额'),
    ('member_recharge_refund', '会员充值与退款'),
  ];
  Widget cell(String key, String label) {
    final on = c.technicianCan(key);
    return Expanded(
      flex: 1,
      child: hrow(
        [
          hbox(
            w: 20,
            h: 20,
            bg: on
                ? dk(
                    context,
                    Color(0xFFDDF6E7),
                    Color.fromRGBO(23, 201, 100, 0.16),
                  )
                : dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
            radius: BorderRadius.circular(10),
            child: hrow(
              [
                hsvg(
                  on
                      ? dk(context, Svgs.s350, Svgs.s351)
                      : dk(context, Svgs.s352, Svgs.s353),
                  w: 12,
                  h: 12,
                ),
              ],
              main: MainAxisAlignment.center,
              cross: CrossAxisAlignment.center,
              gap: 0,
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: hts(
                13,
                on
                    ? dk(context, Color(0xFF18181B), Color(0xFFFAFAFA))
                    : dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                lh: 18,
              ),
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 8,
      ),
    );
  }

  return hcol(
    [
      for (var i = 0; i < items.length; i += 2)
        hrow(
          [
            cell(items[i].$1, items[i].$2),
            cell(items[i + 1].$1, items[i + 1].$2),
          ],
          cross: CrossAxisAlignment.stretch,
          gap: 12,
          intrinsic: true,
          min: false,
        ),
    ],
    gap: 10,
  );
}
