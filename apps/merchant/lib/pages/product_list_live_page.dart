import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../kit/page_header.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../widgets/inventory_bindings.dart';
import 'inventory_live_page.dart';
import 'inventory_page.dart' show InventoryProduct;

/// 全部商品（设计稿 ProductList / ProductListAll / ProductListExp / ProductListOff 是同一个页面的四个筛选）。
/// 数据和库存页同一个来源（`inventory_list`），低库存 / 临期按服务端算好的字段，不在客户端另算一套。
class ProductListLivePage extends StatefulWidget {
  final int initialFilter;

  /// 0 全部 / 1 低库存 / 2 临期 / 3 已停用；设计稿里从库存页进入时默认是低库存。
  const ProductListLivePage({super.key, this.initialFilter = 1});
  @override
  State<ProductListLivePage> createState() => _ProductListState();
}

class _ProductListState extends State<ProductListLivePage> {
  static const _filters = ['全部', '低库存', '临期', '已停用'];
  late int filter = widget.initialFilter;
  final _key = GlobalKey<AsyncViewState<List<InventoryProduct>>>();
  String q = '';

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

  Future<List<InventoryProduct>> _load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录后查看库存', type: AppErrorType.auth);
    }
    final result = await merchantApi.invoke({'action': 'inventory_list'});
    return [
      for (final v in result['items'] as List)
        InventoryProduct(Map<String, dynamic>.from(v as Map)),
    ];
  }

  bool _low(InventoryProduct p) => p.stock < p.safe;
  // TODO: 商品停用需要后端支持（inventory_products 目前没有停用状态），暂时没有已停用商品。
  bool _off(InventoryProduct p) => false;

  List<InventoryProduct> _visible(List<InventoryProduct> all) {
    final key = q.trim().toLowerCase();
    return [
      for (final p in all)
        if (switch (filter) {
              0 => true,
              1 => _low(p),
              2 => p.expiring,
              _ => _off(p),
            } &&
            (key.isEmpty ||
                p.name.toLowerCase().contains(key) ||
                '${p.data['sku'] ?? ''}'.toLowerCase().contains(key)))
          p,
    ];
  }

  int _count(List<InventoryProduct> all, int f) => all
      .where(
        (p) => switch (f) {
          0 => true,
          1 => _low(p),
          2 => p.expiring,
          _ => _off(p),
        },
      )
      .length;

  String _summary(List<InventoryProduct> list) => switch (filter) {
    0 => '共 ${list.length} 项商品',
    1 => '共 ${list.length} 项低于安全库存',
    2 => '共 ${list.length} 项 30 天内到期，先到期的排前面',
    _ => '共 ${list.length} 项已停用',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    body: AsyncView<List<InventoryProduct>>(
      key: _key,
      load: _load,
      isEmpty: (_) => false,
      skeletonPadding: EdgeInsets.zero,
      skeletonScrollable: true,
      waiting: const _Shell(),
      skeleton: const _Shell(loading: true),
      empty: (_) => const SizedBox.shrink(),
      onNext: () => openRoute(context, 'Login'),
      builder: (context, all) => _content(context, all),
    ),
  );

  Widget _content(BuildContext context, List<InventoryProduct> all) {
    final list = _visible(all);
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
      children: [
        AppPageHeader(
          title: '全部商品',
          trailing: Semantics(
            button: true,
            label: '新增商品',
            child: GestureDetector(
              onTap: () => openRoute(context, 'ProductEdit'),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: C.card,
                  shape: BoxShape.circle,
                  boxShadow: softShadow,
                ),
                child: Center(child: AppIcon('add', size: 20, color: C.ink)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: C.card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: softShadow,
                ),
                child: Row(
                  children: [
                    AppIcon('search', size: 18, color: C.faint),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => q = v),
                        style: ts(15, color: C.ink, h: 22),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: '搜索商品名称 / SKU',
                          hintStyle: ts(15, color: C.muted, h: 22),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              button: true,
              label: '扫码',
              child: GestureDetector(
                onTap: () => openRoute(context, 'ScanProduct'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: C.card,
                    shape: BoxShape.circle,
                    boxShadow: softShadow,
                  ),
                  child: Center(child: AppIcon('scan', size: 20, color: C.ink)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 状态：未选中是白底（页面底色是灰），选中是蓝底 + 蓝描边
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final on = filter == i;
              return Semantics(
                button: true,
                selected: on,
                label: _filters[i],
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => filter = i),
                  child: Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? C.primarySoft : C.card,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: on ? C.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${_filters[i]} ${_count(all, i)}',
                      style: ts(
                        13,
                        w: FontWeight.w500,
                        color: on
                            ? C.primaryInk
                            : dk(
                                context,
                                const Color(0xFF3F3F46),
                                const Color(0xFFD4D4D8),
                              ),
                        h: 18,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(_summary(list), style: ts(13, color: C.sub, h: 18)),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          q.isNotEmpty
              ? EmptyView.filtered(onAction: () => setState(() => q = ''))
              : EmptyView(
                  title: all.isEmpty
                      ? '还没有商品'
                      : filter == 1
                      ? '没有低于安全库存的商品'
                      : filter == 2
                      ? '没有临期商品'
                      : filter == 3
                      ? '没有已停用的商品'
                      : '没有商品',
                  message: all.isEmpty ? '先添加商品，才能入库、出库和盘点' : null,
                  actionLabel: all.isEmpty ? '添加第一个商品' : null,
                  onAction: all.isEmpty
                      ? () => openRoute(context, 'ProductEdit')
                      : null,
                )
        else
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: softShadow,
            ),
            child: Column(
              children: [
                for (final (i, p) in list.indexed) ...[
                  if (i > 0)
                    Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 68),
                      color: C.line,
                    ),
                  _row(context, p),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _row(BuildContext context, InventoryProduct p) {
    final low = _low(p);
    final loc = '${p.data['location'] ?? ''}';
    final subs = [
      p.category,
      if (loc.isNotEmpty) loc,
      '参考成本 ${money2(p.cost)}',
    ];
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: C.primarySoft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: AppIcon('box', size: 18, color: C.primaryInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(14, w: FontWeight.w500, h: 20),
                        ),
                      ),
                      if (low) ...[
                        const SizedBox(width: 6),
                        _tag('低库存', C.redInk, C.redSoft),
                      ],
                      if (p.expiring) ...[
                        const SizedBox(width: 6),
                        _tag('临期', C.amberInk, C.amberSoft),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subs.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, color: C.muted, h: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${p.stock} ${p.unit}',
              style: ts(
                15,
                w: FontWeight.w600,
                color: low ? C.redInk : C.ink,
                h: 22,
                tabular: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String t, Color fg, Color bg) => Container(
    height: 18,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      t,
      style: ts(11, w: FontWeight.w600, color: fg, h: 18),
    ),
  );
}

String money2(num v) {
  final fixed = v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
  final parts = fixed.split('.');
  final ip = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '¥$ip${parts.length > 1 ? '.${parts[1]}' : ''}';
}

class _Shell extends StatelessWidget {
  final bool loading;
  const _Shell({this.loading = false});
  @override
  Widget build(BuildContext context) => ListView(
    physics: const NeverScrollableScrollPhysics(),
    padding: EdgeInsets.fromLTRB(20, topInset(context), 20, 130),
    children: [
      const AppPageHeader(title: '全部商品'),
      if (loading) ...[
        const SizedBox(height: 16),
        const AppSkeleton(height: 44, radius: 22),
        const SizedBox(height: 16),
        const AppSkeleton(height: 34, radius: 17),
        const SizedBox(height: 16),
        const AppSkeleton(height: 260, radius: 24),
      ],
    ],
  );
}
