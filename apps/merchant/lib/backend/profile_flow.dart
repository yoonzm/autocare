import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import 'merchant_api.dart';
import 'registration_draft.dart';
import 'store_profile.dart';

/// 「我的 · 编辑资料」：保存当前登录人的姓名与邮箱。校验和写入都在云函数 `profile_update`，
/// 这里只采集输入、调用并在成功后返回上一页。
///
/// TODO: 头像上传依赖图片存储接口（预期后端：profile_avatar_upload），尚未接通；
/// 手机号更换沿用「账号与安全 · 更换手机号」，本页不改。
class ProfileFlow {
  /// 保存成功后通知「我的」页重新读取资料。
  static final changed = ValueNotifier<int>(0);

  static Future<void> save(BuildContext context) async {
    final name = RegistrationDraft.get('ProfileEdit', '您的姓名').trim();
    final email = RegistrationDraft.get('ProfileEdit', '用于接收账单和发票').trim();
    if (name.isEmpty) {
      AppToast.show(context, '请填写姓名');
      return;
    }
    try {
      await merchantApi.updateProfile(name: name, email: email);
      storeProfile.apply(await merchantApi.getStore());
      changed.value++;
      RegistrationDraft.clearRoute('ProfileEdit');
      // 保存后返回「我的」，不再打开新页面。
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) AppToast.error(context, e);
    }
  }
}
