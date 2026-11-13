import '../../backend/data_snapshot.dart';
import 'hold_draft.dart';
import 'hold_sheet_sheet.dart';
import 'order_checkout.dart';
import '../members/member_picker_sheet.dart' show showMemberPicker;
import '../../backend/appointment_flow.dart';

import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/hold_store.dart';
import '../../backend/member_flow.dart';
import '../../backend/service_store.dart';
import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';

import '../../kit/keyboard.dart';
import '../../kit/kit.dart' show dk;
import '../../kit/pickers.dart';
import '../../backend/money_format.dart';
import '../members/member_models.dart';
import '../../theme.dart';
import '../../routes.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

class OrderPage extends StatefulWidget {
  final Member? member;
  final Map<String, dynamic>? appointment, hold;
  final bool walkIn;
  final String plate;
  const OrderPage({
    super.key,
    this.member,
    this.appointment,
    this.hold,
    this.walkIn = false,
    this.plate = '',
  });
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  // ───────── 登录后：服务项目、会员次卡、折扣来自后端 ─────────
  bool get _live => merchantApi.hasSession;
  List<_Svc> _liveSvcs = const [];
  bool _loadingSvcs = false;
  bool _showSvcSkeleton = false;
  AppError? _svcError;

  /// 会员名下可用次卡：服务 ID -> (次卡 ID, 剩余次数)。
  Map<String, (String, int)> _cover = {};
  final _payment = OrderCheckout();
  bool _choosingPayment = false, _submitting = false;
  bool get _busy => _payment.busy || _submitting;
  String get _actionKey => 'order-checkout-${identityHashCode(this)}';
  int _coverVersion = 0;
  AppError? _coverError;
  bool _loadingCover = false;
  List<Map<String, dynamic>> _technicians = const [];
  bool _hasTechnicians = false;
  bool _loadingTechnicians = false;
  bool _showTechnicianSkeleton = false;
  AppError? _technicianError;

  List<_Svc> get _svcs => _liveSvcs;
  List<String> get _cats => [
    '常用',
    ...{for (final s in _liveSvcs) ...s.cats},
  ];

  /// 散客开单：不记会员，没有会员折扣和次卡抵扣（设计稿“开单收银 · 散客”）。
  bool _walkIn = false;
  final _walkPlateCtl = TextEditingController();

  /// 登录后还没选客户：既没选会员也没选散客开单（设计稿“开单收银 · 未选客户”）。
  bool get _noCustomer => _live && !_walkIn && customer.id == null;

  bool _covered(int i) => !_walkIn && _cover.containsKey(_svcs[i].id);

  /// 会员卡折扣（0.9 = 9 折）；没有折扣时 1。
  double get _discount => _walkIn
      ? 1
      : (num.tryParse(
                  '${(customer.data?['card'] as Map?)?['discount'] ?? 1}',
                ) ??
                1)
            .toDouble();

  String get _discountN {
    final d = _discount * 10;
    return '${d == d.roundToDouble() ? d.round() : d.toStringAsFixed(1)} 折';
  }

  String get _discountLabel => '${customer.level} $_discountN';

