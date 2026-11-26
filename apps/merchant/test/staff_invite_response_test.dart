import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:flutter_test/flutter_test.dart';

class InviteApi extends MerchantApi {
  Map<String, dynamic> response = {'ok': true};
  Map<String, dynamic>? sent;

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 20),
    String? requestId,
  }) async {
    sent = body;
    return response;
  }
}

void main() {
  test('短信受理回执无需 item，不能将发送成功误报为失败', () async {
    final api = InviteApi();
    expect(await api.staff('invite', {'id': 's1', 'via': 'sms'}), {'ok': true});
    expect(api.sent, {'action': 'staff_invite', 'id': 's1', 'via': 'sms'});
  });

  test('链接邀请与员工详情继续解析 item', () async {
    final api = InviteApi()
      ..response = {
        'item': {'id': 's1', 'link': 'https://example.com/invite'},
      };
    expect(
      (await api.staff('invite', {'id': 's1'}))['link'],
      'https://example.com/invite',
    );
    api.response = {
      'item': {'id': 's1'},
    };
    expect(await api.staff('get', {'id': 's1'}), {'id': 's1'});
  });
}
