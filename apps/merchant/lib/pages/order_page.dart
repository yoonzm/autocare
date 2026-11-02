import 'dart:async';

import 'package:flutter/material.dart';

import '../backend/member_flow.dart';
import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';

import '../kit/keyboard.dart';
import '../kit/pickers.dart';
import '../backend/catalog_draft.dart';
import '../mock/mock_data.dart';
import '../theme.dart';
import '../routes.dart';
import '../widgets/app_icon.dart';
import '../widgets/common.dart';

class OrderPage extends StatefulWidget {
  final Member? member;
  const OrderPage({super.key, this.member});
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _mockCats = ['常用', '洗车', '镀晶镀膜', '贴膜', '内饰'];

  // ───────── 登录后：服务项目、会员次卡、折扣来自后端 ─────────
  bool get _live => merchantApi.hasSession;
  List<_Svc> _liveSvcs = const [];
  bool _loadingSvcs = false;
  AppError? _svcError;

  /// 会员名下可用次卡：服务 ID -> (次卡 ID, 剩余次数)。
  Map<String, (String, int)> _cover = {};
  bool _busy = false;

  List<_Svc> get _svcs => _live
      ? _liveSvcs
      : [
          for (final s in orderServices)
            _Svc(null, s.name, s.price.toDouble(), s.cats, s.cardCovered),
        ];

  List<String> get _cats => _live
      ? [
          '常用',
          ...{for (final s in _liveSvcs) ...s.cats},
        ]
      : _mockCats;

  bool _covered(int i) =>
      _live ? _cover.containsKey(_svcs[i].id) : _svcs[i].mockCovered;

  /// 会员卡折扣（0.9 = 9 折）；没有折扣时 1。
  double get _discount => _live
      ? (num.tryParse(
                  '${(customer.data?['card'] as Map?)?['discount'] ?? 1}',
                ) ??
                1)
            .toDouble()
      : 0.9;

  String get _discountN {
    final d = _discount * 10;
    return '${d == d.roundToDouble() ? d.round() : d.toStringAsFixed(1)} 折';
  }

  String get _discountLabel => '${_live ? customer.level : '黑金'} $_discountN';

  @override
  void initState() {
    super.initState();
    if (_live) {
      picked.clear();
      if (widget.member != null) MemberFlow.current ??= widget.member!.data;
      unawaited(_loadServices());
      unawaited(_loadCover());
    }
  }

  Future<void> _loadServices() async {
    setState(() {
      _loadingSvcs = true;
      _svcError = null;
    });
    try {
      final rows = await merchantApi.list('services');
      if (!mounted) return;
      setState(() {
        _liveSvcs = [
          for (final r in rows)
            if (r['active'] != false)
              _Svc(
                '${r['id']}',
                '${r['name']}',
                (num.tryParse('${r['price']}') ?? 0).toDouble(),
                {'${r['category'] ?? '其他'}'},
                false,
              ),
        ];
        _loadingSvcs = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingSvcs = false;
        _svcError = AppError.from(e);
      });
    }
  }

