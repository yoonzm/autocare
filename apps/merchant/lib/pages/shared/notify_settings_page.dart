import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

/// 通知与消息：本月短信统计、通知开关、固定模板只读预览与发送记录入口。
class NotifySettingsPage extends StatefulWidget {
  const NotifySettingsPage({super.key});

  @override
  State<NotifySettingsPage> createState() => _NotifySettingsPageState();
}

class _NotifySettingsPageState extends State<NotifySettingsPage> {
  final _overviewKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  late final _actionKey = 'notify-settings-${identityHashCode(this)}';

  Map<String, dynamic>? _bookingSettings;
  String? _savingKey;

  @override
  void initState() {
    super.initState();
    AppointmentFlow.changed.addListener(_onAppointmentChanged);
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_onAppointmentChanged);
    super.dispose();
  }

  void _onAppointmentChanged() {
    _overviewKey.currentState?.reload();
  }

  Future<Map<String, dynamic>> _loadOverview() async {
    final data = await merchantApi.storeSmsOverview();
    final bs = data['booking_settings'];
    if (bs is Map) {
      _bookingSettings = Map<String, dynamic>.from(bs);
    }
    return data;
  }

  Future<void> _toggleSetting(String key, bool value) async {
    final current = _bookingSettings;
    if (current == null || _savingKey != null) return;
    setState(() => _savingKey = key);
    await runBusy(_actionKey, () async {
      try {
        final next = {...current, key: value};
        final saved = await merchantApi.appointment('settings_save', next);
        if (!mounted) return;
        setState(() => _bookingSettings = saved);
        AppointmentFlow.notify();
      } catch (e) {
        if (!mounted) return;
        AppToast.error(context, e);
      } finally {
        if (mounted) setState(() => _savingKey = null);
      }
    });
  }

  void _showTemplateSheet(Map<String, dynamic> item) {
    final title = '${item['title'] ?? ''}';
    final hint = '${item['trigger_hint'] ?? '点击开关可控制是否自动发送'}';
    final preview = '${item['template_preview'] ?? ''}';
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.of(ctx).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: C.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: ts(17, w: FontWeight.w600, color: C.ink, h: 24),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: C.inset,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('固定模板 · 只读', style: ts(11, color: C.muted, h: 14)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(hint, style: ts(13, color: C.muted, h: 18)),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(preview, style: ts(14, color: C.ink, h: 21)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AsyncActionScope(
      actionKey: _actionKey,
      child: Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(
            children: [
              const SubHeader('通知与消息'),
              Expanded(
                child: AsyncView<Map<String, dynamic>>(
                  key: _overviewKey,
                  load: _loadOverview,
                  isEmpty: (_) => false,
                  skeleton: _buildSkeleton(),
                  empty: (_) => const SizedBox.shrink(),
                  builder: (context, data) => _buildContent(context, data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Container(
          height: 148,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 156,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Map<String, dynamic> data) {
    final stats = Map<String, dynamic>.from(
      data['month_stats'] as Map? ?? const {},
    );
    final scenarios = [
      for (final s in (data['scenarios'] as List? ?? const []))
        if (s is Map) Map<String, dynamic>.from(s),
    ];
    final transactionScenarios =
        scenarios.where((s) => s['group'] == 'transaction').toList();
    final bookingScenarios =
        scenarios.where((s) => s['group'] == 'booking').toList();
    final readonlyScenarios = scenarios
        .where((s) => s['group'] != 'booking' && s['group'] != 'transaction')
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: [
        _heroCard(stats),
        if (transactionScenarios.isNotEmpty) ...[
          const SizedBox(height: 20),
          _sectionTitle('消费与充值通知 · 点击查看模板'),
          const SizedBox(height: 10),
          _card(
            children: [
              for (var i = 0; i < transactionScenarios.length; i++) ...[
                if (i > 0) Divider(height: 1, color: C.line),
                _toggleRow(transactionScenarios[i]),
              ],
            ],
          ),
        ],
        const SizedBox(height: 20),
        _sectionTitle('预约短信通知 · 与预约设置同步'),
        const SizedBox(height: 10),
        _card(
          children: [
            for (var i = 0; i < bookingScenarios.length; i++) ...[
              if (i > 0) Divider(height: 1, color: C.line),
              _toggleRow(bookingScenarios[i]),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitle('业务与验证码模板 · 平台固定配置'),
        const SizedBox(height: 10),
        _card(
          children: [
            for (var i = 0; i < readonlyScenarios.length; i++) ...[
              if (i > 0) Divider(height: 1, color: C.line),
              _readonlyRow(readonlyScenarios[i]),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _logsEntryCard(stats),
      ],
    );
  }

  Widget _heroCard(Map<String, dynamic> stats) {
    final total = (stats['total'] as num?)?.toInt() ?? 0;
    final delivered = (stats['delivered'] as num?)?.toInt() ?? 0;
    final failed = (stats['failed'] as num?)?.toInt() ?? 0;
    final pending = (stats['pending'] as num?)?.toInt() ?? 0;

    return Container(
      decoration: C.hero(28),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本月已发送通知短信',
            style: ts(13, color: const Color(0xFFA1A1AA), h: 18),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$total',
                style: ts(
                  36,
                  w: FontWeight.w600,
                  color: const Color(0xFFFAFAFA),
                  h: 44,
                ),
              ),
              const SizedBox(width: 6),
              Text('条', style: ts(14, color: const Color(0xFFA1A1AA), h: 20)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _statPill('已送达 $delivered', const Color(0xFF5FD48C)),
              const SizedBox(width: 8),
              _statPill('待回执 $pending', const Color(0xFFA1A1AA)),
              const SizedBox(width: 8),
              _statPill(
                '失败 $failed',
                failed > 0 ? const Color(0xFFFF7B7E) : const Color(0xFFA1A1AA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: ts(12, w: FontWeight.w500, color: color, h: 16)),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(text, style: ts(13, w: FontWeight.w600, color: C.muted, h: 18)),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  (String icon, Color bg, Color fg) _iconStyle(String key) {
    return switch (key) {
      'order_consume' => ('receipt', C.primarySoft, C.primaryInk),
      'member_recharge' => ('card', C.greenSoft, C.greenInk),
      'appointment_confirm' || 'appointment_reschedule' => (
        'calendar',
        C.primarySoft,
        C.primaryInk,
      ),
      'appointment_cancel' => ('calendar', C.redSoft, C.redInk),
      'appointment_reminder' => ('clock', C.amberSoft, C.amberInk),
      'appointment_manager' => ('bell', C.amberSoft, C.amberInk),
      'hold_pickup' => ('car', C.greenSoft, C.greenInk),
      'staff_invite' => ('users', C.primarySoft, C.primaryInk),
      'member_followup' => ('chat', C.amberSoft, C.amberInk),
      _ => ('shield', C.inset, C.sub),
    };
  }

  Widget _iconTile(String key) {
    final (icon, bg, fg) = _iconStyle(key);
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: AppIcon(icon, size: 18, color: fg),
    );
  }

  Widget _toggleRow(Map<String, dynamic> item) {
    final key = '${item['key'] ?? ''}';
    final settingKey = '${item['setting_key'] ?? ''}';
    final enabled = _bookingSettings != null && settingKey.isNotEmpty
        ? _bookingSettings![settingKey] == true
        : item['enabled'] == true;
    final busy = _savingKey == settingKey;

    return InkWell(
      onTap: () => _showTemplateSheet(item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        child: Row(
          children: [
            _iconTile(key),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title'] ?? ''}',
                    style: ts(15, w: FontWeight.w600, color: C.ink, h: 20),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '点击查看固定短信模板',
                    style: ts(12, color: C.muted, h: 16),
                  ),
                ],
              ),
            ),
            if (busy)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              Switch.adaptive(
                value: enabled,
                activeTrackColor: C.primary,
                onChanged: settingKey.isEmpty
                    ? null
                    : (v) => _toggleSetting(settingKey, v),
              ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyRow(Map<String, dynamic> item) {
    final key = '${item['key'] ?? ''}';
    final hint = '${item['trigger_hint'] ?? ''}';
    return InkWell(
      onTap: () => _showTemplateSheet(item),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        child: Row(
          children: [
            _iconTile(key),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item['title'] ?? ''}',
                    style: ts(15, w: FontWeight.w600, color: C.ink, h: 20),
                  ),
                  if (hint.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: ts(12, color: C.muted, h: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('固定模板', style: ts(11, color: C.muted, h: 14)),
            ),
            const SizedBox(width: 4),
            AppIcon('chevronRight', size: 16, color: C.faint),
          ],
        ),
      ),
    );
  }

  Widget _logsEntryCard(Map<String, dynamic> stats) {
    final total = (stats['total'] as num?)?.toInt() ?? 0;
    final failed = (stats['failed'] as num?)?.toInt() ?? 0;
    return _card(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => openRoute(context, 'SmsLogs'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: C.inset,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: AppIcon('document', size: 17, color: C.sub),
                ),
                const SizedBox(width: 12),
                Text(
                  '发送记录',
                  style: ts(15, w: FontWeight.w600, color: C.ink, h: 20),
                ),
                const Spacer(),
                Text(
                  '本月 $total 条 · $failed 条失败',
                  style: ts(13, color: C.muted, h: 18),
                ),
                const SizedBox(width: 6),
                AppIcon('chevronRight', size: 16, color: C.faint),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
