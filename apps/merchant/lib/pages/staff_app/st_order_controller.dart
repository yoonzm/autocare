import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../backend/data_snapshot.dart';
import '../../backend/hold_store.dart';
import '../../backend/merchant_api.dart';

/// 一次员工开单的输入、估价与提交。价格、权限及真实挂单写入仍由服务端决定。
class StOrderController extends ChangeNotifier {
  final Map<String, dynamic> info;
  final Set<String> selected = {};
  String note = '';
  Map<String, dynamic>? quote;
  AppError? quoteError;
  bool quoting = false, busy = false, disposed = false, submitted = false;
  bool _uncertain = false;
  int _seq = 0;
  String? _intent, _requestId;

  StOrderController(Map<String, dynamic> info) : info = dataSnapshot(info);
  List<Map<String, dynamic>> get lines => [
    for (final id in selected) {'service_id': id, 'qty': 1},
  ];

  Future<void> toggle(String id) async {
    if (busy || disposed || submitted) return;
    selected.contains(id) ? selected.remove(id) : selected.add(id);
    await refreshQuote();
  }

  Future<void> refreshQuote() async {
    if (disposed || busy) return;
    final seq = ++_seq;
    quote = null;
    quoteError = null;
    quoting = selected.isNotEmpty;
    notifyListeners();
    if (!quoting) return;
    try {
      final result = await merchantApi.staffWork('staff_order_quote', {
        'member_id': info['id'],
        'lines': lines,
      });
      if (disposed || seq != _seq) return;
      quote = dataSnapshot(result);
    } catch (e) {
      if (disposed || seq != _seq) return;
      quoteError = AppError.from(e);
    } finally {
      if (!disposed && seq == _seq) {
        quoting = false;
        notifyListeners();
      }
    }
  }

  Future<bool> submit() async {
    if (disposed || busy || submitted) return false;
    if (_uncertain) throw const AppError('提交结果未确认，请先联系前台核对，避免重复开单');
    if (selected.isEmpty) throw const AppError('请先选择服务项目');
    if (quoting) throw const AppError('正在读取估价，请稍后提交');
    if (quote == null || quoteError != null) throw const AppError('请先重试读取估价');
    final values = dataSnapshot({
      'member_id': info['id'],
      'lines': lines,
      'plate': info['plate'] ?? '',
      'note': note,
    });
    final intent = jsonEncode(values);
    if (_intent != intent) {
      _intent = intent;
      _requestId = MerchantApi.newRequestId();
    }
    busy = true;
    notifyListeners();
    try {
      await merchantApi.submitStaffOrder(values, requestId: _requestId);
      submitted = true;
      HoldStore.reset();
      return true;
    } catch (e) {
      final error = AppError.from(e);
      // TODO: staff_order_submit 尚未在事务内消费请求标识。服务端补齐幂等前，
      // 网络/超时/服务异常可能已写入，当前表单不盲目重试；不能宣称请求头已保证去重。
      if (error.retryable) {
        _uncertain = true;
        throw const AppError('提交结果未确认，请先联系前台核对，避免重复开单');
      }
      rethrow;
    } finally {
      busy = false;
      if (!disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    disposed = true;
    _seq++;
    super.dispose();
  }
}
