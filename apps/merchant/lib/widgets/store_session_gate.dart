import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/service_store.dart';
import '../backend/store_profile.dart';
import '../kit/async_kit.dart';
import '../pages/account/login_page.dart';

typedef _RestoredStore = ({
  Map<String, dynamic> store,
  Map<String, dynamic>? identity,
});

/// Restore the server-selected store before mounting any store-dependent pages.
/// A delayed/failed profile must never race their requests or use cached identity.
class StoreSessionGate extends StatelessWidget {
  final Widget child;
  const StoreSessionGate({super.key, required this.child});

  Future<_RestoredStore> _restore() async {
    final store = await merchantApi.getStore();
    // 老板冷启动只恢复了登录令牌；推送与站内信还需要服务端确认的身份。
    final identity = Access.context.isEmpty
        ? await merchantApi.identity('context')
        : null;
    return (store: store, identity: identity);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: AsyncView<_RestoredStore>(
      load: _restore,
      isEmpty: (_) => false,
      skeleton: const _StoreSessionSkeleton(),
      empty: (_) => const SizedBox.shrink(),
      onLoaded: (restored) {
        storeProfile.apply(restored.store);
        if (restored.identity case final identity?) Access.apply(identity);
        unawaited(ServiceStore.load().then((_) {}, onError: (_) {}));
      },
      onNext: () => Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginPage()),
        (_) => false,
      ),
      builder: (_, _) => child,
    ),
  );
}

class _StoreSessionSkeleton extends StatelessWidget {
  const _StoreSessionSkeleton();
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        Row(
          children: [
            Expanded(child: AppSkeleton(width: 180, height: 28)),
            SizedBox(width: 24),
            AppSkeleton(width: 44, height: 44),
          ],
        ),
        SizedBox(height: 24),
        SkeletonDashboardCard(height: 197, radius: 28),
        SizedBox(height: 24),
        SkeletonDashboardCard(height: 160, radius: 28),
        SizedBox(height: 24),
        SkeletonList(count: 2),
      ],
    ),
  );
}
