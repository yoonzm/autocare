import 'package:autocare_async_kit/async_kit.dart';
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
}
