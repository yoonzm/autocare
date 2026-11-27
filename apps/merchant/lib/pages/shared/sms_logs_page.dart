import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;
import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart' show AppSpinner;
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

/// 门店业务通知短信发送记录（独立二级页）。
class SmsLogsPage extends StatefulWidget {
  const SmsLogsPage({super.key});

  @override
  State<SmsLogsPage> createState() => _SmsLogsPageState();
}

class _SmsLogsPageState extends State<SmsLogsPage> {
  String _filter = 'all';
  bool _loading = false;
  bool _loaded = false;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  bool _hasMore = false;
  int _nextOffset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  Future<void> _load({required bool reset}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final res = await merchantApi.storeSmsLogs(
        status: _filter,
        offset: reset ? 0 : _nextOffset,
        limit: 20,
      );
      if (!mounted) return;
      final rows = [
        for (final r in (res['items'] as List? ?? const []))
          if (r is Map) Map<String, dynamic>.from(r),
      ];
      setState(() {
        _items = reset ? rows : [..._items, ...rows];
        _hasMore = res['has_more'] == true;
        _nextOffset = (res['next_offset'] as num?)?.toInt() ?? _items.length;
        _loaded = true;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppError.from(e).message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  setState(() => _filter = value);
                  _load(reset: true);
                },
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: ts(14, color: C.redInk, h: 20)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _load(reset: true),
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_loaded && _loading) {
      return Center(child: AppSpinner(size: 22, color: C.primary));
    }

    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(reset: true),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
          children: [
            Column(
              children: [
                AppIcon('bell', size: 32, color: C.faint),
                const SizedBox(height: 10),
                Text(
                  _filter == 'failed'
                      ? '暂无发送失败的短信记录'
                      : _filter == 'delivered'
                          ? '暂无已送达的短信记录'
                          : '本店暂未发送业务通知短信',
                  style: ts(14, color: C.muted, h: 20),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: ListView(
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
                for (var i = 0; i < _items.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: C.line),
                  _row(_items[i]),
                ],
                if (_hasMore) ...[
                  Divider(height: 1, color: C.line),
                  InkWell(
                    onTap: _loading ? null : () => _load(reset: false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: _loading
                            ? AppSpinner(size: 14, color: C.primaryInk)
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
