import 'expense_controller.dart';

extension ExpenseFormatting on ExpenseController {
  num get viewPrevious => previousSpent();
  String get viewChange => viewPrevious == 0
      ? "—"
      : "${((spent() - viewPrevious) * 100 / viewPrevious).toStringAsFixed(1)}%";
  String get spendingText => spent().toStringAsFixed(2);
  String get changeText => '较上月 $viewChange';
  String get revenueText => expenseMoney(revenue);
  String get profitText => expenseMoney(revenue - spent());
  String get marginText => revenue == 0
      ? '—'
      : '${((revenue - spent()) * 100 / revenue).toStringAsFixed(1)}%';
  String get unpaidText =>
      '待付款 ${entries.where((e) => e['status'] == 'unpaid').length}';
  String get rentText => expenseMoney(spent('房租'));
  String get laborText => expenseMoney(spent('人工'));
  String get materialsText => expenseMoney(spent('材料采购'));
  String get utilityText => expenseMoney(spent('水电'));
  String get marketingText => expenseMoney(spent('营销推广'));
  String get otherText =>
      expenseMoney(spent('其他') + spent('税费') + spent('设备维修') + spent('损耗'));
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
