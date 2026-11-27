import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/password_validation.dart';
import '../../backend/store_profile.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/text_input.dart';
import '../../resources/merchant_svgs.dart';
import '../../routes.dart' show openRoute;
import '../../kit/page_header.dart';
import 'password_strength_widgets.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmation = TextEditingController();
  late final _strengthInputs = Listenable.merge([
    _currentPassword,
    _newPassword,
  ]);
  final _visible = [false, false, false];
  late final _api = merchantApi;

  PasswordEvaluation _evaluate() => evaluatePassword(
    _newPassword.text,
    current: _currentPassword.text,
    phone: storeProfile.localPhone,
  );
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
      builder: (actionKey, onSave) => ListenableBuilder(
        listenable: Listenable.merge([
          busyActions,
          _currentPassword,
          _newPassword,
          _confirmation,
        ]),
        builder: (context, child) => ConfirmDiscard(
          dirty: _currentPassword.text.isNotEmpty ||
              _newPassword.text.isNotEmpty ||
              _confirmation.text.isNotEmpty,
          busy: busyActions.value.contains(actionKey),
          child: child!,
        ),
        child: AsyncActionScope(
          actionKey: actionKey,
          child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          header: AppPageHeader(title: '修改登录密码'),
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, 8, 20, 120),
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
                                      hiddenIcon: NegMargin(
                                        top: 0,
                                        left: 0,
                                        child: hbox(
                                          w: 32,
                                          h: 32,
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(context, Svgs.s85, Svgs.s86),
                                                w: 20,
                                                h: 20,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
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
                                      hiddenIcon: NegMargin(
                                        top: 0,
                                        left: 0,
                                        child: hbox(
                                          w: 32,
                                          h: 32,
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(context, Svgs.s85, Svgs.s86),
                                                w: 20,
                                                h: 20,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
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
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 6,
                          ),
                          ListenableBuilder(
                            listenable: _strengthInputs,
                            builder: (context, _) => PasswordStrengthBar(
                              strength: _evaluate().strength,
                            ),
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
                                      hiddenIcon: NegMargin(
                                        top: 0,
                                        left: 0,
                                        child: hbox(
                                          w: 32,
                                          h: 32,
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(context, Svgs.s85, Svgs.s86),
                                                w: 20,
                                                h: 20,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
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
                    ListenableBuilder(
                      listenable: _strengthInputs,
                      builder: (context, _) {
                        final eval = _evaluate();
                        return PasswordRulesCard(
                          rules: [
                            PasswordRuleItem(
                              label: '长度 8–20 位',
                              satisfied: eval.hasLength,
                            ),
                            PasswordRuleItem(
                              label: '同时包含字母和数字',
                              satisfied: eval.hasLetterAndDigit,
                            ),
                            PasswordRuleItem(
                              label: '不能与当前密码相同',
                              satisfied: eval.differsFromCurrent,
                            ),
                            PasswordRuleItem(
                              label: '不含手机号连续数字',
                              satisfied: eval.noPhoneDigits,
                            ),
                          ],
                        );
                      },
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        '忘记当前密码？用验证码重置',
                        style: hts(
                          13,
                          dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onTap: () => openRoute(context, 'ForgotVerify'),
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
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onSave,
                        child: hbox(
                          h: 50,
                          bg: dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                          radius: BorderRadius.circular(25),
                          child: Align(
                            alignment: Alignment(0, 0),
                            widthFactor: 1,
                            child: hBusy(
                              actionKey,
                              Text(
                                '确认修改',
                                style: hts(
                                  15,
                                  dk(
                                    context,
                                    Color(0xFFFFFFFF),
                                    Color(0xFF18181B),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
                              ),
                              style: hts(
                                15,
                                dk(
                                  context,
                                  Color(0xFFFFFFFF),
                                  Color(0xFF18181B),
                                ),
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
        ),
        ),
      ),
    );
  }
}
