import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../preferences/theme_preferences.dart';
import '../../routes.dart' show openRoute;
import '../../resources/staff_svgs.dart';
import 'st_live.dart';

class StMineTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StMineTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final name = '${d['name']}';
    final phone = '${d['phone'] ?? ''}';
    final masked = phone.length == 11
        ? '${phone.substring(0, 3)}****${phone.substring(7)}'
        : phone;
    final joined = StaffFlow.dotDate(d['joined_on'], monthOnly: true);
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1100,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 110),
            child: hcol(
              [
                hrow(
                  [
                    hbox(w: 87),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '我的',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    hbox(w: 87),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  grad: LinearGradient(
                    begin: Alignment(-0.5, -0.866),
                    end: Alignment(0.5, 0.866),
                    colors: [
                      Color(0xFF26262C),
                      Color(0xFF18181B),
                      Color(0xFF2B2418),
                    ],
                    stops: [0, 0.55, 1],
                  ),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  child: hstack(
                    hcol(
                      [
                        hcol(
                          [
                            hrow(
                              [
                                hbox(
                                  w: 60,
                                  h: 60,
                                  grad: LinearGradient(
                                    begin: Alignment(-0.5, -0.866),
                                    end: Alignment(0.5, 0.866),
                                    colors: [
                                      Color(0xFFFBE7B0),
                                      Color(0xFFE6B85C),
                                    ],
                                    stops: [0, 1],
                                  ),
                                  radius: BorderRadius.circular(30),
                                  align: Alignment(0, 0),
                                  child: Text(
                                    stInitial(name),
                                    style: hts(
                                      24,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
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
                                            flex: 38,
                                            child: Text(
                                              name,
                                              style: hts(
                                                19,
                                                Color(0xFFFAFAFA),
                                                w: FontWeight.w600,
                                                lh: 28,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            flex: 38,
                                            child: hbox(
                                              bg: dk(
                                                context,
                                                Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  0.14,
                                                ),
                                                Color.fromRGBO(9, 9, 11, 0.92),
                                              ),
                                              radius: BorderRadius.circular(9),
                                              pad: EdgeInsets.fromLTRB(
                                                8,
                                                0,
                                                8,
                                                0,
                                              ),
                                              child: Text(
                                                Access.roleBrief(),
                                                style: hts(
                                                  11,
                                                  Color(0xFFF5D78E),
                                                  w: FontWeight.w600,
                                                  lh: 18,
                                                ),
                                                softWrap: false,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                        main: MainAxisAlignment.start,
                                        cross: CrossAxisAlignment.center,
                                        gap: 8,
                                      ),
                                      Text(
                                        '$masked · 入职 $joined',
                                        style: hts(
                                          12,
                                          dk(
                                            context,
                                            Color(0xFFA1A1AA),
                                            Color(0xFF80808A),
                                          ),
                                          lh: 17,
                                        ),
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
                              gap: 14,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                        hcol(
                          [
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '${d['month_done'] ?? 0}',
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '本月完成',
                                        style: hts(
                                          11,
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
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '—',
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '好评率',
                                        style: hts(
                                          11,
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
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        stMoney(d['month_commission']),
                                        style: hts(
                                          17,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 24,
                                        ),
                                      ),
                                      Text(
                                        '本月提成',
                                        style: hts(
                                          11,
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
                              cross: CrossAxisAlignment.start,
                              gap: 0,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 0,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 14,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -120,
                        right: -120,
                        child: IntrinsicWidth(
                          child: hsvg(Svgs.s2, w: 260, h: 260),
                        ),
                      ),
                      Positioned(
                        top: -100,
                        right: -80,
                        width: 260,
                        height: 260,
                        child: hbox(
                          w: 260,
                          h: 260,
                          radius: BorderRadius.circular(130),
                        ),
                      ),
                    ],
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'StPerf'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFDDF6E7),
                                  Color.fromRGBO(23, 201, 100, 0.16),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s63, Svgs.s64),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '业绩提成',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      '本月 ${stMoney(d['month_commission'])}',
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
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'StArrivals'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s65, Svgs.s66),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '今日到店',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      '${(d['waiting'] ?? 0) + (d['working'] ?? 0)} 位',
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
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => AppToast.show(context, '请直接联系店长'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s67, Svgs.s68),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '联系店长',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 1,
                                ),
                              ),
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 0,
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
                      if (((Access.context['identity_count'] as num?) ?? 1) > 1)
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => AccessFlow.switchIdentity(context),
                          child: hbox(
                            minH: 60,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 32,
                                  h: 32,
                                  bg: dk(
                                    context,
                                    Color(0xFFFDEFD6),
                                    Color.fromRGBO(245, 165, 36, 0.16),
                                  ),
                                  radius: BorderRadius.circular(10),
                                  child: hrow(
                                    [
                                      hsvg(
                                        dk(context, Svgs.s71, Svgs.s72),
                                        w: 18,
                                        h: 18,
                                      ),
                                    ],
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
                                        '切换身份',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      Text(
                                        '当前：${Access.storeName} · ${Access.roleName()}',
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
                                hsvg(
                                  dk(context, Svgs.s45, Svgs.s46),
                                  w: 16,
                                  h: 16,
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                        ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'ThemeSheet'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s73, Svgs.s74),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '外观',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      themeModeLabel(appThemeMode.value),
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
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            AppToast.show(context, 'TODO：员工账号使用验证码登录，暂不支持修改密码'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s75, Svgs.s76),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '账号与安全',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      '修改密码 · 登录设备',
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
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(context, 'AboutApp'),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s77, Svgs.s78),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '关于汽美管家',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    Text(
                                      'v1.0.0',
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
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => AccessFlow.signOut(context),
                        child: hbox(
                          minH: 60,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              hbox(
                                w: 32,
                                h: 32,
                                bg: dk(
                                  context,
                                  Color(0xFFFFE1E2),
                                  Color.fromRGBO(255, 56, 60, 0.18),
                                ),
                                radius: BorderRadius.circular(10),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s79, Svgs.s80),
                                      w: 18,
                                      h: 18,
                                    ),
                                  ],
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
                                      '退出登录',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 1,
                                ),
                              ),
                              hsvg(
                                dk(context, Svgs.s45, Svgs.s46),
                                w: 16,
                                h: 16,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
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

/// 我的：本人资料与本月数据；「切换身份」只在多身份账号显示。
class StMineLivePage extends StatelessWidget {
  const StMineLivePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    // 切换身份 / 权限调整后，身份相关的行（切换身份、当前身份）随之更新
    listenable: Access.changed,
    builder: (_, _) => StLive(
      title: '我的',
      load: merchantApi.staffHome,
      builder: (_, d) => StMineTemplate(d: d),
    ),
  );
}
