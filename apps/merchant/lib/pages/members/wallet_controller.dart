import 'member_picker_sheet.dart';
import 'recharge_pick_sheet.dart';
import 'member_route_data.dart';

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/member_flow.dart' show money2;
import '../../backend/package_calc.dart' show PackageRowInfo, formatMoney;
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_events.dart';
import 'member_view.dart';

class WalletReceipt {
  final Map<String, dynamic> member, data;
  final bool sale;
  const WalletReceipt._(this.member, this.data, this.sale);
  WalletReceipt({
    required Map<String, dynamic> member,
    required Map<String, dynamic> data,
    required bool sale,
  }) : this._(Map.unmodifiable(member), Map.unmodifiable(data), sale);
}

class WalletController extends ChangeNotifier {
  static const methods = ['微信', '支付宝', '现金', 'POS 刷卡'];
  static const saleMethods = [...methods, '会员余额'];
  Map<String, dynamic>? member;
  final custom = TextEditingController();
  int tab, preset = 1, method = 0, saleMethod = 0;
  List<Map<String, dynamic>> options = [], packages = [];
  String packageId = '';
  bool busy = false, disposed = false;
  final ready = <int>{};
  String? _body, _requestId;
  WalletController({Map<String, dynamic>? member, this.tab = 0})
    : member = member == null ? null : Map.unmodifiable(member) {
    custom.addListener(_changed);
  }
  void _changed() {
    if (!disposed) notifyListeners();
  }

  String get actionKey => 'wallet-${identityHashCode(this)}';
  MemberView get memberView => MemberView(member ?? const {});
  int get presetIndex => custom.text.trim().isEmpty ? preset : -1;
  void selectTab(int value) {
    if (!busy) {
      tab = value;
      _changed();
    }
  }

  void selectPreset(int value) {
    if (busy || value < 0 || value >= options.length) return;
    preset = value;
    custom.clear();
    _changed();
  }

  void selectMethod(int value) {
    if (!busy) {
      method = value;
      _changed();
    }
  }

  void selectSaleMethod(int value) {
    if (!busy) {
      saleMethod = value;
      _changed();
    }
  }

  void selectPackage(String value) {
    if (!busy) {
      packageId = value;
      _changed();
    }
  }

  void selectMember(Map<String, dynamic> value) {
    if (!busy && !disposed) {
      member = Map.unmodifiable(value);
      _changed();
    }
  }

