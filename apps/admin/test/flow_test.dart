import 'dart:async';

import 'package:autocare_admin/data/admin_api.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/main.dart';
import 'package:autocare_admin/pages/accounts_pages.dart';
import 'package:autocare_admin/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Network fixture only in tests; production Store starts with no data.
class TestApi extends AdminApi {
  final calls = <String>[];
  bool fail = false;
  bool mustChange = false;
  Completer<Map<String, dynamic>>? pending;
  Map<String, dynamic> get account => {
    'id': 'a',
    'username': 'test_admin',
    'name': '测试管理员',
    'role': 'superAdmin',
    'enabled': true,
    'must_change': mustChange,
  };
  @override
  bool get hasSession => false;
  @override
  Future<Map<String, dynamic>> login(String username, String password) async =>
      {'me': account};
  @override
  Future<void> clearSession() async {}
  @override
  Future<void> changePassword(String password) async {
    await call('change_password', {'password': password});
  }

  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add(action);
    if (fail) throw const AppError('服务不可用', type: AppErrorType.server);
    if (action == 'snapshot') {
      if (pending != null) return pending!.future;
      return {
        'me': account,
        'now': DateTime.now().toUtc().toIso8601String(),
        'merchants': [],
        'orders': [],
        'tickets': [],
        'accounts': [account],
        'plans': [],
        'more': false,
        'stats': {
          'history': List.generate(
            6,
            (i) => {'month': '${i + 1}月', 'value': 0},
          ),
        },
      };
    }
    if (action == 'change_password') {
      mustChange = false;
      return {'ok': true};
    }
    if (action == 'merchant_upgrade' || action == 'refund') {
      throw const AppError('支付渠道尚未接通');
    }
    return {'ok': true};
  }
}

