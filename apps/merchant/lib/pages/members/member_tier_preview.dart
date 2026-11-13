import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import '../../widgets/choice_controls.dart';

/// 只展示本店真实卡种；开户实际等级仍由后端决定。
class MemberTierPreview extends StatelessWidget {
  const MemberTierPreview({super.key});

  Future<List<Map<String, dynamic>>> _load() async {
    final rows = await merchantApi.list('cards');
    num threshold(Map<String, dynamic> row) =>
        (row['upgrade_recharge'] as num? ?? 0) +
        (row['upgrade_cumulative'] as num? ?? 0);
    rows.sort((a, b) {
      final aHas =
          a['upgrade_recharge'] != null || a['upgrade_cumulative'] != null;
      final bHas =
          b['upgrade_recharge'] != null || b['upgrade_cumulative'] != null;
      if (aHas != bHas) return aHas ? 1 : -1;
      final byThreshold = threshold(a).compareTo(threshold(b));
      return byThreshold != 0
          ? byThreshold
          : '${a['created_at'] ?? ''}'.compareTo('${b['created_at'] ?? ''}');
    });
    return rows;
  }

  String _rule(Map<String, dynamic> row) => [
    if (row['upgrade_recharge'] != null)
      '充值 ¥${formatMoney(row['upgrade_recharge'])}',
    if (row['upgrade_cumulative'] != null)
      '消费 ¥${formatMoney(row['upgrade_cumulative'])}',
  ].join('\n或');

  @override
  Widget build(BuildContext context) => AsyncView<List<Map<String, dynamic>>>(
    load: _load,
    shrinkWrap: true,
    inlineError: true,
    skeletonScrollable: false,
    skeletonPadding: EdgeInsets.zero,
    isEmpty: (rows) => rows.isEmpty,
    skeleton: const AppSkeleton(height: 66),
    empty: (_) => const EmptyView.firstTime(title: '请先设置会员卡种'),
    builder: (context, rows) => HTierPicker(
      labels: [for (final row in rows) '${row['name']}'],
      rules: [for (final row in rows) _rule(row)],
      onChanged: (_) => AppToast.show(context, '会员等级由后台按门店规则开通与升级'),
    ),
  );
}
