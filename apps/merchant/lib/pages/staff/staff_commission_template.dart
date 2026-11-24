import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart' show AppTokens;

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;
import 'staff_live.dart';
import 'staff_route_data.dart';

class StaffCommissionTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  final bool returnToCaller;
  const StaffCommissionTemplate({
    super.key,
    required this.d,
    this.returnToCaller = false,
  });

  @override
  State<StaffCommissionTemplate> createState() => _StaffCommissionState();
}

class _StaffCommissionState extends State<StaffCommissionTemplate> {
  late String _mode;
  late final TextEditingController _rate;
  final _overrides = <String, TextEditingController>{};
  final _errors = <String, String?>{};
  bool _submitted = false;
  bool _busy = false;
  bool _saved = false;
  late String _initial;
  Map<String, dynamic> get d => widget.d;
  List<Map<String, dynamic>> get _services => [
    for (final s in (d['services'] as List? ?? const []))
      Map<String, dynamic>.from(s as Map),
  ];
  String get _draft => '$_mode|${_rate.text}|${_overrides.entries.map((e) => '${e.key}:${e.value.text}').join('|')}';

  @override
  void initState() {
    super.initState();
    _mode = d['commission_mode'] as String? ?? 'follow';
    _rate = TextEditingController(text: '${d['commission_rate'] ?? 0}');
    final values = Map<String, dynamic>.from(d['commission_overrides'] as Map? ?? {});
    // Preserve overrides for inactive services too; the active list may omit them.
    for (final id in {...values.keys, ..._services.map((s) => '${s['id']}')}) {
      _overrides[id] = TextEditingController(text: values[id]?.toString() ?? '');
    }
    _initial = _draft;
    for (final c in [_rate, ..._overrides.values]) {
      c.addListener(_changed);
    }
  }

  void _changed() => setState(() {
    if (_submitted) _refreshErrors();
  });

  String? _validateValue(String raw, {bool optional = false}) {
    final text = raw.trim();
    if (optional && text.isEmpty) return null;
    final rate = num.tryParse(text);
    if (rate == null || !rate.isFinite || rate < 0 || rate > 100) {
      return '请输入 0–100 的比例';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(text)) {
      return '最多保留两位小数';
    }
    return null;
  }

  bool _refreshErrors() {
    _errors.clear();
    if (_mode == 'flat') {
      final err = _validateValue(_rate.text);
      if (err != null) _errors['flat'] = err;
    } else if (_mode == 'custom') {
      for (final s in _services) {
        final id = '${s['id']}';
        final err = _validateValue(_overrides[id]?.text ?? '', optional: true);
        if (err != null) _errors[id] = err;
      }
    }
    return _errors.isEmpty;
  }

