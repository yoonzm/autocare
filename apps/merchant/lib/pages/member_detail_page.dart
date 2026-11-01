import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';
import 'order_page.dart';

class MemberDetailPage extends StatelessWidget {
  final Member member;
  const MemberDetailPage({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SubHeader(
              '会员详情',
              trailing: Align(
                alignment: Alignment.centerRight,
                child: RoundBtn(
                  'dots',
                  label: '更多',
                  onTap: () => openRoute(context, 'MemberMore'),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _hero(),
                  const SizedBox(height: 16),
                  _wechat(context),
                  const SizedBox(height: 16),
                  _vehicles(context),
                  const SizedBox(height: 16),
                  _packs(context),
                  const SizedBox(height: 16),
                  _recordsRow(context),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottom > 0 ? bottom - 4 : 16,
              ),
              decoration: BoxDecoration(
                color: C.card,
                boxShadow: [
                  BoxShadow(color: C.line, offset: const Offset(0, -1)),
                  const BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: _bottomBtn(
                      '余额充值',
                      C.chip,
                      C.ink,
                      () => openRoute(context, 'Recharge'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 14,
                    child: _bottomBtn(
                      '为他开单',
                      C.primary,
                      Colors.white,
                      () => push(context, OrderPage(member: member)),
                      icon: 'receipt',
                      bold: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomBtn(
    String t,
    Color bg,
    Color fg,
    VoidCallback onTap, {
    String? icon,
    bool bold = false,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            AppIcon(icon, size: 18, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            t,
            style: ts(
              15,
              w: bold ? FontWeight.w600 : FontWeight.w500,
              color: fg,
              h: 22,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _hero() {
    Widget stat(String l, String v) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: ts(12, color: const Color(0xFFA1A1AA), h: 16)),
          const SizedBox(height: 2),
          Text(
            v,
            style: ts(
              15,
              w: FontWeight.w600,
              color: const Color(0xFFFAFAFA),
              h: 22,
            ),
          ),
        ],
      ),
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: C.heroCard,
        border: C.heroBorder,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(
            right: -90,
            bottom: -120,
            child: Rings(size: 260, color: Color(0xFF3A3226)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: C.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      member.name.substring(0, 1),
                      style: ts(18, w: FontWeight.w600, color: C.onGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.name,
                          style: ts(
                            18,
                            w: FontWeight.w600,
                            color: const Color(0xFFFAFAFA),
                            h: 26,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '138 **** 6021 · 入会 2023.04',
                          style: ts(12, color: const Color(0xFFA1A1AA), h: 16),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: C.gold,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      '${member.level}会员',
                      style: ts(12, w: FontWeight.w600, color: C.onGold, h: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '储值余额（元）',
                style: ts(12, color: const Color(0xFFA1A1AA), h: 16),
              ),
              const SizedBox(height: 2),
              Text(
                '3,680.00',
                style: ts(
                  32,
                  w: FontWeight.w600,
                  color: const Color(0xFFFAFAFA),
                  h: 38,
                  spacing: -1,
                  tabular: true,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.only(top: 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFF2E2E33))),
                ),
                child: Row(
                  children: [
                    stat('累计消费', '¥28,450'),
                    stat('到店次数', '46 次'),
                    stat('积分', '12,450'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _wechat(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => openRoute(context, member.bound ? 'NotifyLog' : 'BindInvite'),
    child: AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: member.bound ? C.greenSoft : C.chip,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AppIcon(
                  'chat',
                  size: 18,
                  color: member.bound ? C.greenInk : C.muted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.bound ? '微信已绑定' : '微信未绑定', style: ts(15, h: 22)),
                  Text(
                    member.bound ? '2024.03.12 绑定 · 通知已开启' : '绑定后可微信通知消费与充值',
                    style: ts(12, color: C.muted, h: 16),
                  ),
                ],
              ),
            ),
            Text(
              member.bound ? '通知记录' : '发送邀请',
              style: ts(13, color: C.muted, h: 18),
            ),
            const SizedBox(width: 4),
            AppIcon('chevronRight', size: 16, color: C.faint),
          ],
        ),
      ),
    ),
  );

  Widget _sectionHead(String title, String action, VoidCallback onTap) => Row(
    children: [
      Expanded(
        child: Text(title, style: ts(15, w: FontWeight.w600, h: 22)),
      ),
      GestureDetector(
        onTap: onTap,
        child: Text(
          action,
          style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
        ),
      ),
    ],
  );

  Widget _vehicles(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead('名下车辆', '添加车辆', () => openRoute(context, 'VehicleAdd')),
        for (var i = 0; i < memberVehicles.length; i++) ...[
          const SizedBox(height: 12),
          if (i > 0) ...[const Divider1(), const SizedBox(height: 12)],
          _vehicle(memberVehicles[i], green: i == 1),
        ],
      ],
    ),
  );

  Widget _vehicle(Vehicle v, {bool green = false}) => Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: C.inset,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: AppIcon('car', size: 22, color: C.sub)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(v.model, style: ts(14, w: FontWeight.w500, h: 20)),
            const SizedBox(height: 2),
            Text(v.note, style: ts(12, color: C.muted, h: 16)),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: green ? const Color(0xFFD7F5E1) : const Color(0xFF0B5FD6),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: green ? const Color(0xFF86D9A4) : const Color(0xFF5B9BF0),
            width: 1.5,
          ),
        ),
        child: Text(
          v.plate,
          maxLines: 1,
          style: ts(
            12,
            w: FontWeight.w600,
            color: green ? const Color(0xFF14532D) : Colors.white,
            h: 16,
          ),
        ),
      ),
    ],
  );

  Widget _packs(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHead('次卡套餐', '购买次卡', () => openRoute(context, 'RechargeCard')),
        for (var i = 0; i < memberPacks.length; i++) ...[
          const SizedBox(height: 14),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openRoute(context, 'PackageDetail'),
            child: _pack(memberPacks[i], i),
          ),
        ],
      ],
    ),
  );

  Widget _pack(CardPack p, int i) {
    final amber = i == 1;
    final bg = amber ? C.amberSoft : C.primarySoft;
    final fg = amber ? C.amberInk : C.primaryInk;
    final bar = amber ? C.amber : C.primary;
    final rest = p.expire.contains('到期') && i == 1
        ? ' / ${p.total} 次 · ${p.expire}'
        : ' / ${p.total} 次';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(
                child: AppIcon(amber ? 'sparkle' : 'drop', size: 16, color: fg),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(p.name, style: ts(14, w: FontWeight.w500, h: 20)),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${p.used}',
                    style: ts(13, w: FontWeight.w600, h: 18),
                  ),
                  TextSpan(
                    text: rest,
                    style: ts(13, color: C.muted, h: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Stack(
            children: [
              Container(height: 6, color: C.chip),
              FractionallySizedBox(
                widthFactor: p.used / p.total,
                child: Container(height: 6, color: bar),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recordsRow(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => openRoute(context, 'MemberRecords'),
    child: AppCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: C.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: AppIcon('receipt', size: 18, color: C.primaryInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('消费与充值记录', style: ts(15, w: FontWeight.w500, h: 22)),
            ),
            Text('最近 今天', style: ts(13, color: C.muted, h: 18)),
            const SizedBox(width: 4),
            AppIcon('chevronRight', size: 16, color: C.faint),
          ],
        ),
      ),
    ),
  );
}
