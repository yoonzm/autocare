import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/shared/stats_page.dart';
import 'package:autocare_merchant/widgets/common.dart';
import 'package:autocare_merchant/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'home_stats_test.dart' show StatsApi;
import 'members_test.dart' show phone;

Map<String, dynamic> month() => {
  'range': 'month',
  'from': '2026-11-01',
  'to': '2026-11-13',
  'prev_from': '2026-10-01',
  'prev_to': '2026-10-13',
  'revenue': 128460.5,
  'orders': 86,
  'change_percent': 12.3,
  'member_share': 68.4,
  'unit': 'day',
  'current': [100, 300.5, 200, null],
  'previous': [80, 120, null, null],
  'composition': [
    {'key': 'coating', 'amount': 64230, 'percent': 50},
    {'key': 'wrap', 'amount': 25692, 'percent': 20},
    {'key': 'wash', 'amount': 25692, 'percent': 20},
    {'key': 'other', 'amount': 12846.5, 'percent': 10},
  ],
};

Map<String, dynamic> today() => {
  ...month(),
  'range': 'today',
  'from': '2026-11-13',
  'to': '2026-11-13',
  'revenue': 1234.56,
  'orders': 4,
  'change_percent': -12.5,
  'member_share': 25,
  'unit': 'hour',
  'composition': [
    {'key': 'coating', 'amount': 0, 'percent': 0},
    {'key': 'wrap', 'amount': 0, 'percent': 0},
    {'key': 'wash', 'amount': 1234.56, 'percent': 100},
    {'key': 'other', 'amount': 0, 'percent': 0},
  ],
};

