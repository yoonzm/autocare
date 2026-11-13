import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';

class MemberFilters {
  final Set<String> tierIds;
  final int balance, visit;
  MemberFilters({
    Set<String> tierIds = const {},
    this.balance = 0,
    this.visit = -1,
  }) : tierIds = Set.unmodifiable(tierIds);
  bool get active => tierIds.isNotEmpty || balance != 0 || visit != -1;
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
    filters = MemberFilters(
      tierIds: {
        for (final i in values)
          if (i >= 0 && i < tiers.length) '${tiers[i]['id']}',
      },
      balance: filters.balance,
      visit: filters.visit,
    );
    _changed();
  }

  void chooseBalance(int value) {
    filters = MemberFilters(
      tierIds: filters.tierIds,
      balance: value,
      visit: filters.visit,
    );
    _changed();
  }

  void chooseVisit(int value) {
    filters = MemberFilters(
      tierIds: filters.tierIds,
      balance: filters.balance,
      visit: value,
    );
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

  void unsupported(BuildContext context, int _) {
    // TODO: members list 尚无次卡状态/车辆项目筛选参数，不能假装应用条件。
    AppToast.show(context, '次卡状态、车辆与项目筛选暂未接通');
    notifyListeners();
  }

  @override
  void dispose() {
    disposed = true;
    _version++;
    _debounce?.cancel();
    super.dispose();
  }
}
