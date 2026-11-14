import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';
import 'staff_route_data.dart';

class StaffCommissionTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StaffCommissionTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final id = '${d['id']}';
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    final services = [
      for (final s in (d['services'] as List? ?? const []))
        Map<String, dynamic>.from(s as Map),
    ];
    return AsyncActionScope(
      actionKey: 'StaffCommission>StaffDetail-${identityHashCode(context)}',
      child: HPage(
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => runBusy(
                          'StaffCommission>StaffDetail-${identityHashCode(context)}',
                          () async {
                            try {
                              await StaffFlow.saveCommission(id, 'follow');
                              if (context.mounted) {
                                openRoute(
                                  context,
                                  'StaffDetail',
                                  arguments: StaffRouteData(staffId: id),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) AppToast.error(context, e);
                            }
                          },
                        ),
                        child: hbox(
                          h: 44,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(22),
                          pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                          child: Align(
                            alignment: Alignment(-1, 0),
                            widthFactor: 1,
                            child: hBusy(
                              'StaffCommission>StaffDetail-${identityHashCode(context)}',
                              Text(
                                '保存',
                                style: hts(
                                  14,
                                  Color(0xFFFFFFFF),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                              style: hts(
                                14,
                                Color(0xFFFFFFFF),
                                w: FontWeight.w600,
                                lh: 20,
                              ),
                              label: '提交中…',
                            ),
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
                            staffInitial(d),
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
                                name,
                                style: hts(
                                  16,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '$role · 上月提成 ${StaffFlow.money(d['last_month_commission'])}',
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
                        border: Border.all(
                          color: Color(0xFF0485F7),
                          width: 1.5,
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
                                  for (final s in services)
                                    hrow(
                                      [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '${s['name']}',
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
                                          staffServiceRate(s),
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
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => AppToast.show(
                          context,
                          'TODO：比例输入界面待设计确认，当前仅支持跟随项目设置',
                        ),
                        child: hbox(
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
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => AppToast.show(
                          context,
                          'TODO：比例输入界面待设计确认，当前仅支持跟随项目设置',
                        ),
                        child: hbox(
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
      ),
    );
  }
}

/// 提成方案（设计稿 StaffCommission）：读取员工与各服务项目的提成设置。
class StaffCommissionLivePage extends StatelessWidget {
  final String? staffId;
  const StaffCommissionLivePage({super.key, this.staffId});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    staffId: staffId,
    title: '提成方案',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffCommissionTemplate(d: d),
  );
}
