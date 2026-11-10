import 'package:flutter/foundation.dart';

/// 员工端任务的跨页状态：当前查看的任务（预约）ID。
class TaskFlow {
  TaskFlow._();
  static final changed = ValueNotifier<int>(0);
  static void notify() => changed.value++;
  static String? currentId;
}
