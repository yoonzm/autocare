import '../../routes.dart' show openRoute;

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show ConfirmDiscard;
import 'inventory_controller.dart';
import 'inventory_management_controller.dart';
import 'category_manage_bound_template.dart';
import 'stock_alert_settings_bound_template.dart';
import 'stock_docs_bound_template.dart';
import 'stock_in_detail_bound_template.dart';
import 'stock_out_detail_bound_template.dart';
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
  late InventoryManagementController c;
  var key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  InventoryManagementController _createController() {
    final controller = InventoryManagementController(
      widget.mode,
      documentId: widget.documentId,
      count: widget.countController,
      returnProduct: widget.returnProduct,
    )..tab = widget.initialTab;
    controller.reload = () async {
      if (!controller.disposed) await key.currentState?.reload();
    };
    return controller;
  }

  @override
  void didUpdateWidget(InventoryManagementPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mode != oldWidget.mode ||
        widget.documentId != oldWidget.documentId ||
        widget.countController != oldWidget.countController ||
        widget.returnProduct != oldWidget.returnProduct ||
        widget.initialTab != oldWidget.initialTab) {
      c.dispose();
      key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
      c = _createController();
    }
  }

  @override
  void initState() {
    super.initState();
    c = _createController();
    inventoryChanged.addListener(reload);
  }

  void reload() {
    if (!c.busy && !c.dirty) key.currentState?.reload();
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
    if (widget.mode == 'scan') return {};
    final controller = c;
    final mode = widget.mode;
    if (mode == 'document' && widget.documentId == null) {
      throw const AppError('请先选择库存单据', type: AppErrorType.notFound);
    }
    final result = await merchantApi.invoke(switch (mode) {
      'docs' => {'action': 'inventory_documents'},
      'document' => {
        'action': 'inventory_document_get',
        'id': widget.documentId,
      },
      _ => {'action': 'inventory_options'},
    });
    if (!mounted || controller.disposed) return result;
    controller.apply(result);
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
          child: AbsorbPointer(
            absorbing: c.busy,
            child: switch (widget.mode) {
              'categories' => CategoryManageBoundTemplate(c: c),
              'settings' => StockAlertSettingsBoundTemplate(c: c),
              'docs' => StockDocsBoundTemplate(c: c),
              'scan' => ScanProductBoundTemplate(c: c),
              _ =>
                c.kind == 'in'
                    ? StockInDetailBoundTemplate(c: c)
                    : StockOutDetailBoundTemplate(c: c),
            },
          ),
        ),
      ),
    ),
  );
}
