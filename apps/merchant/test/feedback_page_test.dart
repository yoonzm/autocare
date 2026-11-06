import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/gen/feedback_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackApi extends MerchantApi {
  bool signedIn = true;
  final local = SupabaseClient(
    'http://localhost:54321',
    'test-key',
    authOptions: const AuthClientOptions(autoRefreshToken: false),
  );
  final calls = <Map<String, dynamic>>[];
  final ids = <String?>[];
  Completer<Map<String, dynamic>>? response;
  @override
  bool get hasSession => signedIn;
  @override
  SupabaseClient get client => local;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = const Duration(seconds: 15),
    String? requestId,
  }) {
    calls.add(body);
    ids.add(requestId);
    return response?.future ?? Future.value({'id': 'ticket-1'});
  }
}

void main() {
  late MerchantApi original;
  late FeedbackApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = FeedbackApi();
  });
  tearDown(() {
    merchantApi = original;
    C.dark = false;
  });
  setUpAll(() async {
    final file = File('C:/Windows/Fonts/msyh.ttc');
    if (file.existsSync()) {
      await (FontLoader('FeedbackTest')..addFont(
            Future.value(ByteData.sublistView(file.readAsBytesSync())),
          ))
          .load();
    }
  });
  Future<void> open(
    WidgetTester t, {
    bool dark = false,
    GlobalKey? boundary,
  }) async {
    C.dark = dark;
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'FeedbackTest',
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        navigatorObservers: [navTracker],
        initialRoute: 'AboutApp',
        routes: {
          'AboutApp': (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.pushNamed(context, 'Feedback'),
              child: const Text('打开反馈'),
            ),
          ),
          'Feedback': (_) =>
              RepaintBoundary(key: boundary, child: const FeedbackPage()),
        },
      ),
    );
    await t.tap(find.text('打开反馈'));
    await t.pumpAndSettle();
  }

  Future<void> capture(WidgetTester t, GlobalKey key, String name) async {
    final directory = Platform.environment['FEEDBACK_RENDER_DIR'];
    if (directory == null) return;
    await t.runAsync(() async {
      final image =
          await (key.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await Directory(directory).create(recursive: true);
      await File('$directory/$name.png')
          .writeAsBytes(data!.buffer.asUint8List());
    });
  }

  for (final dark in [false, true]) {
    testWidgets(
      'feedback preserves designed fields and phone layout ${dark ? 'dark' : 'light'}',
      (t) async {
        final key = GlobalKey();
        await open(t, dark: dark, boundary: key);
        expect(find.byType(TextField), findsNWidgets(2));
        expect(
          t.widget<TextField>(find.byType(TextField).last).controller!.text,
          isEmpty,
        );
        expect(find.text('139 **** 8812'), findsNothing);
        expect(find.text('反馈提交后将由平台处理，暂不支持查看进度和回复'), findsOneWidget);
        expect(find.text('提交反馈'), findsOneWidget);
        await capture(t, key, dark ? 'feedback-dark' : 'feedback-light');
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'submission blocks duplicates, keeps button size and preserves failed input',
    (t) async {
      await open(t);
      await t.enterText(find.byType(TextField).first, '真实问题描述');
      await t.enterText(find.byType(TextField).last, 'owner@example.com');
      await t.tap(find.text('问题报告').last);
      final submit = find
          .ancestor(
            of: find.text('提交反馈'),
            matching: find.byType(GestureDetector),
          )
          .first;
      final size = t.getSize(submit);
      api.response = Completer<Map<String, dynamic>>();
      await t.tap(submit);
      await t.pump(const Duration(milliseconds: 100));
      expect(api.calls.length, 1);
      expect(find.byType(AppSpinner), findsOneWidget);
      expect(t.getSize(submit), size);
      await t.tap(submit, warnIfMissed: false);
      expect(api.calls.length, 1);
      api.response!.completeError(const AppError('反馈提交失败'));
      await t.pump(const Duration(milliseconds: 600));
      await t.pumpAndSettle();
      expect(find.text('真实问题描述'), findsOneWidget);
      expect(find.text('owner@example.com'), findsOneWidget);
      expect(find.text('反馈提交失败'), findsOneWidget);
      expect(api.calls.first['category'], '问题报告');
      final id = api.ids.first;
      api.response = null;
      await t.tap(find.text('提交反馈'));
      await t.pump(const Duration(milliseconds: 600));
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      expect(api.ids.last, id);
      expect(find.text('打开反馈'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('unsigned feedback offers login and makes no request', (t) async {
    api.signedIn = false;
    await open(t);
    expect(find.byType(TextField), findsNothing);
    expect(find.text('重新登录'), findsOneWidget);
    expect(api.calls, isEmpty);
  });
}
