import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/push_service.dart';

void main() {
  test('extractPushMessageId reads top-level and nested extra fields', () {
    expect(extractPushMessageId({'message_id': 'm-1'}), 'm-1');
    expect(
      extractPushMessageId({
        'extraMap': {'message_id': 'm-2'},
      }),
      'm-2',
    );
    expect(
      extractPushMessageId({'extParameters': '{"message_id":"m-3"}'}),
      'm-3',
    );
    expect(
      extractPushMessageId({
        'userInfo': {'extParameters': '{"message_id":"m-4"}'},
      }),
      'm-4',
    );
    expect(extractPushMessageId({'extParameters': 'not-json'}), isNull);
    expect(extractPushMessageId({'title': 'hello'}), isNull);
  });
}
