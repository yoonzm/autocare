import 'dart:async';
import 'dart:io';

import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/card_tiers_live_page.dart';
import 'package:autocare_merchant/pages/services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 前端规范（docs/frontend-guidelines.md）中加载与反馈要求的验证。

class _Api extends MerchantApi {
  final List<String> calls = [];
  final List<Object> failures = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> cards = [];
  Duration latency = Duration.zero;
  int refreshed = 0;
  bool refreshFails = false;
  @override
  bool get hasSession => true;
  @override
  Future<void> refreshAuth() async {
    refreshed++;
    if (refreshFails) throw const AppError('refresh failed');
  }

  @override
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async =>
      (autoUpgrade: true, balanceRefundable: false);

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    calls.add('list:$kind');
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failures.isNotEmpty) throw failures.removeAt(0);
    return kind == 'services' ? services : cards;
  }
}

/// 只覆写“发一次请求”，用来验证重试 / 刷新令牌 / 幂等标识的规则。
class _Net extends MerchantApi {
  final List<Object> script;
  final List<String?> requestIds = [];
  int attempts = 0;
  int refreshed = 0;
  _Net(this.script);
  @override
  Future<void> refreshAuth() async => refreshed++;
  @override
  Future<Map<String, dynamic>> performRequest(
    Map<String, dynamic> body,
    Duration timeout,
    String? requestId,
  ) async {
    requestIds.add(requestId);
    final step = script[attempts++];
    if (step is AppError) throw step;
    return step as Map<String, dynamic>;
  }
}

