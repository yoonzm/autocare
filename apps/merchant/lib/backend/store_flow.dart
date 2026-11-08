import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../kit/kit.dart' show hConfirm;
import '../routes.dart';
import '../pages/shell.dart';
import 'merchant_api.dart';
import 'store_context.dart';
import 'store_profile.dart';
import 'registration_draft.dart';
import 'catalog_draft.dart';
import 'member_flow.dart';
import 'order_flow.dart';
import 'scan_flow.dart';
import 'service_store.dart';
import 'hold_flow.dart';

class StoreFlow {
  static String? _request, _body;
  static void clear() {
    _request = _body = null;
  }

  static Future<void> save(BuildContext context, {required bool create}) async {
    final route = create ? 'StoreAdd' : 'StoreEdit';
    final values = <String, dynamic>{
      if (!create) 'id': StoreContext.id,
      'name': RegistrationDraft.get(
        route,
        create ? '如：驰光汽车美容 · 浦东店' : '请输入门店名称',
      ).trim(),
      'phone': RegistrationDraft.get(
        route,
        create ? '请输入门店电话' : '请输入联系电话',
      ).trim(),
      'address': RegistrationDraft.get(
        route,
        create ? '请选择或输入门店地址' : '请输入门店地址',
      ).trim(),
    };
    // The server repeats these checks and atomically enforces quota/ownership.
    if ('${values['name']}'.isEmpty || '${values['address']}'.isEmpty) {
      AppToast.show(context, '请填写门店名称和地址');
      return;
    }
    final body = jsonEncode({'create': create, ...values});
    if (_body != body) {
      _body = body;
      _request = MerchantApi.newRequestId();
    }
    try {
      await merchantApi.storeMutation(
        create ? 'create' : 'update',
        values,
        requestId: _request,
      );
      clear();
      if (!create) storeProfile.apply(await merchantApi.getStore());
      if (!context.mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (create) {
        // Keep the active store unchanged, as required by the StoreAdd design.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (nav.context.mounted) openRoute(nav.context, 'StoreSwitch');
        });
      }
    } catch (e) {
      if (context.mounted) AppToast.error(context, e);
    }
  }

  static Future<void> switchTo(
    BuildContext context,
    String id, {
    String? name,
  }) async {
    final nav = Navigator.of(context);
    const forms = {
      'ServiceEdit',
      'CardTierEdit',
      'PackageEdit',
      'MemberAdd',
      'MemberEdit',
      'Order',
      'AppointmentAdd',
      'StoreEdit',
      'Feedback',
    };
    if (navTracker.stack.any((route) => forms.contains(route.settings.name))) {
      final confirmed = await hConfirm(
        context,
        '切换门店将放弃当前未保存的表单，是否继续？',
        ok: '切换门店',
      );
      if (!confirmed || !nav.mounted) return;
    }
    await merchantApi.storeMutation('switch', {'id': id});
    final accountPhone = storeProfile.accountPhone;
    final subscription = storeProfile.subscription;
    final plan = storeProfile.plan;
    final count = storeProfile.storeCount;
    final endsAt = storeProfile.trialEndsAt?.toIso8601String();
    StoreContext.bind(id);
    storeProfile.clear();
    if (name != null) {
      storeProfile.apply({
        'id': id,
        'name': name,
        'account_phone': accountPhone,
        'subscription': subscription,
        'store_count': count,
        'plan': plan,
        'trial_ends_at': endsAt,
      });
    }
    MemberFlow.resetStore();
    ScanFlow.resetStore();
    OrderFlow.reset();
    CatalogDraft.current = null;
    RegistrationDraft.clear();
    clear();
    // Recreate every store-dependent page. Keep the new store selected even if
    // its profile request fails, so stale store data cannot reappear.
    if (nav.mounted) {
      tabIndex.value = 0;
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: 'Main'),
          builder: (_) => const Shell(),
        ),
        (_) => false,
      );
    }
    try {
      storeProfile.apply(await merchantApi.getStore());
    } catch (e) {
      if (nav.mounted && StoreContext.id == id) {
        AppToast.show(
          nav.context,
          AppError.from(e).message,
          kind: ToastKind.error,
          actionLabel: '重试',
          onAction: storeProfile.load,
        );
      }
    }
    if (StoreContext.id != id) return;
    unawaited(ServiceStore.load().then((_) {}, onError: (_) {}));
    HoldFlow.loadSoon();
  }
}
