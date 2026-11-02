import 'dart:async';

import 'package:flutter/material.dart';

import '../kit/async_kit.dart';
import '../mock/mock_data.dart';
import '../routes.dart';
import 'catalog_draft.dart';
import 'merchant_api.dart';
import 'package_calc.dart' show formatMoney;

/// 会员（核心维护）的适配层：编辑草稿、保存、删除，以及“当前会员”。
///
/// 页面里的输入框 / 选项由 `kit.dart` 按页面名和示例值绑定到 [CatalogDraft]
/// 的 `members` / `vehicles` 草稿；这里负责把草稿提交给云函数。
/// 办卡的规则（发放哪张卡种、手机号 / 车牌唯一）都在云函数里，这里只收集输入、展示结果。
class MemberFlow {
  MemberFlow._();

  /// 正在查看 / 刚办卡的会员（后端返回的整条记录，含卡种和车辆）。
  static Map<String, dynamic>? current;

  /// 称呼：设计稿两个选项，顺序固定。
  static const honorifics = ['先生', '女士'];

  /// 客户来源，顺序与设计稿一致。
  static const sources = ['到店自然客', '老客推荐', '团购平台', '短视频'];

  /// 车身颜色，顺序与设计稿的 5 个色块一致。
  static const colors = [
    '黑色',
    '白色',
    '银色',
    '灰色',
    '红色',
    '蓝色',
    '棕色',
    '香槟金',
    '绿色',
    '橙色',
    '紫色',
  ];

  /// 新建会员草稿：设计稿默认称呼先生；来源默认不选。
  static void beginAdd() {
    CatalogDraft.begin('members');
    CatalogDraft.set('members', 'honorific', '先生');
    CatalogDraft.set('members', 'color', colors.first);
    CatalogDraft.set('members', 'energy', 'fuel');
  }

  static void beginEdit(Map<String, dynamic> member) {
    CatalogDraft.begin('members', {
      'id': member['id'],
      'phone': member['phone'],
      'name': member['name'],
      'honorific': member['honorific'],
      'birthday': _birthdayText(member['birthday']),
      'note': member['note'],
    });
  }

  static void beginVehicle(String memberId) =>
      CatalogDraft.begin('vehicles', {'member_id': memberId, 'energy': 'fuel'});

  /// `1985-06-12` -> `1985.06.12`
  static String _birthdayText(Object? v) =>
      v == null ? '' : v.toString().replaceAll('-', '.');

  static String get _phoneDigits =>
      '${CatalogDraft.current?.fields['phone'] ?? ''}'.replaceAll(
        RegExp(r'\D'),
        '',
      );

