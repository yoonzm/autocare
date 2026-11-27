import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show
        AppButton,
        AppButtonKind,
        AppSegmented,
        AppTextField,
        SegmentItem,
        showAppBottomSheet;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;

import '../../backend/merchant_api.dart';
import '../../backend/package_calc.dart' show formatMoney;
import '../../backend/service_store.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../kit/sheet_route.dart';
import '../../kit/text_input.dart';
import '../../routes.dart' show openRoute;
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart' show AppCard, Divider1;
import '../inventory/inventory_controller.dart'
    show editProduct, inputDialog, qty;
import '../inventory/inventory_pickers.dart' show showProductPicker;

/// 服务编辑入口：编辑数据通过参数传入，返回是否已保存或删除。
Future<bool?> openServiceEditor(
  BuildContext context, {
  Map<String, dynamic>? initial,
}) => Navigator.of(context).push<bool>(
  appSheetRoute<bool>(
    settings: const RouteSettings(name: 'ServiceEdit'),
    page: ServiceEditPage(initial: initial),
  ),
);

/// 编辑项目（设计稿 ServiceEdit）：基本信息、价格与会员价、技师提成、耗材绑定、销售设置。
/// 名称 / 价格 / 分类 / 工时 / 提成 / 耗材 / 上架状态都由 merchant-v1 的服务接口校验并保存。
class ServiceEditPage extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const ServiceEditPage({super.key, this.initial});

  @override
  State<ServiceEditPage> createState() => _ServiceEditPageState();
}

class _ServiceEditPageState extends State<ServiceEditPage> {
  late final _api = merchantApi;
  late final _name = TextEditingController(
    text: widget.initial?['name']?.toString() ?? '',
  );
  late final _price = TextEditingController(
    text: widget.initial?['price'] is num
        ? MoneyInputFormatter.format(widget.initial!['price'] as num)
        : '${widget.initial?['price'] ?? ''}',
  );

  /// 提成：按实收比例（percent）或固定金额（fixed）。新建默认按 8% 比例。
  late bool _fixedCommission = widget.initial?['commission_type'] == 'fixed';
  late final _commission = TextEditingController(
    text: widget.initial?['commission_value'] is num
        ? MoneyInputFormatter.format(widget.initial!['commission_value'] as num)
        : '8',
  );
  late String _category = widget.initial?['category']?.toString() ?? '镀晶镀膜';
  late int _durationMinutes =
      int.tryParse('${widget.initial?['duration_minutes'] ?? 30}') ?? 30;
  late bool _active = widget.initial?['active'] != false;

  /// 耗材绑定：库存商品 + 每次服务的用量（保存时整体替换）。
  late final List<Map<String, dynamic>> _consumables = [
    for (final c in (widget.initial?['consumables'] as List? ?? const []))
      Map<String, dynamic>.from(c as Map),
  ];
  bool _pickingProducts = false;

  /// 会员价：本店启用的卡种里有折扣的（折扣小于 1），按折扣从低到高。
  List<Map<String, dynamic>> _cards = const [];
  bool _cardsFailed = false;

  late final String _initialSnapshot = _snapshot();

  String _snapshot() => [
    _name.text,
    _price.text,
    _fixedCommission,
    _commission.text,
    _category,
    _durationMinutes,
    _active,
    for (final c in _consumables) '${c['product_id']}:${c['quantity']}',
  ].join('\u0000');

  @override
  void initState() {
    super.initState();
    _initialSnapshot;
    _price.addListener(_rebuild);
    _commission.addListener(_rebuild);
    _loadCards();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _price.dispose();
    _name.dispose();
    _commission.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    if (!_api.hasSession) return;
    try {
      final rows = await _api.list('cards');
      if (!mounted) return;
      setState(() {
        _cardsFailed = false;
        _cards =
            [
              for (final c in rows)
                if (((num.tryParse('${c['discount']}') ?? 1)) < 1) c,
            ]..sort(
              (a, b) =>
                  (num.parse('${a['discount']}'))
                      .compareTo(num.parse('${b['discount']}')),
            );
      });
    } catch (_) {
      if (mounted) setState(() => _cardsFailed = true);
    }
  }