  Future<void> _loadCover() async {
    final id = customer.id;
    if (id == null) return;
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
          if (left > 0 && !map.containsKey(sid)) {
            map[sid] = ('${p['id']}', left);
          }
        }
      }
      if (mounted) setState(() => _cover = map);
    } catch (_) {
      // 次卡读取失败时按普通项目收费，服务端会再次核对
    }
  }

  List<(String, String)> get _pays => [
    ('会员余额', '可用 $_balanceText'),
    ('微信 / 支付宝', '扫码收款'),
    ('现金', '可找零'),
    ('组合支付', '余额 + 其他'),
  ];
  int cat = 0;
  bool searching = false;
  String query = '';
  final _searchCtl = TextEditingController();
  String bay = '2 号工位';
  String finish = '今天 15:30';
  static const _bays = ['1 号工位', '2 号工位', '3 号工位', '4 号工位', '5 号工位', '贴膜间'];
  late Member customer =
      widget.member ??
      (merchantApi.hasSession
          ? const Member('请选择会员', '', '', '', '—', '', {})
          : members.first);
  int pay = 0;
  final Set<int> picked = {0, 1};
  final Set<String> techs = {'李国强 · 镀晶', '王磊 · 洗车'};

  double get subtotal => picked.fold(0, (s, i) => s + _svcs[i].price);
  double get cardOff =>
      picked.where(_covered).fold(0, (s, i) => s + _svcs[i].price);
  // 会员卡折扣：次卡抵扣之外的项目（登录后与云函数一致，逐项四舍五入到分）
  double get vipOff => _live
      ? picked
            .where((i) => !_covered(i))
            .fold(
              0.0,
              (s, i) =>
                  s + (_svcs[i].price * (1 - _discount) * 100).round() / 100,
            )
      : (subtotal - cardOff) * 0.1;
  double get payable => subtotal - cardOff - vipOff;

  void checkout() {
    if (picked.isEmpty) {
      toast(context, '请先选择服务项目');
      return;
    }
    if (_live) {
      unawaited(_checkoutLive());
      return;
    }
    openRoute(context, customer.bound ? 'PaySuccess' : 'PayUnbound');
  }

  /// 真实收款：价格、折扣、次卡抵扣、扣款都由云函数算，这里只传选择；收款方式只是记账。
  Future<void> _checkoutLive() async {
    if (_busy) return;
    final id = customer.id;
    if (id == null) {
      toast(context, '请先选择会员');
      return;
    }
    String method;
    num? balancePart;
    String? other;
    if (payable <= 0) {
      method = '现金'; // 全部由次卡抵扣，云函数记为“次卡抵扣”
    } else if (pay == 0) {
      method = '会员余额';
    } else if (pay == 1) {
      final r = await pickFromList(context, '选择收款方式', ['微信', '支付宝'], '微信');
      if (r == null || !mounted) return;
      method = r;
    } else if (pay == 2) {
      method = '现金';
    } else {
      method = '组合支付';
      final bal = num.tryParse('${customer.data?['balance'] ?? 0}') ?? 0;
      final max = bal < payable ? bal : payable - 0.01;
      final part = await pickAmount(context, '使用余额（最多 ¥${money(max)}）', '');
      if (!mounted) return;
      final n = num.tryParse((part ?? '').replaceAll(RegExp(r'[¥,\s]'), ''));
      if (n == null || n <= 0 || n > max) {
        if (mounted) toast(context, '请填写使用的余额金额');
        return;
      }
      balancePart = n;
      final r = await pickFromList(context, '其余部分的收款方式', [
        '微信',
        '支付宝',
        '现金',
        'POS 刷卡',
      ], '微信');
      if (r == null || !mounted) return;
      other = r;
    }
    setState(() => _busy = true);
    final started = DateTime.now();
    try {
      final res = await merchantApi.checkout(
        memberId: id,
        lines: [
          for (final i in picked)
            {
              'service_id': _svcs[i].id,
              'qty': 1,
              if (_covered(i)) 'member_package_id': _cover[_svcs[i].id]!.$1,
            },
        ],
        method: method,
        balancePart: balancePart,
        other: other,
        plate: customer.plate.contains('·')
            ? customer.plate.replaceAll('·', '')
            : '',
      );
      // 加载指示至少停留 500ms
      final left = kIndicatorMinShow - DateTime.now().difference(started);
      if (left > Duration.zero) await Future<void>.delayed(left);
      MemberFlow.lastOrder = {
        ...res,
        'member_name': customer.name,
        'plate': customer.plate,
        'at': DateTime.now(),
      };
      MemberFlow.current = await merchantApi.member(id);
      CatalogDraft.changed.value++;
      if (res['upgraded_to'] != null && mounted) {
        toast(context, '已自动升级为${res['upgraded_to']}');
      }
      if (mounted) {
        setState(() => picked.clear());
        openRoute(context, 'PaySuccess');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: C.red,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Text(
                              '4',
                              style: ts(
                                11,
                                w: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
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
                  _servicesCard(),
                  const SizedBox(height: 16),
                  _jobCard(),
                  const SizedBox(height: 16),
                  _payCard(),
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
                          '应收 · 已优惠 ¥${money(cardOff + vipOff)}',
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  PrimaryButton(
                    '挂单',
                    bg: C.chip,
                    fg: C.ink,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    onTap: () => openRoute(context, 'HoldSheet'),
                  ),
                  const SizedBox(width: 12),
                  PrimaryButton(
                    '确认收款',
                    onTap: checkout,
                    loading: _busy,
                    loadingText: '提交中…',
                  ),
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

  Future<void> _pickCustomer() async {
    final m = _live
        ? await pickLiveMember(context)
        : await pickMember(context, current: customer);
    if (m != null && mounted) {
      setState(() {
        customer = m;
        picked.clear();
        _cover = {};
      });
      if (_live) {
        MemberFlow.current = m.data;
        unawaited(_loadCover());
      }
    }
  }

  Widget _customer(BuildContext context) => AppCard(
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
              Text(
                '余额 $_balanceText · ${customer.bound ? '微信已绑定' : '微信未绑定'}',
                style: ts(12, color: C.muted, h: 16),
              ),
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
          const SkeletonList(count: 5)
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
                  Text(s.name, style: ts(14, w: FontWeight.w500, h: 20)),
                  const SizedBox(height: 3),
                  if (on && _covered(i))
                    Row(
                      children: [
                        Text(
                          '¥${s.price}',
                          style: ts(
                            13,
                            color: C.muted,
                            h: 18,
                            deco: TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Pill(
                          '次卡抵扣 1 次',
                          bg: C.greenSoft,
                          fg: C.greenInk,
                          size: 11,
                        ),
                      ],
                    )
                  else if (on)
                    Row(
                      children: [
                        Text(
                          '¥${money(s.price)}',
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
                      '¥${money(s.price)}',
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

  Widget _jobCard() {
    const all = ['李国强 · 镀晶', '王磊 · 洗车', '刘洋'];
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('施工安排', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in all)
                GestureDetector(
                  onTap: () => setState(
                    () => techs.contains(t) ? techs.remove(t) : techs.add(t),
                  ),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.fromLTRB(4, 0, 12, 0),
                    decoration: BoxDecoration(
                      color: techs.contains(t) ? C.primarySoft : C.inset,
                      borderRadius: BorderRadius.circular(18),
                      border: techs.contains(t)
                          ? Border.all(color: C.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Avatar(
                          t.substring(0, 1),
                          size: 28,
                          bg: C.card,
                          fg: C.ink,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t,
                          style: ts(
                            13,
                            w: FontWeight.w500,
                            color: techs.contains(t) ? C.primaryInk : C.sub,
                            h: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
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

  Future<void> _pickBay() async {
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
            _live ? '${customer.level} $_discountN' : '黑金会员 9 折',
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

/// 开单页里的一个服务项目（登录后来自后端，设计预览来自示例数据）。
class _Svc {
  final String? id;
  final String name;
  final double price;
  final Set<String> cats;
  final bool mockCovered;
  const _Svc(this.id, this.name, this.price, this.cats, this.mockCovered);
}
