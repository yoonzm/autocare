import 'package:flutter/material.dart';

import '../backend/staff_flow.dart';
import '../backend/task_flow.dart';
import '../routes.dart' show openRoute;
import 'staff_live.dart';

/// 员工端页面共用的小工具与数据宿主（设计稿 St* 画板）。

/// 头像里的字：门店 / 姓名首字。
String stInitial(String s) => s.isEmpty ? '' : String.fromCharCode(s.runes.first);

/// 北京时间的问候语。
String stGreeting([DateTime? now]) {
  final t = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
  return t.hour < 11 ? '早上好' : (t.hour < 18 ? '下午好' : '晚上好');
}

String stMoney(Object? v) => StaffFlow.money(v);

/// 10:30（北京时间）。
String stClock(Object? iso) {
  final t = DateTime.tryParse('${iso ?? ''}')?.toUtc().add(const Duration(hours: 8));
  if (t == null) return '—';
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// 今天 10:30 / 明天 10:30。
String stDayLabel(Object? iso) => '${staffDayLabel(iso)} ${stClock(iso)}';

bool stPlateGreen(Object? plate) => staffGreenPlate(plate);

/// 员工端页面的数据宿主：加载骨架 → 内容，失败给带重试的错误页，可下拉刷新。
class StLive extends StatelessWidget {
  final Future<Map<String, dynamic>> Function() load;
  final Widget Function(BuildContext context, Map<String, dynamic> data) builder;
  final String title;
  const StLive({super.key, required this.load, required this.builder, this.title = ''});

  @override
  Widget build(BuildContext context) =>
      StaffLiveHost(needsId: false, title: title, load: (_) => load(), builder: builder);
}

/// 预约结束时间（开始时间 + 标准工时）。
DateTime stEnd(Map<String, dynamic> t) => (DateTime.tryParse('${t['starts_at']}') ?? DateTime.now())
    .add(Duration(minutes: ((t['duration_minutes'] as num?) ?? 30).toInt()));

/// 打开任务详情（预约 ID 经 [TaskFlow] 传给详情页）。
void stOpenTask(BuildContext context, String id) {
  TaskFlow.currentId = id;
  openRoute(context, 'StTaskDetail');
}
