import '../widgets/inventory_bindings.dart';
import 'inventory_live_page.dart';

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/page_header.dart';
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
                        '先添加商品，才能入库、出库和盘点。服务里绑定的耗材也从这里选。',
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
                onTap: () => openRoute(context, 'ScanProduct'),
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
          Row(
            children: [
              _entry(context, '全部商品', '${products.length} 项', 'ProductList'),
              const SizedBox(width: 10),
              _entry(context, '库存单据', '入库 / 出库 / 盘点', 'StockDocs'),
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
                        '${products.where((p) => p.stock < p.safe).length} 项低于安全库存',
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
                  onTap: () => openRoute(context, 'ProductList'),
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
          if (list.isEmpty)
            EmptyView.firstTime(
              title: products.isEmpty ? '还没有库存商品' : '请先登录后查看库存',
            ),
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
    int share(String category) {
      final total = products.fold<double>(
        0,
        (v, p) => v + (p.data['stock_value'] as num).toDouble(),
      );
      return total == 0
          ? 0
          : (100 *
                    products
                        .where((p) => p.category == category)
                        .fold<double>(
                          0,
                          (v, p) =>
                              v + (p.data['stock_value'] as num).toDouble(),
                        ) /
                    total)
                .round();
    }

    final segs = [
      ('贴膜', share('贴膜'), C.ink),
      ('镀晶镀膜', share('镀晶'), C.primary),
      ('洗护用品', share('洗护'), Color(0xFF7CC4FB)),
      ('配件', share('配件'), Color(0xFFD4D4D8)),
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
                      products
                          .fold<double>(
                            0,
                            (v, p) =>
                                v + (p.data['stock_value'] as num).toDouble(),
                          )
                          .toStringAsFixed(2),
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
              Text(
                '${products.length} 个 SKU',
                style: ts(12, color: C.muted, h: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 10,
            child: Row(
              children: [
                for (var i = 0; i < segs.length; i++)
                  Expanded(
                    flex: segs[i].$2 == 0 ? 1 : segs[i].$2,
                    child: Container(
                      margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
                      decoration: BoxDecoration(
                        color: segs[i].$2 == 0 ? C.chip : segs[i].$3,
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

  /// 全部商品 / 库存单据入口（设计稿 Inventory：两张并排的白色卡片，右侧箭头）。
  Widget _entry(BuildContext context, String title, String sub, String route) =>
      Expanded(
        child: AppCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          onTap: () => openRoute(context, route),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ts(14, w: FontWeight.w500, h: 20)),
                    Text(sub, style: ts(12, color: C.muted, h: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AppIcon('chevronRight', size: 16, color: C.faint),
            ],
          ),
        ),
      );

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
        {'入库': 'StockIn', '出库': 'StockOut', '盘点': 'StockCheckNew'}[t]!,
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

  Widget _row(BuildContext context, InventoryProduct p) {
    final low = p.stock < p.safe;
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