  num? get _priceValue => num.tryParse(_price.text.replaceAll(',', '').trim());
  num? get _commissionValue =>
      num.tryParse(_commission.text.replaceAll(',', '').trim());

  String get _durationLabel => _durationText(_durationMinutes);
  static String _durationText(int m) => m < 60
      ? '$m 分钟'
      : m % 60 == 0
      ? '${m ~/ 60} 小时'
      : '${(m / 60).toStringAsFixed(1)} 小时';

  /// 可选分类：本店已有的服务分类 + 当前分类；没有任何分类时给几个常用的。
  List<String> get _categoryOptions {
    final set = <String>{
      for (final s in ServiceStore.items ?? const <Map<String, dynamic>>[])
        if ('${s['category'] ?? ''}'.isNotEmpty) '${s['category']}',
      _category,
    };
    if (set.length < 2) {
      set.addAll(['镀晶镀膜', '洗车', '贴膜', '内饰', '改色膜', '保养维修']);
    }
    return set.toList();
  }

  static const _newCategory = '＋ 新建分类';

  Future<void> _pickCategory() async {
    final value = await pickFromList(context, '选择分类', [
      ..._categoryOptions,
      _newCategory,
    ], _category);
    if (value == null || !mounted) return;
    if (value == _newCategory) {
      final created = (await _askNewCategory())?.trim();
      if (created == null || created.isEmpty || !mounted) return;
      setState(() => _category = created);
      return;
    }
    setState(() => _category = value);
  }

  /// 新建分类：底部弹层 + 组件库输入框（不用系统对话框）。名称最多 20 字，由输入框限制。
  Future<String?> _askNewCategory() async {
    final ctrl = TextEditingController();
    try {
      return await showAppBottomSheet<String>(
        context,
        title: '新建分类',
        builder: (sheetContext) => AppTextField(
          label: '分类名称',
          hint: '如：打蜡抛光',
          controller: ctrl,
          formatters: [LengthLimitingTextInputFormatter(20)],
          onSubmitted: (v) => Navigator.of(sheetContext).pop(v),
        ),
        actions: [
          AppButton(
            label: '取消',
            kind: AppButtonKind.secondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: '确定',
            onPressed: () => Navigator.of(context).pop(ctrl.text),
          ),
        ],
      );
    } finally {
      // 弹层关闭动画结束后再释放，避免动画期间读取已释放的控制器。
      Future<void>.delayed(const Duration(milliseconds: 400), ctrl.dispose);
    }
  }

  Future<void> _pickDuration() async {
    const minutes = [30, 60, 90, 120, 180, 240, 360, 480];
    final options = {...minutes, _durationMinutes}.toList()..sort();
    final value = await pickFromList(context, '标准工时', [
      for (final m in options) _durationText(m),
    ], _durationLabel);
    if (value == null || !mounted) return;
    setState(() {
      _durationMinutes = options.firstWhere((m) => _durationText(m) == value);
    });
  }

  Future<void> _refreshServices() async {
    try {
      await ServiceStore.refresh();
    } catch (_) {
      // 写入已经成功；保留缓存，列表后续可重试读取。
    }
  }

  // ───────── 耗材 ─────────
  Future<void> _addConsumables() async {
    if (_pickingProducts) return;
    setState(() => _pickingProducts = true);
    try {
      final data = await _api.invoke({'action': 'inventory_list'});
      if (!mounted) return;
      final products = [
        for (final p in (data['items'] as List? ?? const []))
          Map<String, dynamic>.from(p as Map),
      ];
      final picked = await showProductPicker(
        context,
        products: products,
        excluded: {for (final c in _consumables) c['product_id']},
        onCreate: () => editProduct(context, null),
      );
      if (picked == null || !mounted) return;
      setState(() {
        for (final p in picked) {
          if (_consumables.any((c) => c['product_id'] == p['id'])) continue;
          _consumables.add({
            'product_id': p['id'],
            'quantity': 1,
            'name': p['name'],
            'unit': p['unit'],
            'stock': p['stock'],
            'safe': p['safe'],
            'active': p['active'] != false,
            'allow_decimal': p['allow_decimal'] != false,
          });
        }
      });
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    } finally {
      if (mounted) setState(() => _pickingProducts = false);
    }
  }

