import 'package:flutter/material.dart';

import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  static const _cats = ['全部', '洗护', '镀晶', '贴膜', '配件'];
  int cat = 0;

  @override
  Widget build(BuildContext context) {
    final list = products
        .where((p) => cat == 0 || p.category == _cats[cat])
        .toList();
    return Scaffold(
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 12,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '库存',
                  style: ts(28, w: FontWeight.w600, h: 36, spacing: -0.7),
                ),
              ),
              RoundBtn(
                'scan',
                label: '扫码查询',
                onTap: () => toast(context, '扫码查询（演示）'),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => openRoute(context, 'StockIn'),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: C.btn,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      AppIcon('add', size: 18, color: C.btnFg),
                      const SizedBox(width: 6),
                      Text(
                        '入库',
                        style: ts(
                          14,
                          w: FontWeight.w500,
                          color: C.btnFg,
                          h: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _overview(),
          const SizedBox(height: 16),
          Row(
            children: [
              _action(context, '入库', 'arrowIn', C.greenSoft, C.greenInk),
              const SizedBox(width: 10),
              _action(context, '出库', 'arrowOut', C.amberSoft, C.amberInk),
              const SizedBox(width: 10),
              _action(context, '盘点', 'clipboard', C.primarySoft, C.primaryInk),
            ],
          ),
          const SizedBox(height: 16),
          Segmented(
            labels: _cats,
            selected: cat,
            onChanged: (i) => setState(() => cat = i),
          ),
          const SizedBox(height: 16),
          AppCard(
            radius: 18,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: C.amberSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppIcon('warn', size: 18, color: C.amberInk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '7 项低于安全库存',
                        style: ts(14, w: FontWeight.w500, h: 20),
                      ),
                      Text(
                        '另有 2 项将在 30 天内过期',
                        style: ts(12, color: C.muted, h: 16),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => openRoute(context, 'StockIn'),
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.chip,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '去补货',
                      style: ts(13, w: FontWeight.w500, h: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  _row(context, list[i]),
                  if (i < list.length - 1) const Divider1(indent: 72),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overview() {
    final segs = [
      ('贴膜', 46, C.ink),
      ('镀晶镀膜', 24, C.primary),
      ('洗护用品', 18, Color(0xFF7CC4FB)),
      ('配件', 12, Color(0xFFD4D4D8)),
    ];
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('库存总值（元）', style: ts(12, color: C.muted, h: 16)),
                    const SizedBox(height: 2),
                    Text(
                      '86,540',
                      style: ts(
                        28,
                        w: FontWeight.w600,
                        h: 34,
                        spacing: -0.8,
                        tabular: true,
                      ),
                    ),
                  ],
                ),
              ),
              Text('248 个 SKU', style: ts(12, color: C.muted, h: 16)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 10,
            child: Row(
              children: [
                for (var i = 0; i < segs.length; i++)
                  Expanded(
                    flex: segs[i].$2,
                    child: Container(
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                      decoration: BoxDecoration(
                        color: segs[i].$3,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            runSpacing: 6,
            children: [
              for (final s in segs)
                SizedBox(
                  width: 140,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: s.$3,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${s.$1} ${s.$2}%',
                        style: ts(12, color: C.sub, h: 16),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext context,
    String t,
    String i,
    Color bg,
    Color fg,
  ) => Expanded(
    child: AppCard(
      radius: 20,
      padding: const EdgeInsets.all(12),
      onTap: () => openRoute(
        context,
        {'入库': 'StockIn', '出库': 'StockOut', '盘点': 'StockCheck'}[t]!,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: AppIcon(i, size: 18, color: fg),
          ),
          const SizedBox(width: 10),
          Text(t, style: ts(14, w: FontWeight.w500, h: 20)),
        ],
      ),
    ),
  );

  Widget _row(BuildContext context, Product p) {
    final low = p.stock < p.safe;
    final crit = p.stock * 2 < p.safe;
    final barColor = crit ? C.red : (low ? C.amber : C.green);
    final txtColor = crit ? C.redInk : (low ? C.amberInk : C.ink);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openRoute(context, 'ProductDetail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: crit ? C.btn : (low ? C.primarySoft : C.greenSoft),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AppIcon(
                'box',
                size: 20,
                color: crit ? C.btnFg : (low ? C.primaryInk : C.greenInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          p.name,
                          style: ts(14, w: FontWeight.w500, h: 20),
                        ),
                      ),
                      Text(
                        '${p.stock} ${p.unit}',
                        style: ts(
                          14,
                          w: FontWeight.w600,
                          color: txtColor,
                          h: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: p.ratio,
                            minHeight: 4,
                            backgroundColor: C.chip,
                            valueColor: AlwaysStoppedAnimation(barColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '安全库存 ${p.safe}',
                        style: ts(11, color: C.muted, h: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