void main() {
  late MerchantApi original;
  setUp(() => original = merchantApi);
  tearDown(() => merchantApi = original);

  test('首页统计是只读请求：失败重试且不发送写入幂等键', () async {
    final api = _Net([
      const AppError('网络异常', type: AppErrorType.network),
      {
        'item': {'orders': 3},
      },
    ]);
    expect(await api.homeStats(), {'orders': 3});
    expect(api.attempts, 2);
    expect(api.requestIds, [null, null]);
  });

  group('统一错误类型', () {
    test('HTTP 状态映射：401 登录失效，5xx 服务异常，4xx 直接展示服务端文案', () {
      expect(AppError.fromStatus(401).type, AppErrorType.auth);
      final s = AppError.fromStatus(503);
      expect(s.type, AppErrorType.server);
      expect(s.code, 'SRV_503');
      expect(s.retryable, isTrue);
      final b = AppError.fromStatus(400, '验证码错误');
      expect(b.type, AppErrorType.business);
      expect(b.message, '验证码错误');
      expect(b.retryable, isFalse);
      // 业务失败（含 403 / 404 带服务端文案）不当成无权限 / 不存在
      expect(AppError.fromStatus(403, '当前密码错误').type, AppErrorType.business);
      expect(AppError.fromStatus(404, '该手机号尚未注册').type, AppErrorType.business);
      expect(AppError.fromStatus(403).type, AppErrorType.forbidden);
      expect(AppError.fromStatus(404).type, AppErrorType.notFound);
      expect(AppError.fromStatus(403).retryable, isFalse);
    });

    test('异常映射：超时 / 断网', () {
      expect(AppError.from(TimeoutException('x')).type, AppErrorType.timeout);
      expect(
        AppError.from(const SocketException('x')).type,
        AppErrorType.network,
      );
      expect(AppError.from(const AppError('a')).message, 'a');
      expect(AppError.from(StateError('boom')).type, AppErrorType.server);
    });

    test('Toast 时长：成功 / 信息 3s，失败 5s，带操作 8s', () {
      expect(
        AppToast.durationOf(ToastKind.success),
        const Duration(seconds: 3),
      );
      expect(AppToast.durationOf(ToastKind.info), const Duration(seconds: 3));
      expect(AppToast.durationOf(ToastKind.error), const Duration(seconds: 5));
      expect(
        AppToast.durationOf(ToastKind.error, hasAction: true),
        const Duration(seconds: 8),
      );
    });
  });

  group('网络层规则', () {
    test('读请求失败静默重试 1 次，成功则不报错', () async {
      final api = _Net([
        const AppError.network(),
        {'items': []},
      ]);
      final r = await api.invoke({'action': 'list', 'kind': 'services'});
      expect(r['items'], isEmpty);
      expect(api.attempts, 2);
    });

    test('读请求重试后仍失败才抛出', () async {
      final api = _Net([const AppError.timeout(), const AppError.timeout()]);
      await expectLater(
        api.invoke({'action': 'get_store'}),
        throwsA(isA<AppError>()),
      );
      expect(api.attempts, 2);
    });

    test('写请求不自动重试，且带幂等标识', () async {
      final api = _Net([const AppError.network()]);
      await expectLater(
        api.invoke({'action': 'save', 'kind': 'services'}),
        throwsA(isA<AppError>()),
      );
      expect(api.attempts, 1);
      expect(api.requestIds.single, isNotNull);
      expect(api.requestIds.single!.length, 32);
      // 读请求不带
      final read = _Net([
        {'items': []},
      ]);
      await read.invoke({'action': 'list', 'kind': 'cards'});
      expect(read.requestIds.single, isNull);
    });

    test('业务失败（4xx）不重试', () async {
      final api = _Net([const AppError('名称已存在')]);
      await expectLater(
        api.invoke({'action': 'list', 'kind': 'cards'}),
        throwsA(isA<AppError>()),
      );
      expect(api.attempts, 1);
    });

    test('401：先静默刷新令牌，成功则重试一次，不算登录失效', () async {
      final before = authExpired.value;
      final api = _Net([
        const AppError('过期', type: AppErrorType.auth),
        {'ok': true},
      ]);
      final r = await api.invoke({'action': 'change_password'});
      expect(r['ok'], isTrue);
      expect(api.refreshed, 1);
      expect(api.attempts, 2);
      expect(authExpired.value, before);
    });

    test('401：刷新后仍 401 才判定登录失效', () async {
      final before = authExpired.value;
      final api = _Net([
        const AppError('过期', type: AppErrorType.auth),
        const AppError('过期', type: AppErrorType.auth),
      ]);
      await expectLater(
        api.invoke({'action': 'change_password'}),
        throwsA(
          isA<AppError>().having((e) => e.type, 'type', AppErrorType.auth),
        ),
      );
      expect(authExpired.value, before + 1);
    });

    test('登录接口的 401 是密码错误，不触发刷新令牌 / 登录失效', () async {
      final before = authExpired.value;
      final api = _Net([const AppError('手机号或密码错误', type: AppErrorType.auth)]);
      await expectLater(
        api.invoke({'action': 'login_password'}),
        throwsA(isA<AppError>()),
      );
      expect(api.refreshed, 0);
      expect(authExpired.value, before);
    });
  });

  group('AsyncView 时序与状态', () {
    Widget host(
      Future<List<int>> Function() load, {
      GlobalKey<AsyncViewState<List<int>>>? key,
      void Function(List<int>)? onLoaded,
    }) => MaterialApp(
      home: Scaffold(
        body: AsyncView<List<int>>(
          key: key,
          load: load,
          isEmpty: (d) => d.isEmpty,
          skeleton: const SkeletonList(count: 2),
          empty: (_) => EmptyView.firstTime(
            title: '还没有数据',
            actionLabel: '去添加',
            onAction: () {},
          ),
          onLoaded: onLoaded,
          builder: (_, d) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [for (final i in d) Text('条目$i')],
          ),
        ),
      ),
    );

    testWidgets('快速返回（<300ms）不出现骨架', (t) async {
      await t.pumpWidget(
        host(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return [1];
        }),
      );
      await t.pump(const Duration(milliseconds: 50));
      expect(find.byType(SkeletonList), findsNothing);
      await t.pump(const Duration(milliseconds: 100));
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('条目1'), findsOneWidget);
      expect(find.byType(SkeletonList), findsNothing);
    });

    testWidgets('超过 300ms 才出骨架，出现后至少停留 500ms', (t) async {
      await t.pumpWidget(
        host(() async {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          return [1];
        }),
      );
      await t.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await t.pump(const Duration(milliseconds: 100)); // 350ms：骨架出现
      expect(find.byType(SkeletonList), findsOneWidget);
      await t.pump(
        const Duration(milliseconds: 100),
      ); // 450ms：数据已返回，但骨架还要留够 500ms
      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.text('条目1'), findsNothing);
      await t.pump(const Duration(milliseconds: 600)); // 骨架出现满 500ms
      await t.pump(const Duration(milliseconds: 300)); // 150ms 淡入
      expect(find.text('条目1'), findsOneWidget);
      expect(find.byType(SkeletonList), findsNothing);
    });

    testWidgets('失败：整页错误态 + 重试；重试中按钮 loading 且不可再点', (t) async {
      var n = 0;
      await t.pumpWidget(
        host(() async {
          n++;
          if (n == 1) throw const AppError.network();
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return [7];
        }),
      );
      await t.pumpAndSettle();
      expect(find.text('网络不太给力'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);

      await t.tap(find.text('重试'));
      await t.pump();
      // 点击后立即 loading：文字换成转圈，不能再点
      expect(find.text('重试'), findsNothing);
      expect(find.byType(AppSpinner), findsOneWidget);
      await t.pump(const Duration(milliseconds: 100));
      expect(n, 2);
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('条目7'), findsOneWidget);
    });

    testWidgets('登录失效 / 无权限不给重试，给明确的下一步', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 300,
                  child: ErrorView(
                    error: const AppError('x', type: AppErrorType.auth),
                    onRetry: () {},
                    onNext: () {},
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: ErrorView(
                    error: AppError.fromStatus(403),
                    onRetry: () {},
                    onNext: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(find.text('重试'), findsNothing);
      expect(find.text('重新登录'), findsOneWidget);
      expect(find.text('返回'), findsOneWidget);
    });

    testWidgets('空数据：说明 + 下一步动作', (t) async {
      await t.pumpWidget(host(() async => []));
      await t.pumpAndSettle();
      expect(find.text('还没有数据'), findsOneWidget);
      expect(find.text('去添加'), findsOneWidget);
    });

    testWidgets('已有数据时刷新失败：保留旧内容，只弹带重试的 Toast', (t) async {
      final key = GlobalKey<AsyncViewState<List<int>>>();
      var n = 0;
      await t.pumpWidget(
        host(() async {
          n++;
          if (n == 2) throw const AppError.timeout();
          return [n];
        }, key: key),
      );
      await t.pumpAndSettle();
      expect(find.text('条目1'), findsOneWidget);

      unawaited(key.currentState!.reload());
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      await t.pumpAndSettle();
      expect(find.text('条目1'), findsOneWidget); // 旧内容还在
      expect(find.text('请求超时，当前网络较慢，请稍后重试'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);

      await t.tap(find.text('重试'));
      await t.pumpAndSettle();
      expect(find.text('条目3'), findsOneWidget);
    });

    testWidgets('页面销毁后请求才返回，不会回调更新（无异常）', (t) async {
      final c = Completer<List<int>>();
      await t.pumpWidget(host(() => c.future));
      await t.pump(const Duration(milliseconds: 100));
      await t.pumpWidget(const SizedBox());
      c.complete([1]);
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
    });
  });

  group('LoadingButton', () {
    testWidgets('点击立即 loading、连点只执行一次、结束后恢复', (t) async {
      var runs = 0;
      final done = Completer<void>();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: '提交',
              loadingLabel: '提交中…',
              onPressed: () async {
                runs++;
                await done.future;
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('提交'));
      await t.pump();
      expect(find.text('提交中…'), findsOneWidget);
      expect(find.byType(AppSpinner), findsOneWidget);
      await t.tap(find.text('提交中…'));
      await t.tap(find.text('提交中…'));
      await t.pump();
      expect(runs, 1);
      done.complete();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('提交'), findsOneWidget);
      expect(find.byType(AppSpinner), findsNothing);
    });

    testWidgets('失败：恢复可点，用 Toast 说明原因', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: '提交',
              onPressed: () async => throw const AppError('名称已存在'),
            ),
          ),
        ),
      );
      await t.tap(find.text('提交'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('名称已存在'), findsOneWidget);
      expect(find.text('提交'), findsOneWidget);
    });

    testWidgets('禁用时说明原因，而不是只置灰', (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              label: '提交',
              onPressed: null,
              disabledReason: '请先填写手机号',
            ),
          ),
        ),
      );
      await t.tap(find.text('提交'));
      await t.pump();
      expect(find.text('请先填写手机号'), findsOneWidget);
    });

    testWidgets('runBusy：重复触发被忽略，loading 至少 500ms', (t) async {
      var runs = 0;
      unawaited(runBusy('k', () async => runs++));
      unawaited(runBusy('k', () async => runs++));
      expect(isBusy('k'), isTrue);
      await t.pump(const Duration(milliseconds: 300));
      expect(isBusy('k'), isTrue);
      await t.pump(const Duration(milliseconds: 300));
      expect(isBusy('k'), isFalse);
      expect(runs, 1);
    });
  });

  group('已接后端的页面', () {
    late _Api api;
    setUp(() {
      api = _Api();
      merchantApi = api;
      CatalogDraft.current = null;
    });

    void phone(WidgetTester t) {
      t.view.physicalSize = const Size(390 * 3, 900 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);
    }

    testWidgets('服务项目：加载骨架 → 列表', (t) async {
      phone(t);
      api.latency = const Duration(milliseconds: 400);
      api.services = [
        {'id': '1', 'name': '精致洗车', 'category': '洗车', 'price': 88},
      ];
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pump(const Duration(milliseconds: 350));
      expect(find.byType(SkeletonServiceList), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(find.text('精致洗车'), findsOneWidget);
      expect(find.byType(SkeletonServiceList), findsNothing);
    });

    testWidgets('服务项目：已下架的项目显示“已下架”', (t) async {
      phone(t);
      api.services = [
        {
          'id': '1',
          'name': '发动机舱清洗',
          'category': '洗车',
          'price': 120,
          'active': false,
        },
        {
          'id': '2',
          'name': '快速洗车',
          'category': '洗车',
          'price': 38,
          'active': true,
        },
      ];
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pumpAndSettle();
      expect(find.text('已下架'), findsOneWidget);
    });

    testWidgets('服务项目：首次为空引导新建；失败可重试', (t) async {
      phone(t);
      api.failures.add(const AppError.timeout()); // 假后端直接抛错，不经过 invoke 的内部重试
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pumpAndSettle();
      expect(find.text('请求超时'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);

      await t.tap(find.text('重试'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('还没有服务项目'), findsOneWidget);
      expect(find.text('新增项目'), findsWidgets);
    });

    testWidgets('服务项目：分类筛选无结果时给“重置筛选”', (t) async {
      phone(t);
      api.services = [
        {'id': '1', 'name': '精致洗车', 'category': '洗车', 'price': 88},
      ];
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('镀晶镀膜'));
      await t.pumpAndSettle();
      expect(find.text('当前筛选下没有数据'), findsOneWidget);
      await t.tap(find.text('重置筛选'));
      await t.pumpAndSettle();
      expect(find.text('精致洗车'), findsOneWidget);
    });

    testWidgets('会员卡种：首次为空引导新建；失败有重试', (t) async {
      phone(t);
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      await t.pumpAndSettle();
      expect(find.text('还没有会员卡种'), findsOneWidget);
      expect(find.text('新建卡种'), findsOneWidget);
    });

    testWidgets('会员卡种：加载失败显示错误态，重试后恢复', (t) async {
      phone(t);
      api.failures.add(const AppError.network());
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      await t.pumpAndSettle();
      expect(find.text('网络不太给力'), findsOneWidget);
      api.cards = [
        {
          'id': 'c1',
          'name': '黑金卡',
          'discount': 0.8,
          'description': '',
          'active': true,
        },
      ];
      await t.ensureVisible(find.text('重试'));
      await t.tap(find.text('重试'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('网络不太给力'), findsNothing);
      expect(find.text('黑金卡'), findsWidgets);
    });
  });
}
