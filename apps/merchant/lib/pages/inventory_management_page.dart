import '../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show ConfirmDiscard;
import '../widgets/inventory_bindings.dart';
import '../widgets/inventory_management_bindings.dart';
import 'category_manage_bound_template.dart';
import 'stock_alert_settings_bound_template.dart';
import 'stock_docs_bound_template.dart';
import 'stock_in_detail_bound_template.dart';
import 'stock_out_detail_bound_template.dart';
import 'stock_check_new_bound_template.dart';
import 'stock_check_result_bound_template.dart';
import 'scan_product_bound_template.dart';

class InventoryManagementPage extends StatefulWidget {
  final String mode;
  final String? documentId;
  final InventoryController? countController;
  final bool returnProduct;
  final int initialTab;
  const InventoryManagementPage({
    super.key,
    required this.mode,
    this.documentId,
    this.countController,
    this.returnProduct = false,
    this.initialTab = 0,
  });
  @override
  State<InventoryManagementPage> createState() => _State();
}

class _State extends State<InventoryManagementPage> {
  late final c = InventoryManagementController(
    widget.mode,
    documentId: widget.documentId,
    count: widget.countController,
    returnProduct: widget.returnProduct,
  );
  final key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  @override
  void initState() {
    super.initState();
    c.tab = widget.initialTab;
    inventoryChanged.addListener(reload);
    c.reload = () async {
      await key.currentState?.reload();
    };
  }

  void reload() {
    if (!c.busy) key.currentState?.reload();
  }

  @override
  void dispose() {
    inventoryChanged.removeListener(reload);
    c.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (widget.mode == 'scan' || widget.mode == 'result') return {};
    final result = await merchantApi.invoke(switch (widget.mode) {
      'docs' => {'action': 'inventory_documents'},
      'document' => {
        'action': 'inventory_document_get',
        'id': widget.documentId,
      },
      _ => {'action': 'inventory_options'},
    });
    c.apply(result);
    if (widget.mode == 'new') {
      final list = await merchantApi.invoke({'action': 'inventory_list'});
      c.products = maps(list['items'])
          .where((p) => p['active'] != false)
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<Map<String, dynamic>>(
      key: key,
      load: load,
      isEmpty: (_) => false,
      skeleton: const SkeletonList(count: 4),
      empty: (_) => const SizedBox.shrink(),
      onNext: () => openRoute(context, 'Login'),
      builder: (_, data) => ListenableBuilder(
        listenable: c,
        builder: (_, _) => ConfirmDiscard(
          dirty: c.dirty,
          busy: c.busy,
          child: switch (widget.mode) {
            'categories' => CategoryManageBoundTemplate(c: c),
            'settings' => StockAlertSettingsBoundTemplate(c: c),
            'docs' => StockDocsBoundTemplate(c: c),
            'new' => StockCheckNewBoundTemplate(c: c),
            'result' => StockCheckResultBoundTemplate(c: c),
            'scan' => ScanProductBoundTemplate(c: c),
            _ =>
              c.kind == 'in'
                  ? StockInDetailBoundTemplate(c: c)
                  : c.kind == 'out'
                  ? StockOutDetailBoundTemplate(c: c)
                  : StockCheckResultBoundTemplate(c: c),
          },
        ),
      ),
    ),
  );
}
