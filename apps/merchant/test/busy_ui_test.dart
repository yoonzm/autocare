import 'dart:io';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/card_tiers_live_page.dart';
import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/pages/services_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 加载态的视觉规范（docs/frontend-guidelines.md · 加载态的通用要求）：
/// 骨架贴顶、行数一致、按钮 loading 尺寸不变且只显示转圈、图标按钮只显示转圈。
class _Api extends MerchantApi {
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
            builder: (_) => Builder(builder: genRoutes[s.name]!),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('注册底部“下一步”：loading 时宽高不变（不会缩成圆），只显示转圈', (t) async {
      await openGen(t, 'RegPhone');
      final button = find
          .ancestor(of: find.text('下一步'), matching: find.byType(Container))
          .first;
      final before = t.getSize(button);
      expect(find.byType(AppSpinner), findsNothing);

      busyActions.value = {'RegPhone>RegShop'};
      await t.pump();
      final after = t.getSize(button);
      expect(after, before);
      expect(find.byType(AppSpinner), findsOneWidget);
      // 原来的文字被隐藏；设计稿的全宽按钮：转圈在左、“提交中…”在右，都在按钮里面
      final text = t.widget<Opacity>(
        find
            .ancestor(of: find.text('下一步'), matching: find.byType(Opacity))
            .first,
      );
      expect(text.opacity, 0);
      expect(find.text('提交中…'), findsOneWidget);
      final spinner = t.getRect(find.byType(AppSpinner));
      final label = t.getRect(find.text('提交中…'));
      expect(spinner.right, lessThan(label.left));
      expect(t.getRect(button).contains(spinner.center), isTrue);
      expect(t.getRect(button).contains(label.center), isTrue);

      busyActions.value = const {};
      await t.pump();
      expect(find.byType(AppSpinner), findsNothing);
      expect(t.getSize(button), before);
    });

    testWidgets('保存页：“保存”加载时和设计稿图标按钮一样：44×44 的圆 + 20px 转圈，取消 ✕ 不转圈', (t) async {
      for (final route in ['ServiceEdit', 'CardTierEdit', 'PackageEdit']) {
        await t.pumpWidget(const SizedBox());
        await openGen(t, route);
        final key = {
          'ServiceEdit': 'ServiceEdit>Services',
          'CardTierEdit': 'CardTierEdit>CardTiers',
          'PackageEdit': 'PackageEdit>CardPackages',
        }[route]!;
        final save = find
            .ancestor(of: find.text('保存'), matching: find.byType(Container))
            .first;
        expect(t.getSize(save).width, greaterThan(50), reason: route);
        busyActions.value = {key};
        await t.pump();
        expect(find.byType(AppSpinner), findsOneWidget, reason: route);
        expect(find.text('保存中…'), findsNothing);
        // 加载时“保存”两个字已经换成转圈，从转圈往外找按钮
        final pill = find
            .ancestor(
              of: find.byType(AppSpinner),
              matching: find.byType(Container),
            )
            .first;
        expect(t.getSize(pill), const Size(44, 44), reason: route);
        expect(t.getSize(find.byType(AppSpinner)), const Size(20, 20));
        final c = t.getCenter(pill);
        expect(
          (t.getCenter(find.byType(AppSpinner)) - c).distance,
          lessThan(0.5),
        );
        busyActions.value = const {};
        await t.pump();
        expect(find.text('保存'), findsOneWidget, reason: route);
        expect(t.getSize(save).width, greaterThan(50), reason: route);
      }
    });

    testWidgets('每个提交按钮都有 loading：逐页检查生成页里的转圈', (t) async {
      const pages = {
        'RegShop': 'RegShop>RegDone',
        'ChangePassword': 'ChangePassword>Security',
        'ChangePhone': 'ChangePhone>Security',
        'DeleteAccount': 'DeleteAccount>Login',
        'Security': 'Security>Login',
        'CardTierEdit': 'CardTierEdit>CardTiers',
        'ForgotVerify': 'ForgotVerify>ForgotReset',
        'ForgotReset': 'ForgotReset>ForgotDone',
      };
      for (final e in pages.entries) {
        await t.pumpWidget(const SizedBox());
        await openGen(t, e.key);
        busyActions.value = {e.value};
        await t.pump();
        expect(
          find.byType(AppSpinner),
          findsOneWidget,
          reason: '${e.key} 的提交按钮应显示转圈',
        );
        busyActions.value = const {};
        await t.pump();
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

  test('生成脚本里的异步按钮和 asyncActionKeys 完全一致', () {
    final src = File('tools/design_to_flutter.py').readAsStringSync();
    final block = RegExp(
      r'ASYNC_ACTIONS = \{(.*?)\n\}',
      dotAll: true,
    ).firstMatch(src)!.group(1)!;
    // 同一个路由里的几个页签共用动作键前缀（如 RechargeCard 属于 Recharge 路由）
    final keyPage = {
      for (final m in RegExp(
        r"'(\w+)': '(\w+)'",
      ).allMatches(RegExp(r'KEY_PAGE = \{(.*?)\}').firstMatch(src)!.group(1)!))
        m.group(1)!: m.group(2)!,
    };
    final fromGenerator = {
      for (final m in RegExp(r"\('(\w+)', '(\w+)'\)").allMatches(block))
        '${keyPage[m.group(1)] ?? m.group(1)}>${m.group(2)}',
    };
    expect(fromGenerator, asyncActionKeys);
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
