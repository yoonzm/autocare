import 'package:flutter/foundation.dart';

/// 新增门店（临时 mock）：只在本机内存里保存“新增的演示门店”。
///
/// 后端目前一个账号只有一家真实门店（见切换门店弹层读取的门店列表）；演示门店不参与任何数据读写，
/// 不能切换过去，只是让“新增门店”流程可以走通和浏览。
///
/// TODO: 新增门店需要后端支持——按套餐限制数量，创建时初始化默认营业时间和工位，
/// 预期云函数：store_create；跨门店切换：store_switch（所有读写按当前门店隔离、清理各类缓存）。
class MockStores {
  MockStores._();

  /// 专业版最多 3 家（设计稿 StoreSwitch / StoreAdd 的文案）。
  static const max = 3;

  /// 新增的演示门店名称。
  static final extra = ValueNotifier<List<String>>(const []);

  /// 真实门店数量（切换门店弹层读到列表后记下；还没读到时按 1 家算）。
  static int realCount = 1;

  static int get count => realCount + extra.value.length;
  static bool get full => count >= max;
  static int get remaining => max - count;

  static void reset() {
    extra.value = const [];
    realCount = 1;
  }

  /// 校验并创建演示门店；返回错误文字，成功返回 null。创建后仍停留在当前门店。
  static String? create({
    required String name,
    required String phone,
    required String address,
  }) {
    final n = name.trim();
    if (n.isEmpty) return '请输入门店名称';
    if (n.length > 30) return '门店名称不能超过 30 个字';
    if (address.trim().isEmpty) return '请选择或输入门店地址';
    final p = phone.trim();
    if (p.isNotEmpty && !RegExp(r'^[0-9\-+ ]{6,20}$').hasMatch(p)) {
      return '请输入正确的门店电话';
    }
    if (full) return '专业版最多 $max 家门店';
    if (extra.value.contains(n)) return '已有同名门店';
    extra.value = [...extra.value, n];
    return null;
  }
}
