import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/catalog_draft.dart';
import '../kit/async_kit.dart';
import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/common.dart';

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
    if (merchantApi.hasSession) CatalogDraft.changed.addListener(_reload);
  }

  @override
  void dispose() {
    CatalogDraft.changed.removeListener(_reload);
    super.dispose();
  }

  /// 保存 / 删除后静默刷新：旧内容保留，只在顶部出细进度条。
  void _reload() => _view.currentState?.reload();

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
      );
      items.add(item);
      liveRows[item] = row;
    }
    liveServices = items;
    return items;
  }

  void _add() {
    if (merchantApi.hasSession) CatalogDraft.begin('services');
    openRoute(context, 'ServiceEdit');
  }

  @override
  Widget build(BuildContext context) {
    // Anonymous widget tests keep the original design fixture. A signed-in
    // merchant must never see the sample data as if it were their own.
    final live = merchantApi.hasSession;
    final source = live ? (liveServices ?? <ServiceItem>[]) : services;
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
                child: RoundBtn('add', label: '新增项目', onTap: _add),
              ),
            ),
            const SizedBox(height: 8),
            ChipTabs(
              labels: cats,
              selected: cat,
              onChanged: (i) => setState(() => cat = i),
            ),
            Expanded(
              child: live
                  ? AsyncView<List<Map<String, dynamic>>>(
                      key: _view,
                      load: () => merchantApi.list('services'),
                      isEmpty: (rows) => rows.isEmpty,
                      skeleton: const SkeletonList(count: 5),
                      empty: (_) => EmptyView.firstTime(
                        title: '还没有服务项目',
                        message: '添加第一个服务项目，开始设置价格',
                        actionLabel: '新增项目',
                        onAction: _add,
                      ),
                      onLoaded: (rows) => setState(() => _apply(rows)),
                      builder: (ctx, rows) => _list(ctx, _apply(rows)),
                    )
                  : _list(context, services),
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
    if (!merchantApi.hasSession) return view;
    return RefreshIndicator(
      onRefresh: () async => _view.currentState?.reload(),
      child: view,
    );
  }

  Widget _row(BuildContext context, ServiceItem s) {
    final dim = s.offline;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (merchantApi.hasSession) {
          CatalogDraft.begin('services', liveRows[s]);
        }
        openRoute(context, 'ServiceEdit');
      },
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
