import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'wallet_controller.dart';
import 'recharge_page.dart';
import 'recharge_card_page.dart';
import 'recharge_empty_page.dart';
import 'recharge_empty_card_page.dart';

class WalletPage extends StatefulWidget {
  final Map<String, dynamic>? member;
  final int initial;
  const WalletPage({super.key, this.member, this.initial = 0});
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late var c = WalletController(member: widget.member, tab: widget.initial);
  @override
  void didUpdateWidget(WalletPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member?['id'] != oldWidget.member?['id'] ||
        widget.initial != oldWidget.initial) {
      c.dispose();
      c = WalletController(member: widget.member, tab: widget.initial);
    }
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

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
    return ListenableBuilder(
      listenable: c,
      builder: (_, _) {
        final tab = c.tab;
        return Scaffold(
          body: AsyncView<Map<String, dynamic>>(
            key: ValueKey((c, tab)),
            load: () => c.ready.contains(tab)
                ? Future.value({'items': tab == 0 ? c.options : c.packages})
                : c.loadOptions(tab),
            onLoaded: (data) => c.applyOptions(tab, data),
            isEmpty: (_) => false,
            skeletonPadding: EdgeInsets.zero,
            skeleton: const SkeletonDataPage(title: '会员充值'),
            empty: (_) => const SizedBox.shrink(),
            builder: (_, _) => AsyncActionScope(
              actionKey: c.actionKey,
              child: c.member == null
                  ? tab == 0
                        ? RechargeEmptyPage(controller: c)
                        : RechargeEmptyCardPage(controller: c)
                  : tab == 0
                  ? RechargePage(controller: c)
                  : RechargeCardPage(controller: c),
            ),
          ),
        );
      },
    );
  }
}