  @override
  void dispose() {
    for (final c in [_rate, ..._overrides.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    _submitted = true;
    final valid = _refreshErrors();
    setState(() {});
    if (!valid) return;
    FocusScope.of(context).unfocus();
    final mode = _mode;
    final rate = mode == 'flat' ? num.parse(_rate.text) : 0;
    final overrides = <String, num>{
      if (mode == 'custom')
        for (final e in _overrides.entries)
          if (e.value.text.trim().isNotEmpty) e.key: num.parse(e.value.text),
    };
    setState(() => _busy = true);
    try {
      final result = await StaffFlow.saveCommission(
        '${d['id']}', mode, rate: rate, overrides: overrides,
      );
      if (!mounted) return;
      setState(() { _saved = true; _busy = false; });
      AppToast.show(context, '提成方案已保存');
      if (widget.returnToCaller) {
        Navigator.of(context).pop(result);
      } else {
        openRoute(context, 'StaffDetail', arguments: StaffRouteData(staffId: '${d['id']}'));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        AppToast.error(context, e);
      }
    }
  }

  Widget _input(
    TextEditingController controller, {
    required String fieldKey,
    required String label,
    bool optional = false,
  }) {
    final colors = AppTokens.of(context);
    final error = _errors[fieldKey];
    final hasError = error != null && error.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: colors.small),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError ? colors.badge : colors.line,
              width: hasError ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AppTextInput(
                  controller: controller,
                  keyboard: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  style: colors.body.copyWith(fontWeight: FontWeight.w400),
                  hint: optional ? '留空跟随项目设置' : '请输入提成比例',
                  hintColor: colors.inkFaint,
                ),
              ),
              const SizedBox(width: 8),
              Text('%', style: colors.body.copyWith(color: colors.inkMute)),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              error,
              style: colors.caption.copyWith(color: colors.requiredStar),
            ),
          ),
      ],
    );
  }

  Widget _card(String mode, String title, String subtitle, Widget content) {
    final colors = AppTokens.of(context);
    final selected = _mode == mode;
    return Container(
      decoration: BoxDecoration(
        color: selected ? colors.primarySoft : colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? colors.primary : colors.line, width: selected ? 1.5 : 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          selected: selected, button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _mode = mode;
                _submitted = false;
                _errors.clear();
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: colors.ink)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, height: 1.5, color: colors.inkSub)),
                ])),
                const SizedBox(width: 12),
                Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? colors.primary : colors.inkFaint, size: 24),
              ]),
            ),
          ),
        ),
        if (selected) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: content),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTokens.of(context);
    final name = '${d['name']}';
    final role = StaffFlow.roleName(d['role']);
    final services = _services;
    return ConfirmDiscard(
      dirty: !_saved && _initial != _draft,
      busy: _busy,
      child: HPage(
        bg: colors.bg,
        header: AppPageHeader(
          title: '提成方案',
          leadingEnabled: !_busy,
          trailing: Semantics(
            button: true, label: _busy ? '保存中' : '保存',
            child: GestureDetector(
              onTap: _busy ? null : _save,
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: _busy ? 12 : 18),
                decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(22)),
                alignment: Alignment.center,
                child: _busy ? AppSpinner(size: 20, color: colors.onPrimary) : Text('保存', style: TextStyle(color: colors.onPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
        flow: AbsorbPointer(
          absorbing: _busy,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  hbox(
                    bg: dk(context, Color(0xFF18181B), Color(0xFF1F1F23)),
                    radius: BorderRadius.circular(22),
                    pad: EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: hrow(
                      [
                        hbox(
                          w: 40,
                          h: 40,
                          bg: dk(
                            context,
                            Color(0xFFE1F0FE),
                            Color.fromRGBO(4, 133, 247, 0.18),
                          ),
                          radius: BorderRadius.circular(20),
                          align: Alignment(0, 0),
                          child: Text(
                            staffInitial(d),
                            style: hts(
                              15,
                              dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)),
                              w: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: hcol(
                            [
                              Text(
                                name,
                                style: hts(
                                  16,
                                  Color(0xFFFAFAFA),
                                  w: FontWeight.w600,
                                  lh: 22,
                                ),
                              ),
                              Text(
                                '$role · 上月提成 ${StaffFlow.money(d['last_month_commission'])}',
                                style: hts(
                                  12,
                                  dk(
                                    context,
                                    Color(0xFFA1A1AA),
                                    Color(0xFF80808A),
                                  ),
                                  lh: 16,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 2,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 12,
                    ),
                  ),
                const SizedBox(height: 16),
                _card('follow', '跟随项目设置', '按「服务项目」中各项目设定的提成规则计算',
                  Column(children: [
                    Divider(color: colors.line, height: 16),
                    if (services.isEmpty) Text('还没有服务项目，请先在服务项目中设置提成。', style: TextStyle(color: colors.inkSub)),
                    for (final s in services) Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Expanded(child: Text('${s['name']}', style: TextStyle(color: colors.inkSub, fontSize: 13))),
                        Text(staffServiceRate(s), style: TextStyle(color: colors.ink, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ])),
                const SizedBox(height: 10),
                _card('flat', '统一比例', '所有项目按同一比例，覆盖项目设置',
                  _input(_rate, fieldKey: 'flat', label: '统一提成比例')),
                const SizedBox(height: 10),
                _card('custom', '按项目自定义', '仅对该员工单独设置，其余项目仍跟随项目设置',
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Text('留空跟随项目设置；填写 0 表示该项目不提成。', style: TextStyle(color: colors.inkSub, fontSize: 12)),
                    if (services.isEmpty) const Padding(padding: EdgeInsets.only(top: 12), child: Text('还没有可设置的服务项目。')),
                    for (final s in services) Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: _input(_overrides['${s['id']}']!, fieldKey: '${s['id']}', label: '${s['name']} · 项目默认 ${staffServiceRate(s)}', optional: true),
                    ),
                  ])),
                const SizedBox(height: 16),
                Text('修改后对之后结算的订单生效（含已完工待结算订单），已结算订单的提成不会重算。', style: TextStyle(color: colors.inkSub, fontSize: 12, height: 1.5)),
              ]),
            ),
        ),
      ),
    );
  }
}

class StaffCommissionLivePage extends StatelessWidget {
  final String? staffId;
  final bool returnToCaller;
  const StaffCommissionLivePage({
    super.key,
    this.staffId,
    this.returnToCaller = false,
  });

  @override
  Widget build(BuildContext context) => StaffLiveHost(
    staffId: staffId,
    title: '提成方案',
    load: (id) => merchantApi.staff('get', {'id': id}),
    builder: (_, d) => StaffCommissionTemplate(
      key: ValueKey(d['id']), d: d, returnToCaller: returnToCaller,
    ),
  );
}
