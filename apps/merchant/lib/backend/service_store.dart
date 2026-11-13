import 'data_snapshot.dart';
import 'store_context.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'merchant_api.dart';

/// 服务项目的全局缓存。
///
/// 开单、次卡套餐选服务、服务项目列表……很多页面都要用同一份服务项目，没必要每个页面都重新请求：
/// - 登录后（读到门店资料时）预加载一次；之后各页面直接读缓存，打开就有数据，没有骨架屏闪一下；
/// - 缓存超过 [maxAge] 时，读取的同时在后台静默刷新（刷新完通过 [changed] 通知页面）；
/// - 在服务项目页新增 / 修改 / 删除后立即刷新缓存；
/// - 同时发起多个读取只会发一个请求；
/// - 退出登录 / 换账号时清空，不会看到上一家店的服务项目。
///
/// 价格等规则仍以云函数为准（开单时云函数按服务端价格结算），缓存只用来显示和选择。
class ServiceStore {
  ServiceStore._();

  /// 缓存多久后读取时顺带后台刷新。
  static const maxAge = Duration(minutes: 5);

  static List<Map<String, dynamic>>? _cached;
  static DateTime? _loadedAt;
  static Future<List<Map<String, dynamic>>>? _inflight;

  /// 缓存属于哪个 API 客户端；换了客户端（测试里换成假接口、重新初始化）就当作没有缓存。
  static Object? _owner;
  static int _revision = 0;
  static int? _storeEpoch;

  static void _sync() {
    if (!identical(_owner, merchantApi) || _storeEpoch != StoreContext.epoch) {
      _revision++;
      _storeEpoch = StoreContext.epoch;
      _cached = null;
      _loadedAt = null;
      _inflight = null;
      _owner = merchantApi;
    }
  }

  static List<Map<String, dynamic>>? get _items {
    _sync();
    return _cached;
  }

  /// 缓存更新（后台刷新完成 / 保存后刷新 / 清空）时加一。
  static final changed = ValueNotifier<int>(0);

  /// 全部服务项目（含已下架）；还没读过时为 null。
  static List<Map<String, dynamic>>? get items => _items;

  /// 在售的服务项目（开单、套餐选服务用）。
  static List<Map<String, dynamic>> get sellable => [
    for (final s in _items ?? const <Map<String, dynamic>>[])
      if (s['active'] != false) s,
  ];

  static bool get _stale =>
      _loadedAt == null || DateTime.now().difference(_loadedAt!) > maxAge;

  /// 读取服务项目。有缓存时立即返回缓存（过期则同时后台刷新）；没有缓存时请求并等待结果，
  /// 失败会抛出（页面显示错误和重试）。[force] 为 true 时一定重新请求。
  static Future<List<Map<String, dynamic>>> load({bool force = false}) {
    final cached = _items;
    if (cached != null && !force) {
      if (_stale) {
        unawaited(refresh().catchError((_) => <Map<String, dynamic>>[]));
      }
      return Future.value(cached);
    }
    return refresh();
  }

  /// 重新请求并更新缓存。已经有请求在进行时复用它。失败时保留旧缓存并抛出。
  static Future<List<Map<String, dynamic>>> refresh() {
    _sync();
    final running = _inflight;
    if (running != null) return running;
    final epoch = StoreContext.epoch;
    final revision = _revision;
    final api = merchantApi;
    final future = () async {
      try {
        final rows = List<Map<String, dynamic>>.unmodifiable(
          (await api.list('services')).map(dataSnapshot),
        );
        if (epoch != StoreContext.epoch ||
            revision != _revision ||
            !identical(api, merchantApi)) {
          return rows;
        }
        _cached = rows;
        _loadedAt = DateTime.now();
        changed.value++;
        return rows;
      } finally {
        if (epoch == StoreContext.epoch &&
            revision == _revision &&
            identical(api, merchantApi)) {
          _inflight = null;
        }
      }
    }();
    _inflight = future;
    return future;
  }

  /// 测试用：把缓存时间调成 [age] 之前，用来验证过期后的后台刷新。
  @visibleForTesting
  static void debugAge(Duration age) =>
      _loadedAt = DateTime.now().subtract(age);

  /// 清空（退出登录 / 换账号）。
  static void clear() {
    _revision++;
    _cached = null;
    _loadedAt = null;
    _inflight = null;
    changed.value++;
  }
}
