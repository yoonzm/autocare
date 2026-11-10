import 'package:autocare_admin/data/admin_api.dart';
import 'package:autocare_admin/data/models.dart';
import 'package:autocare_admin/data/store.dart';
import 'package:autocare_admin/pages/mine_page.dart';
import 'package:autocare_admin/pages/users_pages.dart';
import 'package:autocare_admin/theme.dart';
import 'package:autocare_async_kit/async_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> user(
  String id,
  String phone,
  String name, {
  String role = 'owner',
  String status = 'active',
  String store = '驰光汽车美容',
  int stores = 1,
  DateTime? requested,
  DateTime? cancelled,
  String reason = '',
}) => {
  'user_id': id,
  'created_at': '2026-06-18T02:00:00Z',
  'last_sign_in_at': '2026-11-05T06:18:00Z',
  'phone': phone,
  'name': name,
  'role': role,
  'identities': [
    for (var i = 0; i < stores; i++)
      {
        'kind': role == 'owner' ? 'owner' : 'staff',
        'role': role,
        'store_name': store,
        'joined_on': '2026-07-02',
        'status': 'active',
      },
  ],
  'frozen': status == 'frozen',
  'delete_requested_at': requested?.toIso8601String(),
  'cancelled_at': cancelled?.toIso8601String(),
  'cancel_source': cancelled == null ? null : 'admin',
  'cancel_reason': reason,
  'cancel_note': '',
  'status': status,
};

class UsersApi extends AdminApi {
  final calls = <Map<String, dynamic>>[];
  Object? failure;
  Object? cancelFailure;
  int holds = 0, appointments = 0;
  late List<Map<String, dynamic>> rows;
  @override
  bool get hasSession => false;
  Map<String, dynamic> counts() => {
    'total': rows.length,
    'cooling': rows.where((r) => r['status'] == 'cooling').length,
    'cancelled': rows.where((r) => r['status'] == 'cancelled').length,
    'frozen': rows.where((r) => r['status'] == 'frozen').length,
  };

  @override
  Future<Map<String, dynamic>> call(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    calls.add({'action': action, ...values});
    final now = DateTime.now().toUtc().toIso8601String();
    if (failure != null) throw failure!;
    switch (action) {
      case 'user_list':
        final status = values['status'] as String;
        final q = (values['q'] as String?) ?? '';
        final list = rows.where((r) {
          if (status != 'all' && r['status'] != status) return false;
          return q.isEmpty ||
              (r['phone'] as String).contains(q) ||
              (r['name'] as String).contains(q);
        }).toList();
        return {'items': list, 'more': false, 'counts': counts(), 'now': now};
      case 'user_get':
        return {
          'item': rows.firstWhere((r) => r['user_id'] == values['id']),
          'devices': 1,
          'events': [
            {'text': '用户自助申请注销', 'at': '2026-11-05T06:20:00Z', 'by': '用户本人'},
          ],
          'open_holds': holds,
          'open_appointments': appointments,
          'now': now,
        };
      case 'user_cancel':
        if (cancelFailure != null) throw cancelFailure!;
        final row = rows.firstWhere((r) => r['user_id'] == values['id']);
        row['status'] = 'cancelled';
        row['cancelled_at'] = now;
        return {'ok': true};
    }
    return {};
  }
}

