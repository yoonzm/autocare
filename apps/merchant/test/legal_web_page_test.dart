import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/account/legal_web_page.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Uri? loadedUrl;
  late Map<String, String>? loadedHeaders;
  late VoidCallback loaded;
  late ValueChanged<AppError> failed;
  var builds = 0;

  setUp(() {
    loadedUrl = null;
    loadedHeaders = null;
    builds = 0;
    legalWebViewBuilder = (url, headers, onLoaded, onError) {
      builds++;
      loadedUrl = url;
      loadedHeaders = headers;
      loaded = onLoaded;
      failed = onError;
      return const ColoredBox(color: Colors.white, child: Text('H5 正文'));
    };
  });
  tearDown(() => legalWebViewBuilder = legalNativeWebViewBuilder);

  Future<void> open(WidgetTester t, LegalDoc doc) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(home: LegalWebPage(doc: doc)));
  }

  testWidgets('用户协议加载公开静态 HTML，不带鉴权请求头', (t) async {
    await open(t, LegalDoc.terms);
    expect(find.text('用户协议'), findsOneWidget);
    expect(loadedUrl.toString(), '$supabaseUrl/legal/terms.html?theme=light');
    expect(loadedHeaders, isEmpty);
    expect(find.byType(AppSpinner), findsOneWidget);
    loaded();
    await t.pump();
    expect(find.byType(AppSpinner), findsNothing);
    expect(find.text('H5 正文'), findsOneWidget);
  });

  testWidgets('隐私政策使用 privacy 页面', (t) async {
    await open(t, LegalDoc.privacy);
    expect(find.text('隐私政策'), findsOneWidget);
    expect(loadedUrl!.path, '/legal/privacy.html');
  });

  for (final doc in LegalDoc.values) {
    testWidgets('$doc 正文跟随 App 主题，覆盖相反的系统主题', (t) async {
      t.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(t.platformDispatcher.clearPlatformBrightnessTestValue);
      await open(t, doc);
      expect(loadedUrl!.queryParameters['theme'], 'light');
      loaded();
      await t.pump();

      t.platformDispatcher.platformBrightnessTestValue = Brightness.light;
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: LegalWebPage(doc: doc),
        ),
      );
      await t.pump(kThemeAnimationDuration);
      expect(loadedUrl!.queryParameters['theme'], 'dark');
      expect(find.byType(AppSpinner), findsOneWidget);
      loaded();
      await t.pump();
      expect(find.byType(AppSpinner), findsNothing);
    });
  }

  testWidgets('加载失败显示错误和重试，重试重新加载同一页面', (t) async {
    await open(t, LegalDoc.privacy);
    failed(const AppError.network());
    await t.pump();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('H5 正文'), findsNothing);
    final before = builds;
    await t.tap(find.text('重试'));
    await t.pump();
    expect(find.byType(ErrorView), findsNothing);
    expect(builds, before + 1);
    expect(loadedUrl!.path, '/legal/privacy.html');
  });
}
