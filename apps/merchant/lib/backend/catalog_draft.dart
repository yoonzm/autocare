import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import 'merchant_api.dart';

/// Non-visual adapter for the existing generated catalog forms.
class CatalogDraft {
  static CatalogDraft? current;
  static final changed = ValueNotifier<int>(0);
  static bool _busy = false;

  final String kind;
  final String? id;
  final Map<String, dynamic> fields;

  CatalogDraft._(this.kind, this.id, this.fields);

  static void begin(String kind, [Map<String, dynamic>? row]) {
    current = CatalogDraft._(kind, row?['id']?.toString(), {...?row});
  }

  static String text(String kind, String field, String fallback) {
    final draft = current;
    if (draft == null || draft.kind != kind) return fallback;
    final value = draft.fields[field];
    if (value != null) return value.toString();
    return switch (field) {
      'name' || 'price' => '',
      _ => fallback,
    };
  }

  static void set(String kind, String field, Object? value) {
    final draft = current;
    if (draft?.kind == kind) draft!.fields[field] = value;
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
      values.addAll({
        'discount': discount,
        'description': draft.fields['description'] ?? '',
      });
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
