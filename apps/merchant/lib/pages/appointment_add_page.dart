import 'package:flutter/material.dart';

import '../kit/kit.dart';
import '../mock/mock_data.dart';
import '../kit/keyboard.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class AppointmentAddPage extends StatefulWidget {
  const AppointmentAddPage({super.key});
  @override
  State<AppointmentAddPage> createState() => _AppointmentAddPageState();
}

class _AppointmentAddPageState extends State<AppointmentAddPage> {
  bool isMember = true;
  final Set<int> picked = {2};
  int dateIdx = 0;
  String time = '17:30';
  int station = 3;
  String tech = '老周';
  bool notify = true;
  bool remind = true;
  bool deposit = false;
  static const _bays = [
    '1 号工位 · 空闲',
    '2 号工位 · 施工中',
    '3 号工位 · 施工中',
    '4 号工位 · 空闲（推荐）',
    '5 号工位 · 空闲',
  ];
  static const _techs = ['老周', '小陈', '张师傅'];
  String get _bayLabel => _bays[station];
  static const _hoursOf = [0.5, 1.0, 1.5, 1.5, 3.0, 6.0];
  double get hours => picked.fold(0.0, (s, i) => s + _hoursOf[i]);
  String get hoursText => hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toString();

  static const _dates = ['今天 10.31', '明天 11.01', '周一 11.02', '周二 11.03'];
  static const _times = [
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
  ];
  static const _disabled = {
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
  };

  Member customer = members[5]; // 刘先生

  Future<void> _pickCustomer() async {
    final m = await pickMember(context, current: customer);
    if (m != null && mounted) setState(() => customer = m);
  }

  int get total => picked.fold(0, (s, i) => s + apptServices[i].price);

  void submit() {
    if (picked.isEmpty) {
      toast(context, '请至少选择一个服务项目');
      return;
    }
    appointmentStore.add(
      Appointment(
        time,
        '$hoursText 小时',
        customer.plate,
        isMember ? customer.name : '散客',
        isMember ? customer.level : '散客',
        picked.map((i) => apptServices[i].name).join(' · '),
        '${station + 1} 号工位 · $tech',
        ApptStatus.waiting,
      ),
    );
    Navigator.of(context).pop();
    toast(context, '预约成功，已通知客户');
  }

  Future<void> _pickBay() async {
    final r = await pickFromList(context, '选择工位', _bays, _bayLabel);
    if (r != null && mounted) setState(() => station = _bays.indexOf(r));
  }

  Future<void> _pickTech() async {
    final r = await pickFromList(context, '选择技师', _techs, tech);
    if (r != null && mounted) setState(() => tech = r);
  }

