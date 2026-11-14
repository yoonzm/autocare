import '../members/member_picker_sheet.dart' show showMemberPicker;

import 'dart:async';

import '../../backend/appointment_flow.dart';
import '../../backend/mutation_request.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';
import '../../backend/member_flow.dart';
import '../../backend/service_store.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart';
import 'booking_resources_page.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../members/member_models.dart' show Member;
import '../../kit/keyboard.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';
import '../../widgets/choice_chip_group.dart';

class AppointmentAddPage extends StatefulWidget {
  const AppointmentAddPage({super.key});
  @override
  State<AppointmentAddPage> createState() => _AppointmentAddPageState();
}

class _AppointmentAddPageState extends State<AppointmentAddPage> {
  final _actionKey = 'appointment-add:${UniqueKey()}';
  final _write = MutationRequest();
  final _today = bookingToday;
  Timer? _optionsTimer;
  bool _slotsPending = false;
  bool isMember = true;
  final Set<int> picked = {};
  int dateIdx = 0;
  String time = '';
  Map<String, dynamic>? _bay, _tech;
  Map<String, dynamic> _options = {};
  List<Map<String, dynamic>> get _services => List<Map<String, dynamic>>.from(
    _options['services'] as List? ?? ServiceStore.sellable,
  );
  List<Map<String, dynamic>> get _resources =>
      List<Map<String, dynamic>>.from(_options['resources'] as List? ?? []);
  final _slotsKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  bool _optionsLoading = false;
  bool _optionsReady = false;
  bool _showOptionsSkeleton = false;
  AppError? _optionsError;
  List<Map<String, dynamic>> _slots = [];
  final _note = TextEditingController();
  bool _busy = false;
  bool _awaitPicker = false;
  bool _dirty = false;
  int _revision = 0;
  bool notify = false, remind = false;
  String get tech => '${_tech?['name'] ?? '暂不指定'}';
  String get _bayLabel => '${_bay?['name'] ?? '暂不指定'}';
  int get minutes => picked.fold(
    0,
    (s, i) => s + (_services[i]['duration_minutes'] as num).toInt(),
  );
  double get hours => minutes / 60;
  String get hoursText => hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toString();
  DateTime get _date => _today.add(Duration(days: dateIdx));
  List<String> get _dates => [
    for (var i = 0; i < 4; i++)
      '${i == 0
          ? '今天'
          : i == 1
          ? '明天'
          : '周${'一二三四五六日'[_today.add(Duration(days: i)).weekday - 1]}'} ${_today.add(Duration(days: i)).month.toString().padLeft(2, '0')}.${_today.add(Duration(days: i)).day.toString().padLeft(2, '0')}',
  ];
  Member customer = const Member('请选择会员', '', '', '未选择', '—', '', {});

  Future<void> _loadOptions() async {
    if (_optionsLoading) return;
    setState(() {
      _optionsLoading = true;
      _showOptionsSkeleton = false;
      _optionsError = null;
    });
    DateTime? shownAt;
    final timer = _optionsTimer = Timer(kIndicatorDelay, () {
      if (mounted && _optionsLoading && !_optionsReady) {
        setState(() => _showOptionsSkeleton = true);
        shownAt = DateTime.now();
      }
    });
    Map<String, dynamic>? data;
    AppError? failed;
    try {
      data = dataSnapshot(await merchantApi.appointment('options'));
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    if (shownAt != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(shownAt!);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted) return;
    final oldServices = _services;
    final selectedIds = {
      for (final i in picked)
        if (i < oldServices.length) oldServices[i]['id'],
    };
    setState(() {
      _optionsLoading = false;
      _showOptionsSkeleton = false;
      if (failed == null) {
        _options = data!;
        _optionsReady = true;
        _optionsError = null;
        picked
          ..clear()
          ..addAll([
            for (var i = 0; i < _services.length; i++)
              if (selectedIds.contains(_services[i]['id'])) i,
          ]);
      } else if (!_optionsReady) {
        _optionsError = failed;
      }
    });
    if (failed != null && _optionsReady) AppToast.error(context, failed);
  }

  Future<void> _pickCustomer() async {
    if (_awaitPicker) return;
    _awaitPicker = true;
    try {
      final row = await showMemberPicker(context);
      if (mounted && row != null) {
        setState(() {
          customer = memberFromRow(row);
          _dirty = true;
        });
      }
    } finally {
      _awaitPicker = false;
    }
  }

  num get total =>
      picked.fold<num>(0, (s, i) => s + (_services[i]['price'] as num)) *
      (isMember
          ? ((customer.data?['card'] as Map?)?['discount'] as num? ?? 1)
          : 1);
  void _changed() {
    _dirty = true;
    _revision++;
    if (_slotsKey.currentState?.busy == true) {
      _slotsPending = true;
    } else {
      _slotsPending = false;
      _slotsKey.currentState?.reload();
    }
  }

  Future<Map<String, dynamic>> _loadSlots() async {
    while (true) {
      if (!mounted) throw StateError('页面已关闭');
      final version = _revision;
      if (picked.isEmpty) {
        _slotsPending = false;
        return {'slots': [], '_revision': version};
      }
      try {
        final result = await merchantApi.appointment('slots', {
          'day': bookingDay(_date),
          'service_ids': [for (final i in picked) _services[i]['id']],
          'bay_id': _bay?['id'],
          'technician_id': _tech?['id'],
        });
        if (version == _revision) {
          _slotsPending = false;
          return {...result, '_revision': version};
        }
      } catch (e) {
        if (version == _revision) rethrow;
      }
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (isMember && customer.id == null) {
      AppToast.show(context, '请选择会员或切换散客');
      return;
    }
    if (picked.isEmpty) {
      AppToast.show(context, '请至少选择一个服务项目');
      return;
    }
    if (_slotsKey.currentState?.busy == true) {
      AppToast.show(context, '正在读取可预约时段，请稍后提交');
      return;
    }
    if (time.isEmpty) {
      AppToast.show(context, '请选择可预约时段');
      return;
    }
    setState(() => _busy = true);
    try {
      await runBusy(_actionKey, () async {
        await _write.send({
          'action': 'appointment_save',
          'member_id': isMember ? customer.id : null,
          'service_ids': [for (final i in picked) _services[i]['id']],
          'starts_at': '${bookingDay(_date)}T$time:00+08:00',
          'bay_id': _bay?['id'],
          'technician_id': _tech?['id'],
          'note': _note.text.trim(),
        });
      });
      AppointmentFlow.notify();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        AppToast.showOn(messenger, '预约已保存', kind: ToastKind.success);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, e);
        _changed();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void submit() => unawaited(_submit());
  Future<void> _pickResource(String kind) async {
    if (!_optionsReady) {
      AppToast.show(context, '工位和技师资料尚未加载完成');
      return;
    }
    final rows = _resources
        .where((r) => r['kind'] == kind && r['active'] == true)
        .toList();
    final label = kind == 'bay' ? '工位' : '技师';
    final current = kind == 'bay' ? _bay : _tech;
    final selected = await pickValue<int>(
      context,
      '选择$label',
      [for (var i = 0; i <= rows.length; i++) i],
      rows.indexWhere((r) => r['id'] == current?['id']) + 1,
      (i) => i == 0 ? '暂不指定' : '${rows[i - 1]['name']}',
    );
    if (selected == null || !mounted) return;
    setState(() {
      final value = selected == 0 ? null : rows[selected - 1];
      if (kind == 'bay') {
        _bay = value;
        if (value?['linked_id'] != null && _tech == null) {
          _tech = _resources
              .where(
                (r) => r['id'] == value!['linked_id'] && r['active'] == true,
              )
              .firstOrNull;
        }
      } else {
        _tech = value;
        if (value?['linked_id'] != null) {
          _bay = _resources
              .where(
                (r) => r['id'] == value!['linked_id'] && r['active'] == true,
              )
              .firstOrNull;
        }
      }
      time = '';
    });
    _changed();
  }

  Future<void> _pickBay() => _pickResource('bay');
  Future<void> _pickTech() => _pickResource('technician');
  @override
  void initState() {
    super.initState();
    if (merchantApi.hasSession) unawaited(_loadOptions());
    _note.addListener(() {
      if (mounted) setState(() => _dirty = true);
    });
  }

  @override
  void dispose() {
    _optionsTimer?.cancel();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return ConfirmDiscard(
      busy: _busy,
      dirty: _dirty,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SubHeader('新建预约', close: true),
              Expanded(child: _form()),
            ],
          ),
        ),
      ),
    );
  }

  String get _endTime {
    if (time.isEmpty) return '—';
    final p = time.split(':');
    var m = int.parse(p[0]) * 60 + int.parse(p[1]) + (hours * 60).round();
    return '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';
  }

  Widget _form() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return AbsorbPointer(
      absorbing: _busy,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
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
                              controller: _note,
                              readOnly: _busy,
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
                    _sectionLabel('通知'),
                    AppCard(
                      radius: 24,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          _switch(
                            '预约成功后通知客户',
                            '微信优先，失败转短信',
                            notify,
                            (v) => AppToast.show(
                              context,
                              'TODO：微信／短信通知尚未接通，未发送通知',
                            ),
                          ),
                          const Divider1(indent: 16),
                          _switch(
                            '到店前 2 小时提醒客户',
                            '按"通知与消息"设置发送',
                            remind,
                            (v) => AppToast.show(context, 'TODO：预约提醒服务尚未接通'),
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
                            '${_date.month}.${_date.day} ${time.isEmpty ? '请选择时间' : time} · $_bayLabel',
                            style: ts(12, color: C.muted, h: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '预计 ¥${total.toStringAsFixed(2)}',
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
                        child: hBusy(
                          _actionKey,
                          Text(
                            '确认预约',
                            style: ts(
                              15,
                              w: FontWeight.w600,
                              color: C.btnFg,
                              h: 22,
                            ),
                          ),
                          style: ts(
                            15,
                            w: FontWeight.w600,
                            color: C.btnFg,
                            h: 22,
                          ),
                          label: '提交中…',
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
                onChanged: (i) => setState(() {
                  isMember = i == 0;
                  _dirty = true;
                }),
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
                          customer.phone.length == 11
                              ? '${customer.phone.substring(0, 3)} **** ${customer.phone.substring(7)}'
                              : '请选择预约会员',
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
                Text(
                  '${((customer.data?['vehicles'] as List?)?.firstOrNull as Map?)?['brand_model'] ?? '—'}',
                  style: ts(14, h: 20),
                ),
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
        if (_services.isEmpty &&
            !_optionsReady &&
            ServiceStore.items == null &&
            _optionsError == null)
          SizedBox(
            height: 36,
            child: _showOptionsSkeleton && _optionsError == null
                ? const Row(
                    children: [
                      AppSkeleton(width: 112, height: 34, radius: 17),
                      SizedBox(width: 8),
                      AppSkeleton(width: 96, height: 34, radius: 17),
                    ],
                  )
                : const SizedBox.shrink(),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _services.length; i++)
                _chip(
                  '${_services[i]['name']} ¥${_services[i]['price']}',
                  picked.contains(i),
                  () {
                    setState(() {
                      picked.contains(i) ? picked.remove(i) : picked.add(i);
                      time = '';
                    });
                    _changed();
                  },
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
        ChoiceChipGroup<int>(
          semanticLabel: '到店日期',
          kind: ChipKind.pill,
          items: [
            for (var i = 0; i < _dates.length; i++)
              ChoiceChipItem(value: i, label: _dates[i]),
          ],
          selected: dateIdx,
          onChanged: (i) {
            if (dateIdx == i) return;
            setState(() {
              dateIdx = i;
              time = '';
            });
            _changed();
          },
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
        if (!_optionsReady)
          SizedBox(
            height: 136,
            child: _optionsError != null
                ? ErrorView(
                    inline: true,
                    error: _optionsError!,
                    retrying: _optionsLoading,
                    onRetry: _loadOptions,
                  )
                : _showOptionsSkeleton
                ? const AppSkeleton(height: 120, radius: 12)
                : const SizedBox.shrink(),
          )
        else if (!_resources.any(
          (r) => r['kind'] == 'bay' && r['active'] == true,
        ))
          EmptyView(
            title: '还没有可预约工位',
            message: '先添加真实工位，再安排预约',
            actionLabel: '添加工位',
            inline: true,
            onAction: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BusinessHoursPage()),
              );
              if (mounted) {
                await _loadOptions();
                _changed();
              }
            },
          )
        else
          SizedBox(
            height: 136,
            child: AsyncView<Map<String, dynamic>>(
              key: _slotsKey,
              inlineError: true,
              load: _loadSlots,
              isEmpty: (_) => false,
              skeletonPadding: EdgeInsets.zero,
              skeleton: const AppSkeleton(height: 120, radius: 12),
              empty: (_) => const SizedBox.shrink(),
              onSettled: () {
                if (_slotsPending && mounted) {
                  _slotsPending = false;
                  _slotsKey.currentState?.reload();
                }
              },
              onLoaded: (data) => setState(() {
                if (data['_revision'] != _revision) {
                  _slotsPending = true;
                  _slots = [];
                  return;
                }
                _slots = List<Map<String, dynamic>>.from(data['slots'] as List);
                if (!_slots.any(
                  (s) => s['time'] == time && s['available'] == true,
                )) {
                  time = '';
                }
              }),
              builder: (_, data) => AbsorbPointer(
                absorbing: _slotsKey.currentState?.busy == true,
                child: SingleChildScrollView(
                  child: _slots.isEmpty
                      ? EmptyView(
                          title: picked.isEmpty ? '请先选择服务项目' : '所选日期没有可预约时段',
                          inline: true,
                        )
                      : ChoiceChipGroup<String>(
                          semanticLabel: '到店时间',
                          kind: ChipKind.tile,
                          items: [
                            for (final slot in _slots)
                              ChoiceChipItem(
                                value: slot['time'] as String,
                                label: slot['time'] as String,
                                disabled: slot['available'] != true,
                              ),
                          ],
                          selected: time.isEmpty ? null : time,
                          onChanged: (value) => setState(() {
                            time = value;
                            _dirty = true;
                          }),
                        ),
                ),
              ),
            ),
          ),
      ],
    ),
  );

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
