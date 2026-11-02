import 'package:autocare_merchant/backend/catalog_draft.dart';
import 'package:autocare_merchant/backend/member_flow.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/member_detail_page.dart';
import 'package:autocare_merchant/pages/members_page.dart';
import 'package:autocare_merchant/routes.dart';
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
  Object? listError;
  Duration listDelay = Duration.zero;
  Object? saveError;

  @override
  bool get hasSession => true;

  @override
  Future<List<Map<String, dynamic>>> list(String kind) async =>
      kind == 'cards' ? tiers : const [];

  @override
  Future<
    ({List<Map<String, dynamic>> items, Map<String, int> counts, int total})
  >
  members({String? query, String? cardTypeId}) async {
    listCalls.add((q: query, tier: cardTypeId));
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
    return (items: items, counts: counts, total: rows.length);
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
      expect(find.text('未登记车辆 · —'), findsOneWidget);
      expect(find.text('全部 2'), findsOneWidget);
      expect(find.text('普通会员 1'), findsOneWidget);
      expect(find.text('金卡 1'), findsOneWidget);
      // 余额依赖储值模块：不显示假数字
      expect(find.text('¥3,680'), findsNothing);
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

    testWidgets('高级筛选依赖其他模块：只提示，不打开假的筛选面板', (t) async {
      phone(t);
      await t.pumpWidget(app(const MembersPage()));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('筛选会员'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('高级筛选暂未接通'), findsOneWidget);
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
      expect(find.text('3,680.00'), findsNothing);
      expect(find.text('暂无次卡'), findsOneWidget);
    });

    testWidgets('详情页底部按钮依赖支付 / 订单：只提示', (t) async {
      phone(t);
      fake.rows.add(detailRow);
      await t.pumpWidget(
        app(MemberDetailPage(member: memberFromRow(detailRow))),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('余额充值'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      expect(find.textContaining('余额充值暂未接通'), findsOneWidget);
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
}
