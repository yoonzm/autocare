import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppChoiceGroup, ChoiceItem;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../kit/async_kit.dart' show AppToast;
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../kit/text_input.dart' show MoneyInputFormatter;
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import 'inventory_controller.dart';
import 'stock_out_line_template.dart';

/// 出库类型单选标签（四种类型互斥）。出库页的各种版式共用。
class OutReasonChips extends StatelessWidget {
  final InventoryController c;
  const OutReasonChips({super.key, required this.c});
  @override
  Widget build(BuildContext context) => AppChoiceGroup<String>(
    selected: '${c.payload['reason'] ?? InventoryController.outReasons.first}',
    onChanged: c.setOutReason,
    items: [
      for (final r in InventoryController.outReasons)
        ChoiceItem(value: r, label: r, enabled: !c.busy),
    ],
  );
}

/// 出库 · 损耗报废（设计稿 StockOutScrap）/ 出库 · 退回供应商（设计稿 StockOutReturn）。
/// 与「施工领用 / 内部使用」是同一张出库单，只是按类型换一套版式；这两种没有「关联信息」。
class StockOutVariantPage extends StatefulWidget {
  final InventoryController c;
  const StockOutVariantPage({super.key, required this.c});
  @override
  State<StockOutVariantPage> createState() => _StockOutVariantState();
}

class _StockOutVariantState extends State<StockOutVariantPage> {
  InventoryController get c => widget.c;
  bool get _scrap => c.payload['reason'] == '损耗报废';

  late final _refund = TextEditingController(
    text: c.payload['refund_amount'] is num
        ? (c.payload['refund_amount'] as num).toStringAsFixed(2)
        : '',
  );

  @override
  void dispose() {
    _refund.dispose();
    super.dispose();
  }

