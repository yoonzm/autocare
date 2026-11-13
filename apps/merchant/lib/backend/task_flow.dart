import 'package:flutter/foundation.dart';

/// 任务数据变更的刷新信号；导航参数与完工结果由页面实例持有。
class TaskFlow {
  TaskFlow._();
  static final changed = ValueNotifier<int>(0);
  static void notify() => changed.value++;
}
