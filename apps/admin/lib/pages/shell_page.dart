import 'package:flutter/material.dart';

import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';
import 'home_page.dart';
import 'merchants_page.dart';
import 'mine_page.dart';
import 'subs_pages.dart';

/// 底部导航当前页，供概览页的快捷入口切换。
final tabIndex = ValueNotifier<int>(0);

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> with WidgetsBindingObserver {
  final dataKey = GlobalKey<AsyncViewState<bool>>();
  DateTime lastActive = DateTime.now();
  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard_rounded, '概览'),
    (Icons.storefront_outlined, Icons.storefront_rounded, '商家'),
    (Icons.receipt_long_outlined, Icons.receipt_long_rounded, '订阅'),
    (Icons.person_outline_rounded, Icons.person_rounded, '我的'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    tabIndex.value = 0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        DateTime.now().difference(lastActive) > const Duration(minutes: 5)) {
      dataKey.currentState?.reload();
    }
    if (state != AppLifecycleState.resumed) lastActive = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 登录后不能侧滑回登录页
      child: ValueListenableBuilder<int>(
        valueListenable: tabIndex,
        builder: (context, i, _) => Scaffold(
          backgroundColor: C.bg,
          body: AsyncView<bool>(
            key: dataKey,
            load: store.refresh,
            isEmpty: (_) => false,
            skeleton: AdPage(
              title: _items[i].$3,
              back: false,
              children: [
                if (i == 0 || i == 2)
                  const SkeletonDashboardCard(height: 180, radius: 24),
                const SkeletonTileList(),
              ],
            ),
            empty: (_) => const SizedBox.shrink(),
            skeletonScrollable: false,
            builder: (context, data) => IndexedStack(
              index: i,
              children: const [
                HomePage(),
                MerchantsPage(),
                SubsPage(),
                MinePage(),
              ],
            ),
          ),
          bottomNavigationBar: ListenableBuilder(
            listenable: store,
            builder: (context, _) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: C.card.withValues(alpha: .96),
                border: Border(top: BorderSide(color: C.stroke)),
              ),
              child: Row(
                children: [
                  for (var n = 0; n < _items.length; n++)
                    Expanded(
                      key: ValueKey('nav-$n'),
                      child: Semantics(
                        button: true,
                        selected: n == i,
                        label: _items[n].$3,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => tabIndex.value = n,
                          child: SizedBox(
                            height: 58,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Badge(
                                  isLabelVisible:
                                      n == 3 && store.todoTickets > 0,
                                  smallSize: 8,
                                  child: Icon(
                                    n == i ? _items[n].$2 : _items[n].$1,
                                    size: 24,
                                    color: n == i ? C.primary : C.faint,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _items[n].$3,
                                  style: ts(
                                    11,
                                    w: FontWeight.w500,
                                    color: n == i ? C.primary : C.faint,
                                    h: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
