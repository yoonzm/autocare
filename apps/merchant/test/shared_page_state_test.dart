import 'dart:async';

import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/pickers.dart';
import 'package:autocare_merchant/pages/staff/staff_live.dart';
import 'package:autocare_merchant/pages/staff_app/st_auth_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_identity_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_msgs_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_front_home_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

class _Api extends BookingApi {
  Completer<Map<String, dynamic>>? selection, join, readAll;
  Object? signOutError, queueError;
  int signOutCalls = 0;
  @override
  Future<Map<String, dynamic>> identity(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    final pending = action == 'select'
        ? selection
        : action == 'join'
        ? join
        : null;
    if (pending != null) {
      calls.add({'action': 'identity_$action', ...values});
      return pending.future;
    }
    return super.identity(action, values);
  }

  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) {
    if (action == 'staff_messages_read' && readAll != null) {
      calls.add({'action': action, ...values});
      return readAll!.future;
    }
    if (action == 'staff_cash_queue') {
      calls.add({'action': action});
      return queueError != null
          ? Future.error(queueError!)
          : Future.value({'items': []});
    }
    return super.staffWork(action, values);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    if (signOutError != null) throw signOutError!;
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = merchantApi;
    merchantApi = api = _Api();
    Access.clear();
  });
  tearDown(() {
    merchantApi = original;
    Access.clear();
  });
  int calls(String action) =>
      api.calls.where((v) => v['action'] == action).length;

  testWidgets('身份列表随页面持有深快照，销毁后的选择响应不能改会话或导航', (t) async {
    phone(t);
    api.selection = Completer();
    final source = [Map<String, dynamic>.from(api.identities[2])];
    final page = StIdentityLivePage(items: source, phone: '13911112222');
    source.single['store_name'] = '被外部修改的门店';
    await t.pumpWidget(MaterialApp(home: page));
    await t.pumpAndSettle();
    expect(find.text('被外部修改的门店'), findsNothing);
    expect(find.textContaining('139 **** 2222 在以下门店有身份'), findsOneWidget);
    await t.tap(find.text('悦驰汽车装饰 · 松江店'));
    await t.pump();
    await t.pumpWidget(const MaterialApp(home: Text('新页面')));
    api.selection!.complete({'ok': true});
    await t.pumpAndSettle();
    expect(Access.role, 'owner');
    expect(calls('identity_context'), 0);
    expect(find.text('新页面'), findsOneWidget);
  });

  testWidgets('加入确认提交锁属于页面实例，失败后可重试', (t) async {
    phone(t);
    Access.apply({...api.identityCtx, 'status': 'pending'});
    api.join = Completer();
    await t.pumpWidget(const MaterialApp(home: StAuthLivePage()));
    await t.pumpAndSettle();
    await t.tap(find.text('确认加入并进入工作台'));
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    await t.pumpWidget(
      const MaterialApp(home: StAuthLivePage(key: ValueKey('other'))),
    );
    await t.pump();
    await t.tap(find.text('确认加入并进入工作台'));
    await t.pump();
    expect(calls('identity_join'), 2);
    api.join!.completeError(const AppError.timeout());
    await t.pumpAndSettle();
    expect(find.text('确认加入并进入工作台'), findsOneWidget);
    expect(calls('identity_context'), 0);
    api.join = Completer();
    await t.tap(find.text('确认加入并进入工作台'));
    await t.pump();
    expect(calls('identity_join'), 3);
    await t.pumpWidget(const SizedBox());
    api.join!.complete({'ok': true});
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
    expect(calls('identity_context'), 0);
    expect(t.takeException(), isNull);
  });

  testWidgets('全部已读防重复并显示loading，不同消息页不共享提交键', (t) async {
    phone(t);
    api.readAll = Completer();
    await t.pumpWidget(
      const MaterialApp(home: StMsgsTemplate(d: {'items': []})),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('全部已读'));
    await t.pump();
    expect(find.byType(AppSpinner), findsOneWidget);
    await t.tap(find.text('全部已读'), warnIfMissed: false);
    expect(calls('staff_messages_read'), 1);
    await t.pumpWidget(
      const MaterialApp(
        home: StMsgsTemplate(key: ValueKey('second'), d: {'items': []}),
      ),
    );
    await t.pump();
    await t.tap(find.text('全部已读'));
    await t.pump();
    expect(calls('staff_messages_read'), 2);
    api.readAll!.completeError(const AppError.timeout());
    await t.pumpAndSettle();
    expect(find.text('全部已读'), findsOneWidget);
  });

  testWidgets('员工数据读取期间收到刷新，失败解锁后仍会重新读取', (t) async {
    phone(t);
    final first = Completer<Map<String, dynamic>>();
    final refresh = ValueNotifier(0);
    addTearDown(refresh.dispose);
    var reads = 0;
    await t.pumpWidget(
      MaterialApp(
        home: StaffLiveHost(
          needsId: false,
          refresh: refresh,
          load: (_) =>
              ++reads == 1 ? first.future : Future.value({'name': '更新数据'}),
          builder: (_, data) {
            expect(() => data['name'] = '外部修改', throwsUnsupportedError);
            return Text('${data['name']}');
          },
        ),
      ),
    );
    refresh.value++;
    first.completeError(const AppError.timeout());
    await t.pumpAndSettle();
    expect(reads, 2);
    expect(find.text('更新数据'), findsOneWidget);
  });

  testWidgets('前台已授权的队列读取失败不能伪装为空，可重试', (t) async {
    phone(t);
    Access.apply({
      ...api.identityCtx,
      'role': 'cashier',
      'caps': {'cash_queue': true},
    });
    api.queueError = const AppError.timeout();
    await t.pumpWidget(const MaterialApp(home: StFrontHomeLivePage()));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    api.queueError = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsNothing);
    expect(find.byType(ErrorView), findsNothing);
    expect(calls('staff_cash_queue'), 2);
  });

  testWidgets('退出接口失败停留原页面，不清除当前身份冒充成功', (t) async {
    phone(t);
    Access.apply(api.identityCtx);
    api.signOutError = const AppError.timeout();
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () => AccessFlow.signOut(ctx),
              child: const Text('退出'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('退出'));
    await t.pumpAndSettle();
    expect(api.signOutCalls, 1);
    expect(Access.role, 'technician');
    expect(find.text('退出'), findsOneWidget);
    expect(find.textContaining('请求超时'), findsWidgets);
  });

  testWidgets('通用日期选择使用当前日历，不再固定历史设计日期', (t) async {
    phone(t);
    final today = DateTime.now();
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (ctx) => Scaffold(
            body: TextButton(
              onPressed: () => pickDate(
                ctx,
                '选择日期',
                birthday: false,
                current: '',
                fullFormat: true,
              ),
              child: const Text('日期'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('日期'));
    await t.pumpAndSettle();
    expect(
      find.textContaining('${today.year} 年 ${today.month} 月 ${today.day} 日'),
      findsOneWidget,
    );
    expect(find.textContaining('今天'), findsOneWidget);
  });
}
