import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/inventory/inventory_management_page.dart';

import 'members_test.dart' show MemberFakeApi, phone;

class _Api extends MemberFakeApi {
  final calls = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration? timeout,
    String? requestId,
  }) async {
    calls.add(body);
    if (body['action'] == 'inventory_options') {
      return {
        'categories': [
          {'id': 'c', 'name': '真实分类', 'count': 2},
        ],
        'suppliers': [],
        'settings': {
          'revision': 0,
          'low_enabled': true,
          'expiry_enabled': true,
          'expiry_days': 15,
          'home_enabled': true,
          'message_enabled': false,
        },
      };
    }
    if (body['action'] == 'inventory_documents') {
      return {
        'items': [
          {
            'id': '12345678-aaaa-bbbb-cccc-111111111111',
            'kind': 'in',
            'status': 'posted',
            'total': 25.5,
            'created_at': '2026-11-08',
            'payload': {
              'supplier': '真实供应商',
              'lines': [
                {'id': 'p', 'quantity': 2.5, 'cost': 10},
              ],
            },
          },
        ],
      };
    }
    if (body['action'] == 'inventory_document_get') {
      return {
        'item': {
          'id': body['id'],
          'kind': 'in',
          'status': 'posted',
          'can_void': true,
          'total': 25.5,
          'created_at': '2026-11-08',
          'payload': {
            'supplier': '真实供应商',
            'payment': '现金',
            'snapshots': [
              {'id': 'p', 'name': '真实耗材', 'stock': 0, 'unit': '升'},
            ],
            'lines': [
              {'id': 'p', 'quantity': 2.5, 'cost': 10},
            ],
          },
          'movements': [],
        },
      };
    }
    if (body['action'] == 'inventory_settings_save') {
      return {'item': body['payload']};
    }
    return super.invoke(body, requestId: requestId);
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
  });
  tearDown(() => merchantApi = original);
  Future<void> open(WidgetTester t, String mode, {String? id}) async {
    phone(t);
    final boundary = GlobalKey();
    await t.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: InventoryManagementPage(mode: mode, documentId: id),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    const output = String.fromEnvironment('INVENTORY_RENDER');
    if (output.isNotEmpty) {
      await t.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()
                    as RenderRepaintBoundary)
                .toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory(output).create(recursive: true);
        await File('$output/management-$mode.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  }

  testWidgets('商品分类只显示后端分类与真实数量', (t) async {
    await open(t, 'categories');
    expect(find.text('真实分类'), findsOneWidget);
    expect(find.text('2 个商品'), findsOneWidget);
    expect(find.text('42 个商品'), findsNothing);
    expect(find.text('贴膜'), findsNothing);
    expect(find.text('商品分类'), findsOneWidget);
  });
  testWidgets('库存单据列表与详情使用真实单据、商品和金额', (t) async {
    await open(t, 'docs');
    expect(find.text('RK-12345678'), findsOneWidget);
    expect(find.text('¥25.50'), findsOneWidget);
    expect(find.textContaining('蓝盾膜业'), findsNothing);
    await t.tap(find.text('RK-12345678'));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('真实供应商'), findsOneWidget);
    expect(find.text('真实耗材'), findsOneWidget);
    expect(find.text('× 2.5 升'), findsOneWidget);
    expect(find.textContaining('窗膜'), findsNothing);
  });
  testWidgets('预警设置保存服务端字段、未接通知不会假装开启', (t) async {
    await open(t, 'settings');
    expect(find.text('库存预警设置'), findsOneWidget);
    for (final days in ['7 天', '15 天', '30 天', '60 天']) {
      await t.ensureVisible(find.text(days));
      await t.tap(find.text(days));
      await t.pump();
      for (final channel in ['首页卡片', 'App 消息推送', '微信服务通知']) {
        expect(find.text(channel), findsOneWidget, reason: '选择过期阈值不能按文案过滤通知渠道');
      }
    }
    await t.ensureVisible(find.text('保存'));
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(
      api.calls
          .where((c) => c['action'] == 'inventory_settings_save')
          .single['payload']['expiry_days'],
      60,
    );
  });
}
