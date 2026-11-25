import 'dart:async';

import 'package:flutter/material.dart';

import 'access_flow.dart';
import 'merchant_api.dart';

/// 随登录身份清空；只有 App 在前台时每 30 秒读取未读数。
class InboxStore extends ChangeNotifier with WidgetsBindingObserver {
  int epoch = 0;
  int? unread;
  String? latest;
  AppError? error;
  bool _disposed = false, _started = false, _active = true, _busy = false;
  int _request = 0;
  Timer? _timer;
  bool get ready => merchantApi.hasSession && Access.context.isNotEmpty;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    Access.changed.addListener(_identityChanged);
    _active =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    _schedule();
    unawaited(refresh());
  }

  void _identityChanged() {
    epoch++;
    _request++;
    _busy = false;
    unread = null;
    latest = null;
    error = null;
    notifyListeners();
    _schedule();
    unawaited(refresh());
  }

  void _schedule() {
    _timer?.cancel();
    if (_active && ready) {
      _timer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => unawaited(refresh()),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    _schedule();
    if (_active) unawaited(refresh());
  }

  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> args = const {},
  ]) async {
    final version = epoch;
    final result = await merchantApi.inbox(action, args);
    if (_disposed || version != epoch) {
      throw const AppError('登录身份已变化，请重新打开消息', type: AppErrorType.auth);
    }
    return result;
  }

  void acceptUnread(Object? value, {String? newest}) {
    _request++;
    _busy = false;
    final next = (value as num?)?.toInt() ?? 0;
    final changed = unread != next || latest != newest || error != null;
    latest = newest;
    unread = next;
    error = null;
    if (!_disposed && changed) notifyListeners();
  }

  Future<void> refresh() async {
    if (_disposed || !_active || !ready || _busy) return;
    _busy = true;
    final request = ++_request;
    final version = epoch;
    try {
      final data = await call('unread');
      if (_disposed || version != epoch || request != _request) return;
      acceptUnread(data['unread'], newest: data['latest'] as String?);
    } catch (e) {
      if (_disposed || version != epoch || request != _request) return;
      error = AppError.from(e);
      notifyListeners();
    } finally {
      if (request == _request) _busy = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (_started) {
      Access.changed.removeListener(_identityChanged);
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
}

class InboxScope extends InheritedNotifier<InboxStore> {
  const InboxScope({super.key, required InboxStore store, required super.child})
    : super(notifier: store);
  static InboxStore? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InboxScope>()?.notifier;
}

class InboxHost extends StatefulWidget {
  final Widget child;
  const InboxHost({super.key, required this.child});
  @override
  State<InboxHost> createState() => _InboxHostState();
}

class _InboxHostState extends State<InboxHost> {
  final store = InboxStore();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) store.start();
    });
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      InboxScope(store: store, child: widget.child);
}