  Future<void> _editConsumable(Map<String, dynamic> c) async {
    final action = await pickFromList(context, '${c['name']}', [
      '修改用量',
      '移除',
    ], '');
    if (action == null || !mounted) return;
    if (action == '移除') {
      setState(() => _consumables.remove(c));
      return;
    }
    final v = await inputDialog(
      context,
      '每次用量（${c['unit']}）',
      '请输入用量',
      qty(c['quantity'] as num),
      numeric: true,
    );
    if (v == null || !mounted) return;
    final q = num.tryParse(v.trim());
    if (q == null || q <= 0 || q > 999999 || (q * 1000).round() != q * 1000) {
      AppToast.show(context, '用量须大于 0，最多三位小数', kind: ToastKind.error);
      return;
    }
    if (c['allow_decimal'] == false && q != q.truncate()) {
      AppToast.show(context, '该商品不允许小数用量', kind: ToastKind.error);
      return;
    }
    setState(() => c['quantity'] = q);
  }

  // ───────── 保存 / 删除 ─────────
  Future<void> _save() async {
    final name = _name.text.trim();
    final price = _priceValue;
    if (name.isEmpty) {
      AppToast.show(context, '请输入名称', kind: ToastKind.error);
      return;
    }
    if (price == null || !price.isFinite || price < 0) {
      AppToast.show(context, '请输入正确的门店价', kind: ToastKind.error);
      return;
    }
    final rate = _commissionValue;
    if (rate == null ||
        rate < 0 ||
        (!_fixedCommission && rate > 100) ||
        (_fixedCommission && rate > 99999999)) {
      AppToast.show(
        context,
        _fixedCommission ? '请输入正确的提成金额' : '提成比例须为 0–100%',
        kind: ToastKind.error,
      );
      return;
    }
    await _api.save('services', {
      if (widget.initial?['id'] != null) 'id': widget.initial!['id'],
      'name': name,
      'price': price,
      'category': _category,
      'duration_minutes': _durationMinutes,
      'description': widget.initial?['description'] ?? '',
      'commission_type': _fixedCommission ? 'fixed' : 'percent',
      'commission_value': rate,
      'active': _active,
      'consumables': [
        for (final c in _consumables)
          {'product_id': c['product_id'], 'quantity': c['quantity']},
      ],
    });
    await _refreshServices();
    if (!mounted) return;
    AppToast.show(context, '已保存', kind: ToastKind.success);
    Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final id = widget.initial?['id']?.toString();
    if (id == null) {
      AppToast.show(context, '尚未保存，无需删除');
      return;
    }
    final confirmed = await hConfirm(
      context,
      '确认删除此项目？',
      onConfirm: () async {
        await _api.delete('services', id);
        await _refreshServices();
      },
    );
    if (confirmed && mounted) Navigator.of(context).pop(true);
  }

  // ───────── 界面 ─────────
  Widget _label(String text) => SizedBox(
    width: 72,
    child: Text(text, style: ts(14, color: C.sub, h: 20)),
  );

  Widget _chevron() => Padding(
    padding: const EdgeInsets.only(left: 12),
    child: AppIcon('chevronRight', size: 16, color: C.faint),
  );

