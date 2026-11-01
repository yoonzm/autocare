import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

String followSub(Merchant m) {
  final d = m.daysLeft;
  final a = d < 0
      ? '已到期 ${-d} 天'
      : m.plan == PlanKind.trial
      ? '试用剩 $d 天'
      : d == 0
      ? '今天到期'
      : '$d 天后到期';
  return '$a · ${m.logs.isEmpty ? '未联系' : '已联系 ${m.logs.length} 次'}';
}

class FollowPage extends StatefulWidget {
  const FollowPage({super.key});
  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  int tab = 1;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final list = store.followUps(tab);
      return AdPage(
        title: '到期跟进',
        children: [
          Segmented(
            labels: [
              '已到期 ${store.followUps(0).length}',
              '7 日内 ${store.followUps(1).length}',
              '30 日内 ${store.followUps(2).length}',
            ],
            index: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('暂无需要跟进的商家')
          else
            RowGroup([
              for (final m in list)
                Row1(
                  leading: ToneTile(m.tone, Icons.storefront_outlined),
                  title: m.name,
                  sub: followSub(m),
                  trailing: m.plan == PlanKind.trial && m.daysLeft >= 0
                      ? Pill('待转化', C.primaryInk, C.primarySoft)
                      : m.daysLeft < 0
                      ? Pill('待跟进', C.redInk, C.redSoft)
                      : Pill('待跟进', C.amberInk, C.amberSoft),
                  onTap: () => go(context, FollowLogPage(m)),
                ),
            ]),
        ],
      );
    },
  );
}

class FollowLogPage extends StatefulWidget {
  final Merchant m;
  const FollowLogPage(this.m, {super.key});
  @override
  State<FollowLogPage> createState() => _FollowLogPageState();
}

class _FollowLogPageState extends State<FollowLogPage> {
  final note = TextEditingController();

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void _save() {
    if (note.text.trim().isEmpty) {
      toast(context, '请填写沟通内容');
      return;
    }
    FocusScope.of(context).unfocus();
    store.addLog(widget.m, note.text);
    note.clear();
    toast(context, '已保存跟进记录');
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.m;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => AdPage(
        title: '跟进记录',
        dock: Btn('保存记录', onTap: _save),
        children: [
          HCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SoftTile(Icons.storefront_outlined, C.amberInk, C.amberSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.name, style: ts(15, w: FontWeight.w600, h: 22)),
                      Text(
                        m.daysLeft < 0
                            ? '已到期 ${-m.daysLeft} 天 · ${m.plan.label}'
                            : '${m.daysLeft} 天后到期 · ${m.plan.label}',
                        style: ts(12, color: C.muted, h: 17),
                      ),
                    ],
                  ),
                ),
                m.plan == PlanKind.trial && m.daysLeft >= 0
                    ? Pill('待转化', C.primaryInk, C.primarySoft)
                    : Pill('待跟进', C.redInk, C.redSoft),
              ],
            ),
          ),
          Section(
            '历史记录',
            HCard(
              child: m.logs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('还没有跟进记录', style: ts(13, color: C.muted)),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < m.logs.length; i++)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      margin: const EdgeInsets.only(top: 4),
                                      decoration: BoxDecoration(
                                        color: C.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: C.primary.withValues(alpha: .15),
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i < m.logs.length - 1)
                                      Expanded(
                                        child: Container(
                                          width: 2,
                                          margin: const EdgeInsets.only(top: 8),
                                          color: C.stroke,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${md(m.logs[i].date)} · ${m.logs[i].who}',
                                          style: ts(12, w: FontWeight.w500, color: C.muted, h: 17),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          m.logs[i].text,
                                          style: ts(14, w: FontWeight.w500, h: 21),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ),
          Section(
            '新增记录',
            HCard(
              child: Field(
                label: '沟通内容',
                controller: note,
                hint: '记录本次沟通内容',
                maxLines: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
