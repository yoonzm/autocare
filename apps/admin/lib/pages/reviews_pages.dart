import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

(Color, Color) reviewColors(RStatus s) => switch (s) {
  RStatus.pending => (C.amberInk, C.amberSoft),
  RStatus.approved => (C.greenInk, C.greenSoft),
  RStatus.rejected => (C.redInk, C.redSoft),
};

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({super.key});
  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final s = RStatus.values[tab];
      final list = store.reviews.where((r) => r.status == s).toList();
      return AdPage(
        title: '开通审核',
        children: [
          Segmented(
            labels: [
              '待审核 ${store.pendingReviews}',
              '已通过',
              '已驳回',
            ],
            index: tab,
            onChanged: (i) => setState(() => tab = i),
          ),
          if (list.isEmpty)
            const Empty('暂无记录')
          else
            RowGroup([
              for (final r in list)
                Row1(
                  leading: SoftTile(Icons.storefront_outlined, C.amberInk, C.amberSoft),
                  title: r.name,
                  sub: '${md(r.submitted)}提交 · ${r.city}',
                  trailing: Pill(r.status.label, reviewColors(r.status).$1, reviewColors(r.status).$2),
                  onTap: () => go(context, ReviewDetailPage(r)),
                ),
            ]),
        ],
      );
    },
  );
}

class ReviewDetailPage extends StatelessWidget {
  final Review r;
  const ReviewDetailPage(this.r, {super.key});

  static const _reasons = [
    ('营业执照不清晰', '请商家重新上传清晰的营业执照'),
    ('门头照片与店名不符', '门头照片中的店名需与申请一致'),
    ('缺少环保备案', '需补充环保备案材料'),
    ('疑似重复申请', '该店铺已存在，请勿重复提交'),
  ];

  Future<void> _approve(BuildContext context) async {
    final trial = r.plan == PlanKind.trial;
    final ok = await confirm(
      context,
      title: '通过并开通',
      message: trial
          ? '将为「${r.name}」开通 ${store.plans.last.trialDays} 天试用，并短信通知店主。'
          : '将为「${r.name}」开通${r.plan.label}（1 年），并短信通知店主。',
      ok: '通过并开通',
    );
    if (!ok || !context.mounted) return;
    store.approve(r);
    toast(context, '已开通，商家已加入商家列表');
    Navigator.pop(context);
  }

  Future<void> _reject(BuildContext context) async {
    final i = await pickOption(
      context,
      title: '驳回原因',
      subtitle: r.name,
      options: [for (final x in _reasons) SheetOption(x.$1, x.$2, danger: true)],
      footnote: '原因会通过短信告知店主，可重新提交。',
      ok: '确认驳回',
    );
    if (i == null || !context.mounted) return;
    store.reject(r, _reasons[i].$1);
    toast(context, '已驳回');
    Navigator.pop(context);
  }

  void _preview(BuildContext context, String name, IconData icon) {
    showDialog<void>(
      context: context,
      builder: (c) => Dialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: ts(16, w: FontWeight.w600, h: 24)),
              const SizedBox(height: 12),
              Container(
                height: 220,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 56, color: C.faint),
                    const SizedBox(height: 8),
                    Text('${r.name}\n（演示图片）', textAlign: TextAlign.center, style: ts(12, color: C.muted, h: 17)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Btn('关闭', ghost: true, onTap: () => Navigator.pop(c)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final (fg, bg) = reviewColors(r.status);
      final t = r.submitted;
      final time =
          '${md(t)} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} 提交';
      return AdPage(
        title: '审核详情',
        dock: r.status == RStatus.pending
            ? Row(
                children: [
                  Expanded(flex: 5, child: Btn('驳回', soft: true, onTap: () => _reject(context))),
                  const SizedBox(width: 10),
                  Expanded(flex: 7, child: Btn('通过并开通', onTap: () => _approve(context))),
                ],
              )
            : null,
        children: [
          HCard(
            child: Row(
              children: [
                SoftTile(Icons.storefront_outlined, C.amberInk, C.amberSoft),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: ts(15, w: FontWeight.w600, h: 22)),
                      Text(time, style: ts(12, color: C.muted, h: 17)),
                    ],
                  ),
                ),
                Pill(r.status.label, fg, bg),
              ],
            ),
          ),
          HCard(
            child: Column(
              children: [
                KV('店主', '${r.owner}* · ${r.maskedPhone}'),
                KV('城市', '${r.city} · ${r.district}'),
                KV('工位数', '${r.bays}'),
                KV('选择套餐', r.plan == PlanKind.trial ? '试用 ${store.plans.last.trialDays} 天' : r.plan.label),
                if (r.status == RStatus.rejected) KV('驳回原因', r.reason ?? '-', vColor: C.redInk),
              ],
            ),
          ),
          Section(
            '证照材料',
            Row(
              children: [
                for (final (i, e) in [
                  ('营业执照', Icons.description_outlined),
                  ('门头照片', Icons.storefront_outlined),
                  ('环保备案', Icons.eco_outlined),
                ].indexed) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _preview(context, e.$1, e.$2),
                      child: Container(
                        height: 96,
                        decoration: BoxDecoration(
                          color: C.card,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: softShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(e.$2, size: 28, color: C.primary),
                            const SizedBox(height: 6),
                            Text(e.$1, style: ts(12, w: FontWeight.w500, color: C.sub, h: 17)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    },
  );
}
