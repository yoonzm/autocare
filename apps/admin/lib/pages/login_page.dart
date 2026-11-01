import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController(text: 'ops@chiguang.example');
  final pw = TextEditingController();
  bool show = false;
  String? error;

  @override
  void dispose() {
    email.dispose();
    pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final err = store.checkCredentials(email.text, pw.text);
    setState(() => error = err);
    if (err != null) return;
    final ok = await showSheet<bool>(context, (c) => const _CodeSheet());
    if (ok != true || !mounted) return;
    store.signIn(email.text);
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const ShellPage()));
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DarkHero(
              radius: const BorderRadius.vertical(bottom: Radius.circular(40)),
              padding: EdgeInsets.fromLTRB(20, top + 56, 20, 44),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFBE7B0), Color(0xFFE6B85C)],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x59F5D78E),
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bar_chart_rounded,
                      size: 34,
                      color: C.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '汽美管家 · 运营后台',
                    style: ts(
                      22,
                      w: FontWeight.w600,
                      color: const Color(0xFFFAFAFA),
                      h: 30,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '商家、订阅与收入，一个 App 管理',
                    style: ts(13, color: C.faint, h: 19),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: HCard(
                child: Column(
                  children: [
                    Field(
                      label: '工作邮箱',
                      required: true,
                      controller: email,
                      hint: 'name@company.example',
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    Field(
                      label: '密码',
                      required: true,
                      controller: pw,
                      hint: '请输入密码',
                      obscure: !show,
                      error: error,
                      onSubmitted: (_) => _submit(),
                      suffix: GestureDetector(
                        onTap: () => setState(() => show = !show),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            show
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                            color: C.muted,
                            semanticLabel: show ? '隐藏密码' : '显示密码',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const SoftTile(Icons.lock_outline, C.greenInk, C.greenSoft, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '仅限平台运营人员登录，登录将进行二次验证',
                            style: ts(12, color: C.muted, h: 17),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: C.primarySoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '演示账号：ops@chiguang.example（运营）、wang@chiguang.example（超级管理员），密码 ${Store.demoPassword}',
                        style: ts(11, color: C.primaryInk, h: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .94),
          border: const Border(top: BorderSide(color: C.stroke)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Btn('登录', onTap: _submit),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => toast(context, '请联系超级管理员重置密码'),
              child: Text('忘记密码请联系超级管理员', style: ts(11, color: C.faint, h: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 二次验证：输入 6 位短信验证码。
class _CodeSheet extends StatefulWidget {
  const _CodeSheet();
  @override
  State<_CodeSheet> createState() => _CodeSheetState();
}

class _CodeSheetState extends State<_CodeSheet> {
  final ctrl = TextEditingController();
  String? error;
  int resent = 0;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void _verify() {
    if (ctrl.text == Store.demoCode) {
      Navigator.pop(context, true);
    } else {
      setState(() => error = ctrl.text.length < 6 ? '请输入 6 位验证码' : '验证码错误，请重试');
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('二次验证', style: ts(20, w: FontWeight.w600, h: 28)),
      const SizedBox(height: 2),
      Text(
        '验证码已发送至绑定手机 ${resent > 0 ? '（已重发 $resent 次）' : ''}· 演示验证码 ${Store.demoCode}',
        style: ts(12, color: C.muted, h: 17),
      ),
      const SizedBox(height: 14),
      Field(
        label: '短信验证码',
        required: true,
        controller: ctrl,
        hint: '6 位数字',
        keyboard: TextInputType.number,
        formatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        error: error,
        onSubmitted: (_) => _verify(),
        suffix: GestureDetector(
          onTap: () => setState(() => resent++),
          child: Text('重新发送', style: ts(13, w: FontWeight.w500, color: C.primary)),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            flex: 5,
            child: Btn('取消', ghost: true, onTap: () => Navigator.pop(context)),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 7, child: Btn('验证并登录', onTap: _verify)),
        ],
      ),
    ],
  );
}
