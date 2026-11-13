import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/data_snapshot.dart';
import '../../backend/mutation_request.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';

class StaffEditorController extends ChangeNotifier {
  Map<String, dynamic> options;
  final Map<String, dynamic> draft;
  final bool creating;
  final request = MutationRequest();
  final actionKey = 'staff-editor:${UniqueKey()}';
  bool busy = false, dirty = false, saving = false, disposed = false;
  bool _committed = false, _uncertain = false;
  bool get locked => busy || isBusy(actionKey);
  int filter = 0;
  bool showInactive = false;
  static const roles = ['manager', 'cashier', 'technician'];
  static const skills = ['洗车', '内饰清洁', '镀晶', '抛光', '贴膜', '石墨烯镀膜', '空调杀菌'];
  static const roleFilter = [null, ...roles];
  StaffEditorController(
    Map<String, dynamic> options, {
    Map<String, dynamic>? row,
    String? initialRole,
  }) : options = dataSnapshot(options),
       creating = row == null,
       draft = {
         'name': '',
         'phone': '',
         'role': initialRole ?? 'technician',
         'skills': '',
         'bay_id': null,
         'joined_on': bookingDay(bookingToday),
         ...?(row == null ? null : dataSnapshot(row)),
       };
  List<Map<String, dynamic>> get staffRows => [
    for (final row in options['staff'] as List? ?? const [])
      Map<String, dynamic>.from(row as Map),
  ];
  List<Map<String, dynamic>> get bays => [
    for (final row in options['bays'] as List? ?? const [])
      Map<String, dynamic>.from(row as Map),
  ];
  List<Map<String, dynamic>> get rows => staffRows;
  List<Map<String, dynamic>> get visibleStaff => rows
      .where(
        (r) =>
            r['status'] != 'disabled' &&
            (roleFilter[filter] == null || r['role'] == roleFilter[filter]),
      )
      .toList();
  List<Map<String, dynamic>> get inactiveStaff => rows
      .where(
        (r) =>
            r['status'] == 'disabled' &&
            (roleFilter[filter] == null || r['role'] == roleFilter[filter]),
      )
      .toList();
  int count(int tab) => rows
      .where(
        (r) =>
            r['status'] != 'disabled' &&
            (roleFilter[tab] == null || r['role'] == roleFilter[tab]),
      )
      .length;
  String get roleKey => roleFilter[filter] ?? 'technician';
  bool roleCan(String role, String key) =>
      ((options['permissions'] as Map?)?[role] as Map?)?[key] == true;
  Set<int> get skillIndexes => {
    for (var i = 0; i < skills.length; i++)
      if ('${draft['skills']}'.split(' / ').contains(skills[i])) i,
  };
  void Function(BuildContext, Map<String, dynamic>?)? onEdit;
  void Function(BuildContext, Map<String, dynamic>)? onAdded;
  void Function(BuildContext)? onDisable;
  void editResource(BuildContext context, Map<String, dynamic>? row) =>
      onEdit?.call(context, row);
  void addStaff(BuildContext context) => onEdit?.call(context, null);
  void changed() {
    if (!disposed) notifyListeners();
  }

  void edited() {
    if (disposed) return;
    dirty = true;
    _committed = false;
    changed();
  }

  void setDraft(String key, Object? value) {
    if (locked) return;
    draft[key] = value;
    edited();
  }

  void setFilter(int value) {
    filter = value;
    changed();
  }

  void deferred(BuildContext context) {
    // TODO: staff notification/shift/specialty extensions require their own backend contract.
    AppToast.show(context, 'TODO：此功能尚未接通，当前未执行该操作');
  }

  void toggleActive(BuildContext context) {
    if (!locked) onDisable?.call(context);
  }

  Future<Map<String, dynamic>?> persist() async {
    if (busy || disposed || _committed) return null;
    if (_uncertain) throw const AppError('保存结果未确认，请先返回员工列表核对，避免重复新增');
    busy = true;
    changed();
    try {
      final result = await request.send({
        'action': 'staff_save',
        'id': draft['id'],
        'name': '${draft['name']}'.trim(),
        'phone': '${draft['phone']}'.trim(),
        'role': draft['role'],
        'skills': draft['skills'],
        'bay_id': draft['bay_id'],
        'joined_on': draft['joined_on'],
      });
      dirty = false;
      _committed = true;
      StaffFlow.notify();
      AppointmentFlow.notify();
      return dataSnapshot(Map<String, dynamic>.from(result['item'] as Map));
    } catch (e) {
      // TODO: save_staff has no creation idempotency transaction yet. Unknown results require checking the list first.
      if (creating && AppError.from(e).retryable) {
        _uncertain = true;
        throw const AppError('保存结果未确认，请先返回员工列表核对，避免重复新增');
      }
      rethrow;
    } finally {
      busy = false;
      changed();
    }
  }

  Future<void> save(BuildContext context) async {
    if (locked || disposed) return;
    Map<String, dynamic>? result;
    saving = true;
    changed();
    await runBusy(actionKey, () async {
      try {
        result = await persist();
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      }
    });
    saving = false;
    changed();
    if (result == null || !context.mounted || disposed) return;
    if (creating && onAdded != null) {
      onAdded!(context, result!);
      return;
    }
    AppToast.show(context, '已保存', kind: ToastKind.success);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
