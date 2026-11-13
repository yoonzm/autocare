import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/members/wallet_controller.dart';
import 'package:autocare_merchant/pages/members/wallet_page.dart';
import 'package:autocare_merchant/pages/members/member_picker_sheet.dart';
import 'package:autocare_merchant/pages/members/recharge_pick_sheet.dart';
import 'package:autocare_merchant/pages/members/recharge_page.dart';
import 'package:autocare_merchant/pages/members/packages/member_package_controller.dart';
import 'package:autocare_merchant/pages/members/packages/member_package_route_data.dart';
import 'package:autocare_merchant/pages/members/packages/package_detail_page.dart';

import 'members_test.dart' show MemberFakeApi, row, phone;

class WalletApi extends MemberFakeApi {
  final attempts = <Map<String, dynamic>>[];
  Completer<void>? gate;
  Completer<Map<String, dynamic>>? oldPackage;
  @override
  Future<Map<String, dynamic>> memberPackage(String id) async {
    if (id == 'old') return oldPackage!.future;
    return {'id': id, 'name': '新次卡', 'total_count': 20, 'used_count': 2};
  }

  bool fail = false, refreshFails = false, optionsFail = false;
  @override
  Future<List<Map<String, dynamic>>> rechargeOptions() async {
    if (optionsFail) throw const AppError('读取档位失败', type: AppErrorType.network);
    return super.rechargeOptions();
  }

  @override
  Future<Map<String, dynamic>> member(String id) async {
    if (refreshFails) throw const AppError('会员资料刷新失败');
    return super.member(id);
  }

  @override
  Future<Map<String, dynamic>> recharge({
    required String memberId,
    required num amount,
    required String method,
    String note = '',
    String? requestId,
  }) async {
    attempts.add({
      'member': memberId,
      'amount': amount,
      'method': method,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('暂时无法记账');
    return super.recharge(memberId: memberId, amount: amount, method: method);
  }

  @override
  Future<Map<String, dynamic>> extendPackage({
    required String id,
    required int days,
    required String reason,
    String? requestId,
  }) async {
    attempts.add({
      'id': id,
      'days': days,
      'reason': reason,
      'requestId': requestId,
    });
    await gate?.future;
    if (fail) throw const AppError('延期失败');
    return {'expires_at': '2027-01-01'};
  }
}

class RecordingApi extends MerchantApi {
  final requests = <({Map<String, dynamic> body, String? id})>[];
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = kRequestTimeout,
    String? requestId,
  }) async {
    requests.add((body: body, id: requestId));
    return {'item': <String, dynamic>{}};
  }
}

WalletController controller(WalletApi api, {String id = 'a'}) {
  final c = WalletController(member: row(id: id));
  c.applyOptions(0, {'items': api.rechargeOpts});
  return c;
}

