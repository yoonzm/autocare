import '../../backend/data_snapshot.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/staff_flow.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart' show dk;

/// 员工模块各页面共用的数据宿主：按调用者传入的员工 ID 读取员工并交给设计稿模板绘制。
/// 页面（`sheet: false`）自带 Scaffold，数据变化（编辑 / 停用 / 提成 / 邀请）后自动刷新；
/// 底部弹层（`sheet: true`）不套 Scaffold，只在打开时读取一次。
class StaffLiveHost extends StatefulWidget {
  /// `needsId: false` 的页面（角色权限）不需要员工 ID，id 传空串。
  final bool needsId;
  final String? staffId;
  final Future<Map<String, dynamic>> Function(String id) load;
  final Widget Function(BuildContext context, Map<String, dynamic> data)
  builder;
  final bool sheet;

  /// 额外的刷新信号（如任务进度 / 完工后列表与工作台需要重新读取）。
  final Listenable? refresh;

  /// 骨架屏里的标题栏文字（外壳在加载时就显示）。
  final String title;
  const StaffLiveHost({
    super.key,
    required this.load,
    required this.builder,
    this.sheet = false,
    this.title = '',
    this.needsId = true,
    this.staffId,
    this.refresh,
  });

  @override
  State<StaffLiveHost> createState() => _StaffLiveHostState();
}

class _StaffLiveHostState extends State<StaffLiveHost> {
  var _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
  bool _pending = false;

  @override
  void initState() {
    super.initState();
    if (!widget.sheet) {
      StaffFlow.changed.addListener(_reload);
      widget.refresh?.addListener(_reload);
    }
  }

  @override
  void dispose() {
    StaffFlow.changed.removeListener(_reload);
    widget.refresh?.removeListener(_reload);
    super.dispose();
  }

  @override
  void didUpdateWidget(StaffLiveHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.sheet) {
      StaffFlow.changed.removeListener(_reload);
      oldWidget.refresh?.removeListener(_reload);
    }
    if (!widget.sheet) {
      StaffFlow.changed.addListener(_reload);
      widget.refresh?.addListener(_reload);
    }
    if (widget.staffId != oldWidget.staffId) {
      _key = GlobalKey<AsyncViewState<Map<String, dynamic>>>();
      _pending = false;
    }
  }

  void _reload() {
    if (!mounted) return;
    if (_key.currentState?.busy == true) {
      _pending = true;
      return;
    }
    _key.currentState?.reload();
  }

  void _settled() {
    if (!mounted || !_pending) return;
    _pending = false;
    _key.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.needsId ? widget.staffId : '';
    if (id == null) {
      final empty = ErrorView(
        error: const AppError('请先选择员工', type: AppErrorType.notFound),
        onNext: () => Navigator.of(context).maybePop(),
      );
      return widget.sheet
          ? SizedBox(height: 280, child: empty)
          : Scaffold(body: empty);
    }
    if (widget.sheet) {
      return _SheetLoader(
        key: ValueKey(id),
        load: () async => dataSnapshot(await widget.load(id)),
        builder: widget.builder,
      );
    }
    final view = AsyncView<Map<String, dynamic>>(
      key: _key,
      onSettled: _settled,
      load: () async => dataSnapshot(await widget.load(id)),
      isEmpty: (_) => false,
      skeletonPadding: EdgeInsets.zero,
      skeletonScrollable: false,
      skeleton: StaffSkeleton(title: widget.title),
      empty: (_) => const SizedBox.shrink(),
      builder: (context, data) => widget.builder(context, data),
      onNext: () => Navigator.of(context).maybePop(),
    );
    return Scaffold(body: view);
  }
}

/// 底部弹层的加载：弹层外层是 SingleChildScrollView（高度不受限），
/// 不能放 AsyncView（需要有限高度），所以弹层自己读取：骨架 → 内容，失败给带重试的错误。
class _SheetLoader extends StatefulWidget {
  final Future<Map<String, dynamic>> Function() load;
  final Widget Function(BuildContext context, Map<String, dynamic> data)
  builder;
  const _SheetLoader({super.key, required this.load, required this.builder});

  @override
  State<_SheetLoader> createState() => _SheetLoaderState();
}

class _SheetLoaderState extends State<_SheetLoader> {
  late Future<Map<String, dynamic>> _future = widget.load();

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: _future,
    builder: (context, snap) {
      if (snap.hasData) return widget.builder(context, snap.data!);
      if (snap.hasError) {
        return Container(
          height: 280,
          decoration: BoxDecoration(
            color: dk(
              context,
              const Color(0xFFFFFFFF),
              const Color(0xFF18181B),
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ErrorView(
            error: AppError.from(snap.error!),
            onRetry: () => setState(() => _future = widget.load()),
            onNext: () => Navigator.of(context).maybePop(),
          ),
        );
      }
      return const StaffSkeleton(sheet: true);
    },
  );
}

/// 员工详情 / 提成 / 记录 / 权限等页面的加载骨架：标题栏外壳 + 贴合内容的卡片块。
class StaffSkeleton extends StatelessWidget {
  final String title;
  final bool sheet;
  const StaffSkeleton({super.key, this.title = '', this.sheet = false});

