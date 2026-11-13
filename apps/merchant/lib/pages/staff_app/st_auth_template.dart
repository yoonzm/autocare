import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/access_flow.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/staff_svgs.dart';

class StAuthTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  final String actionKey;
  final VoidCallback onJoin;
  const StAuthTemplate({
    super.key,
    required this.d,
    required this.actionKey,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final role = '${d['role']}';
    final store = '${d['store_name']}';
    final items = stPermItems[role] ?? stPermItems['technician']!;
    final caps = ((d['caps'] as Map?) ?? const {}).map(
      (k, v) => MapEntry('$k', v == true),
    );

    Widget permCell(String key, String label) {
      final on = caps[key] == true;
      return Expanded(
        flex: 1,
        child: on
            ? hrow(
                [
                  hbox(
                    w: 20,
                    h: 20,
                    bg: dk(
                      context,
                      Color(0xFFDDF6E7),
                      Color.fromRGBO(23, 201, 100, 0.16),
                    ),
                    radius: BorderRadius.circular(10),
                    child: hrow(
                      [hsvg(dk(context, Svgs.s5, Svgs.s6), w: 12, h: 12)],
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
                        dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                        lh: 18,
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 8,
              )
            : hrow(
                [
                  hbox(
                    w: 20,
                    h: 20,
                    bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                    radius: BorderRadius.circular(10),
                    child: hrow(
                      [hsvg(dk(context, Svgs.s7, Svgs.s8), w: 12, h: 12)],
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
                        dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
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

    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            h: 300,
            grad: LinearGradient(
              begin: Alignment(-0.5, -0.866),
              end: Alignment(0.5, 0.866),
              colors: [Color(0xFF26262C), Color(0xFF18181B), Color(0xFF2B2418)],
              stops: [0, 0.55, 1],
            ),
            radius: BorderRadius.only(
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
              bottomRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
            ),
            clip: true,
            child: hstack(
              hcol(
                [],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 0,
                min: false,
              ),
              [
                Positioned(
                  left: 45,
                  top: -10,
                  child: IntrinsicWidth(child: hsvg(Svgs.s3, w: 300, h: 300)),
                ),
                Positioned(
                  top: -80,
                  right: -60,
                  width: 260,
                  height: 260,
                  child: hbox(
                    w: 260,
                    h: 260,
                    radius: BorderRadius.circular(130),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 88,
                  right: 0,
                  child: hcol(
                    [
                      hbox(
                        w: 64,
                        h: 64,
                        grad: LinearGradient(
                          begin: Alignment(-0.5, -0.866),
                          end: Alignment(0.5, 0.866),
                          colors: [Color(0xFF7CC0FF), Color(0xFF0485F7)],
                          stops: [0, 1],
                        ),
                        radius: BorderRadius.circular(20),
                        shadow: [
                          BoxShadow(
                            color: Color.fromRGBO(4, 133, 247, 0.4),
                            offset: Offset(0, 10),
                            blurRadius: 28,
                            spreadRadius: 0,
                          ),
                        ],
                        child: hrow(
                          [hsvg(Svgs.s4, w: 32, h: 32)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      Text(
                        '欢迎加入$store',
                        style: hts(
                          22,
                          Color(0xFFFAFAFA),
                          w: FontWeight.w600,
                          lh: 30,
                        ),
                      ),
                      Text(
                        '已为你开通${Access.roleName(role)}账号',
                        style: hts(
                          13,
                          dk(context, Color(0xFFA1A1AA), Color(0xFF80808A)),
                          lh: 19,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.center,
                    gap: 10,
                  ),
                ),
              ],
            ),
          ),
          hbox(
            pad: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: hcol(
              [
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
                        minH: 48,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '门店',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            Text(
                              store,
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFFFAFAFA),
                                ),
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      hbox(
                        minH: 48,
                        pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: hrow(
                          [
                            Expanded(
                              flex: 1,
                              child: Text(
                                '身份',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ),
                            hbox(
                              bg: dk(
                                context,
                                Color(0xFFDDF6E7),
                                Color.fromRGBO(23, 201, 100, 0.16),
                              ),
                              radius: BorderRadius.circular(10),
                              pad: EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Text(
                                Access.roleName(role),
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF2B7745),
                                    Color(0xFF5FD48C),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                      hbox(
                        h: 1,
                        bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)),
                        margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                      ),
                      hbox(
                        minH: 48,
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
                                    Color(0xFF71717A),
                                    Color(0xFF9A9AA3),
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
                                w: FontWeight.w500,
                                lh: 22,
                              ),
                            ),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
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
                      Text(
                        '你可以',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hcol([
                        for (var i = 0; i < items.length; i += 2)
                          hrow(
                            [
                              permCell(items[i].$1, items[i].$2),
                              permCell(items[i + 1].$1, items[i + 1].$2),
                            ],
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                            intrinsic: true,
                            min: false,
                          ),
                      ], gap: 10),
                      Text(
                        '权限由老板或店长设置，调整后立即生效。',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 17,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 12,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 14,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
      overlays: [
        HBottomDock(
          child: hbox(
            bg: dk(
              context,
              Color.fromRGBO(255, 255, 255, 0.94),
              Color.fromRGBO(9, 9, 11, 0.92),
            ),
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
            pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
            child: hcol(
              [
                ActionButton(
                  actionKey: actionKey,
                  label: '确认加入并进入工作台',
                  kind: AppButtonKind.primary,
                  size: AppButtonSize.large,
                  expanded: true,
                  onPressed: onJoin,
                ),
                AppButton(
                  label: '不是我，换个账号',
                  kind: AppButtonKind.text,
                  size: AppButtonSize.medium,
                  expanded: false,
                  onPressed: () => AccessFlow.signOut(context),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// 加入门店：员工首次用该身份登录时确认一次（每个「门店 + 身份」只出现一次）。
class StAuthLivePage extends StatefulWidget {
  const StAuthLivePage({super.key});
  @override
  State<StAuthLivePage> createState() => _StAuthLivePageState();
}

class _StAuthLivePageState extends State<StAuthLivePage> {
  late final _actionKey = 'staff-join-${identityHashCode(this)}';
  Future<void> _join() => runBusy(_actionKey, () async {
    try {
      await AccessFlow.join(context);
    } catch (e) {
      if (mounted) AccessFlow.toastError(context, e);
    }
  });
  @override
  Widget build(BuildContext context) => AsyncActionScope(
    actionKey: _actionKey,
    child: StAuthTemplate(
      d: Access.context,
      actionKey: _actionKey,
      onJoin: _join,
    ),
  );
}

/// 加入页展示的权限（与「员工与权限」里该身份的开关一致，数据来自服务端生效权限）。
const stPermItems = <String, List<(String, String)>>{
  'technician': [
    ('order_view_own', '查看派给我的任务'),
    ('progress_update', '更新施工进度'),
    ('stock_use', '领用耗材'),
    ('perf_view_own', '查看个人业绩'),
    ('stats_view_store', '查看门店营业额'),
    ('member_recharge_refund', '会员充值与退款'),
  ],
  'cashier': [
    ('cashier', '开单收银'),
    ('cash_queue', '处理待收银'),
    ('member_recharge_refund', '会员充值'),
    ('appt_edit', '新建与改期预约'),
    ('order_refund', '订单退款'),
    ('stats_view_store', '查看门店营业统计'),
  ],
  'manager': [
    ('order_view_all', '查看全店任务'),
    ('cashier', '开单收银'),
    ('member_recharge_refund', '会员充值'),
    ('stock_manage', '入库与盘点'),
    ('order_refund', '订单退款'),
    ('stats_view_store', '查看门店营业统计'),
  ],
};
