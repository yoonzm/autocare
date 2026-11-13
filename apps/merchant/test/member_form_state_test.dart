import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/members/member_add_done_page.dart';
import 'package:autocare_merchant/pages/members/member_edit_page.dart';
import 'package:autocare_merchant/pages/members/member_form_controller.dart';
import 'package:autocare_merchant/pages/members/member_records_live_page.dart';
import 'package:autocare_merchant/pages/members/member_detail_page.dart';

import 'members_test.dart' show MemberFakeApi, row, phone;

typedef LedgerPage = ({List<Map<String, dynamic>> items, int total});

class FormApi extends MemberFakeApi {
  Completer<void>? saveGate;
  Completer<LedgerPage>? oldLedger;
  Completer<Map<String, dynamic>>? oldMember;
  final writes = <Map<String, dynamic>>[];
  final ledgerIds = <String>[];
  @override
  Future<Map<String, dynamic>> member(String id) async {
    if (id == 'old' && oldMember != null) return oldMember!.future;
    return super.member(id);
  }

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    writes.add({'kind': kind, ...values});
    await saveGate?.future;
    return super.save(kind, values);
  }

  @override
  Future<LedgerPage> ledger(
    String memberId, {
    String filter = 'all',
    int offset = 0,
    int limit = 30,
  }) async {
    ledgerIds.add(memberId);
    if (memberId == 'old' && oldLedger != null) return oldLedger!.future;
    return (items: <Map<String, dynamic>>[], total: 0);
  }
}

void main() {
  late MerchantApi original;
  late FormApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = FormApi();
  });
  tearDown(() {
    merchantApi = original;

  });

  test('两个编辑表单按各自快照提交，实例间不串字段且同实例防重复', () async {
    final first = MemberFormController(
      MemberFormKind.edit,
      member: row(id: 'a', name: '甲'),
    );
    final second = MemberFormController(
      MemberFormKind.edit,
      member: row(id: 'b', name: '乙'),
    );
    first.input('name').text = '甲的新姓名';
    second.input('name').text = '乙的新姓名';
    final gate = api.saveGate = Completer<void>();
    final a = first.save();
    expect(await first.save(), isNull);
    final b = second.save();
    expect(api.writes.map((w) => w['id']), ['a', 'b']);
    expect(api.writes.map((w) => w['name']), ['甲的新姓名', '乙的新姓名']);
    gate.complete();
    await Future.wait([a, b]);
    expect(first.text('name'), '甲的新姓名');
    expect(second.text('name'), '乙的新姓名');
    first.dispose();
    second.dispose();
  });

  test('服务端拒绝后保留输入和选择，修正后可以重试', () async {
    final c = MemberFormController(MemberFormKind.create);
    c.input('phone').text = '13912345678';
    c.input('name').text = '客户';
    c.set('color', '红色');
    api.saveError = const AppError('手机号重复');
    await expectLater(c.save(), throwsA(isA<AppError>()));
    expect(c.busy, isFalse);
    expect(c.text('phone'), '13912345678');
    expect(c.text('color'), '红色');
    api.saveError = null;
    c.input('phone').text = '13912345679';
    final result = await c.save();
    expect(result!['phone'], '13912345679');
    c.dispose();
  });

  test('车辆保存使用固定所属会员，识别空颜色不覆盖已有输入', () async {
    final owner = row(id: 'a');
    final c = MemberFormController(MemberFormKind.vehicle, member: owner);
    owner['id'] = 'b';
    c.set('color', '红色');
    c.input('vin').text = '12345678901234567';
    c.applyVehicle({'plate': '粤BD12345', 'brand_model': '实际车型', 'color': ''});
    await c.save();
    final sent = api.savedVehicles.single;
    expect(sent['member_id'], 'a');
    expect(sent['plate'], '粤BD12345');
    expect(sent['energy'], 'ev');
    expect(sent['brand_model'], '实际车型');
    expect(sent['color'], '红色');
    expect(sent['vin'], '12345678901234567');
    c.dispose();
  });

  test('销毁表单后晚到失败不通知已销毁的监听者', () async {
    final c = MemberFormController(MemberFormKind.edit, member: row());
    var notifications = 0;
    c.addListener(() => notifications++);
    final gate = api.saveGate = Completer<void>();
    api.saveError = const AppError('请求失败');
    final pending = expectLater(c.save(), throwsA(isA<AppError>()));
    c.dispose();
    final before = notifications;
    gate.complete();
    await pending;
    expect(notifications, before);
  });

  testWidgets('缺少会员参数的编辑页阻止打开，不读取全局旧会员', (t) async {

    await t.pumpWidget(const MaterialApp(home: MemberEditPage()));
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('全局旧会员'), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    expect(api.writes, isEmpty);
  });

  testWidgets('结果页需要明确的办卡回执，不借用之前的全局会员', (t) async {

    await t.pumpWidget(const MaterialApp(home: MemberAddDonePage()));
    await t.pumpAndSettle();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('全局旧会员'), findsNothing);
  });

  testWidgets('切换流水会员后，旧请求失败不能覆盖新会员页面', (t) async {
    phone(t);
    api.oldLedger = Completer<LedgerPage>();
    await t.pumpWidget(
      MaterialApp(
        home: MemberRecordsLivePage(
          member: row(id: 'old', name: '旧会员'),
        ),
      ),
    );
    await t.pump(const Duration(milliseconds: 100));
    expect(api.ledgerIds, contains('old'));
    await t.pumpWidget(
      MaterialApp(
        home: MemberRecordsLivePage(
          member: row(id: 'new', name: '新会员'),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(api.ledgerIds.last, 'new');
    api.oldLedger!.completeError(const AppError('旧会员请求失败'));
    await t.pumpAndSettle();
    expect(find.text('新会员 · 金卡会员'), findsOneWidget);
    expect(find.text('旧会员请求失败'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('复用详情宿主后丢弃旧会员响应，后台刷新不改全局当前会员', (t) async {
    phone(t);
    api.oldMember = Completer<Map<String, dynamic>>();
    final next = row(id: 'new', name: '新会员');
    api.rows.add(next);

    await t.pumpWidget(
      MaterialApp(
        home: MemberDetailPage(
          member: memberFromRow(row(id: 'old', name: '旧会员')),
        ),
      ),
    );
    await t.pump();
    await t.pumpWidget(
      MaterialApp(home: MemberDetailPage(member: memberFromRow(next))),
    );
    await t.pumpAndSettle();
    api.oldMember!.complete(row(id: 'old', name: '旧会员晚到数据'));
    await t.pumpAndSettle();
    expect(find.text('新会员'), findsOneWidget);
    expect(find.text('旧会员晚到数据'), findsNothing);

  });
}
