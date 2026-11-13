import 'dart:math' as math;

import 'expense_controller.dart';

extension ExpenseFormatting on ExpenseController {
  num get viewPrevious => previousSpent();
  String get viewChange => viewPrevious == 0
      ? "—"
      : "${((spent() - viewPrevious) * 100 / viewPrevious).toStringAsFixed(1)}%";
  num get viewCategoryAmount => cat["amount"] as num;
  num get viewUsed => spent(category);
  num get viewExcess => math.max(0, viewUsed - viewCategoryAmount);
  String get spendingText => spent().toStringAsFixed(2);
  String get changeText => '较上月 $viewChange';
  String get revenueText => expenseMoney(revenue);
  String get profitText => expenseMoney(revenue - spent());
  String get marginText => revenue == 0
      ? '—'
      : '${((revenue - spent()) * 100 / revenue).toStringAsFixed(1)}%';
  String get budgetUsageText =>
      total == 0 ? '未设预算' : '预算 ${(spent() * 100 / total).toStringAsFixed(1)}%';
  String get unpaidText =>
      '待付款 ${entries.where((e) => e['status'] == 'unpaid').length}';
  String get rentText => expenseMoney(spent('房租'));
  String get laborText => expenseMoney(spent('人工'));
  String get materialsText => expenseMoney(spent('材料采购'));
  String get utilityText => expenseMoney(spent('水电'));
  String get marketingText => expenseMoney(spent('营销推广'));
  String get otherText =>
      expenseMoney(spent('其他') + spent('税费') + spent('设备维修') + spent('损耗'));
  String get monthlyBudgetText => '本月总预算 ${expenseMoney(total)}';
  String get usagePercentText =>
      total == 0 ? '—' : '${(spent() * 100 / total).toStringAsFixed(1)}%';
  String get usedText => expenseMoney(spent());
  String get remainingText => expenseMoney(total - spent());
  String get daysLeftText =>
      '${math.max(0, DateTime(DateTime.parse(month).year, DateTime.parse(month).month + 1, 0).day - DateTime.now().day)} 天';
  String get overspendText =>
      categories.keys
          .where((k) => spent(k) > (categories[k]['amount'] as num))
          .isEmpty
      ? '当前预算未超支'
      : '${categories.keys.where((k) => spent(k) > (categories[k]['amount'] as num)).join('、')}已超支';
  String get categoryTitle => '$category预算';
  String get categoryLabel => category;
  String get categoryKindText =>
      '${['房租', '人工', '税费'].contains(category) ? '固定' : '变动'}开支 · 每月预算';
  String get categoryBalanceText =>
      '${viewUsed > viewCategoryAmount ? '超支' : '剩余'} ${expenseMoney((viewUsed - viewCategoryAmount).abs())}';
  String get categoryBudgetText => '预算 ${expenseMoney(viewCategoryAmount)}';
  String get categoryAmountText => expenseMoney(viewCategoryAmount);
  String get categoryExcessText => expenseMoney(viewExcess);
  String get previousCategoryText =>
      '上月实际 ${expenseMoney(previousSpent(category))}';
  String get categoryTenPercentText =>
      '+10% ${expenseMoney(viewCategoryAmount * 1.1)}';
  String get categoryShareText =>
      '按上月占比 ${expenseMoney(viewPrevious == 0 ? 0 : total * previousSpent(category) / viewPrevious)}';
  String get categoryRestoreText =>
      '恢复 ${expenseMoney((board['budget']?['categories']?[category]?['amount'] as num?) ?? 0)}';
  String get savedTotalText =>
      '保存后总预算为 ${expenseMoney(math.max(total, allocated))}';
  String get categoryBudgetLineText =>
      '预算线 ${expenseMoney(viewCategoryAmount)}';
  String get categoryHistoryText =>
      '近 6 个月累计支出 ${expenseMoney(expenseMaps(board['history']).where((h) => h['category'] == category).fold<num>(0, (n, h) => n + (h['amount'] as num)))}';
  String get categoryCountText =>
      '共 ${entries.where((e) => e['category'] == category).length} 笔';
  String get totalInputLabel => '${DateTime.parse(month).month} 月总预算（元）';
  String get previousBudgetText =>
      '上月预算 ${expenseMoney(board['previous_budget']?['total'] as num? ?? 0)}';
  String get revenueShareText => revenue == 0
      ? '本月暂无营收'
      : '占本月营收 ${(total * 100 / revenue).toStringAsFixed(1)}%';
  String get allocationTextSummary =>
      '已分配 ${expenseMoney(allocated)} · 未分配 ${expenseMoney(total - allocated)}';
  String get adjustTitle => '追加预算 · $category';
  String get fillExcessText => '补齐超支 ${expenseMoney(viewExcess)}';
  String get reserveText => '总预算余额 ${expenseMoney(total - allocated)}';
  String get sourceLabel => '从 $sourceCategory 调剂';
  String get entryAmountText =>
      '−${expenseMoney(draft['amount'] as num? ?? 0)}';
  String get paymentStatusText => draft['status'] == 'paid' ? '已付款' : '挂账待付';
  String get entryDateText => '${draft['occurred_on']}';
  String get entryAccountText => '${draft['account']}';
  String get entryPayeeText => '${draft['payee']}';
  String get entryOperatorText => '${draft['operator'] ?? '—'}';
  String get sourceDocumentText => draft['source_document'] == null
      ? '手工记账'
      : '库存单 ${'${draft['source_document']}'.substring(0, 8)}';
  String get entryNoteText => '${draft['note'] ?? ''}';
  String get repeatExplanation => '到期自动生成待付款记录，确认付款后可编辑状态';
}
