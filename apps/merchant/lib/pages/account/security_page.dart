import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import 'login_page.dart';
import '../../routes.dart' show openRoute;
import '../../widgets/account_tools.dart';
import '../../resources/merchant_svgs.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _api = merchantApi;
  Future<void> _signOutAll() async {
    try {
      await _api.signOutAll();
    } catch (e) {
      throw AppError('退出失败：${AppError.from(e).message}');
    }
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'Login'),
        builder: (_) => const LoginPage(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _signOutAll,
      builder: (actionKey, onSignOut) => AsyncActionScope(
        actionKey: actionKey,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 983,
          fixedHeight: false,
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
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
                            '账号与安全',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        hbox(w: 44),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '登录信息',
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
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => openRoute(context, 'ChangePhone'),
                                child: hbox(
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
                                      hLiveText(
                                        (p) => p.maskedPhone,
                                        hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
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
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              ),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    openRoute(context, 'ChangePassword'),
                                child: hbox(
                                  minH: 54,
                                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '登录密码',
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
                                        '已设置 · 修改',
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
                                      hsvg(
                                        dk(context, Svgs.s3, Svgs.s4),
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
                      gap: 8,
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '登录设备',
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
                          child: AccountDevices(
                            row: (context, device, deviceAction) => hbox(
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
                                          dk(context, Svgs.s340, Svgs.s341),
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
                                          accountDeviceName(device),
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
                                          accountDeviceTime(device),
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
                                  deviceAction,
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 8,
                    ),
                    ActionButton(
                      actionKey: actionKey,
                      label: '退出所有设备',
                      kind: AppButtonKind.primary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: onSignOut,
                    ),
                    AppButton(
                      label: '注销账号',
                      kind: AppButtonKind.danger,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => openRoute(context, 'DeleteAccount'),
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
      ),
    );
  }
}
