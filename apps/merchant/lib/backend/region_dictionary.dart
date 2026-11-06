import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'merchant_api.dart';

class Region {
  final String code, name;
  final String? parentCode;
  final int level;
  const Region(this.code, this.name, this.parentCode, this.level);
  factory Region.fromJson(Map<String, dynamic> row) => Region(
    row['code'] as String,
    row['name'] as String,
    row['parent_code'] as String?,
    row['level'] as int,
  );
}

class CitySelection {
  final Region province, city;
  const CitySelection(this.province, this.city);
  String get label => '${province.name} · ${city.name}';
}

/// Shared three-level backend dictionary. Registration consumes levels 1–2 only.
class RegionDictionary {
  final String version;
  final List<Region> items;
  RegionDictionary.fromJson(Map<String, dynamic> json)
    : version = json['version'] as String,
      items = (json['items'] as List)
          .map((r) => Region.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList();

  List<Region> children(String? parentCode) =>
      items.where((r) => r.parentCode == parentCode).toList();
  List<Region> get provinces =>
      children(null)
          .where((r) => r.level == 1 && children(r.code).isNotEmpty)
          .toList();

  static const _key = 'region_dictionary_v1';
  static Map<String, dynamic>? _cached;
  static DateTime? _checkedAt;
  static Future<RegionDictionary>? _pending;

  static Future<RegionDictionary> load() =>
      _pending ??= _load().whenComplete(() => _pending = null);

  static Future<RegionDictionary> _load() async {
    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_key);
      if (_cached == null && saved != null) {
        final decoded = Map<String, dynamic>.from(jsonDecode(saved) as Map);
        RegionDictionary.fromJson(decoded); // Reject malformed cache.
        _cached = decoded;
      }
    } catch (_) {
      /* Storage is optional; backend remains authoritative. */
    }
    if (_cached != null &&
        _checkedAt != null &&
        DateTime.now().difference(_checkedAt!) < const Duration(hours: 1)) {
      return RegionDictionary.fromJson(_cached!);
    }
    final response = await merchantApi.invoke({
      'action': 'regions',
      if (_cached != null) 'version': _cached!['version'],
    });
    final data = response['unchanged'] == true ? _cached! : response;
    final dictionary = RegionDictionary.fromJson(data);
    // Do not cache empty responses: allow retry after backend initialization.
    if (dictionary.provinces.isNotEmpty) {
      _cached = data;
      _checkedAt = DateTime.now();
      try {
        await prefs?.setString(_key, jsonEncode(data));
      } catch (_) {}
    }
    return dictionary;
  }
}
