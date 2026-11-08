import 'package:flutter/material.dart';

import '../backend/subscription_flow.dart';
import '../backend/store_profile.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../routes.dart';
import 'gen/gen_routes.dart';

class SubscriptionLiveHost extends StatelessWidget {
  final String page;
  const SubscriptionLiveHost(this.page, {super.key});
  @override
  Widget build(BuildContext context) {
    final body = AsyncView<Map<String, dynamic>>(
      load: () async {
        if (page != 'Renew' && ![1, 12].contains(subscriptionFlow.months)) {
          subscriptionFlow.months = 12;
        }
        final data = await subscriptionFlow.load();
        storeProfile.apply(await merchantApi.getStore());
        return data;
      },
      isEmpty: (_) => false,
      inlineError: page == 'Renew',
      pullToRefresh: false,
      skeleton: const Column(
        children: [
          AppSkeleton(height: 120),
          SizedBox(height: 16),
          AppSkeleton(height: 220),
        ],
      ),
      empty: (_) => const SizedBox.shrink(),
      onNext: () => openRoute(context, 'Login'),
      builder: (context, _) => page == 'Renew'
          ? genSheets[page]!(context)
          : genRoutes[page]!(context),
    );
    return page == 'Renew'
        ? SizedBox(height: MediaQuery.sizeOf(context).height * .8, child: body)
        : Scaffold(body: SafeArea(child: body));
  }
}
