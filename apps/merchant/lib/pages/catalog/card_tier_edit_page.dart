import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../backend/store_profile.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/sheet_route.dart';
import '../../kit/text_input.dart';
import '../../resources/merchant_svgs.dart';

Future<bool?> openCardTierEditor(
  BuildContext context, {
  Map<String, dynamic>? initial,
}) => Navigator.of(context).push<bool>(
  appSheetRoute<bool>(
    settings: const RouteSettings(name: 'CardTierEdit'),
    page: CardTierEditPage(initial: initial),
  ),
);

class CardTierEditPage extends StatefulWidget {
  final Map<String, dynamic>? initial;
  const CardTierEditPage({super.key, this.initial});
  @override
  State<CardTierEditPage> createState() => _CardTierEditPageState();
}

class _CardTierEditPageState extends State<CardTierEditPage> {
  static const _validities = ['forever', '1y', '2y'];
  late final _api = merchantApi;
  late final _name = TextEditingController(
    text: widget.initial?['name']?.toString() ?? '',
  );
  late final _recharge = TextEditingController(
    text: widget.initial?['upgrade_recharge']?.toString() ?? '',
  );
  late final _cumulative = TextEditingController(
    text: widget.initial?['upgrade_cumulative']?.toString() ?? '',
  );
  late final _discount = ValCtrl(
    ((num.tryParse('${widget.initial?['discount'] ?? 0.9}') ?? 0.9) * 100)
        .round(),
  );
  late String _color = widget.initial?['color']?.toString() ?? 'black';
  late bool _priority = widget.initial?['priority_booking'] == true;
  late final _multiplier = StrCtrl(
    '${widget.initial?['points_multiplier'] ?? 1} 倍',
  );
  late final _gift = StrCtrl(
    '${widget.initial?['birthday_gift'] ?? ''}'.isEmpty
        ? '不赠送'
        : '${widget.initial!['birthday_gift']}',
  );
  late final _validity = SelCtrl({
    _validities
        .indexOf('${widget.initial?['validity'] ?? 'forever'}')
        .clamp(0, 2),
  }, false);

  @override
  void dispose() {
    _name.dispose();
    _recharge.dispose();
    _cumulative.dispose();
    _discount.dispose();
    _multiplier.dispose();
    _gift.dispose();
    _validity.dispose();
    super.dispose();
  }

  Future<void> _pickMultiplier() async {
    final value = await pickFromList(context, '积分倍率', [
      '1 倍',
      '1.5 倍',
      '2 倍',
      '3 倍',
    ], _multiplier.v);
    if (value != null && mounted) _multiplier.set(value);
  }

  Future<void> _pickGift() async {
    final value = await pickFromList(context, '生日礼', [
      '不赠送',
      '赠精致洗车 1 次',
      '赠精致洗车 2 次',
      '赠 50 元券',
    ], _gift.v);
    if (value != null && mounted) _gift.set(value);
  }

