import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;
import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

/// 门店业务通知短信发送记录（独立二级页）。
class SmsLogsPage extends StatefulWidget {
  const SmsLogsPage({super.key});

  @override
  State<SmsLogsPage> createState() => _SmsLogsPageState();
}

class _SmsLogsPageState extends State<SmsLogsPage> {
  final _view = GlobalKey<AsyncViewState<List<Map<String, dynamic>>>>();
  String _filter = 'all';
  bool _loadingMore = false;
  List<Map<String, dynamic>> _items = const [];
  bool _hasMore = false;
  int _nextOffset = 0;

  Future<List<Map<String, dynamic>>> _loadFirst() async {
    final status = _filter;
    final res = await merchantApi.storeSmsLogs(
      status: status,
      offset: 0,
      limit: 20,
    );
    final rows = [
      for (final r in (res['items'] as List? ?? const []))
        if (r is Map) Map<String, dynamic>.from(r),
    ];
    if (mounted && status == _filter) {
      _items = rows;
      _hasMore = res['has_more'] == true;
      _nextOffset = (res['next_offset'] as num?)?.toInt() ?? rows.length;
    }
    return rows;
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    final status = _filter;
    setState(() => _loadingMore = true);
    try {
      final res = await merchantApi.storeSmsLogs(
        status: status,
        offset: _nextOffset,
        limit: 20,
      );
      if (!mounted || status != _filter) return;
      final rows = [
        for (final r in (res['items'] as List? ?? const []))
          if (r is Map) Map<String, dynamic>.from(r),
      ];
      setState(() {
        _items = [..._items, ...rows];
        _hasMore = res['has_more'] == true;
        _nextOffset = (res['next_offset'] as num?)?.toInt() ?? _items.length;
      });
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    final state = _view.currentState;
    if (state != null) await state.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SubHeader('发送记录'),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: AppSegmented<String>(
                items: const [
                  SegmentItem(value: 'all', label: '全部'),
                  SegmentItem(value: 'delivered', label: '已送达'),
                  SegmentItem(value: 'failed', label: '失败'),
                ],
                selected: _filter,
                onChanged: (value) {
                  if (_filter == value) return;
                  setState(() {
                    _filter = value;
                    _loadingMore = false;
                  });
                  _view.currentState?.reload();
                },
              ),
            ),
            Expanded(
              child: AsyncView<List<Map<String, dynamic>>>(
                key: _view,
                load: _loadFirst,
                isEmpty: (rows) => rows.isEmpty,
                skeletonPadding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                skeleton: const SkeletonList(count: 5),
                empty: (_) => RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 320,
                        child: _filter == 'all'
                            ? const EmptyView(
                                icon: Icons.notifications_none_rounded,
                                title: '本店暂未发送业务通知短信',
                              )
                            : EmptyView(
                                kind: EmptyKind.filter,
                                title: _filter == 'failed'
                                    ? '没有发送失败的短信记录'
                                    : '没有已送达的短信记录',
                                actionLabel: '查看全部',
                                onAction: () {
                                  setState(() => _filter = 'all');
                                  _view.currentState?.reload();
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                builder: (_, rows) {
                  final list = _items.isEmpty ? rows : _items;
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: C.card,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: softShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < list.length; i++) ...[
                                if (i > 0) Divider(height: 1, color: C.line),
                                _row(list[i]),
                              ],
                              if (_hasMore) ...[
                                Divider(height: 1, color: C.line),
                                InkWell(
                                  onTap: _loadingMore ? null : _loadMore,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    child: Center(
                                      child: _loadingMore
                                          ? AppSpinner(
                                              size: 14,
                                              color: C.primaryInk,
                                            )
                                          : Text(
                                              '加载更多记录',
                                              style: ts(
                                                13,
                                                w: FontWeight.w600,
                                                color: C.primaryInk,
                                                h: 18,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(Map<String, dynamic> row) {
    final label = '${row['purpose_label'] ?? '门店通知短信'}';
    final phone = '${row['phone_masked'] ?? ''}';
    final content = '${row['content'] ?? ''}';
    final status = '${row['status'] ?? ''}';
    final delivery = '${row['delivery_status'] ?? 'unknown'}';
    final error = '${row['error'] ?? ''}'.trim();
    final timeStr = _formatTime(
      '${row['delivered_at'] ?? row['sent_at'] ?? row['created_at'] ?? ''}',
    );

    final (String badgeText, Color badgeBg, Color badgeFg) = switch (true) {
      _ when status == 'failed' || delivery == 'failed' => (
        '发送失败',
        C.redSoft,
        C.redInk,
      ),
      _ when delivery == 'delivered' => ('已送达', C.greenSoft, C.greenInk),
      _ when status == 'sent' => ('已受理', C.primarySoft, C.primaryInk),
      _ => ('发送中', C.amberSoft, C.amberInk),
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$label · $phone',
                  style: ts(14, w: FontWeight.w600, color: C.ink, h: 19),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: ts(11, w: FontWeight.w600, color: badgeFg, h: 14),
                ),
              ),
            ],
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              content,
              style: ts(12, color: C.sub, h: 17),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (error.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(error, style: ts(11, color: C.redInk, h: 15)),
          ],
          if (timeStr.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(timeStr, style: ts(11, color: C.faint, h: 15)),
          ],
        ],
      ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final cn = dt.toUtc().add(const Duration(hours: 8));
    String two(int n) => n.toString().padLeft(2, '0');
    return '${cn.month}/${cn.day} ${two(cn.hour)}:${two(cn.minute)}';
  }
}
