import '../../kit/buttons.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/password_validation.dart';
import '../../backend/phone_validation.dart';
import '../../backend/registration_data.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/sms_code.dart';
import '../../kit/text_input.dart';
import '../../resources/merchant_svgs.dart';
import '../../routes.dart' show openRoute;
import 'reg_shop_page.dart';

class RegPhonePage extends StatefulWidget {
  const RegPhonePage({super.key});
  @override
  State<RegPhonePage> createState() => _RegPhonePageState();
}

class _RegPhonePageState extends State<RegPhonePage> {
  final _phone = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _sms = SmsCodeController();
  bool _agreed = true;
  bool _passwordVisible = false;
  late final _api = merchantApi;
  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    _sms.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final phone = _phone.text.trim();
    if (!isMobileNumber(phone)) {
      AppToast.show(context, '请输入正确的 11 位手机号');
      return;
    }
    try {
      final sent = await _sms.send(
        () => _api.sendCode(phone, purpose: 'register'),
      );
      if (sent && mounted) AppToast.show(context, '验证码已发送，请查看短信');
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  }

  Future<void> _continue() async {
    final phone = _phone.text.trim();
    final code = _code.text.trim();
    final password = _password.text;
    final phoneError = phoneVerificationError(phone: phone, code: code);
    if (phoneError != null) throw AppError(phoneError);
    if (password.isEmpty) throw const AppError('请设置登录密码');
    final passwordError = passwordRuleError(password);
    if (passwordError != null) throw AppError(passwordError);
    if (!_agreed) throw const AppError('请先阅读并同意用户服务协议和隐私政策');
    await _api.checkCode(phone, code);
    if (!mounted) return;
    final origin = ModalRoute.of(context);
    unawaited(
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'RegShop'),
          builder: (_) => RegShopPage(
            credentials: RegistrationCredentials(
              phone: phone,
              code: code,
              password: password,
            ),
            originRoute: origin,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _continue,
      builder: (actionKey, onContinue) => AsyncActionScope(
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
                            '免费开通',
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
                    hrow(
                      [
                        Expanded(
                          flex: 1,
                          child: UnconstrainedBox(
                            alignment: Alignment.topLeft,
                            constrainedAxis: Axis.horizontal,
                            child: hbox(
                              h: 4,
                              bg: Color(0xFF0485F7),
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
                                Color(0xFFD4D4D8),
                                Color(0xFF3F3F46),
                              ),
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
                                Color(0xFFD4D4D8),
                                Color(0xFF3F3F46),
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
                    hcol(
                      [
                        Text(
                          '开通你的门店系统',
                          style: hts(
                            24,
                            dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                            w: FontWeight.w600,
                            lh: 32,
                            ls: -0.48,
                          ),
                        ),
                        Text(
                          '手机号注册，3 分钟完成开通',
                          style: hts(
                            14,
                            dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            lh: 20,
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
                            Flexible(
                              flex: 123,
                              child: Text(
                                '限时免费使用',
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
                          gap: 6,
                        ),
                        hrow(
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
                            Flexible(
                              flex: 104,
                              child: Text(
                                '无需绑定支付方式',
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
                          gap: 6,
                        ),
                        hrow(
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
                            Flexible(
                              flex: 117,
                              child: Text(
                                '无需绑定支付方式',
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
                          gap: 6,
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
                                      text: '手机号 ',
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
                                    Text(
                                      '+86',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                      ),
                                    ),
                                    hbox(
                                      w: 1,
                                      h: 18,
                                      bg: dk(
                                        context,
                                        Color(0xFFD4D4D8),
                                        Color(0xFF3F3F46),
                                      ),
                                    ),
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _phone,
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                        hint: '请输入手机号',
                                        keyboard: TextInputType.phone,
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
                                      text: '验证码 ',
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
                                pad: EdgeInsets.fromLTRB(14, 0, 6, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      child: AppTextInput(
                                        controller: _code,
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
                                      ),
                                    ),
                                    AnimatedBuilder(
                                      animation: _sms,
                                      builder: (context, _) => smsCodeButton(
                                        _sms,
                                        onPressed: () => _sendCode(),
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
                                      text: '设置登录密码 ',
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
                                        controller: _password,
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
                                        obscure: !_passwordVisible,
                                      ),
                                    ),
                                    PasswordVisibilityButton(
                                      visible: _passwordVisible,
                                      onPressed: () => setState(
                                        () => _passwordVisible =
                                            !_passwordVisible,
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
                          hrow(
                            [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 1, 0, 0),
                                child: HCheck(
                                  initial: true,
                                  value: _agreed,
                                  onChanged: (value) =>
                                      setState(() => _agreed = value),
                                  size: 16,
                                  color: Color(0xFF0485F7),
                                ),
                              ),
                              Flexible(
                                flex: 84,
                                child: Text(
                                  '我已阅读并同意',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 96,
                                child: AppButton(
                                  label: '《用户服务协议》',
                                  kind: AppButtonKind.text,
                                  size: AppButtonSize.medium,
                                  expanded: false,
                                  onPressed: () => openRoute(context, 'Terms'),
                                ),
                              ),
                              Flexible(
                                flex: 12,
                                child: Text(
                                  '和',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF52525B),
                                      Color(0xFFA8A8B3),
                                    ),
                                    lh: 18,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 72,
                                child: AppButton(
                                  label: '《隐私政策》',
                                  kind: AppButtonKind.text,
                                  size: AppButtonSize.medium,
                                  expanded: false,
                                  onPressed: () =>
                                      openRoute(context, 'Privacy'),
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
                        gap: 16,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        style: hts(
                          13,
                          dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                        ),
                        children: [
                          TextSpan(
                            text: '已有账号？',
                            style: hts(
                              13,
                              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
                            ),
                          ),
                          TextSpan(
                            text: '去登录',
                            style: hts(
                              13,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
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
                        label: '下一步',
                        kind: AppButtonKind.primary,
                        size: AppButtonSize.large,
                        expanded: true,
                        onPressed: onContinue,
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
