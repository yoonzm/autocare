import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../kit/keyboard.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int tab = 0;
  bool agree = true;
  final phone = TextEditingController(text: '13988888812');
  final code = TextEditingController();
  final pwd = TextEditingController();
  int countdown = 0;
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

  void sendCode() {
    if (countdown > 0) return;
    if (phone.text.trim().length < 11) {
      toast(context, '请输入正确的手机号');
      return;
    }
    toast(context, '验证码已发送（演示）');
    setState(() => countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => countdown--);
      if (countdown <= 0) t.cancel();
    });
  }

  void login() {
    if (!agree) {
      toast(context, '请先勾选用户协议和隐私政策');
      return;
    }
    if (phone.text.trim().length < 11) {
      toast(context, '请输入正确的手机号');
      return;
    }
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
        const Positioned(right: -178, top: -100, child: Rings(size: 360)),
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

  Widget _field(String label, Widget child) => Column(
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
        ),
        child: child,
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
                  keyboardType: TextInputType.phone,
                  style: ts(15),
                  decoration: _dec('请输入手机号'),
                ),
              ),
            ],
          ),
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
                    child: Text(
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
          )
        else
          _field(
            '密码',
            TextField(
              onTapOutside: onTapOutsideDismiss,
              controller: pwd,
              obscureText: true,
              style: ts(15),
              decoration: _dec('请输入密码'),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton('登录', onTap: login),
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
      onTap: login,
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
