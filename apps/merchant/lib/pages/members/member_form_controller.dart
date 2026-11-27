import '../scan/scan_page.dart';

import 'package:flutter/material.dart';

import '../../backend/member_flow.dart' show memberFromRow, plateText;
import '../../backend/merchant_api.dart';
import '../../kit/kit.dart' show hConfirm;
import '../../kit/pickers.dart' show PlateCtrl, pickCarModel, pickDate;
import 'member_events.dart';
import 'member_picker_sheet.dart' show showMemberPicker;
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_route_data.dart';

enum MemberFormKind { create, edit, vehicle }

class MemberFormController extends ChangeNotifier {
  static const honorifics = ['先生', '女士'];
  static const sources = ['到店自然客', '老客推荐', '团购平台', '短视频'];
  final MemberFormKind kind;
  final Map<String, dynamic>? member;
  final Map<String, dynamic>? vehicle;
  final fields = <String, TextEditingController>{};
  final values = <String, dynamic>{};
  late final Map<String, String> _initialValues;
  late final String _initialPlate;
  late final PlateCtrl plate;
  bool busy = false, disposed = false, _deleted = false;

  bool get isEditingVehicle =>
      kind == MemberFormKind.vehicle && vehicle?['id'] != null;

  MemberFormController(
    this.kind, {
    Map<String, dynamic>? member,
    Map<String, dynamic>? vehicle,
  }) : member = member == null ? null : Map.unmodifiable(member),
       vehicle = vehicle == null ? null : Map.unmodifiable(vehicle) {
    if (kind == MemberFormKind.edit && member != null) values.addAll(member);
    values['honorific'] ??= '先生';
    values['birthday'] = '${values['birthday'] ?? ''}'.replaceAll('-', '.');
    values['color'] ??= kind == MemberFormKind.create ? '黑色' : '';
    if (vehicle != null) {
      for (final entry in vehicle.entries) {
        if (entry.value != null && '${entry.value}'.isNotEmpty) {
          values[entry.key] = entry.value;
        }
      }
    }
    final text = '${values['plate'] ?? ''}';
    plate = PlateCtrl(
      text,
      text.isNotEmpty
          ? text.length == 8
          : values.containsKey('energy')
          ? values['energy'] == 'ev'
          : false,
    )..addListener(_changed);
    _initialValues = {
      for (final e in values.entries) e.key: '${e.value ?? ''}',
    };
    _initialPlate = plate.text;
  }

  bool get dirty {
    if (_deleted) return false;
    if (plate.text != _initialPlate) return true;
    final keys = {..._initialValues.keys, ...values.keys, ...fields.keys};
    for (final k in keys) {
      if (text(k) != (_initialValues[k] ?? '')) return true;
    }
    return false;
  }

  TextEditingController input(String field) => fields.putIfAbsent(
    field,
    () => TextEditingController(text: '${values[field] ?? ''}')
      ..addListener(_changed),
  );
  String text(String field) => fields[field]?.text ?? '${values[field] ?? ''}';
  void set(String field, Object? value) {
    if (busy || disposed) return;
    values[field] = value;
    if (fields.containsKey(field)) fields[field]!.text = '$value';
    _changed();
  }

  void _changed() {
    if (!disposed) notifyListeners();
  }

  Future<void> selectBirthday(BuildContext context) async {
    final value = await pickDate(
      context,
      '选择生日',
      birthday: true,
      current: text('birthday'),
    );
    if (value != null && !disposed) set('birthday', value);
  }

  Future<void> selectCar(BuildContext context) async {
    final value = await pickCarModel(context, text('brand_model'));
    if (value != null && !disposed) set('brand_model', value);
  }

  Future<void> selectReferrer(BuildContext context) async {
    final row = await showMemberPicker(
      context,
      title: '选择推荐人',
      allowAdd: false,
    );
    if (row != null && !disposed) {
      final selected = memberFromRow(row);
      set('referrer_id', selected.id);
      set('referrer_label', '${selected.name} · ${selected.level}');
    }
  }

  void applyVehicle(Map<String, dynamic> vehicle) {
    if (busy || disposed) return;
    final number = '${vehicle['plate'] ?? ''}';
    if (number.isNotEmpty) {
      plate.setGreen(number.length == 8);
      plate.setText(number);
    }
    for (final field in ['brand_model', 'color']) {
      final value = '${vehicle[field] ?? ''}';
      if (value.isNotEmpty) set(field, value);
    }
  }

