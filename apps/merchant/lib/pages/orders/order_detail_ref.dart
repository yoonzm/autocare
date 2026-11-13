import '../../backend/data_snapshot.dart';
import '../../backend/merchant_api.dart';

/// 列表、会员流水向详情交付的明确目标，不保存当前订单。
class OrderDetailRef {
  final String kind, id;
  const OrderDetailRef({required this.kind, required this.id});

  Future<Map<String, dynamic>> load() async {
    if (!merchantApi.hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    if (id.isEmpty ||
        !const ['consume', 'package', 'recharge', 'refund'].contains(kind)) {
      throw const AppError('请先选择订单', type: AppErrorType.notFound);
    }
    // 现有列表协议的 refund 仅给原记录 ID，没有原类型字段。
    // 只在消费详情明确返回不存在时读取次卡详情；权限、网络错误直接展示。
    // TODO: order_list 增加原订单类型后可直接读取，禁止按标题猜测。
    if (kind == 'refund') {
      try {
        return dataSnapshot(
          await merchantApi.orderCenter('detail', {
            'type': 'consume',
            'id': id,
          }),
        );
      } catch (e) {
        if (AppError.from(e).type != AppErrorType.notFound) rethrow;
        return dataSnapshot(
          await merchantApi.orderCenter('detail', {
            'type': 'package',
            'id': id,
          }),
        );
      }
    }
    return dataSnapshot(
      await merchantApi.orderCenter('detail', {'type': kind, 'id': id}),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is OrderDetailRef && other.kind == kind && other.id == id;
  @override
  int get hashCode => Object.hash(kind, id);
}

class OrderFilters {
  final int type, method, status;
  final String operatorName;
  const OrderFilters({
    this.type = 0,
    this.method = 0,
    this.status = 0,
    this.operatorName = '',
  });
}
