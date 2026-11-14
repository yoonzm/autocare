import 'package:autocare_merchant/pages/staff/staff_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/pages/staff/role_permission_template.dart';
import 'package:autocare_merchant/pages/staff/staff_commission_template.dart';
import 'package:autocare_merchant/pages/staff/staff_detail_off_template.dart';
import 'package:autocare_merchant/pages/staff/staff_detail_template.dart';
import 'package:autocare_merchant/pages/staff/staff_invite_template.dart';
import 'package:autocare_merchant/pages/staff/staff_records_template.dart';
import 'package:autocare_merchant/routes.dart' show navTracker;

import 'appointments_test.dart' show BookingApi;
import 'members_test.dart' show phone;

void main() {
  late MerchantApi original;
  late BookingApi api;
  setUp(() {
    original = merchantApi;
    merchantApi = api = BookingApi();
    navTracker.stack.clear();
  });
  tearDown(() {
    merchantApi = original;
    navTracker.stack.clear();
  });

  /// 首页是空 Scaffold，被测页面压在上面，方便 openRoute 找到上一层。
  Future<void> open(WidgetTester t, Widget page) async {
    phone(t);
    await t.pumpWidget(
      MaterialApp(
        navigatorObservers: [navTracker],
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        onGenerateInitialRoutes: (_) => [
          MaterialPageRoute(
            settings: const RouteSettings(name: 'Staff'),
            builder: (_) => const Scaffold(),
          ),
          MaterialPageRoute(builder: (_) => page),
        ],
      ),
    );
    await t.pumpAndSettle();
  }

  Finder text(String s) => find.text(s);
  List<Map<String, dynamic>> calls(String action) =>
      api.calls.where((c) => c['action'] == action).toList();

  testWidgets('员工列表：页签人数按角色和状态统计，待激活 / 停用员工按设计稿展示', (t) async {
    await open(t, const StaffResourcesPage());
    // 全部 / 店长 / 前台收银 / 施工技师：不含已停用
    expect(text('全部 2'), findsOneWidget);
    expect(text('店长 0'), findsOneWidget);
    expect(text('前台收银 1'), findsOneWidget);
    expect(text('施工技师 1'), findsOneWidget);
    expect(find.textContaining('真实技师'), findsOneWidget);
    expect(find.textContaining('真实前台'), findsOneWidget);
    expect(text('待激活'), findsOneWidget);
    expect(text('邀请已发送，等待员工登录'), findsOneWidget);
    expect(text('空闲'), findsOneWidget);
    expect(text('本月 2 台次'), findsOneWidget);
    expect(text('已停用账号'), findsOneWidget);
    expect(text('1 人'), findsOneWidget);
    // 「全部」页签没有单一角色，不显示「X 可以」
    expect(find.textContaining('可以'), findsNothing);
    await t.tap(text('施工技师 1'));
    await t.pumpAndSettle();
    // 技师权限来自后端保存的开关
    expect(text('技师可以'), findsOneWidget);
    expect(text('查看派给我的工单'), findsOneWidget);
    expect(text('会员充值与退款'), findsOneWidget);
  });

  testWidgets('「X 可以」跟随所选页签：店长 / 前台收银 / 技师各自的权限', (t) async {
    await open(t, const StaffResourcesPage());
    await t.tap(text('前台收银 1'));
    await t.pumpAndSettle();
    expect(text('前台收银可以'), findsOneWidget);
    expect(text('开单收银'), findsOneWidget);
    expect(text('入库与出库'), findsOneWidget);
    expect(text('查看派给我的工单'), findsNothing);
    await t.tap(text('店长 0'));
    await t.pumpAndSettle();
    expect(text('店长可以'), findsOneWidget);
    expect(text('查看全店工单'), findsOneWidget);
    expect(text('查看门店营业统计'), findsOneWidget);
    await t.tap(text('施工技师 1'));
    await t.pumpAndSettle();
    expect(text('技师可以'), findsOneWidget);
    expect(text('领用耗材'), findsOneWidget);
    expect(text('开单收银'), findsNothing);
  });

  testWidgets('没有已停用员工时不显示「已停用账号」', (t) async {
    api.staffRows.removeWhere((r) => r['status'] == 'disabled');
    await open(t, const StaffResourcesPage());
    expect(text('已停用账号'), findsNothing);
    expect(text('0 人'), findsNothing);
  });

  testWidgets('角色页签筛选：前台只显示前台；店长没有员工时给出空状态', (t) async {
    await open(t, const StaffResourcesPage());
    await t.tap(find.textContaining('前台收银').first);
    await t.pumpAndSettle();
    expect(find.textContaining('真实前台'), findsOneWidget);
    expect(find.textContaining('真实技师'), findsNothing);
    await t.tap(find.textContaining('店长').first);
    await t.pumpAndSettle();
    // 设计稿 StaffEmptyRole：页签栏保留，列表卡片里一行说明 + 文字入口
    expect(text('店长下还没有员工'), findsOneWidget);
    expect(text('添加后自动拥有下方的店长权限'), findsOneWidget);
    expect(text('添加店长'), findsOneWidget);
    expect(text('店长可以'), findsOneWidget);
    expect(text('全部 2'), findsOneWidget);
    // 点「添加店长」进入新增页，角色预选店长
    await t.tap(text('添加店长'));
    await t.pumpAndSettle();
    expect(text('新增员工'), findsOneWidget);
    await t.enterText(find.byType(TextFormField).at(0), '新店长');
    await t.enterText(find.byType(TextFormField).at(1), '13800007777');
    await t.tap(text('保存并邀请'));
    await t.pumpAndSettle();
    expect(calls('staff_save').single['role'], 'manager');
  });

  testWidgets('点员工行进入详情：真实本月统计、最近施工，客户好评无数据显示 —', (t) async {
    await open(t, const StaffResourcesPage());
    await t.tap(find.textContaining('真实技师'));
    await t.pumpAndSettle();
    expect(text('员工详情'), findsOneWidget);
    expect(text('真实技师'), findsOneWidget);
    expect(text('本月台次'), findsOneWidget);
    expect(text('¥96'), findsOneWidget);
    expect(text('—'), findsWidgets); // 客户好评
    expect(text('139 **** 5678'), findsOneWidget);
    expect(text('施工技师'), findsWidgets);
    expect(text('沪A12345'), findsOneWidget);
    expect(text('进行中'), findsOneWidget);
    expect(text('昨天 · +¥60'), findsOneWidget);
    expect(calls('staff_get').single['id'], 't1');
  });

  testWidgets('详情 → 编辑：保存只提交输入，由后端校验', (t) async {
    await open(t, const StaffDetailLivePage(staffId: 't1'));
    await t.tap(text('编辑'));
    await t.pumpAndSettle();
    expect(text('编辑员工'), findsOneWidget);
    final name = find.byType(TextFormField).first;
    await t.enterText(name, '新名字');
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    final call = calls('staff_save').single;
    expect(call['id'], 't1');
    expect(call['name'], '新名字');
    expect(call['role'], 'technician');
    expect(call.containsKey('status'), isFalse);
    expect(call.containsKey('store_id'), isFalse);
  });

  testWidgets('新增员工 → 邀请页：展示刚保存的员工，复制登录说明，短信明确未接通', (t) async {
    String? copied;
    t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    addTearDown(
      () => t.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await open(t, const StaffEditorPage());
    final inputs = find.byType(TextFormField);
    await t.enterText(inputs.at(0), '新员工');
    await t.enterText(inputs.at(1), '13800009999');
    await t.tap(text('保存并邀请'));
    await t.pumpAndSettle();
    final save = calls('staff_save').single;
    expect(save['id'], isNull);
    expect(save['name'], '新员工');
    expect(save['phone'], '13800009999');
    expect(text('员工已添加'), findsOneWidget);
    expect(text('邀请新员工登录汽美管家'), findsOneWidget);
    expect(find.textContaining('138 **** 9999'), findsWidgets);
    await t.ensureVisible(text('复制邀请说明'));
    await t.pumpAndSettle();
    await t.tap(text('复制邀请说明'));
    await t.pumpAndSettle();
    expect(copied, contains('13800009999'));
    expect(copied, contains('获取验证码登录'));
    expect(text('邀请说明已复制'), findsWidgets);
    await t.pump(const Duration(seconds: 4));
    await t.ensureVisible(text('发送短信'));
    await t.pumpAndSettle();
    await t.tap(text('发送短信'));
    await t.pumpAndSettle();
    expect(text('短信邀请尚未接通：缺少助通邀请短信模板'), findsWidgets);
  });

  testWidgets('邀请页没有刚添加的员工时给出提示，不展示示例员工', (t) async {
    await open(t, const StaffInviteLivePage());
    expect(find.byType(ErrorView), findsOneWidget);
    expect(text('赵敏'), findsNothing);
  });

  testWidgets('停用账号：无进行中订单时直接停用并回到列表', (t) async {
    await open(t, const StaffDetailLivePage(staffId: 't1'));
    await t.tap(text('停用账号'));
    await t.pumpAndSettle();
    expect(text('停用 真实技师 的账号？'), findsOneWidget);
    expect(find.textContaining('需先转交'), findsNothing);
    await t.tap(text('确认停用'));
    await t.pumpAndSettle();
    final call = calls('staff_status').single;
    expect(call['id'], 't1');
    expect(call['status'], 'disabled');
    expect(call['transfer_to'], isNull);
    expect(text('停用 真实技师 的账号？'), findsNothing);
  });

  testWidgets('停用账号：有进行中订单必须先转交，确认停用不会发请求', (t) async {
    api.openWork = [
      {
        'id': 'a1',
        'plate': '沪A12345',
        'status': 'arrived',
        'items': [
          {'name': '真实洗车'},
        ],
        'bay_name': '真实工位',
      },
    ];
    api.staffRows.add({
      'id': 't2',
      'role': 'technician',
      'name': '接手技师',
      'phone': '13600000000',
      'skills': '镀晶',
      'status': 'active',
      'busy': false,
      'month_orders': 7,
    });
    await open(t, const StaffDetailLivePage(staffId: 't1'));
    await t.tap(text('停用账号'));
    await t.pumpAndSettle();
    expect(text('进行中的 1 个订单需先转交给其他技师'), findsOneWidget);
    await t.tap(text('确认停用'));
    await t.pump();
    expect(text('请先转交进行中的订单'), findsWidgets);
    expect(calls('staff_status'), isEmpty);
    await t.pump(const Duration(seconds: 4));
    await t.tap(text('去转交'));
    await t.pumpAndSettle();
    expect(text('转交进行中的订单'), findsOneWidget);
    expect(text('沪A12345'), findsNWidgets(2)); // 弹层里一张订单卡 + 背后详情页的最近施工
    expect(text('施工中 · 真实工位'), findsOneWidget);
    expect(text('接手技师'), findsOneWidget);
    expect(find.textContaining('本月 7 台次'), findsOneWidget);
    await t.tap(text('转交并停用'));
    await t.pumpAndSettle();
    final call = calls('staff_status').single;
    expect(call['status'], 'disabled');
    expect(call['transfer_to'], 't2');
  });

  testWidgets('已停用员工详情与重新启用', (t) async {
    await open(t, const StaffDetailOffLivePage(staffId: 'x1'));
    expect(text('已停用'), findsOneWidget);
    expect(text('原因：已离职'), findsOneWidget);
    expect(text('停用于 2026.10.18 · 操作人 店主'), findsOneWidget);
    expect(text('1,206 台次'), findsOneWidget);
    expect(text('¥42,380'), findsOneWidget);
    await t.tap(text('重新启用账号'));
    await t.pumpAndSettle();
    expect(text('重新启用 已离职技师 的账号？'), findsOneWidget);
    await t.tap(text('确认启用'));
    await t.pumpAndSettle();
    final call = calls('staff_status').single;
    expect(call['id'], 'x1');
    expect(call['status'], 'enabled');
  });

  testWidgets('提成方案：只有跟随项目设置可保存，其余两项提示待设计，不假装成功', (t) async {
    await open(t, const StaffCommissionLivePage(staffId: 't1'));
    expect(text('上月提成 ¥8,640'), findsNothing);
    expect(find.textContaining('上月提成 ¥8,640'), findsOneWidget);
    expect(text('真实洗车'), findsOneWidget);
    expect(text('8%'), findsOneWidget);
    expect(text('¥60/单'), findsOneWidget);
    await t.tap(text('统一比例'));
    await t.pump();
    expect(find.textContaining('TODO'), findsWidgets);
    expect(calls('staff_commission_save'), isEmpty);
    await t.pump(const Duration(seconds: 4));
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    final call = calls('staff_commission_save').single;
    expect(call['mode'], 'follow');
  });

  testWidgets('施工记录：本月 / 上月 / 全部分别按范围向后端读取', (t) async {
    await open(t, const StaffRecordsLivePage(staffId: 't1'));
    expect(find.textContaining('真实技师 · 施工记录'), findsOneWidget);
    expect(text('沪A12345'), findsOneWidget);
    expect(text('提成 待结算'), findsOneWidget);
    expect(text('+¥60'), findsOneWidget);
    expect(text('1.8 h'), findsOneWidget);
    expect(calls('staff_records').single['range'], 'month');
    await t.tap(text('上月'));
    await t.pumpAndSettle();
    expect(calls('staff_records').last['range'], 'last');
    expect(text('暂无施工记录'), findsOneWidget);
    expect(text('上月台次'), findsOneWidget);
    await t.tap(text('全部'));
    await t.pumpAndSettle();
    expect(calls('staff_records').last['range'], 'all');
    expect(text('累计台次'), findsOneWidget);
  });

  testWidgets('角色权限：技师开关逐项保存；店长固定为全部，修改只提示且不提交', (t) async {
    await open(t, const RolePermissionLivePage(initialRole: 'technician'));
    expect(find.textContaining('对该角色的 1 名员工立即生效'), findsOneWidget);
    // 「查看门店营业统计」默认关闭：点开后只保存技师角色这一项变化
    await t.ensureVisible(text('查看门店营业统计'));
    await t.pumpAndSettle();
    final row = find
        .ancestor(of: text('查看门店营业统计'), matching: find.byType(Row))
        .first;
    await t.tap(
      find.descendant(of: row, matching: find.byType(GestureDetector)).last,
    );
    await t.pump();
    await t.ensureVisible(text('保存'));
    await t.pumpAndSettle();
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    final call = calls('staff_permissions_save').single;
    expect(call['role'], 'technician');
    expect((call['permissions'] as Map)['stats_view_store'], isTrue);
    expect((call['permissions'] as Map)['order_view_own'], isTrue);
  });

  testWidgets('角色权限：店长页签的开关点击只提示固定，保存不提交任何权限', (t) async {
    await open(t, const RolePermissionLivePage(initialRole: 'technician'));
    await t.tap(text('店长'));
    await t.pumpAndSettle();
    await t.ensureVisible(text('开单收银'));
    await t.pumpAndSettle();
    final row = find
        .ancestor(of: text('开单收银'), matching: find.byType(Row))
        .first;
    await t.tap(
      find.descendant(of: row, matching: find.byType(GestureDetector)).last,
    );
    await t.pump();
    expect(find.textContaining('店长权限固定为全部'), findsWidgets);
    await t.pump(const Duration(seconds: 4));
    await t.ensureVisible(text('保存'));
    await t.pumpAndSettle();
    await t.tap(text('保存'));
    await t.pumpAndSettle();
    expect(calls('staff_permissions_save'), isEmpty);
  });
}
