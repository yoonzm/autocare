/// 员工会员链路只传明确会员 ID，不借用商户端完整会员资料或全局选择。
class StMemberRouteData {
  final String memberId;
  const StMemberRouteData(this.memberId);
  @override
  bool operator ==(Object other) =>
      other is StMemberRouteData && other.memberId == memberId;
  @override
  int get hashCode => memberId.hashCode;
}
