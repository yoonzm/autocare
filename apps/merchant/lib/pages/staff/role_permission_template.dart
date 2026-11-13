import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;

import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../routes.dart' show openRoute;
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

class RolePermissionTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  final String initialRole;
  const RolePermissionTemplate({
    super.key,
    required this.d,
    this.initialRole = 'technician',
  });

  @override
  State<RolePermissionTemplate> createState() => _RolePermissionTemplateState();
}

class _RolePermissionTemplateState extends State<RolePermissionTemplate> {
  static const roles = ['manager', 'cashier', 'technician'];
  static const keys = [
    'order_view_own',
    'order_view_all',
    'progress_update',
    'cashier',
    'member_view',
    'member_recharge_refund',
    'stock_use',
    'stock_manage',
    'perf_view_own',
    'stats_view_store',
  ];
  late String role = widget.initialRole;
  late final Map<String, Map<String, bool>> edits = {
    for (final r in roles)
      r: {
        for (final k in keys)
          k: ((widget.d['permissions'] as Map?)?[r] as Map?)?[k] == true,
      },
  };
  final Set<String> dirty = {};

  bool on(String k) => edits[role]![k] ?? false;

  void set(String k, bool v) {
    if (role == 'manager') {
      AppToast.show(context, '店长权限固定为全部，不能修改');
      return;
    }
    setState(() {
      edits[role]![k] = v;
      dirty.add(role);
    });
  }

  Future<void> save() async {
    try {
      for (final r in dirty) {
        await StaffFlow.savePermissions(r, edits[r]!);
      }
      if (mounted) openRoute(context, 'Staff');
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    final count = [
      for (final s in (d['staff'] as List? ?? const []))
        if ((s as Map)['role'] == role && s['status'] != 'disabled') s,
    ].length;
    return AsyncActionScope(
      actionKey: 'RolePermission>Staff-${identityHashCode(context)}',
      child: HPage(
        bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
        height: 1080,
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
                          '角色权限',
                          style: hts(
                            17,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ActionButton(
                        actionKey:
                            'RolePermission>Staff-${identityHashCode(context)}',
                        label: '保存',
                        kind: AppButtonKind.primary,
                        size: AppButtonSize.medium,
                        expanded: false,
                        onPressed: () => runBusy(
                          'RolePermission>Staff-${identityHashCode(context)}',
                          save,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 8,
                  ),
                  AppSegmented<String>(
                    items: const [
                      SegmentItem(value: 'manager', label: '店长'),
                      SegmentItem(value: 'cashier', label: '前台收银'),
                      SegmentItem(value: 'technician', label: '施工技师'),
                    ],
                    selected: role,
                    onChanged: (v) => setState(() => role = v),
                  ),
                  hbox(
                    bg: dk(
                      context,
                      Color(0xFFE1F0FE),
                      Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    radius: BorderRadius.circular(18),
                    pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: hrow(
                      [
                        hsvg(dk(context, Svgs.s336, Svgs.s337), w: 18, h: 18),
                        Flexible(
                          flex: 210,
                          child: Text(
                            '修改后对该角色的 $count 名员工立即生效',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              lh: 18,
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 10,
                    ),
                  ),
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '工单与施工',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
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
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '查看派给自己的工单',
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
                                  ),
                                  HSwitchValue(
                                    value: on('order_view_own'),
                                    onChanged: (v) => set('order_view_own', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '查看全店工单',
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
                                  ),
                                  HSwitchValue(
                                    value: on('order_view_all'),
                                    onChanged: (v) => set('order_view_all', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text(
                                          '更新施工进度与拍照',
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
                                          '完工照片同步给车主',
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
                                      gap: 0,
                                    ),
                                  ),
                                  HSwitchValue(
                                    value: on('progress_update'),
                                    onChanged: (v) => set('progress_update', v),
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                  ),
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '收银与会员',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
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
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '开单收银',
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
                                  ),
                                  HSwitchValue(
                                    value: on('cashier'),
                                    onChanged: (v) => set('cashier', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '查看会员资料',
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
                                  ),
                                  HSwitchValue(
                                    value: on('member_view'),
                                    onChanged: (v) => set('member_view', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: hcol(
                                      [
                                        Text(
                                          '会员充值与退款',
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
                                          '涉及资金，建议仅店长开启',
                                          style: hts(
                                            12,
                                            dk(
                                              context,
                                              Color(0xFFA43433),
                                              Color(0xFFFF7B7E),
                                            ),
                                            lh: 16,
                                          ),
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.stretch,
                                      gap: 0,
                                    ),
                                  ),
                                  HSwitchValue(
                                    value: on('member_recharge_refund'),
                                    onChanged: (v) =>
                                        set('member_recharge_refund', v),
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                  ),
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '库存',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
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
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '领用耗材',
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
                                  ),
                                  HSwitchValue(
                                    value: on('stock_use'),
                                    onChanged: (v) => set('stock_use', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '入库与盘点',
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
                                  ),
                                  HSwitchValue(
                                    value: on('stock_manage'),
                                    onChanged: (v) => set('stock_manage', v),
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
                  ),
                  hcol(
                    [
                      hbox(
                        pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                        child: Text(
                          '经营数据',
                          style: hts(
                            13,
                            dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                            w: FontWeight.w500,
                            lh: 18,
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
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '查看个人业绩与提成',
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
                                  ),
                                  HSwitchValue(
                                    value: on('perf_view_own'),
                                    onChanged: (v) => set('perf_view_own', v),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                            hbox(
                              h: 1,
                              bg: dk(
                                context,
                                Color(0xFFEFEFF1),
                                Color(0xFF2A2A2E),
                              ),
                              margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                            ),
                            hbox(
                              minH: 52,
                              pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '查看门店营业统计',
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
                                  ),
                                  HSwitchValue(
                                    value: on('stats_view_store'),
                                    onChanged: (v) =>
                                        set('stats_view_store', v),
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
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 8,
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

/// 角色权限（设计稿 RolePermission）：逐店读取并保存角色权限开关，店长固定为全部。
class RolePermissionLivePage extends StatelessWidget {
  final String initialRole;
  const RolePermissionLivePage({super.key, this.initialRole = 'technician'});

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    title: '角色权限',
    needsId: false,
    load: (_) => merchantApi.staff('list'),
    builder: (_, d) => RolePermissionTemplate(d: d, initialRole: initialRole),
  );
}
