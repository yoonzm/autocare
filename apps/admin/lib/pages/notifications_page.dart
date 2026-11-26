import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../data/store.dart';
import '../theme.dart';
import '../ui.dart';

const _roleLabels = {
  'owner': '老板',
  'manager': '店长',
  'cashier': '前台',
  'technician': '技师',
};

const _channelMeta = [
  ('inbox', '站内信', '写入 App 消息中心并留痕'),
  ('push', 'App 推送', '通过阿里云 EMAS 推送到已绑定设备'),
  ('sms', '短信', '通过助通自定义短信通道下发'),
  ('popup', '应用内弹窗', '打开或切回 App 时强提醒展示'),
];

String _audienceLabel(Map<String, dynamic> n) {
  final type = '${n['audience_type'] ?? ''}';
  final role = n['audience_role'] as String?;
  final storeName = '${n['audience_store_name'] ?? ''}';
  return switch (type) {
    'all' => '全员',
    'role' => '全部${_roleLabels[role] ?? '成员'}',
    'store' =>
      role == null ? '$storeName · 全员' : '$storeName · ${_roleLabels[role] ?? role}',
    _ => '指定个人',
  };
}

String _channelName(String key) => switch (key) {
  'inbox' => '站内信',
  'push' => '推送',
  'sms' => '短信',
  'popup' => '弹窗',
  _ => key,
};

Tone _channelTone(String key) => switch (key) {
  'inbox' => Tone.wait,
  'push' => Tone.violet,
  'sms' => Tone.ok,
  'popup' => Tone.warn,
  _ => Tone.off,
};

String _fmtTime(Object? raw) {
  final dt = DateTime.tryParse('$raw');
  if (dt == null) return '';
  final bj = beijingDate(dt.toIso8601String());
  return '${bj.month.toString().padLeft(2, '0')}-${bj.day.toString().padLeft(2, '0')} '
      '${bj.hour.toString().padLeft(2, '0')}:${bj.minute.toString().padLeft(2, '0')}';
}

