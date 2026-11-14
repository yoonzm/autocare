import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';

class MemberFilters {
  final Set<String> tierIds;
  final int balance, visit, packageStatus, vehicleProject;
  MemberFilters({
    Set<String> tierIds = const {},
    this.balance = 0,
    this.visit = -1,
    this.packageStatus = -1,
    this.vehicleProject = -1,
  }) : tierIds = Set.unmodifiable(tierIds);
  bool get active =>
      tierIds.isNotEmpty ||
      balance != 0 ||
      visit != -1 ||
      packageStatus != -1 ||
      vehicleProject != -1;
  MemberFilters copyWith({
    Set<String>? tierIds,
    int? balance,
    int? visit,
    int? packageStatus,
    int? vehicleProject,
  }) => MemberFilters(
    tierIds: tierIds ?? this.tierIds,
    balance: balance ?? this.balance,
    visit: visit ?? this.visit,
    packageStatus: packageStatus ?? this.packageStatus,
    vehicleProject: vehicleProject ?? this.vehicleProject,
  );

  /// 与后端 `package_status` 对应：7 天内到期 / 剩余 ≤ 2 次 / 已用完。
  String? get packageStatusKey => packageStatus >= 0 && packageStatus < 3
      ? const ['expiring', 'low', 'used_up'][packageStatus]
      : null;

  /// 与后端 `vehicle_project` 对应：新能源车主 / 做过镀晶 / 车衣质保中 / 多辆车。
  String? get vehicleProjectKey => vehicleProject >= 0 && vehicleProject < 4
      ? const ['ev', 'coating', 'wrap_warranty', 'multi'][vehicleProject]
      : null;
  num? get min => const <num?>[null, null, 500, 2000][balance];
  num? get max => const <num?>[null, 500, 2000, null][balance];
  int? get within => visit == 0
      ? 7
      : visit == 1
      ? 30
      : null;
  int? get over => visit == 2
      ? 60
      : visit == 3
      ? 90
      : null;
}

class MemberFilterController extends ChangeNotifier {
  List<Map<String, dynamic>> tiers = [];
  MemberFilters filters;
  int? matched;
  AppError? countError;
  bool disposed = false;
  int _version = 0;
  Timer? _debounce;
  MemberFilterController(this.filters);
  Set<int> get tierIndices => {
    for (var i = 0; i < tiers.length; i++)
      if (filters.tierIds.contains('${tiers[i]['id']}')) i,
  };
  Future<List<Map<String, dynamic>>> loadTiers() async {
    final rows = await merchantApi.list('cards');
    num rank(Map<String, dynamic> t) =>
        (num.tryParse('${t['upgrade_recharge'] ?? 0}') ?? 0) * 1000000 +
        (num.tryParse('${t['upgrade_cumulative'] ?? 0}') ?? 0);
    rows.sort((a, b) => rank(a).compareTo(rank(b)));
    return rows;
  }

  void applyTiers(List<Map<String, dynamic>> value) {
    if (disposed) return;
    tiers = value.map((r) => Map<String, dynamic>.unmodifiable(r)).toList();
    refreshCount();
  }

  String tierName(int index) =>
      index < tiers.length ? '${tiers[index]['name'] ?? ''}' : '—';
  void chooseTiers(BuildContext context, Set<int> values) {
    if (values.any((i) => i < 0 || i >= tiers.length)) {
      AppToast.show(context, '本店没有这个卡种');
    }
    filters = filters.copyWith(
      tierIds: {
        for (final i in values)
          if (i >= 0 && i < tiers.length) '${tiers[i]['id']}',
      },
    );
    _changed();
  }

  void chooseBalance(int value) {
    filters = filters.copyWith(balance: value);
    _changed();
  }

  void chooseVisit(int value) {
    filters = filters.copyWith(visit: value);
    _changed();
  }

  void choosePackageStatus(int value) {
    filters = filters.copyWith(packageStatus: value);
    _changed();
  }

  void chooseVehicleProject(int value) {
    filters = filters.copyWith(vehicleProject: value);
    _changed();
  }

  void reset() {
    filters = MemberFilters();
    _changed();
  }

  void _changed() {
    if (!disposed) {
      notifyListeners();
      refreshCount();
    }
  }

  void refreshCount() {
    if (disposed) return;
    final version = ++_version;
    final snapshot = filters;
    matched = null;
    countError = null;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final page = await merchantApi.members(
          cardTypeIds: snapshot.tierIds.toList(),
          balanceMin: snapshot.min,
          balanceMax: snapshot.max,
          visitedWithinDays: snapshot.within,
          visitedOverDays: snapshot.over,
          packageStatus: snapshot.packageStatusKey,
          vehicleProject: snapshot.vehicleProjectKey,
          limit: 1,
        );
        if (!disposed && version == _version) {
          matched = page.matched;
          notifyListeners();
        }
      } catch (e) {
        if (!disposed && version == _version) {
          countError = AppError.from(e);
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    disposed = true;
    _version++;
    _debounce?.cancel();
    super.dispose();
  }
}
