import 'inventory_count_page.dart';

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show ConfirmDiscard;
import '../widgets/inventory_bindings.dart';
import 'stock_in_live_template.dart';
import 'stock_out_live_template.dart';
import 'stock_check_live_template.dart';
import 'product_detail_live_template.dart';
import '../routes.dart';

class InventoryLivePage extends StatefulWidget {
  final String mode;
  final bool legacyCheck;
  final String? productId;
  final String? documentId;
  final List<String> productIds;
  const InventoryLivePage({
    super.key,
    required this.mode,
    this.legacyCheck = false,
    this.productId,
    this.documentId,
    this.productIds = const [],
  });
  @override
  State<InventoryLivePage> createState() => _InventoryLiveState();
}

class _InventoryLiveState extends State<InventoryLivePage> {
  InventoryController? c;
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  @override
  void initState() {
    super.initState();
    inventoryChanged.addListener(reload);
  }

  void reload() {
    if (widget.mode == 'detail') key.currentState?.reload();
  }

  @override
  void dispose() {
    inventoryChanged.removeListener(reload);
    c?.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (widget.mode == 'detail') {
      if (widget.productId == null) {
        throw const AppError('请先选择商品', type: AppErrorType.notFound);
      }
      return merchantApi.invoke({
        'action': 'inventory_get',
        'id': widget.productId,
      });
    }
    final responses = await Future.wait([
      merchantApi.invoke({'action': 'inventory_list'}),
      merchantApi.invoke(
        widget.documentId == null
            ? {'action': 'inventory_draft', 'kind': widget.mode}
            : {'action': 'inventory_document_get', 'id': widget.documentId},
      ),
    ]);
    return {'items': responses[0]['items'], 'draft': responses[1]['item']};
  }

  @override
  Widget build(BuildContext context) =>
      widget.mode == 'check' && !widget.legacyCheck
      ? const InventoryCountStartPage()
      : Scaffold(
          body: AsyncView<Map<String, dynamic>>(
            key: key,
            load: load,
            isEmpty: (_) => false,
            skeletonPadding: EdgeInsets.zero,
            skeleton: SkeletonDataPage(
              title: switch (widget.mode) {
                'in' => '商品入库',
                'out' => '商品出库',
                'check' => '库存盘点',
                _ => '商品详情',
              },
              detail: widget.mode == 'detail',
            ),
            empty: (_) => const SizedBox.shrink(),
            onNext: () => openRoute(context, 'Login'),
            onLoaded: (data) {
              if (widget.mode == 'detail') {
                if (c == null) {
                  c = InventoryController(
                    'detail',
                    [],
                    Map<String, dynamic>.from(data['item']),
                    null,
                    widget.productId,
                  );
                } else {
                  c!.detail.addAll(Map<String, dynamic>.from(data['item']));
                }
              } else {
                c ??= InventoryController(
                  widget.mode,
                  maps(data['items']),
                  {},
                  data['draft'] == null
                      ? null
                      : Map<String, dynamic>.from(data['draft']),
                  widget.productId,
                );
                for (final id in widget.productIds) {
                  final p = c!.products.where((p) => p['id'] == id).firstOrNull;
                  if (p != null && !c!.lines.any((l) => l['id'] == id)) {
                    c!.lines.add({
                      'id': id,
                      'quantity': ((p['safe'] as num) - (p['stock'] as num))
                          .clamp(1, 999999999),
                      'cost': p['cost'],
                      'version': p['version'],
                    });
                    c!.changed();
                  }
                }
              }
            },
            builder: (_, data) => ListenableBuilder(
              listenable: c!,
              builder: (_, _) => ConfirmDiscard(
                dirty: c!.dirty,
                busy: c!.busy,
                child: AbsorbPointer(
                  absorbing: c!.busy,
                  child: switch (widget.mode) {
                    'in' => StockInLiveTemplate(c: c!),
                    'out' => StockOutLiveTemplate(c: c!),
                    'check' => StockCheckLiveTemplate(c: c!),
                    _ => ProductDetailLiveTemplate(c: c!),
                  },
                ),
              ),
            ),
          ),
        );
}
