import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/shared/stats_page.dart';
import 'package:autocare_merchant/widgets/common.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_stats_test.dart' show StatsApi;
import 'members_test.dart' show phone;

void main() {
  late MerchantApi original;
  late StatsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = StatsApi();
  });
  tearDown(() {
    merchantApi = original;
    C.dark = false;
  });

  for (final dark in [false, true]) {
    testWidgets('统计保留卡片布局，今日读真实汇总，其他时段不推算假数据 ${dark ? '深色' : '浅色'}', (t) async {
      phone(t);
      C.dark = dark;
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: const StatsPage(),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('本月营业额（元）'), findsOneWidget);
      expect(find.text('TODO：该时段统计接口尚未接通'), findsOneWidget);
      final before = t.getRect(find.byType(AppCard).first);
      await t.tap(find.text('今日'));
      await t.pumpAndSettle();
      expect(find.text('1,234.56'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('较上周同日 -12.5%'), findsOneWidget);
      expect(find.text('TODO：分时趋势接口尚未接通'), findsOneWidget);
      // 卡片为原有自然流布局，真实数字长度可改变高度；固定的是左右边界和图表高度。
      final after = t.getRect(find.byType(AppCard).first);
      expect(after.topLeft, before.topLeft);
      expect(after.width, before.width);
      expect(
        t
            .getSize(
              find.byWidgetPredicate((w) => w is SizedBox && w.height == 110),
            )
            .height,
        110,
      );
      for (final period in ['本周', '本月', '自定义']) {
        await t.tap(find.text(period).first);
        await t.pumpAndSettle();
        expect(find.text('1,234.56'), findsNothing);
        expect(find.textContaining('统计接口尚未接通'), findsWidgets);
      }
      for (final sample in [
        '328,460',
        '71,280',
        '158,920',
        '68%',
        '38%',
        '¥124,815',
      ]) {
        expect(find.text(sample), findsNothing);
      }
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('读取失败可重试，真实零值不会回退示例金额', (t) async {
    phone(t);
    api.error = const AppError.timeout();
    await t.pumpWidget(const MaterialApp(home: StatsPage()));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsOneWidget);
    expect(find.text('本月营业额（元）'), findsNothing);
    api.error = null;
    api.stats = {
      ...api.stats,
      'revenue': 0,
      'orders': 0,
      'change_percent': null,
    };
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    await t.tap(find.text('今日'));
    await t.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('较上周同日 -12.5%'), findsNothing);
  });

  testWidgets('未登录只提供登录入口，不展示统计预览', (t) async {
    phone(t);
    merchantApi = MerchantApi();
    await t.pumpWidget(const MaterialApp(home: StatsPage()));
    await t.pumpAndSettle();
    expect(find.text('重新登录'), findsOneWidget);
    expect(find.text('营业统计'), findsNothing);
  });
}
