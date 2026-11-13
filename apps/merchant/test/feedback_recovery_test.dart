import 'dart:typed_data';

import 'package:autocare_merchant/backend/feedback_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('恢复数据是只读副本，仅同账号可领取一次，另一账号进入时清除', () {
    final recovery = FeedbackRecovery();
    final original = FeedbackDraft()
      ..text = '原描述'
      ..contact = 'owner@example.com'
      ..type = 1;
    original.images[0] = FeedbackImage(Uint8List.fromList([1, 2, 3]))
      ..uploadedId = 'image-1';
    recovery.save('owner-a', original);
    original.text = '后来编辑';
    original.images[0]!.bytes[0] = 9;
    original.images[0]!.uploadedId = 'changed';
    expect(recovery.take(null), isNull);
    final restored = recovery.take('owner-a')!;
    expect(restored.text, '原描述');
    expect(restored.type, 1);
    expect(restored.images[0]!.bytes, [1, 2, 3]);
    expect(restored.images[0]!.uploadedId, 'image-1');
    restored.images[0]!.bytes[1] = 8;
    expect(original.images[0]!.bytes, [9, 2, 3]);
    expect(recovery.take('owner-a'), isNull);
    recovery.save('owner-a', original);
    expect(recovery.take('owner-b'), isNull);
    expect(recovery.take('owner-a'), isNull);
    recovery.save(null, original);
    expect(recovery.take(null), isNull);
  });
  test('登录恢复后复用失败提交编号和已上传附件，保持后端重试幂等', () async {
    final original = FeedbackDraft()..text = '超时待重试';
    original.images[1] = FeedbackImage(
      Uint8List.fromList([255, 216, 255, 224]),
    );
    final actions = <String>[], ids = <String?>[];
    Future<Map<String, dynamic>> first(
      Map<String, dynamic> body, {
      Duration timeout = const Duration(seconds: 15),
      String? requestId,
    }) async {
      actions.add(body['action']);
      ids.add(requestId);
      if (body['action'] == 'support_upload') return {'id': 'uploaded'};
      throw const AppError('登录已过期', type: AppErrorType.auth);
    }

    await expectLater(original.submit(first), throwsA(isA<AppError>()));
    final recovery = FeedbackRecovery()..save('owner-a', original);
    final restored = recovery.take('owner-a')!;
    final originalId = ids.last;
    await restored.submit((
      body, {
      timeout = const Duration(seconds: 15),
      requestId,
    }) async {
      actions.add(body['action']);
      ids.add(requestId);
      expect(body['attachments'], ['uploaded']);
      return {'id': 'ticket'};
    });
    expect(actions, ['support_upload', 'support_create', 'support_create']);
    expect(ids.last, originalId);
    expect(restored.submitted, isTrue);
    recovery.save('owner-a', restored);
    expect(recovery.take('owner-a'), isNull);
  });
}
