/// 员工管理页面的显式导航参数；活动表单与选择状态由各页面实例持有。
class StaffRouteData {
  final String? staffId;
  final String? role;
  final Map<String, dynamic>? employee;
  const StaffRouteData({this.staffId, this.role, this.employee});
  @override
  bool operator ==(Object other) =>
      other is StaffRouteData &&
      staffId == other.staffId &&
      role == other.role &&
      employee?['id'] == other.employee?['id'];
  @override
  int get hashCode => Object.hash(staffId, role, employee?['id']);
}
