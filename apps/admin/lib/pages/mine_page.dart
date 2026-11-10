import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import '../data/theme_state.dart';
import 'accounts_pages.dart';
import 'login_page.dart';
import 'plans_pages.dart';
import 'sms_pages.dart';
import 'users_pages.dart';
import 'theme_sheet.dart';
import 'tickets_pages.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirm(
      context,
      title: '退出登录',
      message: '确定要退出当前账号吗？',
      ok: '退出登录',
      danger: true,
      onConfirm: store.signOut,
    );
    if (!ok || !context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([store, appThemeMode]),
    builder: (context, _) {
      final me = store.me;
      if (me == null) return const SizedBox();
      return AdPage(
        title: '我的',
        back: false,
        children: [
          DarkHero(
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment(-.5, -1),
                      end: Alignment(.5, 1),
                      colors: [Color(0xFFFBE7B0), Color(0xFFE6B85C)],
                    ),
                  ),
                  child: Text(
                    me.name.characters.first,
                    style: ts(
                      24,
                      w: FontWeight.w600,
                      color: const Color(0xFF18181B),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              me.name,
                              overflow: TextOverflow.ellipsis,
                              style: ts(
                                19,
                                w: FontWeight.w600,
                                color: const Color(0xFFFAFAFA),
                                h: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Pill(
                            me.role == Role.superAdmin ? '超级管理员' : '平台运营',
                            C.gold,
                            const Color(0x24FFFFFF),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        me.username,
                        style: ts(12, color: const Color(0xFFA1A1AA), h: 17),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          RowGroup([
            Row1(
              leading: SoftTile(
                Icons.workspace_premium_outlined,
                C.violetInk,
                C.violetSoft,
              ),
              title: '套餐管理',
              trailing: Text(
                '${store.plans.length} 个套餐',
                style: ts(13, color: C.muted),
              ),
              onTap: () => go(context, const PlansPage()),
            ),
            Row1(
              leading: SoftTile(
                Icons.chat_bubble_outline_rounded,
                C.primaryInk,
                C.primarySoft,
              ),
              title: '工单',
              trailing: store.todoTickets > 0
                  ? Text(
                      '${store.todoTickets} 待处理',
                      style: ts(13, color: C.muted),
                    )
                  : null,
              onTap: () => go(context, const TicketsPage()),
            ),
            Row1(
              leading: SoftTile(Icons.group_outlined, C.greenInk, C.greenSoft),
              title: '运营账号',
              sub:
                  '${store.isSuper ? store.accounts.length : '—'} 人 · 仅超级管理员可见',
              onTap: () {
                if (!store.isSuper) {
                  toast(context, '仅超级管理员可管理运营账号');
                  return;
                }
                go(context, const AccountsPage());
              },
            ),
            // 短信记录含验证码明文：只有超级管理员能看到入口（服务端同样限制）。
            if (store.isSuper)
              Row1(
                leading: SoftTile(
                  Icons.sms_outlined,
                  C.primaryInk,
                  C.primarySoft,
                ),
                title: '短信记录',
                sub: '验证码与通知 · 仅超级管理员可见',
                onTap: () => go(context, const SmsLogsPage()),
              ),
            if (store.isSuper)
              Row1(
                leading: SoftTile(
                  Icons.person_outline_rounded,
                  C.amberInk,
                  C.amberSoft,
                ),
                title: '用户账号',
                sub: store.userCooling != null && store.userCooling! > 0
                    ? '${store.userCooling} 个注销中 · 仅超级管理员可见'
                    : '老板与员工账号 · 仅超级管理员可见',
                onTap: () => go(context, const UsersPage()),
              ),
            Row1(
              leading: SoftTile(Icons.dark_mode_outlined, C.sub, C.chip),
              title: '外观',
              trailing: Text(
                themeModeLabel(appThemeMode.value),
                style: ts(13, color: C.muted),
              ),
              onTap: () => showThemeSheet(context),
            ),
          ]),
          HCard(
            padding: EdgeInsets.zero,
            onTap: () {
              unawaited(_logout(context));
            },
            child: Row1(
              leading: SoftTile(Icons.logout_rounded, C.redInk, C.redSoft),
              title: '退出登录',
              minHeight: 64,
            ),
          ),
        ],
      );
    },
  );
}
