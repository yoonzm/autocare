// 从员工端设计稿生成页派生（tools/bind_st.py），仅绑定数据和事件；不手工修改 gen_st/。
import 'package:flutter/material.dart';

import '../backend/access_flow.dart';
import '../backend/merchant_api.dart';
import '../backend/task_flow.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import '../routes.dart' show openRoute;
import 'gen_st/svgs.dart';
import 'st_live.dart';

class StMsgsTemplate extends StatefulWidget {
  final Map<String, dynamic> d;
  const StMsgsTemplate({super.key, required this.d});

  @override
  State<StMsgsTemplate> createState() => _StMsgsTemplateState();
}

class _StMsgsTemplateState extends State<StMsgsTemplate> {
  static const kinds = ['task', 'arrival', 'system'];
  int tab = 0;

  Future<void> open(Map<String, dynamic> m) async {
    final link = '${m['link'] ?? ''}';
    if (link.startsWith('StTaskDetail:')) {
      TaskFlow.currentId = link.substring('StTaskDetail:'.length);
      openRoute(context, 'StTaskDetail');
    } else if (link.isNotEmpty) {
      openRoute(context, link);
    }
    if (m['read_at'] == null) {
      try {
        await merchantApi.staffWork('staff_messages_read', {'id': m['id']});
        TaskFlow.notify();
      } catch (_) {
        // 标记已读失败不影响查看，下次进入仍显示未读
      }
    }
  }

