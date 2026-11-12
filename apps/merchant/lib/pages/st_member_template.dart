// 从员工端设计稿生成页派生（tools/bind_st_members.py），仅绑定数据和事件；不手工修改 gen_st/。
import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';

/// 员工端「会员查询」→「会员简况」之间传递会员 ID。
class StMemberFlow {
  static String? currentId;

  /// 核销等操作成功后刷新会员简况。
  static final changed = ValueNotifier<int>(0);
}

/// 员工端会员查询：只返回脱敏后的服务相关信息（服务端校验「会员查询」权限）。
class StMemberTemplate extends StatefulWidget {
  final List<Map<String, dynamic>> initial;
  const StMemberTemplate({super.key, required this.initial});

  @override
  State<StMemberTemplate> createState() => _StMemberTemplateState();
}

class _StMemberTemplateState extends State<StMemberTemplate> {
  late List<Map<String, dynamic>> items = widget.initial;
  String query = '';
  Timer? _debounce;
  int _seq = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void onQuery(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text.trim()));
  }

  Future<void> _search(String q) async {
    final seq = ++_seq;
    try {
      final d = await merchantApi.staffWork('staff_member_search', {'q': q});
      if (!mounted || seq != _seq) return;
      setState(() {
        query = q;
        items = [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
      });
    } catch (e) {
      if (mounted && seq == _seq) hToast(context, '查询失败：$e');
    }
  }

  String get empty => query.isEmpty ? '暂无到店记录' : '没有找到匹配的会员';

  void onOpen(Map<String, dynamic> m) {
    StMemberFlow.currentId = '${m['id']}';
    openRoute(context, 'StMemberInfo');
  }

  String _initial(Map<String, dynamic> m) => stInitial('${m['name'] ?? ''}');
  String _level(Map<String, dynamic> m) => '${m['level'] ?? ''}'.isEmpty ? '会员' : '${m['level']}';
  String _sub(Map<String, dynamic> m) {
    final plate = '${m['plate'] ?? ''}';
    return plate.isEmpty ? '${m['phone_masked'] ?? ''}' : '${m['phone_masked'] ?? ''} · $plate';
  }

  Widget _row(BuildContext context, int i, Map<String, dynamic> m) {
    switch (i % 3) {
      case 0:
        return hTap(context, hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.5, -0.866), end: Alignment(0.5, 0.866), colors: [Color(0xFFFBE7B0), Color(0xFFE6B85C)], stops: [0, 1]), radius: BorderRadius.circular(22), align: Alignment(0, 0), child: Text(_initial(m), style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600))), Expanded(flex: 1, child: hcol([hrow([Flexible(flex: 45, child: Text('${m['name'] ?? ''}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22))), Flexible(flex: 38, child: hbox(bg: Color(0xFFF5D78E), radius: BorderRadius.circular(9), pad: EdgeInsets.fromLTRB(8, 0, 8, 0), child: Text(_level(m), style: hts(11, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 18), softWrap: false, maxLines: 1)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 8), Text(_sub(m), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 3)), hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 12)), onTap: () => onOpen(m));
      case 1:
        return hTap(context, hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.5, -0.866), end: Alignment(0.5, 0.866), colors: [Color(0xFFFFF1CF), Color(0xFFF5D78E)], stops: [0, 1]), radius: BorderRadius.circular(22), align: Alignment(0, 0), child: Text(_initial(m), style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600))), Expanded(flex: 1, child: hcol([hrow([Flexible(flex: 30, child: Text('${m['name'] ?? ''}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22))), Flexible(flex: 38, child: hbox(bg: dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16)), radius: BorderRadius.circular(9), pad: EdgeInsets.fromLTRB(8, 0, 8, 0), child: Text(_level(m), style: hts(11, dk(context, Color(0xFF855F2E), Color(0xFFF0C46A)), w: FontWeight.w600, lh: 18), softWrap: false, maxLines: 1)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 8), Text(_sub(m), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 3)), hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 12)), onTap: () => onOpen(m));
      default:
        return hTap(context, hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.5, -0.866), end: Alignment(0.5, 0.866), colors: [Color(0xFFE4E4E7), Color(0xFFC4C4CB)], stops: [0, 1]), radius: BorderRadius.circular(22), align: Alignment(0, 0), child: Text(_initial(m), style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600))), Expanded(flex: 1, child: hcol([hrow([Flexible(flex: 30, child: Text('${m['name'] ?? ''}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22))), Flexible(flex: 38, child: hbox(bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)), radius: BorderRadius.circular(9), pad: EdgeInsets.fromLTRB(8, 0, 8, 0), child: Text(_level(m), style: hts(11, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w600, lh: 18), softWrap: false, maxLines: 1)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 8), Text(_sub(m), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 3)), hsvg(dk(context, Svgs.s45, Svgs.s46), w: 16, h: 16)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 12)), onTap: () => onOpen(m));
    }
  }

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol([hbox(pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 110), child: hcol([hrow([hbox(w: 87), Expanded(flex: 1, child: Text('会员查询', style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 24), textAlign: TextAlign.center)), hbox(w: 87)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0), hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), pad: EdgeInsets.fromLTRB(16, 4, 16, 4), child: hcol([hrow([hsvg(dk(context, Svgs.s47, Svgs.s48), w: 18, h: 18), Expanded(child: HInput(onChanged: onQuery, style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), lh: 22), hint: '手机号后 4 位 / 车牌 / 姓名')), hTap(context, NegMargin(top: 0, left: 0, child: hbox(w: 32, h: 32, bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)), radius: BorderRadius.circular(16), child: hrow([hsvg(dk(context, Svgs.s49, Svgs.s50), w: 18, h: 18)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0))), to: 'StVerify')], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 10)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 14)), hcol([hbox(pad: EdgeInsets.fromLTRB(4, 0, 0, 0), child: Text('最近到店', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18))), hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), pad: EdgeInsets.fromLTRB(0, 4, 0, 4), child: hcol([if (items.isEmpty) hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([Expanded(flex: 1, child: Text(empty, style: hts(14, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 20)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0)), for (var i = 0; i < items.length; i++) ...[if (i > 0) hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)), margin: EdgeInsets.fromLTRB(72, 0, 0, 0)), _row(context, i, items[i])]], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 8)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 16))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0),
      overlays: [],
    );
  }
}

/// 员工底部「会员」Tab / 会员查询页：默认列出最近到店的会员。
class StMemberLivePage extends StatelessWidget {
  const StMemberLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '会员查询',
    load: () => merchantApi.staffWork('staff_member_search', {'q': ''}),
    builder: (_, d) => StMemberTemplate(
      initial: [for (final x in (d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)],
    ),
  );
}
