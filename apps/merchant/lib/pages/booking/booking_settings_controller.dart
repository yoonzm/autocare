import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/mutation_request.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show hConfirm;
import '../../kit/pickers.dart' show pickFromList, pickTime, pickValue;

class BookingSettingsController extends ChangeNotifier {
  Map<String, dynamic> options;
  final String mode;
  late final Map<String, dynamic> settings =
      Map<String, dynamic>.from(options['settings'] as Map)
        ..update('opens_at', (v) => '$v'.substring(0, 5))
        ..update('closes_at', (v) => '$v'.substring(0, 5));
  final Map<String, dynamic> draft;
  final request = MutationRequest();
  final actionKey = 'booking-settings:${UniqueKey()}';
  bool busy = false, saving = false, dirty = false, disposed = false;
  bool _committed = false, _uncertain = false;
  bool get locked => busy || isBusy(actionKey);
  BookingSettingsController(
    Map<String, dynamic> options,
    this.mode, [
    Map<String, dynamic>? row,
  ]) : options = dataSnapshot(options),
       draft = {
         'name': '',
         'phone': '',
         'category': '',
         'active': true,
         'position': 0,
         'linked_id': null,
         ...?row == null ? null : dataSnapshot(row),
       };
  List<Map<String, dynamic>> get resources => [
    for (final r in options['resources'] as List? ?? const [])
      Map<String, dynamic>.from(r as Map),
  ];
  List<Map<String, dynamic>> get rows =>
      resources.where((r) => r['kind'] == 'bay').toList();
  String get linkedName =>
      '${resources.where((r) => r['id'] == draft['linked_id']).firstOrNull?['name'] ?? '未指定'}';
  VoidCallback? reload;
  void Function(BuildContext, Map<String, dynamic>?)? onEdit;
  void editResource(BuildContext context, Map<String, dynamic>? row) =>
      onEdit?.call(context, row);
  void edited() {
    if (disposed) return;
    dirty = true;
    _committed = false;
    notifyListeners();
  }

  void changed() {
    if (!disposed) notifyListeners();
  }

  void setSetting(String key, Object value) {
    if (locked) return;
    settings[key] = value;
    edited();
  }

  void setDraft(String key, Object? value) {
    if (locked) return;
    draft[key] = value;
    edited();
  }

  void deferred(BuildContext context) {
    // TODO: online booking policy and notifications need their own backend contracts.
    AppToast.show(context, 'TODO：此功能尚未接通，当前未执行该操作');
  }

  Future<Map<String, dynamic>?> persist() async {
    if (busy || disposed || _committed) return null;
    if (_uncertain) throw const AppError('保存结果未确认，请先返回工位列表核对，避免重复新增');
    final creating = mode == 'bay' && draft['id'] == null;
    busy = true;
    notifyListeners();
    try {
      final result = await request.send(
        mode == 'settings' || mode == 'business'
            ? {...settings, 'action': 'appointment_settings_save'}
            : {
                ...draft,
                'kind': 'bay',
                'joined_on': null,
                'action': 'appointment_resource_save',
              },
      );
      _committed = true;
      dirty = false;
      AppointmentFlow.notify();
      return dataSnapshot(Map<String, dynamic>.from(result['item'] as Map));
    } catch (e) {
      // Resource creation has no transaction replay contract yet. Do not blindly retry an unknown result.
      if (creating && AppError.from(e).retryable) {
        _uncertain = true;
        throw const AppError('保存结果未确认，请先返回工位列表核对，避免重复新增');
      }
      rethrow;
    } finally {
      busy = false;
      changed();
    }
  }

  Future<void> save(BuildContext context) async {
    if (locked || disposed) return;
    Map<String, dynamic>? saved;
    saving = true;
    changed();
    await runBusy(actionKey, () async {
      try {
        saved = await persist();
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      }
    });
    saving = false;
    changed();
    if (saved == null || !context.mounted || disposed) return;
    AppToast.show(context, '已保存', kind: ToastKind.success);
    Navigator.of(context).pop();
  }

  Future<void> toggleActive(BuildContext context) async {
    if (locked) return;
    if (draft['id'] == null) {
      AppToast.show(context, '请先保存工位资料');
      return;
    }
    await hConfirm(
      context,
      draft['active'] == false ? '确认启用？' : '确认停用？',
      onConfirm: () async {
        busy = true;
        changed();
        try {
          final result = await request.send({
            ...draft,
            'active': draft['active'] != true,
            'kind': 'bay',
            'joined_on': null,
            'action': 'appointment_resource_save',
          });
          if (!disposed) {
            draft.addAll(Map<String, dynamic>.from(result['item']));
            dirty = false;
          }
          AppointmentFlow.notify();
        } finally {
          busy = false;
          changed();
        }
      },
    );
  }

  Future<void> pickSettingTime(
    BuildContext context,
    String field,
    String title,
  ) async {
    final value = await pickTime(context, title, '${settings[field]}');
    if (value != null && context.mounted && !disposed) setSetting(field, value);
  }

  Future<void> pickLinked(BuildContext context) async {
    final list = resources
        .where((r) => r['kind'] == 'technician' && r['active'] == true)
        .toList();
    final index = await pickResourceIndex(context, '默认技师', [
      '未指定',
      ...list.map((r) => '${r['name']}'),
    ], list.indexWhere((r) => r['id'] == draft['linked_id']) + 1);
    if (index != null && context.mounted && !disposed) {
      setDraft('linked_id', index == 0 ? null : list[index - 1]['id']);
    }
  }

  Future<void> pickPosition(BuildContext context) async {
    final result = await pickFromList(context, '排序', [
      for (var i = 0; i < 100; i++) '第 ${i + 1} 位',
    ], '第 ${draft['position'] + 1} 位');
    if (result != null && context.mounted && !disposed) {
      setDraft('position', int.parse(result.replaceAll(RegExp(r'\D'), '')) - 1);
    }
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

// The picker keeps the established list presentation while returning an index, so duplicate labels do not select another record.
Future<int?> pickResourceIndex(
  BuildContext context,
  String title,
  List<String> labels,
  int current,
) => pickValue<int>(
  context,
  title,
  [for (var i = 0; i < labels.length; i++) i],
  current,
  (i) => labels[i],
);
