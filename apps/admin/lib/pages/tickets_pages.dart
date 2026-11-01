import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

(Color, Color) ticketColors(TStatus s) => switch (s) {
  TStatus.todo => (C.redInk, C.redSoft),
  TStatus.doing => (C.primaryInk, C.primarySoft),
  TStatus.done => (C.greenInk, C.greenSoft),
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
          Segmented(
            labels: ['待处理 ${store.todoTickets}', '处理中', '已解决'],
            index: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('暂无工单')
          else
            RowGroup([
              for (final t in list)
                Row1(
                  leading: SoftTile(
                    Icons.chat_bubble_outline_rounded,
                    ticketColors(t.status).$1,
                    ticketColors(t.status).$2,
                  ),
                  title: t.title,
                  sub: '${t.merchant} · ${t.when}',
                  trailing: Pill(t.status.label, ticketColors(t.status).$1, ticketColors(t.status).$2),
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

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  void _send() {
    if (text.text.trim().isEmpty) {
      toast(context, '请输入回复内容');
      return;
    }
    store.reply(widget.t, text.text);
    text.clear();
  }

  Future<void> _resolve() async {
    final ok = await confirm(
      context,
      title: '标记为已解决',
      message: '工单关闭后商家将收到通知，不能再继续回复。',
      ok: '已解决',
    );
    if (!ok || !mounted) return;
    store.resolve(widget.t);
    toast(context, '工单已解决');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final (fg, bg) = ticketColors(t.status);
        return AdPage(
          title: '工单详情',
          dock: t.status == TStatus.done
              ? Text('该工单已解决', textAlign: TextAlign.center, style: ts(13, color: C.muted, h: 50))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Field(
                      label: '回复',
                      controller: text,
                      hint: '输入回复内容…',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(flex: 7, child: Btn('发送', onTap: _send)),
                        const SizedBox(width: 10),
                        Expanded(flex: 5, child: Btn('已解决', ghost: true, onTap: _resolve)),
                      ],
                    ),
                  ],
                ),
          children: [
            HCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(t.title, style: ts(17, w: FontWeight.w600, h: 24))),
                      Pill(t.status.label, fg, bg),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${t.merchant} · ${t.when} · 店主 ${t.owner}', style: ts(12, color: C.muted, h: 17)),
                ],
              ),
            ),
            for (final m in t.msgs)
              Align(
                alignment: m.fromMerchant ? Alignment.centerLeft : Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    child: Text(
                      m.text,
                      style: ts(14, color: m.fromMerchant ? C.ink : Colors.white, h: 21),
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
