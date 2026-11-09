import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/appointment_flow.dart';
import '../backend/staff_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show SelCtrl, ValCtrl, HSwitchValue, hConfirm, dk;
import '../kit/pickers.dart';
import 'choice_chip_group.dart';

/// 既有设计模板的非视觉绑定层；不向模板注入示例业务数据。
class BookingTemplateController extends ChangeNotifier {
  final Map<String, dynamic> options;
  final String mode;
  late final Map<String, dynamic> settings =
      Map<String, dynamic>.from(options['settings'] as Map)
        ..update('opens_at', (v) => '$v'.substring(0, 5))
        ..update('closes_at', (v) => '$v'.substring(0, 5));
  late final Map<String, dynamic> draft = {
    'name': '',
    'phone': '',
    'category': '',
    'active': true,
    'position': 0,
    'linked_id': null,
    'joined_on': bookingDay(bookingToday),
    if (isStaff) 'role': StaffFlow.takePresetRole() ?? 'technician',
    ...?_initial,
    // 员工的擅长项目 / 固定工位沿用表单控件原有的草稿键
    if (isStaff) 'category': '${_initial?['skills'] ?? ''}',
    if (isStaff) 'linked_id': _initial?['bay_id'],
  };
  bool get isStaff => mode == 'staff' || mode == 'staff_list';
  final Map<String, dynamic>? _initial;
  int filter = 0;
  bool showInactive = false;
  bool busy = false;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool dirty = false;
  String activeButton = '';
  Appointment? booking;
  int? rescheduleDay;
  String selectedTime = '';
  int? cancelReason;
  String dateLabel(int i) {
    final day = bookingToday.add(Duration(days: i));
    return '${i == 0
        ? '今天'
        : i == 1
        ? '明天'
        : '周${'一二三四五六日'[day.weekday - 1]}'} ${day.month.toString().padLeft(2, '0')}.${day.day.toString().padLeft(2, '0')}';
  }

  BookingTemplateController(this.options, this.mode, [this._initial]);
  List<Map<String, dynamic>> get resources => isStaff
      ? [
          for (final b in (options['bays'] as List? ?? const []))
            {...Map<String, dynamic>.from(b as Map), 'kind': 'bay', 'active': true},
        ]
      : List<Map<String, dynamic>>.from(options['resources'] as List);
  static const _roleFilter = [null, 'manager', 'cashier', 'technician'];
  List<Map<String, dynamic>> get staffRows => [
    for (final r in (options['staff'] as List? ?? const []))
      Map<String, dynamic>.from(r as Map),
  ];
  bool _inFilter(Map<String, dynamic> r) =>
      _roleFilter[filter] == null || r['role'] == _roleFilter[filter];

  /// 页签上的人数：不含已停用；0 全部，1 店长，2 前台收银，3 施工技师。
  int count(int tab) => staffRows
      .where(
        (r) =>
            r['status'] != 'disabled' &&
            (_roleFilter[tab] == null || r['role'] == _roleFilter[tab]),
      )
      .length;
  List<Map<String, dynamic>> get rows => isStaff
      ? staffRows
      : resources
            .where(
              (r) => r['kind'] == (mode == 'business' ? 'bay' : 'technician'),
            )
            .toList();
  List<Map<String, dynamic>> get activeStaff =>
      rows.where((r) => r['status'] != 'disabled').toList();
  List<Map<String, dynamic>> get inactiveStaff =>
      rows.where((r) => r['status'] == 'disabled' && _inFilter(r)).toList();
  List<Map<String, dynamic>> get visibleStaff =>
      rows.where((r) => r['status'] != 'disabled' && _inFilter(r)).toList();

  /// 本店保存的技师权限开关（员工与权限页「技师可以」）。
  bool roleCan(String role, String key) =>
      role == 'manager' ||
      ((options['permissions'] as Map?)?[role] as Map?)?[key] == true;

  /// 当前页签对应的角色（全部页签时没有单一角色，按技师处理）。
  String get roleKey => _roleFilter[filter] ?? 'technician';

  /// 空状态里的「添加店长 / 添加前台收银 …」：新增员工并预选当前页签的角色。
  void addStaff(BuildContext context) {
    final role = _roleFilter[filter];
    if (role != null) StaffFlow.presetRole = role;
    editResource(context, null);
  }
  List<Map<String, dynamic>> get bays => resources
      .where(
        (r) =>
            r['kind'] == 'bay' &&
            (r['active'] == true || r['id'] == draft['linked_id']),
      )
      .toList();
  String get linkedName =>
      resources.where((r) => r['id'] == draft['linked_id']).firstOrNull?['name']
          as String? ??
      '未指定';
  void changed() => notifyListeners();
  void edited() {
    dirty = true;
    notifyListeners();
  }

  void deferred(BuildContext context) =>
      AppToast.show(context, 'TODO：此功能尚未接通，当前未执行该操作');
  Future<void> save(BuildContext context, {String button = '保存'}) async {
    if (busy) return;
    if (mode == 'reschedule' &&
        (rescheduleDay == null || selectedTime.isEmpty)) {
      AppToast.show(context, '请选择新日期和时间');
      return;
    }
    busy = true;
    activeButton = button;
    notifyListeners();
    final messenger = ScaffoldMessenger.of(context);
    if (mode == 'staff') {
      try {
        final saved = await StaffFlow.save({
          'id': draft['id'],
          'name': '${draft['name']}'.trim(),
          'phone': '${draft['phone']}'.trim(),
          'role': draft['role'],
          'skills': '${draft['category']}',
          'bay_id': draft['linked_id'],
          'joined_on': '${draft['joined_on']}',
        });
        AppointmentFlow.notify();
        dirty = false;
        if (!context.mounted) return;
        if (_initial == null) {
          // 新增成功：进入邀请页（设计稿 StaffAdd → StaffInvite）
          StaffFlow.invited = saved;
          onAdded?.call(context);
        } else {
          AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) AppToast.error(context, e);
      } finally {
        busy = false;
        notifyListeners();
      }
      return;
    }
    try {
      await Future.wait([
        mode == 'reschedule'
            ? AppointmentFlow.save({
                'id': booking!.id,
                'starts_at':
                    '${bookingDay(bookingToday.add(Duration(days: rescheduleDay!)))}T$selectedTime:00+08:00',
                'bay_id': booking!.row['bay_id'],
                'technician_id': booking!.row['technician_id'],
              })
            : mode == 'settings' || mode == 'business'
            ? merchantApi.appointment('settings_save', settings)
            : merchantApi.appointment('resource_save', {
                ...draft,
                'kind': mode == 'bay' ? 'bay' : 'technician',
                'joined_on': mode == 'bay' ? null : draft['joined_on'],
              }),
        Future<void>.delayed(kIndicatorMinShow),
      ]);
      AppointmentFlow.notify();
      if (context.mounted) {
        AppToast.showOn(
          messenger,
          mode == 'staff' && _initial == null ? '技师资料已保存，员工邀请尚未接通' : '已保存',
          kind: ToastKind.success,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(BuildContext context) async {
    if (cancelReason == null) return;
    final ok = await hConfirm(
      context,
      '确认取消预约？',
      message: '取消后将释放预约时段',
      onConfirm: () async {
        await AppointmentFlow.change(
          booking!.id,
          'cancel',
          reason: ['客户有事', '时间冲突', '联系不上', '其他'][cancelReason!],
        );
      },
    );
    if (ok && context.mounted) Navigator.of(context).pop();
  }

  /// 新增员工保存成功后由路由层打开邀请页。
  void Function(BuildContext)? onAdded;

  /// 编辑页「停用账号」：由路由层打开停用确认弹层。
  void Function(BuildContext)? onDisable;
  void editResource(BuildContext context, Map<String, dynamic>? row) {
    // 编辑器的构造由路由层注入，避免模板依赖页面实现。
    onEdit?.call(context, row);
  }

  void Function(BuildContext, Map<String, dynamic>?)? onEdit;
  Future<void> toggleActive(BuildContext context) async {
    if (busy) return;
    if (mode == 'staff') {
      onDisable?.call(context);
      return;
    }
    if (draft['id'] == null) {
      AppToast.show(context, '请先保存工位资料');
      return;
    }
    await hConfirm(
      context,
      draft['active'] == false ? '确认启用？' : '确认停用？',
      onConfirm: () async {
        final active = draft['active'] != true;
        final result = await merchantApi.appointment('resource_save', {
          ...draft,
          'kind': mode == 'bay' ? 'bay' : 'technician',
          'active': active,
          'joined_on': mode == 'bay' ? null : draft['joined_on'],
        });
        draft.addAll(result);
        dirty = false;
        AppointmentFlow.notify();
        notifyListeners();
      },
    );
  }

  Future<void> pickLinked(BuildContext context) async {
    final list = resources
        .where((r) => r['kind'] == 'technician' && r['active'] == true)
        .toList();
    final picked = await pickFromList(context, '默认技师', [
      '未指定',
      ...list.map((r) => '${r['name']}'),
    ], linkedName);
    if (picked == null) return;
    draft['linked_id'] = picked == '未指定'
        ? null
        : list.firstWhere((r) => r['name'] == picked)['id'];
    edited();
  }

  Future<void> pickPosition(BuildContext context) async {
    final picked = await pickFromList(context, '排序', [
      for (var i = 0; i < 100; i++) '第 ${i + 1} 位',
    ], '第 ${draft['position'] + 1} 位');
    if (picked != null) {
      draft['position'] = int.parse(picked.replaceAll(RegExp(r'\D'), '')) - 1;
      edited();
    }
  }
}

class BookingString extends StatefulWidget {
  final BookingTemplateController c;
  final String field, initial;
  final Widget Function(BuildContext, StrCtrl) builder;
  const BookingString({
    super.key,
    required this.c,
    required this.field,
    required this.initial,
    required this.builder,
  });
  @override
  State<BookingString> createState() => _StringState();
}

class _StringState extends State<BookingString> {
  late final StrCtrl ctrl = StrCtrl('${widget.c.settings[widget.field]}')
    ..addListener(_change);
  void _change() {
    widget.c.settings[widget.field] = ctrl.v;
    widget.c.edited();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, ctrl);
}

class BookingNumber extends StatefulWidget {
  final BookingTemplateController c;
  final String field;
  final List<int> inits;
  final Widget Function(BuildContext, List<ValCtrl>) builder;
  const BookingNumber({
    super.key,
    required this.c,
    required this.field,
    required this.inits,
    required this.builder,
  });
  @override
  State<BookingNumber> createState() => _NumberState();
}

class _NumberState extends State<BookingNumber> {
  late final ValCtrl ctrl = ValCtrl(
    (widget.c.settings[widget.field] as num?)?.toInt() ?? 0,
  )..addListener(_change);
  void _change() {
    widget.c.settings[widget.field] = ctrl.v;
    widget.c.edited();
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, [ctrl]);
    if (widget.field.startsWith('deferred_')) {
      return GestureDetector(
        onTap: () => widget.c.deferred(context),
        child: AbsorbPointer(child: child),
      );
    }
    return child;
  }
}

class BookingSelections extends StatefulWidget {
  final BookingTemplateController c;
  final String field;
  final List<(Set<int>, bool)> groups;
  final Widget Function(BuildContext, List<SelCtrl>) builder;
  const BookingSelections({
    super.key,
    required this.c,
    required this.field,
    required this.groups,
    required this.builder,
  });
  @override
  State<BookingSelections> createState() => _SelectionsState();
}

class _SelectionsState extends State<BookingSelections> {
  static const skills = ['洗车', '内饰清洁', '镀晶', '抛光', '贴膜', '石墨烯镀膜', '空调杀菌'];
  static const cats = ['洗车', '美容', '贴膜'];
  static const _roles = ['manager', 'cashier', 'technician'];
  late final SelCtrl ctrl = SelCtrl(_initial(), widget.groups.first.$2)
    ..addListener(_change);
  Set<int> _initial() {
    final c = widget.c;
    return switch (widget.field) {
      'slot_minutes' => {
        [15, 30, 60].indexOf(c.settings['slot_minutes'] as int),
      },
      'closed_days' => {
        for (final i in c.settings['closed_days'] as List) (i as int) - 1,
      },
      'working_days' => {
        for (var i = 0; i < 7; i++)
          if (!(c.settings['closed_days'] as List).contains(i + 1)) i,
      },
      'staff_filter' => {c.filter},
      'staff_role' => {
        _roles.indexOf('${c.draft['role']}').clamp(0, 2),
      },
      'staff_skills' => {
        for (var i = 0; i < skills.length; i++)
          if ('${c.draft['category']}'.split(' / ').contains(skills[i])) i,
      },
      'bay_category' => {
        if (cats.contains(c.draft['category']))
          cats.indexOf(c.draft['category'] as String),
      },
      'fixed_bay' => {
        c.bays.indexWhere((r) => r['id'] == c.draft['linked_id']) + 1,
      },
      _ => {},
    };
  }

  void _change() {
    final c = widget.c, selected = ctrl.selected;
    switch (widget.field) {
      case 'slot_minutes':
        c.settings['slot_minutes'] = [15, 30, 60][selected.first];
      case 'closed_days':
        c.settings['closed_days'] = [for (final i in selected) i + 1];
      case 'working_days':
        c.settings['closed_days'] = [
          for (var i = 0; i < 7; i++)
            if (!selected.contains(i)) i + 1,
        ];
      case 'staff_filter':
        c.filter = selected.first;
      case 'staff_skills':
        c.draft['category'] = [for (final i in selected) skills[i]].join(' / ');
      case 'bay_category':
        c.draft['category'] = selected.isEmpty ? '' : cats[selected.first];
      case 'fixed_bay':
        c.draft['linked_id'] = selected.first == 0
            ? null
            : c.bays[selected.first - 1]['id'];
      case 'staff_role':
        c.draft['role'] = _roles[selected.first];
    }
    if (widget.field == 'staff_filter') {
      c.changed();
    } else {
      c.edited();
    }
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, [ctrl]);
}

class BookingInput extends StatelessWidget {
  final BookingTemplateController c;
  final String hint, value;
  final TextStyle style;
  final TextInputType? keyboard;
  final bool obscure;
  final int? maxLines;
  final TextAlign align;
  final Color hintColor;
  const BookingInput({
    super.key,
    required this.c,
    required this.style,
    this.hint = '',
    this.value = '',
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.align = TextAlign.start,
    this.hintColor = const Color(0xFF71717A),
  });
  @override
  Widget build(BuildContext context) {
    final field = hint.contains('工位') || hint == '员工姓名'
        ? 'name'
        : hint.contains('手机号')
        ? 'phone'
        : 'joined_on';
    return TextFormField(
      // 入职日期按设计稿显示为 2026.11.01；内部（以及提交）仍用 2026-11-01。
      initialValue: field == 'joined_on'
          ? '${c.draft[field] ?? ''}'.replaceAll('-', '.')
          : '${c.draft[field] ?? ''}',
      readOnly: c.busy,
      style: style,
      textAlign: align,
      keyboardType: keyboard,
      obscureText: obscure,
      maxLines: maxLines,
      minLines: 1,
      onChanged: (v) {
        c.draft[field] = field == 'joined_on' ? v.replaceAll('.', '-') : v;
        c.edited();
      },
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: hint,
        hintStyle: style.copyWith(
          color: dk(context, hintColor, const Color(0xFF9A9AA3)),
        ),
      ),
    );
  }
}

class BookingDeferredSwitch extends StatelessWidget {
  const BookingDeferredSwitch({super.key});
  @override
  Widget build(BuildContext context) => HSwitchValue(
    value: false,
    onChanged: (_) => AppToast.show(context, 'TODO：线上预约、通知与定金尚未接通，未执行该操作'),
  );
}

class BookingRescheduleSlots extends StatelessWidget {
  final BookingTemplateController c;
  const BookingRescheduleSlots({super.key, required this.c});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 88,
    child: AsyncView<Map<String, dynamic>>(
      key: ValueKey(c.rescheduleDay),
      load: () => merchantApi.appointment('slots', {
        'day': bookingDay(bookingToday.add(Duration(days: c.rescheduleDay!))),
        'service_ids': c.booking!.row['service_ids'],
        'exclude': c.booking!.id,
        'bay_id': c.booking!.row['bay_id'],
        'technician_id': c.booking!.row['technician_id'],
      }),
      isEmpty: (_) => false,
      inlineError: true,
      pullToRefresh: false,
      skeletonPadding: EdgeInsets.zero,
      skeleton: const AppSkeleton(height: 88, radius: 12),
      empty: (_) => const SizedBox.shrink(),
      builder: (_, data) => SingleChildScrollView(
        child: (data['slots'] as List).isEmpty
            ? const EmptyView(title: '该日期没有可预约时段', inline: true)
            : ChoiceChipGroup<String>(
                semanticLabel: '新时间',
                kind: ChipKind.tile,
                items: [
                  for (final slot in data['slots'] as List)
                    ChoiceChipItem(
                      value: slot['time'] as String,
                      label: slot['time'] as String,
                      disabled: slot['available'] != true,
                      isOriginal:
                          bookingDay(c.booking!.start) ==
                              bookingDay(
                                bookingToday.add(
                                  Duration(days: c.rescheduleDay!),
                                ),
                              ) &&
                          slot['time'] == c.booking!.time,
                    ),
                ],
                selected: c.selectedTime.isEmpty ? null : c.selectedTime,
                onChanged: (value) {
                  c.selectedTime = value;
                  c.edited();
                },
              ),
      ),
    ),
  );
}
