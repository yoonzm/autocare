import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import 'staff_route_data.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/kit.dart';
import '../../kit/sheet_route.dart';
import '../../routes.dart' show openRoute;
import 'staff_editor_page.dart';
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

class StaffDetailTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StaffDetailTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    final skills = '${d['skills'] ?? ''}'.isEmpty
        ? <String>[]
        : '${d['skills']}'.split(' / ');
    final recent = [
      for (final r in (d['recent'] as List? ?? const []))
        Map<String, dynamic>.from(r as Map),
    ];
    final status = [
      if (d['status'] == 'pending')
        '待激活'
      else if (d['busy'] == true)
        '施工中'
      else
        '空闲',
      if (d['bay_name'] != null) '${d['bay_name']}',
    ].join(' · ');
    Widget recentRow(Map<String, dynamic> r) {
      final plate = '${r['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${r['plate']}';
      return hrow(
        [
          (staffGreenPlate(r['plate'])
              ? hbox(
                  bg: Color(0xFFD7F5E1),
                  radius: BorderRadius.circular(4),
                  pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: Text(
                    plate,
                    style: hts(
                      11,
                      Color(0xFF14532D),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                  ),
                )
              : hbox(
                  bg: Color(0xFF0B5FD6),
                  radius: BorderRadius.circular(4),
                  pad: EdgeInsets.fromLTRB(5, 2, 5, 2),
                  child: Text(
                    plate,
                    style: hts(
                      11,
                      Color(0xFFFFFFFF),
                      w: FontWeight.w600,
                      lh: 16,
                    ),
                  ),
                )),
          Expanded(
            flex: 1,
            child: Text(
              '${r['service'] ?? ''}',
              style: hts(
                14,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                lh: 20,
              ),
            ),
          ),
          (r['status'] == 'arrived'
              ? Text(
                  '进行中',
                  style: hts(
                    12,
                    dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                    w: FontWeight.w500,
                    lh: 16,
                  ),
                )
              : Text(
                  '${staffDayLabel(r['at'])}${r['commission'] == null ? '' : ' · +${StaffFlow.money(r['commission'])}'}',
                  style: hts(
                    12,
                    dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                    lh: 16,
                  ),
                )),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      );
    }

    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 880,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
            child: hcol(
              [
                hrow(
                  [
                    AppIconButton(
                      svg: dk(context, Svgs.s0, Svgs.s1),
                      semanticLabel: "返回",
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '员工详情',
                        style: hts(
                          17,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    AppButton(
                      label: '编辑',
                      kind: AppButtonKind.surface,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => Navigator.of(context).push(
                        appSheetRoute<void>(
                          settings: const RouteSettings(name: 'StaffEdit'),
                          page: StaffEditorPage(row: d),
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 8,
                ),
                hbox(
                  bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                  radius: BorderRadius.circular(28),
                  pad: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  clip: true,
                  border: dk(
                    context,
                    null,
                    Border(
                      top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      right: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      bottom: BorderSide(color: Color(0xFF2E2E33), width: 1),
                      left: BorderSide(color: Color(0xFF2E2E33), width: 1),
                    ),
                  ),
                  child: hstack(
                    hcol(
                      [
                        hrow(
                          [
                            hbox(
                              w: 56,
                              h: 56,
                              bg: dk(
                                context,
                                Color(0xFFE1F0FE),
                                Color.fromRGBO(4, 133, 247, 0.18),
                              ),
                              radius: BorderRadius.circular(28),
                              align: Alignment(0, 0),
                              child: Text(
                                staffInitial(d),
                                style: hts(
                                  20,
                                  dk(
                                    context,
                                    Color(0xFF1E63AE),
                                    Color(0xFF6AB4FA),
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
                                        flex: 54,
                                        child: Text(
                                          name,
                                          style: hts(
                                            18,
                                            Color(0xFFFAFAFA),
                                            w: FontWeight.w600,
                                            lh: 26,
                                          ),
                                        ),
                                      ),
                                      Flexible(
                                        flex: 113,
                                        child: hbox(
                                          bg: Color(0xFF27272A),
                                          radius: BorderRadius.circular(9),
                                          pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                          child: hrow(
                                            [
                                              hbox(
                                                w: 6,
                                                h: 6,
                                                bg: Color(0xFF0485F7),
                                                radius: BorderRadius.circular(
                                                  3,
                                                ),
                                              ),
                                              Flexible(
                                                flex: 88,
                                                child: Text(
                                                  status,
                                                  style: hts(
                                                    11,
                                                    Color(0xFFFAFAFA),
                                                    w: FontWeight.w500,
                                                    lh: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.center,
                                            gap: 5,
                                          ),
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 8,
                                  ),
                                  Text(
                                    '$role · 入职 ${StaffFlow.dotDate(d['joined_on'], monthOnly: true)}',
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
                                gap: 4,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 14,
                        ),
                        hbox(
                          border: Border(
                            top: BorderSide(color: Color(0xFF2E2E33), width: 1),
                          ),
                          pad: EdgeInsets.fromLTRB(0, 14, 0, 0),
                          child: hcol([
                            hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '本月台次',
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
                                      Text(
                                        '${d['month_orders'] ?? 0}',
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
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
                                        '本月提成',
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
                                      Text(
                                        StaffFlow.money(d['month_commission']),
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
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
                                        '客户好评',
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
                                      Text(
                                        '—',
                                        style: hts(
                                          18,
                                          Color(0xFFFAFAFA),
                                          w: FontWeight.w600,
                                          lh: 26,
                                        ),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.stretch,
                                    gap: 2,
                                  ),
                                ),
                              ],
                              cross: CrossAxisAlignment.stretch,
                              gap: 8,
                              intrinsic: true,
                              min: false,
                            ),
                          ], gap: 8),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 18,
                    ),
                    [],
                    behind: [
                      Positioned(
                        top: -110,
                        right: -100,
                        child: hsvg(Svgs.s354, w: 220, h: 220),
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
                      hbox(
                        minH: 54,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '手机号',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              StaffFlow.maskedPhone(d['phone']),
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
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          openRoute(
                            context,
                            'RolePermission',
                            arguments: StaffRouteData(
                              role: d['role'] == 'cashier'
                                  ? 'cashier'
                                  : 'technician',
                            ),
                          );
                        },
                        child: hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '角色与权限',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ),
                              hbox(
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(10),
                                pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Text(
                                  role,
                                  style: hts(
                                    12,
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
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
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
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      hbox(
                        minH: 54,
                        pad: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '擅长项目',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF52525B),
                                    Color(0xFFA8A8B3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            hwrap(
                              [
                                for (final s
                                    in (skills.isEmpty ? ['未设置'] : skills))
                                  hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(11),
                                    pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                    child: Text(
                                      s,
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 22,
                                      ),
                                    ),
                                  ),
                              ],
                              gap: 6,
                              rowGap: 6,
                              cross: WrapCrossAlignment.start,
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 12,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => openRoute(
                          context,
                          'StaffCommission',
                          arguments: StaffRouteData(
                            staffId: d['id'] as String?,
                          ),
                        ),
                        child: hbox(
                          minH: 54,
                          pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '提成方案',
                                  style: hts(
                                    14,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 20,
                                  ),
                                ),
                              ),
                              Text(
                                staffCommissionLabel(d),
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
                              hsvg(dk(context, Svgs.s3, Svgs.s4), w: 16, h: 16),
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: Text(
                              '最近施工',
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
                          AppButton(
                            label: '全部记录',
                            kind: AppButtonKind.text,
                            size: AppButtonSize.medium,
                            expanded: false,
                            onPressed: () => openRoute(
                              context,
                              'StaffRecords',
                              arguments: StaffRouteData(
                                staffId: d['id'] as String?,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.baseline,
                        gap: 0,
                      ),
                      if (recent.isEmpty)
                        Text(
                          '暂无施工记录',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 18,
                          ),
                        ),
                      for (var i = 0; i < recent.length; i++) ...[
                        if (i > 0)
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                          ),
                        recentRow(recent[i]),
                      ],
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
                AppButton(
                  label: '停用账号',
                  kind: AppButtonKind.danger,
                  size: AppButtonSize.large,
                  expanded: true,
                  onPressed: () => openRoute(
                    context,
                    'DisableStaff',
                    arguments: StaffRouteData(staffId: d['id'] as String?),
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

/// 员工详情（设计稿 StaffDetail）：读取真实员工、本月统计与最近施工。
class StaffDetailLivePage extends StatelessWidget {
  final String? staffId;
  const StaffDetailLivePage({super.key, this.staffId});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    staffId: staffId,
    title: '员工详情',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffDetailTemplate(d: d),
  );
}

/// 编辑员工：从详情进入时按当前员工读取，再交给编辑表单。
class StaffEditLivePage extends StatelessWidget {
  final String? staffId;
  const StaffEditLivePage({super.key, this.staffId});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    staffId: staffId,
    title: '编辑员工',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffEditorPage(row: d),
  );
}
