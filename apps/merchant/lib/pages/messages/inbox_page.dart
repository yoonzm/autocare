import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/inbox_store.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../widgets/choice_chip_group.dart';
import '../../routes.dart' show openRoute;
import '../orders/order_detail_ref.dart';
import '../staff_app/task_route_data.dart';

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
        switch (target['type']) {
          case 'holds':
            openRoute(context, 'HoldList', arguments: 3);
          case 'order':
            openRoute(
              context,
              'OrderDetail',
              arguments: OrderDetailRef(kind: 'consume', id: '${target['id']}'),
            );
          case 'task':
            openRoute(
              context,
              'StTaskDetail',
              arguments: TaskRouteData(taskId: '${target['id']}'),
            );
          case 'arrivals':
            openRoute(context, 'StArrivals');
          case 'performance':
            openRoute(context, 'StPerf');
          case 'profile':
            openRoute(context, 'StMine');
          case 'none':
            break;
          default:
            AppToast.show(context, '${target['message'] ?? '该业务已不可访问'}');
        }
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

  Widget _row(Map<String, dynamic> m) {
    final unread = m['read_at'] == null;
    final at = DateTime.tryParse('${m['created_at']}')?.toLocal();
    final time = at == null
        ? ''
        : '${at.month}月${at.day}日 ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
    return AsyncActionScope(
      actionKey: '$_actionKey:${m['id']}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: dk(context, Colors.white, const Color(0xFF18181B)),
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: _mutating ? null : () => _open(m),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      hBusy(
                        '$_actionKey:${m['id']}',
                        Icon(
                          m['kind'] == 'task'
                              ? Icons.assignment_outlined
                              : m['kind'] == 'arrival'
                              ? Icons.directions_car_outlined
                              : Icons.notifications_none,
                          size: 22,
                          color: const Color(0xFF0485F7),
                        ),
                        icon: true,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${m['title']}',
                          style: hts(
                            15,
                            dk(context, const Color(0xFF18181B), Colors.white),
                            w: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          key: ValueKey('unread-${m['id']}'),
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${m['body'] ?? ''}',
                    style: hts(
                      13,
                      dk(
                        context,
                        const Color(0xFF52525B),
                        const Color(0xFFA8A8B3),
                      ),
                      lh: 20,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(time, style: hts(11, const Color(0xFF71717A))),
                ],
              ),
            ),
          ),
        ),
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
        header: AppPageHeader(
          title: '消息',
          trailing: SizedBox(
            width: 120,
            child: LoadingButton(
              label: '全部已读',
              loadingLabel: '处理中',
              height: 40,
              style: LoadingButtonStyle.secondary,
              onPressed:
                  _snapshot == null || _mutating || (_inbox?.unread ?? 0) == 0
                  ? null
                  : _readAll,
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: IgnorePointer(
                ignoring: _mutating || (_viewKey.currentState?.busy ?? false),
                child: ChoiceChipGroup<String>(
                  items: const [
                    ChoiceChipItem(value: 'all', label: '全部'),
                    ChoiceChipItem(value: 'task', label: '任务'),
                    ChoiceChipItem(value: 'arrival', label: '到店'),
                    ChoiceChipItem(value: 'system', label: '系统'),
                  ],
                  selected: _kind,
                  kind: ChipKind.pill,
                  columns: 4,
                  semanticLabel: '消息分类',
                  onChanged: (kind) {
                    if (kind == _kind) return;
                    setState(() => _kind = kind);
                    _reload();
                  },
                ),
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
                    for (final row in _items) _row(row),
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