  Future<void> scanVehicle(BuildContext context) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => const ScanPage(ScanKind.plateCard, returnVehicle: true),
      ),
    );
    if (result != null && !disposed) applyVehicle(result);
  }

  String get actionKey => 'member-form-${identityHashCode(this)}';
  String get deleteActionKey => 'member-vehicle-delete-${identityHashCode(this)}';

  Future<void> deleteVehicle(BuildContext context) async {
    if (busy || disposed || !isEditingVehicle) return;
    if (!merchantApi.hasSession) {
      AppToast.show(context, '请先登录', kind: ToastKind.error);
      return;
    }
    final vehicleId = '${vehicle!['id']}';
    final displayPlate = plateText(
      '${vehicle!['plate'] ?? plate.text}'.trim(),
    );
    ({int openAppointments, int openHolds})? check;
    await runBusy(deleteActionKey, () async {
      busy = true;
      _changed();
      try {
        check = await merchantApi.vehicleDeleteCheck(vehicleId);
      } catch (e) {
        if (context.mounted && !disposed) AppToast.error(context, e);
      } finally {
        busy = false;
        _changed();
      }
    });
    if (check == null || !context.mounted || disposed) return;
    final openParts = <String>[
      if (check!.openAppointments > 0) '${check!.openAppointments} 个未完成预约',
      if (check!.openHolds > 0) '${check!.openHolds} 笔未结算挂单',
    ];
    final message = openParts.isNotEmpty
        ? '该车辆当前有 ${openParts.join('、')}。删除仅移除会员名下的车辆档案，不会影响已有预约、挂单及历史订单记录，确认删除？'
        : '删除后仅移除车辆档案，不影响该车的历史订单与消费记录。';
    final confirmed = await hConfirm(
      context,
      displayPlate.isEmpty ? '删除该车辆？' : '删除车辆 $displayPlate？',
      message: message,
      ok: '确认删除',
      danger: true,
      onConfirm: () async {
        await merchantApi.delete('vehicles', vehicleId);
        _deleted = true;
        memberChanged.value++;
      },
    );
    if (confirmed && context.mounted && !disposed) {
      AppToast.show(context, '已删除');
      Navigator.of(context).pop({'deleted': true});
    }
  }

  Future<void> submit(BuildContext context) => runBusy(actionKey, () async {
    try {
      final row = await save();
      if (!context.mounted || disposed || row == null) return;
      if (kind == MemberFormKind.create) {
        openRoute(
          context,
          'MemberAddDone',
          arguments: MemberRouteData(member: Map.unmodifiable(row)),
        );
      } else {
        AppToast.show(context, '已保存');
        Navigator.of(context).pop(row);
      }
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  });
  Future<Map<String, dynamic>?> save() async {
    if (busy || disposed) return null;
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    final number = plate.text.trim();
    late final String entity;
    late final Map<String, dynamic> body;
    if (kind == MemberFormKind.vehicle) {
      if (member?['id'] == null) {
        throw const AppError('请先选择会员', type: AppErrorType.notFound);
      }
      if (number.isEmpty) throw const AppError('请输入车牌号');
      entity = 'vehicles';
      body = {
        if (isEditingVehicle) 'id': vehicle!['id'],
        'member_id': member!['id'],
        'plate': number,
        'energy': number.length == 8 ? 'ev' : 'fuel',
        'brand_model': text('brand_model'),
        'color': text('color'),
        'vin': text('vin').trim(),
        'mileage': text('mileage').replaceAll(',', '').trim(),
      };
    } else {
      if (kind == MemberFormKind.edit && member?['id'] == null) {
        throw const AppError('请先选择会员', type: AppErrorType.notFound);
      }
      final phone = text('phone').replaceAll(RegExp(r'\D'), '');
      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
        throw const AppError('请输入正确的 11 位手机号');
      }
      if (text('name').trim().isEmpty) {
        throw AppError(kind == MemberFormKind.create ? '请输入客户姓名' : '请输入姓名');
      }
      entity = 'members';
      body = {
        if (kind == MemberFormKind.edit) 'id': member!['id'],
        'phone': phone,
        'name': text('name').trim(),
        'honorific': text('honorific'),
        'birthday': text('birthday').replaceAll('.', '-'),
        'note': text('note').trim(),
        if (kind == MemberFormKind.create) ...{
          'source': text('source'),
          if (text('source') == '老客推荐' && text('referrer_id').isNotEmpty)
            'referrer_id': text('referrer_id'),
          if (number.isNotEmpty)
            'vehicle': {
              'plate': number,
              'energy': number.length == 8 ? 'ev' : 'fuel',
              'brand_model': text('brand_model'),
              'color': text('color'),
            },
        },
      };
    }
    busy = true;
    _changed();
    try {
      final response = await merchantApi.save(entity, body);
      memberChanged.value++;
      return Map<String, dynamic>.from(response['item'] as Map);
    } finally {
      busy = false;
      _changed();
    }
  }

  @override
  void dispose() {
    disposed = true;
    plate.dispose();
    for (final controller in fields.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
