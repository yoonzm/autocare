import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../kit/upload_gallery.dart';
import 'merchant_api.dart';
import 'store_context.dart';

/// 当前会话归属由云函数确认。客户端仅传业务目标，不提供门店/员工身份。
class MediaApi {
  final MerchantApi api;
  final int _epoch = StoreContext.epoch;
  final String prefix;
  final String? taskId;
  MediaApi.store(this.api) : prefix = 'store_media', taskId = null;
  MediaApi.task(this.api, this.taskId) : prefix = 'staff_task_photo';
  Map<String, dynamic> _body(String action) {
    if (_epoch != StoreContext.epoch) throw const AppError('门店已切换，请重新打开图片页面');
    return {
      'action': '${prefix}_$action',
      if (taskId != null) 'target_id': taskId,
    };
  }

  UploadRecord _record(Map<String, dynamic> row) =>
      UploadRecord(row['id'] as String, NetworkImage(row['url'] as String));
  Future<List<UploadRecord>> load() async {
    final r = await api.invoke(_body('list'));
    return [
      for (final row in r['items'] as List)
        _record(Map<String, dynamic>.from(row)),
    ];
  }

  Future<UploadRecord> upload(Uint8List bytes, String id) async {
    final uuid =
        '${id.substring(0, 8)}-${id.substring(8, 12)}-${id.substring(12, 16)}-${id.substring(16, 20)}-${id.substring(20)}';
    final r = await api.invoke(
      {..._body('upload'), 'data': base64Encode(bytes)},
      requestId: uuid,
      timeout: const Duration(seconds: 60),
    );
    return _record(Map<String, dynamic>.from(r['item']));
  }

  Future<void> discard(String id) async {
    final uuid =
        '${id.substring(0, 8)}-${id.substring(8, 12)}-${id.substring(12, 16)}-${id.substring(16, 20)}-${id.substring(20)}';
    await api.invoke({..._body('remove'), 'id': uuid});
  }

  Future<void> remove(UploadRecord record) async {
    await api.invoke({..._body('remove'), 'id': record.id});
  }

  Future<UploadRecord> refresh(UploadRecord record) async =>
      (await load()).firstWhere((r) => r.id == record.id);
}
