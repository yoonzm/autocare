import 'package:flutter/material.dart';
import '../../kit/kit.dart';
import 'svgs.dart';

class StNoPermPage extends StatelessWidget {
  const StNoPermPage({super.key});

  @override
  Widget build(BuildContext context) {
    return HPage(
      bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
      height: 844,
      fixedHeight: false,
      flow: hcol([hbox(pad: EdgeInsets.fromLTRB(28, 0, 28, 120), child: hcol([hbox(w: 88, h: 88, bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)), radius: BorderRadius.circular(28), child: hrow([hsvg(dk(context, Svgs.s87, Svgs.s88), w: 40, h: 40)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 0)), hbox(margin: EdgeInsets.fromLTRB(0, 8, 0, 0), child: Text('暂无权限访问', style: hts(20, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w600, lh: 28), textAlign: TextAlign.center)), Text('该页面需要「查看门店营业统计」权限。请联系店长开通后再试。', style: hts(14, dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)), lh: 21), textAlign: TextAlign.center), Text('从消息推送或分享链接直接打开无权限的页面时，显示这一页。', style: hts(12, dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)), lh: 18), textAlign: TextAlign.center)], main: MainAxisAlignment.center, cross: CrossAxisAlignment.center, gap: 14))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.stretch, gap: 0),
      overlays: [HBottomDock(child: hbox(bg: dk(context, Color.fromRGBO(255, 255, 255, 0.94), Color.fromRGBO(9, 9, 11, 0.92)), shadow: dk(context, [BoxShadow(color: Color(0xFFE4E4E7), offset: Offset(0, -1), blurRadius: 0, spreadRadius: 0)], [BoxShadow(color: Color(0xFF3A3A40), offset: Offset(0, -1), blurRadius: 0, spreadRadius: 0)]), pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)), child: hrow([Expanded(flex: 10, child: hTap(context, hbox(h: 50, bg: dk(context, Color(0xFFEEEEF0), Color(0xFF27272A)), radius: BorderRadius.circular(25), child: Align(alignment: Alignment(0, 0), widthFactor: 1, child: Text('联系店长', style: hts(15, dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)), w: FontWeight.w500, lh: 22)))), to: 'StMine')), Expanded(flex: 14, child: hTap(context, hbox(h: 50, bg: Color(0xFF0485F7), radius: BorderRadius.circular(25), child: Align(alignment: Alignment(0, 0), widthFactor: 1, child: Text('返回工作台', style: hts(15, Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22)))), back: true))], main: MainAxisAlignment.start, cross: CrossAxisAlignment.center, gap: 10)))],
    );
  }
}
