import 'store_context.dart';

import 'dart:math';

import 'package:flutter/foundation.dart' show ValueNotifier, visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:autocare_supabase_adapter/errors.dart';

import '../kit/async_kit.dart';
import 'store_profile.dart';
import 'plate_photo.dart';

export '../kit/async_kit.dart' show AppError, AppErrorType;

const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://autocare.mymember.ltd',
);
const supabasePublishableKey = String.fromEnvironment(
  'SUPABASE_PUBLISHABLE_KEY',
  defaultValue: 'sb_publishable_mzNkMTh1lVnIXThevC--Zj_5bG1XkCJ',
);

/// 登录态失效（刷新令牌也失败）时 +1，App 根据它回到登录页。
final ValueNotifier<int> authExpired = ValueNotifier(0);

/// 服务端返回的身份 / 套餐状态（plan_expired / join_required / staff_disabled），由 App 外壳统一跳转。
final ValueNotifier<String?> accessIssue = ValueNotifier<String?>(null);

/// Only calls the V1 cloud function. Business tables are never written here.
/// [MerchantApi.members] 的结果。
class MemberPage {
  final List<Map<String, dynamic>> items;
  final Map<String, int> counts;
  final int total;
  final int matched;
  final num totalBalance;
  final int newThisMonth;
  const MemberPage({
    required this.items,
    this.counts = const {},
    this.total = 0,
    int? matched,
    this.totalBalance = 0,
    this.newThisMonth = 0,
  }) : matched = matched ?? items.length;
}

class MerchantApi {
  SupabaseClient get client => Supabase.instance.client;

  bool get hasSession {
    try {
      return client.auth.currentSession != null;
    } catch (_) {
      return false; // Widget tests may construct the app without main().
    }
  }

  /// 不需要登录态的动作：401 是业务失败（如密码错误），不能当成登录失效。
  static const _publicActions = {
    'regions',
    'send_code',
    'forgot_verify',
    'reset_password',
    'check_code',
    'holds',
    'hold_get',
    'register',
    'login_password',
    'login_code',
  };

  /// 只读、可重复的请求：失败时静默重试 1 次；写请求不自动重试。
  static const _readActions = {
    'regions',
    'expense_board',
    'expense_source',
    'expense_get',
    'expense_suggest',
    'expense_voucher',
    'inventory_list',
    'inventory_get',
    'inventory_draft',
    'inventory_quote',
    'inventory_options',
    'inventory_assignments',
    'inventory_documents',
    'inventory_document_get',
    'inventory_lookup',
    'appointment_board',
    'appointment_get',
    'appointment_options',
    'appointment_slots',
    'appointment_summary',
    'staff_list',
    'staff_get',
    'staff_records',
    'staff_home',
    'identity_list',
    'identity_context',
    'home_stats',
    'settings_stats',
    'list_stores',
    'get_subscription',
    'subscription_catalog',
    'list',
    'get',
    'get_store',
    'check_code',
    'reminders',
  };

  static final _rand = Random.secure();

