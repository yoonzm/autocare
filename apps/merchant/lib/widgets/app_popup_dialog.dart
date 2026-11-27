import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart' show AppSpinner;
import '../theme.dart';

/// 商户端应用内公告弹窗控制器：
/// 在登录就绪、切换身份及 App 切回前台时拉取服务端未读弹窗，按顺序美观展示，
/// 用户确认后调用 `inbox_popup_dismiss` 标记不再弹出。
class AppPopupCoordinator with WidgetsBindingObserver {
  AppPopupCoordinator._();
  static final AppPopupCoordinator instance = AppPopupCoordinator._();

  GlobalKey<NavigatorState>? _navKey;
  bool _started = false;
  bool _fetching = false;
  bool _showing = false;
  int _epoch = 0;
  final Set<String> _handledIds = {};

  void start({required GlobalKey<NavigatorState> navKey}) {
    _navKey = navKey;
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    Access.changed.addListener(_onIdentityChanged);
    unawaited(checkAndShow());
  }

  void _onIdentityChanged() {
    _epoch++;
    _handledIds.clear();
    unawaited(checkAndShow());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(checkAndShow());
    }
  }

  Future<void> checkAndShow() async {
    if (!_started || _fetching || _showing) return;
    if (!merchantApi.hasSession || Access.context.isEmpty) return;
    final ctx = _navKey?.currentContext;
    if (ctx == null || !ctx.mounted) return;

    _fetching = true;
    final version = _epoch;
    try {
      final data = await merchantApi.inbox('popups');
      if (!_started || version != _epoch) return;
      final raw = data['items'] as List? ?? const [];
      final queue = [
        for (final e in raw)
          if (e is Map && !_handledIds.contains('${e['id'] ?? ''}'))
            Map<String, dynamic>.from(e),
      ];
      if (queue.isEmpty) return;
      final currentCtx = _navKey?.currentContext;
      if (currentCtx == null || !currentCtx.mounted) return;

      _showing = true;
      try {
        await showAppPopupQueue(
          currentCtx,
          items: queue,
          onDismiss: (id) async {
            _handledIds.add(id);
            try {
              await merchantApi.inbox('popup_dismiss', {'id': id});
            } catch (_) {
              // 网络异常不阻塞关闭弹窗；下次恢复前台可重试。
            }
          },
        );
      } finally {
        _showing = false;
      }
    } catch (_) {
      // 弹窗拉取失败静默忽略，不影响主业务使用。
    } finally {
      _fetching = false;
    }
  }

  void dispose() {
    if (_started) {
      Access.changed.removeListener(_onIdentityChanged);
      WidgetsBinding.instance.removeObserver(this);
      _started = false;
    }
    _navKey = null;
    _handledIds.clear();
  }
}

/// 依次展示一条或多条平台公告弹窗。
Future<void> showAppPopupQueue(
  BuildContext context, {
  required List<Map<String, dynamic>> items,
  required Future<void> Function(String id) onDismiss,
}) async {
  if (items.isEmpty) return;
  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: '平台通知',
    barrierColor: Colors.black.withValues(alpha: C.dark ? 0.68 : 0.48),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogCtx, _, _) => _AppPopupDialog(
      items: items,
      onDismiss: onDismiss,
    ),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _AppPopupDialog extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Future<void> Function(String id) onDismiss;
  const _AppPopupDialog({required this.items, required this.onDismiss});

  @override
  State<_AppPopupDialog> createState() => _AppPopupDialogState();
}

class _AppPopupDialogState extends State<_AppPopupDialog> {
  int _index = 0;
  bool _busy = false;

  String _timeText(Object? raw) {
    final dt = DateTime.tryParse('$raw')?.toLocal();
    if (dt == null) return '';
    return '${dt.month}月${dt.day}日 '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _ack() async {
    if (_busy) return;
    final current = widget.items[_index];
    final id = '${current['id'] ?? ''}';
    setState(() => _busy = true);
    try {
      if (id.isNotEmpty) {
        await widget.onDismiss(id);
      }
      if (!mounted) return;
      if (_index + 1 < widget.items.length) {
        setState(() {
          _index++;
          _busy = false;
        });
      } else {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.items[_index];
    final total = widget.items.length;
    final hasNext = _index + 1 < total;
    final timeStr = _timeText(item['created_at']);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: C.card,
              borderRadius: BorderRadius.circular(28),
              border: C.dark
                  ? Border.all(color: const Color(0xFF2E2E34), width: 1)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: C.dark ? 0.5 : 0.14),
                  blurRadius: 32,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 顶部柔和品牌渐变头
                Container(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: C.dark
                          ? const [Color(0xFF1F2A3A), Color(0xFF18181B)]
                          : const [Color(0xFFEAF4FF), Color(0xFFFFFFFF)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: C.primarySoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.campaign_rounded,
                              size: 22,
                              color: C.primaryInk,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: C.primarySoft,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              '平台通知',
                              style: ts(
                                12,
                                w: FontWeight.w600,
                                color: C.primaryInk,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (total > 1)
                            Text(
                              '${_index + 1} / $total',
                              style: ts(
                                12,
                                w: FontWeight.w500,
                                color: C.muted,
                                tabular: true,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '${item['title'] ?? '通知'}',
                        style: ts(18, w: FontWeight.w700, h: 25),
                      ),
                      if (timeStr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          timeStr,
                          style: ts(12, color: C.muted, tabular: true),
                        ),
                      ],
                    ],
                  ),
                ),
                // 正文区域（支持长文滚动）
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: C.inset,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${item['body'] ?? ''}',
                          style: ts(14, color: C.sub, h: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                // 底部主操作按钮
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _ack,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: C.btn,
                        foregroundColor: C.btnFg,
                        disabledBackgroundColor: C.btn.withValues(alpha: 0.6),
                        disabledForegroundColor: C.btnFg,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _busy
                          ? AppSpinner(size: 18, color: C.btnFg)
                          : Text(
                              hasNext ? '下一条（${_index + 1}/$total）' : '我知道了',
                              style: ts(
                                15,
                                w: FontWeight.w600,
                                color: C.btnFg,
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
    );
  }
}
