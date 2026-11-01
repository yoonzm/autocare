import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'follow_pages.dart';
import 'shell_page.dart';
import 'tickets_pages.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => AdPage(
      title: '概览',
      back: false,
      children: [
        DarkHero(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('本月 MRR（元）', style: ts(13, w: FontWeight.w500, color: C.faint, h: 19)),
                  const Spacer(),
                  const Pill('↑ 12.4%', Color(0xFF6EE7A8), Color(0x3317C964)),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                money(store.subsRevenue),
                style: ts(34, w: FontWeight.w600, color: C.gold, h: 42),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _stat('${store.paidCount}', '付费商家'),
                  _stat('${store.trialCount}', '试用中'),
                  _stat('96.2%', '续费率'),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _tile(
                context,
                Icons.hourglass_bottom_rounded,
                C.amberInk,
                C.amberSoft,
                '${store.expiring7}',
                '7 日内到期',
                '需跟进',
                C.redInk,
                () => go(context, const FollowPage()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _tile(
                context,
                Icons.storefront_rounded,
                C.primaryInk,
                C.primarySoft,
                '${store.weekNew}',
                '本周新增商家',
                '↑ +${store.weekNew - 9}',
                C.greenInk,
                () => tabIndex.value = 1,
              ),
            ),
          ],
        ),
        Section(
          '待办',
          RowGroup([
            _todo(
              Icons.event_busy_outlined,
              C.redInk,
              C.redSoft,
              '到期跟进',
              '${store.expiring7} 家 7 日内到期',
              store.expiring7,
              () => go(context, const FollowPage()),
            ),
            _todo(
              Icons.chat_bubble_outline_rounded,
              C.primaryInk,
              C.primarySoft,
              '工单',
              '${store.todoTickets} 个待处理',
              store.todoTickets,
              () => go(context, const TicketsPage()),
            ),
          ]),
        ),
      ],
    ),
  );

  Widget _stat(String v, String k) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(v, style: ts(17, w: FontWeight.w600, color: const Color(0xFFFAFAFA), h: 24)),
        Text(k, style: ts(11, color: C.faint, h: 16)),
      ],
    ),
  );

  Widget _tile(
    BuildContext context,
    IconData icon,
    Color fg,
    Color bg,
    String n,
    String label,
    String note,
    Color noteColor,
    VoidCallback onTap,
  ) => HCard(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftTile(icon, fg, bg, size: 36),
        const SizedBox(height: 10),
        Text(n, style: ts(28, w: FontWeight.w600, h: 34)),
        Text(label, style: ts(12, color: C.muted, h: 17)),
        const SizedBox(height: 4),
        Text(note, style: ts(12, w: FontWeight.w600, color: noteColor, h: 17)),
      ],
    ),
  );

  Widget _todo(
    IconData icon,
    Color fg,
    Color bg,
    String title,
    String sub,
    int n,
    VoidCallback onTap,
  ) => Row1(
    leading: SoftTile(icon, fg, bg),
    title: title,
    sub: sub,
    onTap: onTap,
    trailing: n > 0 ? Pill('$n', C.redInk, C.redSoft) : null,
  );
}
