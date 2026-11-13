import 'dart:convert';
import 'dart:typed_data';

import 'merchant_api.dart';

const feedbackTypes = ['功能建议', '问题报告', '账号与付费', '其他'];
typedef FeedbackRequest = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> body, {
  Duration timeout,
  String? requestId,
});

class FeedbackImage {
  final Uint8List bytes;
  String? uploadedId;
  FeedbackImage(this.bytes);
}

/// 单份反馈表单的输入、附件上传结果及重试编号，由页面持有。
class FeedbackDraft {
  int type = 0;
  String text = '', contact = '';
  final images = List<FeedbackImage?>.filled(3, null);
  bool submitted = false;
  String? _payload, _requestId;
  bool get dirty =>
      type != 0 ||
      text.isNotEmpty ||
      contact.isNotEmpty ||
      images.any((i) => i != null);
  String? get problem => text.trim().isEmpty
      ? '请填写问题描述'
      : text.trim().runes.length > 5000
      ? '问题描述不能超过 5000 字'
      : contact.trim().runes.length > 200
      ? '联系方式不能超过 200 字'
      : null;

  Future<String> submit(FeedbackRequest request) async {
    if (submitted) throw const AppError('反馈已提交');
    if (problem != null) throw AppError(problem!);
    for (final image in images.whereType<FeedbackImage>()) {
      if (image.uploadedId != null) continue;
      final result = await request({
        'action': 'support_upload',
        'data': base64Encode(image.bytes),
      }, timeout: const Duration(seconds: 60));
      final id = result['id'];
      if (id is! String || id.isEmpty) throw const AppError('截图上传未完成，请重试');
      image.uploadedId = id;
    }
    final body = <String, dynamic>{
      'action': 'support_create',
      'category': feedbackTypes[type],
      'text': text.trim(),
      'contact': contact.trim(),
      'attachments': images
          .whereType<FeedbackImage>()
          .map((i) => i.uploadedId!)
          .toList(),
    };
    final signature = jsonEncode(body);
    if (_payload != signature) {
      _payload = signature;
      _requestId = MerchantApi.newRequestId();
    }
    final result = await request(
      body,
      requestId: _requestId,
      timeout: const Duration(seconds: 15),
    );
    final id = result['id'];
    if (id is! String || id.isEmpty) throw const AppError('未确认提交结果，请重试');
    submitted = true;
    return id;
  }
}

/// 登录失效时保存的只读副本；恢复时重新创建表单，不共享正在编辑的对象。
class FeedbackSnapshot {
  final int _type;
  final String _text, _contact;
  final String? _payload, _requestId;
  final List<({Uint8List bytes, String? uploadedId})?> _images;
  FeedbackSnapshot.capture(FeedbackDraft draft)
    : _type = draft.type,
      _text = draft.text,
      _contact = draft.contact,
      _payload = draft._payload,
      _requestId = draft._requestId,
      _images = List.unmodifiable(
        draft.images.map(
          (image) => image == null
              ? null
              : (
                  bytes: Uint8List.fromList(image.bytes).asUnmodifiableView(),
                  uploadedId: image.uploadedId,
                ),
        ),
      );
  FeedbackDraft restore() {
    final draft = FeedbackDraft()
      ..type = _type
      ..text = _text
      ..contact = _contact
      .._payload = _payload
      .._requestId = _requestId;
    for (var i = 0; i < _images.length; i++) {
      final image = _images[i];
      if (image != null) {
        draft.images[i] = FeedbackImage(Uint8List.fromList(image.bytes))
          ..uploadedId = image.uploadedId;
      }
    }
    return draft;
  }
}

/// App 实例持有的登录恢复箱；只在会话失效时保存快照，同账号只能领取一次。
class FeedbackRecovery {
  String? _owner;
  FeedbackSnapshot? _snapshot;
  void save(String? owner, FeedbackDraft draft) {
    if (owner == null || owner.isEmpty || !draft.dirty || draft.submitted) {
      return;
    }
    _owner = owner;
    _snapshot = FeedbackSnapshot.capture(draft);
  }

  FeedbackDraft? take(String? owner) {
    if (owner == null || owner.isEmpty) return null;
    final snapshot = _snapshot, previousOwner = _owner;
    clear();
    return owner == previousOwner ? snapshot?.restore() : null;
  }

  void clear() {
    _owner = null;
    _snapshot = null;
  }
}
