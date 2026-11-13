import 'dart:io';
import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/catalog/card_tiers_live_page.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';
import 'package:autocare_merchant/pages/catalog/services_page.dart';
import 'package:autocare_merchant/pages/catalog/service_edit_page.dart';
import 'package:autocare_merchant/pages/catalog/card_tier_edit_page.dart';
import 'package:autocare_merchant/pages/catalog/package_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 加载态的视觉规范（docs/frontend-guidelines.md · 加载态的通用要求）：
/// 骨架贴顶、行数一致、按钮 loading 尺寸不变且只显示转圈、图标按钮只显示转圈。
class _Api extends MerchantApi {
  Completer<void>? saveGate;
  Completer<void>? codeGate;
  @override
  Future<void> checkCode(String phone, String code) async {
    await codeGate?.future;
    throw const AppError('测试校验失败');
  }

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    await saveGate?.future;
    throw const AppError('测试保存失败');
  }

  @override
  Future<List<Map<String, dynamic>>> accountDevices() async => [];
  @override
  Future<Map<String, dynamic>> cancellationCheck() async => {
    'holds': 0,
    'appointments': 0,
    'can_cancel': true,
    'billing_note': '限时免费期间无套餐欠费',
    'data_note': '门店经营数据保留，不会被清除',
  };
  Duration latency = const Duration(milliseconds: 400);
  @override
  bool get hasSession => true;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    await Future<void>.delayed(latency);
    return [];
  }

  @override
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async =>
      (autoUpgrade: true, balanceRefundable: false);
}

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = _Api();
    busyActions.value = const {};
  });
  tearDown(() {
    merchantApi = original;
    busyActions.value = const {};
  });

  void phone(WidgetTester t, {double h = 844}) {
    t.view.physicalSize = Size(390 * 3, h * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  group('骨架屏', () {
    testWidgets('服务项目：骨架紧贴筛选条下方，不会被居中而在顶部留一大块空白', (t) async {
      phone(t);
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pump(const Duration(milliseconds: 350));
      expect(find.byType(SkeletonServiceList), findsOneWidget);
      final chipsBottom = t.getBottomLeft(find.textContaining('全部')).dy;
      final skeletonTop = t.getTopLeft(find.byType(SkeletonServiceList)).dy;
      expect(skeletonTop - chipsBottom, lessThan(60));
      await t.pumpAndSettle();
    });

    testWidgets('AsyncView 的骨架从区域顶部开始', (t) async {
      phone(t);
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncView<List<int>>(
              load: () async {
                await Future<void>.delayed(const Duration(seconds: 1));
                return [1];
              },
              isEmpty: (d) => d.isEmpty,
              skeleton: const SkeletonList(count: 2),
              empty: (_) => const SizedBox(),
              builder: (_, d) => const Text('内容'),
            ),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 350));
      final top = t.getTopLeft(find.byType(SkeletonList)).dy;
      expect(top, lessThan(80)); // 区域内边距 16 + 状态栏等，不应接近屏幕中部
      await t.pumpAndSettle();
    });

    testWidgets('服务项目与卡种两个列表的骨架都是 5 行', (t) async {
      phone(t);
      await t.pumpWidget(const MaterialApp(home: ServicesPage()));
      await t.pump(const Duration(milliseconds: 350));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'skeleton-service-row-',
              ),
        ),
        findsNWidgets(5),
      );
      await t.pumpAndSettle();

      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      await t.pump(const Duration(milliseconds: 350));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(
                'skeleton-tier-card-',
              ),
        ),
        findsNWidgets(5),
      );
      await t.pumpAndSettle();
    });
  });

  group('按钮 loading', () {
    Future<void> openGen(WidgetTester t, String route) async {
      phone(t, h: 1000);
      final old = FlutterError.onError;
      FlutterError.onError = (d) {
        if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
      };
      addTearDown(() => FlutterError.onError = old);
      await t.pumpWidget(
        MaterialApp(
          initialRoute: route,
          onGenerateRoute: (s) => MaterialPageRoute(
            settings: s,
            builder: (_) => Builder(builder: pageBuilders[s.name]!),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('注册底部“下一步”：loading 时宽高不变（不会缩成圆），保留标准文案', (t) async {
      await openGen(t, 'RegPhone');
      await t.enterText(find.byType(TextFormField).at(0), '13800001234');
      await t.enterText(find.byType(TextFormField).at(1), '246810');
      await t.enterText(find.byType(TextFormField).at(2), 'Pass1234');
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pumpAndSettle();
      final api = merchantApi as _Api;
      api.codeGate = Completer<void>();
      final button = find
          .ancestor(of: find.text('下一步'), matching: find.byType(Container))
          .first;
      final before = t.getSize(button);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await t.tap(find.text('下一步'));
      await t.pump();
      final after = t.getSize(button);
      expect(after, before);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // 标准按钮保留原文案，转圈在左；完整按钮尺寸不变。
      expect(find.text('下一步'), findsOneWidget);
      final spinner = t.getRect(find.byType(CircularProgressIndicator));
      final label = t.getRect(find.text('下一步'));
      expect(spinner.right, lessThan(label.left));
      expect(t.getRect(button).contains(spinner.center), isTrue);
      expect(t.getRect(button).contains(label.center), isTrue);

      api.codeGate!.complete();
      await t.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(t.getSize(button), before);
      await t.pump(const Duration(seconds: 6));
      await t.pumpAndSettle();
    });

    testWidgets('保存页：标准保存按钮加载时尺寸不变且只锁定一次提交', (t) async {
      final pages = <Widget>[
        const ServiceEditPage(initial: {'name': '测试服务', 'price': 88}),
        const CardTierEditPage(initial: {'name': '测试卡种'}),
        const PackageEditPage(
          initial: {
            'name': '测试套餐',
            'price': 88,
            'items': [
              {'service_id': 's1', 'name': '测试服务', 'price': 88, 'count': 1},
            ],
          },
        ),
      ];
      for (final page in pages) {
        await t.pumpWidget(const SizedBox());
        phone(t);
        await t.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () =>
                      Navigator.of(context)
                          .push(MaterialPageRoute<void>(builder: (_) => page)),
                  child: const Text('打开'),
                ),
              ),
            ),
          ),
        );
        await t.tap(find.text('打开'));
        await t.pumpAndSettle();
        final route = page.runtimeType.toString();
        final api = merchantApi as _Api;
        api.saveGate = Completer<void>();
        final save = find
            .ancestor(of: find.text('保存'), matching: find.byType(Container))
            .first;
        final beforeSize = t.getSize(save);
        expect(beforeSize.width, greaterThan(50), reason: route);
        await t.tap(find.text('保存'));
        await t.pump();
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: route,
        );
        expect(find.text('保存中…'), findsNothing);
        // 加载时“保存”两个字已经换成转圈，从转圈往外找按钮
        final pill = find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(Container),
            )
            .first;
        expect(t.getSize(pill), beforeSize, reason: route);
        expect(
          t.getSize(find.byType(CircularProgressIndicator)),
          const Size(16, 16),
        );
        expect(
          t
              .getRect(pill)
              .contains(t.getCenter(find.byType(CircularProgressIndicator))),
          isTrue,
        );
        api.saveGate!.complete();
        await t.pumpAndSettle();
        expect(find.text('保存'), findsOneWidget, reason: route);
        expect(t.getSize(save).width, greaterThan(50), reason: route);
        await t.pump(const Duration(seconds: 6));
        await t.pumpAndSettle();
      }
    });

    testWidgets('图标按钮 loading：只显示转圈，不显示原来的图标', (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F4F5),
                  shape: BoxShape.circle,
                ),
                child: hBusy(
                  'k',
                  const Icon(Icons.refresh, size: 20),
                  icon: true,
                ),
              ),
            ),
          ),
        ),
      );
      final size = t.getSize(find.byType(Container).first);
      expect(find.byType(AppSpinner), findsNothing);
      busyActions.value = {'k'};
      await t.pump();
      expect(find.byType(AppSpinner), findsOneWidget);
      expect(
        t.getSize(find.byType(AppSpinner)),
        const Size(20, 20),
      ); // 设计稿图标按钮的转圈
      final icon = t.widget<Opacity>(
        find
            .ancestor(
              of: find.byIcon(Icons.refresh),
              matching: find.byType(Opacity),
            )
            .first,
      );
      expect(icon.opacity, 0); // 原图标不可见
      expect(t.getSize(find.byType(Container).first), size);
    });
  });

  test('点击组件不再按路由和目的页猜测提交状态', () {
    expect(File('lib/kit/async_action_keys.dart').existsSync(), isFalse);
    final source = File('lib/kit/kit.dart').readAsStringSync();
    expect(source, isNot(contains('asyncActionKeys')));
    expect(source, isNot(contains('final busyKey =')));
  });

  testWidgets('AppSpinner 按设计稿的尺寸绘制，减少动态效果时不转动', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Center(child: AppSpinner(size: 16, color: Colors.blue)),
      ),
    );
    expect(t.getSize(find.byType(AppSpinner)), const Size(16, 16));
    await t.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: MaterialApp(
          home: Center(child: AppSpinner(size: 16, color: Colors.blue)),
        ),
      ),
    );
    // 静止时没有未完成的动画，pumpAndSettle 能立即结束
    await t.pumpAndSettle();
  });
}