  Future<Map<String, dynamic>> loadOptions(int selectedTab) async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    final rows = selectedTab == 0
        ? await merchantApi.rechargeOptions()
        : await merchantApi.list('packages');
    return {
      'items': [
        for (final row in rows)
          if (selectedTab == 0 || row['active'] != false) row,
      ],
    };
  }

  void applyOptions(int selectedTab, Map<String, dynamic> response) {
    if (disposed) return;
    final rows = [
      for (final row in response['items'] as List)
        Map<String, dynamic>.from(row),
    ];
    if (selectedTab == 0) {
      options = rows;
      preset = rows.isEmpty ? -1 : preset.clamp(0, rows.length - 1);
    } else {
      packages = rows;
      if (!rows.any((row) => row['id'] == packageId)) {
        packageId = rows.isEmpty ? '' : '${rows.first['id']}';
      }
    }
    ready.add(selectedTab);
  }

  String amountLabel(int index) => index < options.length
      ? '¥${formatMoney(options[index]['amount'])}'
      : '—';
  String giftLabel(int index) => index < options.length
      ? '送 ¥${formatMoney(options[index]['gift'])}'
      : '—';
  num get amount => custom.text.trim().isNotEmpty
      ? num.tryParse(custom.text.replaceAll(',', '')) ?? 0
      : preset >= 0 && preset < options.length
      ? (options[preset]['amount'] as num)
      : 0;
  num get gift =>
      custom.text.trim().isNotEmpty || preset < 0 || preset >= options.length
      ? 0
      : options[preset]['gift'] as num;
  num get balance => member?['balance'] as num? ?? 0;
  String get amountText => '¥${money2(amount)}';
  String get afterText => '¥${money2(balance + amount + gift)}';
  String get payLine => '实收 · 到账 ¥${formatMoney(amount + gift)}';
  Map<String, dynamic>? get selectedPackage =>
      packages.where((p) => p['id'] == packageId).firstOrNull;
  PackageRowInfo? get _package =>
      selectedPackage == null ? null : PackageRowInfo(selectedPackage!);
  String get saleOriginal => '¥${formatMoney(_package?.original ?? 0)}';
  String get saleSaving =>
      '−¥${formatMoney(((_package?.original ?? 0) - (_package?.price ?? 0)).clamp(0, double.infinity))}';
  String get saleDue => '¥${money2(_package?.price ?? 0)}';
  String get saleConfirm => '确认收款 ¥${formatMoney(_package?.price ?? 0)}';
  String get saleBalanceChip => '储值余额 ¥${formatMoney(balance)}';
  String get saleAll => '查看全部 ${packages.length} 个在售套餐';

  Future<void> chooseMember(BuildContext context) async {
    final selected = await showMemberPicker(context);
    if (selected != null && !disposed) selectMember(selected);
  }

  Future<void> choosePackage(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SingleChildScrollView(
        child: RechargePickSheet(packages: packages, initial: packageId),
      ),
    );
    if (selected != null && !disposed) selectPackage(selected);
  }

  void openMember(BuildContext context) {
    if (member != null) {
      openRoute(
        context,
        'MemberDetail',
        arguments: MemberRouteData(member: member),
      );
    }
  }

  Future<WalletReceipt?> pay({required bool sale}) async {
    if (busy || disposed) return null;
    final customer = member;
    if (customer?['id'] == null) throw const AppError('请先选择会员');
    if (!ready.contains(sale ? 1 : 0)) throw const AppError('请先读取收款配置');
    final selected = selectedPackage;
    final submittedAmount = amount;
    final payment = sale ? saleMethods[saleMethod] : methods[method];
    if (sale && selected == null) throw const AppError('请选择次卡套餐');
    if (!sale && submittedAmount <= 0) throw const AppError('请选择或输入充值金额');
    final intent = jsonEncode({
      'sale': sale,
      'member': customer!['id'],
      'value': sale ? selected!['id'] : submittedAmount,
      'method': payment,
    });
    if (_body != intent) {
      _body = intent;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    _changed();
    try {
      final data = sale
          ? await merchantApi.sellPackage(
              memberId: '${customer['id']}',
              packageId: '${selected!['id']}',
              method: payment,
              requestId: _requestId,
            )
          : await merchantApi.recharge(
              memberId: '${customer['id']}',
              amount: submittedAmount,
              method: payment,
              requestId: _requestId,
            );
      // 收款成功后刷新资料失败，仍必须交付这次真实回执，不能提示重试收款。
      _body = null;
      _requestId = null;
      var refreshed = Map<String, dynamic>.from(customer);
      if (data['balance'] is num) refreshed['balance'] = data['balance'];
      try {
        refreshed = await merchantApi.member('${customer['id']}');
      } catch (_) {
        /* 回执以已提交的服务端结果为准。 */
      }
      memberChanged.value++;
      if (!disposed) member = Map.unmodifiable(refreshed);
      return WalletReceipt(
        member: refreshed,
        sale: sale,
        data: {
          ...data,
          if (!sale) 'amount': submittedAmount,
          if (sale) 'name': selected!['name'],
          'method': payment,
          'at': DateTime.now(),
          'member_name': customer['name'],
        },
      );
    } finally {
      busy = false;
      _changed();
    }
  }

  Future<void> submit(BuildContext context, {required bool sale}) =>
      runBusy(actionKey, () async {
        try {
          final receipt = await pay(sale: sale);
          if (!context.mounted || disposed || receipt == null) return;
          if (receipt.data['upgraded_to'] != null) {
            AppToast.show(context, '已自动升级为${receipt.data['upgraded_to']}');
          }
          openRoute(
            context,
            sale ? 'PackageSold' : 'RechargeSuccess',
            arguments: receipt,
          );
        } catch (e) {
          if (context.mounted && !disposed) AppToast.error(context, e);
        }
      });
  @override
  void dispose() {
    disposed = true;
    custom.dispose();
    super.dispose();
  }
}
