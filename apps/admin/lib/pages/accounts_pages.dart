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
    await pickOption(
      context,
      onConfirm: (i) => _apply(context, a, i),
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
  }

  Future<void> _apply(BuildContext context, Account a, int i) async {
    final isMe = a.id == store.me?.id;
    switch (i) {
      case 0:
        final tmp = await store.resetPassword(a);
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (c) => Dialog(
            backgroundColor: C.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
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
                        child: AppButton(
                          label: '关闭',
                          kind: AppButtonKind.secondary,
                          expanded: true,
                          onPressed: () => Navigator.pop(c),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton(
                          label: '复制密码',
                          expanded: true,
                          onPressed: () {
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
            store.accounts
                    .where((x) => x.role == Role.superAdmin && x.enabled)
                    .length <=
                1) {
          toast(context, '至少需要保留一名超级管理员');
          return;
        }
        await store.setRole(a, target);
        if (!context.mounted) return;
        toast(context, '已设为${target.label}');
        if (isMe && target == Role.ops) {
          toast(context, '你已降为运营，部分功能将不可用');
        }
      default:
        if (isMe && a.enabled) {
          toast(context, '不能禁用自己的账号');
          return;
        }
        await store.setEnabled(a, !a.enabled);
        if (!context.mounted) return;
        toast(context, a.enabled ? '账号已禁用' : '账号已启用');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => AdPage(
      title: '运营账号',
      action: AppIconButton(
        key: const ValueKey('add-account'),
        icon: Icons.add_rounded,
        semanticLabel: '新增账号',
        kind: AppIconButtonKind.primary,
        onPressed: () => go(context, const AccountEditPage()),
      ),
      children: [
        Text(
          '共 ${store.accounts.length} 人 · 仅超级管理员可管理',
          style: ts(13, color: C.sub, h: 18),
        ),
        for (final (i, a) in store.accounts.indexed)
          AppCard(
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
                    a.name.characters.first == '运'
                        ? a.name.characters.last
                        : a.name.characters.first,
                    style: ts(
                      18,
                      w: FontWeight.w600,
                      color: a.enabled
                          ? (i % 3 == 0 ? C.ink : Colors.white)
                          : C.sub,
                    ),
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
                              a.id == store.me?.id ? '${a.name}（我）' : a.name,
                              overflow: TextOverflow.ellipsis,
                              style: ts(
                                15,
                                w: FontWeight.w600,
                                color: a.enabled ? C.ink : C.muted,
                                h: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          a.role == Role.superAdmin
                              ? AppStatusTag('超级管理员', tone: Tone.warn)
                              : AppStatusTag('运营', tone: Tone.wait),
                        ],
                      ),
                      Text(a.username, style: ts(12, color: C.muted, h: 17)),
                    ],
                  ),
                ),
                a.enabled
                    ? AppStatusTag('启用', tone: Tone.ok)
                    : AppStatusTag('已禁用', tone: Tone.bad),
              ],
            ),
          ),
        Section(
          '角色说明',
          AppListGroup(rows: [
            _role('超级管理员', Tone.warn, '全部功能，含运营账号管理、退款与套餐定价'),
            _role('运营', Tone.wait, '商家、订阅、开通审核、工单与到期跟进，不含账号管理'),
          ]),
        ),
      ],
    ),
  );

  Widget _role(String n, Tone tone, String d) => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppStatusTag(n, tone: tone),
        const SizedBox(width: 12),
        Expanded(
          child: Text(d, style: ts(12, color: C.sub, h: 18)),
        ),
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
  bool creating = false;

  @override
  void dispose() {
    name.dispose();
    user.dispose();
    pwd.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    setState(() => creating = true);
    final err = await store.addAccount(name.text, user.text, pwd.text, role);
    if (!mounted) return;
    setState(() {
      error = err;
      creating = false;
    });
    if (err != null) {
      if (!['姓名', '用户名', '密码'].any(err.contains)) {
        AppToast.error(context, AppError(err));
      }
      return;
    }
    toast(context, '账号已创建，首次登录需修改初始密码');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '新增运营账号',
    bottomBar: AppBottomBar(
      primary: AppButton(label: '创建账号', loading: creating, onPressed: _create),
    ),
    children: [
      AppCard(
        child: Column(
          children: [
            AppTextField(
              label: '姓名',
              required: true,
              controller: name,
              hint: '例如 陈运营',
              errorText: error != null && error!.contains('姓名') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: '用户名',
              required: true,
              controller: user,
              hint: '字母、数字或下划线，4–20 位',
              errorText: error != null && error!.contains('用户名') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: '初始密码',
              required: true,
              controller: pwd,
              hint: '至少 8 位',
              obscure: true,
              errorText: error != null && error!.contains('密码') ? error : null,
              onChanged: (_) => setState(() => error = null),
            ),
          ],
        ),
      ),
      Section(
        '角色',
        AppCard(
          child: AppChoiceGroup<Role>(
            kind: ChipKind.option,
            expanded: true,
            selected: role,
            onChanged: (r) => setState(() => role = r),
            items: [
              ChoiceItem(value: Role.ops, label: Role.ops.label, subtitle: '商家、订阅、审核、工单与到期跟进'),
              ChoiceItem(value: Role.superAdmin, label: Role.superAdmin.label, subtitle: '全部功能，含账号管理、退款与套餐定价'),
            ],
          ),
        ),
      ),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: Icons.lock_outline, tone: Tone.ok),
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
