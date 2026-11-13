import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'card_packages_live_page.dart';
import 'card_tiers_live_page.dart';

enum CatalogTab { tiers, packages }

/// 卡种与次卡共用一个页面。当前页签由本次导航实例持有。
class CatalogPage extends StatelessWidget {
  final ValueListenable<CatalogTab> selection;
  const CatalogPage({super.key, required this.selection});

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return ValueListenableBuilder<CatalogTab>(
      valueListenable: selection,
      builder: (_, tab, _) => IndexedStack(
        index: tab.index,
        children: const [CardTiersLivePage(), CardPackagesLivePage()],
      ),
    );
  }
}
