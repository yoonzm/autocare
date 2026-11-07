import 'dart:async';

import 'package:flutter/foundation.dart';

import '../mock/store_state.dart';
import 'hold_flow.dart';
import 'merchant_api.dart';
import 'scan_flow.dart';
import 'service_store.dart';

/// The signed-in owner's store as stored in the backend.
///
/// Until [load] succeeds ([live] is false), pages keep showing the design's
/// sample data, so the prototype stays browsable offline and in tests.
class StoreProfile extends ChangeNotifier {
  bool live = false;
  String name = '';
  String phone = '';
  String city = '';
  String address = '';
  String contactName = '';
  String contactRole = '';
  String bayRange = '';
  String plan = 'trial';
  List<String> businessTypes = const [];
  DateTime? trialEndsAt;

  /// 开通时按主营业务给新门店生成的服务项目数（「开通成功」页展示）。
  int seededServices = 12;

  /// 11-digit mainland number, e.g. `13988888812` (the backend keeps `+86…`).
  String get localPhone {
    final d = phone.replaceAll(RegExp(r'\D'), '');
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

  String get planText => plan == 'trial' ? '专业版 · 试用' : '专业版';

  /// `2026.11.14`, or `—` when the account has no trial end date.
  String get trialEndText {
    final t = trialEndsAt?.toLocal();
    if (t == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}.${two(t.month)}.${two(t.day)}';
  }

  /// 设置页 / 门店信息里的套餐行。
  String get expiryLine => plan == 'trial' ? '专业版 · 试用至 $trialEndText' : '专业版';

  String get addressText =>
      [city, address].where((s) => s.isNotEmpty).join(' ');

  void apply(Map<String, dynamic> s) {
    live = true;
    name = (s['name'] as String?) ?? '';
    phone = (s['phone'] as String?) ?? '';
    city = (s['city'] as String?) ?? '';
    address = (s['address'] as String?) ?? '';
    contactName = (s['contact_name'] as String?) ?? '';
    contactRole = (s['contact_role'] as String?) ?? '';
    bayRange = (s['bay_range'] as String?) ?? '';
    plan = (s['plan'] as String?) ?? 'trial';
    businessTypes = List<String>.from(
      (s['business_types'] as List?) ?? const [],
    );
    final t = s['trial_ends_at'] as String?;
    trialEndsAt = t == null ? null : DateTime.tryParse(t);
    notifyListeners();
  }

  /// Fetches the profile after sign-in. Failures leave the sample data in place.
  Future<void> load() async {
    if (!merchantApi.hasSession) return;
    try {
      apply(await merchantApi.getStore());
      // 服务项目几乎每个页面都要用：读到门店资料后预加载进全局缓存
      unawaited(ServiceStore.load().then((_) {}, onError: (_) {}));
    } catch (e) {
      debugPrint('store profile unavailable: $e');
    }
  }

  void clear() {
    live = false;
    name = phone = city = address = contactName = contactRole = bayRange = '';
    plan = 'trial';
    businessTypes = const [];
    trialEndsAt = null;
    // 换账号 / 退出登录后不保留上一家店的挂单和识别结果
    HoldFlow.reset();
    ScanFlow.last = null;
    ServiceStore.clear();
    MockStores.reset();
    notifyListeners();
  }
}

final StoreProfile storeProfile = StoreProfile();
