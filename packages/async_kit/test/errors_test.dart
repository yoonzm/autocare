import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('403/404 分类保留 HTTP 状态，服务端文案不改变类型', () {
    for (final message in [null, '', '仅服务端知道的具体原因']) {
      expect(AppError.fromStatus(403, message).type, AppErrorType.forbidden);
      expect(AppError.fromStatus(404, message).type, AppErrorType.notFound);
    }
    expect(AppError.fromStatus(404, '订单不存在').message, '订单不存在');
    expect(AppError.fromStatus(403, '不能查看该会员').message, '不能查看该会员');
    expect(AppError.fromStatus(400, '余额不足').type, AppErrorType.business);
  });

  test('弱网与限流状态码映射为可重试错误', () {
    expect(AppError.fromStatus(0).type, AppErrorType.network);
    expect(AppError.fromStatus(0).retryable, isTrue);
    expect(AppError.fromStatus(499).type, AppErrorType.network);
    expect(AppError.fromStatus(499).retryable, isTrue);
    expect(AppError.fromStatus(408).type, AppErrorType.timeout);
    expect(AppError.fromStatus(408).retryable, isTrue);
    final limited = AppError.fromStatus(429);
    expect(limited.type, AppErrorType.server);
    expect(limited.code, 'SRV_429');
    expect(limited.retryable, isTrue);
  });

  testWidgets('ErrorView 行内业务错误展示具体原因并保留重试出口', (t) async {
    var retried = 0;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ErrorView(
            inline: true,
            error: const AppError('门店已切换，请重新操作'),
            onRetry: () => retried++,
          ),
        ),
      ),
    );
    expect(find.text('门店已切换，请重新操作'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    await t.tap(find.text('重试'));
    expect(retried, 1);
  });
}
