/// 任务导航参数；完工结果只传给本次结果页，不保存为全局状态。
class TaskRouteData {
  final String? taskId;
  final Map<String, dynamic>? result;
  const TaskRouteData({this.taskId, this.result});

  @override
  bool operator ==(Object other) =>
      other is TaskRouteData &&
      taskId == other.taskId &&
      result == other.result;

  @override
  int get hashCode => Object.hash(taskId, result);
}
