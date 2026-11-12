import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

String _k(num v) => v >= 10000
    ? '¥${(v / 10000).toStringAsFixed(1)}万'
    : '¥${(v / 1000).toStringAsFixed(1)}k';

class SubsPage extends StatefulWidget {
  const SubsPage({super.key});
  @override
  State<SubsPage> createState() => _SubsPageState();
}

class _SubsPageState extends State<SubsPage> {
  int? sel;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final values = [...store.history, store.monthRevenue];
      final months = store.months;
      final top = values
          .map((v) => v.abs())
          .fold<num>(1, (a, b) => a > b ? a : b);
      final cur = sel ?? values.length - 1;
      return AdPage(
        title: '订阅与收入',
        back: false,
        children: [
          AppHeroCard.custom(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '本月收入（元）',
                      style: ts(13, w: FontWeight.w500, color: C.faint, h: 19),
                    ),
                    const Spacer(),
                    AppStatusTag(
                      percentLabel(store.stats['revenue_change'], change: true),
                      tone: Tone.okOnDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  money(store.monthRevenue),
                  style: ts(34, w: FontWeight.w600, color: C.gold, h: 42),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _stat(_k(store.subsRevenue), '订阅'),
                    _stat(_k(store.addonRevenue), '增值'),
                    _stat(_k(store.refundTotal), '退款'),
                  ],
                ),
              ],
            )),
          Section(
            '近 6 个月收入',
            AppCard(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  Text(
                    '${months[cur]} · ${money(values[cur])}',
                    style: ts(12, w: FontWeight.w500, color: C.muted, h: 17),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 130,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var i = 0; i < values.length; i++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => sel = i),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 26,
                                    height: 96 * values[i].abs() / top,
                                    decoration: BoxDecoration(
                                      color: i == cur ? C.primary : C.stroke,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(4),
                                        bottomRight: Radius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    months[i],
                                    style: ts(
                                      11,
                                      color: i == cur ? C.ink : C.faint,
                                      h: 16,
                                    ),
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
            '近期订单',
            store.orders.isEmpty
                ? const Empty('还没有已支付的订阅订单')
                : AppListGroup(rows: [
                    for (final o in store.orders.take(8))
                      AppListRow(leading: AppIconTile(
                          icon: o.isRefunded
                              ? Icons.undo_rounded
                              : Icons.receipt_long_outlined,
                          tone: o.isRefunded ? Tone.bad : Tone.ok,
                        ), title: o.merchant, subtitle: '${o.title} · ${md(o.time)}', trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              money(o.paid),
                              style:
                                  ts(
                                    15,
                                    w: FontWeight.w600,
                                    color: o.isRefunded ? C.faint : C.ink,
                                    h: 22,
                                  ).copyWith(
                                    decoration: o.isRefunded
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                            if (o.isRefunded) AppStatusTag('已退款', tone: Tone.bad),
                          ],
                        ), onTap: () => go(context, OrderPage(o))),
                  ]),
          ),
        ],
      );
    },
  );

  Widget _stat(String v, String k) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          v,
          style: ts(
            17,
            w: FontWeight.w600,
            color: const Color(0xFFFAFAFA),
            h: 24,
          ),
        ),
        Text(k, style: ts(11, color: C.faint, h: 16)),
      ],
    ),
  );
}

class OrderPage extends StatelessWidget {
  final Order o;
  const OrderPage(this.o, {super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final t = o.time;
      return AdPage(
        title: '订单详情',
        bottomBar: AppBottomBar(
          secondary: AppButton(
            label: o.isRefunded ? '已退款' : '退款',
            kind: o.isRefunded ? AppButtonKind.secondary : AppButtonKind.danger,
            onPressed: o.isRefunded
                ? null
                : () {
                    if (!store.isSuper) {
                      toast(context, '退款需要超级管理员权限');
                      return;
                    }
                    go(context, RefundPage(o));
                  },
          ),
          primary: AppButton(
            label: '返回',
            kind: AppButtonKind.secondary,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        children: [
          AppCard(
            child: Row(
              children: [
                AppIconTile(
                  icon: o.isRefunded
                      ? Icons.undo_rounded
                      : Icons.receipt_long_outlined,
                  tone: o.isRefunded ? Tone.bad : Tone.ok,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.merchant,
                        style: ts(15, w: FontWeight.w600, h: 22),
                      ),
                      Text(
                        '${md(t)} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} 支付',
                        style: ts(12, color: C.muted, h: 17),
                      ),
                    ],
                  ),
                ),
                o.isRefunded
                    ? AppStatusTag('已退款', tone: Tone.bad)
                    : AppStatusTag('已支付', tone: Tone.ok),
              ],
            ),
          ),
          AppCard(
            child: Column(
              children: [
                KV('套餐', o.title),
                KV('原价', money(o.original)),
                if (o.coupon > 0)
                  KV('新店首购券', '-${money(o.coupon)}', vColor: C.greenInk),
                KV('实付', money(o.paid, decimals: true), bold: true),
                if (o.isRefunded)
                  KV('已退款', '-${money(o.refunded)}', vColor: C.redInk),
                Divider(height: 16, color: C.line),
                KV('订单号', o.id),
                KV('支付方式', o.pay),
                KV('服务周期', o.period),
              ],
            ),
          ),
        ],
      );
    },
  );
}

class RefundPage extends StatefulWidget {
  final Order o;
  const RefundPage(this.o, {super.key});
  @override
  State<RefundPage> createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  late final amount = TextEditingController(text: '${widget.o.paid}');
  String? error;

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final v = int.tryParse(amount.text.trim());
    if (v == null || v <= 0 || v > widget.o.paid) {
      setState(
        () => error = v != null && v > widget.o.paid
            ? '退款金额不能超过实付 ${money(widget.o.paid)}'
            : '请输入退款金额',
      );
      return;
    }
    final ok = await showAppDialog(
      context,
      title: '确认退款',
      message: '将原路退回 ${money(v)} 给「${widget.o.merchant}」，并终止对应订阅周期，操作不可撤销。',
      confirmLabel: '确认退款',
      danger: true,
      onConfirm: () async {
        final err = await store.refund(widget.o, amount.text);
        if (err != null) throw AppError(err);
      },
    );
    if (!ok || !mounted) return;
    toast(context, '已退款 ${money(v)}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '订单退款',
    bottomBar: AppBottomBar(
      secondary: AppButton(
        label: '取消',
        kind: AppButtonKind.secondary,
        onPressed: () => Navigator.pop(context),
      ),
      primary: AppButton(
        label: '确认退款',
        kind: AppButtonKind.danger,
        onPressed: () {
          unawaited(_submit());
        },
      ),
    ),
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIconTile(icon: Icons.info_outline_rounded, tone: Tone.warn),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '退款将原路退回商家，并终止对应订阅周期。',
              style: ts(13, color: C.sub, h: 19),
            ),
          ),
        ],
      ),
      AppCard(
        child: AppTextField(
          label: '退款金额',
          required: true,
          controller: amount,
          prefix: '¥',
          hint: '最多 ${money(widget.o.paid)}',
          keyboard: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          errorText: error,
          onChanged: (_) => setState(() => error = null),
        ),
      ),
    ],
  );
}
