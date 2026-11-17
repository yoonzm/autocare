import 'inventory_controller.dart';
import 'inventory_live_page.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../kit/async_kit.dart';
import '../../kit/page_header.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<String> get _cats => [
    '全部',
    ...{for (final p in products) p.category},
  ];
  int cat = 0;
  final _key = GlobalKey<AsyncViewState<List<InventoryProduct>>>();
  @override
  void initState() {
    super.initState();
    inventoryChanged.addListener(_reload);
  }

  void _reload() => _key.currentState?.reload();
  @override
  void dispose() {
    inventoryChanged.removeListener(_reload);
    super.dispose();
  }

  List<InventoryProduct> products = [];
  Future<List<InventoryProduct>> _load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录后查看库存', type: AppErrorType.auth);
    }
    final result = await merchantApi.invoke({'action': 'inventory_list'});
    products = (result['items'] as List)
        .where((v) => v['active'] != false)
        .map((v) => InventoryProduct(Map<String, dynamic>.from(v as Map)))
        .toList();
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsyncView<List<InventoryProduct>>(
        key: _key,
        load: _load,
        isEmpty: (_) => false,
        skeleton: const SkeletonList(count: 5),
        empty: (_) => Scaffold(
          body: ListView(
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 12,
              20,
              130,
            ),
            children: [
              const AppPageHeader(title: '库存管理'),
              SizedBox(
                height: 420,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: C.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: AppIcon(
                        'box',
                        size: 44,
                        color: C.primaryInk,
                        stroke: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('还没有商品', style: ts(18, w: FontWeight.w600, h: 26)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 270,
                      child: Text(
                        '先添加商品，才能入库和出库。服务里绑定的耗材也从这里选。',
                        textAlign: TextAlign.center,
                        style: ts(14, color: C.sub, h: 21),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PrimaryButton(
                      '添加第一个商品',
                      onTap: () => openRoute(context, 'ProductEdit'),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onNext: () => openRoute(context, 'Login'),
        builder: (context, data) => _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final list = products
        .where(
          (p) => cat == 0 || cat >= _cats.length || p.category == _cats[cat],
        )
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
                onTap: () => openRoute(context, 'ScanProduct'),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => openRoute(context, 'StockOut'),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: C.card,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: softShadow,
                  ),
                  child: Row(
                    children: [
                      AppIcon('arrowOut', size: 18, color: C.ink),
                      const SizedBox(width: 6),
                      Text('出库', style: ts(14, w: FontWeight.w500, h: 20)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => openRoute(context, 'StockIn'),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                  decoration: BoxDecoration(
                    color: C.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      AppIcon('add', size: 18, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        '入库',
                        style: ts(
                          14,
                          w: FontWeight.w500,
                          color: Colors.white,
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
          Segmented(
            labels: _cats,
            selected: cat,
            onChanged: (i) => setState(() => cat = i),
          ),
          const SizedBox(height: 16),
          // 没有低于安全库存的商品时不显示预警卡片。
          if (products.any((p) => p.data['low'] == true)) ...[
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
                          '${products.where((p) => p.data['low'] == true).length} 项低于安全库存',
                          style: ts(14, w: FontWeight.w500, h: 20),
                        ),
                        Text(
                          '另有 ${products.where((p) => p.expiring).length} 项将在 30 天内过期',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        openRoute(context, 'ProductList', arguments: 1),
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
          ],
          if (list.isEmpty)
            EmptyView.firstTime(
              title: products.isEmpty ? '还没有库存商品' : '当前分类还没有商品',
            ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < list.length; i++) ...[
                  _row(context, list[i]),
                  if (i < list.length - 1) const Divider1(indent: 72),
                ],
                if (list.isNotEmpty)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: C.line,
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openRoute(context, 'ProductList'),
                  child: SizedBox(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '查看全部商品 · ${products.length} 项',
                          style: ts(
                            14,
                            w: FontWeight.w500,
                            color: C.primaryInk,
                            h: 20,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AppIcon('chevronRight', size: 16, color: C.primaryInk),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 库存价值构成：按分类汇总库存价值（批次数量 × 成本），占比用「最大余数法」取整，
  /// 保证各项相加正好是 100%；价值为 0 的分类占比 0，价值很小但不为 0 的至少显示 1%。
  List<(String, int, Color)> _shares() {
    const palette = [
      Color(0xFFF5D78E),
      C.primary,
      Color(0xFF7CC4FB),
      Color(0xFF52525B),
    ];
    final cats = <String>[];
    final values = <String, double>{};
    for (final p in products) {
      if (!values.containsKey(p.category)) cats.add(p.category);
      values[p.category] =
          (values[p.category] ?? 0) +
          (p.data['stock_value'] as num? ?? 0).toDouble();
    }
    final total = values.values.fold<double>(0, (a, b) => a + b);
    final percent = <String, int>{for (final c in cats) c: 0};
    if (total > 0) {
      final exact = {for (final c in cats) c: values[c]! * 100 / total};
      for (final c in cats) {
        percent[c] = exact[c]!.floor();
      }
      var left = 100 - percent.values.fold<int>(0, (a, b) => a + b);
      final order = [...cats]
        ..sort(
          (x, y) => (exact[y]! - exact[y]!.floor()).compareTo(
            exact[x]! - exact[x]!.floor(),
          ),
        );
      for (final c in order) {
        if (left <= 0) break;
        if (exact[c]! > 0) {
          percent[c] = percent[c]! + 1;
          left--;
        }
      }
      // 价值很小但不为 0 的分类至少显示 1%（从占比最大的分类里扣）。
      for (final c in cats) {
        if (values[c]! > 0 && percent[c] == 0) {
          final big = cats.reduce((x, y) => percent[x]! >= percent[y]! ? x : y);
          if (percent[big]! > 1) {
            percent[big] = percent[big]! - 1;
            percent[c] = 1;
          }
        }
      }
    }
    return [
      for (final e in cats.indexed)
        (e.$2, percent[e.$2]!, palette[e.$1 % palette.length]),
    ];
  }

  Widget _overview() {
    final segs = _shares();
    final total = products.fold<double>(
      0,
      (v, p) => v + (p.data['stock_value'] as num? ?? 0).toDouble(),
    );
    const gold = Color(0xFFF5D78E);
    Widget legend(String text, Color dot) => Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ts(12, color: const Color(0xFFD4D4D8), h: 16),
          ),
        ),
      ],
    );
    // 深色渐变总览卡（设计稿 InventoryV1）：库存总值、SKU 数、价值构成、库存单据入口。
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -0.866),
          end: Alignment(0.5, 0.866),
          colors: [Color(0xFF26262C), Color(0xFF18181B), Color(0xFF2B2418)],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _RingsPainter())),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '库存总值（元）',
                            style: ts(
                              12,
                              color: const Color(0xFFA1A1AA),
                              h: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatMoney(total),
                            style: ts(
                              36,
                              w: FontWeight.w600,
                              h: 42,
                              spacing: -1.08,
                              tabular: true,
                              color: const Color(0xFFFAFAFA),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E2A1E),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${products.length} 个 SKU',
                        style: ts(11, w: FontWeight.w600, color: gold, h: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 10,
                  child: segs.every((e) => e.$2 == 0)
                      ? Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF34343A),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        )
                      : Row(
                          children: [
                            for (final e in segs.where((e) => e.$2 > 0).indexed)
                              Expanded(
                                flex: e.$2.$2,
                                child: Container(
                                  margin: EdgeInsets.only(
                                    left: e.$1 == 0 ? 0 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: e.$2.$3,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < segs.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: legend(
                          '${segs[i].$1} ${segs[i].$2}%',
                          segs[i].$3,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: i + 1 < segs.length
                            ? legend(
                                '${segs[i + 1].$1} ${segs[i + 1].$2}%',
                                segs[i + 1].$3,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                // 库存单据入口：放在总览卡片底部。
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => openRoute(context, 'StockDocs'),
                  child: Container(
                    padding: const EdgeInsets.only(top: 14),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF34343A))),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF27272A),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: AppIcon('document', size: 16, color: gold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '库存单据',
                          style: ts(
                            14,
                            w: FontWeight.w500,
                            color: const Color(0xFFFAFAFA),
                            h: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '入库 / 出库记录',
                            style: ts(
                              12,
                              color: const Color(0xFFA1A1AA),
                              h: 16,
                            ),
                          ),
                        ),
                        AppIcon(
                          'chevronRight',
                          size: 16,
                          color: const Color(0xFFA1A1AA),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, InventoryProduct p) {
    final low = p.data['low'] == true;
    final crit = p.stock * 2 < p.safe;
    final barColor = crit ? C.red : (low ? C.amber : C.green);
    final txtColor = crit ? C.redInk : (low ? C.amberInk : C.ink);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              InventoryLivePage(mode: 'detail', productId: p.data['id']),
        ),
      ),
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

class InventoryProduct {
  final Map<String, dynamic> data;
  InventoryProduct(this.data);
  String get name => data['name'] as String;
  String get category => data['category'] as String;
  String get unit => data['unit'] as String;
  num get stock => data['stock'] as num;
  num get safe => data['safe'] as num;
  double get cost => (data['cost'] as num).toDouble();
  double get ratio => safe == 0
      ? (stock > 0 ? 1 : 0)
      : (stock / (safe * 2)).clamp(0, 1).toDouble();
  bool get expiring => data['expiring'] == true;
}

/// 总览卡片右上角的三圈同心圆（设计稿：240 的圆环偏出卡片，半径 60 / 90 / 118）。
class _RingsPainter extends CustomPainter {
  const _RingsPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2E2E34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final center = Offset(size.width - 30, 30);
    for (final r in const [60.0, 90.0, 118.0]) {
      canvas.drawCircle(center, r, paint);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) => false;
}