bool _popupActive(Map<String, dynamic> n) {
  final channels = List<String>.from(n['channels'] as List? ?? const []);
  if (!channels.contains('popup')) return false;
  if (n['popup_revoked_at'] != null) return false;
  final expRaw = n['popup_expires_at'];
  if (expRaw != null) {
    final exp = DateTime.tryParse('$expRaw');
    if (exp != null && exp.isBefore(DateTime.now().toUtc())) return false;
  }
  return true;
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> items = [];
  bool more = false;
  bool loading = true;
  bool loadingMore = false;
  AppError? error;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load({bool append = false}) async {
    setState(() {
      if (append) {
        loadingMore = true;
      } else {
        loading = true;
      }
    });
    try {
      final last = append && items.isNotEmpty ? items.last : null;
      final page = await store.notificationList(
        beforeAt: last == null ? null : DateTime.tryParse('${last['created_at']}'),
        beforeId: last == null ? null : '${last['id']}',
      );
      if (!mounted) return;
      setState(() {
        items = append ? [...items, ...page.items] : page.items;
        more = page.more;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      final problem = AppError.from(e);
      if (items.isEmpty) {
        setState(() => error = problem);
      } else {
        AppToast.error(context, problem);
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          loadingMore = false;
        });
      }
    }
  }

  Future<void> _openCompose() async {
    final sent = await go<bool>(context, const NotificationComposePage());
    if (sent == true && mounted) unawaited(_load());
  }

  Future<void> _openDetail(Map<String, dynamic> n) async {
    final channels = List<String>.from(n['channels'] as List? ?? const []);
    final canRevoke = _popupActive(n);
    final revoked = await showAppBottomSheet<bool>(
      context,
      title: '${n['title'] ?? '通知详情'}',
      subtitle: '${_audienceLabel(n)} · ${_fmtTime(n['created_at'])} · ${n['actor_name'] ?? ''}',
      builder: (sheetCtx) => _NotificationDetailSheet(
        item: n,
        channels: channels,
        canRevoke: canRevoke,
      ),
    );
    if (revoked == true && mounted) unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    return AdPage(
      title: '通知中心',
      action: AppIconButton(
        key: const ValueKey('compose-notification'),
        icon: Icons.add_rounded,
        semanticLabel: '发通知',
        kind: AppIconButtonKind.primary,
        onPressed: _openCompose,
      ),
      onRefresh: _load,
      children: [
        if (loading && items.isEmpty)
          const AppCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.2)),
            ),
          )
        else if (error != null && items.isEmpty)
          ErrorView(error: error!, onNext: _load)
        else if (items.isEmpty)
          AppCard(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
              child: Column(
                children: [
                  Icon(Icons.campaign_outlined, size: 36, color: C.muted),
                  const SizedBox(height: 10),
                  Text('暂无发送记录', style: ts(15, w: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '可向指定人员、门店、角色或全员发送站内信、推送、短信或应用内弹窗。',
                    textAlign: TextAlign.center,
                    style: ts(13, color: C.muted, h: 19),
                  ),
                  const SizedBox(height: 14),
                  AppButton(label: '发送第一条通知', onPressed: _openCompose),
                ],
              ),
            ),
          )
        else ...[
          for (final n in items) _recordCard(n),
          if (more)
            AppButton(
              label: loadingMore ? '加载中…' : '加载更多',
              kind: AppButtonKind.secondary,
              expanded: true,
              loading: loadingMore,
              onPressed: loadingMore ? null : () => _load(append: true),
            ),
        ],
      ],
    );
  }

  Widget _recordCard(Map<String, dynamic> n) {
    final channels = List<String>.from(n['channels'] as List? ?? const []);
    final activePopup = _popupActive(n);
    final revokedPopup = n['popup_revoked_at'] != null;
    return AppCard(
      onTap: () => _openDetail(n),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${n['title'] ?? ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(15, w: FontWeight.w600, h: 21),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _fmtTime(n['created_at']),
                style: ts(12, color: C.muted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${n['body'] ?? ''}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: ts(13, color: C.sub, h: 19),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              AppStatusTag(
                '${_audienceLabel(n)} · ${n['recipient_count'] ?? 0}人',
                tone: Tone.off,
              ),
              for (final ch in channels)
                AppStatusTag(_channelName(ch), tone: _channelTone(ch)),
              if (activePopup)
                const AppStatusTag('弹窗生效中', tone: Tone.ok)
              else if (revokedPopup)
                const AppStatusTag('弹窗已撤回', tone: Tone.bad),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationDetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final List<String> channels;
  final bool canRevoke;
  const _NotificationDetailSheet({
    required this.item,
    required this.channels,
    required this.canRevoke,
  });
  @override
  State<_NotificationDetailSheet> createState() =>
      _NotificationDetailSheetState();
}

class _NotificationDetailSheetState extends State<_NotificationDetailSheet> {
  bool _busy = false;

  Future<void> _revoke() async {
    setState(() => _busy = true);
    try {
      await store.notificationRevokePopup('${widget.item['id']}');
      if (!mounted) return;
      toast(context, '弹窗已撤回');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.item;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: C.inset,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('${n['body'] ?? ''}', style: ts(14, h: 21)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppStatusTag('命中 ${n['recipient_count'] ?? 0} 人', tone: Tone.off),
            if (widget.channels.contains('inbox'))
              AppStatusTag('站内信 ${n['inbox_count'] ?? 0}', tone: Tone.wait),
            if (widget.channels.contains('push'))
              AppStatusTag('推送入队 ${n['push_count'] ?? 0}', tone: Tone.violet),
            if (widget.channels.contains('sms'))
              AppStatusTag(
                '短信成功 ${n['sms_sent'] ?? 0} / 失败 ${n['sms_failed'] ?? 0}',
                tone: (n['sms_failed'] as int? ?? 0) > 0 ? Tone.bad : Tone.ok,
              ),
            if (widget.channels.contains('popup'))
              AppStatusTag('弹窗 ${n['popup_count'] ?? 0}', tone: Tone.warn),
          ],
        ),
        if (n['popup_expires_at'] != null) ...[
          const SizedBox(height: 8),
          Text(
            '弹窗有效期至：${_fmtTime(n['popup_expires_at'])}',
            style: ts(12, color: C.muted),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: '关闭',
                kind: AppButtonKind.secondary,
                size: AppButtonSize.large,
                expanded: true,
                onPressed: _busy ? null : () => Navigator.pop(context),
              ),
            ),
            if (widget.canRevoke) ...[
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: '撤回弹窗',
                  kind: AppButtonKind.danger,
                  size: AppButtonSize.large,
                  expanded: true,
                  loading: _busy,
                  onPressed: _busy ? null : _revoke,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class NotificationComposePage extends StatefulWidget {
  const NotificationComposePage({super.key});
  @override
  State<NotificationComposePage> createState() =>
      _NotificationComposePageState();
}

class _NotificationComposePageState extends State<NotificationComposePage> {
  final _title = TextEditingController();
  final _body = TextEditingController();

  String _audience = 'users'; // users | store | role | all
  String? _storeId;
  String? _role = 'owner';
  String _storeRole = 'all';
  final List<Map<String, dynamic>> _selectedUsers = [];
  final Set<String> _channels = {'inbox', 'push'};
  int _popupDays = 3; // 1 | 3 | 7 | 0(长期)
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (store.merchants.isNotEmpty) {
      _storeId = store.merchants.first.id;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  String _userKey(Map<String, dynamic> u) =>
      '${u['store_id']}:${u['staff_id'] ?? ''}:${u['owner_id'] ?? ''}';

  Future<void> _pickRecipients() async {
    final picked = await showAppBottomSheet<List<Map<String, dynamic>>>(
      context,
      title: '选择接收人',
      subtitle: '可按姓名、手机号或门店名搜索老板与在职员工',
      builder: (_) => _RecipientPickerSheet(initial: _selectedUsers),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedUsers
          ..clear()
          ..addAll(picked);
      });
    }
  }

  Future<void> _pickStore() async {
    final merchants = store.merchants;
    if (merchants.isEmpty) {
      toast(context, '暂无可选门店');
      return;
    }
    final idx = await pickOption(
      context,
      title: '选择目标门店',
      options: [
        for (final m in merchants)
          SheetOption(m.name, '${m.owner} · ${m.phone}'),
      ],
    );
    if (idx != null && mounted) {
      setState(() => _storeId = merchants[idx].id);
    }
  }

  Merchant? get _selectedMerchant {
    for (final m in store.merchants) {
      if (m.id == _storeId) return m;
    }
    return null;
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final body = _body.text.trim();
    if (title.isEmpty || title.length > 60) {
      toast(context, '请填写 1~60 字的通知标题');
      return;
    }
    if (body.isEmpty || body.length > 500) {
      toast(context, '请填写 1~500 字的通知内容');
      return;
    }
    if (_channels.isEmpty) {
      toast(context, '请至少选择一种发送渠道');
      return;
    }
    if (_audience == 'users' && _selectedUsers.isEmpty) {
      toast(context, '请至少选择一位接收人');
      return;
    }
    if (_audience == 'store' && _storeId == null) {
      toast(context, '请选择目标门店');
      return;
    }

    final targets = _audience == 'users'
        ? [
            for (final u in _selectedUsers)
              {
                'store_id': u['store_id'],
                'staff_id': u['staff_id'],
                'owner_id': u['owner_id'],
                'label': '${u['name']} (${u['store_name']})',
              },
          ]
        : const <Map<String, dynamic>>[];

    final roleParam = _audience == 'role'
        ? _role
        : (_audience == 'store' && _storeRole != 'all' ? _storeRole : null);

    setState(() => _submitting = true);
    try {
      final preview = await store.notificationPreview(
        audienceType: _audience,
        storeId: _audience == 'store' ? _storeId : null,
        role: roleParam,
        targets: targets,
      );
      if (!mounted) return;
      final recCount = preview['recipient_count'] as int? ?? 0;
      if (recCount == 0) {
        setState(() => _submitting = false);
        toast(context, '当前条件下没有可触达的接收人');
        return;
      }
      final phoneCount = preview['phone_count'] as int? ?? 0;
      final deviceCount = preview['push_device_count'] as int? ?? 0;
      final chText = _channels.map(_channelName).join('、');
      final extra = [
        if (_channels.contains('push')) '已绑推送设备 $deviceCount 人',
        if (_channels.contains('sms')) '预计发短信 $phoneCount 个手机号',
      ].join('；');

      setState(() => _submitting = false);
      final ok = await showAppDialog(
        context,
        title: '确认发送通知',
        message:
            '预计触达 $recCount 人，渠道：$chText。${extra.isEmpty ? '' : '\n$extra。'}\n发送后无法撤回短信与推送，确认立即发送吗？',
        confirmLabel: '确认发送',
        danger: _audience == 'all' || _channels.contains('sms'),
        onConfirm: () async {
          final expires = _channels.contains('popup') && _popupDays > 0
              ? DateTime.now().toUtc().add(Duration(days: _popupDays))
              : null;
          await store.notificationSend(
            title: title,
            body: body,
            audienceType: _audience,
            storeId: _audience == 'store' ? _storeId : null,
            role: roleParam,
            targets: targets,
            channels: _channels.toList(),
            popupExpiresAt: expires,
          );
        },
      );
      if (ok && mounted) {
        toast(context, '通知已发送');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final merchant = _selectedMerchant;
    return AdPage(
      title: '发送通知',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('发送对象', style: ts(14, w: FontWeight.w600)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (key, label) in const [
                    ('users', '指定个人'),
                    ('store', '指定门店'),
                    ('role', '按角色'),
                    ('all', '全员'),
                  ])
                    AppChoiceChip(
                      label: label,
                      selected: _audience == key,
                      onTap: () => setState(() => _audience = key),
                    ),
                ],
              ),
              if (_audience == 'users') ...[
                const SizedBox(height: 12),
                if (_selectedUsers.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final u in _selectedUsers)
                        AppChoiceChip(
                          label:
                              '${u['name']} · ${_roleLabels[u['role']] ?? u['role']} ×',
                          selected: true,
                          onTap: () => setState(() {
                            final k = _userKey(u);
                            _selectedUsers.removeWhere((e) => _userKey(e) == k);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                AppButton(
                  label: _selectedUsers.isEmpty
                      ? '选择接收人'
                      : '继续添加（已选 ${_selectedUsers.length} 人）',
                  kind: AppButtonKind.secondary,
                  size: AppButtonSize.small,
                  onPressed: _pickRecipients,
                ),
              ] else if (_audience == 'store') ...[
                const SizedBox(height: 12),
                AppListRow(
                  title: merchant?.name ?? '请选择门店',
                  subtitle: merchant == null
                      ? '点击从门店列表中选择'
                      : '${merchant.owner} · ${merchant.phone}',
                  onTap: _pickStore,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (key, label) in const [
                      ('all', '门店全员'),
                      ('owner', '仅老板'),
                      ('manager', '仅店长'),
                      ('cashier', '仅前台'),
                      ('technician', '仅技师'),
                    ])
                      AppChoiceChip(
                        label: label,
                        selected: _storeRole == key,
                        onTap: () => setState(() => _storeRole = key),
                      ),
                  ],
                ),
              ] else if (_audience == 'role') ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in _roleLabels.entries)
                      AppChoiceChip(
                        label: '全部${entry.value}',
                        selected: _role == entry.key,
                        onTap: () => setState(() => _role = entry.key),
                      ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 10),
                Text(
                  '将触达平台内全部门店老板与所有在职员工。',
                  style: ts(12, color: C.muted),
                ),
              ],
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('触达渠道（可多选）', style: ts(14, w: FontWeight.w600)),
              const SizedBox(height: 10),
              for (final (key, label, desc) in _channelMeta)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppChoiceChip(
                    kind: ChipKind.option,
                    expanded: true,
                    label: label,
                    subtitle: desc,
                    selected: _channels.contains(key),
                    onTap: () => setState(() {
                      if (_channels.contains(key)) {
                        _channels.remove(key);
                      } else {
                        _channels.add(key);
                      }
                    }),
                  ),
                ),
              if (_channels.contains('popup')) ...[
                const SizedBox(height: 4),
                Text('弹窗有效期', style: ts(13, w: FontWeight.w500, color: C.sub)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (days, label) in const [
                      (1, '24 小时'),
                      (3, '3 天'),
                      (7, '7 天'),
                      (0, '长期有效'),
                    ])
                      AppChoiceChip(
                        label: label,
                        selected: _popupDays == days,
                        onTap: () => setState(() => _popupDays = days),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: '通知标题',
                hint: '请输入通知标题（最多 60 字）',
                required: true,
                controller: _title,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: '通知内容',
                hint: '请输入通知正文（最多 500 字）',
                required: true,
                controller: _body,
                maxLines: 5,
              ),
            ],
          ),
        ),
        AppButton(
          label: '下一步 · 预览并发送',
          size: AppButtonSize.large,
          expanded: true,
          loading: _submitting,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }
}

class _RecipientPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> initial;
  const _RecipientPickerSheet({required this.initial});
  @override
  State<_RecipientPickerSheet> createState() => _RecipientPickerSheetState();
}

class _RecipientPickerSheetState extends State<_RecipientPickerSheet> {
  final _picked = <String, Map<String, dynamic>>{};
  List<Map<String, dynamic>> _rows = [];
  bool _loading = true;

  String _key(Map<String, dynamic> u) =>
      '${u['store_id']}:${u['staff_id'] ?? ''}:${u['owner_id'] ?? ''}';

  @override
  void initState() {
    super.initState();
    for (final u in widget.initial) {
      _picked[_key(u)] = u;
    }
    unawaited(_search(''));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    try {
      final list = await store.notificationRecipients(q);
      if (!mounted) return;
      setState(() => _rows = list);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSearchBar(
          hint: '搜索姓名、手机号或门店名',
          onChanged: _search,
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 320),
          child: _loading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  ),
                )
              : _rows.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('未找到匹配的用户', style: ts(13, color: C.muted)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final u = _rows[i];
                    final k = _key(u);
                    final sel = _picked.containsKey(k);
                    return AppChoiceChip(
                      kind: ChipKind.option,
                      expanded: true,
                      label:
                          '${u['name']} · ${_roleLabels[u['role']] ?? u['role']}',
                      subtitle: '${u['store_name']} · ${u['phone'] ?? ''}',
                      selected: sel,
                      onTap: () => setState(() {
                        if (sel) {
                          _picked.remove(k);
                        } else {
                          _picked[k] = u;
                        }
                      }),
                    );
                  },
                ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: '取消',
                kind: AppButtonKind.secondary,
                size: AppButtonSize.large,
                expanded: true,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: '确定（${_picked.length}）',
                size: AppButtonSize.large,
                expanded: true,
                onPressed: () =>
                    Navigator.pop(context, _picked.values.toList()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