void main() {
  late TestApi api;
  setUp(() {
    api = TestApi();
    store = Store(api: api);
  });
  tearDown(() => store = Store());
  test('production state contains no mock records or revenue baselines', () {
    expect(store.merchants, isEmpty);
    expect(store.accounts, isEmpty);
    expect(store.orders, isEmpty);
    expect(store.loaded, isFalse);
    expect(store.me, isNull);
    expect(store.monthRevenue, 0);
  });
  test(
    'failed refresh retains last successful state and is not reported as empty',
    () async {
      await store.refresh();
      expect(store.loaded, isTrue);
      final account = store.me;
      api.fail = true;
      await expectLater(store.refresh(), throwsA(isA<AppError>()));
      expect(store.me, same(account));
      expect(store.loaded, isTrue);
    },
  );
  test(
    'pagination failure does not publish a partially loaded snapshot',
    () async {
      final paged = PagedApi();
      final state = Store(api: paged);
      await expectLater(state.refresh(), throwsA(isA<AppError>()));
      expect(paged.offsets, [0, 200]);
      expect(state.loaded, isFalse);
      expect(state.me, isNull);
    },
  );
  test('merchant phone masking accepts missing and international numbers', () {
    final m = Merchant(
      id: 'm',
      name: '门店',
      city: '',
      owner: '',
      phone: '',
      plan: PlanKind.trial,
      expiry: DateTime.now(),
      opened: DateTime.now(),
    );
    expect(m.maskedPhone, '—');
    expect(m.maskedOwner, '—');
  });
  testWidgets(
    'login has empty fields, placeholders and no demo credential disclosure',
    (t) async {
      await t.pumpWidget(const AdminApp());
      await t.pumpAndSettle();
      final fields = t.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.length, 2);
      expect(fields.every((f) => f.controller!.text.isEmpty), isTrue);
      expect(find.text('请输入用户名'), findsOneWidget);
      expect(find.textContaining('演示账号'), findsNothing);
      expect(find.byTooltip('显示密码'), findsOneWidget);
      await t.tap(find.byTooltip('显示密码'));
      await t.pump();
      expect(find.byTooltip('隐藏密码'), findsOneWidget);
    },
  );
  testWidgets(
    'real empty snapshot displays all four existing tabs and zero chart safely',
    (t) async {
      await t.pumpWidget(const AdminApp());
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).at(0), 'test_admin');
      await t.enterText(find.byType(TextField).at(1), 'TestPassword8');
      await t.tap(find.text('登录'));
      await t.pumpAndSettle();
      expect(api.calls, contains('snapshot'));
      expect(find.text('本月 MRR（元）'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await t.tap(find.byKey(ValueKey('nav-$i')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'initial password must be changed before dashboard data is requested',
    (t) async {
      api.mustChange = true;
      await t.pumpWidget(const AdminApp());
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).at(0), 'test_admin');
      await t.enterText(find.byType(TextField).at(1), 'InitialPassword8');
      await t.tap(find.text('登录'));
      await t.pumpAndSettle();
      expect(find.text('修改密码'), findsOneWidget);
      expect(api.calls, isNot(contains('snapshot')));
      await t.enterText(find.byType(TextField).at(0), 'ChangedPassword9');
      await t.enterText(find.byType(TextField).at(1), 'ChangedPassword9');
      await t.tap(find.text('确认修改'));
      await t.pumpAndSettle();
      expect(api.calls, contains('change_password'));
      expect(api.calls, contains('snapshot'));
    },
  );
  testWidgets(
    'designed async button preserves dimensions and prevents duplicate submission',
    (t) async {
      final pending = Completer<void>();
      var calls = 0;
      var loading = false;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) => SizedBox(
                width: 300,
                child: AppButton(
                  label: '保存',
                  expanded: true,
                  size: AppButtonSize.large,
                  loading: loading,
                  onPressed: () async {
                    calls++;
                    set(() => loading = true);
                    await pending.future;
                    set(() => loading = false);
                  },
                ),
              ),
            ),
          ),
        ),
      );
      final size = t.getSize(find.byType(AppButton));
      await t.tap(find.text('保存'));
      await t.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(t.getSize(find.byType(AppButton)), size);
      await t.tap(find.byType(AppButton), warnIfMissed: false);
      expect(calls, 1);
      pending.complete();
      await t.pumpAndSettle();
      expect(find.text('保存'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    },
  );
  testWidgets(
    'expired session returns to the same form without losing its draft',
    (t) async {
      await t.pumpWidget(const AdminApp());
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).at(0), 'test_admin');
      await t.enterText(find.byType(TextField).at(1), 'TestPassword8');
      await t.tap(find.text('登录'));
      await t.pumpAndSettle();
      final context = t.element(find.text('本月 MRR（元）'));
      unawaited(go<void>(context, const AccountEditPage()));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField).at(0), '未保存的账号草稿');
      authExpired.value++;
      await t.pumpAndSettle();
      expect(find.text('汽美管家 · 运营后台'), findsOneWidget);
      await t.enterText(find.byType(TextField).at(0), 'test_admin');
      await t.enterText(find.byType(TextField).at(1), 'TestPassword8');
      await t.tap(find.text('登录'));
      await t.pumpAndSettle();
      expect(find.text('新增运营账号'), findsOneWidget);
      expect(find.text('未保存的账号草稿'), findsOneWidget);
    },
  );
  testWidgets(
    'failed destructive confirmation stays open and blocks cancellation during submission',
    (t) async {
      final pending = Completer<void>();
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: AppButton(
                label: '执行',
                onPressed: () {
                  unawaited(
                    showAppDialog(
                      context,
                      title: '确认操作',
                      message: '测试',
                      onConfirm: () => pending.future,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('执行'));
      await t.pumpAndSettle();
      await t.tap(find.text('确认'));
      await t.pump();
      await t.tap(find.text('取消'), warnIfMissed: false);
      await t.pump();
      expect(find.text('确认操作'), findsOneWidget);
      pending.completeError(const AppError('提交失败'));
      await t.pumpAndSettle();
      expect(find.text('确认操作'), findsOneWidget);
      expect(find.text('提交失败'), findsOneWidget);
    },
  );
}

class PagedApi extends TestApi {
  final offsets = <int>[];
  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    offsets.add(values['offset'] as int);
    if (values['offset'] == 200) {
      throw const AppError('second page unavailable');
    }
    return {...await super.call(action, values), 'more': true};
  }
}
