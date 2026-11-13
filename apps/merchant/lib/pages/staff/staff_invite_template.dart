import 'package:flutter/material.dart';

import '../../routes.dart' show openRoute;

import 'package:flutter/services.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';
import 'staff_live.dart';

// TODO: 邀请二维码需要 App 下载地址（STAFF_INVITE_BASE_URL）和二维码生成；在此之前不展示示意二维码，
// 复制的是登录说明文字（员工按手机号匹配自动激活，不依赖邀请链接）。短信邀请仍需助通邀请模板，后端明确返回 501。
class StaffInviteTemplate extends StatelessWidget {
  final Map<String, dynamic> d;
  const StaffInviteTemplate({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final id = '${d['id']}';
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    final masked = StaffFlow.maskedPhone(d['phone']);
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 1008,
      fixedHeight: false,
      flow: hcol(
        [
          hbox(
            pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
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
                          [hsvg(dk(context, Svgs.s26, Svgs.s27), w: 20, h: 20)],
                          main: MainAxisAlignment.center,
                          cross: CrossAxisAlignment.center,
                          gap: 0,
                        ),
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.center,
                  gap: 0,
                ),
                hbox(
                  pad: EdgeInsets.fromLTRB(0, 26, 0, 6),
                  child: hstack(
                    hcol(
                      [
                        hbox(
                          w: 128,
                          h: 128,
                          child: hstack(
                            hrow(
                              [
                                hbox(
                                  w: 76,
                                  h: 76,
                                  grad: LinearGradient(
                                    begin: Alignment(-0.342, -0.94),
                                    end: Alignment(0.342, 0.94),
                                    colors: [
                                      Color(0xFF3BDC86),
                                      Color(0xFF17C964),
                                    ],
                                    stops: [0, 1],
                                  ),
                                  radius: BorderRadius.circular(38),
                                  shadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(23, 201, 100, 0.35),
                                      offset: Offset(0, 10),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                  child: hrow(
                                    [hsvg(Svgs.s29, w: 40, h: 40)],
                                    main: MainAxisAlignment.center,
                                    cross: CrossAxisAlignment.center,
                                    gap: 0,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                            [
                              Positioned(
                                left: 0,
                                top: 0,
                                child: IntrinsicWidth(
                                  child: hsvg(Svgs.s28, w: 128, h: 128),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '员工已添加',
                          style: hts(
                            21,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 28,
                          ),
                        ),
                        Text(
                          '$name · $role',
                          style: hts(
                            13,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 19,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    [],
                    behind: [
                      Positioned(
                        left: 38,
                        top: 4,
                        width: 8,
                        height: 8,
                        child: hbox(
                          w: 8,
                          h: 8,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4),
                        ),
                      ),
                      Positioned(
                        left: 300,
                        top: 26,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 124,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Positioned(
                        left: 318,
                        top: 114,
                        width: 9,
                        height: 9,
                        child: hbox(
                          w: 9,
                          h: 9,
                          bg: Color(0xFFF5D78E),
                          radius: BorderRadius.circular(4.5),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 74,
                        width: 6,
                        height: 6,
                        child: hbox(
                          w: 6,
                          h: 6,
                          bg: Color(0xFF0485F7),
                          radius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: 344,
                        top: 72,
                        width: 5,
                        height: 5,
                        child: hbox(
                          w: 5,
                          h: 5,
                          bg: Color(0xFF17C964),
                          radius: BorderRadius.circular(2.5),
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
                  pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: hcol(
                    [
                      hrow(
                        [
                          hbox(
                            w: 44,
                            h: 44,
                            bg: dk(
                              context,
                              Color(0xFFDDF6E7),
                              Color.fromRGBO(23, 201, 100, 0.16),
                            ),
                            radius: BorderRadius.circular(22),
                            align: Alignment(0, 0),
                            child: Text(
                              staffInitial(d),
                              style: hts(
                                17,
                                dk(
                                  context,
                                  Color(0xFF2B7745),
                                  Color(0xFF5FD48C),
                                ),
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
                                  '$role · $masked',
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
                              gap: 2,
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFDEFD6),
                              Color.fromRGBO(245, 165, 36, 0.16),
                            ),
                            radius: BorderRadius.circular(9),
                            pad: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              '待激活',
                              style: hts(
                                11,
                                dk(
                                  context,
                                  Color(0xFF855F2E),
                                  Color(0xFFF0C46A),
                                ),
                                w: FontWeight.w600,
                                lh: 18,
                              ),
                              softWrap: false,
                              maxLines: 1,
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
                    gap: 14,
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
                        '邀请$name登录汽美管家',
                        style: hts(
                          15,
                          dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          w: FontWeight.w600,
                          lh: 22,
                        ),
                      ),
                      hrow(
                        [
                          hbox(
                            bg: Color(0xFFFFFFFF),
                            radius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFFE4E4E7),
                              width: 1,
                            ),
                            pad: EdgeInsets.fromLTRB(12, 12, 12, 12),
                          ),
                        ],
                        main: MainAxisAlignment.center,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                        intrinsic: true,
                      ),
                      hcol(
                        [
                          hrow(
                            [
                              hbox(
                                w: 22,
                                h: 22,
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFF34343A),
                                ),
                                radius: BorderRadius.circular(11),
                                align: Alignment(0, 0),
                                child: Text(
                                  '1',
                                  style: hts(
                                    12,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 296,
                                child: Text(
                                  '下载并打开「汽美管家」App',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                          hrow(
                            [
                              hbox(
                                w: 22,
                                h: 22,
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFF34343A),
                                ),
                                radius: BorderRadius.circular(11),
                                align: Alignment(0, 0),
                                child: Text(
                                  '2',
                                  style: hts(
                                    12,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 247,
                                child: Text(
                                  '用该手机号获取验证码登录，无需注册门店',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                          hrow(
                            [
                              hbox(
                                w: 22,
                                h: 22,
                                bg: dk(
                                  context,
                                  Color(0xFF18181B),
                                  Color(0xFF34343A),
                                ),
                                radius: BorderRadius.circular(11),
                                align: Alignment(0, 0),
                                child: Text(
                                  '3',
                                  style: hts(
                                    12,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 276,
                                child: Text(
                                  '手机号与登记的 $masked 匹配即自动激活',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 10,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                      ),
                      hrow(
                        [
                          Expanded(
                            flex: 1,
                            child: UnconstrainedBox(
                              alignment: Alignment.topLeft,
                              constrainedAxis: Axis.horizontal,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => runBusy(
                                  'StaffInvite>copy-${identityHashCode(context)}',
                                  () async {
                                    try {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              '请下载「汽美管家」App，使用手机号 ${d['phone']} 获取验证码登录，确认加入门店即可开始使用。',
                                        ),
                                      );
                                      if (context.mounted) {
                                        AppToast.show(
                                          context,
                                          '邀请说明已复制',
                                          kind: ToastKind.success,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        AppToast.error(context, e);
                                      }
                                    }
                                  },
                                ),
                                child: hbox(
                                  h: 44,
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(22),
                                  child: Align(
                                    alignment: Alignment(0, 0),
                                    widthFactor: 1,
                                    child: hBusy(
                                      'StaffInvite>copy-${identityHashCode(context)}',
                                      Text(
                                        '复制邀请说明',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w500,
                                        ),
                                      ),
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                      ),
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
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => runBusy(
                                  'StaffInvite>sms-${identityHashCode(context)}',
                                  () async {
                                    try {
                                      await merchantApi.staff('invite', {
                                        'id': id,
                                        'via': 'sms',
                                      });
                                      if (context.mounted) {
                                        AppToast.show(
                                          context,
                                          '短信已发送',
                                          kind: ToastKind.success,
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        AppToast.error(context, e);
                                      }
                                    }
                                  },
                                ),
                                child: hbox(
                                  h: 44,
                                  bg: dk(
                                    context,
                                    Color(0xFFEEEEF0),
                                    Color(0xFF27272A),
                                  ),
                                  radius: BorderRadius.circular(22),
                                  child: Align(
                                    alignment: Alignment(0, 0),
                                    widthFactor: 1,
                                    child: hBusy(
                                      'StaffInvite>sms-${identityHashCode(context)}',
                                      Text(
                                        '发送短信',
                                        style: hts(
                                          14,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w500,
                                        ),
                                      ),
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                      ),
                                    ),
                                  ),
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
                      Text(
                        '邀请 7 天内有效，逾期可在员工详情中重新发送。',
                        style: hts(
                          12,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                          lh: 17,
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
              gap: 16,
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
            child: hrow(
              [
                Expanded(
                  flex: 10,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openRoute(context, 'StaffAdd'),
                    child: hbox(
                      h: 50,
                      bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '继续添加',
                          style: hts(
                            15,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => openRoute(context, 'Staff'),
                    child: hbox(
                      h: 50,
                      bg: Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      child: Align(
                        alignment: Alignment(0, 0),
                        widthFactor: 1,
                        child: Text(
                          '完成',
                          style: hts(
                            15,
                            Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
          ),
        ),
      ],
    );
  }
}

/// 新增员工后的邀请页：展示调用者传入的已保存员工，不读取示例数据。
class StaffInviteLivePage extends StatelessWidget {
  final Map<String, dynamic>? employee;
  const StaffInviteLivePage({super.key, this.employee});

  @override
  Widget build(BuildContext context) {
    final d = employee;
    if (d == null) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先添加员工', type: AppErrorType.notFound),
          onNext: () => Navigator.of(context).maybePop(),
        ),
      );
    }
    return StaffInviteTemplate(d: d);
  }
}
