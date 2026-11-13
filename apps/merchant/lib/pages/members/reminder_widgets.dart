import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../theme.dart' show C, softShadow;
import 'member_reminder_controller.dart';

class FollowProgress extends StatelessWidget {
  final double fraction;
  const FollowProgress({super.key, required this.fraction});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F46),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: fraction,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF0485F7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

class ReminderList extends StatelessWidget {
  final MemberReminderController controller;
  final VoidCallback reload;
  const ReminderList({
    super.key,
    required this.controller,
    required this.reload,
  });
  @override
  Widget build(BuildContext context) {
    final kind = MemberReminderController.kinds[controller.tab];
    final items = controller.items;
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            kind == '养护到期' ? '养护提醒暂未接通' : '今天没有需要回访的客户',
            style: hts(
              14,
              dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3)),
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _ReminderCard(item: items[i], controller: controller, reload: reload),
        ],
      ],
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final MemberReminderController controller;
  final VoidCallback reload;
  const _ReminderCard({
    required this.item,
    required this.controller,
    required this.reload,
  });

  @override
  Widget build(BuildContext context) {
    final kind = '${item['kind']}';
    final actionKey = controller.markKey('${item['member_id']}');
    final (bg, fg) = switch (kind) {
      '次卡到期' => (
        dk(
          context,
          const Color(0xFFFFE1E2),
          const Color.fromRGBO(255, 56, 60, 0.18),
        ),
        dk(context, const Color(0xFFA43433), const Color(0xFFFF7B7E)),
      ),
      '生日' => (
        dk(
          context,
          const Color(0xFFFDEFD6),
          const Color.fromRGBO(245, 165, 36, 0.16),
        ),
        dk(context, const Color(0xFF855F2E), const Color(0xFFF5A524)),
      ),
      _ => (
        dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A)),
        dk(context, const Color(0xFF3F3F46), const Color(0xFFA8A8B3)),
      ),
    };
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    final name = '${item['name']}';
    final sub = [
      if ('${item['card'] ?? ''}'.isNotEmpty) '${item['card']}',
      if ('${item['plate'] ?? ''}'.isNotEmpty) '${item['plate']}',
    ].join(' · ');
    final primary = switch (kind) {
      '次卡到期' => '发送续卡优惠',
      '生日' => '发放生日礼',
      _ => '标记已回访',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: C.dark ? null : softShadow,
        border: C.dark ? Border.all(color: const Color(0xFF26262B)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  kind,
                  style: hts(11, fg, w: FontWeight.w600, lh: 20),
                ),
              ),
              const Spacer(),
              Text(
                '${item['when']}',
                style: hts(12, fg, w: FontWeight.w500, lh: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.openMember(context, '${item['member_id']}'),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: dk(
                      context,
                      const Color(0xFFE1F0FE),
                      const Color.fromRGBO(4, 133, 247, 0.18),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    name.isEmpty ? '' : name.substring(0, 1),
                    style: hts(
                      14,
                      dk(
                        context,
                        const Color(0xFF1E63AE),
                        const Color(0xFF6AB4FA),
                      ),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '$name ',
                              style: hts(15, ink, w: FontWeight.w500, lh: 22),
                            ),
                            if (sub.isNotEmpty)
                              TextSpan(
                                text: '· $sub',
                                style: hts(12, muted, lh: 22),
                              ),
                          ],
                        ),
                      ),
                      if ('${item['text']}'.isNotEmpty)
                        Text(
                          '${item['text']}',
                          style: hts(
                            13,
                            dk(
                              context,
                              const Color(0xFF52525B),
                              const Color(0xFFA8A8B3),
                            ),
                            lh: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FollowButton(
                  label: primary,
                  filled: true,
                  actionKey: actionKey,
                  onTap: () async {
                    if (primary == '标记已回访') {
                      await controller.mark(
                        context,
                        '${item['member_id']}',
                        reload,
                      );
                    } else {
                      // TODO: 续卡优惠 / 生日礼要通过微信或短信下发、并发放赠品，依赖微信和营销模块。
                      hToast(context, '$primary暂未接通（依赖微信 / 短信通知）');
                    }
                  },
                ),
              ),
              if (primary != '标记已回访') ...[
                const SizedBox(width: 8),
                _FollowButton(
                  label: '标记已回访',
                  filled: false,
                  actionKey: actionKey,
                  onTap: () =>
                      controller.mark(context, '${item['member_id']}', reload),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final String label;
  final bool filled;
  final Future<void> Function() onTap;
  final String actionKey;
  const _FollowButton({
    required this.label,
    required this.filled,
    required this.onTap,
    required this.actionKey,
  });
  @override
  Widget build(BuildContext context) => AsyncActionScope(
    actionKey: actionKey,
    child: ActionButton(
      actionKey: actionKey,
      label: label,
      kind: filled ? AppButtonKind.primary : AppButtonKind.secondary,
      size: AppButtonSize.medium,
      expanded: false,
      onPressed: onTap,
    ),
  );
}
