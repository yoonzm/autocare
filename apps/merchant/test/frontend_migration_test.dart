import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/routes.dart';
import 'package:autocare_merchant/navigation/page_registry.dart';

void main() {
  final inventory = jsonDecode(
    File('../../docs/frontend-migration.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final entries = (inventory['entries'] as List).cast<Map<String, dynamic>>();

  test('迁移清单覆盖全部现存页面，移除的旧文件不能继续留在清单', () {
    final listed = entries.map((entry) => 'lib/${entry['path']}').toSet();
    final actualPages = Directory('lib/pages')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .map((file) => file.path.replaceAll('\\', '/'))
        .toSet();
    expect(listed, containsAll(actualPages));
    expect(
      entries.map((entry) => entry['path']).toSet(),
      hasLength(entries.length),
    );
    for (final path in listed) {
      expect(File(path).existsSync(), isTrue, reason: '$path 已移动或删除，需要更新清单');
    }
  });

  test('已验证页面不再使用全局编辑草稿或按路由猜测字段', () {
    final migrated = entries.where((entry) => entry['status'] == 'verified');
    expect(migrated, isNotEmpty);
    for (final entry in migrated) {
      final path = 'lib/${entry['path']}';
      final source = File(path).readAsStringSync();
      for (final legacy in [
        'TaskFlow.currentId',
        'TaskFlow.finished',
        'StaffFlow.currentId',
        'StaffFlow.invited',
        'StaffFlow.transferTo',
        'StaffFlow.permissionRole',
        'StaffFlow.presetRole',
        'CatalogDraft',
        'OrderFlow.',
        'OrderRef.current',
        'StMemberFlow',
        'RegistrationDraft',
        'LegacyControlSlots',
        'imageStore(',
        'HImageSlot(',
        'hPickImage(',
        'hCaptureImage(',
        'FeedbackForm(',
        'feedbackInput(',
        'feedbackImage(',
        'feedbackSubmit(',
        'HInput(',
        'HStrHolder(',
        'HSelHolder(',
        'HHolder(',
        'HCodeHolder(',
        'hSendCode(',
        'PasswordEye(',
        'forgotFlow',
        'hFlowText(',
        'hConfirmPop(',
        '_hasSaveLabel(',
        'ModalRoute.of(context)?.settings.name',
      ]) {
        expect(
          source,
          isNot(contains(legacy)),
          reason: '$path 恢复了旧绑定方式 $legacy',
        );
      }
    }
  });

  test('重复服务选择模板和示例会员选择器已清除，目录列表只展示真实数据', () {
    expect(
      File('lib/pages/catalog/service_picker_sheet.dart').existsSync(),
      isFalse,
    );
    expect(sheetBuilders.containsKey('ServicePicker'), isFalse);
    expect(sheetRoutes.containsKey('ServicePicker'), isFalse);
    final picker = File('lib/kit/pickers.dart').readAsStringSync();
    expect(picker, isNot(contains('mock_data.dart')));
    expect(picker, isNot(contains('class _MemberPicker ')));
    for (final path in [
      'services_page',
      'card_packages_live_page',
      'card_tiers_live_page',
    ]) {
      final source = File('lib/pages/catalog/$path.dart').readAsStringSync();
      expect(source, isNot(contains('mock_data.dart')), reason: path);
      expect(source, isNot(contains('hTap(')), reason: path);
      expect(source, contains('AppErrorType.auth'), reason: path);
    }
  });

  test('预约和员工编辑不再通过文案猜测字段或共享路由提交锁', () {
    for (final path in [
      'widgets/booking_template_bindings.dart',
      'kit/async_action_keys.dart',
    ]) {
      expect(File('lib/$path').existsSync(), isFalse, reason: path);
    }
    final files = [
      ...Directory('lib/pages/booking').listSync().whereType<File>(),
      ...Directory('lib/pages/staff').listSync().whereType<File>(),
    ];
    for (final file in files) {
      final source = file.readAsStringSync();
      for (final legacy in [
        'BookingTemplateController',
        'BookingInput(',
        'BookingSelections(',
        'BookingNumber(',
        'BookingString(',
        'AppointmentFlow.save(',
        'AppointmentFlow.change(',
        'asyncActionKeys',
      ]) {
        expect(
          source,
          isNot(contains(legacy)),
          reason: '${file.path}: $legacy',
        );
      }
    }
    final staff = File('lib/pages/staff/staff_editor_controller.dart')
        .readAsStringSync();
    expect(staff, contains("draft['skills']"));
    expect(staff, contains("draft['bay_id']"));
    expect(staff, isNot(contains("draft['category']")));
    expect(staff, isNot(contains("draft['linked_id']")));
  });

  test('订单中心按实例管理列表与详情，原全局状态和重复退款模板已移除', () {
    expect(File('lib/backend/order_flow.dart').existsSync(), isFalse);
    expect(
      File('lib/pages/orders/order_refund_sheet.dart').existsSync(),
      isFalse,
    );
    for (final path in [
      'lib/pages/orders/order_live_pages.dart',
      'lib/pages/orders/order_list_controller.dart',
      'lib/pages/orders/order_detail_ref.dart',
      'lib/pages/members/member_records_live_page.dart',
    ]) {
      final source = File(path).readAsStringSync();
      expect(source, isNot(contains('OrderRef.current')));
      expect(source, isNot(contains('OrderFlow.')));
      expect(source, isNot(contains("startsWith('次卡')")));
    }
  });

  test('员工会员/开单/核销不再读取全局会员或共享提交 key', () {
    for (final name in [
      'st_member_template',
      'st_member_info_template',
      'st_order_template',
      'st_redeem_sheet',
      'st_cash_queue_template',
    ]) {
      final source = File('lib/pages/staff_app/$name.dart').readAsStringSync();
      for (final legacy in [
        'StMemberFlow',
        "'StOrder>submit'",
        "'StRedeem>send'",
        "'StRedeem>confirm'",
        "'StCashQueue>return'",
        'HInput(',
        'hTap(',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$name: $legacy');
      }
    }
  });

  test('支出字段和动作显式绑定，旧共享绑定层与样例查表已删除', () {
    expect(File('lib/widgets/expense_bindings.dart').existsSync(), isFalse);
    for (final file in Directory(
      'lib/pages/expenses',
    ).listSync().whereType<File>()) {
      final source = file.readAsStringSync();
      for (final old in [
        'c.text(',
        'c.tap(',
        'c.initial(',
        'c.pick(',
        'c.entryText(',
        'c.rowText(',
        'inputValue(',
        'ExpenseSelections(',
        'HSelHolder(',
        'HStrHolder(',
        "'Expense-suggest'",
        "'expense-upload'",
        "'ExpenseAdd_1'",
      ]) {
        expect(source, isNot(contains(old)), reason: '${file.path}: $old');
      }
    }
  });

  test('公共组件中已移除的目录编辑业务推断不能重新引入', () {
    for (final path in [
      'lib/kit/kit.dart',
      'lib/kit/pickers.dart',
      'lib/kit/image_pick.dart',
    ]) {
      final source = File(path).readAsStringSync();
      for (final route in [
        'ServiceEdit',
        'CardTierEdit',
        'PackageEdit',
        'ChangePassword',
        'ChangePhone',
        'ForgotVerify',
        'ForgotReset',
        'RegPhone',
        'RegShop',
        'DeleteAccount',
        'ProfileEdit',
        'StoreAdd',
        'StoreEdit',
        'Security',
        'MemberAdd',
        'MemberEdit',
        'VehicleAdd',
        'MemberDelete',
      ]) {
        expect(source, isNot(contains("'$route'")), reason: '$path: $route');
      }
    }
  });
  test('会员资料和车辆控件不再持有跨页面车牌、颜色或表单回填状态', () {
    for (final path in [
      'lib/kit/pickers.dart',
      'lib/widgets/color_fields.dart',
    ]) {
      final source = File(path).readAsStringSync();
      for (final oldBinding in [
        'CatalogDraft',
        '_memberField(',
        'plateEnergy',
        'ScanFlow.takePrefill',
      ]) {
        expect(
          source,
          isNot(contains(oldBinding)),
          reason: '$path: $oldBinding',
        );
      }
    }
    final flow = File('lib/backend/member_flow.dart').readAsStringSync();
    for (final oldCommand in [
      'void beginAdd(',
      'void beginEdit(',
      'void beginVehicle(',
      'void applyRecognizedVehicle(',
      'Future<void> create(',
      'Future<void> update(',
      'Future<void> saveVehicle(',
      'Future<void> deleteCurrent(',
    ]) {
      expect(flow, isNot(contains(oldCommand)), reason: oldCommand);
    }
  });
  test('会员收款、次卡和会员选择不再使用全局编辑对象或按文案绑定', () {
    final paths = [
      'lib/pages/members/member_picker_sheet.dart',
      'lib/pages/members/member_picker_widgets.dart',
      ...Directory('lib/pages/members')
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('wallet') ||
                f.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('recharge'),
          )
          .map((f) => f.path),
      ...Directory('lib/pages/members/packages')
          .listSync()
          .whereType<File>()
          .map((f) => f.path),
    ];
    for (final path in paths) {
      final source = File(path).readAsStringSync();
      for (final legacy in [
        'MemberFlow.current',
        'CatalogDraft',
        'hTap(',
        'HSelHolder(',
        'hMemberText(',
        'hRechargeText(',
        'hPackageText(',
        '_samplePackages(',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$path: $legacy');
      }
    }
    for (final path in ['lib/kit/kit.dart', 'lib/routes.dart']) {
      final source = File(path).readAsStringSync();
      for (final legacy in [
        'MemberFlow.beginRecharge',
        'MemberFlow.beginExtend',
        'MemberFlow.beginRefund',
        'MemberFlow.currentPackage',
        'MemberFlow.lastRecharge',
        'MemberFlow.lastSale',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$path: $legacy');
      }
    }
  });
  test('会员调整、回访与筛选清除全局草稿和路由业务初始化', () {
    for (final name in [
      'member_adjust_page',
      'member_adjust_controller',
      'member_visit_page',
      'member_visit_controller',
      'member_follow_up_page',
      'member_reminder_controller',
      'member_filter_sheet',
      'member_filter_controller',
      'member_more_sheet',
      'reminder_widgets',
      'visit_history',
      'members_page',
      'member_detail_page',
    ]) {
      final source = File('lib/pages/members/$name.dart').readAsStringSync();
      for (final legacy in [
        'MemberFlow.',
        'CatalogDraft',
        'hTap(',
        'HSelHolder(',
        'HHolder(',
        'HInput(',
        'hFollowText(',
        'hFollowRich(',
        'hVisitNext(',
        'hTierName(',
        'hFilterCountText(',
        'memberVehicles[',
        'memberPacks[',
        'members.where(',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$name: $legacy');
      }
    }
    for (final path in ['lib/kit/kit.dart', 'lib/routes.dart']) {
      final source = File(path).readAsStringSync();
      for (final legacy in [
        'MemberFlow.beginAdjust',
        'MemberFlow.adjust(',
        'MemberFlow.beginVisit',
        'MemberFlow.saveVisit',
        'MemberFlow.filter',
        'MemberFlow.loadReminders',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$path: $legacy');
      }
    }
    expect(File('lib/widgets/follow_widgets.dart').existsSync(), isFalse);
  });
  test('开单、挂单和扫描不再依赖全局目标、草稿或最近一次结果', () {
    for (final name in [
      'order_page',
      'order_checkout',
      'order_route_data',
      'order_receipt_view',
      'pay_success_page',
      'hold_list_page',
      'hold_sheet_sheet',
      'hold_board',
      'hold_controller',
      'hold_draft',
    ]) {
      final source = File('lib/pages/orders/$name.dart').readAsStringSync();
      for (final legacy in [
        'CatalogDraft',
        'MemberFlow.',
        'ScanFlow.',
        'HoldFlow.',
        'hTap(',
        'HSelHolder(',
        'HInput(',
        'hHoldText(',
        'hOrderText(',
        '_samples',
        'mock/mock_data.dart',
      ]) {
        expect(source, isNot(contains(legacy)), reason: '$name: $legacy');
      }
    }
    for (final file in Directory(
      'lib/pages/scan',
    ).listSync().whereType<File>()) {
      final source = file.readAsStringSync();
      for (final legacy in [
        'ScanFlow.',
        'MemberFlow.',
        'imageStore(',
        'hCaptureImage(',
        'hScanText(',
        'hMemberText(',
        'hTap(',
      ]) {
        expect(
          source,
          isNot(contains(legacy)),
          reason: '${file.path}: $legacy',
        );
      }
    }
    for (final name in [
      'backend/catalog_draft.dart',
      'backend/scan_flow.dart',
      'backend/hold_flow.dart',
      'kit/legacy_control_slots.dart',
      'widgets/member_widgets.dart',
      'widgets/hold_widgets.dart',
    ]) {
      expect(File('lib/$name').existsSync(), isFalse, reason: name);
    }
    final member = File('lib/backend/member_flow.dart').readAsStringSync();
    expect(member, isNot(contains('class MemberFlow')));
    final store = File('lib/backend/hold_store.dart').readAsStringSync();
    for (final editing in [
      'static HoldDraft',
      'static HoldEvent',
      'static final tab',
      'static void begin(',
    ]) {
      expect(store, isNot(contains(editing)), reason: editing);
    }
    final images = File('lib/kit/image_pick.dart').readAsStringSync();
    expect(images, isNot(contains('imageStore(')));
  });
  test('库存页面与控制器不再根据示例文案和目标路由分发字段或动作', () {
    for (final file in Directory(
      'lib/pages/inventory',
    ).listSync().whereType<File>()) {
      final source = file.readAsStringSync();
      for (final oldBinding in [
        'c.text(',
        'c.initial(',
        'c.lineText(',
        'c.batchText(',
        'c.recordText(',
        'c.tap(',
        'InventorySelections(',
        'InventoryManagementSelections(',
        'String sample',
        'String? intent',
        'String? action',
        'String? to',
        'HStrHolder(',
        'HSelHolder(',
        'hTap(',
      ]) {
        expect(
          source,
          isNot(contains(oldBinding)),
          reason: '${file.path}: $oldBinding',
        );
      }
    }
  });
  test('导航只构建页面与传参，不保留全局组合页签或执行业务请求', () {
    final routes = File('lib/routes.dart').readAsStringSync();
    expect(routes, isNot(contains('pairTabs')));
    expect(routes, isNot(contains('class PairPage')));
    expect(routes, isNot(matches(RegExp(r'merchantApi\.(?!hasSession)'))));
    final profile = File('lib/backend/store_profile.dart').readAsStringSync();
    for (final old in [
      'seededServices',
      'subscriptionDays',
      'applyDirectory',
      'storeOffer',
    ]) {
      expect(profile, isNot(contains(old)), reason: old);
    }
    final supplier = File('lib/pages/inventory/inventory_pickers.dart')
        .readAsStringSync();
    expect(supplier, isNot(contains("'inventory-supplier-save'")));
  });

  test('共享控件不再分发业务字段，示例数据与身份选择草稿已移出生产源码', () {
    final kit = File('lib/kit/kit.dart').readAsStringSync();
    final pickers = File('lib/kit/pickers.dart').readAsStringSync();
    for (final legacy in [
      'class HInput ',
      'class HHolder ',
      'class HDyn ',
      'class HSelHolder ',
    ]) {
      expect(kit, isNot(contains(legacy)), reason: legacy);
    }
    for (final legacy in [
      'Future<void> hPick(',
      'class HStrHolder ',
      'class HCodeHolder ',
      'const _techs',
      'const _today',
    ]) {
      expect(pickers, isNot(contains(legacy)), reason: legacy);
    }
    expect(Directory('lib/mock').existsSync(), isFalse);
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      expect(source, isNot(contains('AccessFlow.items')), reason: file.path);
      expect(source, isNot(contains('AccessFlow.phone')), reason: file.path);
      expect(source, isNot(contains('mock_data.dart')), reason: file.path);
    }
    final info = File('lib/pages/account/store_info_page.dart')
        .readAsStringSync();
    for (final sample in ['CG-0021', '共 6 张', "'专业版'", "'StoreQR'", '驰光汽车美容']) {
      expect(info, isNot(contains(sample)), reason: sample);
    }
    final stats = File('lib/pages/shared/stats_page.dart').readAsStringSync();
    expect(stats, isNot(contains('revenueShares')));
    expect(stats, isNot(contains('328,460')));
  });

  test('通用点击包装及其演示回退已删除，页面显式绑定动作', () {
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      expect(
        file.readAsStringSync(),
        isNot(contains('hTap(')),
        reason: file.path,
      );
    }
  });

  test('旧目录已移除，保留代码的导入不能重新指向生成目录', () {
    for (final name in ['gen', 'gen_st', 'st_gen']) {
      expect(Directory('lib/pages/$name').existsSync(), isFalse);
    }
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      final imports = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''')
          .allMatches(source);
      for (final match in imports) {
        expect(
          match.group(1),
          isNot(matches(RegExp(r'(?:^|/)(?:gen|gen_st|st_gen)/'))),
          reason: file.path,
        );
      }
    }
  });
  test('一期不用的前端路由不再注册，已删除源码不再返回', () {
    for (final name in [
      'Plans',
      'PlanCheckout',
      'Subscription',
      'Renew',
      'PlanExpired',
      'PayConfig',
      'PayMethod',
      'PayApplyIntro',
      'StoreSwitch',
      'StoreAdd',
      'DataBackup',
      'NotifySettings',
      'Messages',
      'Printer',
      'BindH5',
      'BindDone',
      'WechatBind',
      'MemberSendMsg',
    ]) {
      expect(pageFor(name), isNull, reason: name);
      expect(pageBuilders.containsKey(name), isFalse, reason: name);
      expect(sheetRoutes.containsKey(name), isFalse, reason: name);
    }
    for (final entry in (inventory['removed'] as List)) {
      expect(
        File('lib/${entry['path']}').existsSync(),
        isFalse,
        reason: entry['path'],
      );
    }
  });
}
