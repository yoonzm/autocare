import 'dart:async';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import 'merchant_api.dart';

/// Non-visual adapter for the existing generated catalog forms.
class CatalogDraft {
  static CatalogDraft? current;
  static final changed = ValueNotifier<int>(0);

  /// 编辑中的内容有变化（卡面预览据此刷新）。
  static final preview = ValueNotifier<int>(0);
  static bool _busy = false;

  /// 卡面颜色，顺序与设计稿的 4 个色块一致：黑金 / 香槟金 / 银灰 / 海蓝。
  static const cardColors = ['black', 'champagne', 'silver', 'blue'];

  /// 所有合法颜色。新门店的“普通会员”是白色卡面，编辑页的 4 个色块里没有它，
  /// 编辑这张卡时不选色块、保存时保持白色不变。
  static const allCardColors = [...cardColors, 'white'];

  /// 有效期，顺序与设计稿一致：永久有效 / 1 年 / 2 年。
  static const cardValidities = ['forever', '1y', '2y'];

  /// 生日礼选项里“不赠送”对应空字符串。
  static const noGift = '不赠送';

  final String kind;
  final String? id;
  final Map<String, dynamic> fields;

  CatalogDraft._(this.kind, this.id, this.fields);

  static void begin(String kind, [Map<String, dynamic>? row]) {
    final fields = {...?row};
    if (kind == 'cards') {
      // 新建卡种的默认值（已有记录来自后端，字段齐全）
      fields.putIfAbsent('color', () => 'black');
      fields.putIfAbsent('points_multiplier', () => 1);
      fields.putIfAbsent('birthday_gift', () => '');
      fields.putIfAbsent('priority_booking', () => false);
      fields.putIfAbsent('validity', () => 'forever');
    }
    current = CatalogDraft._(kind, row?['id']?.toString(), fields);
    _notifyPreview();
  }

  /// 草稿可能在页面构建过程中被写入（控件初始化时），而预览正在监听它；
  /// 延后到构建结束再通知，避免“构建期间刷新”。
  static void _notifyPreview() => scheduleMicrotask(() => preview.value++);

  // ───────── 卡种字段 <-> 界面文字 ─────────
  static dynamic _field(String name) => current?.fields[name];

  static String get cardName => _field('name')?.toString() ?? '';
  static num get cardDiscount =>
      num.tryParse(_field('discount')?.toString() ?? '') ?? 0.9;

  /// 当前卡面颜色（含白色）。
  static String get cardColor {
    final c = _field('color')?.toString() ?? '';
    return allCardColors.contains(c) ? c : 'black';
  }

  /// 在 4 个色块里的序号；白色卡面不在其中，返回 -1。
  static int get colorIndex => cardColors.indexOf(cardColor);

  static int get validityIndex {
    final i = cardValidities.indexOf(_field('validity')?.toString() ?? '');
    return i < 0 ? 0 : i;
  }

  static bool get priorityBooking => _field('priority_booking') == true;

  /// `2 倍` / `1.5 倍`
  static String get multiplierLabel =>
      '${formatNumber(num.tryParse(_field('points_multiplier')?.toString() ?? '') ?? 1)} 倍';

  /// 生日礼：空 = `不赠送`。
  static String get giftLabel {
    final g = _field('birthday_gift')?.toString() ?? '';
    return g.isEmpty ? noGift : g;
  }

  static void setMultiplier(String label) {
    final n = num.tryParse(label.replaceAll('倍', '').trim());
    if (n != null) set('cards', 'points_multiplier', n);
  }

  static void setGift(String label) =>
      set('cards', 'birthday_gift', label == noGift ? '' : label);

  /// 去掉多余的小数：`2.0` -> `2`，`1.5` -> `1.5`。
  static String formatNumber(num n) =>
      n == n.roundToDouble() ? n.round().toString() : n.toString();

  static String text(String kind, String field, String fallback) {
    final draft = current;
    if (draft == null || draft.kind != kind) return fallback;
    final value = draft.fields[field];
    if (value != null) return value.toString();
    return switch (field) {
      'name' || 'price' || 'upgrade_recharge' || 'upgrade_cumulative' => '',
      _ => fallback,
    };
  }

  static void set(String kind, String field, Object? value) {
    final draft = current;
    if (draft?.kind == kind) {
      draft!.fields[field] = value;
      _notifyPreview();
    }
  }

  /// 保存当前编辑中的服务项目 / 卡种。校验失败和请求失败都用 Toast 说明原因，
  /// 输入内容保留；成功后提示“已保存”并返回。按钮的 loading 由调用方的
  /// `runBusy` 提供，这里的 [_busy] 只是兜底防重复提交。
  static Future<void> save(BuildContext context, String kind) async {
    final draft = current;
    if (draft == null || draft.kind != kind) return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final name = draft.fields['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      fail('请输入名称');
      return;
    }
    final values = <String, dynamic>{'name': name};
    if (draft.id != null) values['id'] = draft.id;
    if (kind == 'services') {
      final price = num.tryParse(
        (draft.fields['price'] ?? '').toString().replaceAll(',', ''),
      );
      if (price == null || price < 0) {
        fail('请输入正确的门店价');
        return;
      }
      values.addAll({
        'price': price,
        'category': draft.fields['category'] ?? '镀晶镀膜',
        'description': draft.fields['description'] ?? '',
      });
    } else {
      final discount = num.tryParse(
        draft.fields['discount']?.toString() ?? '0.9',
      );
      if (discount == null || discount <= 0 || discount > 1) {
        fail('请输入正确的折扣');
        return;
      }
      // 升级条件：留空表示不按这一项升级
      num? money(String field, String label) {
        final text = (draft.fields[field] ?? '')
            .toString()
            .replaceAll(',', '')
            .trim();
        if (text.isEmpty) return null;
        final v = num.tryParse(text);
        if (v == null || v < 0 || v > 99999999) {
          throw FormatException('请输入正确的$label金额');
        }
        return v;
      }

      try {
        values['upgrade_recharge'] = money('upgrade_recharge', '单次充值满');
        values['upgrade_cumulative'] = money('upgrade_cumulative', '累计消费满');
      } on FormatException catch (e) {
        fail(e.message);
        return;
      }
      values.addAll({
        'discount': discount,
        'color': cardColor,
        'points_multiplier':
            num.tryParse(draft.fields['points_multiplier']?.toString() ?? '') ??
            1,
        'birthday_gift': draft.fields['birthday_gift'] ?? '',
        'priority_booking': priorityBooking,
        'validity': cardValidities[validityIndex],
      });
      // 说明没有编辑入口：新建时不传，修改时原样保留
      if (draft.fields.containsKey('description')) {
        values['description'] = draft.fields['description'];
      }
    }
    if (_busy) return;
    _busy = true;
    try {
      await merchantApi.save(kind, values);
      changed.value++;
      AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    } finally {
      _busy = false;
    }
  }

  /// 当前草稿是否是一条已保存的记录（没有 id 的新建项无需删除）。
  static bool canRemove(String kind) =>
      current?.kind == kind && current?.id != null;

  /// 删除 / 停用当前记录。失败时抛出 [AppError]，由确认弹窗保持打开并提示。
  static Future<void> removeCurrent(String kind) async {
    final draft = current;
    if (draft == null || draft.kind != kind || draft.id == null) {
      throw const AppError('尚未保存，无需删除');
    }
    await merchantApi.delete(kind, draft.id!);
    changed.value++;
  }
}
