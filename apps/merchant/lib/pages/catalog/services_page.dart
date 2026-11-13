import '../../routes.dart' show openRoute;
import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import 'service_edit_page.dart';
import '../../backend/service_store.dart';
import '../../kit/async_kit.dart';
import 'service_item.dart';
import '../../backend/money_format.dart';
import '../../backend/data_snapshot.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  /// 已登录时来自后端；null 表示还没加载成功（此时芯片计数为 0）。
  List<ServiceItem>? liveServices;
  final Map<ServiceItem, Map<String, dynamic>> liveRows = {};
  final _view = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  static const _keys = [null, '镀晶镀膜', '洗车', '贴膜', '内饰'];
  int cat = 0;

  @override
  void initState() {
    super.initState();
    ServiceStore.changed.addListener(_reload);
  }

  @override
  void dispose() {
    ServiceStore.changed.removeListener(_reload);
    super.dispose();
  }

  /// 保存 / 删除后静默刷新：旧内容保留，只在顶部出细进度条。
  bool _forceNext = false;
  bool _pending = false;
  void _reload() {
    if (!mounted) return;
    if (_view.currentState?.busy == true) {
      _pending = true;
      return;
    }
    _view.currentState?.reload();
  }

  void _settled() {
    if (!mounted || !_pending) return;
    _pending = false;
    _view.currentState?.reload();
  }

  /// 后端记录 -> 页面条目（并记住记录，编辑时用）。
  List<ServiceItem> _apply(List<Map<String, dynamic>> rows) {
    liveRows.clear();
    final items = <ServiceItem>[];
    for (final row in rows) {
      final item = ServiceItem(
        row['category']?.toString() ?? '其他',
        row['name']?.toString() ?? '',
        row['description']?.toString() ?? '',
        num.tryParse(row['price'].toString()) ?? 0,
        offline: row['active'] == false,
        tag: row['active'] == false ? '已下架' : '',
      );
      items.add(item);
      liveRows[item] = dataSnapshot(row);
    }
    liveServices = items;
    return items;
  }

  void _add() => openServiceEditor(context);

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
    final source = liveServices ?? <ServiceItem>[];
    final cats = [
      '全部 ${source.length}',
      for (final key in _keys.skip(1))
        '$key ${source.where((s) => s.category == key).length}',
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SubHeader(
              '服务项目与价格',
              trailing: Align(
                alignment: Alignment.centerRight,
                child: RoundBtn(
                  kind: AppIconButtonKind.primary,
                  'add',
                  label: '新增项目',
                  onTap: _add,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ChipTabs(
              labels: cats,
              selected: cat,
              onChanged: (i) => setState(() => cat = i),
            ),
            Expanded(
              child: AsyncView<List<Map<String, dynamic>>>(
                key: _view,
                onSettled: _settled,
                // 服务项目走全局缓存：打开就有数据，后台静默刷新；下拉刷新才强制重新请求
                load: () {
                  final force = _forceNext;
                  _forceNext = false;
                  return ServiceStore.load(force: force);
                },
                isEmpty: (rows) => rows.isEmpty,
                skeleton: const SkeletonServiceList(),
                empty: (_) => EmptyView.firstTime(
                  title: '还没有服务项目',
                  message: '添加第一个服务项目，开始设置价格',
                  actionLabel: '新增项目',
                  onAction: _add,
                ),
                onLoaded: (rows) => setState(() => _apply(rows)),
                builder: (ctx, rows) => _list(ctx, _apply(rows)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<ServiceItem> source) {
    final list = source
        .where((s) => _keys[cat] == null || s.category == _keys[cat])
        .toList();
    if (list.isEmpty) {
      // 当前分类下没有：筛选条保持可见，只给“重置筛选”
      return EmptyView.filtered(onAction: () => setState(() => cat = 0));
    }
    final groups = <String, List<ServiceItem>>{};
    for (final s in list) {
      groups.putIfAbsent(s.category, () => []).add(s);
    }
    final view = ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        for (final e in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              e.key,
              style: ts(13, w: FontWeight.w500, color: C.muted, h: 18),
            ),
          ),
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (var i = 0; i < e.value.length; i++) ...[
                  _row(context, e.value[i]),
                  if (i < e.value.length - 1) const Divider1(indent: 16),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
    return RefreshIndicator(
      onRefresh: () async {
        _forceNext = true;
        await _view.currentState?.reload();
      },
      child: view,
    );
  }

  Widget _row(BuildContext context, ServiceItem s) {
    final dim = s.offline;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openServiceEditor(context, initial: liveRows[s]),
      child: Opacity(
        opacity: dim ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            s.name,
                            style: ts(15, w: FontWeight.w500, h: 22),
                          ),
                        ),
                        if (s.tag.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Pill(
                            s.tag,
                            bg: dim ? C.chip : C.greenSoft,
                            fg: dim ? C.muted : C.greenInk,
                            size: 11,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(s.desc, style: ts(12, color: C.muted, h: 16)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${money(s.price, digits: s.price % 1 == 0 ? 0 : 2)}',
                    style: ts(16, w: FontWeight.w600, h: 22, tabular: true),
                  ),
                  if (s.memberNote.isNotEmpty)
                    Text(s.memberNote, style: ts(11, color: C.amberInk, h: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
