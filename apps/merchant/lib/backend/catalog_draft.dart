import 'package:flutter/material.dart';

import 'merchant_api.dart';

/// Non-visual adapter for the existing generated catalog forms.
class CatalogDraft {
  static CatalogDraft? current;
  static final changed = ValueNotifier<int>(0);

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

  static Future<void> save(BuildContext context, String kind) async {
    final draft = current;
    if (draft == null || draft.kind != kind) return;
    final name = draft.fields['name']?.toString().trim() ?? '';
    if (name.isEmpty) {
      _message(context, '请输入名称');
      return;
    }
    final values = <String, dynamic>{'name': name};
    if (draft.id != null) values['id'] = draft.id;
    if (kind == 'services') {
      final price = num.tryParse(
        (draft.fields['price'] ?? '').toString().replaceAll(',', ''),
      );
      if (price == null || price < 0) {
        _message(context, '请输入正确的门店价');
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
        _message(context, '请输入正确的折扣');
        return;
      }
      values.addAll({
        'discount': discount,
        'description': draft.fields['description'] ?? '',
      });
    }
    try {
      await merchantApi.save(kind, values);
      changed.value++;
      if (context.mounted) {
        _message(context, '已保存');
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (context.mounted) _message(context, '保存失败：$e');
    }
  }

  static Future<void> remove(BuildContext context, String kind) async {
    final draft = current;
    if (draft == null || draft.kind != kind || draft.id == null) {
      _message(context, '尚未保存，无需删除');
      return;
    }
    try {
      await merchantApi.delete(kind, draft.id!);
      changed.value++;
      if (context.mounted) {
        _message(context, kind == 'cards' ? '已停用' : '已删除');
        Navigator.of(context).maybePop();
      }
    } catch (e) {
      if (context.mounted) _message(context, '删除失败：$e');
    }
  }

  static void _message(BuildContext context, String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
