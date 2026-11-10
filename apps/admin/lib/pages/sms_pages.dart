import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

const _tabKinds = ['all', 'code', 'notice', 'failed'];

(Color, Color) _purposeColors(SmsLog s) {
  if (!s.isCode) return (C.greenInk, C.greenSoft);
  return switch (s.purpose) {
    'login' => (C.primaryInk, C.primarySoft),
    'register' => (C.amberInk, C.amberSoft),
    _ => (C.violetInk, C.violetSoft),
  };
}

(String, Color, Color) _statusLook(SmsLog s) => switch (s.status) {
  'sent' => (
    // TODO sms_delivery_receipt: 渠道只返回“已受理”，没有运营商送达回执，所以这里不写“已送达”。
    '已发送',
    C.green,
    C.greenInk,
  ),
  'failed' => ('失败', C.red, C.redInk),
  _ => ('发送中', C.amber, C.amberInk),
};

String _dayLabel(DateTime t) {
  final now = beijingDate(kNow.toIso8601String());
  final d = beijingDate(t.toIso8601String());
  final diff = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(d.year, d.month, d.day)).inDays;
  return diff == 0
      ? '今天'
      : diff == 1
      ? '昨天'
      : md(d);
}

Future<void> _copyCode(BuildContext context, SmsLog s) async {
  await Clipboard.setData(ClipboardData(text: s.code ?? ''));
  if (context.mounted) toast(context, '验证码已复制');
}

/// 重发：服务端生成新验证码并经真实渠道发送，遵守冷却与每日额度；失败时展示服务端文案。
Future<bool> _resend(BuildContext context, SmsLog s) async {
  try {
    await store.smsResend(s);
    if (context.mounted) toast(context, '验证码已重新发送');
    return true;
  } catch (e) {
    if (context.mounted) AppToast.error(context, e);
    return false;
  }
}

class SmsLogsPage extends StatefulWidget {
  const SmsLogsPage({super.key});
  @override
  State<SmsLogsPage> createState() => _SmsLogsPageState();
}

class _SmsLogsPageState extends State<SmsLogsPage> {
  final search = TextEditingController();
  int tab = 0;
  List<SmsLog> items = [];
  bool more = false;
  int failedCount = 0;
  bool loading = true;
  bool loadingMore = false;
  AppError? error;
  Timer? _debounce;
  Timer? _tick;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    // 验证码剩余时间每秒更新；没有可用验证码时不重绘。
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && items.any((s) => s.usable(kNow))) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tick?.cancel();
    search.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    final generation = append ? _generation : ++_generation;
    setState(() {
      if (append) {
        loadingMore = true;
      } else {
        loading = true;
      }
    });
    try {
      final page = await store.smsList(
        kind: _tabKinds[tab],
        phone: search.text.trim(),
        before: append ? items.last : null,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        items = append ? [...items, ...page.items] : page.items;
        more = page.more;
        failedCount = page.failedCount;
        error = null;
      });
    } catch (e) {
      if (!mounted || generation != _generation) return;
      final problem = AppError.from(e);
      if (items.isEmpty) {
        setState(() => error = problem);
      } else {
        // 已有内容时刷新失败只提示，不替换页面。
        AppToast.error(context, problem);
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          loading = false;
          loadingMore = false;
        });
      }
    }
  }

  void _searchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) unawaited(_load());
    });
  }

  Future<void> _open(SmsLog s) async {
    await go(context, SmsLogDetailPage(s.id));
    if (mounted) unawaited(_load());
  }

  String get _emptyText => search.text.trim().isNotEmpty
      ? '没有找到相关短信'
      : switch (tab) {
          3 => '暂时没有发送失败的短信',
          2 => '暂无通知短信',
          _ => '暂无短信记录',
        };

  Widget _body() {
    if (items.isEmpty) {
      if (loading) return const _SmsSkeleton();
      final problem = error;
      if (problem != null) {
        return ErrorView(
          inline: true,
          error: problem,
          retrying: loading,
          onRetry: () => unawaited(_load()),
        );
      }
      return EmptyView(title: _emptyText);
    }
    final groups = <String, List<SmsLog>>{};
    for (final s in items) {
      groups.putIfAbsent(_dayLabel(s.createdAt), () => []).add(s);
    }
    final now = kNow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Opacity(
          // 筛选 / 刷新时保留旧内容并变淡，不整页白屏。
          opacity: loading ? .6 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in groups.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4, bottom: 10),
                  child: Text(
                    entry.key,
                    style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
                  ),
                ),
                for (final s in entry.value)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _SmsCard(
                      s,
                      now,
                      onTap: () => unawaited(_open(s)),
                      onResend: () async {
                        if (await _resend(context, s) && mounted) {
                          unawaited(_load());
                        }
                      },
                    ),
                  ),
              ],
            ],
          ),
        ),
        if (more)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: LoadingButton(
              label: '加载更多',
              onPressed: () => _load(append: true),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '短信记录',
    gap: 14,
    onRefresh: _load,
    children: [
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, size: 18, color: C.muted),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: search,
                keyboardType: TextInputType.phone,
                onChanged: _searchChanged,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                style: ts(14, h: 20),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: '输入手机号，查最新验证码',
                  hintStyle: ts(14, color: C.faint, h: 20),
                ),
              ),
            ),
          ],
        ),
      ),
      Segmented(
        labels: const ['全部', '验证码', '通知', '失败'],
        index: tab,
        badges: {3: failedCount},
        onChanged: (i) {
          if (i == tab) return;
          setState(() => tab = i);
          unawaited(_load());
        },
      ),
      _body(),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          '仅超级管理员可见，其他运营账号看不到此入口。验证码完整显示，请勿外传。',
          style: ts(12, color: C.muted, h: 18),
        ),
      ),
    ],
  );
}

