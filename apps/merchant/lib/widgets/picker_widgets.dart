import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/package_calc.dart' show formatMoney;
import '../kit/async_kit.dart';
import '../kit/keyboard.dart';
import '../kit/kit.dart';

/// “选择会员”弹层的搜索行：车牌 / 手机号 / 姓名 + 扫码找会员。
/// 没登录（设计预览）时是设计稿的静态样子。
Widget hMemberPickerSearch() => _PickerSearch();

class _PickerSearch extends StatefulWidget {
  @override
  State<_PickerSearch> createState() => _PickerSearchState();
}

class _PickerSearchState extends State<_PickerSearch> {
  final _ctl = TextEditingController();

  @override
  void initState() {
    super.initState();
    MemberFlow.pickerQuery.value = '';
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: dk(
                context,
                const Color(0xFFF4F4F5),
                const Color(0xFF27272A),
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFFA1A1AA),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _ctl,
                    onTapOutside: onTapOutsideDismiss,
                    onChanged: (v) => MemberFlow.pickerQuery.value = v.trim(),
                    style: hts(
                      15,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      lh: 22,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '车牌 / 手机号 / 姓名',
                      hintStyle: hts(15, muted, lh: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: '扫码找会员',
          child: GestureDetector(
            onTap: () {
              // TODO: 扫车牌 / 会员码识别依赖识别服务和会员端小程序，目前只有示例识别结果。
              hToast(context, '扫码找会员暂未接通');
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dk(
                  context,
                  const Color(0xFF18181B),
                  const Color(0xFF34343A),
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.qr_code_scanner_rounded,
                size: 20,
                color: Color(0xFFFAFAFA),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// “选择会员”弹层的会员列表：最近使用 / 全部会员 · N，随搜索词刷新。
Widget hMemberPickerList() => Builder(
  builder: (context) {
    // 弹层本身是可滚动的容器（高度不受限），列表要自己有确定的高度：
    // 设计稿的弹层高 700，去掉标题 / 搜索行和底部“新增会员”后约 470
    final h = (MediaQuery.of(context).size.height * 0.94 - 250).clamp(
      200.0,
      470.0,
    );
    return SizedBox(height: h, child: const _PickerList());
  },
);

class _PickerList extends StatefulWidget {
  const _PickerList();
  @override
  State<_PickerList> createState() => _PickerListState();
}

class _PickerListState extends State<_PickerList> {
  List<Map<String, dynamic>> _recent = const [];
  List<Map<String, dynamic>> _all = const [];
  int _total = 0;
  AppError? _error;
  bool _loading = true;
  bool _skeleton = false;
  Timer? _debounce;
  String _q = '';

  @override
  void initState() {
    super.initState();
    MemberFlow.pickerQuery.addListener(_onQuery);
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    MemberFlow.pickerQuery.removeListener(_onQuery);
    super.dispose();
  }

  void _onQuery() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _q = MemberFlow.pickerQuery.value;
      _load();
    });
  }

  Future<void> _load() async {
    if (!merchantApi.hasSession) return;
    setState(() {
      _loading = true;
      _skeleton = false;
      _error = null;
    });
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && _loading) setState(() => _skeleton = true);
    });
    try {
      // 搜索时只看匹配的会员；不搜索时分“最近使用”和“全部会员”
      final all = await merchantApi.members(query: _q, limit: 50);
      final recent = _q.isEmpty
          ? await merchantApi.members(recent: true, limit: 3)
          : null;
      if (!mounted) return;
      setState(() {
        _all = all.items;
        _total = all.matched;
        _recent = recent?.items ?? const [];
      });
    } catch (e) {
      if (mounted) setState(() => _error = AppError.from(e));
    } finally {
      timer.cancel();
      if (mounted) setState(() => _loading = false);
    }
  }

  static const _grads = [
    [Color(0xFFFBE7B0), Color(0xFFE6B85C)],
    [Color(0xFF7CC0FF), Color(0xFF0485F7)],
    [Color(0xFF59D49A), Color(0xFF17A864)],
    [Color(0xFFA78BFA), Color(0xFF7C5CE6)],
    [Color(0xFFF5B547), Color(0xFFE08A1E)],
  ];

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) return const SizedBox.shrink();
    if (_error != null && _all.isEmpty) {
      return ErrorView(error: _error!, retrying: _loading, onRetry: _load);
    }
    if (_loading && _all.isEmpty) {
      return _skeleton ? const SkeletonList(count: 5) : const SizedBox.shrink();
    }
    if (_all.isEmpty) {
      return EmptyView(
        title: _q.isEmpty ? '还没有会员' : '没有找到会员',
        message: _q.isEmpty ? '点下面的“新增会员”办卡' : '换个车牌、手机号或姓名试试',
      );
    }
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    Widget heading(String t) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Text(t, style: hts(12, muted, w: FontWeight.w500, lh: 17)),
    );
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (_recent.isNotEmpty) ...[
          heading('最近使用'),
          for (var i = 0; i < _recent.length; i++) _row(context, _recent[i], i),
        ],
        heading('全部会员 · $_total'),
        for (var i = 0; i < _all.length; i++) _row(context, _all[i], i + 2),
      ],
    );
  }

  Widget _row(BuildContext context, Map<String, dynamic> m, int i) {
    final g = _grads[i % _grads.length];
    final name = '${m['name']}';
    final card = Map<String, dynamic>.from((m['card'] as Map?) ?? const {});
    final vehicles = List<Map<String, dynamic>>.from(
      (m['vehicles'] as List?) ?? const [],
    );
    final plate = vehicles.isEmpty
        ? '未登记车辆'
        : _plate('${vehicles.first['plate']}');
    final p = '${m['phone']}';
    final phone = p.length == 11
        ? '${p.substring(0, 3)} **** ${p.substring(7)}'
        : p;
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final muted = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    final balance = num.tryParse('${m['balance'] ?? 0}') ?? 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => MemberFlow.pickMember(context, m),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: g,
                  ),
                ),
                child: Text(
                  name.isEmpty ? '' : name.substring(0, 1),
                  style: hts(16, Colors.white, w: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: hts(15, ink, w: FontWeight.w600, lh: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          decoration: BoxDecoration(
                            color: dk(
                              context,
                              const Color(0xFFFDEFD6),
                              const Color.fromRGBO(245, 165, 36, 0.16),
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Text(
                            '${card['name'] ?? ''}',
                            style: hts(
                              11,
                              dk(
                                context,
                                const Color(0xFF855F2E),
                                const Color(0xFFF5A524),
                              ),
                              w: FontWeight.w600,
                              lh: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text('$plate · $phone', style: hts(12, muted, lh: 17)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '¥${formatMoney(balance)}',
                    style: hts(14, ink, w: FontWeight.w600, lh: 20, tab: true),
                  ),
                  Text('余额', style: hts(11, muted, lh: 16)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _plate(String p) =>
      p.length < 3 ? p : '${p.substring(0, 2)}·${p.substring(2)}';
}
