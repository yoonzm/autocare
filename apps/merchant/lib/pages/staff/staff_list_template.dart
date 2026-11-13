import '../../kit/single_selection.dart';

import 'package:flutter/material.dart';

import 'staff_route_data.dart';

import '../../kit/kit.dart';
import '../../backend/staff_flow.dart';
import '../../routes.dart' show openRoute;
import 'staff_editor_controller.dart';
import '../../resources/merchant_svgs.dart';

class StaffListTemplate extends StatelessWidget {
  final StaffEditorController c;
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.of(context).maybePop(),
                      child: hbox(
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => c.editResource(context, null),
                      child: hbox(
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
                  child: SingleSelection(
                    index: c.filter,
                    onChanged: c.setFilter,
                    builder: (context, selection) => hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: HSel(
                              ctrl: selection,
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
                              ctrl: selection,
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
                              ctrl: selection,
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
                              ctrl: selection,
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
                c.visibleStaff.isEmpty
                    ? _emptyRoleCard(context, c)
                    : hbox(
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
                if (c.inactiveStaff.isNotEmpty)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final off = c.inactiveStaff;
                      if (off.length == 1) {
                        // 设计稿：只有一位停用员工时直接进入他的详情
                        openRoute(
                          context,
                          'StaffDetailOff',
                          arguments: StaffRouteData(
                            staffId: off.first['id'] as String,
                          ),
                        );
                        return;
                      }
                      c.showInactive = !c.showInactive;
                      c.changed();
                    },
                    child: hbox(
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
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
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
                  ),
                if (c.showInactive && c.inactiveStaff.isNotEmpty)
                  _staffCard(context, [
                    for (var i = 0; i < c.inactiveStaff.length; i++) ...[
                      if (i > 0) _staffDivider(context),
                      _staffRow(context, c, c.inactiveStaff[i], i, off: true),
                    ],
                  ]),
                if (c.filter != 0)
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
                                '${_roleCanTitle(c.roleKey)}可以',
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
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                openRoute(
                                  context,
                                  'RolePermission',
                                  arguments: StaffRouteData(role: c.roleKey),
                                );
                              },
                              child: Text(
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
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                        _permissionGrid(context, c, c.roleKey),
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
  StaffEditorController c,
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
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      openRoute(
        context,
        off ? 'StaffDetailOff' : 'StaffDetail',
        arguments: StaffRouteData(staffId: r['id'] as String),
      );
    },
    child: hbox(
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
  );
}

/// 技师权限：来自本店保存的角色权限（设计稿 Staff「技师可以」）。
Widget _permissionGrid(
  BuildContext context,
  StaffEditorController c,
  String role,
) {
  // 技师沿用设计稿 Staff；店长 / 前台收银用设计稿 StaffEmptyRole 的六项
  final items = role == 'technician'
      ? const <(String, String)>[
          ('order_view_own', '查看派给我的工单'),
          ('progress_update', '更新施工进度'),
          ('stock_use', '领用耗材'),
          ('perf_view_own', '查看个人业绩'),
          ('stats_view_store', '查看门店营业额'),
          ('member_recharge_refund', '会员充值与退款'),
        ]
      : const <(String, String)>[
          ('order_view_all', '查看全店工单'),
          ('cashier', '开单收银'),
          ('member_view', '查看会员资料'),
          ('member_recharge_refund', '会员充值与退款'),
          ('stock_manage', '入库与盘点'),
          ('stats_view_store', '查看门店营业统计'),
        ];
  Widget cell(String key, String label) {
    final on = c.roleCan(role, key);
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

  return hcol([
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
  ], gap: 10);
}

/// 设计稿 StaffEmptyRole：某个角色下没有员工时，列表卡片里只放一行说明 + 文字入口，保留页签栏。
Widget _emptyRoleCard(BuildContext context, StaffEditorController c) {
  final role = StaffFlow.roleName(c.roleKey);
  final all = c.filter == 0;
  return hbox(
    minH: 64,
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
    pad: EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: hrow(
      [
        Expanded(
          flex: 1,
          child: hcol(
            [
              Text(
                all ? '还没有员工' : '$role下还没有员工',
                style: hts(
                  14,
                  dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                  lh: 20,
                ),
              ),
              Text(
                all ? '添加后可分配角色与权限' : '添加后自动拥有下方的$role权限',
                style: hts(
                  12,
                  dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                  lh: 17,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 2,
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => c.addStaff(context),
          child: hbox(
            h: 44,
            pad: EdgeInsets.fromLTRB(4, 0, 4, 0),
            align: Alignment.center,
            child: Text(
              all ? '添加员工' : '添加$role',
              style: hts(
                13,
                dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                w: FontWeight.w600,
                lh: 18,
              ),
            ),
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.center,
      gap: 12,
    ),
  );
}

String _roleCanTitle(String role) => switch (role) {
  'manager' => '店长',
  'cashier' => '前台收银',
  _ => '技师',
};
