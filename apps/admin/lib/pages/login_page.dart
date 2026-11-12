import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'shell_page.dart';

class LoginPage extends StatefulWidget {
  final bool resuming;
  final String? previousUser;
  const LoginPage({super.key, this.resuming = false, this.previousUser});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final user = TextEditingController();
  final pw = TextEditingController();
  String? error;
  bool submitting = false;

  @override
  void dispose() {
    user.dispose();
    pw.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (submitting) return;
    FocusScope.of(context).unfocus();
    setState(() => submitting = true);
    final err = await store.checkCredentials(user.text, pw.text);
    if (!mounted) return;
    setState(() {
      error = err;
      submitting = false;
    });
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
    if (widget.resuming && store.me?.id == widget.previousUser) {
      await store.refresh();
      if (mounted) Navigator.pop(context, true);
    } else if (widget.resuming) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ShellPage()),
        (_) => false,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ShellPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return PopScope(
      canPop: !widget.resuming,
      child: Scaffold(
        backgroundColor: C.bg,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              AppHeroCard.custom(padding: EdgeInsets.fromLTRB(20, top + 56, 20, 44), child: Column(
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
                )),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: AppCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: '用户名',
                        required: true,
                        controller: user,
                        hint: '请输入用户名',
                        onChanged: (_) => setState(() => error = null),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: '密码',
                        required: true,
                        controller: pw,
                        hint: '请输入密码',
                        obscure: true,
                        errorText: error,
                        onChanged: (_) => setState(() => error = null),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          AppIconTile(icon: Icons.lock_outline, tone: Tone.ok),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '仅限平台运营人员登录',
                              style: ts(12, color: C.muted, h: 17),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomBar(
          primary: AppButton(label: '登录', loading: submitting, onPressed: _submit),
        ),
      ),
    );
  }
}

/// 首次登录 / 密码被重置后的强制改密页，不可返回。
class ChangePasswordPage extends StatefulWidget {
  final String username;
  final bool restoring;
  const ChangePasswordPage({
    super.key,
    required this.username,
    this.restoring = false,
  });
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final next = TextEditingController();
  final again = TextEditingController();
  String? error;
  bool saving = false;

  @override
  void dispose() {
    next.dispose();
    again.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (saving) return;
    final a = store.me!;
    setState(() => saving = true);
    final err = await store.changePassword(a, next.text, again.text);
    if (!mounted) return;
    setState(() {
      error = err;
      saving = false;
    });
    if (err != null) return;
    toast(context, '密码已修改');
    if (widget.restoring) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ShellPage()));
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: AdPage(
      title: '修改密码',
      back: false,
      bottomBar: AppBottomBar(
        primary: AppButton(label: '确认修改', loading: saving, onPressed: _save),
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconTile(icon: Icons.lock_outline, tone: Tone.warn),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '当前密码为初始或临时密码，请先设置新密码后再进入后台。',
                style: ts(13, color: C.sub, h: 19),
              ),
            ),
          ],
        ),
        AppCard(
          child: Column(
            children: [
              AppTextField(
                label: '新密码',
                required: true,
                controller: next,
                hint: '至少 8 位',
                obscure: true,
                onChanged: (_) => setState(() => error = null),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: '确认新密码',
                required: true,
                controller: again,
                hint: '再次输入新密码',
                obscure: true,
                errorText: error,
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