void main() {
  late UsersApi api;
  late DateTime now;
  setUp(() {
    api = UsersApi();
    store = Store(api: api);
    now = DateTime.now().toUtc();
    api.rows = [
      user('a', '13800137712', '陈明', stores: 2),
      user(
        'b',
        '13911223344',
        '刘强',
        role: 'cashier',
        status: 'cooling',
        store: '星航汽车养护',
        requested: now.subtract(const Duration(days: 6)),
      ),
      user(
        'c',
        '13677889900',
        '吴师傅',
        role: 'technician',
        status: 'cancelled',
        cancelled: now.subtract(const Duration(days: 8)),
        reason: 'violation',
      ),
      user('d', '18623456789', '郑老板', status: 'frozen', store: '车安心养护'),
    ];
  });
  tearDown(() {
    store = Store();
    C.dark = false;
  });

  Future<void> open(WidgetTester t, {Widget? page}) async {
    t.view.physicalSize = const Size(390, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(MaterialApp(home: page ?? const UsersPage()));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
  }

  testWidgets('列表：手机号不脱敏，角色、状态、冷静期提示与总数', (t) async {
    await open(t);
    expect(find.text('138 0013 7712'), findsOneWidget);
    expect(find.text('驰光汽车美容 · 2 家店'), findsOneWidget);
    expect(find.text('老板'), findsWidgets);
    expect(find.text('前台'), findsOneWidget);
    expect(find.text('正常'), findsOneWidget);
    expect(find.text('注销中'), findsWidgets);
    expect(find.text('已注销'), findsWidgets);
    expect(find.text('已冻结'), findsWidgets);
    expect(find.textContaining('冷静期剩 9 天'), findsOneWidget);
    expect(find.text('1 个账号正处于注销冷静期，冷静期内用户重新登录即可撤销。'), findsOneWidget);
    expect(find.text('共 4 个账号 · 含老板、店长、前台、技师'), findsOneWidget);
    expect(api.calls.first, {'action': 'user_list', 'status': 'all'});
  });

  testWidgets('筛选与搜索都交给服务端，没有结果显示空状态', (t) async {
    await open(t);
    await t.tap(find.text('已冻结').first);
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.last['status'], 'frozen');
    expect(find.text('186 2345 6789'), findsOneWidget);
    expect(find.text('138 0013 7712'), findsNothing);
    await t.tap(find.text('全部').first);
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    await t.enterText(find.byType(TextField), '7712');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.last['q'], '7712');
    expect(find.text('139 1122 3344'), findsNothing);
    await t.enterText(find.byType(TextField), '999999');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('没有找到相关账号'), findsOneWidget);
  });

  testWidgets('首次加载失败显示错误并可重试', (t) async {
    api.failure = const AppError('服务不可用', type: AppErrorType.server);
    await open(t);
    expect(find.text('138 0013 7712'), findsNothing);
    api.failure = null;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('138 0013 7712'), findsOneWidget);
  });

  testWidgets('注销中账号详情：脱敏姓名、冷静期、身份、设备、操作记录', (t) async {
    await open(t);
    await t.tap(find.text('139 1122 3344'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('账号详情'), findsOneWidget);
    expect(find.text('刘** · 注册于 2026-06-18'), findsOneWidget);
    expect(find.text('用户已申请注销'), findsOneWidget);
    expect(find.textContaining('（剩 9 天）'), findsOneWidget);
    expect(find.text('星航汽车养护'), findsOneWidget);
    expect(find.text('加入于 2026-07-02'), findsOneWidget);
    expect(find.text('1 台在线'), findsOneWidget);
    expect(find.text('注销冷静期'), findsOneWidget);
    expect(find.textContaining('用户自助申请注销'), findsOneWidget);
    expect(find.text('强制注销'), findsOneWidget);
  });

  testWidgets('冻结账号本期未接通：只提示，不调用服务端', (t) async {
    await open(t);
    await t.tap(find.text('139 1122 3344'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    await t.tap(find.text('冻结账号'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('账号冻结暂未接通，本期只支持强制注销'), findsOneWidget);
    expect(api.calls.where((c) => c['action'] == 'user_cancel'), isEmpty);
  });

  testWidgets('强制注销：输入确认词才可提交，成功后回到列表', (t) async {
    await open(t);
    await t.tap(find.text('139 1122 3344'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    await t.tap(find.text('强制注销'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('强制注销账号'), findsOneWidget);
    expect(find.text('只注销这个账号，店铺数据、订单、会员全部保留'), findsOneWidget);
    expect(find.text('无进行中的订单与挂单'), findsOneWidget);
    expect(find.text('若是老板账号，门店数据仍保留，但注销后无人能登录管理'), findsNothing);
    // 没输入确认词：点击无效
    await t.tap(find.text('确认强制注销'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(api.calls.where((c) => c['action'] == 'user_cancel'), isEmpty);
    await t.tap(find.text('违规处理'));
    await t.enterText(find.widgetWithText(TextField, ''), '强制注销');
    await t.pump();
    await t.tap(find.text('确认强制注销'));
    await t.pumpAndSettle(const Duration(milliseconds: 600));
    final cancel = api.calls.singleWhere((c) => c['action'] == 'user_cancel');
    expect(cancel['id'], 'b');
    expect(cancel['reason'], 'violation');
    expect(find.text('账号已强制注销'), findsOneWidget);
    expect(find.text('账号详情'), findsNothing);
    expect(find.text('用户账号'), findsOneWidget);
  });

  testWidgets('有进行中事项时给出警告；老板账号多一条提示；服务端拒绝时留在弹层', (t) async {
    api.holds = 2;
    api.appointments = 1;
    api.cancelFailure = const AppError('账号已注销');
    await open(t);
    await t.tap(find.text('138 0013 7712'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    await t.tap(find.text('强制注销'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('有 2 个挂单、1 个待到店预约，注销后需要他人接手'), findsOneWidget);
    expect(find.text('若是老板账号，门店数据仍保留，但注销后无人能登录管理'), findsOneWidget);
    await t.enterText(find.widgetWithText(TextField, ''), '强制注销');
    await t.pump();
    await t.tap(find.text('确认强制注销'));
    await t.pumpAndSettle(const Duration(milliseconds: 600));
    expect(find.text('账号已注销'), findsOneWidget);
    expect(find.text('强制注销账号'), findsOneWidget);
  });

  testWidgets('已注销账号详情没有操作按钮，并说明店铺数据保留', (t) async {
    await open(t);
    await t.tap(find.text('136 7788 9900'));
    await t.pumpAndSettle(const Duration(milliseconds: 400));
    expect(find.text('该账号已注销'), findsOneWidget);
    expect(find.text('后台强制注销'), findsOneWidget);
    expect(find.text('违规处理'), findsOneWidget);
    expect(find.text('强制注销'), findsNothing);
    expect(find.text('冻结账号'), findsNothing);
    expect(find.textContaining('店铺数据保留'), findsOneWidget);
  });

  testWidgets('「我的」只对超级管理员显示用户账号，并带注销中数量', (t) async {
    Account account(Role role) =>
        Account(id: 'me', name: '测试', username: 'tester', role: role);
    store.me = account(Role.superAdmin);
    store.userCooling = 3;
    await open(t, page: const MinePage());
    expect(find.text('用户账号'), findsOneWidget);
    expect(find.text('3 个注销中 · 仅超级管理员可见'), findsOneWidget);
    store.me = account(Role.ops);
    store.notifyListeners();
    await t.pumpAndSettle();
    expect(find.text('用户账号'), findsNothing);
  });
}