void main() {
  late MerchantApi original;
  late WalletApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = WalletApi();
    api.rows.addAll([row(id: 'a'), row(id: 'b')]);
  });
  tearDown(() {
    merchantApi = original;

  });

  test('三个记账接口把调用者的幂等标识传到请求层', () async {
    final transport = RecordingApi();
    await transport.recharge(
      memberId: 'a',
      amount: 1,
      method: '现金',
      requestId: 'recharge',
    );
    await transport.sellPackage(
      memberId: 'a',
      packageId: 'p',
      method: '现金',
      requestId: 'sale',
    );
    await transport.extendPackage(
      id: 'p',
      days: 30,
      reason: '出差',
      requestId: 'extend',
    );
    expect(transport.requests.map((r) => r.id), [
      'recharge',
      'sale',
      'extend',
    ]);
    expect(transport.requests.map((r) => r.body['action']), [
      'recharge',
      'sell',
      'extend',
    ]);
  });

  test('同一失败收款重试沿用标识，修改金额后创建新标识', () async {
    final c = controller(api);
    api.fail = true;
    await expectLater(c.pay(sale: false), throwsA(isA<AppError>()));
    await expectLater(c.pay(sale: false), throwsA(isA<AppError>()));
    expect(api.attempts[0]['requestId'], isNotNull);
    expect(api.attempts[1]['requestId'], api.attempts[0]['requestId']);
    c.custom.text = '123';
    await expectLater(c.pay(sale: false), throwsA(isA<AppError>()));
    expect(api.attempts[2]['requestId'], isNot(api.attempts[0]['requestId']));
    api.fail = false;
    final result = await c.pay(sale: false);
    expect(api.attempts[3]['requestId'], api.attempts[2]['requestId']);
    expect(result!.data['amount'], 123);
    c.dispose();
  });

  test('两个页面各自提交，同一页面防重复且等待期间固定会员和金额', () async {

    final first = controller(api), second = controller(api, id: 'b');
    second.custom.text = '88';
    api.gate = Completer<void>();
    final a = first.pay(sale: false);
    expect(await first.pay(sale: false), isNull);
    first.selectMember(row(id: 'b'));
    first.selectPreset(0);
    final b = second.pay(sale: false);
    expect(api.attempts.map((r) => r['member']), ['a', 'b']);
    expect(api.attempts.map((r) => r['amount']), [2000, 88]);
    api.gate!.complete();
    final receipts = await Future.wait([a, b]);
    expect(receipts.map((r) => r!.member['id']), ['a', 'b']);

    first.dispose();
    second.dispose();
  });

  test('已记账后资料刷新失败仍交付真实回执，销毁页面也不丢失结果', () async {
    final c = controller(api);
    api.refreshFails = true;
    api.gate = Completer<void>();
    final pending = c.pay(sale: false);
    c.dispose();
    api.gate!.complete();
    final receipt = (await pending)!;
    expect(api.recharges, hasLength(1));
    expect(receipt.data['amount'], 2000);
    expect(receipt.data['gift'], 300);
    expect(receipt.member['balance'], api.rows.first['balance']);
    expect(() => receipt.data['amount'] = 9, throwsUnsupportedError);
    expect(() => receipt.member['id'] = 'b', throwsUnsupportedError);
  });

  testWidgets('档位读取失败展示重试，成功后展示服务端金额', (t) async {
    phone(t);
    api.optionsFail = true;
    await t.pumpWidget(
      MaterialApp(
        home: WalletPage(member: row(id: 'a')),
      ),
    );
    await t.pumpAndSettle();
    expect(t.widget<ErrorView>(find.byType(ErrorView)).error.message, '读取档位失败');
    expect(find.text('¥2,000'), findsNothing);
    api.optionsFail = false;
    api.rechargeOpts = [
      for (final n in [1234, 2345, 3456, 4567]) {'amount': n, 'gift': 0},
    ];
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.text('¥1,234'), findsOneWidget);
    expect(api.attempts, isEmpty);
  });

  testWidgets('套餐弹层取消不改调用者，确认才返回选择', (t) async {
    phone(t);
    final c = WalletController();
    c.applyOptions(1, {
      'items': [
        {'id': 'p1', 'name': '套餐甲', 'price': 100},
        {'id': 'p2', 'name': '套餐乙', 'price': 200},
      ],
    });
    late BuildContext root;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            root = context;
            return const Scaffold();
          },
        ),
      ),
    );
    var picking = c.choosePackage(root);
    await t.pumpAndSettle();
    await t.tap(find.text('套餐乙'));
    Navigator.of(t.element(find.byType(RechargePickSheet))).pop();
    await t.pumpAndSettle();
    await picking;
    expect(c.packageId, 'p1');
    picking = c.choosePackage(root);
    await t.pumpAndSettle();
    await t.tap(find.text('套餐乙'));
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    await picking;
    expect(c.packageId, 'p2');
    c.dispose();
  });

  testWidgets('延期失败保留选择且沿用请求标识，各次卡表单相互独立', (t) async {
    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold();
          },
        ),
      ),
    );
    final first = MemberPackageController(
      MemberPackageRouteData(
        id: 'p1',
        member: row(id: 'a'),
      ),
      {},
    );
    final second = MemberPackageController(
      MemberPackageRouteData(
        id: 'p2',
        member: row(id: 'b'),
      ),
      {},
    );
    first.chooseDays(context, 1);
    first.chooseReason(1);
    second.chooseReason(0);
    api.fail = true;
    final gate = api.gate = Completer<void>();
    final a = first.submit(context);
    await first.submit(context);
    final b = second.submit(context);
    expect(api.attempts.map((r) => r['id']), ['p1', 'p2']);
    gate.complete();
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    await Future.wait([a, b]);
    expect(first.daysIndex, 1);
    expect(first.reasonIndex, 1);
    expect(second.daysIndex, 0);
    expect(second.reasonIndex, 0);
    final retry = first.submit(context);
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    await retry;
    expect(api.attempts[2]['requestId'], api.attempts[0]['requestId']);
    first.chooseDays(context, 2);
    final edited = first.submit(context);
    await t.pump(const Duration(milliseconds: 600));
    await t.pumpAndSettle();
    await edited;
    expect(api.attempts[3]['requestId'], isNot(api.attempts[0]['requestId']));
    await t.pumpAndSettle();
    first.dispose();
    second.dispose();
  });

  testWidgets('缺少次卡参数时明确阻止，不读取旧全局状态', (t) async {

    await t.pumpWidget(
      const MaterialApp(home: Scaffold(body: PackageDetailPage())),
    );
    await t.pumpAndSettle();
    expect(t.widget<ErrorView>(find.byType(ErrorView)).error.message, '请先选择次卡');
    expect(api.attempts, isEmpty);
  });

  testWidgets('复用收款页面更换会员时释放旧输入，不复用旧收款对象', (t) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        home: WalletPage(member: row(id: 'a')),
      ),
    );
    await t.pumpAndSettle();
    final old = t.widget<RechargePage>(find.byType(RechargePage)).controller!;
    old.custom.text = '123';
    await t.pumpWidget(
      MaterialApp(
        home: WalletPage(member: row(id: 'b')),
      ),
    );
    await t.pumpAndSettle();
    final current = t
        .widget<RechargePage>(find.byType(RechargePage))
        .controller!;
    expect(old.disposed, isTrue);
    expect(current.member!['id'], 'b');
    expect(current.custom.text, isEmpty);
    expect(current, isNot(same(old)));
  });

  testWidgets('旧次卡响应晚到不能覆盖新次卡详情', (t) async {
    phone(t);
    api.oldPackage = Completer<Map<String, dynamic>>();
    await t.pumpWidget(
      MaterialApp(
        home: PackageDetailPage(
          data: MemberPackageRouteData(
            id: 'old',
            member: row(id: 'a'),
          ),
        ),
      ),
    );
    await t.pump();
    await t.pumpWidget(
      MaterialApp(
        home: PackageDetailPage(
          data: MemberPackageRouteData(
            id: 'new',
            member: row(id: 'b'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('新次卡'), findsWidgets);
    api.oldPackage!.complete({'id': 'old', 'name': '旧次卡', 'total_count': 30});
    await t.pumpAndSettle();
    expect(find.text('新次卡'), findsWidgets);
    expect(find.text('旧次卡'), findsNothing);
  });

  testWidgets('重叠会员选择弹层各自保留搜索，关闭后不污染全局会员', (t) async {
    phone(t);

    late BuildContext context;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) {
            context = c;
            return const Scaffold();
          },
        ),
      ),
    );
    final a = showMemberPicker(context);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '甲');
    await t.pump(const Duration(milliseconds: 400));
    final b = showMemberPicker(context);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '乙');
    await t.pump(const Duration(milliseconds: 400));
    Navigator.of(t.element(find.byType(MemberPickerSheet).last)).pop();
    await t.pumpAndSettle();
    await b;
    expect(t.widget<TextField>(find.byType(TextField)).controller!.text, '甲');
    Navigator.of(t.element(find.byType(MemberPickerSheet).last)).pop();
    await t.pumpAndSettle();
    await a;

  });
}
