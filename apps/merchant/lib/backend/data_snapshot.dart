/// 参数和回执的独立只读快照；保留 JSON 字段及 DateTime 等不可变标量。
Map<String, dynamic> dataSnapshot(Map<String, dynamic> value) =>
    Map.unmodifiable({
      for (final entry in value.entries) entry.key: _snapshotValue(entry.value),
    });

dynamic _snapshotValue(dynamic value) {
  if (value is Map) return dataSnapshot(Map<String, dynamic>.from(value));
  if (value is List) return List.unmodifiable(value.map(_snapshotValue));
  return value;
}
