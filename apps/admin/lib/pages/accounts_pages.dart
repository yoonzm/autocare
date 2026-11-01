import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

const _avatar = [
  [Color(0xFFFBE7B0), Color(0xFFE6B85C)],
  [Color(0xFF7CC0FF), Color(0xFF0485F7)],
  [Color(0xFF59D49A), Color(0xFF17A864)],
];

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  Future<void> _act(BuildContext context, Account a) async {
    final isMe = identical(a, store.me);
    final i = await pickOption(
      context,
      title: '管理账号 · ${a.name}',
      subtitle: '用户名 ${a.username} · ${a.role.label}',
      options: [
        const SheetOption('重置密码', '设为临时密码，原密码立即失效，首次登录需修改'),
        a.role == Role.ops
            ? const SheetOption('设为超级管理员', '获得账号管理、退款与套餐定价权限')
            : const SheetOption('降为运营', '失去账号管理、退款与套餐定价权限'),
        a.enabled
            ? const SheetOption('禁用账号', '立即退出所有设备，无法再登录，可随时恢复', danger: true)
            : const SheetOption('启用账号', '恢复登录权限'),
      ],
      footnote: '以上操作都会记录操作人和时间。',
    );
    if (i == null || !context.mounted) return;
    switch (i) {
      case 0:
        final tmp = store.resetPassword(a);
        await showDialog<void>(
          context: context,
          builder: (c) => Dialog(
            backgroundColor: C.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 32),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('临时密码已生成', style: ts(18, w: FontWeight.w600, h: 26)),
                  const SizedBox(height: 8),
                  Text(
                    '${a.name} 的原密码已失效，请通过安全渠道告知本人，首次登录需修改。',
                    style: ts(14, color: C.sub, h: 21),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.inset,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: SelectableText(
                      tmp,
                      style: ts(20, w: FontWeight.w600, h: 28),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Btn('关闭', ghost: true, onTap: () => Navigator.pop(c)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 7,
                        child: Btn(
                          '复制密码',
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: tmp));
                            Navigator.pop(c);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        if (context.mounted) toast(context, '已重置，下次登录需修改密码');
      case 1:
        final target = a.role == Role.ops ? Role.superAdmin : Role.ops;
        if (target == Role.ops &&
            store.accounts.where((x) => x.role == Role.superAdmin && x.enabled).length <= 1) {
          toast(context, '至少需要保留一名超级管理员');
          return;
        }
        store.setRole(a, target);
        toast(context, '已设为${target.label}');
        if (isMe && target == Role.ops) {
          toast(context, '你已降为运营，部分功能将不可用');
        }
      default:
        if (isMe && a.enabled) {
          toast(context, '不能禁用自己的账号');
          return;
        }
        store.setEnabled(a, !a.enabled);
        toast(context, a.enabled ? '账号已启用' : '账号已禁用');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => AdPage(
      title: '运营账号',
      action: CircleBtn(
        key: const ValueKey('add-account'),
        Icons.add_rounded,
        () => go(context, const AccountEditPage()),
        primary: true,
        label: '新增账号',
      ),
      children: [
        Text('共 ${store.accounts.length} 人 · 仅超级管理员可管理', style: ts(13, color: C.sub, h: 18)),
        for (final (i, a) in store.accounts.indexed)
          HCard(
            onTap: () => _act(context, a),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: a.enabled ? null : C.stroke,
                    gradient: a.enabled
                        ? LinearGradient(colors: _avatar[i % _avatar.length])
                        : null,
                  ),
                  child: Text(
                    a.name.characters.first == '运' ? a.name.characters.last : a.name.characters.first,
                    style: ts(18, w: FontWeight.w600, color: a.enabled ? (i % 3 == 0 ? C.ink : Colors.white) : C.sub),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              identical(a, store.me) ? '${a.name}（我）' : a.name,
                              overflow: TextOverflow.ellipsis,
                              style: ts(15, w: FontWeight.w600, color: a.enabled ? C.ink : C.muted, h: 22),
                            ),
                          ),
                          const SizedBox(width: 8),
                          a.role == Role.superAdmin
                              ? Pill('超级管理员', C.amberInk, C.amberSoft)
                              : Pill('运营', C.primaryInk, C.primarySoft),
                        ],
                      ),
                      Text(a.username, style: ts(12, color: C.muted, h: 17)),
                    ],
                  ),
                ),
                a.enabled
                    ? Pill('启用', C.greenInk, C.greenSoft)
                    : Pill('已禁用', C.redInk, C.redSoft),
              ],
            ),
          ),
        Section(
          '角色说明',
          RowGroup(indent: 16, [
            _role('超级管理员', C.amberInk, C.amberSoft, '全部功能，含运营账号管理、退款与套餐定价'),
            _role('运营', C.primaryInk, C.primarySoft, '商家、订阅、开通审核、工单与到期跟进，不含账号管理'),
          ]),
        ),
      ],
    ),
  );

  Widget _role(String n, Color fg, Color bg, String d) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Pill(n, fg, bg),
        const SizedBox(width: 12),
        Expanded(child: Text(d, style: ts(12, color: C.sub, h: 18))),
      ],
    ),
  );
}

class AccountEditPage extends StatefulWidget {
  const AccountEditPage({super.key});
  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final name = TextEditingController();
  final user = TextEditingController();
  final pwd = TextEditingController();
  Role role = Role.ops;
  String? error;

  @override
  void dispose() {
    name.dispose();
    user.dispose();
    pwd.dispose();
    super.dispose();
  }

  void _create() {
    final err = store.addAccount(name.text, user.text, pwd.text, role);
    setState(() => error = err);
    if (err != null) return;
    toast(context, '账号已创建，首次登录需修改初始密码');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '新增运营账号',
    dock: Btn('创建账号', onTap: _create),
    children: [
      HCard(
        child: Column(
          children: [
            Field(
              label: '姓名',
              required: true,
              controller: name,
              hint: '例如 陈运营',
              error: error != null && error!.contains('姓名') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
            const SizedBox(height: 14),
            Field(
              label: '用户名',
              required: true,
              controller: user,
              hint: '字母、数字或下划线，4–20 位',
              error: error != null && error!.contains('用户名') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
            const SizedBox(height: 14),
            Field(
              label: '初始密码',
              required: true,
              controller: pwd,
              hint: '至少 8 位',
              obscure: true,
              error: error != null && error!.contains('密码') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
          ],
        ),
      ),
      Section(
        '角色',
        Column(
          children: [
            for (final (r, d) in [
              (Role.ops, '商家、订阅、审核、工单与到期跟进'),
              (Role.superAdmin, '全部功能，含账号管理、退款与套餐定价'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => setState(() => role = r),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: role == r ? C.primarySoft : C.card,
                      borderRadius: BorderRadius.circular(18),
                      border: role == r ? Border.all(color: C.primary, width: 1.5) : null,
                      boxShadow: role == r ? null : softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.label, style: ts(15, w: FontWeight.w600, h: 22)),
                        Text(d, style: ts(12, color: role == r ? C.sub : C.muted, h: 16)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SoftTile(Icons.lock_outline, C.greenInk, C.greenSoft, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '首次登录需修改初始密码，请通过安全渠道告知本人。',
                style: ts(12, color: C.sub, h: 17),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}
