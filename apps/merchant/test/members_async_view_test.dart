import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/members/members_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi, phone, row;

class _Api extends MemberFakeApi {
  final offsets = <int>[];
  Completer<void>? gate;

  @override
  Future<MemberPage> members({
    String? query,
    String? cardTypeId,
    List<String>? cardTypeIds,
    num? balanceMin,
    num? balanceMax,
    int? visitedWithinDays,
    int? visitedOverDays,
    String? packageStatus,
    String? vehicleProject,
    int offset = 0,
    int limit = 50,
    bool recent = false,
  }) async {
    offsets.add(offset);
    // Capture the result before waiting so old requests really return old data.
    final result = await super.members(
      query: query,
      cardTypeId: cardTypeId,
      offset: offset,
      limit: 2,
    );
    final pending = gate;
    gate = null;
    await pending?.future;
    return result;
  }
}

void main() {
  late MerchantApi original;
  late _Api api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = _Api();
  });
  tearDown(() => merchantApi = original);

  Future<void> open(WidgetTester t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: MembersPage()));
    await t.pumpAndSettle();
  }

  Future<void> finish(WidgetTester t) async {
    await t.pump();
    await t.pump(kIndicatorMinShow);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  }

  testWidgets('会员主页使用 AsyncView：下拉刷新保留旧数据且不显示横线', (t) async {
    api.rows.add(row());
    await open(t);
    expect(find.byWidgetPredicate((w) => w is AsyncView), findsOneWidget);
    final pending = api.gate = Completer<void>();
    api.rows[0] = row(name: '更新后的会员');
    await t.drag(find.byType(ListView).first, const Offset(0, 400));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('王建国'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(SkeletonRow), findsNothing);
    pending.complete();
    await finish(t);
    expect(find.text('更新后的会员'), findsOneWidget);
    expect(find.text('王建国'), findsNothing);
    expect(api.offsets, [0, 0]);
  });

  testWidgets('刷新失败保留会员与统计，重试后更新', (t) async {
    api.rows.add(row());
    await open(t);
    api.listError = const AppError('会员读取失败', type: AppErrorType.network);
    final refresh = t.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    final failed = refresh.onRefresh();
    await finish(t);
    await failed;
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('全部 1'), findsOneWidget);
    expect(find.text('会员读取失败'), findsOneWidget);
    api.listError = null;
    api.rows[0] = row(name: '重试成功');
    await t.tap(find.text('重试'));
    await finish(t);
    expect(find.text('重试成功'), findsOneWidget);
  });

  testWidgets('慢筛选期间再搜索：旧响应不能覆盖最后的条件', (t) async {
    api.rows.addAll([row(), row(id: 'm2', name: '林晓雯', tier: 't-base')]);
    await open(t);
    final pending = api.gate = Completer<void>();
    await t.tap(find.text('金卡 1'));
    await t.pump(const Duration(milliseconds: 350));
    await t.enterText(find.byType(TextField), '不存在');
    await t.pump(const Duration(milliseconds: 350));
    pending.complete();
    await finish(t);
    expect(api.listCalls.last.q, '不存在');
    expect(api.listCalls.last.tier, 't-gold');
    expect(find.text('王建国'), findsNothing);
    expect(find.text('重置筛选'), findsOneWidget);
  });

  testWidgets('分页追加，刷新后从第一页重新读取', (t) async {
    api.rows.addAll([
      row(),
      row(id: 'm2', name: '第二位'),
      row(id: 'm3', name: '第三位'),
    ]);
    await open(t);
    await t.ensureVisible(find.text('加载更多'));
    await t.tap(find.text('加载更多'));
    await finish(t);
    expect(find.text('第三位'), findsOneWidget);
    expect(find.text('加载更多'), findsNothing);
    final refresh = t.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    final refreshing = refresh.onRefresh();
    await finish(t);
    await refreshing;
    expect(find.text('第三位'), findsNothing);
    expect(find.text('加载更多'), findsOneWidget);
    expect(api.offsets, [0, 2, 0]);
  });

  testWidgets('刷新废弃迟到的分页结果', (t) async {
    api.rows.addAll([
      row(),
      row(id: 'm2', name: '第二位'),
      row(id: 'm3', name: '第三位'),
    ]);
    await open(t);
    await t.ensureVisible(find.text('加载更多'));
    final pending = api.gate = Completer<void>();
    await t.tap(find.text('加载更多'));
    await t.pump();
    expect(api.offsets.last, 2);
    api.rows.removeLast();
    final refresh = t.widget<RefreshIndicator>(find.byType(RefreshIndicator));
    final refreshing = refresh.onRefresh();
    await t.pump();
    await t.pump(kIndicatorMinShow);
    await refreshing;
    pending.complete();
    await finish(t);
    expect(find.text('第三位'), findsNothing);
    expect(find.text('全部 2'), findsOneWidget);
    expect(find.text('加载更多'), findsNothing);
    expect(api.offsets, [0, 2, 0]);
  });
}