  num? _money(TextEditingController field, String label) {
    final text = field.text.replaceAll(',', '').trim();
    if (text.isEmpty) return null;
    final value = num.tryParse(text);
    if (value == null || !value.isFinite || value < 0 || value > 99999999) {
      throw AppError('请输入正确的$label金额');
    }
    return value;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) throw const AppError('请输入名称');
    final discount = _discount.v / 100;
    if (discount <= 0 || discount > 1) throw const AppError('请输入正确的折扣');
    await _api.save('cards', {
      if (widget.initial?['id'] != null) 'id': widget.initial!['id'],
      'name': name,
      'discount': discount,
      'color': _color,
      'upgrade_recharge': _money(_recharge, '单次充值满'),
      'upgrade_cumulative': _money(_cumulative, '累计消费满'),
      'points_multiplier': num.parse(_multiplier.v.replaceAll('倍', '').trim()),
      'birthday_gift': _gift.v == '不赠送' ? '' : _gift.v,
      'priority_booking': _priority,
      'validity': _validities[_validity.selected.first],
      if (widget.initial?.containsKey('description') == true)
        'description': widget.initial!['description'],
    });
    if (!mounted) return;
    AppToast.show(context, '已保存', kind: ToastKind.success);
    Navigator.of(context).pop(true);
  }

  Future<void> _disable() async {
    final id = widget.initial?['id']?.toString();
    if (id == null) {
      AppToast.show(context, '尚未保存，无需删除');
      return;
    }
    final confirmed = await hConfirm(
      context,
      '确认停用此卡种？',
      onConfirm: () => _api.delete('cards', id),
    );
    if (confirmed && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (saveKey, onSave) => AsyncActionScope(
        actionKey: saveKey,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 1170,
          fixedHeight: false,
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
                child: hcol(
                  [
                    hrow(
                      [
                        AppIconButton(
                          svg: dk(context, Svgs.s71, Svgs.s72),
                          semanticLabel: "返回",
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '编辑卡种',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ActionButton(
                          actionKey: saveKey,
                          label: '保存',
                          kind: AppButtonKind.primary,
                          size: AppButtonSize.medium,
                          expanded: false,
                          onPressed: onSave,
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
                      gap: 8,
                    ),
                    ListenableBuilder(
                      listenable: Listenable.merge([
                        _name,
                        _discount,
                        storeProfile,
                      ]),
                      builder: (context, _) => CardPreview(
                        name: _name.text.trim(),
                        discount: _discount.v / 100,
                        color: _color,
                        store: storeProfile.name,
                      ),
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(24),
                      shadow: dk(
                        context,
                        [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        [
                          BoxShadow(
                            color: Color(0xFF26262B),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: hcol(
                        [
                          hbox(
                            minH: 54,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                hbox(
                                  w: 72,
                                  child: Text(
                                    '卡种名称',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 20,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: AppTextInput(
                                    style: hts(
                                      15,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      lh: 22,
                                    ),
                                    hint: '请输入卡种名称',
                                    controller: _name,
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.center,
                              gap: 12,
                            ),
                          ),
                          hbox(
                            h: 1,
                            bg: dk(
                              context,
                              Color(0xFFEFEFF1),
                              Color(0xFF2A2A2E),
                            ),
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          hbox(
                            pad: EdgeInsets.fromLTRB(16, 12, 16, 12),
                            child: hcol(
                              [
                                hbox(
                                  minH: 36,
                                  child: hrow(
                                    [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          '卡面颜色',
                                          style: hts(
                                            14,
                                            dk(
                                              context,
                                              Color(0xFF52525B),
                                              Color(0xFFA8A8B3),
                                            ),
                                            lh: 20,
                                          ),
                                        ),
                                      ),
                                      CardColorChoices(
                                        value: _color,
                                        onChanged: (value) =>
                                            setState(() => _color = value),
                                      ),
                                    ],
                                    main: MainAxisAlignment.start,
                                    cross: CrossAxisAlignment.center,
                                    gap: 12,
                                  ),
                                ),
                                Text(
                                  '前四个为系统默认卡种配色，文字颜色会按底色自动调整',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 17,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.stretch,
                              gap: 6,
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
                      ),
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '升级条件（满足任一即实时升级）',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                        hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(24),
                          shadow: dk(
                            context,
                            [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.06),
                                offset: Offset(0, 0),
                                blurRadius: 1,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.06),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.04),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                            [
                              BoxShadow(
                                color: Color(0xFF26262B),
                                offset: Offset(0, 0),
                                blurRadius: 0,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: hcol(
                            [
                              hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '单次充值满',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    hbox(
                                      w: 72,
                                      child: AppTextInput(
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 22,
                                        ),
                                        hint: '请输入单次充值满',
                                        controller: _recharge,
                                        keyboard:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        align: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 8,
                                ),
                              ),
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                              ),
                              hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '累计消费满',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '¥',
                                      style: hts(
                                        15,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 22,
                                      ),
                                    ),
                                    hbox(
                                      w: 72,
                                      child: AppTextInput(
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          w: FontWeight.w600,
                                          lh: 22,
                                        ),
                                        hint: '请输入累计消费满',
                                        controller: _cumulative,
                                        keyboard:
                                            TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        align: TextAlign.right,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 8,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 8,
                    ),
                    hcol(
                      [
                        hbox(
                          pad: EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                            '会员权益',
                            style: hts(
                              13,
                              dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                              w: FontWeight.w500,
                              lh: 18,
                            ),
                          ),
                        ),
                        hbox(
                          bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                          radius: BorderRadius.circular(24),
                          shadow: dk(
                            context,
                            [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.06),
                                offset: Offset(0, 0),
                                blurRadius: 1,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.06),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.04),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                            ],
                            [
                              BoxShadow(
                                color: Color(0xFF26262B),
                                offset: Offset(0, 0),
                                blurRadius: 0,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          pad: EdgeInsets.fromLTRB(0, 4, 0, 4),
                          child: hcol(
                            [
                              hbox(
                                minH: 58,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 32,
                                      h: 32,
                                      bg: dk(
                                        context,
                                        Color(0xFFFDEFD6),
                                        Color.fromRGBO(245, 165, 36, 0.16),
                                      ),
                                      radius: BorderRadius.circular(10),
                                      align: Alignment(0, 0),
                                      child: Text(
                                        '%',
                                        style: hts(
                                          13,
                                          dk(
                                            context,
                                            Color(0xFF855F2E),
                                            Color(0xFFF0C46A),
                                          ),
                                          w: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '项目折扣',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                    ),
                                    Builder(
                                      builder: (context) {
                                        final c1 = _discount;
                                        return HNumberStepper(
                                          ctrl: c1,
                                          step: 1,

                                          value: hbox(
                                            w: 52,
                                            align: Alignment.center,
                                            child: hCount(
                                              c1,
                                              hts(
                                                15,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w600,
                                                lh: 22,
                                              ),
                                              1,
                                              ' 折',
                                              false,
                                            ),
                                          ),

                                          main: MainAxisAlignment.start,
                                          cross: CrossAxisAlignment.center,
                                          gap: 4,
                                        );
                                      },
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                              ),
                              AnimatedBuilder(
                                animation: _multiplier,
                                builder: (context, _) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _pickMultiplier,
                                  child: hbox(
                                    minH: 58,
                                    pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 32,
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFE1F0FE),
                                            Color.fromRGBO(4, 133, 247, 0.18),
                                          ),
                                          radius: BorderRadius.circular(10),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(context, Svgs.s75, Svgs.s76),
                                                w: 18,
                                                h: 18,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            '积分倍率',
                                            style: hts(
                                              15,
                                              dk(
                                                context,
                                                Color(0xFF18181B),
                                                Color(0xFFFAFAFA),
                                              ),
                                              lh: 22,
                                            ),
                                          ),
                                        ),
                                        hStr(
                                          _multiplier,
                                          hts(
                                            15,
                                            dk(
                                              context,
                                              Color(0xFF18181B),
                                              Color(0xFFFAFAFA),
                                            ),
                                            w: FontWeight.w600,
                                            lh: 22,
                                          ),
                                        ),
                                        hsvg(
                                          dk(context, Svgs.s3, Svgs.s4),
                                          w: 16,
                                          h: 16,
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                ),
                              ),
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                              ),
                              AnimatedBuilder(
                                animation: _gift,
                                builder: (context, _) => GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _pickGift,
                                  child: hbox(
                                    minH: 58,
                                    pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                    child: hrow(
                                      [
                                        hbox(
                                          w: 32,
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFFFE1E2),
                                            Color.fromRGBO(255, 56, 60, 0.18),
                                          ),
                                          radius: BorderRadius.circular(10),
                                          child: hrow(
                                            [
                                              hsvg(
                                                dk(context, Svgs.s77, Svgs.s78),
                                                w: 18,
                                                h: 18,
                                              ),
                                            ],
                                            main: MainAxisAlignment.center,
                                            cross: CrossAxisAlignment.center,
                                            gap: 0,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: hcol(
                                            [
                                              Text(
                                                '生日礼',
                                                style: hts(
                                                  15,
                                                  dk(
                                                    context,
                                                    Color(0xFF18181B),
                                                    Color(0xFFFAFAFA),
                                                  ),
                                                  lh: 22,
                                                ),
                                              ),
                                              hStr(
                                                _gift,
                                                hts(
                                                  12,
                                                  dk(
                                                    context,
                                                    Color(0xFF71717A),
                                                    Color(0xFF9A9AA3),
                                                  ),
                                                  lh: 16,
                                                ),
                                              ),
                                            ],
                                            main: MainAxisAlignment.start,
                                            cross: CrossAxisAlignment.stretch,
                                            gap: 0,
                                          ),
                                        ),
                                        hsvg(
                                          dk(context, Svgs.s3, Svgs.s4),
                                          w: 16,
                                          h: 16,
                                        ),
                                      ],
                                      main: MainAxisAlignment.start,
                                      cross: CrossAxisAlignment.center,
                                      gap: 12,
                                    ),
                                  ),
                                ),
                              ),
                              hbox(
                                h: 1,
                                bg: dk(
                                  context,
                                  Color(0xFFEFEFF1),
                                  Color(0xFF2A2A2E),
                                ),
                                margin: EdgeInsets.fromLTRB(60, 0, 0, 0),
                              ),
                              hbox(
                                minH: 58,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 32,
                                      h: 32,
                                      bg: dk(
                                        context,
                                        Color(0xFFDDF6E7),
                                        Color.fromRGBO(23, 201, 100, 0.16),
                                      ),
                                      radius: BorderRadius.circular(10),
                                      child: hrow(
                                        [
                                          hsvg(
                                            dk(context, Svgs.s79, Svgs.s80),
                                            w: 18,
                                            h: 18,
                                          ),
                                        ],
                                        main: MainAxisAlignment.center,
                                        cross: CrossAxisAlignment.center,
                                        gap: 0,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '预约优先排期',
                                        style: hts(
                                          15,
                                          dk(
                                            context,
                                            Color(0xFF18181B),
                                            Color(0xFFFAFAFA),
                                          ),
                                          lh: 22,
                                        ),
                                      ),
                                    ),
                                    HSwitch(
                                      initial: _priority,
                                      value: _priority,
                                      onChanged: (value) =>
                                          setState(() => _priority = value),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.center,
                                  gap: 12,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 0,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 8,
                    ),
                    hbox(
                      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
                      radius: BorderRadius.circular(24),
                      shadow: dk(
                        context,
                        [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 0),
                            blurRadius: 1,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.04),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                        [
                          BoxShadow(
                            color: Color(0xFF26262B),
                            offset: Offset(0, 0),
                            blurRadius: 0,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          Text(
                            '有效期',
                            style: hts(
                              15,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 22,
                            ),
                          ),
                          hbox(
                            bg: dk(
                              context,
                              Color(0xFFEEEEF0),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(18),
                            pad: EdgeInsets.fromLTRB(4, 4, 4, 4),
                            child: Builder(
                              builder: (context) => hrow(
                                [
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: HSel(
                                        ctrl: _validity,
                                        index: 0,
                                        on: hbox(
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFFFFFFF),
                                            Color(0xFF18181B),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          shadow: dk(
                                            context,
                                            [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.08,
                                                ),
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                            [
                                              BoxShadow(
                                                color: Color(0xFF26262B),
                                                offset: Offset(0, 0),
                                                blurRadius: 0,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '永久有效',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        off: hbox(
                                          h: 32,
                                          radius: BorderRadius.circular(16),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '永久有效',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: HSel(
                                        ctrl: _validity,
                                        index: 1,
                                        on: hbox(
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFFFFFFF),
                                            Color(0xFF18181B),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          shadow: dk(
                                            context,
                                            [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.08,
                                                ),
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                            [
                                              BoxShadow(
                                                color: Color(0xFF26262B),
                                                offset: Offset(0, 0),
                                                blurRadius: 0,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '1 年',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        off: hbox(
                                          h: 32,
                                          radius: BorderRadius.circular(16),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '1 年',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: UnconstrainedBox(
                                      alignment: Alignment.topLeft,
                                      constrainedAxis: Axis.horizontal,
                                      child: HSel(
                                        ctrl: _validity,
                                        index: 2,
                                        on: hbox(
                                          h: 32,
                                          bg: dk(
                                            context,
                                            Color(0xFFFFFFFF),
                                            Color(0xFF18181B),
                                          ),
                                          radius: BorderRadius.circular(16),
                                          shadow: dk(
                                            context,
                                            [
                                              BoxShadow(
                                                color: Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.08,
                                                ),
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                            [
                                              BoxShadow(
                                                color: Color(0xFF26262B),
                                                offset: Offset(0, 0),
                                                blurRadius: 0,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '2 年',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF18181B),
                                                  Color(0xFFFAFAFA),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                        off: hbox(
                                          h: 32,
                                          radius: BorderRadius.circular(16),
                                          child: Align(
                                            alignment: Alignment.center,
                                            widthFactor: 1,
                                            child: Text(
                                              '2 年',
                                              style: hts(
                                                13,
                                                dk(
                                                  context,
                                                  Color(0xFF52525B),
                                                  Color(0xFFA8A8B3),
                                                ),
                                                w: FontWeight.w500,
                                                lh: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.stretch,
                                gap: 2,
                                intrinsic: true,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 10,
                      ),
                    ),
                    AppButton(
                      label: '停用此卡种',
                      kind: AppButtonKind.danger,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: _disable,
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.stretch,
                  gap: 16,
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 0,
          ),
          overlays: [],
        ),
      ),
    );
  }
}
