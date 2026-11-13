import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../backend/merchant_api.dart';
import '../../../kit/async_kit.dart';
import '../member_events.dart';
import 'member_package_route_data.dart';
import 'package_extend_sheet.dart';
import 'owned_package_view.dart';

class MemberPackageController extends ChangeNotifier {
  static const days = [30, 60, 90];
  static const extendReasons = ['会员长期出差', '门店服务延误', '其他'];
  final MemberPackageRouteData data;
  Map<String, dynamic> row;
  int daysIndex = 0, reasonIndex = -1;
  bool busy = false, disposed = false;
  String? _intent, _requestId;
  MemberPackageController(this.data, Map<String, dynamic> row)
    : row = Map.from(row);
  OwnedPackageView get view =>
      OwnedPackageView(row, member: data.member, extendDays: days[daysIndex]);
  String get actionKey => 'member-package-${identityHashCode(this)}';
  void apply(Map<String, dynamic> value) {
    if (!disposed) row = Map.from(value);
  }

  void chooseDays(BuildContext context, int index) {
    if (busy) return;
    if (index >= days.length) {
      // TODO: 预期 extend.days 已支持，缺少自定义天数输入；不以默认天数代替。
      AppToast.show(context, '自定义延期天数暂未接通：缺少天数输入');
    } else {
      daysIndex = index;
    }
    notifyListeners();
  }

  void chooseReason(int index) {
    if (!busy) {
      reasonIndex = index;
      notifyListeners();
    }
  }

  Future<void> openExtend(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    routeSettings: RouteSettings(name: 'sheet:PackageExtend'),
    builder: (_) {
      final args = MemberPackageRouteData(
        id: data.id,
        member: data.member,
        package: row,
      );
      return SingleChildScrollView(child: PackageExtendSheet(data: args));
    },
  );
  Future<void> submit(BuildContext context) => runBusy(actionKey, () async {
    if (busy || disposed) return;
    final reasons = extendReasons;
    if (reasonIndex < 0 || reasonIndex >= reasons.length) {
      AppToast.show(context, '请选择延期原因');
      return;
    }
    final intent = jsonEncode({
      'id': data.id,
      'value': days[daysIndex],
      'reason': reasons[reasonIndex],
    });
    if (_intent != intent) {
      _intent = intent;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      await merchantApi.extendPackage(
        id: data.id,
        requestId: _requestId,
        days: days[daysIndex],
        reason: reasons[reasonIndex],
      );
      _intent = null;
      _requestId = null;
      memberChanged.value++;
      if (!context.mounted || disposed) return;
      AppToast.show(context, '已延期 ${days[daysIndex]} 天');
      final nav = Navigator.of(context);
      nav.pop();
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  });
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
