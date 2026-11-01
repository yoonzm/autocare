import 'package:flutter/material.dart';

import '../kit/pickers.dart';
import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class OrderPage extends StatefulWidget {
  final Member? member;
  const OrderPage({super.key, this.member});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _cats = ['常用', '洗车', '镀晶镀膜', '贴膜', '内饰'];
  List<(String, String)> get _pays => [
    ('会员余额', '可用 $_balanceText'),
    ('微信 / 支付宝', '扫码收款'),
    ('现金', '可找零'),
    ('组合支付', '余额 + 其他'),
  ];
  int cat = 0;
  late Member customer = widget.member ?? members.first;
  int pay = 0;
  final Set<int> picked = {0, 1};
  final Set<String> techs = {'李国强 · 镀晶', '王磊 · 洗车'};

  double get subtotal => picked.fold(0, (s, i) => s + orderServices[i].price);
  double get cardOff => picked
      .where((i) => orderServices[i].cardCovered)
      .fold(0, (s, i) => s + orderServices[i].price);
  // 黑金 9 折：次卡抵扣之外的项目
  double get vipOff => (subtotal - cardOff) * 0.1;
  double get payable => subtotal - cardOff - vipOff;

  void checkout() {
    if (picked.isEmpty) {
      toast(context, '请先选择服务项目');
      return;
    }
    openRoute(context, customer.bound ? 'PaySuccess' : 'PayUnbound');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  RoundBtn(
                    'chevronLeft',
                    label: '返回',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      '开单收银',
                      textAlign: TextAlign.center,
                      style: ts(17, w: FontWeight.w600, h: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => openRoute(context, 'HoldList'),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: softShadow,
                      ),
                      child: Row(
                        children: [
                          Text('挂单', style: ts(14, w: FontWeight.w500, h: 20)),
                          const SizedBox(width: 6),
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: C.red,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              '4',
                              style: ts(
                                11,
                                w: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _customer(context),
                  const SizedBox(height: 16),
                  _servicesCard(),
                  const SizedBox(height: 16),
                  _jobCard(),
                  const SizedBox(height: 16),
                  _payCard(),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '应收 · 已优惠 ¥${money(cardOff + vipOff)}',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                        Text(
                          '¥${money(payable, digits: 2)}',
                          style: ts(
                            24,
                            w: FontWeight.w600,
                            h: 30,
                            spacing: -0.4,
                            tabular: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrimaryButton(
                    '挂单',
                    bg: C.chip,
                    fg: C.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () => openRoute(context, 'HoldSheet'),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton('确认收款', onTap: checkout),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _balanceText =>
      customer.amountNote == '余额' ? customer.amount : '¥0';

  Future<void> _pickCustomer() async {
    final m = await pickMember(context, current: customer);
    if (m != null && mounted) setState(() => customer = m);
  }

  Widget _customer(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Avatar(customer.name.substring(0, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(customer.name, style: ts(15, w: FontWeight.w500, h: 22)),
                  LevelBadge(customer.level),
                  PlateTag(customer.plate),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '余额 $_balanceText · ${customer.bound ? '微信已绑定' : '微信未绑定'}',
                style: ts(12, color: C.muted, h: 16),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _pickCustomer,
          child: Text(
            '更换',
            style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
          ),
        ),
      ],
    ),
  );

  Widget _servicesCard() => AppCard(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('服务项目', style: ts(15, w: FontWeight.w600, h: 22)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => cat = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cat == i ? C.btn : C.inset,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _cats[i],
                  style: ts(
                    13,
                    w: FontWeight.w500,
                    color: cat == i ? C.btnFg : C.sub,
                    h: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < orderServices.length; i++)
          if (orderServices[i].cats.contains(_cats[cat])) _serviceRow(i),
      ],
    ),
  );

  Widget _serviceRow(int i) {
    final s = orderServices[i];
    final on = picked.contains(i);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => on ? picked.remove(i) : picked.add(i)),
      child: Container(
        color: on ? C.primarySoft : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name, style: ts(14, w: FontWeight.w500, h: 20)),
                  const SizedBox(height: 3),
                  if (on && s.cardCovered)
                    Row(
                      children: [
                        Text(
                          '¥${s.price}',
                          style: ts(
                            13,
                            color: C.muted,
                            h: 18,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          '次卡抵扣 1 次',
                          bg: C.greenSoft,
                          fg: C.greenInk,
                          size: 11,
                        ),
                      ],
                    )
                  else if (on)
                    Row(
                      children: [
                        Text(
                          '¥${money(s.price)}',
                          style: ts(13, w: FontWeight.w600, h: 18),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          '黑金 9 折',
                          bg: C.amberSoft,
                          fg: C.amberInk,
                          size: 11,
                        ),
                      ],
                    )
                  else
                    Text(
                      '¥${money(s.price)}',
                      style: ts(13, w: FontWeight.w600, h: 18),
                    ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: on ? C.primary : C.chip,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                on ? 'check' : 'add',
                size: 16,
                color: on ? Colors.white : C.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jobCard() {
    const all = ['李国强 · 镀晶', '王磊 · 洗车', '刘洋'];
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('施工安排', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in all)
                GestureDetector(
                  onTap: () => setState(
                    () => techs.contains(t) ? techs.remove(t) : techs.add(t),
                  ),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: techs.contains(t) ? C.primarySoft : C.inset,
                      borderRadius: BorderRadius.circular(18),
                      border: techs.contains(t)
                          ? Border.all(color: C.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Avatar(
                          t.substring(0, 1),
                          size: 28,
                          bg: C.card,
                          fg: C.ink,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t,
                          style: ts(
                            13,
                            w: FontWeight.w500,
                            color: techs.contains(t) ? C.primaryInk : C.sub,
                            h: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kv('工位', '2 号工位')),
              const SizedBox(width: 8),
              Expanded(child: _kv('预计完工', '今天 15:30')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: C.inset,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: ts(12, color: C.muted, h: 16)),
        Text(v, style: ts(14, w: FontWeight.w500, h: 20)),
      ],
    ),
  );

  Widget _payCard() => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('结算', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 12),
        _line('项目合计', '¥${money(subtotal, digits: 2)}'),
        if (cardOff > 0)
          _line(
            '次卡抵扣 · 精致洗车 1 次',
            '-¥${money(cardOff, digits: 2)}',
            green: true,
          ),
        if (vipOff > 0)
          _line('黑金会员 9 折', '-¥${money(vipOff, digits: 2)}', green: true),
        const SizedBox(height: 4),
        const Divider1(),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: [
            for (var i = 0; i < _pays.length; i++)
              GestureDetector(
                onTap: () => setState(() => pay = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: pay == i ? C.btn : C.inset,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pays[i].$1,
                        style: ts(
                          14,
                          w: FontWeight.w500,
                          color: pay == i ? C.btnFg : C.ink,
                          h: 20,
                        ),
                      ),
                      Text(
                        _pays[i].$2,
                        style: ts(
                          12,
                          color: pay == i ? C.faint : C.muted,
                          h: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _line(String k, String v, {bool green = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: ts(13, color: C.sub, h: 18)),
        ),
        Text(
          v,
          style: ts(
            13,
            color: green ? C.greenInk : C.ink,
            h: 18,
            tabular: true,
          ),
        ),
      ],
    ),
  );
}