  /// 写请求的请求编号（X-Request-Id），由对应业务后端在事务内执行幂等校验。
  static String newRequestId() {
    final b = List<int>.generate(16, (_) => _rand.nextInt(256));
    return b.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = kRequestTimeout,
    String? requestId,
  }) async {
    final action = body['action']?.toString() ?? '';
    final isRead = _readActions.contains(action);
    // 同一次点击的重试沿用同一个标识
    requestId = isRead ? null : requestId ?? newRequestId();
    final epoch = StoreContext.epoch;
    Future<Map<String, dynamic>> send() async {
      if (epoch != StoreContext.epoch) throw const AppError('门店已切换，请重新操作');
      final result = await performRequest(body, timeout, requestId);
      if (epoch != StoreContext.epoch) throw const AppError('门店已切换，请重新操作');
      return result;
    }

    try {
      return await send();
    } on AppError catch (e) {
      // 身份 / 套餐状态：交给全局处理（回登录、套餐到期页、加入门店），不当作令牌失效重试
      if (const {
        'plan_expired',
        'join_required',
        'staff_disabled',
      }.contains(e.code)) {
        accessIssue.value = e.code;
        rethrow;
      }
      if (e.type == AppErrorType.auth && !_publicActions.contains(action)) {
        // 401：先静默刷新令牌；仍失败才判定登录失效
        try {
          await refreshAuth();
          return await send();
        } catch (_) {
          authExpired.value++;
          throw const AppError('登录已过期，请重新登录', type: AppErrorType.auth);
        }
      }
      if (isRead && e.retryable) {
        await Future<void>.delayed(const Duration(seconds: 1));
        return send();
      }
      rethrow;
    }
  }

  /// 静默刷新令牌（401 时调用）。
  @visibleForTesting
  Future<void> refreshAuth() async {
    await withSupabaseErrors(() => client.auth.refreshSession());
  }

  /// 发出一次请求，失败统一抛 [AppError]（不含重试 / 刷新令牌逻辑）。
  @visibleForTesting
  Future<Map<String, dynamic>> performRequest(
    Map<String, dynamic> body,
    Duration timeout,
    String? requestId,
  ) async {
    final epoch = StoreContext.epoch;
    try {
      final response = await client.functions
          .invoke(
            'merchant-v1',
            body: body,
            headers: {
              'X-Request-Id': ?requestId,
              'X-Store-Id': ?StoreContext.id,
            },
          )
          .timeout(timeout);
      if (epoch != StoreContext.epoch) throw const AppError('门店已切换，请重新操作');
      final data = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : <String, dynamic>{};
      if (response.status < 200 ||
          response.status >= 300 ||
          data['error'] != null) {
        final error = AppError.fromStatus(
          response.status,
          data['error']?.toString(),
        );
        final code = data['code']?.toString();
        throw code == null || code.isEmpty
            ? error
            : AppError(error.message, type: error.type, code: code);
      }
      return data;
    } catch (e) {
      throw supabaseAppError(e);
    }
  }

  /// 验证码通过短信发送，任何环境都不从接口读取验证码。
  Future<void> sendCode(String phone, {required String purpose}) async {
    await invoke({'action': 'send_code', 'phone': phone, 'purpose': purpose});
  }

  /// Validates the code on the server without consuming it.
  Future<void> checkCode(String phone, String code) async {
    await invoke({'action': 'check_code', 'phone': phone, 'code': code});
  }

  /// 开通门店。返回云函数给新门店初始化的数据量：
  /// `{'services': 服务项目数, 'products': 零库存商品数, 'cards': 会员卡种数, 'packages': 次卡套餐数, 'bays': 工位数}`。
  Future<Map<String, dynamic>> register({
    required String phone,
    required String code,
    required String password,
    required String storeName,
    Map<String, dynamic> profile = const {},
  }) async {
    return invoke({
      'action': 'register',
      'phone': phone,
      'code': code,
      'password': password,
      'store_name': storeName,
      ...profile,
    });
  }

  Future<Map<String, dynamic>> getStore() async {
    final data = await invoke({'action': 'get_store'});
    return Map<String, dynamic>.from(data['store'] as Map);
  }

  Future<Map<String, dynamic>> storeMutation(
    String action,
    Map<String, dynamic> values, {
    String? requestId,
  }) async {
    final data = await invoke({
      'action': 'store_$action',
      ...values,
    }, requestId: requestId);
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> subscriptionCatalog() async {
    if (!hasSession) throw const AppError('请先登录', type: AppErrorType.auth);
    final data = await invoke({'action': 'subscription_catalog'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> simulateSubscription(
    Map<String, dynamic> body, {
    required String requestId,
  }) async {
    final data = await invoke({
      'action': 'subscription_simulate',
      ...body,
    }, requestId: requestId);
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> subscription() async {
    final data = await invoke({'action': 'get_subscription'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> stores() async {
    if (!hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    final data = await invoke({'action': 'list_stores'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> settingsStats() async {
    if (!hasSession) {
      throw const AppError('请先登录', type: AppErrorType.auth);
    }
    final data = await invoke({'action': 'settings_stats'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> homeStats() async {
    final data = await invoke({'action': 'home_stats'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> appointment(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final data = await invoke({...values, 'action': 'appointment_$action'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 员工管理：list / get / records 读取；save / status / commission_save / permissions_save / invite 写入。
  /// 权限、角色、提成、状态变更都在云函数与数据库事务中校验，客户端只提交输入。
  Future<Map<String, dynamic>> staff(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final data = await invoke({...values, 'action': 'staff_$action'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 登录后的身份：list 列出「门店 + 身份」/ select 选择身份（staff_id 为空表示老板）/ join 首次确认加入门店 /
  /// context 当前身份、生效权限与套餐状态。权限在服务端逐请求校验，这里只用来决定显示什么。
  Future<Map<String, dynamic>> identity(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final data = await invoke({...values, 'action': 'identity_$action'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 员工工作台（技师：今日任务与业绩；前台：今日笔数与待到店）。
  Future<Map<String, dynamic>> staffHome() async {
    final data = await invoke({'action': 'staff_home'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 员工工作流：staff_task_list / staff_task_detail / staff_task_progress / staff_task_finish /
  /// staff_perf / staff_messages / staff_messages_read。数据范围由服务端按当前身份限定。
  Future<Map<String, dynamic>> staffWork(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final data = await invoke({...values, 'action': action});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 订单中心：list（统一订单列表 + 汇总）/ detail / refund。金额、状态、退回方式都由云函数计算。
  Future<Map<String, dynamic>> orderCenter(
    String action, [
    Map<String, dynamic> values = const {},
  ]) async {
    final data = await invoke({...values, 'action': 'order_$action'});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await invoke({
      'action': 'change_password',
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }

  Future<void> changePhone({
    required String code,
    required String newPhone,
    required String newCode,
  }) async {
    await invoke({
      'action': 'change_phone',
      'code': code,
      'new_phone': newPhone,
      'new_code': newCode,
    });
  }

  /// Starts the 15-day cooling-off period; the server also ends all sessions.
  Future<void> deleteAccount(String code) async {
    await invoke({'action': 'delete_account', 'code': code});
  }

  /// 忘记密码第 1 步：验证码正确，且该手机号是已开通门店的账号。
  Future<void> forgotVerify(String phone, String code) async {
    await invoke({'action': 'forgot_verify', 'phone': phone, 'code': code});
  }

  /// 忘记密码第 2 步：重置密码；成功后所有设备的登录状态都会失效。
  Future<void> resetPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) async {
    await invoke({
      'action': 'reset_password',
      'phone': phone,
      'code': code,
      'new_password': newPassword,
    });
  }

  Future<void> loginPassword(String phone, String password) async {
    final data = await invoke({
      'action': 'login_password',
      'phone': phone,
      'password': password,
    });
    loginHasStaff = data['staff'] == true;
    await withSupabaseErrors(
      () => client.auth.setSession(
        data['refresh_token'] as String,
        accessToken: data['access_token'] as String,
      ),
    );
  }

  /// 最近一次登录的手机号是否登记了员工身份（服务端判断）；是则登录后要走身份选择，而不是直接进商家首页。
  bool loginHasStaff = false;

  Future<void> loginCode(String phone, String code) async {
    final data = await invoke({
      'action': 'login_code',
      'phone': phone,
      'code': code,
    });
    loginHasStaff = data['staff'] == true;
    await withSupabaseErrors(
      () => client.auth.setSession(
        data['refresh_token'] as String,
        accessToken: data['access_token'] as String,
      ),
    );
  }

  Future<void> signOut() async {
    StoreContext.bind(null);
    storeProfile.clear();
    await withSupabaseErrors(() => client.auth.signOut());
  }

  /// 退出所有设备：作废这个账号的全部会话。
  Future<void> signOutAll() async {
    StoreContext.bind(null);
    storeProfile.clear();
    await withSupabaseErrors(
      () => client.auth.signOut(scope: SignOutScope.global),
    );
  }

  Future<List<Map<String, dynamic>>> list(String kind) async {
    final data = await invoke({'action': 'list', 'kind': kind});
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  /// 会员卡的通用规则（充值或消费自动升级 / 储值余额可退款）。
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async {
    final data = await invoke({'action': 'rules', 'kind': 'cards'});
    final r = Map<String, dynamic>.from(data['rules'] as Map);
    return (
      autoUpgrade: r['auto_upgrade'] == true,
      balanceRefundable: r['balance_refundable'] == true,
    );
  }

  Future<void> saveCardRules({
    required bool autoUpgrade,
    required bool balanceRefundable,
  }) async {
    await invoke({
      'action': 'save_rules',
      'kind': 'cards',
      'auto_upgrade': autoUpgrade,
      'balance_refundable': balanceRefundable,
    });
  }

  /// 会员列表：可按姓名 / 手机号 / 车牌搜索，按卡种、储值余额、最近到店筛选，分页。
  /// [counts] 是各卡种的会员数、[total] 是会员总数、[totalBalance] 是储值余额合计、
  /// [newThisMonth] 是本月新增（这几项不受搜索和筛选影响）；[matched] 是符合条件的总数。
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
    final data = await invoke({
      'action': 'list',
      'kind': 'members',
      if (recent) 'sort': 'recent',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      'card_type_id': ?cardTypeId,
      if (cardTypeIds != null && cardTypeIds.isNotEmpty)
        'card_type_ids': cardTypeIds,
      'balance_min': ?balanceMin,
      'balance_max': ?balanceMax,
      'visited_within_days': ?visitedWithinDays,
      'visited_over_days': ?visitedOverDays,
      'offset': offset,
      'limit': limit,
    });
    return MemberPage(
      items: List<Map<String, dynamic>>.from(data['items'] as List),
      counts: {
        for (final e in Map<String, dynamic>.from(
          (data['counts'] as Map?) ?? const {},
        ).entries)
          e.key: (e.value as num).toInt(),
      },
      total: (data['total'] as num?)?.toInt() ?? 0,
      matched: (data['matched'] as num?)?.toInt() ?? 0,
      totalBalance: (data['total_balance'] as num?) ?? 0,
      newThisMonth: (data['new_this_month'] as num?)?.toInt() ?? 0,
    );
  }

  // ───────── 次卡（会员名下） ─────────
  Future<List<Map<String, dynamic>>> memberPackages(String memberId) async {
    final data = await invoke({
      'action': 'list',
      'kind': 'member_packages',
      'member_id': memberId,
    });
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  Future<Map<String, dynamic>> memberPackage(String id) async {
    final data = await invoke({
      'action': 'get',
      'kind': 'member_packages',
      'id': id,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 购买次卡：价格、次数、有效期、限购都由云函数决定；收款方式只是记账。
  Future<Map<String, dynamic>> sellPackage({
    required String memberId,
    required String packageId,
    required String method,
  }) async {
    final data = await invoke({
      'action': 'sell',
      'kind': 'member_packages',
      'member_id': memberId,
      'package_id': packageId,
      'method': method,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> extendPackage({
    required String id,
    required int days,
    required String reason,
  }) async {
    final data = await invoke({
      'action': 'extend',
      'kind': 'member_packages',
      'id': id,
      'days': days,
      'reason': reason,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> refundPackage({
    required String id,
    required String to,
    required String reason,
  }) async {
    final data = await invoke({
      'action': 'refund',
      'kind': 'member_packages',
      'id': id,
      'to': to,
      'reason': reason,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 充值档位和赠送金额：`[{amount, gift}]`。
  Future<List<Map<String, dynamic>>> rechargeOptions() async {
    final data = await invoke({
      'action': 'recharge_options',
      'kind': 'members',
    });
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  // ───────── 扫码找会员（车牌识别） ─────────
  /// 图片只发给后端，识别与本店会员匹配均由云函数完成；不自动重试付费识别。
  Future<Map<String, dynamic>> recognizePlate(String imagePath) async =>
      invoke({
        'action': 'recognize_plate',
        'kind': 'members',
        ...await preparePlatePhoto(imagePath),
      });

  // ───────── 开单收银 ─────────
  /// [lines]: `[{service_id, qty, member_package_id?}]`。价格、折扣、次卡抵扣、扣款都由云函数算。
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
    final data = await invoke({
      'action': 'checkout',
      'kind': 'orders',
      'member_id': memberId,
      'lines': lines,
      'method': method,
      'balance_part': ?balancePart,
      'other': ?other,
      'plate': plate,
      'remark': remark,
      'hold_id': ?holdId,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 散客开单：不记会员、没有折扣和次卡抵扣，只能用微信 / 支付宝 / 现金 / POS 刷卡。
  Future<Map<String, dynamic>> checkoutWalkIn({
    required List<Map<String, dynamic>> lines,
    required String method,
    String plate = '',
    String remark = '',
    String? holdId,
  }) async {
    final data = await invoke({
      'action': 'checkout',
      'kind': 'orders',
      'walk_in': true,
      'hold_id': ?holdId,
      'lines': lines,
      'method': method,
      'plate': plate,
      'remark': remark,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  // ───────── 挂单 ─────────
  /// 待处理的挂单（含明细、会员、云函数按当时价格算的估价 `estimate`）。
  Future<List<Map<String, dynamic>>> holds() async {
    final data = await invoke({'action': 'holds', 'kind': 'orders'});
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  /// 挂起 / 修改一张挂单。[holdId] 为空 = 新挂单，否则整单替换明细。
  Future<Map<String, dynamic>> saveHold({
    String? holdId,

    /// 为空 = 散客挂单（不记会员，没有折扣和次卡）。
    String? memberId,
    required List<Map<String, dynamic>> lines,
    String status = '待施工',
    String note = '',
    String remind = '不提醒',
    String plate = '',
  }) async {
    final data = await invoke({
      'action': 'hold',
      'kind': 'orders',
      'hold_id': ?holdId,
      if (memberId == null) 'walk_in': true else 'member_id': memberId,
      'lines': lines,
      'status': status,
      'note': note,
      'remind': remind,
      'plate': plate,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<void> cancelHold(String id) async {
    await invoke({'action': 'hold_cancel', 'kind': 'orders', 'id': id});
  }

  // ───────── 回访 ─────────
  Future<List<Map<String, dynamic>>> followUps(String memberId) async {
    final data = await invoke({
      'action': 'list',
      'kind': 'follow_ups',
      'member_id': memberId,
    });
    return List<Map<String, dynamic>>.from(data['items'] as List);
  }

  Future<void> saveFollowUp({
    required String memberId,
    required String method,
    required String result,
    String content = '',
    String? nextAt,
  }) async {
    await invoke({
      'action': 'save',
      'kind': 'follow_ups',
      'member_id': memberId,
      'method': method,
      'result': result,
      'content': content,
      'next_at': ?nextAt,
    });
  }

  Future<void> markFollowedUp(String memberId, {String content = ''}) async {
    await invoke({
      'action': 'mark',
      'kind': 'follow_ups',
      'member_id': memberId,
      'content': content,
    });
  }

  /// 回访提醒：次卡到期 / 生日 / 沉睡客户，今天回访过的不再出现。
  Future<Map<String, dynamic>> reminders() =>
      invoke({'action': 'reminders', 'kind': 'follow_ups'});

  /// 储值充值：赠送金额由云函数按规则算出；返回到账后的余额、赠送、获得积分、是否升级。
  Future<Map<String, dynamic>> recharge({
    required String memberId,
    required num amount,
    required String method,
    String note = '',
  }) async {
    final data = await invoke({
      'action': 'recharge',
      'kind': 'members',
      'id': memberId,
      'amount': amount,
      'method': method,
      'note': note,
    });
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  /// 手动调整卡种 / 积分（必须带原因）。
  Future<void> adjustMember({
    required String memberId,
    String? tierId,
    int points = 0,
    required String reason,
    String note = '',
  }) async {
    await invoke({
      'action': 'adjust',
      'kind': 'members',
      'id': memberId,
      'tier_id': ?tierId,
      'points': points,
      'reason': reason,
      'note': note,
    });
  }

  /// 会员的流水（充值、调整、升级），新的在前。
  Future<({List<Map<String, dynamic>> items, int total})> ledger(
    String memberId, {
    String filter = 'all',
    int offset = 0,
    int limit = 30,
  }) async {
    final data = await invoke({
      'action': 'ledger',
      'kind': 'members',
      'id': memberId,
      'filter': filter,
      'offset': offset,
      'limit': limit,
    });
    return (
      items: List<Map<String, dynamic>>.from(data['items'] as List),
      total: (data['total'] as num?)?.toInt() ?? 0,
    );
  }

  Future<Map<String, dynamic>> member(String id) async {
    final data = await invoke({'action': 'get', 'kind': 'members', 'id': id});
    return Map<String, dynamic>.from(data['item'] as Map);
  }

  Future<Map<String, dynamic>> save(String kind, Map<String, dynamic> values) =>
      invoke({'action': 'save', 'kind': kind, ...values});

  Future<void> delete(String kind, String id) async {
    await invoke({'action': 'delete', 'kind': kind, 'id': id});
  }
}

MerchantApi merchantApi = MerchantApi();
