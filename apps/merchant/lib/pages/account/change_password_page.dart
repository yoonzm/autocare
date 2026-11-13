import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/password_validation.dart';
import '../../backend/store_profile.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/text_input.dart';
import '../../resources/merchant_svgs.dart';
import '../../routes.dart' show openRoute;

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  final _visible = [false, false, false];
  late final _api = merchantApi;
  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final problem = passwordChangeError(
      current: _currentPassword.text,
      next: _newPassword.text,
      confirmation: _confirmation.text,
      phone: storeProfile.localPhone,
    );
    if (problem != null) throw AppError(problem);
    await _api.changePassword(_currentPassword.text, _newPassword.text);
    if (!mounted) return;
    AppToast.show(context, '密码已修改', kind: ToastKind.success);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (actionKey, onSave) => AsyncActionScope(
        actionKey: actionKey,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 844,
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
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '修改登录密码',
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
                          hcol(
                            [
                              Text.rich(
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
                                      text: '当前密码 ',
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
                                      text: '*',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              hbox(
                                minH: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _currentPassword,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '请输入当前密码',
                                        obscure: !_visible[0],
                                      ),
                                    ),
                                    PasswordVisibilityButton(
                                      visible: _visible[0],
                                      onPressed: () => setState(
                                        () => _visible[0] = !_visible[0],
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 10,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                          hcol(
                            [
                              Text.rich(
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
                                      text: '新密码 ',
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
                                      text: '*',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              hbox(
                                minH: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _newPassword,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '8-20 位，含字母和数字',

                                        obscure: !_visible[1],
                                      ),
                                    ),
                                    PasswordVisibilityButton(
                                      visible: _visible[1],
                                      onPressed: () => setState(
                                        () => _visible[1] = !_visible[1],
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 10,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                          hcol(
                            [
                              hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: hbox(
                                        h: 4,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: hbox(
                                        h: 4,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: hbox(
                                        h: 4,
                                        bg: Color(0xFF17C964),
                                        radius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: hbox(
                                        h: 4,
                                        bg: dk(
                                          context,
                                          Color(0xFFE4E4E7),
                                          Color(0xFF3A3A40),
                                        ),
                                        radius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 6,
                                intrinsic: true,
                              ),
                              Text(
                                '强度：强',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFF2B7745),
                                    Color(0xFF5FD48C),
                                  ),
                                  w: FontWeight.w500,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 8,
                          ),
                          hcol(
                            [
                              Text.rich(
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
                                      text: '确认新密码 ',
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
                                      text: '*',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFFA43433),
                                          Color(0xFFFF7B7E),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              hbox(
                                minH: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(14, 0, 14, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _confirmation,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '再次输入新密码',

                                        obscure: !_visible[2],
                                      ),
                                    ),
                                    PasswordVisibilityButton(
                                      visible: _visible[2],
                                      onPressed: () => setState(
                                        () => _visible[2] = !_visible[2],
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 10,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 16,
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
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 76,
                                child: Text(
                                  '长度 8–20 位',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 117,
                                child: Text(
                                  '同时包含字母和数字',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 117,
                                child: Text(
                                  '不能与当前密码相同',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                          hrow(
                            [
                              hsvg(Svgs.s87, w: 14, h: 14),
                              Flexible(
                                flex: 117,
                                child: Text(
                                  '不含手机号连续数字',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF3F3F46),
                                      Color(0xFFD4D4D8),
                                    ),
                                  ),
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
                    AppButton(
                      label: '忘记当前密码？用验证码重置',
                      kind: AppButtonKind.text,
                      size: AppButtonSize.medium,
                      expanded: false,
                      onPressed: () => openRoute(context, 'ForgotVerify'),
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
                      flex: 1,
                      child: ActionButton(
                        actionKey: actionKey,
                        label: '确认修改',
                        kind: AppButtonKind.primary,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: onSave,
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
        ),
      ),
    );
  }
}
