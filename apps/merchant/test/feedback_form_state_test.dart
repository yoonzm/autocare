import 'dart:convert';

import 'package:autocare_merchant/backend/feedback_draft.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/account/feedback_page.dart';
import 'package:autocare_merchant/widgets/feedback_recovery_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'feedback_page_test.dart' show FeedbackApi;

class _Api extends FeedbackApi {
  String owner = 'owner-a';
  @override
  String? get accountId => signedIn ? owner : null;
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
  });
  tearDown(() {
    merchantApi = original;
  });
  Future<BuildContext> host(WidgetTester t, FeedbackRecovery recovery) async {
    t.view.physicalSize = const Size(1170, 3600);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    late BuildContext context;
    await t.pumpWidget(
      FeedbackRecoveryScope(
        recovery: recovery,
        child: MaterialApp(
          home: Builder(
            builder: (c) {
              context = c;
              return const Scaffold(body: Text('反馈入口'));
            },
          ),
        ),
      ),
    );
    return context;
  }

  void push(BuildContext c, Widget page) =>
      Navigator.of(c).push<void>(MaterialPageRoute(builder: (_) => page));
  testWidgets('多个反馈表单分别持有描述、类型和联系方式，取消后不覆盖原表单', (t) async {
    final c = await host(t, FeedbackRecovery());
    push(c, const FeedbackPage());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, '第一份描述');
    await t.enterText(find.byType(TextField).last, 'first@example.com');
    await t.tap(find.text('问题报告').last);
    await t.pump();
    push(t.element(find.byType(FeedbackPage)), const FeedbackPage());
    await t.pumpAndSettle();
    expect(
      t
          .widgetList<TextField>(find.byType(TextField))
          .every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
    Navigator.of(t.element(find.byType(FeedbackPage))).pop();
    await t.pumpAndSettle();
    expect(find.text('第一份描述'), findsOneWidget);
    expect(find.text('first@example.com'), findsOneWidget);
    expect(api.calls, isEmpty);
  });
  testWidgets('登录失效仅保存恢复副本，重建页面后同账号领取，第二个表单仍为空', (t) async {
    final recovery = FeedbackRecovery();
    final c = await host(t, recovery);
    push(c, const FeedbackPage());
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, '会话失效前的描述');
    authExpired.value++;
    // App 的登录失效处理会重建导航栈；此处直接销毁页面模拟该生命周期。
    await t.pumpWidget(const SizedBox());
    await t.pump();
    late BuildContext loginContext;
    await t.pumpWidget(
      FeedbackRecoveryScope(
        recovery: recovery,
        child: MaterialApp(
          home: Builder(
            builder: (c) {
              loginContext = c;
              return const Scaffold();
            },
          ),
        ),
      ),
    );
    push(loginContext, const FeedbackPage());
    await t.pumpAndSettle();
    expect(find.text('会话失效前的描述'), findsOneWidget);
    push(t.element(find.byType(FeedbackPage)), const FeedbackPage());
    await t.pumpAndSettle();
    expect(
      t
          .widgetList<TextField>(find.byType(TextField))
          .every((w) => w.controller!.text.isEmpty),
      isTrue,
    );
  });
  testWidgets('截图位置显式绑定，实际图片上传后参与本次反馈，不解析控件 key', (t) async {
    final c = await host(t, FeedbackRecovery());
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
    );
    push(c, FeedbackPage(pickImage: () async => XFile.fromData(bytes)));
    await t.pumpAndSettle();
    await t.tap(find.byKey(const ValueKey('feedback-image-1')));
    await t.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-image-1')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-image-0')),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('feedback-image-2')),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
    await t.enterText(find.byType(TextField).first, '带截图的反馈');
    await t.tap(find.text('提交反馈'));
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    expect(api.calls.map((r) => r['action']), [
      'support_upload',
      'support_create',
    ]);
    expect(base64Decode(api.calls.first['data']), bytes);
    expect(api.calls.last['attachments'], ['ticket-1']);
  });
}
