import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/hold_flow.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/home_page.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'holds_test.dart' show hold;
import 'members_test.dart' show MemberFakeApi, phone;

void main() {
  late MerchantApi original;
  late MemberFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = MemberFakeApi();
    merchantApi = fake;
    CatalogDraft.current = null;
    MemberFlow.current = null;
    HoldFlow.reset();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    HoldFlow.reset();
    navTracker.stack.clear();
  });

  Future<void> openHome(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(navigatorObservers: [navTracker], home: const HomePage()),
    );
    await t.pumpAndSettle();
  }

  testWidgets('首页“施工中”来自挂单里状态为施工中的单子，设计稿里的示例不再出现', (t) async {
    fake.holdRows.addAll([
      hold(items: ['镀晶养护', '内饰精洗']),
      hold(id: 'h2', status: '待结算', name: '李女士'),
      hold(id: 'h3', walkIn: true, items: ['基础洗车'], plate: 'K5F218'),
    ]);
    await openHome(t);
    expect(
      find.textContaining('施工中 · 2 单', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('镀晶养护 · 内饰精洗'), findsOneWidget);
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('散客'), findsOneWidget);
    expect(find.text('李女士'), findsNothing); // 待结算的不在“施工中”
    expect(find.text('3 号工位'), findsNothing);
    expect(find.textContaining('个工位', findRichText: true), findsNothing);
    expect(find.text('65%'), findsNothing);
  });

  testWidgets('没有施工中的车辆：显示一行空状态；读取失败可以重试', (t) async {
    await openHome(t);
    expect(find.text('暂无施工中的车辆'), findsOneWidget);
    expect(
      find.textContaining('施工中 · 0 单', findRichText: true),
      findsOneWidget,
    );

    await t.pumpWidget(const SizedBox());
    HoldFlow.reset();
    fake.holdsError = const AppError('网络不稳定', type: AppErrorType.network);
    await openHome(t);
    expect(find.text('重试'), findsOneWidget);
    fake.holdsError = null;
    fake.holdRows.add(hold());
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(
      find.textContaining('施工中 · 1 单', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('未登录时引导登录，不展示设计稿统计或施工示例', (t) async {
    merchantApi = original;
    await openHome(t);
    expect(
      find.textContaining('施工中 · 2 个工位', findRichText: true),
      findsNothing,
    );
    expect(find.text('3 号工位'), findsNothing);
    expect(find.text('12,860.00'), findsNothing);
    expect(find.text('今日 ¥12,600'), findsNothing);
    expect(find.text('重新登录'), findsOneWidget);
  });
}
