import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

const _statusKinds = ['all', 'cancelled', 'frozen'];

const _avatarTones = [
  [Color(0xFF7CC0FF), Color(0xFF0485F7)],
  [Color(0xFFF5B547), Color(0xFFE08A1E)],
  [Color(0xFFA78BFA), Color(0xFF7C5CE6)],
  [Color(0xFF59D49A), Color(0xFF17A864)],
];

(String, Tone) _statusLook(UserAccount a) => switch (a.status) {
  'cancelled' => ('已注销', Tone.off),
  'frozen' => ('已冻结', Tone.bad),
  _ => ('正常', Tone.ok),
};

Tone _roleTone(String role) => switch (role) {
  'owner' => Tone.dark,
  'manager' => Tone.violet,
  'cashier' => Tone.wait,
  _ => Tone.ok,
};

String _dateText(DateTime? t) {
  if (t == null) return '—';
  final d = beijingDate(t.toIso8601String());
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)}';
}

String _dateTimeText(DateTime? t) {
  if (t == null) return '—';
  final d = beijingDate(t.toIso8601String());
  String two(int n) => n.toString().padLeft(2, '0');
  return '${_dateText(t)} ${two(d.hour)}:${two(d.minute)}';
}

String _shortDate(DateTime t) {
  final d = beijingDate(t.toIso8601String());
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.month)}.${two(d.day)}';
}

class _Avatar extends StatelessWidget {
  final UserAccount a;
  final double size;
  const _Avatar(this.a, this.size);
  @override
  Widget build(BuildContext context) {
    final gone = a.status == 'cancelled';
    final tone = _avatarTones[a.id.hashCode.abs() % _avatarTones.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: gone ? C.stroke : null,
        gradient: gone
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: tone,
              ),
      ),
      child: Text(
        a.initial,
        style: ts(
          size * .39,
          w: FontWeight.w600,
          color: gone ? C.sub : Colors.white,
        ),
      ),
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});
  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final search = TextEditingController();
  int tab = 0;
  List<UserAccount> items = [];
  bool more = false;
  int total = 0;
  bool loading = true;
  AppError? error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _load({bool append = false}) async {
    final generation = append ? _generation : ++_generation;
    setState(() => loading = true);
    try {
      final page = await store.userList(
        status: _statusKinds[tab],
        q: search.text.trim(),
        before: append ? items.last : null,
      );
      if (!mounted || generation != _generation) return;
      setState(() {
        items = append ? [...items, ...page.items] : page.items;
        more = page.more;
        total = page.total;
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
      if (mounted && generation == _generation) setState(() => loading = false);
    }
  }

  Future<void> _open(UserAccount a) async {
    await go(context, UserDetailPage(a.id));
    if (mounted) unawaited(_load());
  }

  String get _emptyText => search.text.trim().isNotEmpty
      ? '没有找到相关账号'
      : switch (tab) {
          1 => '暂时没有注销中的账号',
          2 => '暂时没有已注销的账号',
          3 => '暂时没有已冻结的账号',
          _ => '暂无账号',
        };

  Widget _body() {
    if (items.isEmpty) {
      if (loading) return const _UsersSkeleton();
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
    return Column(
      children: [
        Opacity(
          // 筛选 / 刷新时保留旧内容并变淡，不整页白屏。
          opacity: loading ? .6 : 1,
          child: Column(
            children: [
              for (final a in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _UserCard(a, onTap: () => unawaited(_open(a))),
                ),
            ],
          ),
        ),
        if (more)
          LoadingButton(label: '加载更多', onPressed: () => _load(append: true)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AdPage(
    title: '用户账号',
    gap: 14,
    onRefresh: _load,
    children: [
      AppSearchBar(
        controller: search,
        hint: '手机号 / 姓名 / 门店名',
        onChanged: (_) {
          if (mounted) unawaited(_load());
        },
      ),
      AppSegmented<int>(
        items: const [
          SegmentItem(value: 0, label: '全部'),
          SegmentItem(value: 1, label: '已注销'),
          SegmentItem(value: 2, label: '已冻结'),
        ],
        selected: tab,
        onChanged: (i) {
          if (i == tab) return;
          setState(() => tab = i);
          unawaited(_load());
        },
      ),
      if (total > 0)
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            '共 ${_thousands(total)} 个账号 · 含老板、店长、前台、技师',
            style: ts(13, color: C.sub, h: 18),
          ),
        ),
      _body(),
    ],
  );
}

String _thousands(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

class _UsersSkeleton extends StatelessWidget {
  const _UsersSkeleton();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 4; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const AppSkeleton.circle(size: 46),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSkeleton(width: 120, height: 18),
                      SizedBox(height: 8),
                      AppSkeleton(width: 160, height: 14),
                    ],
                  ),
                ),
                const AppSkeleton(width: 44, height: 18, radius: 9),
              ],
            ),
          ),
        ),
    ],
  );
}

