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
                  const SizedBox(height: 20),
                  SectionTitle(
                    '名下车辆',
                    action: '添加车辆',
                    onAction: () => openRoute(context, 'VehicleAdd'),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (var i = 0; i < memberVehicles.length; i++) ...[
                          _vehicle(memberVehicles[i]),
                          if (i < memberVehicles.length - 1)
                            const Divider1(indent: 16),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionTitle(
                    '次卡套餐',
                    action: '购买次卡',
                    onAction: () => openRoute(context, 'Recharge'),
                  ),
                  const SizedBox(height: 12),
                  for (final p in memberPacks) ...[
                    _pack(context, p),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 10),
                  SectionTitle(
                    '消费与充值记录',
                    action: '全部',
                    onAction: () => openRoute(context, 'MemberRecords'),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        for (var i = 0; i < memberRecords.length; i++) ...[
                          _record(memberRecords[i]),
                          if (i < memberRecords.length - 1)
                            const Divider1(indent: 16),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottom > 0 ? bottom : 16,
              ),
              decoration: BoxDecoration(
                color: C.card,
                boxShadow: [
                  BoxShadow(color: C.line, offset: const Offset(0, -1)),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      '余额充值',
                      bg: C.chip,
                      fg: C.ink,
                      onTap: () => openRoute(context, 'Recharge'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      '为他开单',
                      onTap: () => push(context, OrderPage(member: member)),
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

  Widget _hero() {
    Widget stat(String l, String v) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l, style: ts(12, color: C.faint, h: 16)),
          const SizedBox(height: 2),
          Text(
            v,
            style: ts(
              17,
              w: FontWeight.w600,
              color: const Color(0xFFFAFAFA),
              h: 24,
              tabular: true,
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
          const Positioned(right: -90, top: -100, child: Rings(size: 220)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Avatar(
                    member.name.substring(0, 1),
                    size: 52,
                    bg: C.gold,
                    fg: C.onGold,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                            const SizedBox(width: 8),
                            Pill(
                              '${member.level}会员',
                              bg: C.gold,
                              fg: C.onGold,
                              size: 11,
                            ),
                          ],
                        ),
                        Text(
                          '138 **** 6021 · 入会 2023.04',
                          style: ts(12, color: C.faint, h: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('储值余额（元）', style: ts(13, color: C.faint, h: 18)),
              const SizedBox(height: 2),
              Text(
                '3,680.00',
                style: ts(
                  34,
                  w: FontWeight.w600,
                  color: const Color(0xFFFAFAFA),
                  h: 40,
                  spacing: -1,
                  tabular: true,
                ),
              ),
              const SizedBox(height: 16),
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

  Widget _wechat(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    radius: 20,
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: member.bound ? C.greenSoft : C.chip,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppIcon(
            'chat',
            size: 18,
            color: member.bound ? C.greenInk : C.muted,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.bound ? '微信已绑定' : '微信未绑定',
                style: ts(14, w: FontWeight.w500, h: 20),
              ),
              Text(
                member.bound ? '2024.03.12 绑定 · 通知已开启' : '绑定后可微信通知消费与充值',
                style: ts(12, color: C.muted, h: 16),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () =>
              openRoute(context, member.bound ? 'NotifyLog' : 'BindInvite'),
          child: Text(
            member.bound ? '通知记录' : '发送邀请',
            style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
          ),
        ),
      ],
    ),
  );

  Widget _vehicle(Vehicle v) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(v.model, style: ts(15, w: FontWeight.w500, h: 22)),
              const SizedBox(height: 2),
              Text(v.note, style: ts(12, color: C.muted, h: 16)),
            ],
          ),
        ),
        PlateTag(v.plate),
      ],
    ),
  );

  Widget _pack(BuildContext context, CardPack p) => AppCard(
    onTap: () => openRoute(context, 'PackageDetail'),
    radius: 20,
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(p.name, style: ts(15, w: FontWeight.w500, h: 22)),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${p.used}',
                    style: ts(18, w: FontWeight.w600, h: 24),
                  ),
                  TextSpan(
                    text: ' / ${p.total} 次',
                    style: ts(12, color: C.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: p.used / p.total,
            minHeight: 6,
            backgroundColor: C.chip,
            valueColor: const AlwaysStoppedAnimation(C.primary),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(p.expire, style: ts(12, color: C.muted, h: 16)),
        ),
      ],
    ),
  );

  Widget _record(RecordItem r) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(r.date, style: ts(12, color: C.muted, h: 16)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.title, style: ts(14, w: FontWeight.w500, h: 20)),
              Text(r.desc, style: ts(12, color: C.muted, h: 16)),
            ],
          ),
        ),
        Text(
          r.amount,
          style: ts(
            15,
            w: FontWeight.w600,
            color: r.income ? C.greenInk : C.ink,
            h: 22,
            tabular: true,
          ),
        ),
      ],
    ),
  );
}
