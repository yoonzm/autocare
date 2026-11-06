import 'dart:async';
import 'dart:io' show HandshakeException, SocketException, TlsException;

enum AppErrorType {
  network,
  timeout,
  server,
  auth,
  forbidden,
  notFound,
  business,
}

class AppError implements Exception {
  final AppErrorType type;

  /// 可直接展示给用户的文案。
  final String message;

  /// 服务异常时的错误码，如 `SRV_503`，用于客服排查。
  final String? code;
  const AppError(this.message, {this.type = AppErrorType.business, this.code});

  /// 网络 / 超时 / 服务异常可以重试；登录失效、无权限、不存在、业务失败重试也不会成功。
  bool get retryable =>
      type == AppErrorType.network ||
      type == AppErrorType.timeout ||
      type == AppErrorType.server;

  String get title => switch (type) {
    AppErrorType.network => '网络不太给力',
    AppErrorType.timeout => '请求超时',
    AppErrorType.server => '服务开小差了',
    AppErrorType.auth => '登录已过期',
    AppErrorType.forbidden => '暂无权限访问',
    AppErrorType.notFound => '内容不存在或已删除',
    AppErrorType.business => '操作失败',
  };

  const AppError.network()
    : this('网络不太给力，请检查网络后重试', type: AppErrorType.network);
  const AppError.timeout()
    : this('请求超时，当前网络较慢，请稍后重试', type: AppErrorType.timeout);

  /// 把 HTTP 状态和服务端文案映射成统一错误。
  /// 4xx 业务失败直接展示服务端文案；只有 401 视为登录失效。
  factory AppError.fromStatus(int status, [String? serverMessage]) {
    final text = (serverMessage ?? '').trim();
    if (status == 401) {
      return AppError(
        text.isNotEmpty ? text : '登录已过期，请重新登录',
        type: AppErrorType.auth,
      );
    }
    if (status >= 500) {
      return AppError(
        '服务开小差了，请稍后再试',
        type: AppErrorType.server,
        code: 'SRV_$status',
      );
    }
    if (text.isEmpty) {
      if (status == 403) {
        return const AppError('暂无权限访问', type: AppErrorType.forbidden);
      }
      if (status == 404) {
        return const AppError('内容不存在或已删除', type: AppErrorType.notFound);
      }
    }
    return AppError(text.isNotEmpty ? text : '操作失败（$status）');
  }

  /// 任意异常 -> [AppError]。
  static AppError from(Object e) {
    if (e is AppError) return e;
    if (e is TimeoutException) return const AppError.timeout();
    if (e is SocketException || e is HandshakeException || e is TlsException) {
      return const AppError.network();
    }
    final s = e.toString();
    if (s.contains('SocketException') ||
        s.contains('ClientException') ||
        s.contains('Failed host lookup') ||
        s.contains('Connection')) {
      return const AppError.network();
    }
    return AppError('操作失败，请稍后重试', type: AppErrorType.server, code: 'UNKNOWN');
  }

  @override
  String toString() => message;
}