void main() {
  late MerchantApi original;
  late StatsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = StatsApi();
    api.business['month'] = month();
    api.business['today'] = today();
  });
  tearDown(() {
    merchantApi = original;
    C.dark = false;
  });

  Future<void> open(WidgetTester t, {bool dark = false}) async {
    phone(t);
    C.dark = dark;
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        home: const StatsPage(),
      ),
    );
    await t.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    testWidgets('各时段读真实统计：营业额、对比、构成、台次与会员占比 ${dark ? '深色' : '浅色'}', (t) async {
      await open(t, dark: dark);
      expect(api.businessCalls.map((c) => c.range), ['month']);
      expect(find.text('本月营业额（元）'), findsOneWidget);
      expect(find.text('128,460.50'), findsOneWidget);
      expect(find.text('较上月同期 +12.3%'), findsOneWidget);
      expect(find.text('11.1'), findsOneWidget);
      expect(find.text('11.13'), findsOneWidget);
      expect(find.text('上月'), findsOneWidget);
      expect(find.text('86'), findsOneWidget);
      expect(find.text('68%'), findsOneWidget);
      expect(find.text('64,230'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('12,847'), findsOneWidget); // 12,846.5 取整到元
      expect(find.textContaining('TODO'), findsNothing);
      final before = t.getRect(find.byType(AppCard).first);

      await t.tap(find.text('今日'));
      await t.pumpAndSettle();
      expect(api.businessCalls.map((c) => c.range), ['month', 'today']);
      expect(find.text('今日营业额（元）'), findsOneWidget);
      expect(find.text('1,234.56'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('较上周同日 -12.5%'), findsOneWidget);
      expect(find.text('上周同日'), findsOneWidget);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      // 卡片左右边界和图表高度不随时段变化。
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

      // 示例数字不得再出现。
      for (final sample in ['328,460', '71,280', '158,920', '¥124,815']) {
        expect(find.text(sample), findsNothing);
      }
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('本周与自定义：自定义选日期后带起止日请求，对比期标签随时段变化', (t) async {
    api.business['week'] = {
      ...month(),
      'range': 'week',
      'revenue': 5000,
      'change_percent': null,
    };
    await open(t);
    await t.tap(find.text('本周'));
    await t.pumpAndSettle();
    expect(find.text('本周营业额（元）'), findsOneWidget);
    expect(find.text('5,000.00'), findsOneWidget);
    expect(find.text('—'), findsOneWidget); // 上周同期营业额为 0 时对比显示 —
    expect(find.text('上周'), findsOneWidget);

    api.business['custom'] = {
      ...month(),
      'range': 'custom',
      'from': '2026-11-01',
      'to': '2026-11-01',
      'revenue': 777,
    };
    await t.tap(find.text('自定义'));
    await t.pumpAndSettle();
    expect(find.text('选择统计日期'), findsOneWidget);
    // 同一天作为起止日（当月 1 号必不晚于今天）。
    await t.tap(find.text('1').first);
    await t.pumpAndSettle();
    await t.tap(find.text('1').first);
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    final call = api.businessCalls.last;
    expect(call.range, 'custom');
    expect(call.from, isNotNull);
    expect(call.from!.day, 1);
    expect(call.to!.day, 1);
    expect(find.text('本期营业额（元）'), findsOneWidget);
    expect(find.text('777.00'), findsOneWidget);
    expect(find.text('上一期'), findsOneWidget);
  });

  testWidgets('取消选择日期不发请求，也不切走当前时段', (t) async {
    await open(t);
    await t.tap(find.text('自定义'));
    await t.pumpAndSettle();
    await t.tap(find.byIcon(Icons.close));
    await t.pumpAndSettle();
    expect(api.businessCalls.length, 1);
    expect(find.text('本月营业额（元）'), findsOneWidget);
  });

  testWidgets('切换时段读取失败：保留原时段内容并可重试，不显示新时段的空数据', (t) async {
    await open(t);
    api.businessError = const AppError.timeout();
    await t.tap(find.text('今日'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('请求超时'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
    expect(find.text('本月营业额（元）'), findsOneWidget);
    expect(find.text('128,460.50'), findsOneWidget);
    expect(find.text('今日营业额（元）'), findsNothing);
    // Toast 的“重试”重试的是失败的今日，而不是原来的本月。
    api.businessError = null;
    await t.pump(const Duration(milliseconds: 500));
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(api.businessCalls.map((c) => c.range), ['month', 'today', 'today']);
    expect(find.text('今日营业额（元）'), findsOneWidget);
    expect(find.text('1,234.56'), findsOneWidget);
  });

  testWidgets('失败后点回原页签：直接显示已有数据，不再请求', (t) async {
    await open(t);
    api.businessError = const AppError.timeout();
    await t.tap(find.text('今日'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    await t.tap(find.text('本月').first);
    await t.pump(const Duration(seconds: 9));
    expect(api.businessCalls.map((c) => c.range), ['month', 'today']);
    expect(find.text('128,460.50'), findsOneWidget);
  });

  testWidgets('加载中连续切换：以最后一次选择为准', (t) async {
    api.business['week'] = {...month(), 'range': 'week', 'revenue': 5000};
    await open(t);
    api.businessWait = Completer<void>();
    await t.tap(find.text('本周'));
    await t.pump();
    await t.tap(find.text('今日'));
    await t.pump();
    final gate = api.businessWait!;
    api.businessWait = null;
    gate.complete();
    await t.pumpAndSettle();
    expect(api.businessCalls.last.range, 'today');
    expect(find.text('今日营业额（元）'), findsOneWidget);
    expect(find.text('1,234.56'), findsOneWidget);
  });

  testWidgets('首次读取失败可重试，真实零值显示 0 而不回退示例', (t) async {
    phone(t);
    api.businessError = const AppError.timeout();
    await t.pumpWidget(const MaterialApp(home: StatsPage()));
    await t.pumpAndSettle();
    expect(find.text('请求超时'), findsOneWidget);
    expect(find.text('本月营业额（元）'), findsNothing);
    api.businessError = null;
    api.business.remove('month'); // 空店：营业额 0、无对比、无会员占比
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('0.00'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(find.text('0%'), findsNWidgets(4));
    expect(find.text('—'), findsNWidgets(2)); // 对比、会员消费占比
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
