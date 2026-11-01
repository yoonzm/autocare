import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../backend/merchant_backend.dart';
import '../theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final storeName = TextEditingController();
  bool register = false;
  bool busy = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    storeName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final mail = email.text.trim();
    if (!mail.contains('@') ||
        password.text.length < 6 ||
        (register && storeName.text.trim().isEmpty)) {
      setState(
        () => message = register ? '请填写有效邮箱、至少 6 位密码和门店名称' : '请填写有效邮箱和至少 6 位密码',
      );
      return;
    }
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (register) {
        final result = await MerchantBackend.client.auth.signUp(
          email: mail,
          password: password.text,
          data: {'store_name': storeName.text.trim()},
        );
        if (mounted && result.session == null) {
          setState(() => message = '注册成功，请查收验证邮件；验证后返回登录。');
        }
      } else {
        await MerchantBackend.client.auth.signInWithPassword(
          email: mail,
          password: password.text,
        );
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => message = e.message);
    } catch (_) {
      if (mounted) setState(() => message = '连接失败，请检查网络后重试');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.directions_car_rounded, size: 54, color: C.primary),
                const SizedBox(height: 18),
                Text(
                  '汽美管家',
                  textAlign: TextAlign.center,
                  style: ts(28, w: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  register ? '创建你的门店账号' : '登录商户端',
                  textAlign: TextAlign.center,
                  style: ts(14, color: C.muted),
                ),
                const SizedBox(height: 32),
                if (register) ...[
                  TextField(
                    controller: storeName,
                    decoration: const InputDecoration(labelText: '门店名称'),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: '邮箱'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  autofillHints: [
                    register
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  decoration: const InputDecoration(labelText: '密码（至少 6 位）'),
                ),
                if (message != null) ...[
                  const SizedBox(height: 14),
                  Text(message!, style: ts(13, color: C.primaryInk)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: busy ? null : submit,
                  child: Text(
                    busy
                        ? '请稍候…'
                        : register
                        ? '注册'
                        : '登录',
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () => setState(() {
                          register = !register;
                          message = null;
                        }),
                  child: Text(register ? '已有账号？去登录' : '还没有账号？注册门店'),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前使用邮箱密码认证；短信登录暂未开通。',
                  textAlign: TextAlign.center,
                  style: ts(12, color: C.muted),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
