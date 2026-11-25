import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSel;
import 'package:autocare_merchant/kit/single_selection.dart';
import 'package:autocare_merchant/pages/inventory/inventory_live_page.dart';
import 'package:autocare_merchant/pages/inventory/inventory_management_page.dart';
import 'package:autocare_merchant/pages/inventory/inventory_management_controller.dart';
import 'package:autocare_merchant/pages/inventory/inventory_controller.dart'
    show InventoryController;

import 'members_test.dart' show MemberFakeApi, phone;

Map<String, dynamic> product(String id) => {
  'id': id,
  'name': '商品$id',
  'unit': '瓶',
  'stock': 3,
  'safe': 1,
  'cost': 10,
  'version': 1,
  'batches': [],
  'movements': [],
};

class InventoryStateApi extends MemberFakeApi {
  final writes = <Map<String, dynamic>>[];
  Completer<void>? saveGate;
  Completer<Map<String, dynamic>>? oldDocument;

  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    if (body['action'] == 'inventory_get') return {'item': product(body['id'])};
    if (body['action'] == 'inventory_void') {
      writes.add({
        'requestId': requestId,
        ...jsonDecode(jsonEncode(body)) as Map<String, dynamic>,
      });
      await saveGate?.future;
      throw const AppError('服务端拒绝保存');
    }
    if (body['action'] == 'inventory_document_get') {
      if (body['id'] == 'old' && oldDocument != null) {
        return oldDocument!.future;
      }
      return document('${body['id']}');
    }
    if (body['action'] == 'inventory_quote') {
      return {
        'item': {'total': 10, 'subtotal': 10},
      };
    }
    return super.invoke(body, requestId: requestId);
  }

  Map<String, dynamic> document(String id) => {
    'item': {
      'id': '$id-12345678',
      'kind': 'in',
      'status': 'posted',
      'can_void': true,
      'total': 10,
      'payload': {'supplier': '供应商$id', 'lines': [], 'snapshots': []},
      'movements': [],
    },
  };
}

void main() {
  late MerchantApi original;
  late InventoryStateApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = InventoryStateApi();
  });
  tearDown(() => merchantApi = original);

  testWidgets('单选值受调用方控制，实例隔离并能恢复取消后的选择', (t) async {
    final values = ValueNotifier([0, 1]);
    addTearDown(values.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: values,
          builder: (_, current, _) => Column(
            children: [
              for (var page = 0; page < 2; page++)
                SingleSelection(
                  index: current[page],
                  onChanged: (_) {},
                  builder: (_, selection) => Row(
                    children: [
                      for (var i = 0; i < 2; i++)
                        HSel(
                          ctrl: selection,
                          index: i,
                          on: Text('$page-$i-selected'),
                          off: Text('$page-$i'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await t.tap(find.text('0-1'));
    await t.pump();
    expect(find.text('0-1-selected'), findsOneWidget);
    expect(find.text('1-1-selected'), findsOneWidget);
    // 异步选择取消后，调用方重新发出原值。
    values.value = [0, 1];
    await t.pump();
    expect(find.text('0-0-selected'), findsOneWidget);
    expect(find.text('1-1-selected'), findsOneWidget);
  });

  testWidgets('两个单据作废实例并行提交互不阻塞，失败保留字段并重用请求编号', (t) async {
    final first = InventoryManagementController('document', documentId: 'doc-1')
      ..document = {'can_void': true}
      ..voidReason = '录错数量'
      ..dirty = true;
    final second = InventoryManagementController('document', documentId: 'doc-2')
      ..document = {'can_void': true}
      ..voidReason = '其他'
      ..dirty = true;
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold();
          },
        ),
      ),
    );
    final gate = api.saveGate = Completer<void>();
    final a = first.confirmVoid(context);
    final duplicate = first.confirmVoid(context);
    final b = second.confirmVoid(context);
    expect(api.writes, hasLength(2));
    expect(api.writes.map((w) => w['payload']['reason']), ['录错数量', '其他']);
    expect(first.busy, isTrue);
    expect(second.busy, isTrue);
    gate.complete();
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await Future.wait([a, b, duplicate]);
    expect(first.dirty, isTrue);
    expect(second.dirty, isTrue);
    expect(first.voidReason, '录错数量');
    expect(first.busy, isFalse);
    expect(second.busy, isFalse);
    final retry = first.confirmVoid(context);
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await retry;
    expect(api.writes.last['requestId'], api.writes.first['requestId']);
    first.dispose();
    second.dispose();
  });

  testWidgets('复用商品详情宿主时按新 ID 读取，不沿用旧控制器', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(
        home: InventoryLivePage(mode: 'detail', productId: 'a'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('商品a'), findsOneWidget);
    await t.pumpWidget(
      const MaterialApp(
        home: InventoryLivePage(mode: 'detail', productId: 'b'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('商品b'), findsOneWidget);
    expect(find.text('商品a'), findsNothing);
  });

  testWidgets('控制器销毁后，晚到的提交失败不向当前页面显示旧错误', (t) async {
    final c = InventoryManagementController('document', documentId: 'doc-1')
      ..document = {'can_void': true};
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold(body: Text('当前页面'));
          },
        ),
      ),
    );
    final gate = api.saveGate = Completer<void>();
    final pending = c.confirmVoid(context);
    c.dispose();
    gate.complete();
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    await pending;
    expect(find.text('当前页面'), findsOneWidget);
    expect(find.text('服务端拒绝保存'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('晚到的旧单据响应不会覆盖新单据控制器', (t) async {
    phone(t);
    api.oldDocument = Completer();
    await t.pumpWidget(
      const MaterialApp(
        home: InventoryManagementPage(mode: 'document', documentId: 'old'),
      ),
    );
    await t.pump();
    await t.pumpWidget(
      const MaterialApp(
        home: InventoryManagementPage(mode: 'document', documentId: 'new'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('供应商new'), findsOneWidget);
    api.oldDocument!.complete(api.document('old'));
    await t.pumpAndSettle();
    expect(find.text('供应商new'), findsOneWidget);
    expect(find.text('供应商old'), findsNothing);
  });

  testWidgets('入库单：付款方式、同步开支等不影响金额的字段变化不清空报价，运费变化才重新报价', (t) async {
    phone(t);
    final c = InventoryController('in', [], {}, null, null)
      ..quote = {'total': 10, 'subtotal': 10};
    addTearDown(c.dispose);
    c.payload['sync_expense'] = true;
    c.changed(requote: false);
    expect(c.quote, isNotNull, reason: '同步开支不应让金额转圈');
    c.selectPayment(1);
    expect(c.quote, isNotNull, reason: '付款方式不应让金额转圈');
    c.changed();
    expect(c.quote, isNull, reason: '商品或运费变化要重新报价');
    await t.pump(const Duration(seconds: 2));
  });
}
