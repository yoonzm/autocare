import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/inbox_store.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../routes.dart' show openRoute;
import 'inbox_navigation.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});
  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  InboxStore? _inbox;
  bool _ownsStore = false, _mutating = false, _pending = false;
  int _epoch = 0;
  int? _lastUnread;
  String? _lastLatest;
  String _kind = 'all';
  String? _snapshot;
  Map<String, dynamic>? _cursor;
  List<Map<String, dynamic>> _items = [];
  var _viewKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  String get _actionKey => 'inbox-${identityHashCode(this)}-$_epoch';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inbox != null) return;
    _inbox = InboxScope.of(context);
    if (_inbox == null) {
      _inbox = InboxStore();
      _ownsStore = true;
    }
    _epoch = _inbox!.epoch;
    _inbox!.addListener(_changed);
    if (_ownsStore) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _inbox!.start();
      });
    }
  }

  void _changed() {
    if (!mounted) return;
    if (_epoch != _inbox!.epoch) {
      _epoch = _inbox!.epoch;
      _items = [];
      _cursor = null;
      _snapshot = null;
      _lastUnread = null;
      _lastLatest = null;
      _mutating = false;
      _pending = false;
      setState(
        () => _viewKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>(),
      );
    } else if ((_lastUnread != _inbox!.unread ||
            _lastLatest != _inbox!.latest) &&
        _inbox!.unread != null &&
        !_mutating) {
      _reload();
    }
  }

  void _reload() {
    if (_mutating || _viewKey.currentState?.busy == true) {
      _pending = true;
      return;
    }
    unawaited(_viewKey.currentState?.reload());
  }

  void _settled() {
    if (_pending && mounted && !_mutating) {
      _pending = false;
      _reload();
    }
  }

  Future<Map<String, dynamic>> _load() async {
    while (true) {
      final kind = _kind;
      final data = await _inbox!.call('list', {'kind': kind});
      if (kind == _kind) return data;
    }
  }

  void _loaded(Map<String, dynamic> data) {
    _items = [
      for (final row in data['items'] as List? ?? [])
        Map<String, dynamic>.from(row as Map),
    ];
    _cursor = data['next'] == null
        ? null
        : Map<String, dynamic>.from(data['next'] as Map);
    _snapshot = data['snapshot_at'] as String?;
    _lastUnread = (data['unread'] as num?)?.toInt();
    _lastLatest = data['latest'] as String?;
    _inbox!.acceptUnread(data['unread'], newest: _lastLatest);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _more() async {
    if (_mutating || _viewKey.currentState?.busy == true || _cursor == null) {
      return;
    }
    final version = _epoch;
    setState(() => _mutating = true);
    try {
      final data = await _inbox!.call('list', {
        'kind': _kind,
        'cursor': _cursor,
      });
      if (!mounted || version != _epoch) return;
      final ids = _items.map((e) => e['id']).toSet();
      setState(() {
        _items.addAll([
          for (final row in data['items'] as List? ?? [])
            if (!ids.contains((row as Map)['id']))
              Map<String, dynamic>.from(row),
        ]);
        _cursor = data['next'] == null
            ? null
            : Map<String, dynamic>.from(data['next'] as Map);
      });
    } finally {
      if (mounted && version == _epoch) {
        setState(() => _mutating = false);
        _settled();
      }
    }
  }

  Future<void> _readAll() async {
    if (_mutating || _viewKey.currentState?.busy == true || _snapshot == null) {
      return;
    }
    final version = _epoch;
    setState(() => _mutating = true);
    try {
      final data = await _inbox!.call('read', {'before': _snapshot});
      if (!mounted || version != _epoch) return;
      _lastUnread = (data['unread'] as num?)?.toInt();
      _lastLatest = data['latest'] as String?;
      _inbox!.acceptUnread(data['unread'], newest: _lastLatest);
      setState(() {
        _items = [
          for (final m in _items) {...m, 'read_at': _snapshot},
        ];
      });
    } finally {
      if (mounted && version == _epoch) {
        setState(() => _mutating = false);
        _settled();
      }
    }
  }

  Future<void> _open(Map<String, dynamic> row) async {
    if (_mutating || _viewKey.currentState?.busy == true) return;
    final version = _epoch;
    setState(() => _mutating = true);
    await runBusy('$_actionKey:${row['id']}', () async {
      try {
        if (row['read_at'] == null) {
          final data = await _inbox!.call('read', {'id': row['id']});
          if (!mounted || version != _epoch) return;
          _lastUnread = (data['unread'] as num?)?.toInt();
          _lastLatest = data['latest'] as String?;
          _inbox!.acceptUnread(data['unread'], newest: _lastLatest);
          setState(() => row['read_at'] = DateTime.now().toIso8601String());
        }
        final target = await _inbox!.call('target', {'id': row['id']});
        if (!mounted || version != _epoch) return;
        openInboxTarget(context, target);
      } catch (e) {
        if (mounted && version == _epoch) AppToast.error(context, e);
      } finally {
        if (mounted && version == _epoch) {
          setState(() => _mutating = false);
          _settled();
        }
      }
    });
  }

  String _timeLabel(Object? raw) {
    final at = DateTime.tryParse('$raw')?.toLocal();
    if (at == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) {
      return '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    }
    if (day == DateTime(now.year, now.month, now.day - 1)) return '昨天';
    return '${at.month}月${at.day}日';
  }

  Widget _row(Map<String, dynamic> m) {
    final unread = m['read_at'] == null;
    final (icon, bg, fg) = switch (m['kind']) {
      'task' => ('receipt', C.greenSoft, C.greenInk),
      'arrival' => ('calendar', C.redSoft, C.redInk),
      _ => ('bell', C.primarySoft, C.primaryInk),
    };
    return AsyncActionScope(
      actionKey: '$_actionKey:${m['id']}',
      child: InkWell(
        onTap: _mutating ? null : () => _open(m),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: hBusy(
                  '$_actionKey:${m['id']}',
                  AppIcon(icon, size: 20, color: fg),
                  icon: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${m['title']}',
                                  style: ts(15, w: FontWeight.w600, h: 22),
                                ),
                              ),
                              if (unread) ...[
                                const SizedBox(width: 6),
                                Container(
                                  key: ValueKey('unread-${m['id']}'),
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF383C),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeLabel(m['created_at']),
                          style: ts(12, color: C.faint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${m['body'] ?? ''}',
                      style: ts(13, color: C.sub, h: 19),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _readAllButton() {
    final enabled =
        _snapshot != null && !_mutating && (_inbox?.unread ?? 0) > 0;
    return AsyncActionScope(
      actionKey: '$_actionKey:all',
      child: Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: !enabled
                ? null
                : () async {
                    await runBusy('$_actionKey:all', () async {
                      try {
                        await _readAll();
                      } catch (e) {
                        if (mounted) AppToast.error(context, e);
                      }
                    });
                  },
            child: SizedBox(
              width: 88,
              height: 44,
              child: Center(
                child: hBusy(
                  '$_actionKey:all',
                  Text('全部已读', style: ts(14, w: FontWeight.w500, h: 20)),
                  icon: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    const kinds = ['all', 'task', 'arrival', 'system'];
    const labels = ['全部', '任务', '到店', '系统'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: C.segment,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < kinds.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: Semantics(
                button: true,
                selected: _kind == kinds[i],
                child: GestureDetector(
                  onTap: () {
                    if (_kind == kinds[i]) return;
                    setState(() => _kind = kinds[i]);
                    _reload();
                  },
                  child: Container(
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _kind == kinds[i] ? C.card : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _kind == kinds[i] ? softShadow : null,
                    ),
                    child: Text(
                      labels[i],
                      style: ts(
                        13,
                        w: FontWeight.w500,
                        color: _kind == kinds[i] ? C.ink : C.sub,
                        h: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B));
    return Scaffold(
      backgroundColor: bg,
      body: HHeaderFrame(
        bg: bg,
        header: AppPageHeader(title: '消息中心', trailing: _readAllButton()),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: IgnorePointer(
                ignoring: _mutating || (_viewKey.currentState?.busy ?? false),
                child: _filters(),
              ),
            ),
            Expanded(
              child: AsyncView<Map<String, dynamic>>(
                key: _viewKey,
                load: _load,
                isEmpty: (d) => (d['items'] as List? ?? []).isEmpty,
                skeleton: const SkeletonList(count: 5),
                onLoaded: _loaded,
                onSettled: _settled,
                onNext: () => openRoute(context, 'Login'),
                empty: (_) =>
                    const EmptyView(title: '暂无消息', message: '新的业务通知会显示在这里'),
                builder: (_, _) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: softShadow,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                        clipBehavior: Clip.antiAlias,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            children: [
                              for (var i = 0; i < _items.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 68,
                                    color: C.line,
                                  ),
                                _row(_items[i]),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_cursor != null) const SizedBox(height: 16),
                    if (_cursor != null)
                      LoadingButton(
                        label: '加载更多',
                        loadingLabel: '加载中',
                        style: LoadingButtonStyle.secondary,
                        onPressed: _mutating ? null : _more,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inbox?.removeListener(_changed);
    if (_ownsStore) _inbox?.dispose();
    super.dispose();
  }
}
