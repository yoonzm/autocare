import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'follow_pages.dart';
import 'merchants_page.dart';

class MerchantDetailPage extends StatelessWidget {
  final Merchant m;
  const MerchantDetailPage(this.m, {super.key});

  Future<void> _adjust(BuildContext context) async {
    final pro = m.plan == PlanKind.pro;
    final i = await pickOption(
      context,
      title: '调整套餐',
      subtitle: m.name,
      options: [
        SheetOption(
          m.plan == PlanKind.trial ? '延长试用 7 天' : '延长 7 天',
          '赠送，用于跟进转化',
        ),
        SheetOption(
          pro ? '已是专业版' : '升级到专业版',
          pro ? '无需再升级' : '按差价补缴',
        ),
        SheetOption(m.paused ? '恢复服务' : '暂停服务', m.paused ? '商家端恢复正常使用' : '商家端将提示已暂停'),
      ],
    );
    if (i == null || !context.mounted) return;
    if (i == 1 && pro) {
      toast(context, '该商家已是专业版');
      return;
    }
    toast(context, store.adjust(m, i));
  }

  Future<void> _contact(BuildContext context) async {
    final ok = await confirm(
      context,
      title: '联系店主',
      message: '将通过平台外呼联系 ${m.maskedOwner}（${m.maskedPhone}），通话会被记录。',
      ok: '呼叫',
    );
    if (ok && context.mounted) {
      toast(context, '正在呼叫 ${m.maskedPhone}…（演示）');
    }
  }

  Future<void> _account(BuildContext context) async {
    final i = await pickOption(
      context,
      title: '账号处理',
      subtitle: '${m.name} · 店主 ${m.maskedOwner}',
      options: [
        SheetOption('重发登录验证码', '向店主手机 ${m.maskedPhone} 重新发送短信'),
        const SheetOption('重置登录状态', '退出所有设备，店主需重新登录'),
        SheetOption(
          m.frozen ? '解冻商家账号' : '冻结商家账号',
          m.frozen ? '恢复商家端登录与使用' : '商家端无法登录，数据保留，可随时解冻',
          danger: !m.frozen,
        ),
      ],
      footnote: '以上操作都会记录操作人和时间。',
    );
    if (i == null || !context.mounted) return;
    toast(context, store.account(m, i));
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final (fg, bg) = statusColors(m.status);
      return AdPage(
        title: '商家详情',
        children: [
          DarkHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ToneTile(m.tone, Icons.storefront_outlined, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: ts(17, w: FontWeight.w600, color: const Color(0xFFFAFAFA), h: 24),
                          ),
                          Text(
                            '店主 ${m.maskedOwner} · ${m.maskedPhone}',
                            style: ts(12, color: C.faint, h: 17),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Pill(m.status.label, fg, bg),
                    Pill(m.plan.label, C.sub, C.chip),
                    if (m.frozen) Pill('已冻结', C.redInk, C.redSoft),
                    if (m.paused) Pill('已暂停', C.amberInk, C.amberSoft),
                  ],
                ),
              ],
            ),
          ),
          HCard(
            child: Column(
              children: [
                Row(
                  children: [
                    _num('${m.staff}', '员工数'),
                    _num(money(m.members).substring(1), '会员数'),
                    _num(m.plan.label, '当前套餐'),
                  ],
                ),
                Divider(height: 24, color: C.line),
                KV('到期时间', dotted(m.expiry),
                    vColor: m.daysLeft < 0 ? C.redInk : null),
                KV('开通时间', dotted(m.opened)),
                KV('累计付费', money(m.paidTotal)),
                KV('本月订单', '${m.monthOrders} 单'),
              ],
            ),
          ),
          RowGroup([
            Row1(
              leading: SoftTile(Icons.tune_rounded, C.primaryInk, C.primarySoft),
              title: m.plan == PlanKind.trial ? '延长试用 / 调整套餐' : '延长期限 / 调整套餐',
              onTap: () => _adjust(context),
            ),
            Row1(
              leading: SoftTile(Icons.history_edu_outlined, C.amberInk, C.amberSoft),
              title: '跟进记录',
              trailing: Text('${m.logs.length} 条', style: ts(13, color: C.muted)),
              onTap: () => go(context, FollowLogPage(m)),
            ),
            Row1(
              leading: SoftTile(Icons.phone_outlined, C.greenInk, C.greenSoft),
              title: '联系店主',
              trailing: Text(m.maskedPhone, style: ts(13, color: C.muted)),
              onTap: () => _contact(context),
            ),
            Row1(
              leading: SoftTile(Icons.manage_accounts_outlined, C.redInk, C.redSoft),
              title: '账号处理',
              sub: '重发验证码 · 重置登录 · 冻结',
              onTap: () => _account(context),
            ),
          ]),
        ],
      );
    },
  );

  Widget _num(String v, String k) => Expanded(
    child: Column(
      children: [
        Text(v, style: ts(17, w: FontWeight.w600, h: 24)),
        Text(k, style: ts(12, color: C.muted, h: 17)),
      ],
    ),
  );
}
