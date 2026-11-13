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

class StaffEnableTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StaffEnableTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final id = '${d['id']}';
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    return AsyncActionScope(
      actionKey: 'StaffEnable>Staff-${identityHashCode(context)}',
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
              '重新启用 $name 的账号？',
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
              pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: hrow(
                [
                  hbox(
                    w: 40,
                    h: 40,
                    bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                    radius: BorderRadius.circular(20),
                    align: Alignment(0, 0),
                    child: Text(
                      staffInitial(d),
                      style: hts(
                        15,
                        dk(context, Color(0xFF3F3F46), Color(0xFFD4D4D8)),
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
                            lh: 22,
                          ),
                        ),
                        Text(
                          '$role · 已停用 · ${staffMonthDay(d['disabled_at'])}',
                          style: hts(
                            12,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 16,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 1,
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
                      flex: 130,
                      child: Text(
                        '恢复登录员工端的权限',
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
                hrow(
                  [
                    hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                    Flexible(
                      flex: 260,
                      child: Text(
                        '角色、擅长项目与提成方案保持停用前的设置',
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
                hrow(
                  [
                    hsvg(dk(context, Svgs.s101, Svgs.s102), w: 14, h: 14),
                    Flexible(
                      flex: 143,
                      child: Text(
                        '历史施工记录与提成保留',
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
                        'StaffDetailOff',
                        arguments: StaffRouteData(staffId: d['id'] as String?),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey:
                          'StaffEnable>Staff-${identityHashCode(context)}',
                      label: '确认启用',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => runBusy(
                        'StaffEnable>Staff-${identityHashCode(context)}',
                        () async {
                          try {
                            await StaffFlow.setStatus(id, 'enabled');
                            if (context.mounted) openRoute(context, 'Staff');
                          } catch (e) {
                            if (context.mounted) AppToast.error(context, e);
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

class StaffEnableSheet extends StatelessWidget {
  final String? staffId;
  const StaffEnableSheet({super.key, this.staffId});
  @override
  Widget build(BuildContext context) => StaffLiveHost(
    sheet: true,
    staffId: staffId,
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, data) => StaffEnableTemplate(d: data),
  );
}
