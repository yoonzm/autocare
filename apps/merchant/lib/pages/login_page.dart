import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../backend/store_profile.dart';
import '../kit/keyboard.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'shell.dart';

class LoginPage extends StatefulWidget {
  /// 0 = 验证码登录，1 = 密码登录（设计稿的 LoginPwd）。
  final int initialTab;
  const LoginPage({super.key, this.initialTab = 0});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late int tab = widget.initialTab;
  bool agree = true;

  /// 密码是否明文显示（密码框右侧的小眼睛）。
  bool showPwd = false;
  final phone = TextEditingController();
  final code = TextEditingController();
  final pwd = TextEditingController();
  int countdown = 0;

  /// 获取验证码请求中（按钮显示“发送中…”）/ 登录请求中（表单只读、按钮 loading）。
  bool sending = false;
  bool busy = false;

  /// 字段下方的错误提示；输入后清除。
  String? phoneErr, codeErr, pwdErr;
  final _phoneKey = GlobalKey();
  final _codeKey = GlobalKey();
  final _pwdKey = GlobalKey();
  late final TapGestureRecognizer _terms = TapGestureRecognizer()
    ..onTap = () => openRoute(context, 'Terms');
  late final TapGestureRecognizer _privacy = TapGestureRecognizer()
    ..onTap = () => openRoute(context, 'Privacy');
  Timer? _timer;

  @override
  void dispose() {
    _terms.dispose();
    _privacy.dispose();
    _timer?.cancel();
    super.dispose();
  }

  static final _phoneRe = RegExp(r'^1[3-9]\d{9}$');

  String? _phoneError() {
    final v = phone.text.trim();
    if (v.isEmpty) return '请输入手机号';
    if (!_phoneRe.hasMatch(v)) return '请输入正确的 11 位手机号';
    return null;
  }