  Future<void> readAll() async {
    try {
      await merchantApi.staffWork('staff_messages_read');
      TaskFlow.notify();
    } catch (e) {
      if (mounted) AccessFlow.toastError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = [for (final x in (widget.d['items'] as List? ?? const [])) Map<String, dynamic>.from(x as Map)];
    final shown = tab == 0 ? all : [for (final m in all) if (m['kind'] == kinds[tab - 1]) m];
    Widget row(Map<String, dynamic> m) => switch (m['kind']) {
      'task' => hTap(context, hbox(pad: EdgeInsets.fromLTRB(16, 14, 16, 14), child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hbox(w: 36, h: 36, bg: dk(context, Color(0xFFE1F0FE), Color.fromRGBO(4, 133, 247, 0.18)), radius: BorderRadius.circular(12), child: hrow([hsvg(dk(context, Svgs.s81, Svgs.s82), w: 18, h: 18)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0))), Expanded(flex: 1, child: hcol([hrow([Text('${m['title']}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22)), if (m['read_at'] == null) hbox(w: 8, h: 8, bg: Color(0xFFF31260), radius: BorderRadius.circular(4)), Expanded(flex: 1, child: SizedBox.shrink()), Text(stMsgTime(m['created_at']), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 6), Text('${m['body']}', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 19))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 12, intrinsic: true)), onTap: () => open(m)),
      'arrival' => hTap(context, hbox(pad: EdgeInsets.fromLTRB(16, 14, 16, 14), child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hbox(w: 36, h: 36, bg: dk(context, Color(0xFFDDF6E7), Color.fromRGBO(23, 201, 100, 0.16)), radius: BorderRadius.circular(12), child: hrow([hsvg(dk(context, Svgs.s83, Svgs.s84), w: 18, h: 18)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0))), Expanded(flex: 1, child: hcol([hrow([Text('${m['title']}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 22)), if (m['read_at'] == null) hbox(w: 8, h: 8, bg: Color(0xFFF31260), radius: BorderRadius.circular(4)), Expanded(flex: 1, child: SizedBox.shrink()), Text(stMsgTime(m['created_at']), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 6), Text('${m['body']}', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 19))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 12, intrinsic: true)), onTap: () => open(m)),
      _ => '${m['link']}' == 'StPerf' ? hTap(context, hbox(pad: EdgeInsets.fromLTRB(16, 14, 16, 14), child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hbox(w: 36, h: 36, bg: dk(context, Color(0xFFFDEFD6), Color.fromRGBO(245, 165, 36, 0.16)), radius: BorderRadius.circular(12), child: hrow([hsvg(dk(context, Svgs.s85, Svgs.s86), w: 18, h: 18)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0))), Expanded(flex: 1, child: hcol([hrow([Text('${m['title']}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 22)), if (m['read_at'] == null) hbox(w: 8, h: 8, bg: Color(0xFFF31260), radius: BorderRadius.circular(4)), Expanded(flex: 1, child: SizedBox.shrink()), Text(stMsgTime(m['created_at']), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 6), Text('${m['body']}', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 19))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 12, intrinsic: true)), onTap: () => open(m)) : hTap(context, hbox(pad: EdgeInsets.fromLTRB(16, 14, 16, 14), child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hbox(w: 36, h: 36, bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)), radius: BorderRadius.circular(12), child: hrow([hsvg(dk(context, Svgs.s75, Svgs.s76), w: 18, h: 18)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0))), Expanded(flex: 1, child: hcol([hrow([Text('${m['title']}', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 22)), if (m['read_at'] == null) hbox(w: 8, h: 8, bg: Color(0xFFF31260), radius: BorderRadius.circular(4)), Expanded(flex: 1, child: SizedBox.shrink()), Text(stMsgTime(m['created_at']), style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 17))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 6), Text('${m['body']}', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 19))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 12, intrinsic: true)), onTap: () => open(m)),
    };
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol([hbox(pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 0), child: hcol([hrow([hbox(w: 87, child: hrow([UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: hTap(context, hbox(w: 44, h: 44, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(22), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: hrow([hsvg(dk(context, Svgs.s0, Svgs.s1), w: 20, h: 20)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0)), back: true))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0, intrinsic: true)), Expanded(flex: 1, child: Text('消息', style: hts(17, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 24), textAlign: TextAlign.center)), hbox(w: 87, child: hrow([Flexible(flex: 52, child: hTap(context, hbox(pad: EdgeInsets.fromLTRB(0, 12, 0, 12), child: Text('全部已读', style: hts(13, dk(context, Color(0xFF1E63AE), Color(0xFF6AB4FA)), w: FontWeight.w500, lh: 20))), onTap: () => runBusy('StMsgs>readAll', readAll), label: '全部已读'))], main: MainAxisAlignment.end, cross: CrossAxisAlignment.start, gap: 0))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 0), hbox(bg: dk(context, Color(0xFFE9E9EB), Color(0xFF1F1F23)), radius: BorderRadius.circular(20), pad: EdgeInsets.fromLTRB(4, 4, 4, 4), child: HSelHolder(groups: [({tab}, false)], onSelect: {0: (i) => setState(() => tab = i)}, builder: (context, g1) => hrow([Expanded(flex: 1, child: UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: HSel(ctrl: g1[0], index: 0, segment: true, on: hbox(h: 34, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(17), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('全部', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 18)))), off: hbox(h: 34, radius: BorderRadius.circular(17), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('全部', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18))))))), Expanded(flex: 1, child: UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: HSel(ctrl: g1[0], index: 1, segment: true, on: hbox(h: 34, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(17), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('任务', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 18)))), off: hbox(h: 34, radius: BorderRadius.circular(17), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('任务', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18))))))), Expanded(flex: 1, child: UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: HSel(ctrl: g1[0], index: 2, segment: true, on: hbox(h: 34, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(17), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('到店', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 18)))), off: hbox(h: 34, radius: BorderRadius.circular(17), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('到店', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18))))))), Expanded(flex: 1, child: UnconstrainedBox(alignment: Alignment.topLeft, constrainedAxis: Axis.horizontal, child: HSel(ctrl: g1[0], index: 3, segment: true, on: hbox(h: 34, bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(17), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('系统', style: hts(13, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 18)))), off: hbox(h: 34, radius: BorderRadius.circular(17), child: Align(alignment: Alignment.center, widthFactor: 1, child: Text('系统', style: hts(13, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), w: FontWeight.w500, lh: 18)))))))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 2, intrinsic: true))), hbox(bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)), radius: BorderRadius.circular(24), shadow: dk(context, [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 0), blurRadius: 1, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), offset: Offset(0, 1), blurRadius: 2, spreadRadius: 0), BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), offset: Offset(0, 2), blurRadius: 4, spreadRadius: 0)], [BoxShadow(color: Color(0xFF26262B), offset: Offset(0, 0), blurRadius: 0, spreadRadius: 1)]), pad: EdgeInsets.fromLTRB(0, 4, 0, 4), child: hcol([if (shown.isEmpty) hbox(minH: 64, align: Alignment.center, child: Text('暂无消息', style: hts(13, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18))), for (var i = 0; i < shown.length; i++) ...[if (i > 0) hbox(h: 1, bg: dk(context, Color(0xFFEFEFF1), Color(0xFF2A2A2E)), margin: EdgeInsets.fromLTRB(64, 0, 0, 0)), row(shown[i])]], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 16))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0),
      overlays: [],
    );
  }
}

/// 消息：任务 / 到店 / 系统通知；点开跳转到对应页面并标记已读。
class StMsgsLivePage extends StatelessWidget {
  const StMsgsLivePage({super.key});

  @override
  Widget build(BuildContext context) => StLive(
    title: '消息',
    load: () => merchantApi.staffWork('staff_messages'),
    builder: (_, d) => StMsgsTemplate(d: d),
  );
}
