import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../backend/merchant_api.dart';
import '../kit/async_kit.dart';
import '../kit/kit.dart';
import 'st_member_template.dart' show StMemberFlow;

/// 次卡核销：选一张次卡里的一个项目，验证码发送到会员登记的手机号，会员本人把验证码告知后核销。
/// 设计稿没有这个弹层，只用设计稿同色系的基础样式；验证和扣次全部在服务端完成。
Future<void> showStRedeemSheet(BuildContext context, Map<String, dynamic> info) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RedeemSheet(info: info),
  );
}

class _RedeemSheet extends StatefulWidget {
  final Map<String, dynamic> info;
  const _RedeemSheet({required this.info});

  @override
  State<_RedeemSheet> createState() => _RedeemSheetState();
}

class _RedeemSheetState extends State<_RedeemSheet> {
  final _code = TextEditingController();
  String? _pkg;
  String? _service;
  int _cooldown = 0;
  Timer? _timer;

  List<Map<String, dynamic>> get _options => [
    for (final p in (widget.info['packages'] as List? ?? const []))
      for (final i in ((p as Map)['items'] as List? ?? const []))
        {
          'package_id': '${p['id']}',
          'service_id': '${(i as Map)['service_id']}',
          'label': '${p['name']} · ${i['name']}（剩余 ${i['remaining']} 次）',
        },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _cooldown = _cooldown - 1);
      if (_cooldown <= 0) t.cancel();
    });
  }

  Future<void> _send() => runBusy('StRedeem>send', () async {
    try {
      final r = await merchantApi.staffWork('staff_redeem_send', {'member_id': '${widget.info['id']}'});
      if (!mounted) return;
      _startCooldown(((r['retry_after'] as num?) ?? 60).toInt());
      AppToast.show(context, '验证码已发送至会员手机 ${widget.info['phone_masked']}', kind: ToastKind.success);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  });

  Future<void> _confirm() => runBusy('StRedeem>confirm', () async {
    final pkg = _pkg, service = _service;
    if (pkg == null || service == null) {
      hToast(context, '请选择要核销的项目');
      return;
    }
    if (_code.text.length != 6) {
      hToast(context, '请输入 6 位数字验证码');
      return;
    }
    try {
      final r = await merchantApi.staffWork('staff_redeem', {
        'member_id': '${widget.info['id']}',
        'member_package_id': pkg,
        'service_id': service,
        'qty': 1,
        'code': _code.text,
        'plate': '${widget.info['plate'] ?? ''}',
      });
      if (!mounted) return;
      StMemberFlow.changed.value++;
      Navigator.of(context).pop();
      AppToast.show(context, '核销成功 · ${r['service']} 剩余 ${r['remaining']} 次', kind: ToastKind.success);
    } catch (e) {
      if (mounted) AppToast.error(context, e);
    }
  });

  @override
  Widget build(BuildContext context) {
    final options = _options;
    final ink = dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA));
    final sub = dk(context, const Color(0xFF71717A), const Color(0xFF9A9AA3));
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('次卡核销', style: hts(18, ink, w: FontWeight.w600, lh: 26)),
              const SizedBox(height: 4),
              Text('验证码将发送至会员手机 ${widget.info['phone_masked']}，请会员本人告知验证码。',
                  style: hts(12, sub, lh: 17)),
              const SizedBox(height: 16),
              if (options.isEmpty)
                Text('该会员没有可核销的次卡', style: hts(14, sub, lh: 20))
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final o in options)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() {
                              _pkg = o['package_id'] as String;
                              _service = o['service_id'] as String;
                            }),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Icon(
                                    _pkg == o['package_id'] && _service == o['service_id']
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    size: 20,
                                    color: _pkg == o['package_id'] && _service == o['service_id']
                                        ? const Color(0xFF0485F7)
                                        : sub,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text('${o['label']}', style: hts(14, ink, lh: 20))),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: dk(context, const Color(0xFFF4F4F5), const Color(0xFF27272A)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        style: hts(15, ink, lh: 22),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          counterText: '',
                          hintText: '请输入会员收到的 6 位验证码',
                          hintStyle: hts(15, sub, lh: 22),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  hTap(
                    context,
                    hbox(
                      h: 48,
                      bg: _cooldown > 0
                          ? dk(context, const Color(0xFFEEEEF0), const Color(0xFF27272A))
                          : const Color(0xFFE1F0FE),
                      radius: BorderRadius.circular(24),
                      pad: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        widthFactor: 1,
                        child: hBusy(
                          'StRedeem>send',
                          Text(
                            _cooldown > 0 ? '$_cooldown 秒后重发' : '发送验证码',
                            style: hts(14, _cooldown > 0 ? sub : const Color(0xFF1E63AE), w: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    onTap: _cooldown > 0 ? null : _send,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              hTap(
                context,
                hbox(
                  h: 50,
                  bg: const Color(0xFF0485F7),
                  radius: BorderRadius.circular(25),
                  child: Align(
                    widthFactor: 1,
                    child: hBusy(
                      'StRedeem>confirm',
                      Text('确认核销', style: hts(15, const Color(0xFFFFFFFF), w: FontWeight.w600, lh: 22)),
                    ),
                  ),
                ),
                onTap: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
