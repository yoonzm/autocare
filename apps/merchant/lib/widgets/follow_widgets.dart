import 'package:flutter/material.dart';

import '../backend/catalog_draft.dart';
import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart' show AppToast;
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import '../theme.dart' show C, softShadow;

/// 回访提醒页里的数字（来自 [MemberFlow.reminders]）。
class FollowView {
  const FollowView();
  Map<String, dynamic> get _r => MemberFlow.reminders ?? const {};
  int get pending => (_r['pending'] as num?)?.toInt() ?? 0;
  int get done => (_r['done_today'] as num?)?.toInt() ?? 0;
  Map<String, dynamic> get _counts =>
      Map<String, dynamic>.from((_r['counts'] as Map?) ?? const {});
  int count(String kind) => (_counts[kind] as num?)?.toInt() ?? 0;
  int get all => List.of((_r['items'] as List?) ?? const []).length;

  String get chipAll => '全部 $all';
  String get chipExpire => '次卡到期 ${count('次卡到期')}';
  // TODO: 养护到期要按服务的施工记录推算（如镀晶满 3 个月），依赖订单里的施工记录，暂未接通。
  String get chipCare => '养护到期 0';
  String get chipBirthday => '生日 ${count('生日')}';
  String get chipSleep => '沉睡 ${count('沉睡客户')}';

  double get fraction {
    final total = done + pending;
    return total == 0 ? 0 : (done / total).clamp(0, 1).toDouble();
  }
}

/// 随回访提醒变化的文字；没登录（设计预览）时显示示例。
Widget hFollowText(
  String Function(FollowView f) text,
  String sample,
  TextStyle style, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ValueListenableBuilder<int>(
  valueListenable: MemberFlow.reminderTick,
  builder: (_, _, _) => Text(
    merchantApi.hasSession && MemberFlow.reminders != null
        ? text(const FollowView())
        : sample,
    style: style,
    textAlign: textAlign,
    softWrap: softWrap,
    maxLines: maxLines,
  ),
);

/// 同一行里样式不同的几段文字（如“已完成 5 / 23”“18 位客户”）。
Widget hFollowRich(
  List<String Function(FollowView f)> parts,
  List<String> samples,
  List<TextStyle> styles, {
  TextAlign? textAlign,
  bool? softWrap,
  int? maxLines,
}) => ValueListenableBuilder<int>(
  valueListenable: MemberFlow.reminderTick,
  builder: (_, _, _) {
    final live = merchantApi.hasSession && MemberFlow.reminders != null;
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < parts.length; i++)
            TextSpan(
              text: live ? parts[i](const FollowView()) : samples[i],
              style: styles[i],
            ),
        ],
      ),
      textAlign: textAlign,
      softWrap: softWrap,
      maxLines: maxLines,
    );
  },
);

/// 回访完成度进度条。
Widget hFollowProgress() => ValueListenableBuilder<int>(
  valueListenable: MemberFlow.reminderTick,
  builder: (_, _, _) {
    final f = merchantApi.hasSession && MemberFlow.reminders != null
        ? const FollowView().fraction
        : 0.22;
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFF3F3F46),
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: f,
        child: Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF0485F7),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  },
);

/// 提醒卡片列表：按页签筛选，最近的在前。
Widget hReminderList() => ListenableBuilder(
  listenable: Listenable.merge([
    MemberFlow.reminderTab,
    MemberFlow.reminderTick,
  ]),
  builder: (context, _) {
    if (!merchantApi.hasSession) return const SizedBox.shrink();
    final data = MemberFlow.reminders;
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    final kind = MemberFlow.reminderKinds[MemberFlow.reminderTab.value];
    final items = [
      for (final e in List<Map<String, dynamic>>.from(data['items'] as List))
        if (kind == null || e['kind'] == kind) e,
    ];
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
          _ReminderCard(item: items[i]),
        ],
      ],
    );
  },
);

class _ReminderCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ReminderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final kind = '${item['kind']}';
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
            onTap: () async {
              try {
                MemberFlow.current = await merchantApi.member(
                  '${item['member_id']}',
                );
                if (context.mounted) openRoute(context, 'MemberDetail');
              } catch (e) {
                if (context.mounted) AppToast.error(context, e);
              }
            },
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
                  onTap: () async {
                    if (primary == '标记已回访') {
                      await MemberFlow.markFollowedUp(
                        context,
                        '${item['member_id']}',
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
                  onTap: () => MemberFlow.markFollowedUp(
                    context,
                    '${item['member_id']}',
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  final String label;
  final bool filled;
  final Future<void> Function() onTap;
  const _FollowButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });
  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: _busy
        ? null
        : () async {
            setState(() => _busy = true);
            try {
              await widget.onTap();
            } finally {
              if (mounted) setState(() => _busy = false);
            }
          },
    child: Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.filled
            ? dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA))
            : dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _busy ? '处理中…' : widget.label,
        style: hts(
          13,
          widget.filled
              ? dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B))
              : dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
          w: FontWeight.w500,
          lh: 18,
        ),
      ),
    ),
  );
}

/// 记录回访页的“历史回访”。
Widget hVisitHistory() => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (context, _) {
    final rows = merchantApi.hasSession
        ? MemberFlow.visitHistory
        : const <Map<String, dynamic>>[];
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            '历史回访',
            style: hts(
              13,
              dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
              w: FontWeight.w500,
              lh: 18,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
            boxShadow: C.dark ? null : softShadow,
            border: C.dark ? Border.all(color: const Color(0xFF26262B)) : null,
          ),
          child: rows.isEmpty
              ? Text('还没有回访记录', style: hts(13, muted, lh: 18))
              : Column(
                  children: [
                    for (var i = 0; i < rows.length && i < 5; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                [
                                  '${rows[i]['method']}',
                                  if ('${rows[i]['result']}'.isNotEmpty)
                                    '${rows[i]['result']}',
                                ].join(' · '),
                                style: hts(14, ink, w: FontWeight.w500, lh: 20),
                              ),
                              const Spacer(),
                              Text(
                                _md(rows[i]['created_at']),
                                style: hts(12, muted, lh: 17),
                              ),
                            ],
                          ),
                          if ('${rows[i]['content']}'.isNotEmpty)
                            Text(
                              '${rows[i]['content']}',
                              style: hts(13, muted, lh: 18),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  },
);

String _md(Object? at) {
  final t = DateTime.tryParse('$at')?.toLocal();
  if (t == null) return '';
  return '${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
}

/// 下次回访日期：点一下选日期，选了之后保存回访时一并提交。
Widget hVisitNext(String sample, TextStyle style) => ListenableBuilder(
  listenable: CatalogDraft.preview,
  builder: (context, _) {
    if (!merchantApi.hasSession) return Text(sample, style: style);
    final v = CatalogDraft.text('visit', 'next', '');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final ctrl = StrCtrl(v.isEmpty ? '选填' : v.replaceAll('-', '.'));
        await hPick(context, 'datefull', '下次回访', ctrl);
        final r = ctrl.v;
        if (RegExp(r'^\d{4}\.\d{1,2}\.\d{1,2}$').hasMatch(r)) {
          CatalogDraft.set('visit', 'next', r.replaceAll('.', '-'));
        }
      },
      child: Text(v.isEmpty ? '选填' : v.replaceAll('-', '.'), style: style),
    );
  },
);
