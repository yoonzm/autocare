import 'dart:convert';
import 'dart:typed_data';

import 'package:autocare_merchant/backend/media_api.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:flutter_test/flutter_test.dart';

class _Api extends MerchantApi {
  final calls = <Map<String, dynamic>>[];
  final ids = <String?>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    String? requestId,
  }) async {
    calls.add(body);
    ids.add(requestId);
    final item = {
      'id': requestId ?? 'photo',
      'url': 'https://example.test/image',
    };
    if (body['action'].toString().endsWith('_list')) {
      return {
        'items': [item],
      };
    }
    return {'item': item, 'ok': true};
  }
}

void main() {
  test('施工照片绑定明确任务，重试和移除使用同一UUID，不传门店身份', () async {
    final api = _Api(), bytes = Uint8List.fromList([1, 2, 3]);
    final media = MediaApi.task(api, 'task');
    final id = MerchantApi.newRequestId();
    final saved = await media.upload(bytes, id);
    await media.upload(bytes, id);
    expect(api.ids[0], api.ids[1]);
    expect(
      api.ids[0],
      matches(
        RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
        ),
      ),
    );
    expect(api.calls.first, {
      'action': 'staff_task_photo_upload',
      'target_id': 'task',
      'data': base64Encode(bytes),
    });
    await media.discard(id);
    expect(api.calls.last['id'], saved.id);
    await media.remove(saved);
    expect(api.calls.last['id'], saved.id);
  });
  test('门店图片由服务端会话决定门店，读取转换签名图片', () async {
    final api = _Api();
    final media = MediaApi.store(api);
    final items = await media.load();
    expect(api.calls.single, {'action': 'store_media_list'});
    expect(items.single.id, 'photo');
  });
}
