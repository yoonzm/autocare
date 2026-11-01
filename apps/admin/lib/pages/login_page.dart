import 'package:flutter/material.dart';

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
  final user = TextEditingController(text: 'ops_xiaoli');
  final pw = TextEditingController();
  String? error;

  @override
  void dispose() {
    user.dispose();
    pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final err = store.checkCredentials(user.text, pw.text);
    setState(() => error = err);
    if (err != null) return;
    if (store.needsPasswordChange(user.text)) {
      // 首次登录或密码被重置：必须先改密
      final done = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => ChangePasswordPage(username: user.text),
        ),
      );
      if (done != true || !mounted) return;
      pw.clear();
    }
    store.signIn(user.text);
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
                    child: Icon(
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
                      label: '用户名',
                      required: true,
                      controller: user,
                      hint: '请输入用户名',
                      onChanged: (_) => setState(() => error = null),
                    ),
                    const SizedBox(height: 14),
                    Field(
                      label: '密码',
                      required: true,
                      controller: pw,
                      hint: '请输入密码',
                      obscure: true,
                      error: error,
                      onChanged: (_) => setState(() => error = null),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        SoftTile(Icons.lock_outline, C.greenInk, C.greenSoft, size: 32),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '仅限平台运营人员登录',
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
                        '演示账号：ops_xiaoli（运营）、wang_admin（超级管理员），密码 ${Store.demoPassword}',
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
          color: C.card.withValues(alpha: .94),
          border: Border(top: BorderSide(color: C.stroke)),
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

/// 首次登录 / 密码被重置后的强制改密页，不可返回。
class ChangePasswordPage extends StatefulWidget {
  final String username;
  const ChangePasswordPage({super.key, required this.username});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final next = TextEditingController();
  final again = TextEditingController();
  String? error;

  @override
  void dispose() {
    next.dispose();
    again.dispose();
    super.dispose();
  }

  void _save() {
    final a = store.accounts.firstWhere((a) => a.username == widget.username.trim().toLowerCase());
    final err = store.changePassword(a, next.text, again.text);
    setState(() => error = err);
    if (err != null) return;
    toast(context, '密码已修改');
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: AdPage(
      title: '修改密码',
      back: false,
      dock: Btn('确认修改', onTap: _save),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SoftTile(Icons.lock_outline, C.amberInk, C.amberSoft, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '当前密码为初始或临时密码，请先设置新密码后再进入后台。',
                style: ts(13, color: C.sub, h: 19),
              ),
            ),
          ],
        ),
        HCard(
          child: Column(
            children: [
              Field(
                label: '新密码',
                required: true,
                controller: next,
                hint: '至少 8 位',
                obscure: true,
                onChanged: (_) => setState(() => error = null),
              ),
              const SizedBox(height: 14),
              Field(
                label: '确认新密码',
                required: true,
                controller: again,
                hint: '再次输入新密码',
                obscure: true,
                error: error,
                onChanged: (_) => setState(() => error = null),
                onSubmitted: (_) => _save(),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
