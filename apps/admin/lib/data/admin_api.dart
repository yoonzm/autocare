import 'dart:async';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:autocare_async_kit/async_kit.dart';
import 'package:autocare_supabase_adapter/errors.dart';

const backendUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://autocare.mymember.ltd',
);
const backendKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_mzNkMTh1lVnIXThevC--Zj_5bG1XkCJ',
);
final authExpired = ValueNotifier<int>(0);
String requestId() {
  final r = Random.secure();
  final b = List<int>.generate(16, (_) => r.nextInt(256));
  b[6] = (b[6] & 15) | 64;
  b[8] = (b[8] & 63) | 128;
  final s = b.map((n) => n.toRadixString(16).padLeft(2, '0')).join();
  return '${s.substring(0, 8)}-${s.substring(8, 12)}-${s.substring(12, 16)}-${s.substring(16, 20)}-${s.substring(20)}';
}

class AdminApi {
  final _pendingWrites = <String, String>{};
  SupabaseClient get client => Supabase.instance.client;
  bool get hasSession => client.auth.currentSession != null;
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final read =
        action == 'snapshot' ||
        action == 'me' ||
        action == 'ticket_attachment' ||
        action == 'sms_list' ||
        action == 'sms_get' ||
        action == 'user_list' ||
        action == 'user_get';
    final operation = '$action:${jsonEncode(values)}';
    final id = read || action == 'login'
        ? requestId()
        : _pendingWrites.putIfAbsent(operation, requestId);
    var refreshed = false;
    var retried = false;
    while (true) {
      try {
        final result = await client.functions
            .invoke(
              'admin-v1',
              body: {'action': action, ...values},
              headers: {'X-Request-Id': id},
            )
            .timeout(kRequestTimeout);
        final body = Map<String, dynamic>.from(result.data as Map);
        if (body['error'] != null) {
          throw AppError.fromStatus(result.status, body['error'] as String);
        }
        _pendingWrites.remove(operation);
        return body;
      } catch (error) {
        final problem = supabaseAppError(error);
        if (action != 'login' && problem.type == AppErrorType.auth) {
          if (!refreshed) {
            refreshed = true;
            try {
              await client.auth.refreshSession().timeout(kRequestTimeout);
              continue;
            } catch (_) {
              /* Expired below. */
            }
          }
          await withSupabaseErrors(
            () => client.auth.signOut(scope: SignOutScope.local),
          );
          authExpired.value++;
        }
        if (read && problem.retryable && !retried) {
          retried = true;
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        if (!problem.retryable && problem.type != AppErrorType.auth) {
          _pendingWrites.remove(operation);
        }
        throw problem;
      }
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final data = await call('login', {
      'username': username,
      'password': password,
    });
    await withSupabaseErrors(
      () => client.auth.setSession(data['refresh_token'] as String),
    );
    return data;
  }

  Future<void> changePassword(String password) async {
    final data = await call('change_password', {'password': password});
    await withSupabaseErrors(
      () => client.auth.setSession(data['refresh_token'] as String),
    );
  }

  Future<void> clearSession() async {
    _pendingWrites.clear();
    await withSupabaseErrors(
      () => client.auth.signOut(scope: SignOutScope.local),
    );
  }
}
