import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/inbox_store.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/messages/inbox_page.dart';
import 'package:autocare_merchant/widgets/inbox_bell.dart';

import 'members_test.dart' show MemberFakeApi, phone;

Map<String, dynamic> message(String id, {String? read}) => {
  'id': id,
  'kind': 'system',
  'title': '通知 $id',
  'body': '车辆已完工，请核对后收银',
  'created_at': '2026-11-25T10:00:00Z',
  'read_at': read,
};

class InboxApi extends MemberFakeApi {
  final requests = <Map<String, dynamic>>[];
  Object? inboxError, readError, moreError, unreadError;
  Completer<Map<String, dynamic>>? pendingUnread, pendingList;
  int unread = 2;
  String target = 'none';
  @override
  Future<Map<String, dynamic>> inbox(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    requests.add({'action': action, ...values});
    if (action == 'unread') {
      if (pendingUnread != null) return pendingUnread!.future;
      if (unreadError != null) throw unreadError!;
      return {'unread': unread};
    }
    if (action == 'read') {
      if (readError != null) throw readError!;
      unread = values['before'] == null ? 1 : 0;
      return {'unread': unread};
    }
    if (action == 'target') return {'type': target, 'message': '任务已转交，无法查看'};
    if (pendingList != null) return pendingList!.future;
    if (inboxError != null) throw inboxError!;
    if (values['cursor'] != null && moreError != null) throw moreError!;
    return {
      'items': [message(values['cursor'] == null ? '1' : '2')],
      'unread': unread,
      'snapshot_at': '2026-11-25T10:00:01Z',
      'next': values['cursor'] == null
          ? {'id': '1', 'at': '2026-11-25T10:00:00Z'}
          : null,
    };
  }
}

void main() {
  late MerchantApi old;
  late InboxApi api;
  late InboxStore store;
  setUp(() {
    old = merchantApi;
    merchantApi = api = InboxApi();
    Access.apply({
      'store_id': 'shop',
      'role': 'cashier',
      'caps': {'cashier': true},
    });
    store = InboxStore();
  });
  tearDown(() {
    store.dispose();
    merchantApi = old;
    Access.clear();
  });
  Future<void> show(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(
      InboxScope(
        store: store,
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('分页合并、单条已读与全部已读都真实提交，读取截止时间保留', (t) async {
    await show(t);
    expect(find.text('通知 1'), findsOneWidget);
    expect(store.unread, 2);
    await t.tap(find.text('加载更多'));
    await t.pumpAndSettle();
    expect(find.text('通知 2'), findsOneWidget);
    expect(api.requests.where((r) => r['cursor'] != null).single['cursor'], {
      'id': '1',
      'at': '2026-11-25T10:00:00Z',
    });
    await t.tap(find.text('通知 1'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('unread-1')), findsNothing);
    expect(store.unread, 1);
    await t.tap(find.text('全部已读'));
    await t.pumpAndSettle();
    expect(store.unread, 0);
    expect(find.byKey(const ValueKey('unread-2')), findsNothing);
    expect(
      api.requests.where((r) => r['before'] != null).single['before'],
      '2026-11-25T10:00:01Z',
    );
  });
  testWidgets('已读失败保留未读，业务失效明确提示', (t) async {
    await show(t);
    api.readError = const AppError('操作失败');
    await t.tap(find.text('通知 1'));
    await t.pumpAndSettle();
    expect(find.byKey(const ValueKey('unread-1')), findsOneWidget);
    expect(api.requests.where((r) => r['action'] == 'target'), isEmpty);
    api.readError = null;
    api.target = 'unavailable';
    await t.tap(find.text('通知 1'));
    await t.pumpAndSettle();
    expect(find.text('任务已转交，无法查看'), findsWidgets);
  });
  testWidgets('读取失败可重试，分页失败保留已有消息', (t) async {
    api.inboxError = const AppError.timeout();
    await show(t);
    expect(find.text('请求超时'), findsOneWidget);
    api.inboxError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    api.moreError = const AppError('加载失败');
    await t.tap(find.text('加载更多'));
    await t.pumpAndSettle();
    expect(find.text('通知 1'), findsOneWidget);
    expect(find.text('通知 2'), findsNothing);
    api.moreError = null;
    await t.tap(find.text('加载更多'));
    await t.pumpAndSettle();
    expect(find.text('通知 2'), findsOneWidget);
    await t.pump(const Duration(seconds: 1));
  });
  testWidgets('身份切换丢弃晚到列表和未读响应', (t) async {
    final stale = Completer<Map<String, dynamic>>();
    api.pendingUnread = stale;
    store.start();
    final staleList = Completer<Map<String, dynamic>>();
    api.pendingList = staleList;
    phone(t);
    await t.pumpWidget(
      InboxScope(
        store: store,
        child: const MaterialApp(home: InboxPage()),
      ),
    );
    await t.pump();
    api.pendingUnread = null;
    api.pendingList = null;
    api.unread = 0;
    Access.apply({'store_id': 'shop2', 'role': 'owner'});
    await t.pumpAndSettle();
    stale.complete({'unread': 99});
    staleList.complete({
      'items': [message('旧店')],
      'unread': 99,
    });
    await t.pumpAndSettle();
    expect(store.unread, 0);
    expect(find.text('通知 旧店'), findsNothing);
    store.didChangeAppLifecycleState(AppLifecycleState.paused);
  });
  testWidgets('只在前台轮询，回到前台刷新，失败保留上次未读数', (t) async {
    store.start();
    await t.pump();
    expect(store.unread, 2);
    api.unread = 3;
    await t.pump(const Duration(seconds: 30));
    await t.pump();
    expect(store.unread, 3);
    store.didChangeAppLifecycleState(AppLifecycleState.paused);
    final n = api.requests.length;
    await t.pump(const Duration(seconds: 60));
    expect(api.requests.length, n);
    api.unreadError = const AppError.timeout();
    store.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await t.pump();
    expect(store.error, isNotNull);
    expect(store.unread, 3);
    api.unreadError = null;
    api.unread = 0;
    await store.refresh();
    expect(store.unread, 0);
    store.didChangeAppLifecycleState(AppLifecycleState.paused);
  });
  testWidgets('铃铛显示未读提示并进入统一消息页', (t) async {
    phone(t);
    store.acceptUnread(3);
    await t.pumpWidget(
      InboxScope(
        store: store,
        child: const MaterialApp(home: Scaffold(body: InboxBell())),
      ),
    );
    expect(find.bySemanticsLabel('消息，3 条未读'), findsOneWidget);
    await t.tap(find.byType(IconButton));
    await t.pumpAndSettle();
    expect(find.byType(InboxPage), findsOneWidget);
  });
}