  String get _endTime {
    final p = time.split(':');
    var m = int.parse(p[0]) * 60 + int.parse(p[1]) + (hours * 60).round();
    return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SubHeader('新建预约', close: true),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _customerCard(),
                  const SizedBox(height: 16),
                  _servicesCard(),
                  const SizedBox(height: 16),
                  _timeCard(),
                  const SizedBox(height: 16),
                  _sectionLabel('安排'),
                  AppCard(
                    radius: 24,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _pickRow('工位', _bayLabel, _pickBay),
                        const Divider1(indent: 16),
                        _pickRow('技师', tech, _pickTech),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    radius: 24,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '备注',
                                style: ts(14, w: FontWeight.w600, h: 20),
                              ),
                              TextSpan(
                                text: ' · 选填',
                                style: ts(14, color: C.muted, h: 20),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: C.inset,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            onTapOutside: onTapOutsideDismiss,
                            minLines: 2,
                            maxLines: 4,
                            style: ts(14, h: 20),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              hintText: '如：车身有划痕、需要提前洗车',
                              hintStyle: ts(14, color: C.muted, h: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionLabel('通知与定金'),
                  AppCard(
                    radius: 24,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _switch(
                          '预约成功后通知客户',
                          '微信优先，失败转短信',
                          notify,
                          (v) => setState(() => notify = v),
                        ),
                        const Divider1(indent: 16),
                        _switch(
                          '到店前 2 小时提醒客户',
                          '按"通知与消息"设置发送',
                          remind,
                          (v) => setState(() => remind = v),
                        ),
                        const Divider1(indent: 16),
                        _switch(
                          '收取预约定金',
                          '客户爽约将不予退还 · ¥50',
                          deposit,
                          (v) => setState(() => deposit = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottom > 0 ? bottom - 4 : 16,
              ),
              decoration: BoxDecoration(
                color: C.card.withValues(alpha: 0.94),
                border: Border(top: BorderSide(color: C.stroke)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '10.31 今天 $time · ${station + 1} 号工位',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '预计 ¥${money(total)}',
                          style: ts(20, w: FontWeight.w600, h: 26),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: submit,
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: C.btn,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        '确认预约',
                        style: ts(
                          15,
                          w: FontWeight.w600,
                          color: C.btnFg,
                          h: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String t) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      t,
      style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
    ),
  );

  Widget _customerCard() => AppCard(
    radius: 24,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('客户', style: ts(15, w: FontWeight.w600, h: 22)),
            ),
            SizedBox(
              width: 132,
              child: Segmented(
                labels: const ['会员', '散客'],
                selected: isMember ? 0 : 1,
                onChanged: (i) => setState(() => isMember = i == 0),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isMember)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _pickCustomer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: C.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      customer.name.substring(0, 1),
                      style: ts(16, w: FontWeight.w600, color: C.onGold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              customer.name,
                              style: ts(15, w: FontWeight.w600, h: 22),
                            ),
                            const SizedBox(width: 6),
                            _levelTag(customer.level),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${customer.phone.substring(0, 3)} **** ${customer.phone.substring(7)} · ${customer.amountNote == '余额' ? '余额 ${customer.amount}' : customer.amountNote}',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                      ],
                    ),
                  ),
                  AppIcon('chevronRight', size: 16, color: C.faint),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: C.inset,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              '散客预约：到店后登记车牌与联系方式',
              style: ts(13, color: C.muted, h: 18),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(
            children: [
              Text('车辆', style: ts(14, color: C.sub, h: 20)),
              const Spacer(),
              if (isMember) ...[
                _plateSmall(customer.plate),
                const SizedBox(width: 12),
                Text('大众 帕萨特 · 灰', style: ts(14, h: 20)),
              ] else
                Text('到店填写', style: ts(14, color: C.muted, h: 20)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _plateSmall(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFF0B5FD6),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFF5B9BF0), width: 1.5),
    ),
    child: Text(
      t,
      style: ts(11, w: FontWeight.w600, color: Colors.white, h: 16),
    ),
  );

  Widget _levelTag(String level) {
    final black = level == '黑金';
    final gold = level == '金卡';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: black ? C.pill : (gold ? C.gold : C.chip),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        level,
        style: ts(
          11,
          w: FontWeight.w600,
          color: black ? C.gold : (gold ? C.onGold : C.sub),
          h: 18,
        ),
      ),
    );
  }

  Widget _servicesCard() => AppCard(
    radius: 24,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '服务项目 ',
                      style: ts(15, w: FontWeight.w600, h: 22),
                    ),
                    TextSpan(
                      text: '· 可多选',
                      style: ts(15, color: C.muted, h: 22),
                    ),
                  ],
                ),
              ),
            ),
            Text('预计 $hoursText 小时', style: ts(13, color: C.muted, h: 18)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < apptServices.length; i++)
              _chip(
                '${apptServices[i].name} ¥${money(apptServices[i].price)}',
                picked.contains(i),
                () => setState(
                  () => picked.contains(i) ? picked.remove(i) : picked.add(i),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _timeCard() => AppCard(
    radius: 24,
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('到店时间', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _dates.length; i++)
              _chip(_dates[i], dateIdx == i, () => setState(() => dateIdx = i)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text('灰色为已过去或已约满', style: ts(12, color: C.muted, h: 16)),
            const Spacer(),
            Text(
              '$time – $_endTime',
              style: ts(12, w: FontWeight.w600, color: C.primaryInk, h: 16),
            ),
          ],
        ),
        const SizedBox(height: 12),
        for (var r = 0; r < 3; r++) ...[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (var c = 0; c < 4; c++) ...[
                if (c > 0) const SizedBox(width: 8),
                Expanded(child: _slot(_times[r * 4 + c])),
              ],
            ],
          ),
        ],
      ],
    ),
  );

  Widget _slot(String t) {
    final off = _disabled.contains(t);
    final on = time == t;
    return GestureDetector(
      onTap: off ? null : () => setState(() => time = t),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? C.primarySoft : C.inset,
          borderRadius: BorderRadius.circular(12),
          border: on ? Border.all(color: C.primary, width: 1.5) : null,
        ),
        child: Text(
          t,
          style: ts(
            14,
            w: FontWeight.w500,
            color: off ? C.faint : (on ? C.primaryInk : C.ink),
            h: 20,
            tabular: true,
          ).copyWith(decoration: off ? TextDecoration.lineThrough : null),
        ),
      ),
    );
  }

  Widget _pickRow(String label, String value, VoidCallback onTap) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(label, style: ts(14, color: C.sub, h: 20)),
              ),
              Text(value, style: ts(15, h: 22)),
              const SizedBox(width: 12),
              AppIcon('chevronRight', size: 16, color: C.faint),
            ],
          ),
        ),
      );

  Widget _chip(String t, bool on, VoidCallback? tap) => GestureDetector(
    onTap: tap,
    child: Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: on ? C.primarySoft : C.inset,
        borderRadius: BorderRadius.circular(17),
        border: on ? Border.all(color: C.primary, width: 1.5) : null,
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          t,
          style: ts(
            13,
            w: FontWeight.w500,
            color: on ? C.primaryInk : C.sub,
            h: 18,
          ),
        ),
      ),
    ),
  );

  Widget _switch(String t, String sub, bool v, ValueChanged<bool> f) =>
      Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: ts(14, h: 20)),
                  Text(sub, style: ts(12, color: C.muted, h: 16)),
                ],
              ),
            ),
            HSwitchValue(value: v, onChanged: f),
          ],
        ),
      );
}