  /// 基本信息里的一行：左侧标签（72 宽），值靠右。
  Widget _infoRow({
    required String label,
    required Widget value,
    VoidCallback? onTap,
  }) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _label(label),
          const SizedBox(width: 12),
          Expanded(child: value),
          if (onTap != null) _chevron(),
        ],
      ),
    ),
  );

  Widget _rightText(String text) =>
      Text(text, textAlign: TextAlign.right, style: ts(15, h: 22));

  Widget _basicInfo() => AppCard(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        _infoRow(
          label: '项目名称',
          value: AppTextInput(
            style: ts(15, h: 22),
            hint: '请输入项目名称',
            controller: _name,
            align: TextAlign.right,
          ),
        ),
        const Divider1(indent: 16),
        _infoRow(
          label: '所属分类',
          value: _rightText(_category),
          onTap: _pickCategory,
        ),
        const Divider1(indent: 16),
        _infoRow(
          label: '标准工时',
          value: _rightText(_durationLabel),
          onTap: _pickDuration,
        ),
      ],
    ),
  );

  Widget _cardBadge(String name) {
    final dark = name.contains('黑金');
    final gold = !dark && name.contains('金');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: dark ? C.pill : (gold ? C.amberSoft : C.chip),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        name,
        style: ts(
          11,
          w: FontWeight.w600,
          color: dark ? C.gold : (gold ? C.amberInk : C.sub),
          h: 18,
        ),
      ),
    );
  }

  Widget _memberPrices() {
    if (_cardsFailed) {
      return Row(
        children: [
          Expanded(
            child: Text('会员价读取失败', style: ts(12, color: C.muted, h: 16)),
          ),
          GestureDetector(
            onTap: _loadCards,
            child: Text(
              '重试',
              style: ts(12, w: FontWeight.w500, color: C.primaryInk, h: 16),
            ),
          ),
        ],
      );
    }
    final price = _priceValue;
    return Column(
      children: [
        for (final c in _cards) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                _cardBadge('${c['name']}'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_discountText(num.parse('${c['discount']}'))} 折',
                    style: ts(14, color: C.muted, h: 20),
                  ),
                ),
                Text(
                  price == null
                      ? '—'
                      : '¥${formatMoney(_memberPrice(price, num.parse('${c['discount']}')))}',
                  style: ts(14, w: FontWeight.w600, h: 20),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 0.9 → 9，0.95 → 9.5。
  static String _discountText(num d) {
    final v = d * 10;
    return v == v.roundToDouble() ? '${v.round()}' : v.toStringAsFixed(1);
  }

  static num _memberPrice(num price, num discount) =>
      (price * discount * 100).round() / 100;

  Widget _priceCard() => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('价格', style: ts(15, w: FontWeight.w600, h: 22)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: C.inset,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text('门店价', style: ts(13, color: C.sub, h: 18)),
              ),
              Text('¥', style: ts(18, w: FontWeight.w600, h: 24)),
              const SizedBox(width: 4),
              SizedBox(
                width: 96,
                child: AppTextInput(
                  style: ts(26, w: FontWeight.w600, h: 32, spacing: -0.52),
                  hint: '0.00',
                  controller: _price,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  align: TextAlign.right,
                  inputFormatters: const [MoneyInputFormatter()],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _memberPrices(),
        if (!_cardsFailed && _cards.isNotEmpty) const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: _cards.isEmpty && !_cardsFailed
                    ? '还没有带折扣的会员卡种，'
                    : '会员价按卡种折扣自动计算，',
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: GestureDetector(
                  onTap: () => openRoute(context, 'CardTiers'),
                  child: Text(
                    '去调整卡种折扣',
                    style: ts(
                      12,
                      w: FontWeight.w500,
                      color: C.primaryInk,
                      h: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          style: ts(12, color: C.muted, h: 16),
        ),
      ],
    ),
  );

  Widget _commissionCard() {
    final rate = _commissionValue;
    final price = _priceValue;
    final hint = _fixedCommission
        ? '每单固定'
        : (rate == null || price == null)
        ? '—'
        : '约 ¥${formatMoney((price * rate / 100).round())} / 单';
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('技师提成', style: ts(15, w: FontWeight.w600, h: 22)),
          const SizedBox(height: 12),
          AppSegmented<bool>(
            selected: _fixedCommission,
            onChanged: (fixed) => setState(() {
              if (fixed == _fixedCommission) return;
              _fixedCommission = fixed;
              _commission.text = fixed ? '0' : '8';
            }),
            items: const [
              SegmentItem(value: false, label: '按实收比例'),
              SegmentItem(value: true, label: '固定金额'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                _fixedCommission ? '提成金额' : '提成比例',
                style: ts(14, color: C.sub, h: 20),
              ),
              Expanded(
                child: Text(
                  hint,
                  textAlign: TextAlign.right,
                  style: ts(12, color: C.muted, h: 16),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: _fixedCommission ? 72 : 48,
                height: 36,
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: AppTextInput(
                  style: ts(15, w: FontWeight.w600, h: 22),
                  hint: _fixedCommission ? '金额' : '比例',
                  controller: _commission,
                  keyboard: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  align: TextAlign.center,
                  inputFormatters: const [MoneyInputFormatter()],
                ),
              ),
              const SizedBox(width: 8),
              Text(_fixedCommission ? '元' : '%', style: ts(14, h: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _consumableRow(Map<String, dynamic> c) {
    final stock = c['stock'] as num? ?? 0;
    final low = stock < (c['safe'] as num? ?? 0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _editConsumable(c),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: low ? C.primarySoft : C.chip,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppIcon(
                'box',
                size: 18,
                color: low ? C.primaryInk : C.sub,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${c['name']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts(14, w: FontWeight.w500, h: 20),
                ),
                Text(
                  '库存 ${qty(stock)} ${c['unit']}${low ? ' · 偏低' : ''}',
                  style: ts(12, color: low ? C.amberInk : C.muted, h: 16),
                ),
              ],
            ),
          ),
          Text(
            '× ${qty(c['quantity'] as num)} ${c['unit']}',
            style: ts(14, w: FontWeight.w600, h: 20),
          ),
        ],
      ),
    );
  }

  Widget _consumablesCard() => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text('耗材绑定', style: ts(15, w: FontWeight.w600, h: 22)),
            ),
            Text('完工后自动扣减库存', style: ts(12, color: C.muted, h: 16)),
          ],
        ),
        const SizedBox(height: 12),
        if (_consumables.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '还没有绑定耗材。绑定后，员工提交完工时按这里的用量从库存自动出库。',
              style: ts(12, color: C.muted, h: 17),
            ),
          )
        else
          for (final c in _consumables) ...[
            _consumableRow(c),
            const SizedBox(height: 12),
          ],
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _addConsumables,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: C.stroke, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppIcon('add', size: 16, color: C.sub),
                const SizedBox(width: 6),
                Text(
                  _pickingProducts ? '读取库存…' : '从库存添加耗材',
                  style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _salesCard() => AppCard(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: Text('上架销售', style: ts(15, h: 22))),
          HSwitch(
            initial: _active,
            value: _active,
            onChanged: (v) => setState(() => _active = v),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (saveKey, onSave) => ListenableBuilder(
        listenable: Listenable.merge([busyActions, _name, _price, _commission]),
        builder: (context, child) => ConfirmDiscard(
          dirty: _snapshot() != _initialSnapshot,
          busy: busyActions.value.contains(saveKey),
          child: child!,
        ),
        child: AsyncActionScope(
          actionKey: saveKey,
          child: HPage(
          bg: C.bg,
          header: AppPageHeader(
            title: widget.initial?['id'] == null ? '新增项目' : '编辑项目',
            leading: AppHeaderLeading.close,
            trailing: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onSave,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: C.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: hBusy(
                  saveKey,
                  Text(
                    '保存',
                    style: ts(
                      14,
                      w: FontWeight.w600,
                      color: Colors.white,
                      h: 20,
                    ),
                  ),
                  style: ts(14, w: FontWeight.w600, color: Colors.white, h: 20),
                  round: true,
                ),
              ),
            ),
          ),
          flow: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _basicInfo(),
                const SizedBox(height: 16),
                _priceCard(),
                const SizedBox(height: 16),
                _commissionCard(),
                const SizedBox(height: 16),
                _consumablesCard(),
                const SizedBox(height: 16),
                _salesCard(),
                const SizedBox(height: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _delete,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      '删除此项目',
                      style: ts(15, w: FontWeight.w500, color: C.redInk, h: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          overlays: const [],
        ),
        ),
      ),
    );
  }
}
