import 'data_snapshot.dart';
import 'catalog_counts.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'access_flow.dart';
import 'store_context.dart';
import 'hold_store.dart';
import 'merchant_api.dart';
import 'service_store.dart';

/// The signed-in owner's store as stored in the backend.
///
/// Cold startup restores this profile before mounting store-dependent pages.
/// Failed refreshes retain the last confirmed profile; they never use demo data.
class StoreProfile extends ChangeNotifier {
  bool live = false;
  int _revision = 0;
  String accountPhone = '';
  String hoursLine = '未设置营业时间与工位';

  /// 当前登录人自己的资料（「我的 · 编辑资料」）：老板是账号联系人，员工是自己的员工档案。
  Map<String, dynamic> profile = const {};
  String get profileName => '${profile['name'] ?? ''}';
  String get profileEmail => '${profile['email'] ?? ''}';
  String get avatarUrl => '${profile['avatar_url'] ?? ''}';

  String get profileMaskedPhone {
    final d = '${profile['phone'] ?? ''}'.replaceAll(RegExp(r'\D'), '');
    final p = d.length >= 11 ? d.substring(d.length - 11) : d;
    return p.length == 11
        ? '${p.substring(0, 3)} **** ${p.substring(7)}'
        : (p.isEmpty ? '—' : p);
  }

  String get profileInitial =>
      profileName.isEmpty ? '—' : String.fromCharCode(profileName.runes.first);
  String get profileRoleText {
    final role = '${profile['role'] ?? 'owner'}';
    return role == 'owner' && contactRole.isNotEmpty
        ? contactRole
        : Access.roleBrief(role);
  }

  /// `2022.01`；没有入职 / 开通日期时是 `—`。
  String get profileJoinedText {
    final d = DateTime.tryParse('${profile['joined_on'] ?? ''}');
    return d == null ? '—' : '${d.year}.${d.month.toString().padLeft(2, '0')}';
  }

  String name = '';
  String phone = '';
  String city = '';
  String address = '';
  String contactName = '';
  String contactRole = '';
  List<String> businessTypes = const [];

  /// 11-digit mainland number, e.g. `13988888812` (the backend keeps `+86…`).
  String get localPhone {
    final d = (accountPhone.isEmpty ? phone : accountPhone).replaceAll(
      RegExp(r'\D'),
      '',
    );
    return d.length >= 11 ? d.substring(d.length - 11) : d;
  }

  /// 经办人：`陈明（店长）`；没填联系人时是“店主”。
  String get operatorText => contactName.isEmpty
      ? '店主'
      : (contactRole.isEmpty ? contactName : '$contactName（$contactRole）');

  /// `139 **** 8812`
  String get maskedPhone {
    final p = localPhone;
    return p.length == 11 ? '${p.substring(0, 3)} **** ${p.substring(7)}' : p;
  }

  /// 设置页 / 门店信息里的套餐行。
  String get expiryLine => '限时免费';

  String get addressText =>
      [city, address].where((s) => s.isNotEmpty).join(' ');

  void apply(Map<String, dynamic> s) {
    _revision++;
    live = true;
    profile = dataSnapshot(
      Map<String, dynamic>.from((s['profile'] as Map?) ?? const {}),
    );
    if (s['id'] != null) StoreContext.bind('${s['id']}');
    hoursLine = '${s['hours_line'] ?? '未设置营业时间与工位'}';
    accountPhone = '${s['account_phone'] ?? s['phone'] ?? ''}';
    name = (s['name'] as String?) ?? '';
    phone = (s['phone'] as String?) ?? '';
    city = (s['city'] as String?) ?? '';
    address = (s['address'] as String?) ?? '';
    contactName = (s['contact_name'] as String?) ?? '';
    contactRole = (s['contact_role'] as String?) ?? '';
    businessTypes = List<String>.unmodifiable(
      (s['business_types'] as List?) ?? const [],
    );
    notifyListeners();
  }

  /// Best-effort refresh after sign-in or profile changes. Cold startup uses
  /// StoreSessionGate so restoration failures remain visible and retryable.
  Future<void> load() async {
    if (!merchantApi.hasSession) return;
    final revision = ++_revision;
    final epoch = StoreContext.epoch;
    final api = merchantApi;
    try {
      final data = await api.getStore();
      if (revision != _revision ||
          epoch != StoreContext.epoch ||
          !identical(api, merchantApi)) {
        return;
      }
      apply(data);
      // 服务项目几乎每个页面都要用：读到门店资料后预加载进全局缓存
      unawaited(ServiceStore.load().then((_) {}, onError: (_) {}));
    } catch (e) {
      debugPrint('store profile unavailable: $e');
    }
  }

  void clear() {
    _revision++;
    Access.clear();
    StoreContext.invalidate();
    live = false;
    profile = const {};
    name = phone = city = address = contactName = contactRole = '';
    businessTypes = const [];
    // 换账号 / 退出登录后不保留上一家店的挂单和识别结果
    HoldStore.reset();
    CatalogCounts.cards = null;
    CatalogCounts.packages = null;
    ServiceStore.clear();
    accountPhone = '';
    notifyListeners();
  }
}

final StoreProfile storeProfile = StoreProfile();
