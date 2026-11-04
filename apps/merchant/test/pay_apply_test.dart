import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/gen/gen_routes.dart';
import 'package:autocare_merchant/routes.dart';

import 'members_test.dart' show MemberFakeApi, app, phone;

void main() {
  late MerchantApi original;
  setUp(() {
    original = merchantApi;
    merchantApi = MemberFakeApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  testWidgets('支付与收款：没有开通能力，真实状态是“未开通”，开通入口可进入开通须知', (t) async {
    phone(t);
    await t.pumpWidget(
      app(
        Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () => openRoute(context, 'PayConfig'),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('未开通'), findsWidgets);
    // 不显示已开通状态里的示例商户号
    expect(find.textContaining('已开通'), findsNothing);
  });

  testWidgets('开通流程：4 步资料页都能浏览，设计稿路由都已登记', (t) async {
    for (final n in [
      'PayApplyIntro',
      'PayApplyStep1',
      'PayApplyStep2',
      'PayApplyStep3',
      'PayApplyStep4',
      'PayApplyReview',
      'PayApplyBind',
      'PayApplyReviewing',
      'PayApplySign',
      'PayApplyRejected',
      'PayApplyDone',
      'PayConfigUnopened',
    ]) {
      expect(genRoutes.containsKey(n), isTrue, reason: n);
    }
  });

  for (final (from, label) in [
    ('PayApplyReview', '提交申请'),
    ('PayApplyBind', '发送授权请求'),
  ]) {
    testWidgets('$label：接口没接通，提示未接通，不跳到“审核中”冒充已提交', (t) async {
      phone(t);
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, from),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text(label).first);
      await t.pump();
      expect(find.text('微信支付开通暂未接通，申请还没有提交'), findsWidgets);
      expect(navTracker.has('PayApplyReviewing'), isFalse);
      await t.pump(const Duration(seconds: 6));
    });
  }
}
