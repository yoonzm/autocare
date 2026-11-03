import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/member_detail_page.dart';
import 'package:autocare_merchant/pages/order_page.dart';
import 'package:autocare_merchant/pages/members_page.dart';
import 'package:autocare_merchant/routes.dart';

import 'packages_test.dart' show pkgRow;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MemberFakeApi extends MerchantApi {
  final tiers = <Map<String, dynamic>>[
    {'id': 't-base', 'name': '普通会员'},
    {'id': 't-gold', 'name': '金卡'},
  ];
  final rows = <Map<String, dynamic>>[];
  final saved = <Map<String, dynamic>>[];
  final savedVehicles = <Map<String, dynamic>>[];
  final deleted = <String>[];
  final listCalls = <({String? q, String? tier})>[];
  final filterCalls = <Map<String, Object?>>[];
  Object? listError;
  Duration listDelay = Duration.zero;
  Object? saveError;

  @override
  bool get hasSession => true;

  @override
  Future<Map<String, dynamic>> homeStats() async => {
    'date': '2026-11-03',
    'revenue': 0,
    'orders': 0,
    'new_members': 0,
    'average': 0,
    'change_percent': null,
    'daily_revenue': [0, 0, 0, 0, 0, 0, 0],
    'recharge': 0,
  };

  int serviceCalls = 0;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    if (kind == 'services') serviceCalls++;
    // 真实接口每次返回新的列表
    return kind == 'cards'
        ? [...tiers]
        : kind == 'packages'
        ? [...packages]
        : kind == 'services'
        ? [...services]
        : const [];
  }

  final services = <Map<String, dynamic>>[];
  final checkouts = <Map<String, dynamic>>[];
  Object? checkoutError;
  @override
  Future<Map<String, dynamic>> checkout({
    required String memberId,
    required List<Map<String, dynamic>> lines,
    required String method,
    num? balancePart,
    String? other,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    if (checkoutError != null) throw checkoutError!;
    checkouts.add({
      'member': memberId,
      'lines': lines,
      'method': method,
      'plate': plate,
      'hold': holdId,
    });
    if (holdId != null) holdRows.removeWhere((h) => h['id'] == holdId);
    return {
      'items': '精致洗车 · 内饰深度清洁',
      'subtotal': 448,
      'card_off': 68,
      'discount_off': 19,
      'discount': 0.95,
      'card_name': '金卡',
      'payable': 361,
      'balance_paid': 361,
      'pay_method': method,
      'balance': 3319,
      'points_gained': 541,
    };
  }

  final walkIns = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> checkoutWalkIn({
    required List<Map<String, dynamic>> lines,
    required String method,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    walkIns.add({
      'lines': lines,
      'method': method,
      'plate': plate,
      'hold': holdId,
    });
    if (holdId != null) holdRows.removeWhere((h) => h['id'] == holdId);
    return {
      'items': '精致洗车',
      'subtotal': 68,
      'card_off': 0,
      'discount_off': 0,
      'discount': 1,
      'card_name': '散客',
      'payable': 68,
      'balance_paid': 0,
      'pay_method': method,
      'points_gained': 0,
    };
  }

  // 挂单
  final holdRows = <Map<String, dynamic>>[];
  final heldSaves = <Map<String, dynamic>>[];
  final heldCancelled = <String>[];
  Object? holdsError;
  Object? holdSaveError;
  @override
  Future<List<Map<String, dynamic>>> holds() async {
    if (holdsError != null) throw holdsError!;
    return [...holdRows];
  }

  @override
  Future<Map<String, dynamic>> saveHold({
    String? holdId,
    String? memberId,
    required List<Map<String, dynamic>> lines,
    String status = '待施工',
    String note = '',
    String remind = '不提醒',
    String plate = '',
  }) async {
    if (holdSaveError != null) throw holdSaveError!;
    heldSaves.add({
      'hold': holdId,
      'member': memberId,
      'lines': lines,
      'status': status,
      'note': note,
      'remind': remind,
      'plate': plate,
    });
    final row = {
      'id': holdId ?? 'h${holdRows.length + 1}',
      'member_id': memberId,
      'status': status,
      'note': note,
      'remind': remind,
      'vehicle_plate': plate,
      'estimate': 342,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
      'member': memberId == null
          ? null
          : {
              'id': memberId,
              'name': '王建国',
              'card': {'name': '金卡'},
            },
      'items': [
        for (var i = 0; i < lines.length; i++)
          {
            'position': i,
            'service_id': lines[i]['service_id'],
            'name': '项目${i + 1}',
            'qty': 1,
          },
      ],
    };
    holdRows
      ..removeWhere((h) => h['id'] == row['id'])
      ..insert(0, row);
    return row;
  }

  @override
  Future<void> cancelHold(String id) async {
    heldCancelled.add(id);
    holdRows.removeWhere((h) => h['id'] == id);
  }

  final packages = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> rechargeOpts = [
    {'amount': 1000, 'gift': 100},
    {'amount': 2000, 'gift': 300},
    {'amount': 5000, 'gift': 1000},
    {'amount': 10000, 'gift': 2500},
  ];
  @override
  Future<List<Map<String, dynamic>>> rechargeOptions() async => [
    ...rechargeOpts,
  ];
  final visits = <Map<String, dynamic>>[];
  final followHistory = <Map<String, dynamic>>[];
  final marked = <String>[];
  Map<String, dynamic> reminderData = {
    'items': <Map<String, dynamic>>[],
    'counts': <String, dynamic>{},
    'pending': 0,
    'done_today': 0,
  };
  @override
  Future<List<Map<String, dynamic>>> followUps(String memberId) async => [
    ...followHistory,
  ];

  @override
  Future<void> saveFollowUp({
    required String memberId,
    required String method,
    required String result,
    String content = '',
    String? nextAt,
  }) async {
    visits.add({
      'member': memberId,
      'method': method,
      'result': result,
      'content': content,
      'next': nextAt,
    });
  }

  @override
  Future<void> markFollowedUp(String memberId, {String content = ''}) async {
    marked.add(memberId);
    final items = List<Map<String, dynamic>>.from(reminderData['items'] as List)
      ..removeWhere((e) => e['member_id'] == memberId);
    reminderData = {
      ...reminderData,
      'items': items,
      'pending': items.length,
      'done_today': (reminderData['done_today'] as int) + 1,
    };
  }

  @override
  Future<Map<String, dynamic>> reminders() async => reminderData;

  final memberPkgs = <Map<String, dynamic>>[];
  final extended = <Map<String, dynamic>>[];
  final refunded = <Map<String, dynamic>>[];
  @override
  Future<List<Map<String, dynamic>>> memberPackages(String memberId) async => [
    ...memberPkgs,
  ];

  @override
  Future<Map<String, dynamic>> memberPackage(String id) async =>
      memberPkgs.firstWhere((e) => e['id'] == id);

  @override
  Future<Map<String, dynamic>> extendPackage({
    required String id,
    required int days,
    required String reason,
  }) async {
    extended.add({'id': id, 'days': days, 'reason': reason});
    final p = memberPkgs.firstWhere((e) => e['id'] == id);
    p['expires_at'] = DateTime.parse('${p['expires_at']}')
        .add(Duration(days: days))
        .toIso8601String();
    return {'expires_at': p['expires_at']};
  }

  @override
  Future<Map<String, dynamic>> refundPackage({
    required String id,
    required String to,
    required String reason,
  }) async {
    refunded.add({'id': id, 'to': to, 'reason': reason});
    final p = memberPkgs.firstWhere((e) => e['id'] == id);
    p['refunded_at'] = DateTime.now().toIso8601String();
    return {'refund': 432, 'balance': 4112};
  }

  final sales = <Map<String, dynamic>>[];
  Object? sellError;
  @override
  Future<Map<String, dynamic>> sellPackage({
    required String memberId,
    required String packageId,
    required String method,
  }) async {
    if (sellError != null) throw sellError!;
    sales.add({'member': memberId, 'package': packageId, 'method': method});
    final p = packages.firstWhere((e) => e['id'] == packageId);
    final m = rows.firstWhere((r) => r['id'] == memberId);
    if (method == '会员余额') m['balance'] = (m['balance'] as num) - p['price'];
    return {
      'price': p['price'],
      'original_price': 1360,
      'total_count': 20,
      'expires_at': '2027-11-01T08:00:00Z',
      'balance': m['balance'],
      'points_gained': p['price'],
    };
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
    listCalls.add((q: query, tier: cardTypeId));
    filterCalls.add({
      'ids': cardTypeIds,
      'min': balanceMin,
      'max': balanceMax,
      'within': visitedWithinDays,
      'over': visitedOverDays,
    });
    if (listDelay > Duration.zero) await Future<void>.delayed(listDelay);
    if (listError != null) throw listError!;
    final items = [
      for (final r in rows)
        if ((cardTypeId == null || r['card_type_id'] == cardTypeId) &&
            (query == null ||
                '${r['name']}${r['phone']}'.contains(query) ||
                (r['vehicles'] as List).any(
                  (v) => '${(v as Map)['plate']}'.contains(query),
                )))
          r,
    ];
    final counts = <String, int>{};
    for (final r in rows) {
      counts['${r['card_type_id']}'] =
          (counts['${r['card_type_id']}'] ?? 0) + 1;
    }
    return MemberPage(
      items: (recent ? items.reversed.toList() : items)
          .skip(offset)
          .take(limit)
          .toList(),
      counts: counts,
      total: rows.length,
      matched: items.length,
      totalBalance: rows.fold<num>(
        0,
        (s, r) => s + (r['balance'] as num? ?? 0),
      ),
    );
  }

  @override
  Future<Map<String, dynamic>> member(String id) async =>
      rows.firstWhere((r) => r['id'] == id);

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    if (saveError != null) throw saveError!;
    if (kind == 'vehicles') {
      savedVehicles.add(values);
      return {'item': values};
    }
    saved.add(values);
    final id = values['id']?.toString() ?? 'm-${rows.length + 1}';
    final row = <String, dynamic>{
      'id': id,
      'card_type_id': 't-base',
      'card': {'name': '普通会员', 'discount': 1, 'points_multiplier': 1},
      'vehicles': <Map<String, dynamic>>[],
      'created_at': '2026-11-02T04:30:00Z',
      ...?rows.where((r) => r['id'] == id).firstOrNull,
      ...values,
    };
    final v = values['vehicle'];
    if (v is Map) row['vehicles'] = [v];
    rows
      ..removeWhere((r) => r['id'] == id)
      ..add(row);
    return {'item': row};
  }

  final adjusts = <Map<String, dynamic>>[];
  @override
  Future<void> adjustMember({
    required String memberId,
    String? tierId,
    int points = 0,
    required String reason,
    String note = '',
  }) async {
    adjusts.add({
      'id': memberId,
      'tier_id': tierId,
      'points': points,
      'reason': reason,
    });
    final m = rows.firstWhere((r) => r['id'] == memberId);
    if (tierId != null) m['card_type_id'] = tierId;
    m['points'] = (m['points'] as num) + points;
  }

  final ledgerItems = <Map<String, dynamic>>[];
  final ledgerCalls = <String>[];
  @override
  Future<({List<Map<String, dynamic>> items, int total})> ledger(
    String memberId, {
    String filter = 'all',
    int offset = 0,
    int limit = 30,
  }) async {
    ledgerCalls.add(filter);
    final items = [
      for (final e in ledgerItems)
        if (filter == 'all' || e['kind'] == filter) e,
    ];
    return (
      items: items.skip(offset).take(limit).toList(),
      total: items.length,
    );
  }

  final recharges = <Map<String, dynamic>>[];
  @override
  Future<Map<String, dynamic>> recharge({
    required String memberId,
    required num amount,
    required String method,
    String note = '',
  }) async {
    if (saveError != null) throw saveError!;
    recharges.add({'id': memberId, 'amount': amount, 'method': method});
    final gift = {1000: 100, 2000: 300, 5000: 1000, 10000: 2500}[amount] ?? 0;
    final m = rows.firstWhere((r) => r['id'] == memberId);
    m['balance'] = (m['balance'] as num) + amount + gift;
    return {
      'gift': gift,
      'balance': m['balance'],
      'points_gained': amount,
      'upgraded_to': null,
    };
  }

  @override
  Future<void> delete(String kind, String id) async {
    deleted.add('$kind:$id');
    rows.removeWhere((r) => r['id'] == id);
  }
}