  // ───────── 办卡（新增会员） ─────────
  /// 保存新会员。成功后进入“开卡成功”页；失败用 Toast 说明原因，输入保留。
  static Future<void> create(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'members') return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    final name = '${f['name'] ?? ''}'.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneDigits)) {
      fail('请输入正确的 11 位手机号');
      return;
    }
    if (name.isEmpty) {
      fail('请输入客户姓名');
      return;
    }
    final source = '${f['source'] ?? ''}';
    final referrer = '${f['referrer_id'] ?? ''}';
    final plate = '${f['plate'] ?? ''}'.trim();
    if (source == '老客推荐' && referrer.isEmpty) {
      // 推荐人是选填：没选就按没有推荐人保存
    }
    final values = <String, dynamic>{
      'phone': _phoneDigits,
      'name': name,
      'honorific': '${f['honorific'] ?? ''}',
      'birthday': '${f['birthday'] ?? ''}'.replaceAll('.', '-'),
      'source': source,
      if (source == '老客推荐' && referrer.isNotEmpty) 'referrer_id': referrer,
      'note': '${f['note'] ?? ''}'.trim(),
      // 车辆是选填：填了车牌才登记
      if (plate.isNotEmpty)
        'vehicle': {
          'plate': plate,
          'energy': '${f['energy'] ?? 'fuel'}',
          'brand_model': '${f['brand_model'] ?? ''}',
          'color': '${f['color'] ?? ''}',
        },
    };
    try {
      final res = await merchantApi.save('members', values);
      current = Map<String, dynamic>.from(res['item'] as Map);
      CatalogDraft.changed.value++;
      if (context.mounted) openRoute(context, 'MemberAddDone');
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 修改资料 ─────────
  static Future<void> update(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'members' || draft.id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    final name = '${f['name'] ?? ''}'.trim();
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneDigits)) {
      fail('请输入正确的 11 位手机号');
      return;
    }
    if (name.isEmpty) {
      fail('请输入姓名');
      return;
    }
    try {
      final res = await merchantApi.save('members', {
        'id': draft.id,
        'phone': _phoneDigits,
        'name': name,
        'honorific': '${f['honorific'] ?? ''}',
        'birthday': '${f['birthday'] ?? ''}'.replaceAll('.', '-'),
        'note': '${f['note'] ?? ''}'.trim(),
      });
      current = Map<String, dynamic>.from(res['item'] as Map);
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 车辆 ─────────
  static Future<void> saveVehicle(BuildContext context) async {
    final draft = CatalogDraft.current;
    if (draft == null || draft.kind != 'vehicles') return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    if ('${f['plate'] ?? ''}'.trim().isEmpty) {
      fail('请输入车牌号');
      return;
    }
    try {
      await merchantApi.save('vehicles', {
        if (draft.id != null) 'id': draft.id,
        'member_id': f['member_id'],
        'plate': '${f['plate']}'.trim(),
        'energy': '${f['energy'] ?? 'fuel'}',
        'brand_model': '${f['brand_model'] ?? ''}',
        'color': '${f['color'] ?? ''}',
        'vin': '${f['vin'] ?? ''}'.trim(),
        'mileage': '${f['mileage'] ?? ''}'.replaceAll(',', '').trim(),
      });
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已保存', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 储值充值 ─────────
  /// 充值金额档位和对应的赠送金额（仅用于界面预览，实际赠送以云函数返回为准）。
  static const rechargePresets = [1000, 2000, 5000, 10000];
  static const rechargeGifts = [100, 300, 1000, 2500];

  /// 收款方式（只是记账，不接真实支付通道）。
  static const payMethods = ['微信', '支付宝', '现金', 'POS 刷卡'];

  /// 最近一次充值的结果（充值成功页展示）。
  static Map<String, dynamic>? lastRecharge;

  /// 档位按钮的选中状态，输入自定义金额时要把档位取消。
  static VoidCallback? clearPresetSelection;

  /// 充值表单：默认选中设计稿里的 ¥2,000 档、微信。
  static void beginRecharge() {
    CatalogDraft.begin('recharge', {
      'mode': 'preset',
      'preset': 1,
      'custom': '',
      'method': payMethods.first,
      'sale_package_id': '',
      'sale_method': saleMethods.first,
    });
    unawaited(loadSalePackages());
  }

  static Map<String, dynamic> get _form =>
      CatalogDraft.current?.kind == 'recharge'
      ? CatalogDraft.current!.fields
      : const {};

  static num get rechargeAmount {
    if (_form['mode'] == 'custom') {
      return num.tryParse('${_form['custom'] ?? ''}'.replaceAll(',', '')) ?? 0;
    }
    final i = int.tryParse('${_form['preset']}') ?? -1;
    return i >= 0 && i < rechargePresets.length ? rechargePresets[i] : 0;
  }

  static num get rechargeGift {
    final i = rechargePresets.indexOf(rechargeAmount.toInt());
    return _form['mode'] == 'custom' || i < 0 ? 0 : rechargeGifts[i];
  }

  /// 输入自定义金额：金额以输入为准，档位取消选中。
  static void customAmountTyped(String text) {
    CatalogDraft.set(
      'recharge',
      'mode',
      text.trim().isEmpty ? 'preset' : 'custom',
    );
    if (text.trim().isNotEmpty) clearPresetSelection?.call();
  }

  static Future<void> recharge(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final member = current;
    if (member == null) {
      // TODO: 从首页等入口充值需要先选会员，目前只能从会员详情进入。
      fail('请先从会员详情进入充值');
      return;
    }
    final amount = rechargeAmount;
    if (amount <= 0) {
      fail('请选择或输入充值金额');
      return;
    }
    try {
      final res = await merchantApi.recharge(
        memberId: '${member['id']}',
        amount: amount,
        method: '${_form['method'] ?? payMethods.first}',
      );
      lastRecharge = {
        ...res,
        'amount': amount,
        'method': '${_form['method'] ?? payMethods.first}',
        'at': DateTime.now(),
        'member_name': member['name'],
      };
      current = await merchantApi.member('${member['id']}');
      CatalogDraft.changed.value++;
      if (res['upgraded_to'] != null) {
        AppToast.showOn(
          messenger,
          '已自动升级为${res['upgraded_to']}',
          kind: ToastKind.success,
        );
      }
      if (context.mounted) openRoute(context, 'RechargeSuccess');
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 调整卡种与积分 ─────────
  static const adjustReasons = ['活动补发', '客诉补偿', '录入错误', '其他'];

  /// 本店启用的卡种，按等级从低到高（升级门槛由低到高）。调整页的 4 个卡种按钮按这个顺序对应。
  static List<Map<String, dynamic>> tiers = const [];

  /// 调整页：积分数量从 0 开始（不沿用设计稿示例的 500，避免只想改卡种时误加积分），原因要自己选。
  static Future<void> beginAdjust() async {
    CatalogDraft.begin('adjust', {
      'dir': 'add',
      'points': 0,
      'reason': '',
      'note': '',
      'tier_index': -1,
    });
    try {
      final rows = await merchantApi.list('cards');
      num rank(Map<String, dynamic> t) =>
          (num.tryParse('${t['upgrade_recharge'] ?? 0}') ?? 0) * 1000000 +
          (num.tryParse('${t['upgrade_cumulative'] ?? 0}') ?? 0);
      rows.sort((a, b) => rank(a).compareTo(rank(b)));
      tiers = rows;
      final cur = '${current?['card_type_id']}';
      CatalogDraft.set(
        'adjust',
        'tier_index',
        tiers.indexWhere((t) => '${t['id']}' == cur),
      );
    } catch (_) {
      // 读不到卡种时只能调整积分，卡种按钮点了会提示
    }
  }

  /// 调整后的积分（预览）：增加 / 扣减不会让积分低于 0。
  static int get adjustedPoints {
    final base = int.tryParse('${current?['points'] ?? 0}') ?? 0;
    final f = CatalogDraft.current?.kind == 'adjust'
        ? CatalogDraft.current!.fields
        : const {};
    final n = int.tryParse('${f['points'] ?? 0}') ?? 0;
    final v = f['dir'] == 'sub' ? base - n : base + n;
    return v < 0 ? 0 : v;
  }

  static Future<void> adjust(BuildContext context) async {
    final draft = CatalogDraft.current;
    final member = current;
    if (draft == null || draft.kind != 'adjust' || member == null) return;
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final f = draft.fields;
    final idx = int.tryParse('${f['tier_index']}') ?? -1;
    final curId = '${member['card_type_id']}';
    final tierId =
        idx >= 0 && idx < tiers.length && '${tiers[idx]['id']}' != curId
        ? '${tiers[idx]['id']}'
        : null;
    final n = int.tryParse('${f['points'] ?? 0}') ?? 0;
    final points = f['dir'] == 'sub' ? -n : n;
    final reason = '${f['reason'] ?? ''}';
    if (tierId == null && points == 0) {
      fail('请选择要调整的卡种或积分数量');
      return;
    }
    if (reason.isEmpty) {
      fail('请选择调整原因');
      return;
    }
    try {
      await merchantApi.adjustMember(
        memberId: '${member['id']}',
        tierId: tierId,
        points: points,
        reason: reason,
        note: '${f['note'] ?? ''}'.trim(),
      );
      current = await merchantApi.member('${member['id']}');
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已调整', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 购买次卡 ─────────
  /// 收款方式：4 种记账方式 + 储值余额。
  static const saleMethods = ['微信', '支付宝', '现金', 'POS 刷卡', '会员余额'];

  /// 在售（未下架）的次卡套餐，购买页和“选择次卡套餐”弹层共用。
  static List<Map<String, dynamic>> salePackages = const [];

  /// 最近一次购买的结果（购买成功页展示）。
  static Map<String, dynamic>? lastSale;

  // 购买次卡和储值充值是同一个页面的两个页签，共用一个表单草稿（kind = recharge），
  // 购买次卡的字段带 sale_ 前缀。
  static Map<String, dynamic> get _sale =>
      CatalogDraft.current?.kind == 'recharge'
      ? CatalogDraft.current!.fields
      : const {};

  static Map<String, dynamic>? get salePackage {
    final id = '${_sale['sale_package_id'] ?? ''}';
    for (final p in salePackages) {
      if ('${p['id']}' == id) return p;
    }
    return null;
  }

  static String get saleMethod =>
      '${_sale['sale_method'] ?? saleMethods.first}';

  /// 购买次卡表单（在 [beginRecharge] 开出的草稿里）：读取在售套餐，默认选第一个、微信。
  static Future<void> loadSalePackages() async {
    try {
      final rows = await merchantApi.list('packages');
      salePackages = [
        for (final r in rows)
          if (r['active'] != false) r,
      ];
      CatalogDraft.set(
        'recharge',
        'sale_package_id',
        salePackages.isEmpty ? '' : '${salePackages.first['id']}',
      );
    } catch (_) {
      salePackages = const [];
      CatalogDraft.set('recharge', 'sale_package_id', '');
    }
  }

  static Future<void> sell(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    void fail(String text) =>
        AppToast.showOn(messenger, text, kind: ToastKind.error);
    final member = current;
    if (member == null) {
      fail('请先从会员详情进入');
      return;
    }
    final pkg = salePackage;
    if (pkg == null) {
      fail('请选择次卡套餐');
      return;
    }
    try {
      final res = await merchantApi.sellPackage(
        memberId: '${member['id']}',
        packageId: '${pkg['id']}',
        method: saleMethod,
      );
      lastSale = {
        ...res,
        'name': pkg['name'],
        'method': saleMethod,
        'at': DateTime.now(),
        'member_name': member['name'],
      };
      current = await merchantApi.member('${member['id']}');
      CatalogDraft.changed.value++;
      if (res['upgraded_to'] != null) {
        AppToast.showOn(
          messenger,
          '已自动升级为${res['upgraded_to']}',
          kind: ToastKind.success,
        );
      }
      if (context.mounted) openRoute(context, 'PackageSold');
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 次卡详情 / 延期 / 退款 ─────────
  /// 正在查看的次卡（含包含服务和使用记录）。
  static Map<String, dynamic>? currentPackage;

  static const extendDays = [30, 60, 90];
  static const extendReasons = ['会员长期出差', '门店服务延误', '其他'];
  static const refundTo = ['原路退回', '储值余额'];
  static const refundReasons = ['会员不再需要', '搬家 / 换车', '服务问题'];

  /// 读取次卡详情并保存为当前次卡。
  static Future<void> openPackage(String id) async {
    currentPackage = await merchantApi.memberPackage(id);
  }

  static Future<void> reloadPackage() async {
    final id = currentPackage?['id'];
    if (id != null) currentPackage = await merchantApi.memberPackage('$id');
  }

  /// 延期表单：默认 30 天，原因要自己选。
  static void beginExtend() =>
      CatalogDraft.begin('pkg_extend', {'days_index': 0, 'reason': ''});

  static void beginRefund() =>
      CatalogDraft.begin('pkg_refund', {'to_index': 0, 'reason': ''});

  static Map<String, dynamic> _op(String kind) =>
      CatalogDraft.current?.kind == kind
      ? CatalogDraft.current!.fields
      : const {};

  static int get extendDaysValue {
    final i = int.tryParse('${_op('pkg_extend')['days_index']}') ?? 0;
    return i >= 0 && i < extendDays.length ? extendDays[i] : extendDays.first;
  }

  static Future<void> extendPackage(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    void fail(String t) => AppToast.showOn(messenger, t, kind: ToastKind.error);
    final id = currentPackage?['id'];
    final reason = '${_op('pkg_extend')['reason'] ?? ''}';
    if (id == null) return;
    if (reason.isEmpty) {
      fail('请选择延期原因');
      return;
    }
    try {
      await merchantApi.extendPackage(
        id: '$id',
        days: extendDaysValue,
        reason: reason,
      );
      await reloadPackage();
      CatalogDraft.changed.value++;
      AppToast.showOn(
        messenger,
        '已延期 $extendDaysValue 天',
        kind: ToastKind.success,
      );
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  static Future<void> refundPackage(BuildContext context) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    void fail(String t) => AppToast.showOn(messenger, t, kind: ToastKind.error);
    final id = currentPackage?['id'];
    final reason = '${_op('pkg_refund')['reason'] ?? ''}';
    if (id == null) return;
    if (reason.isEmpty) {
      fail('请选择退款原因');
      return;
    }
    final i = int.tryParse('${_op('pkg_refund')['to_index']}') ?? 0;
    try {
      final res = await merchantApi.refundPackage(
        id: '$id',
        to: refundTo[i.clamp(0, refundTo.length - 1)],
        reason: reason,
      );
      current = await merchantApi.member('${current?['id']}');
      currentPackage = null;
      CatalogDraft.changed.value++;
      AppToast.showOn(
        messenger,
        '已退款 ¥${formatMoney(num.tryParse('${res['refund']}') ?? 0)}',
        kind: ToastKind.success,
      );
      // 关掉退款弹层，再回到会员详情（次卡已退款，详情页不再有意义）
      nav.pop();
      nav.maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  // ───────── 选择会员（充值 / 开单等没带会员进入时） ─────────
  /// 选定会员后通知页面刷新（充值页据此在“未选会员”和有会员之间切换）。
  static final ValueNotifier<int> memberTick = ValueNotifier<int>(0);

  /// 选择会员弹层里的搜索词。
  static final ValueNotifier<String> pickerQuery = ValueNotifier<String>('');

  /// 选中会员：保存为当前会员并关闭弹层。
  static void pickMember(BuildContext context, Map<String, dynamic> row) {
    current = row;
    memberTick.value++;
    Navigator.of(context).maybePop();
  }

  // ───────── 回访 ─────────
  static const visitMethods = ['电话', '微信', '到店'];
  static const visitResults = ['已接通 · 有意向', '已接通 · 暂无需求', '未接通', '已预约到店'];

  /// 当前会员的历史回访（新的在前）。
  static List<Map<String, dynamic>> visitHistory = const [];

  /// 记录回访表单：方式默认电话，结果要自己选。
  static Future<void> beginVisit() async {
    CatalogDraft.begin('visit', {
      'method_index': 0,
      'result_index': -1,
      'content': '',
      'next': '',
    });
    final id = current?['id'];
    if (id == null) return;
    try {
      visitHistory = await merchantApi.followUps('$id');
    } catch (_) {
      visitHistory = const [];
    }
    CatalogDraft.set('visit', 'history_loaded', true); // 通知历史回访刷新
  }

  static Future<void> saveVisit(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    void fail(String t) => AppToast.showOn(messenger, t, kind: ToastKind.error);
    final id = current?['id'];
    final f = CatalogDraft.current?.kind == 'visit'
        ? CatalogDraft.current!.fields
        : const <String, dynamic>{};
    if (id == null) return;
    final ri = int.tryParse('${f['result_index']}') ?? -1;
    if (ri < 0 || ri >= visitResults.length) {
      fail('请选择回访结果');
      return;
    }
    final mi = (int.tryParse('${f['method_index']}') ?? 0).clamp(
      0,
      visitMethods.length - 1,
    );
    try {
      await merchantApi.saveFollowUp(
        memberId: '$id',
        method: visitMethods[mi],
        result: visitResults[ri],
        content: '${f['content'] ?? ''}'.trim(),
        nextAt: '${f['next'] ?? ''}'.isEmpty ? null : '${f['next']}',
      );
      CatalogDraft.changed.value++;
      AppToast.showOn(messenger, '已保存回访', kind: ToastKind.success);
      if (context.mounted) Navigator.of(context).maybePop();
    } catch (e) {
      fail(AppError.from(e).message);
    }
  }

  /// 回访提醒：次卡到期 / 生日 / 沉睡客户。养护到期依赖服务施工记录，暂未接通。
  static Map<String, dynamic>? reminders;
  static final ValueNotifier<int> reminderTab = ValueNotifier<int>(0);
  static final ValueNotifier<int> reminderTick = ValueNotifier<int>(0);
  static const reminderKinds = [null, '次卡到期', '养护到期', '生日', '沉睡客户'];

  static Future<void> loadReminders() async {
    try {
      reminders = await merchantApi.reminders();
    } catch (_) {
      reminders ??= null;
    }
    reminderTick.value++;
  }

  static Future<void> markFollowedUp(
    BuildContext context,
    String memberId,
  ) async {
    try {
      await merchantApi.markFollowedUp(memberId);
      await loadReminders();
    } catch (e) {
      if (context.mounted) AppToast.error(context, e);
    }
  }

  // ───────── 开单 ─────────
  /// 最近一次开单的结果（收款成功页展示）。
  static Map<String, dynamic>? lastOrder;

  // ───────── 筛选会员 ─────────
  /// 卡种页签以外的筛选（卡种多选、储值余额、最近到店）。次卡状态和车辆与项目依赖次卡 / 订单数据，暂未接通。
  static final filter = MemberFilterState();

  // ───────── 删除会员 ─────────
  static Future<void> deleteCurrent() async {
    final id = current?['id']?.toString();
    if (id == null) throw const AppError('会员不存在');
    await merchantApi.delete('members', id);
    current = null;
    CatalogDraft.changed.value++;
  }
}

/// 后端的会员记录 -> 页面里用的 [Member]。
/// 余额、到店时间、微信绑定依赖储值 / 订单 / 微信模块，目前没有数据，显示 “—”。
Member memberFromRow(Map<String, dynamic> row) {
  final vehicles = List<Map<String, dynamic>>.from(
    (row['vehicles'] as List?) ?? const [],
  );
  final card = Map<String, dynamic>.from((row['card'] as Map?) ?? const {});
  return Member(
    '${row['name'] ?? ''}',
    '${card['name'] ?? ''}',
    vehicles.isEmpty ? '未登记车辆' : _plateText('${vehicles.first['plate']}'),
    _lastVisitText(row['last_visit_at']),
    '¥${formatMoney(num.tryParse('${row['balance'] ?? 0}') ?? 0)}',
    '余额',
    const {},
    bound: false,
    phone: '${row['phone'] ?? ''}',
    id: row['id']?.toString(),
    data: row,
  );
}

/// 最近到店：今天到店 / N 天前 / 还没到过店。到店记录来自开单（订单模块接入后才会有）。
String _lastVisitText(Object? at) {
  final t = DateTime.tryParse('${at ?? ''}')?.toLocal();
  if (t == null) return '还没到过店';
  final days = DateTime.now().difference(t).inDays;
  if (days <= 0) return '今天到店';
  if (days < 14) return '$days 天前';
  return '${days ~/ 7} 周前';
}

/// `沪A8K29M` -> `沪A·8K29M`
String _plateText(String plate) =>
    plate.length < 3 ? plate : '${plate.substring(0, 2)}·${plate.substring(2)}';
String plateText(String plate) => _plateText(plate);

/// `1080` -> `1,080.00`
String money2(num v) {
  final s = v.toStringAsFixed(2);
  final parts = s.split('.');
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '$intPart.${parts[1]}';
}

/// 会员筛选面板的条件。[working] 是面板里正在选的，点“查看”后才应用到列表（[applied]）。
class MemberFilterState extends ChangeNotifier {
  MemberFilterState();

  /// 本店卡种按等级从低到高（读取失败时为空，卡种筛选不可用）。
  List<Map<String, dynamic>> tiers = const [];

  // 已应用到会员列表的条件
  Set<int> appliedTiers = {};
  int appliedBalance = 0; // 0 不限 / 1 ¥500 以下 / 2 ¥500–2,000 / 3 ¥2,000 以上
  int appliedVisit = -1; // -1 不限 / 0 7 天内 / 1 30 天内 / 2 超过 60 天 / 3 超过 90 天

  // 面板里正在选的条件
  Set<int> tierSel = {};
  int balanceSel = 0;
  int visitSel = -1;

  /// 面板里的条件当前能匹配多少位会员（“查看 N 位会员”）。
  final ValueNotifier<int?> matched = ValueNotifier<int?>(null);
  Timer? _debounce;

  bool get active =>
      appliedTiers.isNotEmpty || appliedBalance != 0 || appliedVisit != -1;

  /// 打开面板：从已应用的条件开始，并读取卡种。
  Future<void> open() async {
    tierSel = {...appliedTiers};
    balanceSel = appliedBalance;
    visitSel = appliedVisit;
    matched.value = null;
    try {
      final rows = await merchantApi.list('cards');
      num rank(Map<String, dynamic> t) =>
          (num.tryParse('${t['upgrade_recharge'] ?? 0}') ?? 0) * 1000000 +
          (num.tryParse('${t['upgrade_cumulative'] ?? 0}') ?? 0);
      rows.sort((a, b) => rank(a).compareTo(rank(b)));
      tiers = rows;
    } catch (_) {
      // 读不到卡种时卡种筛选不可用
    }
    notifyListeners();
    refreshCount();
  }

  void reset() {
    tierSel = {};
    balanceSel = 0;
    visitSel = -1;
    notifyListeners();
    refreshCount();
  }

  void apply() {
    appliedTiers = {...tierSel};
    appliedBalance = balanceSel;
    appliedVisit = visitSel;
    notifyListeners();
  }

  /// 取消：丢掉面板里的修改。
  void discard() {
    tierSel = {...appliedTiers};
    balanceSel = appliedBalance;
    visitSel = appliedVisit;
  }

  void changed() {
    notifyListeners();
    refreshCount();
  }

  /// 用给定的（面板里或已应用的）条件拼出列表请求的参数。
  Map<String, Object?> args({bool working = false}) {
    final t = working ? tierSel : appliedTiers;
    final b = working ? balanceSel : appliedBalance;
    final v = working ? visitSel : appliedVisit;
    return {
      'ids': [
        for (final i in t)
          if (i < tiers.length) '${tiers[i]['id']}',
      ],
      'min': const [null, null, 500, 2000][b],
      'max': const [null, 500, 2000, null][b],
      'within': v == 0 ? 7 : (v == 1 ? 30 : null),
      'over': v == 2 ? 60 : (v == 3 ? 90 : null),
    };
  }

  void refreshCount() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final a = args(working: true);
      try {
        final page = await merchantApi.members(
          cardTypeIds: (a['ids'] as List<String>),
          balanceMin: a['min'] as num?,
          balanceMax: a['max'] as num?,
          visitedWithinDays: a['within'] as int?,
          visitedOverDays: a['over'] as int?,
          limit: 1,
        );
        matched.value = page.matched;
      } catch (_) {
        matched.value = null;
      }
    });
  }
}
