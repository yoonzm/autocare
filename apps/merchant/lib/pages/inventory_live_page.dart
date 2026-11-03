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
  final String? productId;
  const InventoryLivePage({super.key, required this.mode, this.productId});
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
      merchantApi.invoke({'action': 'inventory_draft', 'kind': widget.mode}),
    ]);
    return {'items': responses[0]['items'], 'draft': responses[1]['item']};
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: key,
      load: load,
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 5),
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
