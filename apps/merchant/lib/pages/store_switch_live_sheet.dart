import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show hbox;
import '../routes.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../mock/mock_data.dart' show money;
import '../mock/store_state.dart';

/// The backend currently permits one store per owner. Only that actual store is
/// selectable; there is no local-only "active store" pretending to switch data.
class StoreSwitchLiveSheet extends StatelessWidget {
  const StoreSwitchLiveSheet({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(
      20,
      10,
      20,
      16 + MediaQuery.paddingOf(context).bottom,
    ),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: C.line,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text('切换门店', style: ts(20, w: FontWeight.w600, h: 28)),
        const SizedBox(height: 14),
        SizedBox(
          height: 204 + 84.0 * MockStores.extra.value.length,
          child: AsyncView<Map<String, dynamic>>(
            load: merchantApi.stores,
            isEmpty: (data) => (data['items'] as List).isEmpty,
            inlineError: true,
            pullToRefresh: false,
            skeletonScrollable: false,
            skeleton: const Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSkeleton(height: 70, radius: 18),
                SizedBox(height: 14),
                AppSkeleton(height: 82, radius: 18),
              ],
            ),
            empty: (_) => const EmptyView.firstTime(title: '当前账号还没有门店'),
            onNext: () => openRoute(context, 'Login'),
            builder: (context, data) => _content(context, data),
          ),
        ),
      ],
    ),
  );

  Widget _content(BuildContext context, Map<String, dynamic> data) {
    final rows = List<Map<String, dynamic>>.from(data['items'] as List);
    final current = '${data['current_store_id']}';
    MockStores.realCount = rows.length;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if ('${row['id']}' == current) {
                  Navigator.of(context).pop();
                } else {
                  // TODO: Real cross-store switching needs server-side membership,
                  // active-store session context and invalidation of all store caches.
                  AppToast.show(context, '跨门店切换暂未开通');
                }
              },
              child: Semantics(
                selected: '${row['id']}' == current,
                button: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: '${row['id']}' == current ? C.primarySoft : C.inset,
                    borderRadius: BorderRadius.circular(18),
                    border: '${row['id']}' == current
                        ? Border.all(color: C.primary, width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${row['name']}',
                              style: ts(15, w: FontWeight.w600, h: 22),
                            ),
                            Text(
                              '${row['status_label']} · 今日 ¥${money((row['revenue'] as num).toDouble(), digits: 2)}',
                              style: ts(12, color: C.muted, h: 16),
                            ),
                          ],
                        ),
                      ),
                      if ('${row['id']}' == current)
                        const AppIcon('check', size: 20, color: C.green),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          // 新增的演示门店（临时 mock，见 MockStores）：只展示，不能切换过去，不参与任何数据读写。
          for (final name in MockStores.extra.value) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => AppToast.show(context, '演示门店，跨门店切换暂未开通'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: ts(15, w: FontWeight.w600, h: 22)),
                    Text('演示门店 · 仅本机可见', style: ts(12, color: C.muted, h: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // 新增门店：临时 mock（见 MockStores），创建的是只在本机可见的演示门店。
              // TODO: 真实新增门店需要后端：同一账号多门店、按套餐限制数量、创建时初始化营业时间和工位（store_create）。
              if (MockStores.full) {
                AppToast.show(context, '专业版最多 ${MockStores.max} 家门店，已达上限');
                return;
              }
              openRoute(context, 'StoreAdd');
            },
            child: hbox(
              radius: BorderRadius.circular(18),
              dashed: true,
              dashColor: C.line,
              dashWidth: 2,
              pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  AppIcon('plus', size: 20, color: C.primaryInk),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '新增门店',
                          style: ts(
                            15,
                            w: FontWeight.w600,
                            color: C.primaryInk,
                            h: 22,
                          ),
                        ),
                        Text(
                          MockStores.extra.value.isEmpty
                              ? '${data['add_hint']}'
                              : MockStores.full
                              ? '专业版最多 ${MockStores.max} 家，已达上限'
                              : '专业版最多 ${MockStores.max} 家，还可添加 ${MockStores.remaining} 家',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
