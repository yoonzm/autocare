import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

String _k(int v) => v >= 10000 ? '¥${(v / 10000).toStringAsFixed(1)}万' : '¥${(v / 1000).toStringAsFixed(1)}k';

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
      final months = ['6月', '7月', '8月', '9月', '10月', '11月'];
      final top = values.reduce((a, b) => a > b ? a : b);
      final cur = sel ?? values.length - 1;
      return AdPage(
        title: '订阅与收入',
        back: false,
        children: [
          DarkHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('本月收入（元）', style: ts(13, w: FontWeight.w500, color: C.faint, h: 19)),
                    const Spacer(),
                    const Pill('↑ 8.2%', Color(0xFF6EE7A8), Color(0x3317C964)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(money(store.monthRevenue), style: ts(34, w: FontWeight.w600, color: C.gold, h: 42)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _stat(_k(store.subsRevenue), '订阅'),
                    _stat(_k(store.addonRevenue), '增值'),
                    _stat(_k(store.refundTotal), '退款'),
                  ],
                ),
              ],
            ),
          ),
          Section(
            '近 6 个月收入',
            HCard(
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
                                    height: 96 * values[i] / top,
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
                                    style: ts(11, color: i == cur ? C.ink : C.faint, h: 16),
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
            RowGroup([
              for (final o in store.orders.take(8))
                Row1(
                  leading: SoftTile(
                    o.isRefunded ? Icons.undo_rounded : Icons.receipt_long_outlined,
                    o.isRefunded ? C.redInk : C.greenInk,
                    o.isRefunded ? C.redSoft : C.greenSoft,
                  ),
                  title: o.merchant,
                  sub: '${o.title} · ${md(o.time)}',
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        money(o.paid),
                        style: ts(15, w: FontWeight.w600, color: o.isRefunded ? C.faint : C.ink, h: 22).copyWith(
                          decoration: o.isRefunded ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (o.isRefunded) const Pill('已退款', C.redInk, C.redSoft),
                    ],
                  ),
                  onTap: () => go(context, OrderPage(o)),
                ),
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
        Text(v, style: ts(17, w: FontWeight.w600, color: const Color(0xFFFAFAFA), h: 24)),
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
        dock: Row(
          children: [
            Expanded(
              flex: 5,
              child: Btn(
                o.isRefunded ? '已退款' : '退款',
                soft: !o.isRefunded,
                ghost: o.isRefunded,
                onTap: o.isRefunded
                    ? null
                    : () {
                        if (!store.isSuper) {
                          toast(context, '退款需要超级管理员权限');
                          return;
                        }
                        go(context, RefundPage(o));
                      },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(flex: 7, child: Btn('返回', ghost: true, onTap: () => Navigator.pop(context))),
          ],
        ),
        children: [
          HCard(
            child: Row(
              children: [
                SoftTile(
                  o.isRefunded ? Icons.undo_rounded : Icons.receipt_long_outlined,
                  o.isRefunded ? C.redInk : C.greenInk,
                  o.isRefunded ? C.redSoft : C.greenSoft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o.merchant, style: ts(15, w: FontWeight.w600, h: 22)),
                      Text(
                        '${md(t)} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} 支付',
                        style: ts(12, color: C.muted, h: 17),
                      ),
                    ],
                  ),
                ),
                o.isRefunded
                    ? const Pill('已退款', C.redInk, C.redSoft)
                    : const Pill('已支付', C.greenInk, C.greenSoft),
              ],
            ),
          ),
          HCard(
            child: Column(
              children: [
                KV('套餐', o.title),
                KV('原价', money(o.original)),
                if (o.coupon > 0) KV('新店首购券', '-${money(o.coupon)}', vColor: C.greenInk),
                KV('实付', '${money(o.paid)}.00', bold: true),
                if (o.isRefunded) KV('已退款', '-${money(o.refunded)}', vColor: C.redInk),
                const Divider(height: 16, color: C.line),
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
      setState(() => error = v != null && v > widget.o.paid
          ? '退款金额不能超过实付 ${money(widget.o.paid)}'
          : '请输入退款金额');
      return;
    }
    final ok = await confirm(
      context,
      title: '确认退款',
      message: '将原路退回 ${money(v)} 给「${widget.o.merchant}」，并终止对应订阅周期，操作不可撤销。',
      ok: '确认退款',
      danger: true,
    );
    if (!ok || !mounted) return;
    final err = store.refund(widget.o, amount.text);
    if (err != null) {
      setState(() => error = err);
      return;
    }
    toast(context, '已退款 ${money(v)}');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '订单退款',
    dock: Row(
      children: [
        Expanded(flex: 5, child: Btn('取消', ghost: true, onTap: () => Navigator.pop(context))),
        const SizedBox(width: 10),
        Expanded(flex: 7, child: Btn('确认退款', danger: true, onTap: _submit)),
      ],
    ),
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SoftTile(Icons.info_outline_rounded, C.amberInk, C.amberSoft, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '退款将原路退回商家，并终止对应订阅周期。',
              style: ts(13, color: C.sub, h: 19),
            ),
          ),
        ],
      ),
      HCard(
        child: Field(
          label: '退款金额',
          required: true,
          controller: amount,
          prefix: '¥',
          hint: '最多 ${money(widget.o.paid)}',
          keyboard: TextInputType.number,
          formatters: [FilteringTextInputFormatter.digitsOnly],
          error: error,
          onChanged: (_) => setState(() => error = null),
        ),
      ),
    ],
  );
}
