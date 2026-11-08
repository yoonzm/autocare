import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart' show hbox;
import '../routes.dart';
import '../backend/store_flow.dart';
import '../backend/store_profile.dart';
import '../theme.dart';
import '../widgets/app_icon.dart';
import '../mock/mock_data.dart' show money;

/// Real stores and account subscription quotas are supplied by the server.
class StoreSwitchLiveSheet extends StatefulWidget {
  const StoreSwitchLiveSheet({super.key});

  @override
  State<StoreSwitchLiveSheet> createState() => _StoreSwitchLiveSheetState();
}

class _StoreSwitchLiveSheetState extends State<StoreSwitchLiveSheet> {
  String? _switching;
  int _count = 1;
  Future<void> _select(String id, String current, String name) async {
    if (_switching != null) return;
    if (id == current) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _switching = id);
    try {
      await StoreFlow.switchTo(context, id, name: name);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _switching = null);
    }
  }

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
          height: (204 + 84.0 * (_count - 1)).clamp(
            204,
            MediaQuery.sizeOf(context).height * 0.65,
          ),
          child: AsyncView<Map<String, dynamic>>(
            load: merchantApi.stores,
            onLoaded: (data) {
              storeProfile.applyDirectory(data);
              if (mounted) {
                setState(
                  () => _count = (data['items'] as List).length.clamp(1, 1000),
                );
              }
            },
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final row in rows) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _select('${row['id']}', current, '${row['name']}'),
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
                      if (_switching == '${row['id']}')
                        const AppSpinner(size: 20, color: C.primary),
                      if (_switching == null && '${row['id']}' == current)
                        const AppIcon('check', size: 20, color: C.green),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (_switching != null) return;
              if (data['can_add'] != true) {
                AppToast.show(context, '${data['add_hint']}');
                return;
              }
              StoreFlow.clear();
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
                          '${data['add_hint']}',
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