class _SmsSkeleton extends StatelessWidget {
  const _SmsSkeleton();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: HCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(width: 150, height: 18),
                SizedBox(height: 12),
                AppSkeleton(width: 170, height: 28),
                SizedBox(height: 12),
                AppSkeleton(width: 120, height: 14),
              ],
            ),
          ),
        ),
    ],
  );
}

class _SmsCard extends StatelessWidget {
  final SmsLog s;
  final DateTime now;
  final VoidCallback onTap;
  final Future<void> Function() onResend;
  const _SmsCard(this.s, this.now, {required this.onTap, required this.onResend});

  @override
  Widget build(BuildContext context) {
    final (purposeFg, purposeBg) = _purposeColors(s);
    final (statusText, dot, statusInk) = _statusLook(s);
    final active = s.usable(now);
    final life = s.lifeText(now);
    return HCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.phoneText, style: ts(15, w: FontWeight.w600, h: 22)),
              const SizedBox(width: 8),
              Pill(s.purposeLabel, purposeFg, purposeBg),
              const Spacer(),
              Text(s.timeText, style: ts(12, color: C.muted, h: 17)),
            ],
          ),
          const SizedBox(height: 8),
          if (s.failed)
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.error.isEmpty ? '发送失败' : '发送失败：${s.error}',
                    style: ts(14, color: C.redInk, h: 20),
                  ),
                ),
                if (s.isCode) ...[
                  const SizedBox(width: 10),
                  _PillAction('重发', C.redSoft, C.redInk, onResend),
                ],
              ],
            )
          else if (s.isCode && s.code != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.code!,
                    style: ts(
                      26,
                      w: FontWeight.w700,
                      color: active ? C.ink : C.faint,
                      h: 32,
                    ).copyWith(
                      letterSpacing: 6,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _PillAction(
                  '复制',
                  active ? C.primarySoft : C.chip,
                  active ? C.primaryInk : C.sub,
                  () => _copyCode(context, s),
                ),
              ],
            )
          else
            Text(s.content, style: ts(13, color: C.sub, h: 20)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(statusText, style: ts(12, color: statusInk, h: 17)),
              if (life.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text('·', style: ts(12, color: C.muted, h: 17)),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    life,
                    overflow: TextOverflow.ellipsis,
                    style: ts(12, color: C.muted, h: 17),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 卡片里的小胶囊按钮；异步动作进行中显示转圈并禁止重复点击，宽高不变。
class _PillAction extends StatefulWidget {
  final String label;
  final Color bg;
  final Color fg;
  final Future<void> Function() onPressed;
  const _PillAction(this.label, this.bg, this.fg, this.onPressed);
  @override
  State<_PillAction> createState() => _PillActionState();
}

class _PillActionState extends State<_PillAction> {
  bool busy = false;

  Future<void> _tap() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _tap,
      child: Container(
        height: 32,
        constraints: const BoxConstraints(minWidth: 58),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: busy
            ? AppSpinner(size: 14, color: widget.fg)
            : Text(
                widget.label,
                style: ts(13, w: FontWeight.w600, color: widget.fg, h: 18),
              ),
      ),
    ),
  );
}

