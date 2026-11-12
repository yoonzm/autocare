// 从员工端设计稿生成页派生（tools/bind_st_members.py），仅绑定数据和事件；不手工修改 gen_st/。
import 'package:flutter/material.dart';

import '../backend/merchant_api.dart';
import '../backend/service_store.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';
import 'st_member_template.dart' show StMemberFlow;

/// 技师快速开单：选服务提交到前台收银。价格、折扣、次卡抵扣全部由服务端估算，提交的只是项目和数量。
class StOrderTemplate extends StatefulWidget {
  final Map<String, dynamic> info;
  final List<Map<String, dynamic>> services;
  const StOrderTemplate({super.key, required this.info, required this.services});

  @override
  State<StOrderTemplate> createState() => _StOrderTemplateState();
}

class _StOrderTemplateState extends State<StOrderTemplate> {
  final Set<String> selected = {};
  String note = '';
  Map<String, dynamic>? quote;
  int _seq = 0;

  List<Map<String, dynamic>> get services => widget.services;
  String get memberId => '${widget.info['id']}';
  String get _plate => '${widget.info['plate'] ?? ''}'.isEmpty ? '未登记车牌' : '${widget.info['plate']}';
  String get _level => '${widget.info['level'] ?? ''}'.isEmpty ? '会员' : '${widget.info['level']}';
  String get _who => '${widget.info['name'] ?? ''} · $_level';
  String get _selText => '已选 ${selected.length} 项 · 会员价';
  String get _totalText => stMoney(quote?['payable'] ?? 0);

  List<Map<String, dynamic>> get _lines => [for (final id in selected) {'service_id': id, 'qty': 1}];

  String _discountText() {
    final d = ((widget.info['discount'] as num?) ?? 1).toDouble();
    if (d >= 1) return '原价';
    final z = (d * 10).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
    return '$_level价 $z 折';
  }

  Future<void> _toggle(String id) async {
    setState(() => selected.contains(id) ? selected.remove(id) : selected.add(id));
    final seq = ++_seq;
    if (selected.isEmpty) {
      setState(() => quote = null);
      return;
    }
    try {
      final q = await merchantApi.staffWork('staff_order_quote', {'member_id': memberId, 'lines': _lines});
      if (mounted && seq == _seq) setState(() => quote = q);
    } catch (e) {
      if (mounted && seq == _seq) {
        setState(() => quote = null);
        AppToast.error(context, e);
      }
    }
  }

