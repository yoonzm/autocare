import 'dart:typed_data';

import 'package:autocare_merchant/backend/feedback_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'lost submit response reuses ID and already uploaded screenshots',
    () async {
      final draft = FeedbackDraft()
        ..text = 'Unable to save'
        ..type = 1
        ..contact = 'owner@example.com';
      draft.images[0] = FeedbackImage(Uint8List.fromList([255, 216, 255, 224]));
      var uploads = 0, creates = 0;
      final ids = <String?>[];
      Future<Map<String, dynamic>> request(
        Map<String, dynamic> body, {
        Duration timeout = const Duration(seconds: 15),
        String? requestId,
      }) async {
        if (body['action'] == 'support_upload') {
          uploads++;
          return {'id': 'image-1'};
        }
        creates++;
        ids.add(requestId);
        expect(body['category'], '问题报告');
        expect(body['contact'], 'owner@example.com');
        expect(body['attachments'], ['image-1']);
        if (creates == 1) {
          throw const AppError('timeout', type: AppErrorType.timeout);
        }
        return {'id': 'ticket-1'};
      }

      await expectLater(draft.submit(request), throwsA(isA<AppError>()));
      expect(draft.text, 'Unable to save');
      expect(await draft.submit(request), 'ticket-1');
      expect(uploads, 1);
      expect(ids.first, isNotEmpty);
      expect(ids.last, ids.first);
      expect(draft.submitted, isTrue);
      await expectLater(draft.submit(request), throwsA(isA<AppError>()));
    },
  );
  test(
    'editing after failure gets a new request ID; invalid forms do not send',
    () async {
      final draft = FeedbackDraft();
      final ids = <String?>[];
      Future<Map<String, dynamic>> request(
        Map<String, dynamic> body, {
        Duration timeout = const Duration(seconds: 15),
        String? requestId,
      }) async {
        ids.add(requestId);
        throw const AppError('offline');
      }

      await expectLater(draft.submit(request), throwsA(isA<AppError>()));
      expect(ids, isEmpty);
      draft.text = 'First';
      await expectLater(draft.submit(request), throwsA(isA<AppError>()));
      draft.text = 'Edited';
      await expectLater(draft.submit(request), throwsA(isA<AppError>()));
      expect(ids[0], isNot(ids[1]));
    },
  );
}