class SmsLogDetailPage extends StatefulWidget {
  final String id;
  const SmsLogDetailPage(this.id, {super.key});
  @override
  State<SmsLogDetailPage> createState() => _SmsLogDetailPageState();
}

class _SmsLogDetailPageState extends State<SmsLogDetailPage> {
  SmsLog? log;
  AppError? error;
  bool loading = true;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final s = log;
      if (mounted && s != null && s.usable(kNow)) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final s = await store.smsGet(widget.id);
      if (!mounted) return;
      setState(() {
        log = s;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final problem = AppError.from(e);
      if (log == null) {
        setState(() => error = problem);
      } else {
        AppToast.error(context, problem);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resendAndBack(SmsLog s) async {
    if (await _resend(context, s) && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = log;
    if (s == null) {
      return AdPage(
        title: '短信详情',
        onRefresh: _load,
        children: [
          if (error != null)
            ErrorView(
              inline: true,
              error: error!,
              retrying: loading,
              onRetry: () => unawaited(_load()),
              onNext: () => Navigator.maybePop(context),
            )
          else
            const _DetailSkeleton(),
        ],
      );
    }
    final now = kNow;
    final (statusText, _, statusInk) = _statusLook(s);
    final active = s.usable(now);
    final life = s.failed
        ? (s.error.isEmpty ? '发送失败' : s.error)
        : s.lifeText(now);
    return AdPage(
      title: '短信详情',
      onRefresh: _load,
      dock: s.isCode
          ? Row(
              children: [
                Expanded(
                  flex: 10,
                  child: Btn('重发', ghost: true, onTap: () => _resendAndBack(s)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 14,
                  child: Btn(
                    '复制验证码',
                    onTap: s.code == null || s.failed
                        ? null
                        : () => _copyCode(context, s),
                  ),
                ),
              ],
            )
          : null,
      children: [
        DarkHero(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.purposeLabel} · ${s.phoneText}',
                style: ts(13, w: FontWeight.w500, color: const Color(0xFFA1A1AA), h: 19),
              ),
              const SizedBox(height: 10),
              if (s.isCode && s.code != null && !s.failed)
                Text(
                  s.code!,
                  style: ts(
                    40,
                    w: FontWeight.w700,
                    color: active ? C.gold : const Color(0xFF80808A),
                    h: 48,
                  ).copyWith(
                    letterSpacing: 10,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                )
              else
                Text(
                  s.failed ? '发送失败' : '—',
                  style: ts(28, w: FontWeight.w700, color: C.gold, h: 36),
                ),
              const SizedBox(height: 10),
              Text(
                life.isEmpty ? statusText : life,
                style: ts(12, color: const Color(0xFFA1A1AA), h: 17),
              ),
            ],
          ),
        ),
        HCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '短信内容',
                style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
              ),
              const SizedBox(height: 8),
              Text(s.content.isEmpty ? '—' : s.content, style: ts(14, h: 22)),
            ],
          ),
        ),
        HCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              KV('状态', statusText, vColor: statusInk),
              Divider(height: 1, color: C.line),
              KV('发送时间', SmsLog.full(s.createdAt)),
              Divider(height: 1, color: C.line),
              // TODO sms_delivery_receipt: 短信渠道暂无送达回执，不能把“已受理时间”当作送达时间。
              const KV('送达时间', '—'),
              Divider(height: 1, color: C.line),
              KV('触发场景', s.scene),
              Divider(height: 1, color: C.line),
              KV('短信通道', s.channelText),
              Divider(height: 1, color: C.line),
              KV('验证状态', s.verifyText(now)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      HCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(width: 160, height: 14),
            SizedBox(height: 14),
            AppSkeleton(width: 220, height: 40),
            SizedBox(height: 14),
            AppSkeleton(width: 120, height: 12),
          ],
        ),
      ),
      SizedBox(height: 16),
      HCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSkeleton(width: 80, height: 14),
            SizedBox(height: 12),
            AppSkeleton(height: 16),
          ],
        ),
      ),
    ],
  );
}