class _UserCard extends StatelessWidget {
  final UserAccount a;
  final VoidCallback onTap;
  const _UserCard(this.a, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (statusText, statusTone) = _statusLook(a);
    final gone = a.status == 'cancelled';
    final third = switch (a.status) {
      'cancelled' when a.cancelledAt != null => (
        '${_shortDate(a.cancelledAt!)} 已注销',
        C.muted,
      ),
      'frozen' => ('账号已冻结', C.redInk),
      _ => null,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: softShadow,
        ),
        child: Row(
          children: [
            _Avatar(a, 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.phoneText,
                    style: ts(
                      15,
                      w: FontWeight.w600,
                      color: gone ? C.muted : C.ink,
                      h: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      AppStatusTag(a.roleLabel, tone: _roleTone(a.role)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          a.summary,
                          overflow: TextOverflow.ellipsis,
                          style: ts(12, color: C.muted, h: 17),
                        ),
                      ),
                    ],
                  ),
                  if (third != null) ...[
                    const SizedBox(height: 3),
                    Text(third.$1, style: ts(12, color: third.$2, h: 17)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppStatusTag(statusText, tone: statusTone),
          ],
        ),
      ),
    );
  }
}

class UserDetailPage extends StatefulWidget {
  final String id;
  const UserDetailPage(this.id, {super.key});
  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  UserDetail? detail;
  AppError? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final d = await store.userGet(widget.id);
      if (!mounted) return;
      setState(() {
        detail = d;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final problem = AppError.from(e);
      if (detail == null) {
        setState(() => error = problem);
      } else {
        AppToast.error(context, problem);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _force(UserDetail d) async {
    final a = d.account;
    final done = await showAppBottomSheet<bool>(
      context,
      title: '强制注销账号',
      subtitle: [
        a.phoneText,
        a.roleLabel,
        if (a.identities.isNotEmpty) a.identities.first.storeName,
      ].join(' · '),
      builder: (_) => _ForceCancelSheet(d),
    );
    if (done != true || !mounted) return;
    toast(context, '账号已强制注销');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final d = detail;
    if (d == null) {
      return AdPage(
        title: '账号详情',
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
    final a = d.account;
    final (statusText, statusTone) = _statusLook(a);
    final statusFg = toneColors(AppTokens.of(context), statusTone).fg;
    final cancelled = a.status == 'cancelled';
    return AdPage(
      title: '账号详情',
      onRefresh: _load,
      bottomBar: cancelled
          ? null
          : AppBottomBar(
              secondary: AppButton(
                label: '冻结账号',
                kind: AppButtonKind.secondary,
                // TODO account_freeze: 账号冻结的后台操作本期未实现，后端预期接口 user_freeze。
                onPressed: () => toast(context, '账号冻结暂未接通，本期只支持强制注销'),
              ),
              primary: AppButton(
                label: '强制注销',
                kind: AppButtonKind.danger,
                // 只是打开弹层，不进入加载状态。
                onPressed: () {
                  unawaited(_force(d));
                },
              ),
            ),
      dock: cancelled
          ? Text(
              '该账号已注销',
              textAlign: TextAlign.center,
              style: ts(13, color: C.muted, h: 50),
            )
          : null,
      children: [
        AppHeroCard.custom(child: Row(
            children: [
              _Avatar(a, 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.phoneText,
                      style: ts(
                        20,
                        w: FontWeight.w600,
                        color: const Color(0xFFFAFAFA),
                        h: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${a.maskedName} · 注册于 ${_dateText(a.createdAt)}',
                      style: ts(12, color: const Color(0xFFA1A1AA), h: 17),
                    ),
                  ],
                ),
              ),
              AppStatusTag(statusText, tone: Tone.gold),
            ],
          )),
        if (cancelled) _cancelledCard(a),
        if (a.identities.isNotEmpty)
          Section(
            '门店身份',
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (var n = 0; n < a.identities.length; n++) ...[
                    if (n > 0) Divider(height: 1, color: C.line),
                    Container(
                      constraints: const BoxConstraints(minHeight: 56),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.identities[n].storeName,
                                  style: ts(14, w: FontWeight.w500, h: 20),
                                ),
                                if (a.identities[n].joinedOn != null)
                                  Text(
                                    '加入于 ${_dateText(a.identities[n].joinedOn)}',
                                    style: ts(12, color: C.muted, h: 16),
                                  ),
                              ],
                            ),
                          ),
                          AppStatusTag(
                            userRoleLabel(a.identities[n].role),
                            tone: _roleTone(a.identities[n].role),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        Section(
          '登录与安全',
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                KV('最近登录', _dateTimeText(a.lastSignInAt)),
                Divider(height: 1, color: C.line),
                KV('登录设备', d.devices > 0 ? '${d.devices} 台在线' : '无在线设备'),
                Divider(height: 1, color: C.line),
                KV(
                  '账号状态',
                  switch (a.status) {
                    'cancelled' => '已注销',
                    'frozen' => '已冻结',
                    _ => '正常',
                  },
                  vColor: a.status == 'active' ? null : statusFg,
                ),
              ],
            ),
          ),
        ),
        Section(
          '操作记录',
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: d.events.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('暂无操作记录', style: ts(14, color: C.muted, h: 20)),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < d.events.length; i++) ...[
                        if (i > 0) Divider(height: 1, color: C.line),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.events[i].text,
                                      style: ts(14, h: 20),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${_dateTimeText(d.events[i].at)} · ${d.events[i].by}',
                                      style: ts(12, color: C.muted, h: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _cancelledCard(UserAccount a) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: C.chip,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('账号已注销', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 10),
        _grid('注销时间', _dateTimeText(a.cancelledAt), muted: true),
        _grid(
          '方式',
          a.cancelSource == 'admin' ? '后台强制注销' : '用户自助注销',
          muted: true,
        ),
        if (a.cancelReason.isNotEmpty)
          _grid(
            '原因',
            switch (a.cancelReason) {
              'user_request' => '用户要求',
              'violation' => '违规处理',
              _ => '其他',
            },
            muted: true,
          ),
        if (a.cancelNote.isNotEmpty) _grid('备注', a.cancelNote, muted: true),
        const SizedBox(height: 4),
        Text(
          '账号已无法登录，所有设备已退出；店铺数据保留。',
          style: ts(12, color: C.sub, h: 18),
        ),
      ],
    ),
  );

  Widget _grid(String k, String v, {bool muted = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(k, style: ts(13, color: muted ? C.sub : C.amberInk, h: 19)),
        ),
        Expanded(child: Text(v, style: ts(13, h: 19))),
      ],
    ),
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();
  @override
  Widget build(BuildContext context) => const Column(
    children: [
      AppCard(
        child: Row(
          children: [
            AppSkeleton.circle(size: 56),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(width: 140, height: 22),
                  SizedBox(height: 8),
                  AppSkeleton(width: 120, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 16),
      AppCard(
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

const _forceReasons = [
  ('user_request', '用户要求'),
  ('violation', '违规处理'),
  ('other', '其他'),
];
const _forceWord = '强制注销';

/// 强制注销底部弹层：只停用账号并让所有设备退出，不删除任何门店数据；输入「强制注销」后才能确认。
class _ForceCancelSheet extends StatefulWidget {
  final UserDetail detail;
  const _ForceCancelSheet(this.detail);
  @override
  State<_ForceCancelSheet> createState() => _ForceCancelSheetState();
}

class _ForceCancelSheetState extends State<_ForceCancelSheet> {
  final confirmText = TextEditingController();
  int reason = 0;
  String? error;
  bool submitting = false;

  @override
  void dispose() {
    confirmText.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => submitting = true);
    try {
      await store.userCancel(widget.detail.account, _forceReasons[reason].$1, '');
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          error = AppError.from(e).message;
          submitting = false;
        });
      }
    }
  }

  Widget _impact(IconData icon, Color color, String text, Color ink) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: ts(13, color: ink, h: 19))),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    final a = d.account;
    final t = AppTokens.of(context);
    final ready = confirmText.text.trim() == _forceWord;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppBanner.err(
          '立即生效。该账号所有设备被强制退出，之后无法登录，且不可恢复；手机号可重新注册为新账号，原账号的门店数据保留。',
        ),
        const SizedBox(height: 12),
        Text('影响范围', style: t.small),
        const SizedBox(height: 6),
        _impact(Icons.check_rounded, t.success, '只注销这个账号，店铺数据、订单、会员全部保留', t.inkSub),
        if (d.openTotal == 0)
          _impact(Icons.check_rounded, t.success, '无进行中的订单与挂单', t.inkSub)
        else
          _impact(
            Icons.warning_amber_rounded,
            t.warn.fg,
            '有 ${d.openHolds} 个挂单、${d.openAppointments} 个待到店预约，注销后需要他人接手',
            t.warn.fg,
          ),
        if (a.role == 'owner')
          _impact(
            Icons.warning_amber_rounded,
            t.warn.fg,
            '若是老板账号，门店数据仍保留，但注销后无人能登录管理',
            t.warn.fg,
          ),
        const SizedBox(height: 6),
        AppChoiceGroup<int>(
          selected: reason,
          onChanged: (i) => setState(() => reason = i),
          items: [
            for (var i = 0; i < _forceReasons.length; i++)
              ChoiceItem(value: i, label: _forceReasons[i].$2, enabled: !submitting),
          ],
        ),
        const SizedBox(height: 12),
        AppTextField(
          label: '输入「$_forceWord」以确认',
          controller: confirmText,
          hint: _forceWord,
          enabled: !submitting,
          errorText: error,
          onChanged: (_) => setState(() => error = null),
        ),
        const SizedBox(height: 6),
        Text('操作人、时间和原因会被记录。仅超级管理员可操作。', style: t.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: '取消',
                kind: AppButtonKind.secondary,
                size: AppButtonSize.large,
                expanded: true,
                onPressed: submitting ? null : () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: AppButton(
                label: '确认强制注销',
                kind: AppButtonKind.danger,
                size: AppButtonSize.large,
                expanded: true,
                loading: submitting,
                onPressed: ready ? _submit : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
