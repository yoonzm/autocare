import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/members/member_adjust_controller.dart';
import 'package:autocare_merchant/pages/members/member_adjust_page.dart';
import 'package:autocare_merchant/pages/members/member_filter_controller.dart';
import 'package:autocare_merchant/pages/members/member_follow_up_page.dart';
import 'package:autocare_merchant/pages/members/member_reminder_controller.dart';
import 'package:autocare_merchant/pages/members/member_visit_controller.dart';
import 'package:autocare_merchant/pages/members/member_visit_page.dart';
import 'package:autocare_merchant/pages/members/members_page.dart';

import 'members_test.dart' show MemberFakeApi, row, phone;
import 'wallet_state_test.dart' show RecordingApi;

class OperationsApi extends MemberFakeApi {
  final writes = <Map<String, dynamic>>[];
  final pendingCounts = <Completer<MemberPage>>[];
  Completer<void>? gate;
  Completer<List<Map<String, dynamic>>>? oldHistory;
  Completer<MemberPage>? oldList;
  bool fail = false,
      cardsFail = false,
      remindersFail = false,
      deferCounts = false;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    if (kind == 'cards' && cardsFail) {
      throw const AppError('读取卡种失败', type: AppErrorType.network);
    }
    return super.list(kind);
  }

  @override
  Future<Map<String, dynamic>> reminders() async {
    if (remindersFail) {
      throw const AppError('读取提醒失败', type: AppErrorType.network);
    }
    return super.reminders();
  }

  @override
  Future<List<Map<String, dynamic>>> followUps(String memberId) async {
    if (memberId == 'a' && oldHistory != null) return oldHistory!.future;
    return [
      {
        'method': '电话',
        'result': '新会员回访',
        'content': '只属于乙',
        'created_at': '2026-11-12',
      },
    ];
  }

  @override
  Future<void> adjustMember({
    required String memberId,
    String? tierId,
    int points = 0,
    required String reason,
    String note = '',
    String? requestId,
  }) async {
    writes.add({
      'id': memberId,
      'tier': tierId,
      'points': points,
      'reason': reason,
      'note': note,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('服务端拒绝调整');
  }

  @override
  Future<void> saveFollowUp({
    required String memberId,
    required String method,
    required String result,
    String content = '',
    String? nextAt,
    String? requestId,
  }) async {
    writes.add({
      'id': memberId,
      'method': method,
      'result': result,
      'content': content,
      'next': nextAt,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('服务端拒绝回访');
  }

  @override
  Future<MemberPage> members({
    String? query,
    String? cardTypeId,
    List<String>? cardTypeIds,
    num? balanceMin,
    num? balanceMax,
    int? visitedWithinDays,
    int? visitedOverDays,
    int offset = 0,
    int limit = 50,
    bool recent = false,
  }) async {
    if (query == '旧' && oldList != null) return oldList!.future;
    if (limit == 1 && deferCounts) {
      final pending = Completer<MemberPage>();
      pendingCounts.add(pending);
      return pending.future;
    }
    return super.members(
      query: query,
      cardTypeId: cardTypeId,
      cardTypeIds: cardTypeIds,
      balanceMin: balanceMin,
      balanceMax: balanceMax,
      visitedWithinDays: visitedWithinDays,
      visitedOverDays: visitedOverDays,
      offset: offset,
      limit: limit,
      recent: recent,
    );
  }
}

void main() {
  late MerchantApi original;
  late OperationsApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = OperationsApi();
  });
  tearDown(() {
    merchantApi = original;

  });

  test('调整与回访客户端将幂等标识传给实际请求层', () async {
    final client = RecordingApi();
    await client.adjustMember(
      memberId: 'a',
      points: 50,
      reason: '补发',
      requestId: 'adjust-id',
    );
    await client.saveFollowUp(
      memberId: 'b',
      method: '电话',
      result: '未接通',
      requestId: 'visit-id',
    );
    expect(client.requests.map((r) => r.id), ['adjust-id', 'visit-id']);
    expect(client.requests.map((r) => r.body['kind']), [
      'members',
      'follow_ups',
    ]);
  });

  test('调整表单独立持有会员和选择，同实例防重，预览扣减不低于零', () async {

    final a = MemberAdjustController(row(id: 'a')),
        b = MemberAdjustController(row(id: 'b'));
    a.chooseReason(0);
    a.chooseDirection(1);
    a.changePoints(99999);
    expect(a.afterPoints, '0');
    a.changePoints(50);
    b.changePoints(10);
    b.chooseReason(1);
    final gate = api.gate = Completer<void>();
    final first = a.save();
    expect(await a.save(), isFalse);
    final second = b.save();
    a.changePoints(1000);
    expect(api.writes.map((w) => w['id']), ['a', 'b']);
    expect(api.writes.map((w) => w['points']), [-50, 10]);
    gate.complete();
    await Future.wait([first, second]);
    expect(a.points, 50);
    expect(b.points, 10);

    a.dispose();
    b.dispose();
  });

  test('调整失败保留输入并沿用请求标识，修改输入后使用新标识', () async {
    final c = MemberAdjustController(row(id: 'a'));
    c.chooseReason(2);
    c.changePoints(20);
    c.note.text = '保留的说明';
    api.fail = true;
    await expectLater(c.save(), throwsA(isA<AppError>()));
    await expectLater(c.save(), throwsA(isA<AppError>()));
    expect(api.writes[0]['requestId'], isNotNull);
    expect(api.writes[1]['requestId'], api.writes[0]['requestId']);
    expect(c.note.text, '保留的说明');
    expect(c.reason, 2);
    expect(c.busy, isFalse);
    c.changePoints(30);
    api.fail = false;
    expect(await c.save(), isTrue);
    expect(api.writes[2]['requestId'], isNot(api.writes[0]['requestId']));
    c.dispose();
  });

  test('回访失败保留方式、结果、内容和日期，销毁后晚到结果不通知监听者', () async {
    final c = MemberVisitController(row(id: 'a'));
    c.chooseMethod(1);
    c.chooseResult(2);
    c.content.text = '真实沟通内容';
    c.next = '2026-12-01';
    api.fail = true;
    await expectLater(c.save(), throwsA(isA<AppError>()));
    await expectLater(c.save(), throwsA(isA<AppError>()));
    expect(api.writes[1]['requestId'], api.writes[0]['requestId']);
    expect(c.content.text, '真实沟通内容');
    expect(c.next, '2026-12-01');
    api.fail = false;
    api.gate = Completer<void>();
    var notified = 0;
    c.addListener(() => notified++);
    final save = c.save();
    expect(await c.save(), isFalse);
    c.dispose();
    final before = notified;
    api.gate!.complete();
    expect(await save, isTrue);
    expect(notified, before);
    expect(api.writes.last['id'], 'a');
    expect(api.writes.last['method'], '微信');
  });

  testWidgets('筛选数量只接受最新条件的响应，销毁后不再回写', (t) async {
    api.deferCounts = true;
    final c = MemberFilterController(MemberFilters());
    c.refreshCount();
    await t.pump(const Duration(milliseconds: 400));
    c.chooseBalance(2);
    await t.pump(const Duration(milliseconds: 400));
    expect(api.pendingCounts, hasLength(2));
    api.pendingCounts[1].complete(const MemberPage(items: [], matched: 12));
    await t.pump();
    expect(c.matched, 12);
    api.pendingCounts[0].complete(const MemberPage(items: [], matched: 99));
    await t.pump();
    expect(c.matched, 12);
    c.chooseVisit(3);
    await t.pump(const Duration(milliseconds: 400));
    c.dispose();
    api.pendingCounts[2].complete(const MemberPage(items: [], matched: 1));
    await t.pump();
    expect(c.matched, isNull);
  });

  testWidgets('两份筛选草稿相互独立，重置不修改调用方的已应用条件', (t) async {
    final applied = MemberFilters(tierIds: {'gold'}, balance: 2, visit: 1);
    final a = MemberFilterController(applied),
        b = MemberFilterController(applied);
    a.reset();
    b.chooseVisit(3);
    expect(applied.tierIds, {'gold'});
    expect(applied.balance, 2);
    expect(applied.visit, 1);
    expect(a.filters.active, isFalse);
    expect(b.filters.visit, 3);
    expect(b.filters.tierIds, {'gold'});
    a.dispose();
    b.dispose();
    await t.pump(const Duration(milliseconds: 400));
  });

  testWidgets('卡种读取失败有错误和重试，不能显示设计稿等级冒充本店配置', (t) async {
    phone(t);
    api.cardsFail = true;
    await t.pumpWidget(
      MaterialApp(
        home: MemberAdjustPage(member: row(id: 'a')),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('黑金'), findsNothing);
    api.cardsFail = false;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('调整卡种与积分'), findsOneWidget);
    expect(find.text('普通'), findsWidgets);
  });

  testWidgets('缺少会员参数的调整和回访页面不使用旧全局会员', (t) async {

    for (final page in [const MemberAdjustPage(), const MemberVisitPage()]) {
      await t.pumpWidget(MaterialApp(home: page));
      await t.pumpAndSettle();
      expect(
        t.widget<ErrorView>(find.byType(ErrorView)).error.message,
        '请先选择会员',
      );
    }
    expect(api.writes, isEmpty);
  });

  testWidgets('历史回访晚到不覆盖新会员，历史读取不阻止独立表单填写', (t) async {
    phone(t);
    api.oldHistory = Completer<List<Map<String, dynamic>>>();
    await t.pumpWidget(
      MaterialApp(
        home: MemberVisitPage(member: row(id: 'a')),
      ),
    );
    await t.pump();
    expect(find.byType(TextFormField), findsOneWidget);
    await t.pumpWidget(
      MaterialApp(
        home: MemberVisitPage(member: row(id: 'b')),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('只属于乙'), findsOneWidget);
    api.oldHistory!.complete([
      {'method': '微信', 'result': '旧会员回访', 'content': '只属于甲'},
    ]);
    await t.pumpAndSettle();
    expect(find.text('只属于乙'), findsOneWidget);
    expect(find.text('只属于甲'), findsNothing);
  });

  testWidgets('提醒读取失败不展示示例人数或空列表假装加载完成', (t) async {
    phone(t);
    api.remindersFail = true;
    await t.pumpWidget(const MaterialApp(home: MemberFollowUpPage()));
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('18 位客户'), findsNothing);
    api.remindersFail = false;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('今天没有需要回访的客户'), findsOneWidget);
  });

  test('提醒页签及统计按页面实例隔离', () {
    final a = MemberReminderController(), b = MemberReminderController();
    a.apply({
      'pending': 3,
      'done_today': 1,
      'items': [
        {'kind': '生日', 'member_id': 'a'},
      ],
    });
    b.apply({
      'pending': 2,
      'done_today': 2,
      'items': [
        {'kind': '沉睡客户', 'member_id': 'b'},
      ],
    });
    a.selectTab(3);
    expect(a.items.single['member_id'], 'a');
    expect(b.tab, 0);
    expect(a.view.fraction, 0.25);
    expect(b.view.fraction, 0.5);
    expect(a.markKey('same'), isNot(b.markKey('same')));
    a.dispose();
    b.dispose();
  });

  testWidgets('会员列表搜索的新响应不会被晚到的旧结果覆盖', (t) async {
    phone(t);
    api.rows.add(row(id: 'b', name: '新会员'));
    api.oldList = Completer<MemberPage>();
    await t.pumpWidget(const MaterialApp(home: MembersPage()));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '旧');
    await t.pump(const Duration(milliseconds: 400));
    await t.enterText(find.byType(TextField), '新');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.text('新会员'), findsOneWidget);
    api.oldList!.complete(
      MemberPage(
        items: [row(id: 'a', name: '旧会员')],
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('新会员'), findsOneWidget);
    expect(find.text('旧会员'), findsNothing);
  });
}
