import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'accounts_pages.dart';
import 'login_page.dart';
import 'plans_pages.dart';
import 'reviews_pages.dart';
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
    );
    if (!ok || !context.mounted) return;
    store.signOut();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final me = store.me;
      if (me == null) return const SizedBox();
      return AdPage(
        title: '我的',
        back: false,
        children: [
          HCard(
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF7CC0FF), Color(0xFF0485F7)],
                    ),
                  ),
                  child: Text(
                    me.name.characters.first == '运' ? me.name.characters.last : me.name.characters.first,
                    style: ts(22, w: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(me.name, style: ts(17, w: FontWeight.w600, h: 24)),
                      const SizedBox(height: 2),
                      Pill(
                        me.role == Role.superAdmin ? '超级管理员' : '平台运营',
                        me.role == Role.superAdmin ? C.amberInk : C.primaryInk,
                        me.role == Role.superAdmin ? C.amberSoft : C.primarySoft,
                      ),
                      const SizedBox(height: 2),
                      Text(me.email, style: ts(12, color: C.muted, h: 17)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          RowGroup([
            Row1(
              leading: const SoftTile(Icons.workspace_premium_outlined, C.violetInk, C.violetSoft),
              title: '套餐管理',
              trailing: Text('${store.plans.length} 个套餐', style: ts(13, color: C.muted)),
              onTap: () => go(context, const PlansPage()),
            ),
            Row1(
              leading: const SoftTile(Icons.chat_bubble_outline_rounded, C.primaryInk, C.primarySoft),
              title: '工单',
              trailing: store.todoTickets > 0
                  ? Text('${store.todoTickets} 待处理', style: ts(13, color: C.muted))
                  : null,
              onTap: () => go(context, const TicketsPage()),
            ),
            Row1(
              leading: const SoftTile(Icons.verified_outlined, C.amberInk, C.amberSoft),
              title: '开通审核',
              trailing: store.pendingReviews > 0
                  ? Text('${store.pendingReviews} 待审核', style: ts(13, color: C.muted))
                  : null,
              onTap: () => go(context, const ReviewsPage()),
            ),
            Row1(
              leading: const SoftTile(Icons.group_outlined, C.greenInk, C.greenSoft),
              title: '运营账号',
              sub: '${store.accounts.length} 人 · 仅超级管理员可见',
              onTap: () {
                if (!store.isSuper) {
                  toast(context, '仅超级管理员可管理运营账号');
                  return;
                }
                go(context, const AccountsPage());
              },
            ),
          ]),
          HCard(
            padding: EdgeInsets.zero,
            onTap: () => _logout(context),
            child: Row1(
              leading: const SoftTile(Icons.logout_rounded, C.redInk, C.redSoft),
              title: '退出登录',
              minHeight: 64,
            ),
          ),
        ],
      );
    },
  );
}