Map<String, dynamic> row({
  String id = 'm1',
  String name = '王建国',
  String phone = '13816826021',
  String tier = 't-gold',
  String tierName = '金卡',
  List<Map<String, dynamic>> vehicles = const [],
}) => {
  'id': id,
  'name': name,
  'phone': phone,
  'honorific': '先生',
  'birthday': '1985-06-12',
  'note': '',
  'card_type_id': tier,
  'card': {'name': tierName, 'discount': 0.95, 'points_multiplier': 1.5},
  'vehicles': vehicles,
  'balance': 3680,
  'points': 12450,
  'total_spent': 28450,
  'total_recharged': 0,
  'visit_count': 46,
  'created_at': '2026-10-01T08:00:00Z',
};

void phone(WidgetTester t) {
  t.view.physicalSize = const Size(390 * 3, 1000 * 3);
  t.view.devicePixelRatio = 3;
  addTearDown(t.view.reset);
  // 测试字体比真机宽，生成页偶尔“溢出几个像素”，不是这里要验证的内容
  final old = FlutterError.onError;
  FlutterError.onError = (d) {
    if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
  };
  addTearDown(() => FlutterError.onError = old);
}

Widget app(Widget home) =>
    MaterialApp(navigatorObservers: [navTracker], home: home);

/// 从“会员详情”这样的有名字的页面进入（和真实流程一致：从会员详情进入充值要带着会员）。
Widget appFromDetail(Widget home) => MaterialApp(
  navigatorObservers: [navTracker],
  initialRoute: 'MemberDetail',
  onGenerateRoute: (s) => MaterialPageRoute(settings: s, builder: (_) => home),
);

