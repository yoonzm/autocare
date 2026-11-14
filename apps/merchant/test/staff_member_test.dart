import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/staff_app/st_cash_queue_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_info_template.dart';
import 'package:autocare_merchant/pages/staff_app/st_member_template.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'members_test.dart' show phone;
import 'staff_work_test.dart' show WorkApi;

/// 员工端会员查询 / 简况的假后端：只返回脱敏信息。
class MemberLookupApi extends WorkApi {
  @override
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    if (action == 'staff_member_search') {
      calls.add({'action': action, ...values});
      final q = '${values['q'] ?? ''}';
      if (q == '无此人') return {'items': []};
      return {
        'items': [
          {
            'id': 'm1',
            'name': '王建国',
            'level': '黑金卡',
            'phone_masked': '138****6021',
            'plate': '沪A8K29M',
          },
        ],
      };
    }
    if (action == 'staff_member_info') {
      calls.add({'action': action, ...values});
      return {
        'id': 'm1',
        'name': '王建国',
        'level': '黑金卡',
        'phone_masked': '138****6021',
        'balance': 3680,
        'points': 12450,
        'vehicles': [
          {'plate': '沪A8K29M', 'model': '宝马 5 系', 'color': '黑色', 'ev': false},
        ],
        'packages': [
          {
            'id': 'p1',
            'name': '精致洗车年卡',
            'remaining': 12,
            'total': 30,
            'expires_at': '2027-03-31T12:00:00Z',
            'items': [
              {'service_id': 's1', 'name': '精致洗车', 'remaining': 12},
            ],
          },
        ],
      };
    }
    if (action == 'staff_cash_queue') {
      calls.add({'action': action, ...values});
      return {
        'items': [
          {
            'id': 'h1',
            'member_id': 'm1',
            'vehicle_plate': '沪A8K29M',
            'created_at': '2026-11-10T02:42:00Z',
            'member': {
              'id': 'm1',
              'name': '王建国',
              'phone': '138****6021',
              'card': {'name': '黑金卡'},
            },
            'submitter': {'name': '老周', 'role': 'technician'},
            'items': [
              {'service_id': 's1', 'name': '精致洗车', 'qty': 1},
            ],
            'lines': [
              {'name': '精致洗车', 'qty': 1, 'unit_price': 68},
            ],
            'quote': {
              'subtotal': 68,
              'card_off': 0,
              'discount_off': 7,
              'payable': 61,
            },
          },
        ],
      };
    }
    if (action == 'staff_order_return' ||
        action == 'staff_redeem_send' ||
        action == 'staff_redeem') {
      calls.add({'action': action, ...values});
      if (action == 'staff_redeem_send') {
        return {'ok': true, 'retry_after': 60, 'expires_in': 300};
      }
      if (action == 'staff_redeem') {
        return {'package': '精致洗车年卡', 'service': '精致洗车', 'remaining': 11};
      }
      return {'ok': true};
    }
    return super.staffWork(action, values);
  }
}

void main() {
  late MerchantApi original;
  late MemberLookupApi api;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    original = merchantApi;
    merchantApi = api = MemberLookupApi();
    navTracker.stack.clear();
    Access.apply({...api.identityCtx});
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
    Access.role = 'owner';
    Access.caps = const {};
    Access.context = const {};
  });

  testWidgets('会员查询：默认列出最近到店，号码已脱敏', (t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: StMemberLivePage()));
    await t.pumpAndSettle();
    expect(
      api.calls.where((c) => c['action'] == 'staff_member_search').first['q'],
      '',
    );
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('138****6021 · 沪A8K29M'), findsOneWidget);
  });

  testWidgets('会员简况：余额 / 积分 / 次卡 / 爱车来自服务端', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(home: StMemberInfoLivePage(memberId: 'm1')),
    );
    await t.pumpAndSettle();
    expect(
      api.calls.where((c) => c['action'] == 'staff_member_info').single['id'],
      'm1',
    );
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('¥3,680'), findsOneWidget);
    expect(find.text('12,450'), findsOneWidget);
    expect(find.text('精致洗车年卡'), findsOneWidget);
    expect(find.text('剩余 12 次 · 2027.03.31 到期'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('沪A8K29M'), findsOneWidget);
  });

  testWidgets('待收银：显示技师提交的单、服务端估价，退回会通知提交人', (t) async {
    phone(t);
    await t.pumpWidget(const MaterialApp(home: StCashQueueLivePage()));
    await t.pumpAndSettle();
    expect(find.text('沪A8K29M'), findsOneWidget);
    expect(find.text('提交人 老周（技师）'), findsOneWidget);
    expect(find.text('¥61'), findsOneWidget);
    expect(find.text('-¥7'), findsOneWidget);
    await t.tap(find.text('退回修改'));
    await t.pumpAndSettle();
    expect(
      api.calls.where((c) => c['action'] == 'staff_order_return').single['id'],
      'h1',
    );
  });

  testWidgets('次卡核销：先给会员发验证码，再带验证码核销', (t) async {
    phone(t);
    await t.pumpWidget(
      const MaterialApp(home: StMemberInfoLivePage(memberId: 'm1')),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('次卡核销'));
    await t.pumpAndSettle();
    await t.tap(find.text('精致洗车年卡 · 精致洗车（剩余 12 次）'));
    await t.pump();
    await t.tap(find.text('发送验证码'));
    await t.pumpAndSettle();
    expect(
      api.calls
          .where((c) => c['action'] == 'staff_redeem_send')
          .single['member_id'],
      'm1',
    );
    await t.enterText(find.byType(TextField), '123456');
    await t.tap(find.text('确认核销'));
    await t.pumpAndSettle();
    final redeem = api.calls.where((c) => c['action'] == 'staff_redeem').single;
    expect(redeem['code'], '123456');
    expect(redeem['member_package_id'], 'p1');
    expect(redeem['service_id'], 's1');
  });
}
