import 'package:flutter/material.dart';

import '../../kit/async_kit.dart';
import '../orders/order_detail_ref.dart';
import '../staff_app/task_route_data.dart';
import '../../routes.dart' show openRoute;

/// 根据服务端 `inbox_target` 返回的白名单目标跳转对应业务页。
void openInboxTarget(BuildContext context, Map<String, dynamic> target) {
  switch (target['type']) {
    case 'holds':
      openRoute(context, 'HoldList', arguments: 3);
    case 'order':
      openRoute(
        context,
        'OrderDetail',
        arguments: OrderDetailRef(kind: 'consume', id: '${target['id']}'),
      );
    case 'task':
      openRoute(
        context,
        'StTaskDetail',
        arguments: TaskRouteData(taskId: '${target['id']}'),
      );
    case 'arrivals':
      openRoute(context, 'StArrivals');
    case 'performance':
      openRoute(context, 'StPerf');
    case 'profile':
      openRoute(context, 'StMine');
    case 'none':
      break;
    default:
      AppToast.show(context, '${target['message'] ?? '该业务已不可访问'}');
  }
}
