import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../mock/app_state.dart';
import '../routes.dart';
import 'merchant_api.dart';
import 'store_profile.dart';

class SubscriptionFlow extends ChangeNotifier {
  Map<String, dynamic> data = {}, receipt = {};
  String plan = 'pro';
  int months = 12;
  String? _request, _signature;
  void reset() {
    data = {};
    receipt = {};
    plan = 'pro';
    months = 12;
    _request = _signature = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> get plans =>
      List<Map<String, dynamic>>.from((data['plans'] as List?) ?? const []);
  Map<String, dynamic> offer([String? kind]) =>
      plans.where((p) => p['kind'] == (kind ?? plan)).firstOrNull ?? {};
  int amount([String? kind, int? duration]) {
    final p = offer(kind);
    final m = duration ?? months;
    return ((p[m == 1
                    ? 'monthly_fee'
                    : m == 3
                    ? 'quarterly_fee'
                    : 'fee']
                as num?) ??
            0)
        .toInt();
  }

  String currency(num cents) => '¥${(cents / 100).toStringAsFixed(2)}';
  void select(String kind) {
    plan = kind;
    notifyListeners();
  }

  void duration(int value) {
    months = value;
    notifyListeners();
  }

  Future<Map<String, dynamic>> load() async {
    data = await merchantApi.subscriptionCatalog();
    notifyListeners();
    return data;
  }

  String date(Object? value) {
    final at = DateTime.tryParse('${value ?? ''}')
        ?.toUtc()
        .add(const Duration(hours: 8));
    return at == null
        ? '—'
        : '${at.year}.${at.month.toString().padLeft(2, '0')}.${at.day.toString().padLeft(2, '0')}';
  }

  String text(String key) {
    final p = offer();
    if (key.startsWith('table:')) {
      final parts = key.split(':');
      final o = offer(parts[1]);
      final feature = parts[2];
      if (feature == 'storeCount') return '${o['store_limit'] ?? '—'}';
      if (feature == 'staffCount') return '${o['staff_limit'] ?? '不限'}';
      if (feature == 'smsCount') return o['sms'] == true ? '已开通' : '未开通';
      final flags = Map<String, dynamic>.from((o['features'] as Map?) ?? {});
      return flags[feature] == true ? '✓' : '—';
    }
    if (key.startsWith('offer:')) {
      final parts = key.split(':');
      final o = offer(parts[1]);
      if (parts[2] == 'price') {
        return currency(
          months == 1 ? amount(parts[1], 1) : amount(parts[1], 12) / 12,
        );
      }
      if (parts[2] == 'total') {
        return '${months == 1 ? '月付' : '年付'} ${currency(amount(parts[1], months == 1 ? 1 : 12))}';
      }
      if (parts[2] == 'limits') {
        return '${o['store_limit'] ?? '—'} 家门店 · ${o['staff_limit'] == null ? '员工数不限' : '${o['staff_limit']} 个员工账号'}';
      }
      if (parts[2] == 'name') return '${o['name'] ?? '—'}';
    }
    switch (key) {
      case 'name':
        return '${p['name'] ?? '—'}';
      case 'priceUnit':
        return months == 12 ? '/月 · 年付' : '/月 · 月付';
      case 'cycle':
        return months == 12 ? '年付' : '月付';
      case 'selectedLimits':
        return '${p['store_limit'] ?? '—'} 家门店 · 账号共享订阅';
      case 'selectedPeriod':
        return '${p['name'] ?? '—'} $months 个月';
      case 'unavailableSms':
        return '短信权益暂未开通';
      case 'unavailableNotice':
        return '预约管理（消息通知未开通）';
      case 'unavailableExport':
        return '开支管理与预算（导出未开通）';
      case 'unavailableShared':
        return '多门店独立管理（跨店会员未开通）';
      case 'refundUnavailable':
        return '退款尚未开通';
      case 'upgradePolicy':
        return '按所选周期计费，保留剩余时长';
      case 'support':
        return '服务支持请联系平台';
      case 'amount':
        return currency(amount());
      case 'month':
        return currency(amount(null, 1));
      case 'quarter':
        return currency(amount(null, 3));
      case 'year':
        return currency(amount(null, 12));
      case 'original':
        return currency(amount(null, 1) * months);
      case 'discount':
        return '-${currency(amount(null, 1) * months - amount())}';
      case 'coupon':
        return '暂无可用优惠券';
      case 'zero':
        return '¥0.00';
      case 'renewTitle':
        return '续费 · ${p['name'] ?? '—'}';
      case 'payLabel':
        return '确认支付 ${currency(amount())}';
      case 'annualHint':
        return '按后端套餐价格计算，无额外优惠券';
      case 'simulation':
        return '模拟支付（暂不扣款）';
      case 'resultAmount':
        return currency((receipt['amount'] as num?) ?? 0);
      case 'resultName':
        return '${receipt['name'] ?? '—'} · ${receipt['months'] ?? '—'} 个月';
      case 'resultPeriod':
        return '${date(receipt['starts_at'])} – ${date(receipt['ends_at'])}';
      case 'resultEnd':
        return date(receipt['ends_at']);
      case 'resultId':
        return '${receipt['id'] ?? '—'}';
      case 'notEnabled':
        return '暂未开通';
    }
    return key;
  }

  Future<void> pay(BuildContext context, {required bool renew}) async {
    final p = offer();
    final body = {
      'plan': plan,
      'version': p['version'],
      'months': months,
      'revision': data['revision'],
      'mode': renew ? 'renew' : 'subscribe',
    };
    final signature = jsonEncode(body);
    if (_signature != signature) {
      _signature = signature;
      _request = MerchantApi.newRequestId();
    }
    try {
      receipt = await merchantApi.simulateSubscription(
        body,
        requestId: _request!,
      );
      // Server receipt is the authority. A subsequent profile fetch failure must
      // not turn an already successful purchase into another charge attempt.
      storeProfile.plan = '${receipt['plan']}';
      storeProfile.trialEndsAt = DateTime.parse('${receipt['ends_at']}');
      storeProfile.subscription = {
        ...p,
        'ends_at': receipt['ends_at'],
        'source': 'simulation',
      };
      storeProfile.notifyListeners();
      subState.value = SubState.normal;
      notifyListeners();
      if (context.mounted) openRoute(context, renew ? 'RenewPaid' : 'PlanPaid');
      unawaited(storeProfile.load());
    } catch (e) {
      final error = AppError.from(e);
      if (error.message.contains('价格已更新') || error.message.contains('订阅已变化')) {
        try {
          await load();
          if (renew) {
            plan = '${(data['subscription'] as Map)['plan']}';
            notifyListeners();
          }
        } catch (_) {
          /* Keep the original failure and allow an explicit retry. */
        }
        if (context.mounted) AppToast.show(context, '套餐或订阅已更新，请核对金额后重新提交');
      } else if (context.mounted) {
        AppToast.error(context, e);
      }
    }
  }
}

final subscriptionFlow = SubscriptionFlow();