  @override
  Widget build(BuildContext context) {
    Widget block(double h, [double r = 24]) =>
        AppSkeleton(height: h, radius: r);
    if (sheet) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        decoration: BoxDecoration(
          color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
            block(28, 8),
            const SizedBox(height: 14),
            block(72, 18),
            const SizedBox(height: 14),
            block(96, 18),
            const SizedBox(height: 14),
            block(50, 25),
          ],
        ),
      );
    }
    return Container(
      color: dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B)),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 44,
            child: Row(
              children: [
                const AppSkeleton.circle(size: 44),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: dk(
                          context,
                          const Color(0xFF18181B),
                          const Color(0xFFFAFAFA),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),
          const SizedBox(height: 16),
          block(150, 28),
          const SizedBox(height: 16),
          block(220),
          const SizedBox(height: 16),
          block(150),
        ],
      ),
    );
  }
}

/// 头像里的字：姓名首字。
String staffInitial(Map<String, dynamic> d) {
  final n = '${d['name'] ?? ''}';
  return n.isEmpty ? '' : String.fromCharCode(n.runes.first);
}

/// 停用日期 10.18。
String staffMonthDay(Object? iso) {
  final s = '${iso ?? ''}';
  if (s.length < 10) return '—';
  final d = DateTime.tryParse(s)?.toUtc().add(const Duration(hours: 8));
  if (d == null) return '—';
  return '${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

/// 停用时间 2026.10.18（北京时间）。
String staffFullDay(Object? iso) {
  final d = DateTime.tryParse('${iso ?? ''}')
      ?.toUtc()
      .add(const Duration(hours: 8));
  if (d == null) return '—';
  return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
}

/// 提成方案的一句话说明（详情页「提成方案」行）。
String staffCommissionLabel(Map<String, dynamic> d) {
  final rate = (d['commission_rate'] as num?) ?? 0;
  return switch (d['commission_mode']) {
    'flat' => '统一 ${rate == rate.truncate() ? rate.toInt() : rate}%',
    'custom' => '按项目自定义',
    _ => '跟随项目设置',
  };
}

/// 1206 → 1,206。
String staffCount(Object? n) => '${(n as num?) ?? 0}'.replaceAllMapped(
  RegExp(r'\B(?=(\d{3})+(?!\d))'),
  (_) => ',',
);

/// 日期标签：今天 / 昨天 / 10.28（北京时间）。
String staffDayLabel(Object? iso) {
  final t = DateTime.tryParse('${iso ?? ''}')
      ?.toUtc()
      .add(const Duration(hours: 8));
  if (t == null) return '—';
  final now = DateTime.now().toUtc().add(const Duration(hours: 8));
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(t.year, t.month, t.day)).inDays;
  if (days == 0) return '今天';
  if (days == 1) return '昨天';
  return '${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
}

/// 今天 11:20 / 昨天 15:40 / 10.28 10:10。
String staffDayTime(Object? iso) {
  final t = DateTime.tryParse('${iso ?? ''}')
      ?.toUtc()
      .add(const Duration(hours: 8));
  if (t == null) return '—';
  return '${staffDayLabel(iso)} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// 新能源车牌（8 位）用绿牌样式，其余蓝牌。
bool staffGreenPlate(Object? plate) =>
    '${plate ?? ''}'.replaceAll('·', '').runes.length == 8;

/// 服务项目的提成：比例 15% / 固定 ¥60/单。
String staffServiceRate(Map<String, dynamic> s) {
  final v = (s['commission_value'] as num?) ?? 0;
  final n = v == v.truncate() ? '${v.toInt()}' : '$v';
  return s['commission_type'] == 'fixed' ? '¥$n/单' : '$n%';
}

/// 转交弹层的数据：待转交员工 + 可接手的技师（营业中、非本人）。
Future<Map<String, dynamic>> loadTransferData(String id) async {
  final out = await Future.wait([
    merchantApi.staff('get', {'id': id}),
    merchantApi.staff('list'),
  ]);
  final candidates = [
    for (final s in (out[1]['staff'] as List))
      if ((s as Map)['role'] == 'technician' &&
          s['status'] != 'disabled' &&
          s['id'] != id)
        s,
  ];
  return {...out[0], 'candidates': candidates};
}