  Future<void> _submit() => runBusy('StOrder>submit', () async {
    if (selected.isEmpty) {
      hToast(context, '请先选择服务项目');
      return;
    }
    try {
      await merchantApi.staffWork('staff_order_submit', {
        'member_id': memberId,
        'lines': _lines,
        'plate': '${widget.info['plate'] ?? ''}',
        'note': note,
      });
      if (!mounted) return;
      AppToast.show(context, '已提交到收银，前台收银后会通知你', kind: ToastKind.success);
      openRoute(context, 'StHome');
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  });

  Widget _icon(BuildContext context, int i) {
    switch (i % 3) {
      case 0:
        return hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.707, -0.707), end: Alignment(0.707, 0.707), colors: [Color(0xFFF5B547), Color(0xFFE08A1E)], stops: [0, 1]), radius: BorderRadius.circular(14), child: hrow([hsvg(Svgs.s91, w: 22, h: 22)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0));
      case 1:
        return hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.707, -0.707), end: Alignment(0.707, 0.707), colors: [Color(0xFF59D49A), Color(0xFF17A864)], stops: [0, 1]), radius: BorderRadius.circular(14), child: hrow([hsvg(Svgs.s92, w: 22, h: 22)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0));
      default:
        return hbox(w: 44, h: 44, grad: LinearGradient(begin: Alignment(-0.707, -0.707), end: Alignment(0.707, 0.707), colors: [Color(0xFF5BA8FF), Color(0xFF0485F7)], stops: [0, 1]), radius: BorderRadius.circular(14), child: hrow([hsvg(Svgs.s93, w: 22, h: 22)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0));
    }
  }

  Widget _row(BuildContext context, int i, Map<String, dynamic> svc) {
    final id = '${svc['id']}';
    final selected = this.selected.contains(id);
    final name = '${svc['name'] ?? ''}';
    final sub = _discountText();
    final price = stMoney(num.tryParse('${svc['price']}') ?? 0);
    return hTap(context, hbox(minH: 72, bg: selected ? dk(context, Color(0xFFF3F9FF), Color.fromRGBO(4, 133, 247, 0.1)) : null, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([_icon(context, i), Expanded(flex: 1, child: hcol([Text(name, style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22)), Text(sub, style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2)), Text(price, style: hts(16, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 23)), selected ? hbox(w: 24, h: 24, bg: Color(0xFF0485F7), radius: BorderRadius.circular(12), child: hrow([hsvg(Svgs.s20, w: 13, h: 13)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0)) : hbox(w: 24, h: 24, radius: BorderRadius.circular(12), border: dk(context, Border.all(color: Color(0xFFD4D4D8), width: 2), Border.all(color: Color(0xFF3F3F46), width: 2)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 12)), onTap: () => _toggle(id));
  }

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol([hbox(pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 130), child: hcol([hrow([hbox(w: 87, child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hTap(context, hbox(w: 44, h: 44, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(22), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: hrow([hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0)), back: true))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0, intrinsic: true)), Expanded(flex: 1, child: Text('快速开单', style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 24), textAlign: TextAlign.center)), hbox(w: 87)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0), hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), pad: EdgeInsets.fromLTRB(16, 12, 16, 12), child: hcol([hrow([hsvg(dk(context, Svgs.s89, Svgs.s90), w: 80, h: 30), Expanded(flex: 1, child: hcol([Align(alignment: Alignment.topLeft, child: hbox(grad: LinearGradient(begin: Alignment(-0, -1), end: Alignment(0, 1), colors: [Color(0xFF2F73F2), Color(0xFF1A4FC4)], stops: [0, 1]), radius: BorderRadius.circular(5), shadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.08), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)], border: Border.all(color: Color.fromRGBO(255, 255, 255, 0.75), width: 1.5), pad: EdgeInsets.fromLTRB(7, 1, 7, 1), child: Text(_plate, style: hts(12, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 18, ls: 0.5), softWrap: false, maxLines: 1))), Text(_who, style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 19))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 4)), hTap(context, hbox(h: 32, bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)), radius: BorderRadius.circular(16), pad: EdgeInsets.fromLTRB(14, 0, 14, 0), child: Align(alignment: Alignment(0, 0), widthFactor: 1, child: Text('更换', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600)))), to: 'StMember')], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 10)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 14)), hcol([hbox(pad: EdgeInsets.fromLTRB(4, 0, 0, 0), child: Text('选择服务', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18))), hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), pad: EdgeInsets.fromLTRB(0, 4, 0, 4), child: hcol([if (services.isEmpty) hbox(minH: 72, pad: EdgeInsets.fromLTRB(16, 0, 16, 0), child: hrow([Expanded(flex: 1, child: Text('暂无在售的服务项目', style: hts(14, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 20)))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0)), for (var i = 0; i < services.length; i++) ...[if (i > 0) hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E))), _row(context, i, services[i])]], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 8), hcol([Text('备注', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 18)), hbox(minH: 48, bg: dk(context, Color(0xFFF4F4F5), Color(0xFF27272A)), radius: BorderRadius.circular(14), pad: EdgeInsets.fromLTRB(14, 0, 14, 0), child: hrow([Expanded(child: HInput(onChanged: (t) => note = t, style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), lh: 22), hint: '如：车内有宠物毛发'))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 10))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 6)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 16))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0),
      overlays: [HBottomDock(child: hbox(bg: dk(context, Color.fromRGBO(255, 255, 255, 0.94), Color.fromRGBO(9, 9, 11, 0.92)), shadow: dk(context, [BoxShadow(color: Color(0xFFE4E4E7), offset: Offset(0, -1), blurRadius: 0, spreadRadius: 0)], [BoxShadow(color: Color(0xFF3A3A40), offset: Offset(0, -1), blurRadius: 0, spreadRadius: 0)]), pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)), child: hcol([hrow([Expanded(flex: 10, child: hcol([Text(_selText, style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)))), Text(_totalText, style: hts(18, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 26))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0)), Expanded(flex: 12, child: hTap(context, hbox(h: 50, bg: Color(0xFF0485F7), radius: BorderRadius.circular(25), child: Align(alignment: Alignment(0, 0), widthFactor: 1, child: hBusy('StOrder>submit', Text('提交到收银', style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22))))), onTap: _submit))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 10)], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 10)))],
    );
  }
}

/// 快速开单：会员取自「会员查询 / 会员简况」选中的那位。
class StOrderLivePage extends StatelessWidget {
  const StOrderLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '快速开单',
    load: () async {
      final id = StMemberFlow.currentId;
      if (id == null) throw const AppError('请先选择会员', type: AppErrorType.notFound);
      final info = await merchantApi.staffWork('staff_member_info', {'id': id});
      await ServiceStore.load();
      return {'info': info, 'services': ServiceStore.sellable};
    },
    builder: (_, d) => StOrderTemplate(
      info: Map<String, dynamic>.from(d['info'] as Map),
      services: [for (final x in (d['services'] as List)) Map<String, dynamic>.from(x as Map)],
    ),
  );
}
