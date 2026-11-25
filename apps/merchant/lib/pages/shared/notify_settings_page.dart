import 'package:flutter/material.dart';

import '../../backend/appointment_flow.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

/// 通知与消息：助通短信概览、预约通知开关、固定模板说明与门店短信发送记录。
class NotifySettingsPage extends StatefulWidget {
  const NotifySettingsPage({super.key});

  @override
  State<NotifySettingsPage> createState() => _NotifySettingsPageState();
}

class _NotifySettingsPageState extends State<NotifySettingsPage> {
  final _overviewKey = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  late final _actionKey = 'notify-settings-${identityHashCode(this)}';

  String _logFilter = 'all';
  bool _logsLoading = false;
  bool _logsLoaded = false;
  String? _logsError;
  List<Map<String, dynamic>> _logs = const [];
  bool _hasMoreLogs = false;
  int _nextOffset = 0;

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
    if (mounted) {
      _loadLogs(reset: true);
    }
    return data;
  }

  Future<void> _loadLogs({required bool reset}) async {
    if (_logsLoading) return;
    setState(() {
      _logsLoading = true;
      if (reset) _logsError = null;
    });
    try {
      final offset = reset ? 0 : _nextOffset;
      final res = await merchantApi.storeSmsLogs(
        status: _logFilter,
        offset: offset,
        limit: 20,
      );
      if (!mounted) return;
      final items = [
        for (final row in (res['items'] as List? ?? const []))
          if (row is Map) Map<String, dynamic>.from(row),
      ];
      setState(() {
        _logs = reset ? items : [..._logs, ...items];
        _hasMoreLogs = res['has_more'] == true;
        _nextOffset = (res['next_offset'] as num?)?.toInt() ?? _logs.length;
        _logsLoaded = true;
        _logsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _logsError = AppError.from(e).message);
    } finally {
      if (mounted) setState(() => _logsLoading = false);
    }
  }

  Future<void> _toggleBookingSetting(String key, bool value) async {
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
          height: 152,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
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
    final provider = Map<String, dynamic>.from(
      data['provider'] as Map? ?? const {},
    );
    final scenarios = [
      for (final s in (data['scenarios'] as List? ?? const []))
        if (s is Map) Map<String, dynamic>.from(s),
    ];
    final bookingScenarios =
        scenarios.where((s) => s['group'] == 'booking').toList();
    final readonlyScenarios =
        scenarios.where((s) => s['group'] != 'booking').toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: [
        _heroCard(stats, provider),
        const SizedBox(height: 20),
        _sectionTitle('预约短信通知 · 与预约设置同步'),
        const SizedBox(height: 10),
        _card(
          children: [
            for (var i = 0; i < bookingScenarios.length; i++) ...[
              if (i > 0) Divider(height: 1, color: C.line),
              _bookingScenarioRow(bookingScenarios[i]),
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
              _readonlyScenarioRow(readonlyScenarios[i]),
            ],
          ],
        ),
        const SizedBox(height: 20),
        _logsHeader(),
        const SizedBox(height: 10),
        _logsSection(),
      ],
    );
  }

  Widget _heroCard(
    Map<String, dynamic> stats,
    Map<String, dynamic> provider,
  ) {
    final total = (stats['total'] as num?)?.toInt() ?? 0;
    final delivered = (stats['delivered'] as num?)?.toInt() ?? 0;
    final failed = (stats['failed'] as num?)?.toInt() ?? 0;
    final pending = (stats['pending'] as num?)?.toInt() ?? 0;
    final configured = provider['configured'] == true;
    final label = '${provider['label'] ?? '助通短信'}';
    final sign = '${provider['signature'] ?? ''}'.trim();

    return Container(
      decoration: C.hero(28),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '本月已发送通知短信',
                style: ts(13, color: const Color(0xFFA1A1AA), h: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: configured
                      ? const Color(0x2917C964)
                      : const Color(0x29F5A524),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  configured
                      ? '$label${sign.isNotEmpty ? ' · 【$sign】' : ' · 已启用'}'
                      : '$label · 未配置',
                  style: ts(
                    11,
                    w: FontWeight.w600,
                    color: configured
                        ? const Color(0xFF5FD48C)
                        : const Color(0xFFF0C46A),
                    h: 15,
                  ),
                ),
              ),
            ],
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

  Widget _bookingScenarioRow(Map<String, dynamic> item) {
    final settingKey = '${item['setting_key'] ?? ''}';
    final enabled = _bookingSettings != null && settingKey.isNotEmpty
        ? _bookingSettings![settingKey] == true
        : item['enabled'] == true;
    final busy = _savingKey == settingKey;
    final preview = '${item['template_preview'] ?? ''}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item['title'] ?? ''}',
                  style: ts(15, w: FontWeight.w600, color: C.ink, h: 20),
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Switch.adaptive(
                  value: enabled,
                  activeTrackColor: C.primary,
                  onChanged: settingKey.isEmpty
                      ? null
                      : (v) => _toggleBookingSetting(settingKey, v),
                ),
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                preview,
                style: ts(12, color: C.muted, h: 17),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _readonlyScenarioRow(Map<String, dynamic> item) {
    final hint = '${item['trigger_hint'] ?? ''}';
    final preview = '${item['template_preview'] ?? ''}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item['title'] ?? ''}',
                  style: ts(15, w: FontWeight.w600, color: C.ink, h: 20),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('固定模板', style: ts(11, color: C.muted, h: 14)),
              ),
            ],
          ),
          if (hint.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(hint, style: ts(12, color: C.muted, h: 16)),
          ],
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(preview, style: ts(12, color: C.sub, h: 17)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _logsHeader() {
    return Row(
      children: [
        _sectionTitle('短信发送记录'),
        const Spacer(),
        _filterChip('all', '全部'),
        const SizedBox(width: 6),
        _filterChip('delivered', '已送达'),
        const SizedBox(width: 6),
        _filterChip('failed', '失败'),
      ],
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _logFilter == value;
    return GestureDetector(
      onTap: () {
        if (_logFilter == value) return;
        setState(() => _logFilter = value);
        _loadLogs(reset: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? C.btn : C.card,
          borderRadius: BorderRadius.circular(12),
          border: selected ? null : Border.all(color: C.line),
        ),
        child: Text(
          label,
          style: ts(
            12,
            w: FontWeight.w600,
            color: selected ? C.btnFg : C.muted,
            h: 16,
          ),
        ),
      ),
    );
  }

  Widget _logsSection() {
    if (_logsError != null && _logs.isEmpty) {
      return _card(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(_logsError!, style: ts(13, color: C.redInk, h: 18)),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => _loadLogs(reset: true),
                  child: const Text('重试'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (!_logsLoaded && _logsLoading) {
      return _card(
        children: const [
          Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ],
      );
    }

    if (_logs.isEmpty) {
      return _card(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            child: Column(
              children: [
                AppIcon('bell', size: 28, color: C.faint),
                const SizedBox(height: 8),
                Text(
                  _logFilter == 'failed'
                      ? '暂无发送失败的短信记录'
                      : _logFilter == 'delivered'
                          ? '暂无已送达的短信记录'
                          : '本店暂未发送业务通知短信',
                  style: ts(13, color: C.muted, h: 18),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return _card(
      children: [
        for (var i = 0; i < _logs.length; i++) ...[
          if (i > 0) Divider(height: 1, color: C.line),
          _logRow(_logs[i]),
        ],
        if (_hasMoreLogs) ...[
          Divider(height: 1, color: C.line),
          InkWell(
            onTap: _logsLoading ? null : () => _loadLogs(reset: false),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: _logsLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        '加载更多记录',
                        style: ts(13, w: FontWeight.w600, color: C.primaryInk, h: 18),
                      ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _logRow(Map<String, dynamic> row) {
    final label = '${row['purpose_label'] ?? '门店通知短信'}';
    final phone = '${row['phone_masked'] ?? ''}';
    final content = '${row['content'] ?? ''}';
    final status = '${row['status'] ?? ''}';
    final delivery = '${row['delivery_status'] ?? 'unknown'}';
    final error = '${row['error'] ?? ''}'.trim();
    final timeStr = _formatTime('${row['delivered_at'] ?? row['sent_at'] ?? row['created_at'] ?? ''}');

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
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
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
