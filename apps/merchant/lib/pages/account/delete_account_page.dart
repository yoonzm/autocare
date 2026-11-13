import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import '../../kit/text_input.dart';
import '../../kit/sms_code.dart';
import '../../backend/merchant_api.dart';
import '../../backend/store_profile.dart';
import '../../backend/phone_validation.dart';
import '../../routes.dart' show openRoute;
import 'login_page.dart';
import '../../widgets/account_tools.dart';
import '../../resources/merchant_svgs.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _code = TextEditingController();
  final _sms = SmsCodeController();
  bool _agreed = false;
  late final _api = merchantApi;
  String? get _problem {
    if (!RegExp(r'^\d{6}$').hasMatch(_code.text.trim())) return '请输入 6 位短信验证码';
    if (!_agreed) return '请先勾选“我已了解注销后果”';
    return null;
  }

  @override
  void dispose() {
    _code.dispose();
    _sms.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = storeProfile.localPhone;
    if (!isMobileNumber(phone)) {
      AppToast.show(context, '请输入正确的 11 位手机号');
      return;
    }
    try {
      final sent = await _sms.send(
        () => _api.sendCode(phone, purpose: 'delete_account'),
      );
      if (sent && mounted) AppToast.show(context, '验证码已发送，请查看短信');
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  }

  Future<void> _submit() {
    final problem = _problem;
    if (problem != null) throw AppError(problem);
    return _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    await _api.deleteAccount(_code.text.trim());
    try {
      await _api.signOut();
    } catch (_) {
      // 注销接口已作废所有会话，本地退出失败不影响注销结果。
    }
    if (!mounted) return;
    AppToast.show(context, '账号已注销', kind: ToastKind.success);
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
      onTap: _submit,
      builder: (actionKey, onSubmit) => AsyncActionScope(
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
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '注销账号',
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
                      bg: dk(
                        context,
                        Color(0xFFFFE1E2),
                        Color.fromRGBO(255, 56, 60, 0.18),
                      ),
                      radius: BorderRadius.circular(18),
                      pad: EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: hrow(
                        [
                          hsvg(dk(context, Svgs.s98, Svgs.s99), w: 18, h: 18),
                          Flexible(
                            flex: 504,
                            child: Text(
                              '注销后账号立即失效且无法恢复，请谨慎操作。',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFFA43433),
                                  Color(0xFFFF7B7E),
                                ),
                                lh: 19,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.start,
                        gap: 10,
                      ),
                    ),
                    AccountCancellationChecks(
                      builder: (context, check) => hcol(
                        [
                          hbox(
                            pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                            child: Text(
                              '注销前需满足',
                              style: hts(
                                13,
                                dk(
                                  context,
                                  Color(0xFF52525B),
                                  Color(0xFFA8A8B3),
                                ),
                                w: FontWeight.w500,
                                lh: 18,
                              ),
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
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
                                  minH: 58,
                                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 20,
                                        h: 20,
                                        bg: check['can_cancel'] == true
                                            ? Color.fromRGBO(
                                                23,
                                                201,
                                                100,
                                                0.133,
                                              )
                                            : Color.fromRGBO(
                                                255,
                                                56,
                                                60,
                                                0.133,
                                              ),
                                        radius: BorderRadius.circular(10),
                                        child: hrow(
                                          [
                                            hsvg(
                                              check['can_cancel'] == true
                                                  ? Svgs.s20
                                                  : Svgs.s399,
                                              w: 12,
                                              h: 12,
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
                                              '无进行中的订单、挂单与预约',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                lh: 20,
                                              ),
                                            ),
                                            Text(
                                              cancellationWork(check),
                                              style: hts(
                                                12,
                                                dk(
                                                  context,
                                                  (check['can_cancel'] == true
                                                      ? Color(0xFF2B7745)
                                                      : Color(0xFFA43433)),
                                                  (check['can_cancel'] == true
                                                      ? Color(0xFF5FD48C)
                                                      : Color(0xFFFF7B7E)),
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
                                      if (check['can_cancel'] != true)
                                        AppButton(
                                          label: '去处理',
                                          kind: AppButtonKind.text,
                                          size: AppButtonSize.medium,
                                          expanded: false,
                                          onPressed: () => openRoute(
                                            context,
                                            check['holds'] > 0
                                                ? 'HoldList'
                                                : 'Appointments',
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
                                  bg: dk(
                                    context,
                                    Color(0xFFEFEFF1),
                                    Color(0xFF2A2A2E),
                                  ),
                                  margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                                ),
                                hbox(
                                  minH: 58,
                                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 20,
                                        h: 20,
                                        bg: Color.fromRGBO(23, 201, 100, 0.133),
                                        radius: BorderRadius.circular(10),
                                        child: hrow(
                                          [hsvg(Svgs.s20, w: 12, h: 12)],
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
                                              '无未结清的欠费',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                lh: 20,
                                              ),
                                            ),
                                            Text(
                                              '${check['billing_note']}',
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
                                  minH: 58,
                                  pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                  child: hrow(
                                    [
                                      hbox(
                                        w: 20,
                                        h: 20,
                                        bg: Color.fromRGBO(23, 201, 100, 0.133),
                                        radius: BorderRadius.circular(10),
                                        child: hrow(
                                          [hsvg(Svgs.s20, w: 12, h: 12)],
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
                                              '经营数据保留在服务器',
                                              style: hts(
                                                14,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                lh: 20,
                                              ),
                                            ),
                                            Text(
                                              '${check['data_note']}',
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
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '注销后将',
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
                          pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: hcol(
                            [
                              hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s101, Svgs.s102),
                                    w: 14,
                                    h: 14,
                                  ),
                                  Flexible(
                                    flex: 182,
                                    child: Text(
                                      '停用账号并退出所有设备',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
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
                                  hsvg(
                                    dk(context, Svgs.s101, Svgs.s102),
                                    w: 14,
                                    h: 14,
                                  ),
                                  Flexible(
                                    flex: 195,
                                    child: Text(
                                      '门店经营数据保留，不会被清除',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
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
                                  hsvg(
                                    dk(context, Svgs.s101, Svgs.s102),
                                    w: 14,
                                    h: 14,
                                  ),
                                  Flexible(
                                    flex: 221,
                                    child: Text(
                                      '注销后账号权益立即终止',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF52525B),
                                          Color(0xFFA8A8B3),
                                        ),
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
                            gap: 10,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
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
                                      text: '短信验证码 ',
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
                                h: 48,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(14),
                                pad: EdgeInsets.fromLTRB(14, 0, 6, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _code,
                                        onChanged: (_) => setState(() {}),
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '6 位数字',
                                        keyboard: TextInputType.number,
                                      ),
                                    ),
                                    ListenableBuilder(
                                      listenable: _sms,
                                      builder: (context, _) => smsCodeButton(
                                        _sms,
                                        onPressed: _sendCode,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 10,
                                ),
                              ),
                              hLiveText(
                                (p) => '验证码将发送至当前账号绑定的手机号 ${p.maskedPhone}',
                                hts(
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
                            gap: 6,
                          ),
                          hrow(
                            [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                                child: HCheck(
                                  initial: false,
                                  value: _agreed,
                                  onChanged: (value) =>
                                      setState(() => _agreed = value),
                                  size: 16,
                                  color: Color(0xFFFF383C),
                                ),
                              ),
                              Flexible(
                                flex: 208,
                                child: Text(
                                  '我已了解注销后果，并同意注销账号',
                                  style: hts(
                                    13,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
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
                      flex: 1,
                      child: ActionButton(
                        actionKey: actionKey,
                        label: '申请注销',
                        kind: AppButtonKind.danger,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: _problem == null ? onSubmit : null,
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
