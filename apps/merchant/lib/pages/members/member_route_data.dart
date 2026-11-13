/// 会员页面显式接收导航数据；不保存全局当前会员或活动表单。
class MemberRouteData {
  final Map<String, dynamic>? member;
  final Map<String, dynamic>? vehicle;
  MemberRouteData({Map<String, dynamic>? member, Map<String, dynamic>? vehicle})
    : member = member == null ? null : Map.unmodifiable(member),
      vehicle = vehicle == null ? null : Map.unmodifiable(vehicle);

  @override
  bool operator ==(Object other) =>
      other is MemberRouteData &&
      member?['id'] == other.member?['id'] &&
      vehicle == other.vehicle;
  @override
  int get hashCode => Object.hash(member?['id'], vehicle);
}