  @override
  void initState() {
    super.initState();
    if (_live) {
      picked.clear();
      final technicianId = widget.appointment?['technician_id'];
      if (technicianId != null) techs.add('$technicianId');
      AppointmentFlow.changed.addListener(_refreshTechnicians);
      unawaited(_loadTechnicians());
      if (widget.appointment != null) {
        _walkIn = widget.appointment!['member_id'] == null;
        _walkPlateCtl.text = '${widget.appointment!['vehicle_plate'] ?? ''}';
      }
      ServiceStore.changed.addListener(_onServiceStore);
      unawaited(_loadServices());
      unawaited(_loadCover());
      if (widget.appointment == null) {
        HoldStore.loadSoon();
        if (widget.walkIn) {
          _walkIn = true;
          customer = _noMember;
          _walkPlateCtl.text = widget.plate;
        }
        if (widget.hold != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _resumeHold(widget.hold!),
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(OrderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member?.id != oldWidget.member?.id ||
        widget.hold?['id'] != oldWidget.hold?['id'] ||
        widget.appointment?['id'] != oldWidget.appointment?['id'] ||
        widget.walkIn != oldWidget.walkIn ||
        widget.plate != oldWidget.plate) {
      _resumeVersion++;
      _coverVersion++;
      _quantities.clear();
      _preferredPackages.clear();
      _cover = {};
      _coverError = null;
      _loadingCover = false;
      picked.clear();
      techs.clear();
      pay = 0;
      _holdId = null;
      _holdRow = null;
      _bookingApplied = false;
      customer = widget.member ?? _noMember;
      _walkIn =
          widget.walkIn ||
          (widget.appointment != null &&
              widget.appointment!['member_id'] == null);
      _walkPlateCtl.text =
          widget.appointment?['vehicle_plate']?.toString() ?? widget.plate;
      if (widget.hold != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _resumeHold(widget.hold!);
        });
      } else {
        unawaited(_loadCover());
        final rows = ServiceStore.items;
        if (rows != null) _applyServices(rows);
      }
    }
  }

  @override
  void dispose() {
    AppointmentFlow.changed.removeListener(_refreshTechnicians);
    ServiceStore.changed.removeListener(_onServiceStore);
    _payment.dispose();
    _searchCtl.dispose();
    _walkPlateCtl.dispose();
    super.dispose();
  }

  /// 正在处理的挂单（取单后继续加项 / 结算）；新开一单时为空。
  String? _holdId;
  Map<String, dynamic>? _holdRow;
  int _resumeVersion = 0;
  final _quantities = <String, int>{};
  final _preferredPackages = <String, String>{};
  int _qty(int index) => _quantities[_svcs[index].id] ?? 1;

  /// 取单：会员、项目放回开单页，结算时由云函数按当前价格重新计算。
  Future<void> _resumeHold(Map<String, dynamic> row) async {
    row = dataSnapshot(row);
    final version = ++_resumeVersion;
    final memberId = '${(row['member'] as Map?)?['id'] ?? row['member_id']}';
    final walkIn = row['member_id'] == null && row['member'] == null;
    try {
      final m = walkIn ? null : await merchantApi.member(memberId);
      if (!mounted || version != _resumeVersion) return;
      if (_liveSvcs.isEmpty) await _loadServices();
      if (!mounted || version != _resumeVersion) return;
      final ids = {
        for (final it in (row['items'] as List? ?? const []))
          '${(it as Map)['service_id']}',
      };
      final next = <int>{
        for (var i = 0; i < _liveSvcs.length; i++)
          if (ids.contains(_liveSvcs[i].id)) i,
      };
      setState(() {
        _walkIn = walkIn;
        _quantities.clear();
        _preferredPackages.clear();
        for (final item in (row['items'] as List? ?? const []).cast<Map>()) {
          final id = '${item['service_id']}';
          _quantities[id] = (item['qty'] as num? ?? 1).toInt();
          if (item['member_package_id'] != null) {
            _preferredPackages[id] = '${item['member_package_id']}';
          }
        }
        techs.clear();
        customer = m == null ? _noMember : memberFromRow(m);
        _cover = {};
        pay = 0;
        if (walkIn) _walkPlateCtl.text = '${row['vehicle_plate'] ?? ''}';
        picked
          ..clear()
          ..addAll(next);
        _holdId = '${row['id']}';
        _holdRow = Map.unmodifiable(row);
      });
      if (!walkIn) unawaited(_loadCover());
      if (next.length < ids.length) {
        toast(context, '部分服务项目已下架，已跳过');
      }
    } catch (e) {
      if (mounted && version == _resumeVersion) {
        final error = AppError.from(e);
        AppToast.show(
          context,
          error.message,
          kind: ToastKind.error,
          actionLabel: error.retryable ? '重试' : null,
          onAction: error.retryable ? () => _resumeHold(row) : null,
        );
      }
    }
  }

  /// 挂单：把这一单交给挂单弹层（价格、折扣、次卡抵扣由云函数估算）。
  Future<void> _hold() async {
    // TODO: 预约关联挂单尚未实现；不得丢弃预约关联后冒充成功。
    if (widget.appointment != null) {
      AppToast.show(context, '预约订单请直接结算，暂不支持挂单');
      return;
    }
    if (picked.isEmpty) {
      toast(context, '请先选择服务项目');
      return;
    }
    // 散客挂单：不记会员，没有折扣和次卡；车牌用开单页上填的车牌号
    final id = customer.id;
    if (!_walkIn && id == null) {
      toast(context, '请先选择客户');
      return;
    }
    final saved = await showHoldEditor(
      context,
      HoldDraft(
        memberId: _walkIn ? null : id,
        memberName: _walkIn ? '散客' : customer.name,
        level: _walkIn ? '非会员' : customer.level,
        plateLabel: _walkIn
            ? (_walkPlateCtl.text.trim().isEmpty
                  ? '未登记车辆'
                  : _walkPlateCtl.text.trim())
            : customer.plate,
        plate: _walkIn
            ? _walkPlateCtl.text.trim()
            : customer.plate.contains('·')
            ? customer.plate.replaceAll('·', '')
            : '',
        lines: [
          for (final i in picked)
            {
              'service_id': _svcs[i].id,
              'qty': _qty(i),
              if (_covered(i)) 'member_package_id': _cover[_svcs[i].id]!.$1,
            },
        ],
        payableText: money(payable, digits: 2),
        holdId: _holdId,
        original: _holdRow,
      ),
    );
    if (saved == null || !mounted) return;
    setState(() {
      picked.clear();
      techs.clear();
      _holdId = null;
      _holdRow = null;
      _quantities.clear();
      _preferredPackages.clear();
      _walkPlateCtl.clear();
    });
    openRoute(context, 'HoldList');
  }

  /// 服务项目走全局缓存：有缓存时打开就有数据（不闪骨架屏），后台刷新完成后更新列表。
  List<_Svc> _svcsOf(List<Map<String, dynamic>> rows) => [
    for (final r in rows)
      if (r['active'] != false)
        _Svc(
          '${r['id']}',
          '${r['name']}',
          (num.tryParse('${r['price']}') ?? 0).toDouble(),
          {'${r['category'] ?? '其他'}'},
        ),
  ];

  /// 列表变了（后台刷新）：已选项目按服务 ID 保留，不会因为顺序变化选错。
  bool _bookingApplied = false;
  void _applyServices(List<Map<String, dynamic>> rows) {
    final keep = {
      for (final i in picked)
        if (i < _liveSvcs.length) _liveSvcs[i].id,
    };
    final next = _svcsOf(rows);
    if (!_bookingApplied && widget.appointment != null && rows.isNotEmpty) {
      keep.addAll((widget.appointment!['service_ids'] as List).cast<String>());
      _bookingApplied = true;
    }
    picked
      ..clear()
      ..addAll([
        for (var i = 0; i < next.length; i++)
          if (keep.contains(next[i].id)) i,
      ]);
    _liveSvcs = next;
  }

  void _onServiceStore() {
    final rows = ServiceStore.items;
    if (!mounted || rows == null) return;
    setState(() => _applyServices(rows));
  }

  Future<void> _loadServices() async {
    final cached = ServiceStore.items;
    if (cached != null && !_loadingSvcs) {
      // 有缓存：直接用，ServiceStore.load 在缓存过期时会后台刷新
      setState(() {
        _svcError = null;
        _applyServices(cached);
      });
      unawaited(ServiceStore.load().then((_) {}, onError: (_) {}));
      return;
    }
    setState(() {
      _loadingSvcs = true;
      _showSvcSkeleton = false;
      _svcError = null;
    });
    DateTime? shownAt;
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && _loadingSvcs && _liveSvcs.isEmpty) {
        setState(() => _showSvcSkeleton = true);
        shownAt = DateTime.now();
      }
    });
    List<Map<String, dynamic>>? rows;
    AppError? failed;
    try {
      rows = await ServiceStore.load();
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    if (shownAt != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(shownAt!);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted) return;
    setState(() {
      _loadingSvcs = false;
      _showSvcSkeleton = false;
      if (failed == null) {
        _applyServices(rows!);
      } else {
        _svcError = failed;
      }
    });
  }

  Future<void> _loadCover() async {
    final id = customer.id;
    final version = ++_coverVersion;
    if (id == null || _walkIn) {
      _cover = {};
      _coverError = null;
      _loadingCover = false;
      return;
    }
    setState(() {
      _loadingCover = true;
      _coverError = null;
    });
    try {
      final rows = await merchantApi.memberPackages(id);
      final map = <String, (String, int)>{};
      for (final p in rows) {
        if (p['refunded_at'] != null) continue;
        final exp = DateTime.tryParse('${p['expires_at'] ?? ''}');
        if (exp != null && exp.isBefore(DateTime.now())) continue;
        for (final it in (p['items'] as List? ?? const [])) {
          final left = ((it['total'] as num) - (it['used'] as num)).toInt();
          final sid = '${it['service_id']}';
          if (left >= (_quantities[sid] ?? 1) &&
              (!map.containsKey(sid) || _preferredPackages[sid] == p['id'])) {
            map[sid] = ('${p['id']}', left);
          }
        }
      }
      if (mounted &&
          version == _coverVersion &&
          customer.id == id &&
          !_walkIn) {
        setState(() => _cover = map);
      }
    } catch (e) {
      if (mounted && version == _coverVersion && customer.id == id) {
        setState(() => _coverError = AppError.from(e));
        AppToast.show(
          context,
          _coverError!.message,
          kind: ToastKind.error,
          actionLabel: '重试',
          onAction: _loadCover,
        );
      }
    } finally {
      if (mounted && version == _coverVersion) {
        setState(() => _loadingCover = false);
      }
    }
  }

  List<(String, String)> get _pays => _walkIn
      ? const [('微信 / 支付宝', '扫码收款'), ('现金', '可找零'), ('银行卡', 'POS 刷卡')]
      : [
          ('会员余额', '可用 $_balanceText'),
          ('微信 / 支付宝', '扫码收款'),
          ('现金', '可找零'),
          ('组合支付', '余额 + 其他'),
        ];
  int cat = 0;
  bool searching = false;
  String query = '';
  final _searchCtl = TextEditingController();
  String bay = '选填';
  String finish = '选填';
  List<String> _bays = [];
  late Member customer = widget.member ?? _noMember;
  int pay = 0;
  final Set<int> picked = {};
  final Set<String> techs = {}; // 按技师 ID 保存当前页面的选择。

  double get subtotal => picked.fold(0, (s, i) => s + _svcs[i].price * _qty(i));
  double get cardOff =>
      picked.where(_covered).fold(0, (s, i) => s + _svcs[i].price * _qty(i));
  // 会员卡折扣：次卡抵扣之外的项目（登录后与云函数一致，逐项四舍五入到分）
  double get vipOff => picked
      .where((i) => !_covered(i))
      .fold(
        0.0,
        (s, i) =>
            s +
            (_svcs[i].price * _qty(i) * (1 - _discount) * 100).round() / 100,
      );
  double get payable => subtotal - cardOff - vipOff;

  Future<void> checkout() async {
    if (_busy || _choosingPayment) return;
    if (picked.isEmpty) {
      toast(context, '请先选择服务项目');
      return;
    }
    if (_noCustomer) {
      toast(context, '请先选择客户');
      return;
    }
    if (!_walkIn && (_loadingCover || _coverError != null)) {
      if (_coverError != null) {
        AppToast.show(
          context,
          _coverError!.message,
          kind: ToastKind.error,
          actionLabel: '重试',
          onAction: _loadCover,
        );
      } else {
        AppToast.show(context, '正在读取会员次卡，请稍候');
      }
      return;
    }
    final member = _walkIn ? null : customer.data;
    final walkIn = _walkIn, selectedPay = pay;
    final due = payable, holdId = _holdId;
    final plate = walkIn
        ? _walkPlateCtl.text.trim()
        : customer.plate.replaceAll('·', '');
    final lines = [
      for (final i in picked)
        {
          'service_id': _svcs[i].id,
          'qty': _qty(i),
          if (!walkIn && _covered(i))
            'member_package_id': _cover[_svcs[i].id]!.$1,
        },
    ];
    setState(() => _choosingPayment = true);
    try {
      await runBusy(_actionKey, () async {
        try {
          String method;
          num? balancePart;
          String? other;
          if (walkIn) {
            if (selectedPay == 0) {
              final value = await pickFromList(context, '选择收款方式', [
                '微信',
                '支付宝',
              ], '微信');
              if (value == null || !mounted) return;
              method = value;
            } else {
              method = selectedPay == 1 ? '现金' : 'POS 刷卡';
            }
          } else if (due <= 0) {
            method = '现金';
          } else if (selectedPay == 0) {
            method = '会员余额';
          } else if (selectedPay == 1) {
            final value = await pickFromList(context, '选择收款方式', [
              '微信',
              '支付宝',
            ], '微信');
            if (value == null || !mounted) return;
            method = value;
          } else if (selectedPay == 2) {
            method = '现金';
          } else {
            method = '组合支付';
            final balance = num.tryParse('${member?['balance'] ?? 0}') ?? 0;
            final max = balance < due ? balance : due - 0.01;
            final input = await pickAmount(
              context,
              '使用余额（最多 ¥${money(max)}）',
              '',
            );
            if (!mounted || input == null) return;
            final value = num.tryParse(input.replaceAll(RegExp(r'[¥,\s]'), ''));
            if (value == null || value <= 0 || value > max) {
              toast(context, '请填写使用的余额金额');
              return;
            }
            balancePart = value;
            other = await pickFromList(context, '其余部分的收款方式', [
              '微信',
              '支付宝',
              '现金',
              'POS 刷卡',
            ], '微信');
            if (other == null || !mounted) return;
          }
          setState(() => _submitting = true);
          final receipt = await _payment.pay(
            member: member,
            lines: lines,
            method: method,
            balancePart: balancePart,
            other: other,
            plate: plate,
            holdId: holdId,
            appointmentId: widget.appointment?['id']?.toString(),
          );
          if (receipt == null || !mounted) return;
          if (receipt.data['upgraded_to'] != null) {
            toast(context, '已自动升级为${receipt.data['upgraded_to']}');
          }
          setState(() {
            picked.clear();
            _holdId = null;
            _holdRow = null;
            _quantities.clear();
            _preferredPackages.clear();
            if (walkIn) _walkPlateCtl.clear();
          });
          openRoute(context, 'PaySuccess', arguments: receipt);
        } catch (e) {
          if (mounted) AppToast.error(context, e);
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _choosingPayment = false;
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!merchantApi.hasSession) {
      return Scaffold(
        body: ErrorView(
          error: const AppError('请先登录', type: AppErrorType.auth),
          onNext: () => openRoute(context, 'Login'),
        ),
      );
    }
    return AsyncActionScope(
      actionKey: _actionKey,
      child: ListenableBuilder(
        listenable: _payment,
        builder: (_, _) => _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  RoundBtn(
                    'chevronLeft',
                    label: '返回',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      '开单收银',
                      textAlign: TextAlign.center,
                      style: ts(17, w: FontWeight.w600, h: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => openRoute(context, 'HoldList'),
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: C.card,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: softShadow,
                      ),
                      child: Row(
                        children: [
                          Text('挂单', style: ts(14, w: FontWeight.w500, h: 20)),
                          const SizedBox(width: 6),
                          ListenableBuilder(
                            listenable: HoldStore.tick,
                            builder: (_, _) {
                              // 登录后显示真实的挂单数量（没有挂单时不显示红点）
                              final n = HoldStore.count;
                              if (n == 0) return const SizedBox.shrink();
                              return Container(
                                constraints: const BoxConstraints(minWidth: 18),
                                height: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: C.red,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  '$n',
                                  style: ts(
                                    11,
                                    w: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _customer(context),
                  const SizedBox(height: 16),
                  // 未选客户：服务项目置灰不可点，施工安排和结算不显示（设计稿“开单收银 · 未选客户”）
                  if (_noCustomer)
                    Opacity(
                      opacity: .45,
                      child: IgnorePointer(child: _servicesCard()),
                    )
                  else ...[
                    _servicesCard(),
                    const SizedBox(height: 16),
                    _jobCard(),
                    const SizedBox(height: 16),
                    _payCard(),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                bottom > 0 ? bottom : 16,
              ),
              decoration: BoxDecoration(
                color: C.card,
                boxShadow: [
                  BoxShadow(color: C.line, offset: const Offset(0, -1)),
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _noCustomer || _walkIn
                              ? '应收'
                              : '应收 · 已优惠 ¥${money(cardOff + vipOff)}',
                          style: ts(12, color: C.muted, h: 16),
                        ),
                        Text(
                          '¥${money(payable, digits: 2)}',
                          style: ts(
                            24,
                            w: FontWeight.w600,
                            h: 30,
                            spacing: -0.4,
                            tabular: true,
                            color: _noCustomer ? C.faint : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_noCustomer) ...[
                    const _DisabledButton('挂单', horizontal: 16, size: 15),
                    const SizedBox(width: 12),
                    const _DisabledButton('请先选择客户', horizontal: 20, size: 16),
                  ] else ...[
                    PrimaryButton(
                      '挂单',
                      bg: C.chip,
                      fg: C.ink,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      onTap: _hold,
                    ),
                    const SizedBox(width: 12),
                    PrimaryButton(
                      '确认收款',
                      onTap: checkout,
                      loading: _busy,
                      loadingText: '提交中…',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _balanceText =>
      customer.amountNote == '余额' ? customer.amount : '¥0';

  static const _noMember = Member('请选择会员', '', '', '', '—', '', {});
  bool _awaitPicker = false;

  Future<void> _pickCustomer() async {
    if (_awaitPicker) return;
    if (!merchantApi.hasSession) {
      openRoute(context, 'Login');
      return;
    }
    _awaitPicker = true;
    try {
      final row = await showMemberPicker(context);
      if (!mounted || row == null) return;
      setState(() {
        _resumeVersion++;
        _coverVersion++;
        _quantities.clear();
        _preferredPackages.clear();
        _walkIn = false;
        customer = memberFromRow(row);
        picked.clear();
        _cover = {};
        pay = 0;
        _holdId = null;
      });
      await _loadCover();
    } finally {
      _awaitPicker = false;
    }
  }

  /// 散客开单：不记会员，没有折扣和次卡抵扣。
  void _startWalkIn() => setState(() {
    _resumeVersion++;
    _coverVersion++;
    _loadingCover = false;
    _coverError = null;
    _quantities.clear();
    _preferredPackages.clear();
    _walkIn = true;
    customer = _noMember;
    picked.clear();
    _cover = {};
    pay = 0;
    _holdId = null;
  });

  /// 散客页点“更换”：回到“选择客户”。
  void _clearCustomer() => setState(() {
    _resumeVersion++;
    _coverVersion++;
    _loadingCover = false;
    _coverError = null;
    _quantities.clear();
    _preferredPackages.clear();
    _walkIn = false;
    customer = _noMember;
    picked.clear();
    _cover = {};
    pay = 0;
    _holdId = null;
  });

  Widget _customer(BuildContext context) {
    if (_noCustomer) return _chooseCustomer();
    if (_walkIn) return _walkInCard();
    return _memberCard(context);
  }

  /// 未选客户：选择会员 / 散客开单。
  Widget _chooseCustomer() => AppCard(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择客户', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _pickCustomer,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: C.primarySoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon('search', size: 18, color: C.primaryInk),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '选择会员',
                        style: ts(
                          14,
                          w: FontWeight.w600,
                          color: C.primaryInk,
                          h: 20,
                        ),
                      ),
                      Text(
                        '车牌 / 手机号',
                        style: ts(12, color: C.primaryInk, h: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _startWalkIn,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: C.inset,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AppIcon('person', size: 18, color: C.sub),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('散客开单', style: ts(14, w: FontWeight.w600, h: 20)),
                      Text(
                        '不记会员，无折扣和次卡抵扣',
                        style: ts(12, color: C.muted, h: 16),
                      ),
                    ],
                  ),
                ),
                AppIcon('chevronRight', size: 18, color: C.faint),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// 散客：不记会员，车牌号选填。
  Widget _walkInCard() => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: dk(
                  context,
                  const Color(0xFFE4E4E7),
                  const Color(0xFF34343A),
                ),
                shape: BoxShape.circle,
              ),
              child: Center(child: AppIcon('person', size: 22, color: C.sub)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('散客', style: ts(15, w: FontWeight.w500, h: 22)),
                      const SizedBox(width: 6),
                      Pill('不记会员', bg: C.inset, fg: C.sub, size: 11),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('无会员折扣与次卡抵扣', style: ts(12, color: C.muted, h: 16)),
                ],
              ),
            ),
            GestureDetector(
              onTap: _clearCustomer,
              child: Text(
                '更换',
                style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: C.inset,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Text('车牌号', style: ts(13, color: C.sub)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _walkPlateCtl,
                  onTapOutside: onTapOutsideDismiss,
                  textCapitalization: TextCapitalization.characters,
                  style: ts(14, h: 20),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: '选填，便于施工与取车',
                    hintStyle: ts(14, color: C.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _memberCard(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Avatar(customer.name.substring(0, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 4,
                children: [
                  Text(customer.name, style: ts(15, w: FontWeight.w500, h: 22)),
                  LevelBadge(customer.level),
                  PlateTag(customer.plate),
                ],
              ),
              const SizedBox(height: 4),
              Text('余额 $_balanceText', style: ts(12, color: C.muted, h: 16)),
            ],
          ),
        ),
        GestureDetector(
          onTap: _pickCustomer,
          child: Text(
            '更换',
            style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
          ),
        ),
      ],
    ),
  );

  Widget _servicesCard() => AppCard(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text('服务项目', style: ts(15, w: FontWeight.w600, h: 22)),
              ),
              Semantics(
                button: true,
                label: '搜索项目',
                child: GestureDetector(
                  onTap: () => setState(() {
                    searching = !searching;
                    if (!searching) {
                      query = '';
                      _searchCtl.clear();
                    }
                  }),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: searching ? C.primarySoft : C.inset,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppIcon(
                        searching ? 'close' : 'search',
                        size: 16,
                        color: searching ? C.primaryInk : C.sub,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (searching) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: C.inset,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  AppIcon('search', size: 16, color: C.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchCtl,
                      autofocus: true,
                      onTapOutside: onTapOutsideDismiss,
                      onChanged: (v) => setState(() => query = v.trim()),
                      style: ts(14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        isCollapsed: true,
                        hintText: '搜索服务项目',
                        hintStyle: ts(14, color: C.muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _cats.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => setState(() => cat = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cat == i ? C.btn : C.inset,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _cats[i],
                  style: ts(
                    13,
                    w: FontWeight.w500,
                    color: cat == i ? C.btnFg : C.sub,
                    h: 18,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_live && _loadingSvcs && _liveSvcs.isEmpty)
          _showSvcSkeleton
              ? const SkeletonServiceList()
              : const SizedBox(height: 120)
        else if (_live && _svcError != null && _liveSvcs.isEmpty)
          SizedBox(
            height: 220,
            child: ErrorView(
              error: _svcError!,
              retrying: _loadingSvcs,
              onRetry: _loadServices,
            ),
          )
        else if (_live && _liveSvcs.isEmpty)
          const SizedBox(
            height: 200,
            child: EmptyView(title: '还没有服务项目', message: '请先在“服务项目”里新增'),
          ),
        for (var i = 0; i < _svcs.length; i++)
          if (query.isNotEmpty
              ? _svcs[i].name.contains(query)
              : (cat == 0 ||
                    _svcs[i].cats.contains(
                      _cats[cat < _cats.length ? cat : 0],
                    )))
            _serviceRow(i),
        if (query.isNotEmpty && !_svcs.any((e) => e.name.contains(query)))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('没有找到「$query」', style: ts(13, color: C.muted)),
            ),
          ),
      ],
    ),
  );

  Widget _serviceRow(int i) {
    final s = _svcs[i];
    final on = picked.contains(i);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => on ? picked.remove(i) : picked.add(i)),
      child: Container(
        color: on ? C.primarySoft : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _qty(i) == 1 ? s.name : '${s.name} × ${_qty(i)}',
                    style: ts(14, w: FontWeight.w500, h: 20),
                  ),
                  const SizedBox(height: 3),
                  if (on && _covered(i))
                    Row(
                      children: [
                        Text(
                          '¥${s.price * _qty(i)}',
                          style: ts(
                            13,
                            color: C.muted,
                            h: 18,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          '次卡抵扣 ${_qty(i)} 次',
                          bg: C.greenSoft,
                          fg: C.greenInk,
                          size: 11,
                        ),
                      ],
                    )
                  else if (on && !_walkIn)
                    Row(
                      children: [
                        Text(
                          '¥${money(s.price * _qty(i))}',
                          style: ts(13, w: FontWeight.w600, h: 18),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          _discountLabel,
                          bg: C.amberSoft,
                          fg: C.amberInk,
                          size: 11,
                        ),
                      ],
                    )
                  else
                    Text(
                      '¥${money(s.price * _qty(i))}',
                      style: ts(13, w: FontWeight.w600, h: 18),
                    ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: on ? C.primary : C.chip,
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                on ? 'check' : 'add',
                size: 16,
                color: on ? Colors.white : C.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshTechnicians() => unawaited(_loadTechnicians());

  Future<void> _loadTechnicians() async {
    if (_loadingTechnicians) return;
    setState(() {
      _loadingTechnicians = true;
      _showTechnicianSkeleton = false;
    });
    DateTime? shownAt;
    final timer = Timer(kIndicatorDelay, () {
      if (mounted && !_hasTechnicians) {
        setState(() => _showTechnicianSkeleton = true);
        shownAt = DateTime.now();
      }
    });
    List<Map<String, dynamic>>? rows;
    AppError? failed;
    try {
      final options = await merchantApi.appointment('options');
      final resources = List<Map<String, dynamic>>.from(
        options['resources'] as List,
      );
      if (mounted) {
        _bays = [
          for (final row in resources)
            if (row['kind'] == 'bay' && row['active'] == true) '${row['name']}',
        ];
      }
      rows = resources
          .where((r) => r['kind'] == 'technician' && r['active'] == true)
          .toList();
    } catch (e) {
      failed = AppError.from(e);
    }
    timer.cancel();
    if (shownAt != null) {
      final left = kIndicatorMinShow - DateTime.now().difference(shownAt!);
      if (left > Duration.zero) await Future<void>.delayed(left);
    }
    if (!mounted) return;
    setState(() {
      _loadingTechnicians = false;
      _showTechnicianSkeleton = false;
      if (failed == null) {
        _technicians = rows!;
        _hasTechnicians = true;
        _technicianError = null;
        final ids = rows.map((r) => '${r['id']}').toSet();
        techs.removeWhere((id) => !ids.contains(id));
      } else if (!_hasTechnicians) {
        _technicianError = failed;
      }
    });
    if (failed != null && _hasTechnicians) {
      AppToast.show(
        context,
        failed.message,
        kind: ToastKind.error,
        actionLabel: failed.retryable ? '重试' : null,
        onAction: failed.retryable ? _loadTechnicians : null,
      );
    }
  }

  Widget _technicianBody() {
    final error = _live
        ? _technicianError
        : const AppError('请先登录', type: AppErrorType.auth);
    if (error != null) {
      return ErrorView(
        inline: true,
        error: error,
        retrying: _loadingTechnicians,
        onRetry: _loadTechnicians,
        onNext: () => openRoute(context, 'Login'),
      );
    }
    if (!_hasTechnicians) {
      return _showTechnicianSkeleton
          ? const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppSkeleton(width: 180, height: 36, radius: 18),
                AppSkeleton(width: 130, height: 36, radius: 18),
              ],
            )
          : const SizedBox(height: 36);
    }
    if (_technicians.isEmpty) {
      return Text(
        '还没有可用技师，请在“员工与权限”中添加或启用',
        style: ts(13, color: C.muted, h: 20),
      );
    }
    return _technicianChips();
  }

  Widget _jobCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('施工安排', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          _technicianBody(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _kv('工位', bay, _pickBay)),
              const SizedBox(width: 8),
              Expanded(child: _kv('预计完工', finish, _pickFinish)),
            ],
          ),
        ],
      ),
    );
  }

  String _technicianLabel(Map<String, dynamic> row) {
    final category = '${row['category'] ?? ''}'.trim();
    return category.isEmpty ? '${row['name']}' : '${row['name']} · $category';
  }

  // TODO: 多技师分配尚无订单/挂单保存接口；这里保持现有页面选择交互，
  // 后续需后端校验 technician_ids 并持久化，不将此选择标记为已保存。
  Widget _technicianChips() => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final t in _technicians)
        GestureDetector(
          onTap: () => setState(
            () => techs.contains('${t['id']}')
                ? techs.remove('${t['id']}')
                : techs.add('${t['id']}'),
          ),
          child: Container(
            height: 36,
            padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
            decoration: BoxDecoration(
              color: techs.contains('${t['id']}') ? C.primarySoft : C.inset,
              borderRadius: BorderRadius.circular(18),
              border: techs.contains('${t['id']}')
                  ? Border.all(color: C.primary, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Avatar(
                  '${t['name']}'.characters.first,
                  size: 28,
                  bg: C.card,
                  fg: C.ink,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    _technicianLabel(t),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(
                      13,
                      w: FontWeight.w500,
                      color: techs.contains('${t['id']}')
                          ? C.primaryInk
                          : C.sub,
                      h: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );

  Future<void> _pickBay() async {
    // TODO: 工位/预计完工选择尚无订单保存字段，不将页面选择宣称为已保存。
    if (_bays.isEmpty) {
      AppToast.show(context, '请先配置可用工位');
      return;
    }
    final r = await pickFromList(context, '选择工位', _bays, bay);
    if (r != null && mounted) setState(() => bay = r);
  }

  Future<void> _pickFinish() async {
    final r = await pickTime(context, '选择预计完工时间', finish);
    if (r != null && mounted) setState(() => finish = '今天 $r');
  }

  Widget _kv(String k, String v, VoidCallback onTap) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: C.inset,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k, style: ts(12, color: C.muted, h: 16)),
                Text(v, style: ts(14, w: FontWeight.w500, h: 20)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _payCard() => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('结算', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 12),
        _line('项目合计', '¥${money(subtotal, digits: 2)}'),
        if (cardOff > 0)
          _line(
            _live
                ? '次卡抵扣 · ${picked.where(_covered).map((i) => _svcs[i].name).join('、')}'
                : '次卡抵扣 · 精致洗车 1 次',
            '-¥${money(cardOff, digits: 2)}',
            green: true,
          ),
        if (vipOff > 0)
          _line(
            '${customer.level} $_discountN',
            '-¥${money(vipOff, digits: 2)}',
            green: true,
          ),
        const SizedBox(height: 4),
        const Divider1(),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.6,
          children: [
            for (var i = 0; i < _pays.length; i++)
              GestureDetector(
                onTap: () => setState(() => pay = i),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: pay == i ? C.btn : C.inset,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _pays[i].$1,
                        style: ts(
                          14,
                          w: FontWeight.w500,
                          color: pay == i ? C.btnFg : C.ink,
                          h: 20,
                        ),
                      ),
                      Text(
                        _pays[i].$2,
                        style: ts(
                          12,
                          color: pay == i ? C.faint : C.muted,
                          h: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _line(String k, String v, {bool green = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: ts(13, color: C.sub, h: 18)),
        ),
        Text(
          v,
          style: ts(
            13,
            color: green ? C.greenInk : C.ink,
            h: 18,
            tabular: true,
          ),
        ),
      ],
    ),
  );
}

/// 开单页里的一个服务项目（来自真实服务项目记录）。
class _Svc {
  final String? id;
  final String name;
  final double price;
  final Set<String> cats;
  const _Svc(this.id, this.name, this.price, this.cats);
}

/// 未选客户时底部栏上置灰的按钮（设计稿：#E4E4E7 底、#A1A1AA 字）。
class _DisabledButton extends StatelessWidget {
  final String text;
  final double horizontal, size;
  const _DisabledButton(
    this.text, {
    required this.horizontal,
    required this.size,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: false,
    label: text,
    child: Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dk(context, const Color(0xFFE4E4E7), const Color(0xFF27272A)),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        style: ts(
          size,
          w: size == 16 ? FontWeight.w600 : FontWeight.w500,
          color: const Color(0xFFA1A1AA),
          h: size == 16 ? 24 : 22,
        ),
      ),
    ),
  );
}