void main() {
  late MerchantApi original;
  late MemberFakeApi fake;
  setUp(() {
    original = merchantApi;
    fake = MemberFakeApi();
    merchantApi = fake;
    CatalogDraft.current = null;
    MemberFlow.current = null;
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    CatalogDraft.current = null;
    MemberFlow.current = null;
    navTracker.stack.clear();
  });

  group('会员列表', () {
    testWidgets('加载慢时显示 5 行骨架，之后是真实会员，卡种页签带数量', (t) async {
      phone(t);
      fake.listDelay = const Duration(milliseconds: 900);
      fake.rows.addAll([
        row(
          vehicles: [
            {'plate': '沪A8K29M', 'brand_model': '宝马 5系', 'energy': 'fuel'},
          ],
        ),
        row(
          id: 'm2',
          name: '林晓雯',
          phone: '13917630412',
          tier: 't-base',
          tierName: '普通会员',
        ),
      ]);
      await t.pumpWidget(app(const MembersPage()));
      await t.pump(const Duration(milliseconds: 400));
      expect(find.byType(SkeletonRow), findsNWidgets(5));
      await t.pumpAndSettle();
      expect(find.text('王建国'), findsOneWidget);
      expect(find.text('林晓雯'), findsOneWidget);
      expect(find.textContaining('沪A·8K29M'), findsOneWidget);
      expect(find.text('未登记车辆 · 还没到过店'), findsOneWidget);
      expect(find.text('全部 2'), findsOneWidget);
      expect(find.text('普通会员 1'), findsOneWidget);
      expect(find.text('金卡 1'), findsOneWidget);
      // 余额是真实数据（测试里每位会员 ¥3,680）
      expect(find.text('¥3,680'), findsNWidgets(2));
    });

    testWidgets('点卡种页签按卡种筛选，搜索按关键字重新请求', (t) async {
      phone(t);
      fake.rows.addAll([
        row(),
        row(id: 'm2', name: '林晓雯', phone: '13917630412', tier: 't-base'),
      ]);
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      await t.tap(find.text('金卡 1'));
      await t.pumpAndSettle();
      expect(fake.listCalls.last.tier, 't-gold');
      expect(find.text('王建国'), findsOneWidget);
      expect(find.text('林晓雯'), findsNothing);

      await t.tap(find.text('全部 2'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), '林晓');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(fake.listCalls.last.q, '林晓');
      expect(find.text('林晓雯'), findsOneWidget);
      expect(find.text('王建国'), findsNothing);
    });

    testWidgets('没有会员：引导新增；搜不到：给“重置筛选”', (t) async {
      phone(t);
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      expect(find.text('还没有会员'), findsOneWidget);
      expect(find.text('新增会员'), findsWidgets);

      fake.rows.add(row());
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), '不存在');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(find.text('重置筛选'), findsOneWidget);
    });

    testWidgets('加载失败：整页错误 + 重试', (t) async {
      phone(t);
      fake.listError = const AppError('网络异常，请稍后重试', type: AppErrorType.network);
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      expect(find.text('重试'), findsOneWidget);
      fake
        ..listError = null
        ..rows.add(row());
      await t.tap(find.text('重试'));
      await t.pumpAndSettle();
      expect(find.text('王建国'), findsOneWidget);
    });

    testWidgets('筛选面板：按卡种 / 储值余额 / 最近到店筛选，次卡状态和车辆项目只提示', (t) async {
      phone(t);
      fake.tiers
        ..clear()
        ..addAll([
          {'id': 't-base', 'name': '普通会员'},
          {'id': 't-silver', 'name': '银卡', 'upgrade_recharge': 2000},
          {'id': 't-gold', 'name': '金卡', 'upgrade_recharge': 5000},
          {'id': 't-black', 'name': '黑金卡', 'upgrade_recharge': 10000},
        ]);
      fake.rows.addAll([row(), row(id: 'm2', name: '林晓雯', tier: 't-base')]);
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('筛选会员'));
      await t.pumpAndSettle();
      expect(navTracker.has('sheet:MemberFilter'), isTrue);
      expect(find.text('筛选会员'), findsOneWidget);
      // 选卡种、余额、最近到店后点“查看”，列表按条件重新请求
      await t.tap(find.text('银卡').first);
      await t.pump();
      await t.tap(find.text('¥500–2,000').first);
      await t.pump();
      await t.tap(find.text('30 天内').first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      // 次卡状态 / 车辆项目依赖其他模块：点了只提示，不产生筛选
      await t.ensureVisible(find.text('已用完').first);
      await t.tap(find.text('已用完').first);
      await t.pump();
      expect(find.textContaining('次卡状态、车辆与项目筛选暂未接通'), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.ensureVisible(find.textContaining('位会员'));
      await t.tap(find.textContaining('位会员'));
      await t.pumpAndSettle();
      expect(fake.filterCalls.last['ids'], ['t-silver']);
      expect(fake.filterCalls.last['min'], 500);
      expect(fake.filterCalls.last['max'], 2000);
      expect(fake.filterCalls.last['within'], 30);
      expect(navTracker.has('sheet:MemberFilter'), isFalse);
    });
  });

  group('办卡（新增会员）', () {
    Future<void> openAdd(WidgetTester t) async {
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  MemberFlow.beginAdd();
                  openRoute(context, 'MemberAdd');
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('表单从空白开始；手机号 / 姓名没填时说明原因，不请求后端', (t) async {
      phone(t);
      await openAdd(t);
      final fields = find.byType(TextFormField);
      expect(t.widget<TextFormField>(fields.at(0)).initialValue, isEmpty);
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(find.text('请输入正确的 11 位手机号'), findsOneWidget);
      expect(fake.saved, isEmpty);
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.enterText(fields.at(0), '13988888812');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      // 输入框的占位文字 + 提示条各一个
      expect(find.text('请输入客户姓名'), findsNWidgets(2));
      expect(fake.saved, isEmpty);
    });

    testWidgets('所有输入框没值时都有占位文字', (t) async {
      phone(t);
      await openAdd(t);
      for (final f in t.widgetList<TextField>(find.byType(TextField))) {
        if (f.controller?.text.isNotEmpty ?? false) continue;
        expect(f.decoration?.hintText, isNotEmpty);
      }
      expect(find.text('请输入手机号'), findsOneWidget);
      expect(find.text('请输入客户姓名'), findsOneWidget);
      expect(find.text('如：车主偏好、车辆旧伤位置'), findsOneWidget);
    });

    testWidgets('填好后保存：提交手机号 / 姓名 / 称呼，进入开卡成功页并显示真实资料', (t) async {
      phone(t);
      await openAdd(t);
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), '139 1688 5530');
      await t.enterText(fields.at(1), '李敏');
      await t.tap(find.text('女士'));
      await t.pump();
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      final sent = fake.saved.single;
      expect(sent['phone'], '13916885530');
      expect(sent['name'], '李敏');
      expect(sent['honorific'], '女士');
      expect(sent.containsKey('vehicle'), isFalse); // 没填车牌就不登记车辆
      // 开卡成功页：显示后端返回的会员，而不是设计稿的“李女士 / 139 **** 5530”示例
      expect(find.text('开卡成功'), findsOneWidget);
      expect(find.text('李女士'), findsWidgets);
      expect(find.text('139 **** 5530'), findsOneWidget);
      expect(find.text('普通会员'), findsWidgets);
      expect(find.text('未登记车辆'), findsOneWidget);
    });

    testWidgets('手机号已是会员：云函数拒绝，Toast 说明原因，仍停留在表单', (t) async {
      phone(t);
      fake.saveError = const AppError('该手机号已是会员');
      await openAdd(t);
      final fields = find.byType(TextFormField);
      await t.enterText(fields.at(0), '13816826021');
      await t.enterText(fields.at(1), '王建国');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(find.text('该手机号已是会员'), findsOneWidget);
      expect(find.text('开卡成功'), findsNothing);
      expect(find.text('新增会员'), findsWidgets);
    });

    testWidgets('开卡成功页的“去充值”依赖支付模块：只提示，不假装成功', (t) async {
      phone(t);
      MemberFlow.current = row(tier: 't-base', tierName: '普通会员');
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberAddDone'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('去充值'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('余额充值暂未接通'), findsOneWidget);
      expect(navTracker.has('Recharge'), isFalse);
    });
  });

  group('详情 / 修改资料 / 车辆 / 删除', () {
    final detailRow = row(
      vehicles: [
        {
          'id': 'v1',
          'plate': '沪A8K29M',
          'energy': 'fuel',
          'brand_model': '宝马 5系 525Li',
          'color': '黑色',
        },
      ],
    );

    testWidgets('详情页：显示真实资料和车辆；余额 / 次卡 / 记录依赖其他模块，不造数据', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      await t.pumpWidget(
        app(MemberDetailPage(member: memberFromRow(detailRow))),
      );
      await t.pumpAndSettle();
      expect(find.text('王建国'), findsOneWidget);
      expect(find.text('金卡'), findsOneWidget);
      // 手机号脱敏 + 入会年月来自真实记录，不是示例里的“入会 2023.04”
      expect(find.text('138 **** 6021 · 入会 2026.10'), findsOneWidget);
      expect(find.textContaining('2023.04'), findsNothing);
      expect(find.text('宝马 5系 525Li'), findsOneWidget);
      expect(find.text('沪A·8K29M'), findsOneWidget);
      // 余额 / 积分 / 累计消费 / 到店次数来自会员记录
      expect(find.text('3,680.00'), findsOneWidget);
      expect(find.text('¥28,450'), findsOneWidget);
      expect(find.text('46 次'), findsOneWidget);
      expect(find.text('12,450'), findsOneWidget);
      expect(find.text('暂无次卡'), findsOneWidget);
    });

    testWidgets('详情页：余额充值进入充值页，为他开单进入开单页', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      await t.pumpWidget(
        app(MemberDetailPage(member: memberFromRow(detailRow))),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('为他开单'));
      await t.pumpAndSettle();
      expect(find.text('开单收银'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('返回'));
      await t.pumpAndSettle();
      await t.tap(find.text('余额充值'));
      await t.pumpAndSettle();
      expect(find.text('会员充值'), findsOneWidget);
    });

    testWidgets('修改资料：回填，保存只提交资料字段并带 id', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      MemberFlow.current = detailRow;
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberEdit'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      final fields = find.byType(TextFormField);
      expect(t.widget<TextFormField>(fields.at(0)).initialValue, '13816826021');
      expect(t.widget<TextFormField>(fields.at(1)).initialValue, '王建国');
      await t.enterText(fields.at(1), '王建国Jr');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      final sent = fake.saved.single;
      expect(sent['id'], 'm1');
      expect(sent['name'], '王建国Jr');
      expect(sent['phone'], '13816826021');
      expect(sent['honorific'], '先生');
      expect(sent['birthday'], '1985-06-12');
      expect(sent.containsKey('card_type_id'), isFalse); // 卡种不能由客户端改
    });

    testWidgets('添加车辆：保存车牌，不填车牌时说明原因', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  MemberFlow.beginVehicle('m1');
                  openRoute(context, 'VehicleAdd');
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('保存').first);
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(find.text('请输入车牌号'), findsOneWidget);
      expect(fake.savedVehicles, isEmpty);
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      CatalogDraft.set('vehicles', 'plate', '沪AF09316');
      CatalogDraft.set('vehicles', 'energy', 'ev');
      await t.tap(find.text('保存').first);
      await t.pumpAndSettle();
      expect(fake.savedVehicles.single['member_id'], 'm1');
      expect(fake.savedVehicles.single['plate'], '沪AF09316');
      expect(fake.savedVehicles.single['energy'], 'ev');
    });

    testWidgets('删除会员：确认后调用后端；失败时保持并提示', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      MemberFlow.current = detailRow;
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberDelete'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('删除会员 王建国？'), findsOneWidget);
      // 储值余额依赖充值模块：不显示设计稿示例里的 ¥3,680.00
      expect(find.textContaining('3,680'), findsNothing);
      await t.tap(find.text('确认删除'));
      await t.pumpAndSettle();
      expect(fake.deleted, ['members:m1']);
      expect(MemberFlow.current, isNull);
    });
  });

  group('储值充值', () {
    Future<void> openRecharge(WidgetTester t) async {
      final r = row(tier: 't-gold', tierName: '金卡');
      fake.rows.add(r);
      MemberFlow.current = r;
      await t.pumpWidget(
        appFromDetail(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'Recharge'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('显示当前会员和真实余额；默认 ¥2,000 档，充值后 = 余额 + 金额 + 赠送', (t) async {
      phone(t);
      await openRecharge(t);
      expect(find.text('¥3,680.00'), findsOneWidget); // 当前余额
      expect(find.text('¥5,980.00'), findsOneWidget); // 充值后
      expect(find.text('实收 · 到账 ¥2,300'), findsOneWidget);
      // 设计稿里的赠品（洗车 2 次）暂未实现，只显示赠送金额
      expect(find.text('送 ¥300'), findsOneWidget);
      expect(find.textContaining('洗车 2 次'), findsNothing);
      expect(
        find.textContaining('王建国 · 138 **** 6021', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('金卡会员'), findsOneWidget);
    });

    testWidgets('换档位、输入自定义金额（不享赠送）、换收款方式，并提交', (t) async {
      phone(t);
      await openRecharge(t);
      await t.tap(find.text('¥1,000').first);
      await t.pump();
      await t.pump();
      expect(find.text('¥4,780.00'), findsOneWidget); // 3680 + 1000 + 100
      await t.enterText(find.widgetWithText(TextFormField, ''), '1500');
      await t.pump();
      await t.pump();
      expect(find.text('实收 · 到账 ¥1,500'), findsOneWidget); // 自定义不赠送
      expect(find.text('¥5,180.00'), findsOneWidget);
      await t.tap(find.text('现金').first);
      await t.pump();
      await t.ensureVisible(find.text('确认收款'));
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      expect(fake.recharges.single, {
        'id': 'm1',
        'amount': 1500,
        'method': '现金',
      });
      // 成功页：显示云函数返回的结果
      expect(find.text('充值成功'), findsOneWidget);
      expect(find.text('¥1,500.00'), findsWidgets);
      expect(find.text('+¥0.00'), findsOneWidget);
      expect(find.text('¥5,180.00'), findsOneWidget);
      expect(find.text('+1,500'), findsOneWidget);
    });

    testWidgets('选档位后成功页显示服务端算的赠送金额和积分', (t) async {
      phone(t);
      await openRecharge(t);
      await t.ensureVisible(find.text('确认收款'));
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      expect(fake.recharges.single['amount'], 2000);
      expect(find.text('+¥300.00'), findsOneWidget);
      expect(find.text('¥2,300.00'), findsOneWidget);
      expect(find.text('¥5,980.00'), findsOneWidget);
      expect(find.text('+2,000'), findsOneWidget);
      // 提交后 MemberFlow 拿到的是最新的会员（余额已更新）
      expect(MemberFlow.current!['balance'], 5980);
    });

    testWidgets('没有选会员就充值：说明原因，不请求后端', (t) async {
      phone(t);
      await openRecharge(t);
      MemberFlow.current = null;
      await t.ensureVisible(find.text('确认收款'));
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      expect(find.text('请先从会员详情进入充值'), findsOneWidget);
      expect(fake.recharges, isEmpty);
    });
  });

  group('消费 / 充值记录', () {
    Future<void> openRecords(WidgetTester t) async {
      final r = row();
      fake.rows.add(r);
      MemberFlow.current = r;
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberRecords'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('顶部累计数据来自会员，流水按月份分组显示真实记录', (t) async {
      phone(t);
      fake.ledgerItems.addAll([
        {
          'kind': 'recharge',
          'amount': 2000,
          'gift': 300,
          'pay_method': '微信',
          'operator': '陈明（店长）',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
        {
          'kind': 'adjust_points',
          'points_delta': -500,
          'reason': '录入错误',
          'operator': '陈明（店长）',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      ]);
      await openRecords(t);
      expect(find.text('王建国 · 金卡会员'), findsOneWidget);
      expect(find.text('¥28,450'), findsOneWidget); // 累计消费
      expect(find.text('46 次'), findsOneWidget);
      expect(find.text('储值充值 · 送 ¥300'), findsOneWidget);
      expect(find.text('+¥2,300'), findsOneWidget);
      expect(find.text('积分调整 · 录入错误'), findsOneWidget);
      expect(find.text('-500 分'), findsOneWidget);
      expect(find.textContaining('微信 · 经办 陈明（店长）'), findsOneWidget);
    });

    testWidgets('充值页签只请求充值流水；消费 / 次卡页签暂无数据来源，显示空状态', (t) async {
      phone(t);
      fake.ledgerItems.add({
        'kind': 'recharge',
        'amount': 1000,
        'gift': 100,
        'pay_method': '现金',
        'operator': '',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
      await openRecords(t);
      await t.tap(find.text('充值').first);
      await t.pumpAndSettle();
      expect(fake.ledgerCalls.last, 'recharge');
      await t.tap(find.text('消费').first);
      await t.pumpAndSettle();
      expect(find.text('暂无记录'), findsOneWidget);
      expect(find.text('开单消费后会显示在这里'), findsOneWidget);
      await t.tap(find.text('次卡').first);
      await t.pumpAndSettle();
      expect(find.text('次卡购买和使用后会显示在这里'), findsOneWidget);
    });

    testWidgets('没有任何流水：显示空状态', (t) async {
      phone(t);
      await openRecords(t);
      expect(find.text('还没有记录'), findsOneWidget);
    });
  });

  group('调整卡种与积分', () {
    Future<void> openAdjust(WidgetTester t) async {
      fake.tiers
        ..clear()
        ..addAll([
          {'id': 't-base', 'name': '普通会员'},
          {'id': 't-silver', 'name': '银卡', 'upgrade_recharge': 2000},
          {'id': 't-gold', 'name': '金卡', 'upgrade_recharge': 5000},
          {'id': 't-black', 'name': '黑金卡', 'upgrade_recharge': 10000},
        ]);
      final r = row(tier: 't-gold', tierName: '金卡');
      fake.rows.add(r);
      MemberFlow.current = r;
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberAdjust'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('显示当前会员、真实积分和本店卡种；积分从 0 开始，原因要自己选', (t) async {
      phone(t);
      await openAdjust(t);
      expect(find.text('12,450'), findsWidgets); // 当前积分 / 调整后
      expect(find.text('0'), findsWidgets); // 数量从 0 开始，不沿用示例的 500
      expect(find.text('500'), findsNothing);
      for (final n in ['普通', '银卡', '金卡', '黑金']) {
        expect(find.text(n), findsWidgets);
      }
      // 没选原因：说明原因，不请求后端
      await t.ensureVisible(find.text('确认调整'));
      await t.tap(find.text('确认调整'));
      await t.pumpAndSettle();
      expect(find.text('请选择要调整的卡种或积分数量'), findsOneWidget);
      expect(fake.adjusts, isEmpty);
    });

    testWidgets('改卡种并选原因后提交：只带卡种和原因，积分不变', (t) async {
      phone(t);
      await openAdjust(t);
      await t.ensureVisible(find.text('银卡').first);
      await t.tap(find.text('银卡').first);
      await t.pump();
      await t.ensureVisible(find.text('录入错误'));
      await t.tap(find.text('录入错误'));
      await t.pump();
      await t.ensureVisible(find.text('确认调整'));
      await t.tap(find.text('确认调整'));
      await t.pumpAndSettle();
      expect(fake.adjusts.single, {
        'id': 'm1',
        'tier_id': 't-silver',
        'points': 0,
        'reason': '录入错误',
      });
    });

    testWidgets('扣减积分：调整后预览不会低于 0，提交负数', (t) async {
      phone(t);
      await openAdjust(t);
      CatalogDraft.set('adjust', 'points', 50);
      CatalogDraft.set('adjust', 'dir', 'sub');
      await t.pump();
      await t.pump();
      expect(find.text('12,400'), findsOneWidget);
      CatalogDraft.set('adjust', 'points', 99999);
      await t.pump();
      await t.pump();
      expect(find.text('0'), findsWidgets);
      CatalogDraft.set('adjust', 'points', 50);
      await t.ensureVisible(find.text('客诉补偿'));
      await t.tap(find.text('客诉补偿'));
      await t.pump();
      await t.ensureVisible(find.text('确认调整'));
      await t.tap(find.text('确认调整'));
      await t.pumpAndSettle();
      expect(fake.adjusts.single['points'], -50);
      expect(fake.adjusts.single['tier_id'], isNull);
    });
  });

  group('充值选择会员', () {
    Future<void> openFromHome(WidgetTester t) async {
      fake.tiers
        ..clear()
        ..addAll([
          {'id': 't-base', 'name': '普通会员'},
          {'id': 't-gold', 'name': '金卡'},
        ]);
      fake.rows.addAll([
        row(),
        row(
          id: 'm2',
          name: '林晓雯',
          phone: '13917630412',
          tier: 't-base',
          tierName: '普通会员',
        ),
      ]);
      MemberFlow.current = fake.rows.first; // 上次看过的会员，从首页进入时不能沿用
      storeProfile.apply({
        'name': '测试店',
        'phone': '+8613900000001',
        'contact_name': '阳光',
        'contact_role': '老板',
      });
      addTearDown(storeProfile.clear);
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'Recharge'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('从首页进入没有会员：显示“请先选择会员”，不沿用上次的会员', (t) async {
      phone(t);
      await openFromHome(t);
      expect(MemberFlow.current, isNull);
      expect(find.text('选择会员'), findsOneWidget);
      expect(find.text('输入车牌、手机号或姓名查找'), findsOneWidget);
      expect(find.text('请先选择会员'), findsOneWidget);
      expect(find.text('确认收款'), findsNothing);
      expect(find.text('王建国'), findsNothing);
      expect(find.text('陈明（店长）'), findsNothing); // 经办人来自门店资料，不是示例
      expect(find.text('阳光（老板）'), findsOneWidget);
    });

    testWidgets('没选会员时储值档位和次卡套餐也是真实数据（置灰、不可操作），各部分有间距', (t) async {
      phone(t);
      fake.rechargeOpts = [
        {'amount': 1000, 'gift': 150},
        {'amount': 2000, 'gift': 350},
        {'amount': 5000, 'gift': 1100},
        {'amount': 10000, 'gift': 2600},
      ];
      fake.packages.addAll([
        pkgRow(id: 'p1', name: '精致洗车年卡', price: 1080),
        pkgRow(id: 'p2', name: '精致洗车 10 次卡', price: 580, validity: 6),
        pkgRow(id: 'p3', name: '下架套餐', price: 99, active: false),
      ]);
      await openFromHome(t);
      // 储值档位的赠送来自云函数（不是设计稿的 ¥100 / ¥300 / ¥1,000 / ¥2,500）
      expect(find.text('送 ¥150'), findsOneWidget);
      expect(find.text('送 ¥350'), findsOneWidget);
      expect(find.text('送 ¥1,100'), findsOneWidget);
      expect(find.text('送 ¥2,600'), findsOneWidget);
      expect(find.text('送 ¥300 + 洗车 2 次'), findsNothing);
      // 档位卡片和下面的“收款方式 / 经办人”卡片之间有间距（不再挨在一起）
      final tiles = t.getRect(find.text('¥5,000'));
      final pay = t.getRect(find.text('收款方式'));
      expect(pay.top - tiles.bottom, greaterThan(40));
      // 购买次卡：真实在售套餐，不含已下架的；置灰不可点选
      await t.tap(find.text('购买次卡').first);
      await t.pumpAndSettle();
      expect(find.text('精致洗车年卡'), findsOneWidget);
      expect(find.text('精致洗车 10 次卡'), findsOneWidget);
      expect(find.text('下架套餐'), findsNothing);
      expect(find.text('查看全部 2 个在售套餐'), findsOneWidget);
      expect(find.text('¥1,080'), findsOneWidget);
      final first = t.getRect(find.text('精致洗车年卡'));
      final second = t.getRect(find.text('精致洗车 10 次卡'));
      expect(second.top - first.bottom, greaterThan(20)); // 套餐行之间有间距
      await t.tap(find.text('精致洗车 10 次卡'));
      await t.pump();
      expect(CatalogDraft.current!.fields['sale_package_id'], isNot('p2'));
      expect(find.text('请先选择会员'), findsOneWidget);
    });

    testWidgets('选择会员弹层：最近使用 / 全部会员、搜索；选中后进入充值页，还能再更换', (t) async {
      phone(t);
      await openFromHome(t);
      await t.tap(find.text('选择会员'));
      await t.pumpAndSettle();
      expect(find.text('选择会员'), findsWidgets);
      expect(find.text('最近使用'), findsOneWidget);
      expect(find.text('全部会员 · 2'), findsOneWidget);
      expect(find.text('林晓雯'), findsWidgets);
      await t.enterText(find.widgetWithText(TextField, ''), '林晓');
      await t.pump(const Duration(milliseconds: 400));
      await t.pumpAndSettle();
      expect(fake.listCalls.last.q, '林晓');
      expect(find.text('王建国'), findsNothing);
      await t.tap(find.text('林晓雯').last);
      await t.pumpAndSettle();
      // 进入充值页，显示选中的会员
      expect(MemberFlow.current!['name'], '林晓雯');
      expect(find.text('请先选择会员'), findsNothing);
      expect(find.text('确认收款'), findsOneWidget);
      expect(find.textContaining('林晓雯', findRichText: true), findsWidgets);
      // “更换”可以再换一个会员
      await t.tap(find.text('更换').first);
      await t.pumpAndSettle();
      expect(find.text('全部会员 · 2'), findsOneWidget);
    });
  });

  group('购买次卡', () {
    Future<void> openSale(WidgetTester t) async {
      final r = row(tier: 't-gold', tierName: '金卡');
      fake.rows.add(r);
      fake.packages.addAll([
        pkgRow(id: 'p1', name: '精致洗车年卡', price: 1080),
        pkgRow(id: 'p2', name: '精致洗车 10 次卡', price: 580, validity: 6),
        pkgRow(id: 'p3', name: '下架套餐', price: 99, active: false),
      ]);
      MemberFlow.current = r;
      await t.pumpWidget(
        appFromDetail(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'Recharge'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      await t.tap(find.text('购买次卡').first);
      await t.pumpAndSettle();
    }

    testWidgets('只列在售套餐，默认选第一个；应收 / 优惠随选择变化', (t) async {
      phone(t);
      await openSale(t);
      expect(find.text('精致洗车年卡'), findsWidgets);
      expect(find.text('精致洗车 10 次卡'), findsOneWidget);
      expect(find.text('下架套餐'), findsNothing); // 已下架不可售卖
      // 会员信息是真实的，不是设计稿的“王建国 / 138 **** 6021”示例
      expect(find.text('王建国'), findsOneWidget);
      expect(find.text('138 **** 6021 · 未登记车辆'), findsOneWidget);
      expect(find.text('金卡会员'), findsOneWidget);
      expect(find.text('确认收款 ¥1,080'), findsOneWidget);
      expect(find.text('¥1,080.00'), findsOneWidget);
      expect(find.text('−¥280'), findsOneWidget); // 原价 20×68 = 1360
      expect(find.text('查看全部 2 个在售套餐'), findsOneWidget);
      expect(find.text('储值余额 ¥3,680'), findsOneWidget);
      await t.tap(find.text('精致洗车 10 次卡'));
      await t.pump();
      await t.pump();
      expect(find.text('确认收款 ¥580'), findsOneWidget);
    });

    testWidgets('确认收款：提交会员 / 套餐 / 收款方式，成功页显示云函数返回的结果', (t) async {
      phone(t);
      await openSale(t);
      await t.ensureVisible(find.text('现金').last);
      await t.tap(find.text('现金').last);
      await t.pump();
      await t.ensureVisible(find.text('确认收款 ¥1,080'));
      await t.tap(find.text('确认收款 ¥1,080'));
      await t.pumpAndSettle();
      expect(fake.sales.single, {
        'member': 'm1',
        'package': 'p1',
        'method': '现金',
      });
      expect(find.text('购买成功'), findsOneWidget);
      expect(find.text('王建国 · 微信 · 次卡购买通知'), findsOneWidget);
      expect(find.text('¥1,080.00'), findsWidgets);
      expect(find.text('20 次'), findsOneWidget);
      expect(find.text('至 2027.11.01'), findsOneWidget);
      expect(find.text('−¥280.00'), findsOneWidget);
      expect(find.textContaining('现金'), findsWidgets);
    });

    testWidgets('云函数拒绝（限购 / 余额不足）：Toast 说明原因，停留在购买页', (t) async {
      phone(t);
      await openSale(t);
      fake.sellError = const AppError('已达到该套餐的每人限购份数');
      await t.ensureVisible(find.text('确认收款 ¥1,080'));
      await t.tap(find.text('确认收款 ¥1,080'));
      await t.pumpAndSettle();
      expect(find.text('已达到该套餐的每人限购份数'), findsOneWidget);
      expect(find.text('购买成功'), findsNothing);
    });
  });

  group('次卡详情 / 延期 / 退款', () {
    Map<String, dynamic> myPkg() => {
      'id': 'mp1',
      'name': '精致洗车年卡',
      'price_paid': 1080,
      'total_count': 20,
      'used_count': 12,
      'purchased_at': '2026-03-31T08:00:00Z',
      'expires_at': DateTime.now()
          .add(const Duration(days: 150))
          .toUtc()
          .toIso8601String(),
      'refunded_at': null,
      'member': {'name': '王建国'},
      'items': [
        {
          'position': 0,
          'service_name': '精致洗车',
          'unit_price': 68,
          'total': 20,
          'used': 12,
        },
      ],
      'events': [
        {
          'kind': 'use',
          'service_name': '精致洗车',
          'count': 1,
          'vehicle_plate': '沪A8K29M',
          'operator': '陈明（店长）',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
        {
          'kind': 'buy',
          'count': 20,
          'amount': 1080,
          'operator': '陈明（店长）',
          'created_at': '2026-03-31T08:00:00Z',
        },
      ],
    };

    Future<void> openDetail(WidgetTester t) async {
      final r = row(tier: 't-gold', tierName: '金卡');
      fake.rows.add(r);
      fake.memberPkgs.add(myPkg());
      MemberFlow.current = r;
      await t.pumpWidget(app(MemberDetailPage(member: memberFromRow(r))));
      await t.pumpAndSettle();
    }

    testWidgets('会员详情列出真实次卡（剩余 / 总次数、到期），点进次卡详情', (t) async {
      phone(t);
      await openDetail(t);
      expect(find.text('精致洗车年卡'), findsOneWidget);
      expect(
        find.textContaining('8 / 20 次', findRichText: true),
        findsOneWidget,
      ); // 剩余 = 20 - 12
      expect(find.text('暂无次卡'), findsNothing);
      await t.tap(find.text('精致洗车年卡'));
      await t.pumpAndSettle();
      expect(find.text('次卡详情'), findsOneWidget);
      expect(find.text('使用中'), findsOneWidget);
      expect(find.textContaining('天后到期'), findsOneWidget);
      expect(find.text('¥1,080'), findsOneWidget);
      expect(find.text('王建国 · 金卡会员'), findsOneWidget);
      expect(find.text('剩余 8 次 / 共 20 次'), findsOneWidget);
      expect(find.text('已用 12'), findsOneWidget);
      expect(find.text('核销 1 次'), findsOneWidget);
      expect(find.text('购买 20 次'), findsOneWidget);
      expect(find.text('已有记录'), findsNothing);
    });

    testWidgets('延期：默认 30 天，原因要选；提交后到期日更新', (t) async {
      phone(t);
      await openDetail(t);
      await t.tap(find.text('精致洗车年卡'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('延期'));
      await t.tap(find.text('延期'));
      await t.pumpAndSettle();
      expect(find.text('延长有效期'), findsOneWidget);
      await t.tap(find.text('确认延期'));
      await t.pumpAndSettle();
      expect(find.text('请选择延期原因'), findsOneWidget);
      expect(fake.extended, isEmpty);
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.tap(find.text('60 天'));
      await t.pump();
      await t.tap(find.text('会员长期出差'));
      await t.pump();
      await t.tap(find.text('确认延期'));
      await t.pumpAndSettle();
      expect(fake.extended.single, {
        'id': 'mp1',
        'days': 60,
        'reason': '会员长期出差',
      });
    });

    testWidgets('退款：按“实付 − 已用次数 × 单次均价”预览可退金额，提交后回到会员详情', (t) async {
      phone(t);
      await openDetail(t);
      await t.tap(find.text('精致洗车年卡'));
      await t.pumpAndSettle();
      await t.ensureVisible(find.text('退款'));
      await t.tap(find.text('退款'));
      await t.pumpAndSettle();
      expect(find.text('次卡退款'), findsOneWidget);
      expect(find.text('已用 12 次 × 单次 ¥54'), findsOneWidget);
      expect(find.text('−¥648.00'), findsOneWidget);
      expect(find.text('¥432.00'), findsOneWidget);
      expect(find.text('确认退款 ¥432'), findsOneWidget);
      await t.tap(find.text('确认退款 ¥432'));
      await t.pumpAndSettle();
      expect(find.text('请选择退款原因'), findsOneWidget); // 原因要自己选
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.tap(find.text('退到储值余额'));
      await t.pump();
      await t.tap(find.text('搬家 / 换车'));
      await t.pump();
      await t.tap(find.text('确认退款 ¥432'));
      await t.pumpAndSettle();
      expect(fake.refunded.single, {
        'id': 'mp1',
        'to': '储值余额',
        'reason': '搬家 / 换车',
      });
    });
  });

  group('开单收银', () {
    Future<void> openOrder(WidgetTester t) async {
      final r = row(
        tier: 't-gold',
        tierName: '金卡',
        vehicles: [
          {'plate': '沪A8K29M', 'energy': 'fuel', 'brand_model': '宝马 5系'},
        ],
      );
      (r['card'] as Map)['discount'] = 0.95;
      fake.rows.add(r);
      fake.services.addAll([
        {
          'id': 's1',
          'name': '精致洗车',
          'price': 68,
          'category': '洗车',
          'active': true,
        },
        {
          'id': 's2',
          'name': '内饰深度清洁',
          'price': 380,
          'category': '内饰',
          'active': true,
        },
        {
          'id': 's3',
          'name': '已下架项目',
          'price': 10,
          'category': '洗车',
          'active': false,
        },
      ]);
      fake.memberPkgs.add({
        'id': 'mp1',
        'name': '精致洗车年卡',
        'refunded_at': null,
        'expires_at': DateTime.now()
            .add(const Duration(days: 100))
            .toUtc()
            .toIso8601String(),
        'items': [
          {'service_id': 's1', 'total': 20, 'used': 12},
        ],
      });
      MemberFlow.current = r;
      await t.pumpWidget(app(OrderPage(member: memberFromRow(r))));
      await t.pumpAndSettle();
    }

    testWidgets('服务项目是真实的在售项目，默认一个都不选；选了之后按次卡 / 折扣算应收', (t) async {
      phone(t);
      await openOrder(t);
      expect(find.text('精致洗车'), findsOneWidget);
      expect(find.text('内饰深度清洁'), findsOneWidget);
      expect(find.text('已下架项目'), findsNothing);
      expect(find.text('¥0.00'), findsWidgets); // 还没选，应收 0
      await t.tap(find.text('精致洗车'));
      await t.pump();
      expect(find.text('次卡抵扣 1 次'), findsOneWidget); // 会员有精致洗车年卡，剩 8 次
      await t.tap(find.text('内饰深度清洁'));
      await t.pump();
      expect(find.text('金卡 9.5 折'), findsWidgets);
      // 448 − 次卡 68 − 9.5 折优惠（380 × 5% = 19）= 361
      expect(find.text('¥361.00'), findsWidgets);
      expect(find.text('-¥19.00'), findsOneWidget);
    });

    testWidgets('确认收款：只提交选择（服务 / 次卡 / 收款方式），成功页显示云函数算的结果', (t) async {
      phone(t);
      await openOrder(t);
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('内饰深度清洁'));
      await t.pump();
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      final sent = fake.checkouts.single;
      expect(sent['member'], 'm1');
      expect(sent['method'], '会员余额');
      expect(sent['lines'], [
        {'service_id': 's1', 'qty': 1, 'member_package_id': 'mp1'},
        {'service_id': 's2', 'qty': 1},
      ]);
      // 客户端不上传任何价格 / 折扣 / 金额
      expect(sent.toString().contains('price'), isFalse);
      expect(find.text('收款成功'), findsOneWidget);
      expect(find.text('¥361.00'), findsWidgets);
      expect(find.text('精致洗车 · 内饰深度清洁'), findsOneWidget);
      expect(find.text('次卡抵扣 −¥68.00 · 金卡 9.5 折 −¥19.00'), findsOneWidget);
      expect(find.text('¥3,319.00'), findsOneWidget);
      expect(find.text('+541'), findsOneWidget);
    });

    testWidgets('没选项目不能收款；云函数拒绝时说明原因，仍停留在开单页', (t) async {
      phone(t);
      await openOrder(t);
      await t.tap(find.text('确认收款'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.text('请先选择服务项目'), findsOneWidget);
      expect(fake.checkouts, isEmpty);
      for (var i = 0; i < 5; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      fake.checkoutError = const AppError('储值余额不足');
      await t.tap(find.text('精致洗车'));
      await t.pump();
      await t.tap(find.text('确认收款'));
      await t.pumpAndSettle();
      expect(find.text('储值余额不足'), findsOneWidget);
      expect(find.text('收款成功'), findsNothing);
    });
  });

  group('回访', () {
    Future<void> openVisit(WidgetTester t) async {
      final r = row(tier: 't-gold', tierName: '金卡');
      fake.rows.add(r);
      fake.followHistory.add({
        'method': '电话',
        'result': '已接通 · 暂无需求',
        'content': '询问车辆使用情况，对服务满意。',
        'created_at': '2026-10-12T08:00:00Z',
      });
      MemberFlow.current = r;
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberVisit'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    testWidgets('记录回访：显示真实历史；结果要选；保存带方式 / 结果 / 内容', (t) async {
      phone(t);
      await openVisit(t);
      expect(find.text('电话 · 已接通 · 暂无需求'), findsOneWidget);
      expect(find.text('询问车辆使用情况，对服务满意。'), findsOneWidget);
      expect(find.text('10.12'), findsOneWidget);
      expect(find.text('提醒方式'), findsOneWidget); // 推送提醒依赖通知模块，保持设计稿样式
      await t.tap(find.text('保存回访'));
      await t.pumpAndSettle();
      expect(find.text('请选择回访结果'), findsOneWidget);
      expect(fake.visits, isEmpty);
      for (var i = 0; i < 6; i++) {
        await t.pump(const Duration(seconds: 1));
      }
      await t.tap(find.text('微信').first);
      await t.pump();
      await t.tap(find.text('已预约到店'));
      await t.pump();
      await t.enterText(find.byType(TextFormField).first, '约了周六镀晶复养');
      await t.tap(find.text('保存回访'));
      await t.pumpAndSettle();
      expect(fake.visits.single, {
        'member': 'm1',
        'method': '微信',
        'result': '已预约到店',
        'content': '约了周六镀晶复养',
        'next': null,
      });
    });

    testWidgets('回访提醒：真实提醒数据、数量、页签筛选，标记已回访后消失', (t) async {
      phone(t);
      fake.reminderData = {
        'items': [
          {
            'kind': '次卡到期',
            'when': '3 天后',
            'member_id': 'a',
            'name': '陈浩',
            'card': '银卡',
            'plate': '苏E3QX18',
            'text': '精致洗车年卡剩 3 次，11.05 到期',
          },
          {
            'kind': '沉睡客户',
            'when': '47 天未到店',
            'member_id': 'b',
            'name': '周志远',
            'card': '银卡',
            'plate': '',
            'text': '余额 ¥180 未用',
          },
        ],
        'counts': {'次卡到期': 1, '沉睡客户': 1},
        'pending': 2,
        'done_today': 3,
      };
      await t.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () => openRoute(context, 'MemberFollowUp'),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('全部 2'), findsWidgets);
      expect(find.text('次卡到期 1'), findsWidgets);
      expect(find.text('养护到期 0'), findsWidgets);
      expect(find.text('沉睡 1'), findsWidgets);
      expect(
        find.textContaining('已完成 3 / 5', findRichText: true),
        findsOneWidget,
      );
      expect(find.text('陈浩'), findsNothing); // 名字和卡种在同一行的富文本里
      expect(find.textContaining('陈浩', findRichText: true), findsOneWidget);
      expect(find.textContaining('周志远', findRichText: true), findsOneWidget);
      await t.ensureVisible(find.text('沉睡 1').first); // 页签条比屏幕宽，要滚到可见
      await t.tap(find.text('沉睡 1').first);
      await t.pumpAndSettle();
      expect(find.textContaining('陈浩', findRichText: true), findsNothing);
      await t.tap(find.text('标记已回访'));
      await t.pumpAndSettle();
      expect(fake.marked, ['b']);
      expect(find.textContaining('周志远', findRichText: true), findsNothing);
      expect(find.text('今天没有需要回访的客户'), findsOneWidget);
    });
  });
}