  Widget _card(List<Widget> children, {double gap = 14}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: BorderRadius.circular(24),
      boxShadow: softShadow,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in children.indexed) ...[
          if (i > 0) SizedBox(height: gap),
          w,
        ],
      ],
    ),
  );

  Widget _title(String t) => Text(t, style: ts(15, w: FontWeight.w600, h: 22));
  Widget _label(String t, {bool required = false}) => Text.rich(
    TextSpan(
      text: t,
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Color(0xFFD6403F)),
          ),
      ],
    ),
    style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
  );

  Widget _field({required Widget child, VoidCallback? onTap}) =>
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: C.chip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: child,
        ),
      );

  Widget _labeled(String label, Widget child, {bool required = false}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label(label, required: required),
          const SizedBox(height: 6),
          child,
        ],
      );

  Widget _typeCard() => _card([
    _title('出库类型'),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('类型'),
        const SizedBox(height: 8),
        OutReasonChips(c: c),
      ],
    ),
  ]);

  // ── 损耗报废 ──
  Widget _scrapCard() => _card([
    _title('报废原因'),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('原因'),
        const SizedBox(height: 8),
        AppChoiceGroup<String>(
          selected: '${c.payload['scrap_reason'] ?? ''}',
          onChanged: c.setScrapReason,
          items: [
            for (final r in InventoryController.scrapReasons)
              ChoiceItem(value: r, label: r, enabled: !c.busy),
          ],
        ),
      ],
    ),
    _labeled(
      '备注',
      _field(
        child: TextFormField(
          initialValue: '${c.payload['note'] ?? ''}',
          style: ts(15, h: 22),
          maxLength: 200,
          buildCounter: (
            _, {
            required currentLength,
            required isFocused,
            maxLength,
          }) => null,
          decoration: InputDecoration(
            isCollapsed: true,
            border: InputBorder.none,
            hintText: '选填，如：搬运时摔裂',
            hintStyle: ts(15, color: C.muted, h: 22),
          ),
          onChanged: (v) {
            c.payload['note'] = v;
            c.dirty = true;
          },
        ),
      ),
    ),
  ]);

  // ── 退回供应商 ──
  Widget _returnCard() => _card([
    _labeled(
      '供应商',
      _field(
        onTap: c.busy ? null : () => c.pick(context, 'supplier', '供应商'),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${c.payload['supplier'] ?? ''}'.isEmpty
                    ? '请选择供应商'
                    : '${c.payload['supplier']}',
                style: ts(
                  15,
                  color: '${c.payload['supplier'] ?? ''}'.isEmpty
                      ? C.muted
                      : C.ink,
                  h: 22,
                ),
              ),
            ),
            AppIcon('chevronRight', size: 16, color: C.faint),
          ],
        ),
      ),
      required: true,
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('应退金额'),
        const SizedBox(height: 6),
        _field(
          child: Row(
            children: [
              Text('¥ ', style: ts(15, h: 22)),
              Expanded(
                child: TextField(
                  controller: _refund,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    const MoneyInputFormatter(),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  style: ts(15, h: 22),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: ts(15, color: C.muted, h: 22),
                  ),
                  onChanged: (v) {
                    final n = num.tryParse(v.replaceAll(',', ''));
                    if (n == null) {
                      c.payload.remove('refund_amount');
                    } else {
                      c.payload['refund_amount'] = n;
                    }
                    c.dirty = true;
                  },
                ),
              ),
              Text('元', style: ts(14, color: C.muted, h: 20)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // TODO: 退款开支要写入负数开支，开支目前只支持大于 0 的金额，等开支支持退款冲减后再接通。
        Text('仅作记录；开支暂不支持负数，退款请在开支里手动记录', style: ts(12, color: C.muted, h: 17)),
      ],
    ),
    Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '同步记一笔退款开支',
                style: ts(14, w: FontWeight.w500, color: C.muted, h: 20),
              ),
              Text('暂未开放：开支暂不支持负数', style: ts(12, color: C.muted, h: 17)),
            ],
          ),
        ),
        HSwitchValue(
          value: false,
          onChanged: (_) => AppToast.show(context, '开支暂不支持负数，退款开支请手动记录'),
        ),
      ],
    ),
  ]);

  Widget _goodsCard() => _card([
    _title('出库商品'),
    for (final l in c.lines)
      Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: StockOutLineTemplate(c: c, line: l),
      ),
    if (c.lines.isEmpty) Text('还没有选择商品', style: ts(13, color: C.muted, h: 18)),
    if (_scrap)
      Row(
        children: [
          Expanded(
            child: Text('报废成本', style: ts(14, color: C.sub, h: 20)),
          ),
          Text(
            c.outSubtotalLabel,
            style: ts(14, w: FontWeight.w600, h: 20, tabular: true),
          ),
        ],
      ),
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: c.busy ? null : () => c.add(context),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: C.chip,
          borderRadius: BorderRadius.circular(21),
        ),
        child: Text('+ 添加商品', style: ts(14, w: FontWeight.w500, h: 20)),
      ),
    ),
  ], gap: 12);

  @override
  Widget build(BuildContext context) => HPage(
    bg: C.bg,
    header: AppPageHeader(
      title: _scrap ? '出库 · 损耗报废' : '出库 · 退回供应商',
      leading: AppHeaderLeading.close,
      leadingEnabled: !c.busy,
    ),
    flow: Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _typeCard(),
          const SizedBox(height: 16),
          if (_scrap) _scrapCard() else _returnCard(),
          const SizedBox(height: 16),
          _goodsCard(),
        ],
      ),
    ),
    overlays: [
      HBottomDock(
        child: HBottomBar(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: c.busy ? null : () => c.submit(context),
            child: hbox(
              h: 50,
              bg: const Color(0xFF0485F7),
              radius: BorderRadius.circular(25),
              child: Align(
                widthFactor: 1,
                child: c.busyLabel(
                  'submit',
                  Text(
                    '确认出库',
                    style: hts(
                      15,
                      const Color(0xFFFFFFFF),
                      w: FontWeight.w600,
                      lh: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
