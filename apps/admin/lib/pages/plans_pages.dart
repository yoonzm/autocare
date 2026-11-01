import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

List<String> planFeatures(PlanInfo p) => [
  if (p.kind == PlanKind.trial) '试用 ${p.trialDays} 天，功能同基础版',
  p.staffLimit == null ? '员工数不限' : '员工数 ≤ ${p.staffLimit}',
  if (p.kind != PlanKind.trial) '会员与开单收银',
  if (p.sms) '预约与短信通知',
  if (p.export) '数据导出与备份',
  if (p.multiStore) '多门店管理',
  if (p.kind == PlanKind.trial) '到期自动提醒',
];

class PlansPage extends StatelessWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => AdPage(
      title: '套餐管理',
      children: [
        if (!store.isSuper)
          Text('套餐定价仅超级管理员可修改', style: ts(13, color: C.sub, h: 18)),
        for (final (i, p) in store.plans.indexed)
          HCard(
            onTap: () {
              if (!store.isSuper) {
                toast(context, '仅超级管理员可修改套餐');
                return;
              }
              go(context, PlanEditPage(p));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ToneTile([1, 3, 0][i], Icons.workspace_premium_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: ts(16, w: FontWeight.w600, h: 24)),
                          Text(
                            p.kind == PlanKind.trial
                                ? '${p.merchants} 家商家在试用'
                                : '${p.merchants} 家商家在用',
                            style: ts(12, color: C.muted, h: 17),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      p.kind == PlanKind.trial ? '${p.trialDays} 天免费' : '${money(p.fee)} / 年',
                      style: ts(15, w: FontWeight.w600, h: 22),
                    ),
                    if (store.isSuper) Icon(Icons.chevron_right_rounded, size: 20, color: C.faint),
                  ],
                ),
                const SizedBox(height: 12),
                for (final f in planFeatures(p))
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: C.green),
                        const SizedBox(width: 8),
                        Text(f, style: ts(13, color: C.sub, h: 19)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class PlanEditPage extends StatefulWidget {
  final PlanInfo p;
  const PlanEditPage(this.p, {super.key});
  @override
  State<PlanEditPage> createState() => _PlanEditPageState();
}

class _PlanEditPageState extends State<PlanEditPage> {
  late final name = TextEditingController(text: widget.p.name);
  late final fee = TextEditingController(
    text: '${widget.p.kind == PlanKind.trial ? widget.p.trialDays : widget.p.fee}',
  );
  late final staff = TextEditingController(text: widget.p.staffLimit?.toString() ?? '');
  late bool sms = widget.p.sms;
  late bool export = widget.p.export;
  late bool multi = widget.p.multiStore;
  String? error;

  @override
  void dispose() {
    name.dispose();
    fee.dispose();
    staff.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final err = store.savePlan(
      widget.p,
      name: name.text,
      fee: fee.text,
      staff: staff.text,
      sms: sms,
      export: export,
      multi: multi,
    );
    setState(() => error = err);
    if (err != null) return;
    toast(context, '套餐已保存');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trial = widget.p.kind == PlanKind.trial;
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return AdPage(
      title: '编辑套餐',
      dock: Btn('保存', onTap: _save),
      children: [
        HCard(
          child: Column(
            children: [
              Field(label: '套餐名称', required: true, controller: name),
              const SizedBox(height: 14),
              Field(
                label: trial ? '试用天数' : '年费（元）',
                required: true,
                controller: fee,
                keyboard: TextInputType.number,
                formatters: digits,
              ),
              const SizedBox(height: 14),
              Field(
                label: '员工数上限',
                controller: staff,
                hint: '留空表示不限',
                keyboard: TextInputType.number,
                formatters: digits,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(error!, style: ts(12, color: C.redInk, h: 17)),
                  ),
                ),
            ],
          ),
        ),
        Section(
          '功能开关',
          RowGroup(indent: 16, [
            _sw('预约与短信通知', sms, (v) => setState(() => sms = v)),
            _sw('数据导出与备份', export, (v) => setState(() => export = v)),
            _sw('多门店管理', multi, (v) => setState(() => multi = v)),
          ]),
        ),
      ],
    );
  }

  Widget _sw(String t, bool v, ValueChanged<bool> on) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    child: Row(
      children: [
        Expanded(child: Text(t, style: ts(15, w: FontWeight.w500, h: 22))),
        Switch1(v, on),
      ],
    ),
  );
}
