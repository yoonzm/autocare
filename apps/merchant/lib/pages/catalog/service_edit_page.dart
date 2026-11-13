import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';
import '../../resources/merchant_svgs.dart';
import '../../backend/merchant_api.dart';
import '../../backend/service_store.dart';
import '../../kit/text_input.dart';
import '../../kit/sheet_route.dart';

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
    text: widget.initial?['price']?.toString() ?? '',
  );
  final _commission = TextEditingController(text: '8');
  final _commissionMode = SelCtrl({0}, false);
  late final _category = StrCtrl(
    widget.initial?['category']?.toString() ?? '镀晶镀膜',
  );
  late int _durationMinutes =
      int.tryParse('${widget.initial?['duration_minutes'] ?? 30}') ?? 30;
  late final _duration = StrCtrl(
    _durationMinutes % 60 == 0
        ? '${_durationMinutes ~/ 60} 小时'
        : '$_durationMinutes 分钟',
  );

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _commission.dispose();
    _commissionMode.dispose();
    _category.dispose();
    _duration.dispose();
    super.dispose();
  }

  // TODO: 提成、耗材关联与开关缺少服务配置的后端保存契约；
  // 预期由 merchant-v1 的服务配置接口校验并持久化，接通前保留外观并阻止修改。
  void _unsupported() => AppToast.show(context, '此设置暂未接通');

  Future<void> _pickCategory() async {
    final value = await pickFromList(context, '选择分类', [
      '镀晶镀膜',
      '洗车',
      '贴膜',
      '内饰',
      '改色膜',
      '保养维修',
    ], _category.v);
    if (value != null && mounted) _category.set(value);
  }

  Future<void> _pickDuration() async {
    final value = await pickFromList(context, '标准工时', [
      '0.5 小时',
      '1 小时',
      '2 小时',
      '3 小时',
      '4 小时',
      '6 小时',
      '8 小时',
    ], _duration.v);
    if (value == null || !mounted) return;
    _durationMinutes = (num.parse(value.split(' ').first) * 60).round();
    _duration.set(value);
  }

  Future<void> _refreshServices() async {
    try {
      await ServiceStore.refresh();
    } catch (_) {
      // 写入已经成功；保留缓存，列表后续可重试读取。
    }
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = num.tryParse(_price.text.replaceAll(',', '').trim());
    if (name.isEmpty) {
      AppToast.show(context, '请输入名称', kind: ToastKind.error);
      return;
    }
    if (price == null || !price.isFinite || price < 0) {
      AppToast.show(context, '请输入正确的门店价', kind: ToastKind.error);
      return;
    }
    await _api.save('services', {
      if (widget.initial?['id'] != null) 'id': widget.initial!['id'],
      'name': name,
      'price': price,
      'category': _category.v,
      'duration_minutes': _durationMinutes,
      'description': widget.initial?['description'] ?? '',
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

  @override
  Widget build(BuildContext context) {
    return AsyncAction(
      onTap: _save,
      builder: (saveKey, onSave) => AsyncActionScope(
        actionKey: saveKey,
        child: HPage(
          bg: dk(context, Color(0xFFF4F4F5), Color(0xFF09090B)),
          height: 1200,
          fixedHeight: false,
          flow: hcol(
            [
              hbox(
                pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 32),
                child: hcol(
                  [
                    hrow(
                      [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: hbox(
                            w: 44,
                            h: 44,
                            bg: dk(
                              context,
                              Color(0xFFFFFFFF),
                              Color(0xFF18181B),
                            ),
                            radius: BorderRadius.circular(22),
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
                            child: hrow(
                              [
                                hsvg(
                                  dk(context, Svgs.s71, Svgs.s72),
                                  w: 20,
                                  h: 20,
                                ),
                              ],
                              main: MainAxisAlignment.center,
                              cross: CrossAxisAlignment.center,
                              gap: 0,
                            ),
                          ),
                          onTap: () => Navigator.maybePop(context),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '编辑项目',
                            style: hts(
                              17,
                              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                              w: FontWeight.w600,
                              lh: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onSave,
                          child: hbox(
                            h: 44,
                            bg: Color(0xFF0485F7),
                            radius: BorderRadius.circular(22),
                            pad: EdgeInsets.fromLTRB(18, 0, 18, 0),
                            child: Align(
                              alignment: Alignment(-1, 0),
                              widthFactor: 1,
                              child: hBusy(
                                saveKey,
                                Text(
                                  '保存',
                                  style: hts(
                                    14,
                                    Color(0xFFFFFFFF),
                                    w: FontWeight.w600,
                                    lh: 20,
                                  ),
                                ),
                                style: hts(
                                  14,
                                  Color(0xFFFFFFFF),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                                round: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.center,
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
                                    '项目名称',
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
                                    hint: '请输入项目名称',
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
                          AnimatedBuilder(
                            animation: _category,
                            builder: (context, _) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _pickCategory,
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 72,
                                      child: Text(
                                        '所属分类',
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
                                      flex: 1,
                                      child: hStr(
                                        _category,
                                        hts(
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
                            margin: EdgeInsets.fromLTRB(16, 0, 0, 0),
                          ),
                          AnimatedBuilder(
                            animation: _duration,
                            builder: (context, _) => GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: _pickDuration,
                              child: hbox(
                                minH: 54,
                                pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: hrow(
                                  [
                                    hbox(
                                      w: 72,
                                      child: Text(
                                        '标准工时',
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
                                      flex: 1,
                                      child: hStr(
                                        _duration,
                                        hts(
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
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 0,
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          Text(
                            '价格',
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
                              Color(0xFFF4F4F5),
                              Color(0xFF27272A),
                            ),
                            radius: BorderRadius.circular(16),
                            pad: EdgeInsets.fromLTRB(14, 10, 14, 10),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '门店价',
                                    style: hts(
                                      13,
                                      dk(
                                        context,
                                        Color(0xFF52525B),
                                        Color(0xFFA8A8B3),
                                      ),
                                      lh: 18,
                                    ),
                                  ),
                                ),
                                Text(
                                  '¥',
                                  style: hts(
                                    18,
                                    dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFFFAFAFA),
                                    ),
                                    w: FontWeight.w600,
                                    lh: 24,
                                  ),
                                ),
                                hbox(
                                  w: 96,
                                  child: AppTextInput(
                                    style: hts(
                                      26,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 32,
                                      ls: -0.52,
                                    ),
                                    hint: '请输入门店价',
                                    controller: _price,
                                    keyboard: TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    align: TextAlign.right,
                                  ),
                                ),
                              ],
                              main: MainAxisAlignment.start,
                              cross: CrossAxisAlignment.baseline,
                              gap: 4,
                            ),
                          ),
                          hcol(
                            [
                              hrow(
                                [
                                  hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFF18181B),
                                      Color(0xFF34343A),
                                    ),
                                    radius: BorderRadius.circular(9),
                                    pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                    child: Text(
                                      '黑金卡',
                                      style: hts(
                                        11,
                                        Color(0xFFF5D78E),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '9 折',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥1,422',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                              hrow(
                                [
                                  hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFFDEFD6),
                                      Color.fromRGBO(245, 165, 36, 0.16),
                                    ),
                                    radius: BorderRadius.circular(9),
                                    pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                    child: Text(
                                      '金卡',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFF855F2E),
                                          Color(0xFFF0C46A),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '95 折',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥1,501',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                              hrow(
                                [
                                  hbox(
                                    bg: dk(
                                      context,
                                      Color(0xFFEEEEF0),
                                      Color(0xFF27272A),
                                    ),
                                    radius: BorderRadius.circular(9),
                                    pad: EdgeInsets.fromLTRB(7, 0, 7, 0),
                                    child: Text(
                                      '银卡',
                                      style: hts(
                                        11,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w600,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      '98 折',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF71717A),
                                          Color(0xFF9A9AA3),
                                        ),
                                        lh: 20,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '¥1,548',
                                    style: hts(
                                      14,
                                      dk(
                                        context,
                                        Color(0xFF18181B),
                                        Color(0xFFFAFAFA),
                                      ),
                                      w: FontWeight.w600,
                                      lh: 20,
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.start,
                                cross: CrossAxisAlignment.center,
                                gap: 8,
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.stretch,
                            gap: 10,
                          ),
                          Text.rich(
                            TextSpan(
                              style: hts(
                                12,
                                dk(
                                  context,
                                  Color(0xFF71717A),
                                  Color(0xFF9A9AA3),
                                ),
                                lh: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: '会员价按卡种折扣自动计算，',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 16,
                                  ),
                                ),
                                TextSpan(
                                  text: '去调整卡种折扣',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF1E63AE),
                                      Color(0xFF6AB4FA),
                                    ),
                                    w: FontWeight.w500,
                                    lh: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 14,
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          Text(
                            '技师提成',
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
                                        ctrl: _commissionMode,
                                        onTap: _unsupported,
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
                                              '按实收比例',
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
                                              '按实收比例',
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
                                        ctrl: _commissionMode,
                                        onTap: _unsupported,
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
                                              '固定金额',
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
                                              '固定金额',
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
                          hrow(
                            [
                              Text(
                                '提成比例',
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
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '约 ¥126 / 单',
                                  style: hts(
                                    12,
                                    dk(
                                      context,
                                      Color(0xFF71717A),
                                      Color(0xFF9A9AA3),
                                    ),
                                    lh: 16,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              hbox(
                                w: 48,
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFF4F4F5),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(10),
                                align: Alignment.centerLeft,
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
                                  hint: '请输入提成比例',
                                  controller: _commission,
                                  readOnly: true,
                                  onTap: _unsupported,
                                  keyboard: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  align: TextAlign.center,
                                ),
                              ),
                              Text(
                                '%',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 8,
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
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
                      pad: EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: hcol(
                        [
                          hrow(
                            [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '耗材绑定',
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
                                ),
                              ),
                              Text(
                                '完工后自动扣减库存',
                                style: hts(
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
                            cross: CrossAxisAlignment.baseline,
                            gap: 0,
                          ),
                          hrow(
                            [
                              hbox(
                                w: 36,
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFE1F0FE),
                                  Color.fromRGBO(4, 133, 247, 0.18),
                                ),
                                radius: BorderRadius.circular(12),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s344, Svgs.s345),
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
                                      '9H 陶瓷镀晶液 50ml',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '库存 6 瓶 · 偏低',
                                      style: hts(
                                        12,
                                        dk(
                                          context,
                                          Color(0xFF855F2E),
                                          Color(0xFFF0C46A),
                                        ),
                                        lh: 16,
                                      ),
                                    ),
                                  ],
                                  main: MainAxisAlignment.start,
                                  cross: CrossAxisAlignment.stretch,
                                  gap: 1,
                                ),
                              ),
                              Text(
                                '× 1 瓶',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          hrow(
                            [
                              hbox(
                                w: 36,
                                h: 36,
                                bg: dk(
                                  context,
                                  Color(0xFFEEEEF0),
                                  Color(0xFF27272A),
                                ),
                                radius: BorderRadius.circular(12),
                                child: hrow(
                                  [
                                    hsvg(
                                      dk(context, Svgs.s346, Svgs.s347),
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
                                      '超细纤维擦车巾',
                                      style: hts(
                                        14,
                                        dk(
                                          context,
                                          Color(0xFF18181B),
                                          Color(0xFFFAFAFA),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 20,
                                      ),
                                    ),
                                    Text(
                                      '库存 86 条',
                                      style: hts(
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
                                  gap: 1,
                                ),
                              ),
                              Text(
                                '× 4 条',
                                style: hts(
                                  14,
                                  dk(
                                    context,
                                    Color(0xFF18181B),
                                    Color(0xFFFAFAFA),
                                  ),
                                  w: FontWeight.w600,
                                  lh: 20,
                                ),
                              ),
                            ],
                            main: MainAxisAlignment.start,
                            cross: CrossAxisAlignment.center,
                            gap: 12,
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _unsupported,
                            child: hbox(
                              h: 40,
                              radius: BorderRadius.circular(14),
                              border: dk(
                                context,
                                Border.all(
                                  color: Color(0xFFD4D4D8),
                                  width: 1.5,
                                ),
                                Border.all(
                                  color: Color(0xFF3F3F46),
                                  width: 1.5,
                                ),
                              ),
                              child: hrow(
                                [
                                  hsvg(
                                    dk(context, Svgs.s348, Svgs.s349),
                                    w: 16,
                                    h: 16,
                                  ),
                                  Flexible(
                                    flex: 91,
                                    child: Text(
                                      '从库存添加耗材',
                                      style: hts(
                                        13,
                                        dk(
                                          context,
                                          Color(0xFF3F3F46),
                                          Color(0xFFD4D4D8),
                                        ),
                                        w: FontWeight.w500,
                                        lh: 18,
                                      ),
                                    ),
                                  ),
                                ],
                                main: MainAxisAlignment.center,
                                cross: CrossAxisAlignment.center,
                                gap: 6,
                              ),
                            ),
                          ),
                        ],
                        main: MainAxisAlignment.start,
                        cross: CrossAxisAlignment.stretch,
                        gap: 12,
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
                            minH: 56,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '上架销售',
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
                                  initial: true,
                                  value: true,
                                  onChanged: (_) => _unsupported(),
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
                            minH: 56,
                            pad: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: hrow(
                              [
                                Expanded(
                                  flex: 1,
                                  child: hcol(
                                    [
                                      Text(
                                        '支持线上预约',
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
                                      Text(
                                        '客户可在小程序预约此项目',
                                        style: hts(
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
                                HSwitch(
                                  initial: false,
                                  value: false,
                                  onChanged: (_) => _unsupported(),
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
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _delete,
                      child: hbox(
                        h: 48,
                        radius: BorderRadius.circular(24),
                        child: Align(
                          alignment: Alignment.center,
                          widthFactor: 1,
                          child: Text(
                            '删除此项目',
                            style: hts(
                              15,
                              dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                              w: FontWeight.w500,
                              lh: 22,
                            ),
                          ),
                        ),
                      ),
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
