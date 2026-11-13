import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import 'staff_route_data.dart';

import '../../backend/staff_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

class DisableStaffTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const DisableStaffTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final id = '${d['id']}';
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    final open = (d['open_work'] as List?) ?? const [];
    return AsyncActionScope(
      actionKey: 'DisableStaff>Staff-${identityHashCode(context)}',
      child: hbox(
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
              '停用 $name 的账号？',
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            hbox(
              bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)),
              radius: BorderRadius.circular(18),
              pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: hrow(
                [
                  hbox(
                    w: 40,
                    h: 40,
                    bg: dk(context, Color(0xFFE4E4E7), Color(0xFF3A3A40)),
                    radius: BorderRadius.circular(20),
                    align: Alignment(0, 0),
                    child: Text(
                      staffInitial(d),
                      style: hts(
                        16,
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
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
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                          ),
                        ),
                        Text(
                          [
                            role,
                            if (d['status'] == 'pending')
                              '待激活'
                            else if (d['busy'] == true)
                              '施工中'
                            else
                              '空闲',
                            if (d['bay_name'] != null) '${d['bay_name']}',
                          ].join(' · '),
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
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
                cross: CrossAxisAlignment.center,
                gap: 12,
              ),
            ),
            hcol(
              [
                hrow(
                  [
                    hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                    Flexible(
                      flex: 260,
                      child: Text(
                        '该员工将无法登录，历史施工记录与提成保留',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 19,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.start,
                  gap: 8,
                ),
                if (open.isNotEmpty)
                  hrow(
                    [
                      hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                      Flexible(
                        flex: 223,
                        child: Text(
                          '进行中的 ${open.length} 个订单需先转交给其他技师',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            lh: 19,
                          ),
                        ),
                      ),
                      Spacer(),
                      Flexible(
                        flex: 39,
                        child: AppButton(
                          label: '去转交',
                          kind: AppButtonKind.text,
                          size: AppButtonSize.medium,
                          expanded: false,
                          onPressed: () {
                            openRoute(
                              context,
                              'StaffTransfer',
                              arguments: StaffRouteData(staffId: id),
                            );
                          },
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
                  ),
                hrow(
                  [
                    hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                    Flexible(
                      flex: 169,
                      child: Text(
                        '可随时在员工详情中重新启用',
                        style: hts(
                          13,
                          dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                          lh: 19,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.start,
                  gap: 8,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
            hrow(
              [
                Expanded(
                  flex: 10,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: AppButton(
                      label: '取消',
                      kind: AppButtonKind.secondary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => openRoute(
                        context,
                        'StaffDetail',
                        arguments: StaffRouteData(staffId: d['id'] as String?),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 16,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey:
                          'DisableStaff>Staff-${identityHashCode(context)}',
                      label: '确认停用',
                      kind: AppButtonKind.danger,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: open.isNotEmpty
                          ? () => AppToast.show(context, '请先转交进行中的订单')
                          : () => runBusy(
                              'DisableStaff>Staff-${identityHashCode(context)}',
                              () async {
                                try {
                                  await StaffFlow.setStatus(id, 'disabled');
                                  if (context.mounted) {
                                    openRoute(context, 'Staff');
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    AppToast.error(context, e);
                                  }
                                }
                              },
                            ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 14,
        ),
      ),
    );
  }
}

class DisableStaffSheet extends StatelessWidget {
  final String? staffId;
  const DisableStaffSheet({super.key, this.staffId});
  @override
  Widget build(BuildContext context) => StaffLiveHost(
    sheet: true,
    staffId: staffId,
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, data) => DisableStaffTemplate(d: data),
  );
}
