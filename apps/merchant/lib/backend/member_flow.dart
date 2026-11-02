import 'dart:async';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../mock/mock_data.dart';
import '../routes.dart';
import 'catalog_draft.dart';
import 'merchant_api.dart';

/// 会员（核心维护）的适配层：编辑草稿、保存、删除，以及“当前会员”。
///
/// 页面里的输入框 / 选项由 `kit.dart` 按页面名和示例值绑定到 [CatalogDraft]
/// 的 `members` / `vehicles` 草稿；这里负责把草稿提交给云函数。
/// 办卡的规则（发放哪张卡种、手机号 / 车牌唯一）都在云函数里，这里只收集输入、展示结果。
class MemberFlow {
  MemberFlow._();

  /// 正在查看 / 刚办卡的会员（后端返回的整条记录，含卡种和车辆）。
  static Map<String, dynamic>? current;

  /// 称呼：设计稿两个选项，顺序固定。
  static const honorifics = ['先生', '女士'];

  /// 客户来源，顺序与设计稿一致。
  static const sources = ['到店自然客', '老客推荐', '团购平台', '短视频'];

  /// 车身颜色，顺序与设计稿的 5 个色块一致。
  static const colors = ['黑色', '白色', '灰色', '蓝色', '红色'];

  /// 新建会员草稿：设计稿默认称呼先生；来源默认不选。
  static void beginAdd() {
    CatalogDraft.begin('members');
    CatalogDraft.set('members', 'honorific', '先生');
    CatalogDraft.set('members', 'color', colors.first);
    CatalogDraft.set('members', 'energy', 'fuel');
  }

  static void beginEdit(Map<String, dynamic> member) {
    CatalogDraft.begin('members', {
      'id': member['id'],
      'phone': member['phone'],
      'name': member['name'],
      'honorific': member['honorific'],
      'birthday': _birthdayText(member['birthday']),
      'note': member['note'],
    });
  }

  static void beginVehicle(String memberId) =>
      CatalogDraft.begin('vehicles', {'member_id': memberId, 'energy': 'fuel'});

  /// `1985-06-12` -> `1985.06.12`
  static String _birthdayText(Object? v) =>
      v == null ? '' : v.toString().replaceAll('-', '.');

  static String get _phoneDigits =>
      '${CatalogDraft.current?.fields['phone'] ?? ''}'.replaceAll(
        RegExp(r'\D'),
        '',
      );

  // ───────── 办卡（新增会员） ─────────
  /// 保存新会员。成功后进入“开卡成功”页；失败用 Toast 说明原因，输入保留。
  static Future<void> create(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'members') return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    final name = '${f['name'] ?? ''}'.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneDigits)) {
      fail('请输入正确的 11 位手机号');
      return;
    }
    if (name.isEmpty) {
      fail('请输入客户姓名');
      return;
    }
    final source = '${f['source'] ?? ''}';
    final referrer = '${f['referrer_id'] ?? ''}';
    final plate = '${f['plate'] ?? ''}'.trim();
    if (source == '老客推荐' && referrer.isEmpty) {
      // 推荐人是选填：没选就按没有推荐人保存
    }
    final values = <String, dynamic>{
      'phone': _phoneDigits,
      'name': name,
      'honorific': '${f['honorific'] ?? ''}',
      'birthday': '${f['birthday'] ?? ''}'.replaceAll('.', '-'),
      'source': source,
      if (source == '老客推荐' && referrer.isNotEmpty) 'referrer_id': referrer,
      'note': '${f['note'] ?? ''}'.trim(),
      // 车辆是选填：填了车牌才登记
      if (plate.isNotEmpty)
        'vehicle': {
          'plate': plate,
          'energy': '${f['energy'] ?? 'fuel'}',
          'brand_model': '${f['brand_model'] ?? ''}',
          'color': '${f['color'] ?? ''}',
        },
    };
    try {
      final res = await merchantApi.save('members', values);
      current = Map<String, dynamic>.from(res['item'] as Map);
      CatalogDraft.changed.value++;
      if (context.mounted) openRoute(context, 'MemberAddDone');
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 修改资料 ─────────
  static Future<void> update(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'members' || draft.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    final name = '${f['name'] ?? ''}'.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneDigits)) {
      fail('请输入正确的 11 位手机号');
      return;
    }
    if (name.isEmpty) {
      fail('请输入姓名');
      return;
    }
    try {
      final res = await merchantApi.save('members', {
        'id': draft.id,
        'phone': _phoneDigits,
        'name': name,
        'honorific': '${f['honorific'] ?? ''}',
        'birthday': '${f['birthday'] ?? ''}'.replaceAll('.', '-'),
        'note': '${f['note'] ?? ''}'.trim(),
      });
      current = Map<String, dynamic>.from(res['item'] as Map);
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 车辆 ─────────
  static Future<void> saveVehicle(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'vehicles') return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    if ('${f['plate'] ?? ''}'.trim().isEmpty) {
      fail('请输入车牌号');
      return;
    }
    try {
      await merchantApi.save('vehicles', {
        if (draft.id != null) 'id': draft.id,
        'member_id': f['member_id'],
        'plate': '${f['plate']}'.trim(),
        'energy': '${f['energy'] ?? 'fuel'}',
        'brand_model': '${f['brand_model'] ?? ''}',
        'color': '${f['color'] ?? ''}',
        'vin': '${f['vin'] ?? ''}'.trim(),
        'mileage': '${f['mileage'] ?? ''}'.replaceAll(',', '').trim(),
      });
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 删除会员 ─────────
  static Future<void> deleteCurrent() async {
    final id = current?['id']?.toString();
    if (id == null) throw const AppError('会员不存在');
    await merchantApi.delete('members', id);
    current = null;
    CatalogDraft.changed.value++;
  }
}

/// 后端的会员记录 -> 页面里用的 [Member]。
/// 余额、到店时间、微信绑定依赖储值 / 订单 / 微信模块，目前没有数据，显示 “—”。
Member memberFromRow(Map<String, dynamic> row) {
  final vehicles = List<Map<String, dynamic>>.from(
    (row['vehicles'] as List?) ?? const [],
  );
  final card = Map<String, dynamic>.from((row['card'] as Map?) ?? const {});
  return Member(
    '${row['name'] ?? ''}',
    '${card['name'] ?? ''}',
    vehicles.isEmpty ? '未登记车辆' : _plateText('${vehicles.first['plate']}'),
    '—',
    '—',
    '余额',
    const {},
    bound: false,
    phone: '${row['phone'] ?? ''}',
    id: row['id']?.toString(),
    data: row,
  );
}

/// `沪A8K29M` -> `沪A·8K29M`
String _plateText(String plate) =>
    plate.length < 3 ? plate : '${plate.substring(0, 2)}·${plate.substring(2)}';
String plateText(String plate) => _plateText(plate);
