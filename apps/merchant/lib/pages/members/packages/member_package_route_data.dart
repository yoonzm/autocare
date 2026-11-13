class MemberPackageRouteData {
  final String id;
  final Map<String, dynamic> member;
  final Map<String, dynamic>? package;
  MemberPackageRouteData({
    required this.id,
    required Map<String, dynamic> member,
    Map<String, dynamic>? package,
  }) : member = Map.unmodifiable(member),
       package = package == null ? null : Map.unmodifiable(package);
  @override
  bool operator ==(Object other) =>
      other is MemberPackageRouteData &&
      id == other.id &&
      member['id'] == other.member['id'];
  @override
  int get hashCode => Object.hash(id, member['id']);
}
