import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:autocare_merchant/backend/access_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/st_member_info_template.dart';
import 'package:autocare_merchant/pages/st_member_template.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'members_test.dart' show phone;
import 'staff_work_test.dart' show WorkApi;

/// 员工端会员查询 / 简况的假后端：只返回脱敏信息。
class MemberLookupApi extends WorkApi {
  @override
  Future<Map<String, dynamic>> staffWork(String action, [Map<String, dynamic> values = const {}]) async {
    if (action == 'staff_member_search') {
      calls.add({'action': action, ...values});
      final q = '${values['q'] ?? ''}';
      if (q == '无此人') return {'items': []};
      return {
        'items': [
          {'id': 'm1', 'name': '王建国', 'level': '黑金卡', 'phone_masked': '138****6021', 'plate': '沪A8K29M'},
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
          {'id': 'p1', 'name': '精致洗车年卡', 'remaining': 12, 'total': 30, 'expires_at': '2027-03-31T12:00:00Z'},
        ],
      };
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
    StMemberFlow.currentId = null;
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
    expect(api.calls.where((c) => c['action'] == 'staff_member_search').first['q'], '');
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('138****6021 · 沪A8K29M'), findsOneWidget);
  });

  testWidgets('会员简况：余额 / 积分 / 次卡 / 爱车来自服务端', (t) async {
    phone(t);
    StMemberFlow.currentId = 'm1';
    await t.pumpWidget(const MaterialApp(home: StMemberInfoLivePage()));
    await t.pumpAndSettle();
    expect(api.calls.where((c) => c['action'] == 'staff_member_info').single['id'], 'm1');
    expect(find.text('王建国'), findsOneWidget);
    expect(find.text('¥3,680'), findsOneWidget);
    expect(find.text('12,450'), findsOneWidget);
    expect(find.text('精致洗车年卡'), findsOneWidget);
    expect(find.text('剩余 12 次 · 2027.03.31 到期'), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('沪A8K29M'), findsOneWidget);
  });
}
