import 'package:flutter/material.dart';

import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppButton, AppButtonKind, AppButtonSize;

import '../../theme.dart';

/// 入库明细里「到期日」的选择弹层（设计稿 StockInExpiry）。
/// 返回 `YYYY-MM-DD`；取消返回 null。
Future<String?> pickExpiryDate(
  BuildContext context, {
  required String productName,
  required DateTime received,
  String? current,
  int? shelfMonths,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: C.card,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
  ),
  builder: (ctx) => SafeArea(
    child: _ExpirySheet(
      productName: productName,
      received: received,
      current: current,
      shelfMonths: shelfMonths,
    ),
  ),
);

DateTime addMonths(DateTime d, int n) {
  final month = d.month - 1 + n;
  final year = d.year + month ~/ 12;
  final m = month % 12 + 1;
  final last = DateTime(year, m + 1, 0).day;
  return DateTime(year, m, d.day > last ? last : d.day);
}

String _dotted(DateTime d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

class _ExpirySheet extends StatefulWidget {
  final String productName;
  final DateTime received;
  final String? current;
  final int? shelfMonths;
  const _ExpirySheet({
    required this.productName,
    required this.received,
    this.current,
    this.shelfMonths,
  });
  @override
  State<_ExpirySheet> createState() => _ExpirySheetState();
}

class _ExpirySheetState extends State<_ExpirySheet> {
  List<int> get _quick {
    final sm = widget.shelfMonths;
    final list = <int>[if (sm != null && sm > 0) sm, 12, 24, 36];
    return list.toSet().toList();
  }

  late final DateTime _received = DateTime(
    widget.received.year,
    widget.received.month,
    widget.received.day,
  );
  late DateTime _picked;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final parsed = DateTime.tryParse(widget.current ?? '');
    final defaultMonths =
        (widget.shelfMonths != null && widget.shelfMonths! > 0)
        ? widget.shelfMonths!
        : 12;
    _picked = parsed == null
        ? addMonths(_received, defaultMonths)
        : DateTime(parsed.year, parsed.month, parsed.day);
    _month = DateTime(_picked.year, _picked.month);
  }

  String get _summary {
    final today = DateTime.now();
    final days = _picked
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    final about = days >= 30 ? '约 ${(days / 30.4).round()} 个月' : '$days 天';
    return '已选 ${_dotted(_picked)} · 距今$about';
  }

  @override
  Widget build(BuildContext context) {
    final first = DateTime(_month.year, _month.month);
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final lead = first.weekday % 7; // 周日在前
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: C.stroke,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text('选择到期日', style: ts(20, w: FontWeight.w600, h: 28)),
            Text(
              widget.shelfMonths != null && widget.shelfMonths! > 0
                  ? '${widget.productName} · 保质期 ${widget.shelfMonths} 个月'
                  : widget.productName,
              style: ts(13, color: C.muted, h: 18),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 14),
            Text(
              '按入库日期 ${_received.month.toString().padLeft(2, '0')}.${_received.day.toString().padLeft(2, '0')} 推算',
              style: ts(12, color: C.muted, h: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final n in _quick) ...[
                  if (n != _quick.first) const SizedBox(width: 8),
                  _chip(n),
                ],
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _arrow(Icons.chevron_left_rounded, '上个月', -1),
                Expanded(
                  child: Text(
                    '${_month.year} 年 ${_month.month} 月',
                    textAlign: TextAlign.center,
                    style: ts(15, w: FontWeight.w600, h: 22),
                  ),
                ),
                _arrow(Icons.chevron_right_rounded, '下个月', 1),
              ],
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.45,
              children: [
                for (final w in const ['日', '一', '二', '三', '四', '五', '六'])
                  Center(
                    child: Text(w, style: ts(12, color: C.muted)),
                  ),
                for (var i = 0; i < lead; i++) const SizedBox.shrink(),
                for (var d = 1; d <= days; d++)
                  _day(DateTime(_month.year, _month.month, d)),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: C.greenSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _summary,
                style: ts(13, w: FontWeight.w500, color: C.greenInk, h: 18),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: '取消',
                    kind: AppButtonKind.secondary,
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    label: '确定',
                    size: AppButtonSize.large,
                    expanded: true,
                    onPressed: () => Navigator.pop(
                      context,
                      '${_picked.year}-${_picked.month.toString().padLeft(2, '0')}-${_picked.day.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(int months) {
    final on = _picked == addMonths(_received, months);
    final isShelf = widget.shelfMonths != null && months == widget.shelfMonths;
    return GestureDetector(
      onTap: () => setState(() {
        _picked = addMonths(_received, months);
        _month = DateTime(_picked.year, _picked.month);
      }),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? C.primarySoft : C.inset,
          borderRadius: BorderRadius.circular(18),
          border: on
              ? Border.all(color: C.primary, width: 1.5)
              : isShelf
              ? Border.all(color: C.primary.withValues(alpha: 0.45), width: 1)
              : null,
        ),
        child: Text(
          isShelf ? '+$months 个月 · 保质期' : '+$months 个月',
          style: ts(
            13,
            w: on ? FontWeight.w600 : FontWeight.w500,
            color: on ? C.primaryInk : C.sub,
          ),
        ),
      ),
    );
  }

  Widget _arrow(IconData icon, String label, int delta) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () =>
          setState(() => _month = DateTime(_month.year, _month.month + delta)),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 22, color: C.sub),
      ),
    ),
  );

  Widget _day(DateTime d) {
    final selected = d == _picked;
    final disabled = d.isBefore(_received);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => setState(() => _picked = d),
      child: Center(
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: selected
              ? const BoxDecoration(color: C.primary, shape: BoxShape.circle)
              : null,
          child: Text(
            '${d.day}',
            style: ts(
              15,
              w: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected
                  ? Colors.white
                  : disabled
                  ? C.faint
                  : C.ink,
            ),
          ),
        ),
      ),
    );
  }
}
