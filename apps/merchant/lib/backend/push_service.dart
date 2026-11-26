import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:aliyun_push/aliyun_push.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../pages/messages/inbox_navigation.dart';
import 'access_flow.dart';
import 'inbox_store.dart';
import 'merchant_api.dart';

const aliyunPushIosAppKey = String.fromEnvironment('ALIYUN_PUSH_IOS_APP_KEY');
const aliyunPushIosAppSecret = String.fromEnvironment(
  'ALIYUN_PUSH_IOS_APP_SECRET',
);

/// 从阿里云推送回调载荷中提取 `message_id`（服务端仅透传 message_id，不传路由）。
String? extractPushMessageId(Map<dynamic, dynamic> raw) {
  final direct = '${raw['message_id'] ?? ''}'.trim();
  if (direct.isNotEmpty) return direct;

  for (final key in const ['extraMap', 'extParameters', 'userInfo', 'aps']) {
    final v = raw[key];
    if (v is Map) {
      final nested = extractPushMessageId(v);
      if (nested != null) return nested;
    } else if (v is String && v.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(v);
        if (decoded is Map) {
          final nested = extractPushMessageId(decoded);
          if (nested != null) return nested;
        }
      } catch (_) {
        // Ignore malformed JSON string in extra field.
      }
    }
  }
  return null;
}

/// 阿里云移动推送（当前接入 iOS 端）：
/// - 未注入 `ALIYUN_PUSH_IOS_APP_KEY` / `ALIYUN_PUSH_IOS_APP_SECRET` 或非 iOS 平台时静默跳过。
/// - 登录后自动绑定 `deviceId` 到当前门店与身份；切换身份/门店时服务端覆盖归属，避免串推。
/// - 点击通知仅携带 `message_id`，通过现有 `inbox_target` 核验权限与归属后再跳转。
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final AliyunPush _sdk = AliyunPush();
  GlobalKey<NavigatorState>? _navKey;
  bool _started = false;
  String? _deviceId;
  String? _boundKey;
  String? _pendingMessageId;
  bool _opening = false;

  bool get _supported =>
      !kIsWeb &&
      Platform.isIOS &&
      aliyunPushIosAppKey.isNotEmpty &&
      aliyunPushIosAppSecret.isNotEmpty;

  Future<void> start({required GlobalKey<NavigatorState> navKey}) async {
    _navKey = navKey;
    if (_started || !_supported) return;
    _started = true;
    Access.changed.addListener(_onIdentityChanged);

    _sdk.addMessageReceiver(
      onNotification: _onNotification,
      onMessage: (_) async {},
      onNotificationOpened: _onOpened,
      onNotificationRemoved: (_) async {},
      onIOSChannelOpened: _onOpened,
      onIOSRegisterDeviceTokenSuccess: (_) async {
        await _refreshDeviceId();
      },
      onIOSRegisterDeviceTokenFailed: (_) async {},
    );

    try {
      final res = await _sdk.initPush(
        appKey: aliyunPushIosAppKey,
        appSecret: aliyunPushIosAppSecret,
      );
      if (res['code'] == kAliyunPushSuccessCode) {
        await _sdk.setIOSForegroundNoticeMode(
          ForegroundNoticeMode.showAndCallback,
        );
        await _refreshDeviceId();
      }
    } catch (_) {
      // 初始化失败不影响 App 主流程（仍可通过前台轮询拉取站内信）。
    }
  }

  Future<void> _refreshDeviceId() async {
    if (!_started) return;
    try {
      final id = (await _sdk.getDeviceId()).trim();
      if (id.length >= 8) {
        _deviceId = id;
        await _syncBinding();
      }
    } catch (_) {
      // 忽略暂未取到 deviceId 的情况，APNs 注册成功回调会再次触发。
    }
  }

  void _onIdentityChanged() {
    unawaited(_syncBinding());
    final pending = _pendingMessageId;
    if (pending != null &&
        merchantApi.hasSession &&
        Access.context.isNotEmpty) {
      _pendingMessageId = null;
      unawaited(_openMessage(pending));
    }
  }

  String? get _currentBindingKey {
    if (!merchantApi.hasSession || Access.context.isEmpty) return null;
    final storeId = '${Access.context['store_id'] ?? ''}';
    if (storeId.isEmpty) return null;
    final staffId = '${Access.context['staff_id'] ?? ''}';
    final actor = Access.isOwner ? (merchantApi.accountId ?? '') : staffId;
    return '$storeId:${Access.role}:$actor';
  }

  Future<void> _syncBinding() async {
    final token = _deviceId;
    if (token == null || token.isEmpty) return;
    final nextKey = _currentBindingKey;
    if (nextKey == null) {
      _boundKey = null;
      return;
    }
    if (nextKey == _boundKey) return;
    try {
      await merchantApi.pushRegister(platform: 'ios', token: token);
      _boundKey = nextKey;
    } catch (_) {
      // 网络波动时保留待下次身份变更或启动重试。
    }
  }

  /// 退出登录前调用，尽力解除当前设备绑定；失败不阻塞退出流程。
  Future<void> unregisterBeforeSignOut() async {
    final token = _deviceId;
    _boundKey = null;
    if (!_started || token == null || token.isEmpty || !merchantApi.hasSession) {
      return;
    }
    try {
      await merchantApi.pushUnregister(platform: 'ios', token: token);
    } catch (_) {
      // 忽略解绑网络异常，下次登录会由服务端 upsert 覆盖。
    }
  }

  /// 同步 iOS 桌面角标数（与站内信未读数一致）。
  Future<void> syncBadge(int unread) async {
    if (!_started || !_supported) return;
    try {
      await _sdk.syncIOSBadgeNum(unread < 0 ? 0 : unread);
    } catch (_) {}
  }

  Future<void> _onNotification(Map<dynamic, dynamic> message) async {
    final ctx = _navKey?.currentContext;
    if (ctx != null) {
      unawaited(InboxScope.of(ctx)?.refresh());
    }
  }

  Future<void> _onOpened(Map<dynamic, dynamic> message) async {
    final id = extractPushMessageId(message);
    if (id == null) return;
    if (!merchantApi.hasSession || Access.context.isEmpty) {
      _pendingMessageId = id;
      return;
    }
    await _openMessage(id);
  }

  Future<void> _openMessage(String messageId) async {
    if (_opening) return;
    final ctx = _navKey?.currentContext;
    if (ctx == null) {
      _pendingMessageId = messageId;
      return;
    }
    _opening = true;
    try {
      final inbox = InboxScope.of(ctx);
      try {
        final readRes = await merchantApi.inbox('read', {'id': messageId});
        inbox?.acceptUnread(
          readRes['unread'],
          newest: readRes['latest'] as String?,
        );
      } catch (_) {
        // 已读标记失败不阻止继续解析目标。
      }
      final target = await merchantApi.inbox('target', {'id': messageId});
      final currentCtx = _navKey?.currentContext;
      if (currentCtx != null && currentCtx.mounted) {
        openInboxTarget(currentCtx, target);
      }
    } catch (e) {
      final currentCtx = _navKey?.currentContext;
      if (currentCtx != null && currentCtx.mounted) {
        AppToast.error(currentCtx, e);
      }
    } finally {
      _opening = false;
    }
  }

  void dispose() {
    if (_started) {
      Access.changed.removeListener(_onIdentityChanged);
      _started = false;
    }
    _navKey = null;
  }
}
