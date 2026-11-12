import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

Tone ticketTone(TStatus s) => switch (s) {
  TStatus.todo => Tone.bad,
  TStatus.doing => Tone.wait,
  TStatus.done => Tone.ok,
};

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});
  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final s = TStatus.values[tab];
      final list = store.tickets.where((t) => t.status == s).toList();
      return AdPage(
        title: '工单',
        children: [
          AppSegmented<int>(
            items: [
              SegmentItem(value: 0, label: '待处理 ${store.todoTickets}'),
              const SegmentItem(value: 1, label: '处理中'),
              const SegmentItem(value: 2, label: '已解决'),
            ],
            selected: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('暂无工单')
          else
            AppListGroup(rows: [
              for (final t in list)
                AppListRow(size: AppRowSize.spacious, 
                  leading: AppIconTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    tone: ticketTone(t.status),
                  ),
                  title: t.title,
                  subtitle: '${t.merchant} · ${t.when}',
                  trailing: AppStatusTag(t.status.label, tone: ticketTone(t.status)),
                  onTap: () => go(context, TicketDetailPage(t)),
                ),
            ]),
        ],
      );
    },
  );
}

class TicketDetailPage extends StatefulWidget {
  final Ticket t;
  const TicketDetailPage(this.t, {super.key});
  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> {
  final text = TextEditingController();
  bool sending = false;

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (text.text.trim().isEmpty) {
      toast(context, '请输入回复内容');
      return;
    }
    setState(() => sending = true);
    try {
      await store.reply(widget.t, text.text);
      if (!mounted) return;
      text.clear();
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Future<void> _resolve() async {
    final ok = await showAppDialog(
      context,
      title: '标记为已解决',
      message: '工单关闭后商家将收到通知，不能再继续回复。',
      confirmLabel: '已解决',
      onConfirm: () => store.resolve(widget.t),
    );
    if (!ok || !mounted) return;
    // TODO support_notify: no merchant notification channel/delivery callback yet.
    toast(context, '工单已解决，通知渠道尚未接通');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final t =
            store.tickets.where((t) => t.id == widget.t.id).firstOrNull ??
            widget.t;
        return AdPage(
          title: '工单详情',
          dock: t.status == TStatus.done
              ? Text(
                  '该工单已解决',
                  textAlign: TextAlign.center,
                  style: ts(13, color: C.muted, h: 50),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: '回复',
                      controller: text,
                      hint: '输入回复内容…',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: '已解决',
                            kind: AppButtonKind.secondary,
                            size: AppButtonSize.large,
                            expanded: true,
                            onPressed: sending
                                ? null
                                : () {
                                    unawaited(_resolve());
                                  },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            label: '发送',
                            size: AppButtonSize.large,
                            expanded: true,
                            loading: sending,
                            onPressed: _send,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.title,
                          style: ts(17, w: FontWeight.w600, h: 24),
                        ),
                      ),
                      AppStatusTag(t.status.label, tone: ticketTone(t.status)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${t.merchant} · ${t.when} · 店主 ${t.owner}',
                    style: ts(12, color: C.muted, h: 17),
                  ),
                ],
              ),
            ),
            for (final m in t.msgs)
              Align(
                alignment: m.fromMerchant
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * .78,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: m.fromMerchant ? C.card : C.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(m.fromMerchant ? 4 : 18),
                        bottomRight: Radius.circular(m.fromMerchant ? 18 : 4),
                      ),
                      boxShadow: m.fromMerchant ? softShadow : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.text,
                          style: ts(
                            14,
                            color: m.fromMerchant ? C.ink : Colors.white,
                            h: 21,
                          ),
                        ),
                        for (final id in m.attachments)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _TicketScreenshot(id: id),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TicketScreenshot extends StatefulWidget {
  final String id;
  const _TicketScreenshot({required this.id});
  @override
  State<_TicketScreenshot> createState() => _TicketScreenshotState();
}

class _TicketScreenshotState extends State<_TicketScreenshot> {
  final view = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    height: 180,
    child: AsyncView<Map<String, dynamic>>(
      key: view,
      inlineError: true,
      load: () => store.api.call('ticket_attachment', {'id': widget.id}),
      isEmpty: (_) => false,
      skeleton: Center(child: AppSpinner(size: 20, color: C.primary)),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, data) => Image.network(
        data['url'] as String,
        fit: BoxFit.contain,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Center(child: AppSpinner(size: 20, color: C.primary)),
        errorBuilder: (_, _, _) => LoadingButton(
          label: '截图加载失败，重试',
          onPressed: () async {
            await view.currentState?.reload();
          },
        ),
      ),
    ),
  );
}