  /// 滚动到第一个出错的字段。
  void _focusFirstError() {
    final key = phoneErr != null
        ? _phoneKey
        : codeErr != null
        ? _codeKey
        : pwdErr != null
        ? _pwdKey
        : null;
    final ctx = key?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 200),
        alignment: 0.3,
      );
    }
  }

  Future<void> sendCode() async {
    if (countdown > 0 || sending || busy) return;
    final problem = _phoneError();
    if (problem != null) {
      setState(() => phoneErr = problem);
      _focusFirstError();
      return;
    }
    setState(() => sending = true);
    try {
      // 加载指示至少停留 500ms，避免一闪而过
      await Future.wait<void>([
        merchantApi.sendCode(phone.text.trim(), purpose: 'login'),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
      if (!mounted) return;
      AppToast.show(context, '验证码已发送，请查看短信');
    } catch (e) {
      // 失败立即恢复可点
      if (mounted) {
        setState(() => sending = false);
        AppToast.error(context, e);
      }
      return;
    }
    setState(() {
      sending = false;
      countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => countdown--);
      if (countdown <= 0) t.cancel();
    });
  }

  Future<void> login() async {
    if (busy) return;
    // 先校验，错误显示在字段下方并滚动到第一个错误
    final p = _phoneError();
    String? c, w;
    if (tab == 0) {
      final v = code.text.trim();
      if (v.isEmpty) {
        c = '请输入验证码';
      } else if (!RegExp(r'^\d{6}$').hasMatch(v)) {
        c = '验证码为 6 位数字';
      }
    } else if (pwd.text.isEmpty) {
      w = '请输入密码';
    }
    if (p != null || c != null || w != null) {
      setState(() {
        phoneErr = p;
        codeErr = c;
        pwdErr = w;
      });
      _focusFirstError();
      return;
    }
    if (!agree) {
      AppToast.show(context, '请先勾选用户协议和隐私政策', kind: ToastKind.error);
      return;
    }
    // 提交中：整个表单只读，按钮 loading（至少停留 500ms）
    setState(() => busy = true);
    try {
      await Future.wait([
        () async {
          if (tab == 0) {
            await merchantApi.loginCode(phone.text.trim(), code.text.trim());
          } else {
            await merchantApi.loginPassword(phone.text.trim(), pwd.text);
          }
          await storeProfile.load();
        }(),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
    } catch (e) {
      // 失败后恢复可点，输入内容保留
      if (mounted) {
        setState(() => busy = false);
        AppToast.show(context, AppError.from(e).message, kind: ToastKind.error);
      }
      return;
    }
    if (!mounted) return;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => const Shell()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Column(
            children: [
              _brand(context),
              Transform.translate(offset: const Offset(0, -48), child: _form()),
              Transform.translate(
                offset: const Offset(0, -48),
                child: _others(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brand(BuildContext context) => Container(
    width: double.infinity,
    height: 330,
    clipBehavior: Clip.antiAlias,
    padding: EdgeInsets.fromLTRB(
      28,
      MediaQuery.of(context).padding.top + 40,
      28,
      0,
    ),
    decoration: BoxDecoration(
      color: C.heroCard,
      border: C.heroBorder,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
    ),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // 设计稿：right -150 / top -60（相对整个区块），这里的 Stack 在内边距之内，要减掉内边距
        Positioned(
          right: -178,
          top: -60 - (MediaQuery.of(context).padding.top + 40),
          child: const Rings(
            size: 360,
            viewBox: 360,
            radii: [80, 120, 160],
            dot: (Offset(180, 100), 5, Color(0xFF0485F7)),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: C.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: AppIcon('car', color: Colors.white, size: 30),
            ),
            const SizedBox(height: 20),
            Text(
              '汽美管家',
              style: ts(
                28,
                w: FontWeight.w600,
                color: const Color(0xFFFAFAFA),
                h: 36,
              ),
            ),
            const SizedBox(height: 6),
            Text('会员、库存、营业数据，一部手机管好门店', style: ts(14, color: C.faint, h: 20)),
          ],
        ),
      ],
    ),
  );

  Widget _field(String label, Widget child, {String? error, Key? fieldKey}) =>
      Column(
        key: fieldKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: ts(13, w: FontWeight.w500, h: 18)),
          const SizedBox(height: 6),
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 14, right: 6),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: C.inset,
              borderRadius: BorderRadius.circular(14),
              border: error != null
                  ? Border.all(color: C.red, width: 1.2)
                  : null,
            ),
            child: child,
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Text(error, style: ts(12, color: C.redInk, h: 17)),
            ),
        ],
      );

  InputDecoration _dec(String hint) => InputDecoration(
    border: InputBorder.none,
    hintText: hint,
    hintStyle: ts(15, color: C.muted),
    isCollapsed: true,
  );

  Widget _form() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(28),
      boxShadow: C.dark
          ? softShadow
          : const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (final e in ['验证码登录', '密码登录'].asMap().entries) ...[
              GestureDetector(
                onTap: () => setState(() => tab = e.key),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: tab == e.key ? C.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    e.value,
                    style: ts(
                      16,
                      w: tab == e.key ? FontWeight.w600 : FontWeight.w500,
                      color: tab == e.key ? C.ink : C.muted,
                      h: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _field(
          '手机号',
          Row(
            children: [
              Text('+86', style: ts(15, w: FontWeight.w500)),
              Container(
                width: 1,
                height: 18,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                color: C.stroke,
              ),
              Expanded(
                child: TextField(
                  onTapOutside: onTapOutsideDismiss,
                  controller: phone,
                  readOnly: busy,
                  onChanged: (_) {
                    if (phoneErr != null) setState(() => phoneErr = null);
                  },
                  keyboardType: TextInputType.phone,
                  style: ts(15),
                  decoration: _dec('请输入手机号'),
                ),
              ),
            ],
          ),
          error: phoneErr,
          fieldKey: _phoneKey,
        ),
        const SizedBox(height: 16),
        if (tab == 0)
          _field(
            '验证码',
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onTapOutside: onTapOutsideDismiss,
                    controller: code,
                    readOnly: busy,
                    onChanged: (_) {
                      if (codeErr != null) setState(() => codeErr = null);
                    },
                    keyboardType: TextInputType.number,
                    style: ts(15),
                    decoration: _dec('6 位数字'),
                  ),
                ),
                GestureDetector(
                  onTap: sendCode,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: softShadow,
                    ),
                    child: sending
                        // 设计稿的验证码按钮加载态：转圈 + “发送中…”
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AppSpinner(size: 16, color: C.muted),
                              const SizedBox(width: 6),
                              Text(
                                '发送中…',
                                style: ts(
                                  13,
                                  w: FontWeight.w500,
                                  color: C.muted,
                                  h: 18,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            countdown > 0 ? '$countdown 秒后重发' : '获取验证码',
                            style: ts(
                              13,
                              w: FontWeight.w500,
                              color: countdown > 0 ? C.muted : C.primaryInk,
                              h: 18,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            error: codeErr,
            fieldKey: _codeKey,
          )
        else
          _field(
            '密码',
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onTapOutside: onTapOutsideDismiss,
                    controller: pwd,
                    readOnly: busy,
                    onChanged: (_) {
                      if (pwdErr != null) setState(() => pwdErr = null);
                    },
                    obscureText: !showPwd,
                    style: ts(15),
                    decoration: _dec('请输入登录密码'),
                  ),
                ),
                Semantics(
                  button: true,
                  label: showPwd ? '隐藏密码' : '显示密码',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => showPwd = !showPwd),
                    child: SizedBox(
                      width: 40,
                      height: 44,
                      child: Icon(
                        showPwd
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: C.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            error: pwdErr,
            fieldKey: _pwdKey,
          ),
        if (tab == 1) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Semantics(
              button: true,
              label: '忘记密码',
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: busy ? null : () => openRoute(context, 'ForgotVerify'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '忘记密码？',
                    style: ts(
                      13,
                      w: FontWeight.w500,
                      color: C.primaryInk,
                      h: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            '登录',
            onTap: login,
            loading: busy,
            loadingText: '登录中…',
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => setState(() => agree = !agree),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: agree ? C.primary : C.card,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: agree ? C.primary : C.faint,
                    width: 1.5,
                  ),
                ),
                child: agree
                    ? const AppIcon(
                        'check',
                        size: 12,
                        color: Colors.white,
                        stroke: 3,
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: ts(12, color: C.sub, h: 18),
                    children: [
                      const TextSpan(text: '我已阅读并同意 '),
                      TextSpan(
                        text: '《用户协议》',
                        style: ts(12, w: FontWeight.w500, color: C.primaryInk),
                        recognizer: _terms,
                      ),
                      const TextSpan(text: '和'),
                      TextSpan(
                        text: '《隐私政策》',
                        style: ts(12, w: FontWeight.w500, color: C.primaryInk),
                        recognizer: _privacy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _others() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            const Expanded(child: Divider1()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('其他方式', style: ts(12, color: C.muted, h: 16)),
            ),
            const Expanded(child: Divider1()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _circle('chat', C.green, '微信登录'),
            const SizedBox(width: 24),
            _circle('phoneDevice', C.ink, '本机号码一键登录'),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => openRoute(context, 'RegPhone'),
          child: Text.rich(
            TextSpan(
              style: ts(12, color: C.muted, h: 16),
              children: [
                const TextSpan(text: '还没有门店账号？'),
                TextSpan(
                  text: '免费开通',
                  style: ts(12, w: FontWeight.w500, color: C.primaryInk),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    ),
  );

  Widget _circle(String i, Color c, String label) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      // TODO: WeChat/one-tap login need provider credentials and backend functions.
      onTap: () => toast(context, '$label 暂未接通'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: C.card,
          shape: BoxShape.circle,
          boxShadow: softShadow,
        ),
        child: AppIcon(i, color: c, size: 24),
      ),
    ),
  );
}
