import 'package:flutter/material.dart';

import '../pages/catalog/catalog_page.dart';
export '../pages/catalog/catalog_page.dart' show CatalogTab;

/// 路由拥有自己的页签状态，返回已有页面时只切换该路由的页签。
class CatalogRoute extends MaterialPageRoute<void> {
  final ValueNotifier<CatalogTab> _selection;
  CatalogRoute(CatalogTab initial) : this._(ValueNotifier(initial));
  CatalogRoute._(ValueNotifier<CatalogTab> selection)
    : _selection = selection,
      super(
        settings: const RouteSettings(name: 'CardTiers'),
        builder: (_) => CatalogPage(selection: selection),
      );

  CatalogTab get selected => _selection.value;
  void select(CatalogTab tab) => _selection.value = tab;

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }
}
