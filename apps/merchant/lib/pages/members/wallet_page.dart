import 'dart:async';

import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../kit/single_selection.dart';
import '../../kit/text_input.dart';
import '../../resources/merchant_svgs.dart';
import '../../routes.dart' show openRoute;
import 'packages/package_choices.dart' show PackageChoices;
import 'wallet_controller.dart';

/// 会员充值与购买次卡统一骨架页：共用页签、会员卡片、收款方式与底部收款栏，仅中间业务区随页签切换。
class WalletPage extends StatefulWidget {
  final Map<String, dynamic>? member;
  final int initial;
  const WalletPage({super.key, this.member, this.initial = 0});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late WalletController c = _createController();

  WalletController _createController() {
    final ctrl = WalletController(member: widget.member, tab: widget.initial);
    if (merchantApi.hasSession) {
      unawaited(ctrl.ensureTabLoaded(widget.initial));
    }
    return ctrl;
  }

  @override
  void didUpdateWidget(WalletPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.member?['id'] != oldWidget.member?['id'] ||
        widget.initial != oldWidget.initial) {
      c.dispose();
      c = _createController();
    }
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
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
    return Scaffold(
      body: ListenableBuilder(
        listenable: c,
        builder: (context, _) {
          final tab = c.tab;
          final hasMember = c.member != null;
          return AsyncActionScope(
            actionKey: c.actionKey,
            child: HPage(
              bg: dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B)),
              header: const AppPageHeader(title: '会员充值'),
              flow: hcol(
                [
                  hbox(
                    pad: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    child: hcol(
                      [
                        _TabBar(tab: tab, onSelect: c.selectTab),
                        hcol(
                          [
                            if (!hasMember)
                              _EmptyMemberCard(
                                onTap: () => c.chooseMember(context),
                              )
                            else if (tab == 0)
                              _RechargeMemberCard(c: c)
                            else
                              _CardMemberCard(c: c),
                            _MiddleSection(
                              c: c,
                              tab: tab,
                              hasMember: hasMember,
                            ),
                            _PayMethodCard(c: c, disabled: !hasMember),
                          ],
                          main: MainAxisAlignment.start,
                          cross: CrossAxisAlignment.stretch,
                          gap: 16,
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
              overlays: [_BottomDock(c: c, tab: tab, hasMember: hasMember)],
            ),
          );
        },
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onSelect;
  const _TabBar({required this.tab, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    Widget item(int index, String label) {
      final active = tab == index;
      final pill = active
          ? hbox(
              h: 34,
              bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
              radius: BorderRadius.circular(17),
              shadow: _tabShadow(context),
              child: Align(
                alignment: Alignment.center,
                widthFactor: 1,
                child: Text(
                  label,
                  style: hts(
                    14,
                    dk(
                      context,
                      const Color(0xFF18181B),
                      const Color(0xFFFAFAFA),
                    ),
                    w: FontWeight.w500,
                    lh: 20,
                  ),
                ),
              ),
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onSelect(index),
              child: hbox(
                h: 34,
                radius: BorderRadius.circular(17),
                child: Align(
                  alignment: Alignment.center,
                  widthFactor: 1,
                  child: Text(
                    label,
                    style: hts(
                      14,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w500,
                      lh: 20,
                    ),
                  ),
                ),
              ),
            );
      return Expanded(
        flex: 1,
        child: UnconstrainedBox(
          alignment: Alignment.topLeft,
          constrainedAxis: Axis.horizontal,
          child: pill,
        ),
      );
    }

    return hbox(
      bg: dk(context, const Color(0xFFE9E9EB), const Color(0xFF1F1F23)),
      radius: BorderRadius.circular(20),
      pad: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: hrow(
        [item(0, '储值充值'), item(1, '购买次卡')],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 2,
        intrinsic: true,
      ),
    );
  }
}

class _EmptyMemberCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyMemberCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: hbox(
        bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
        radius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFBFDDFB), width: 2),
        pad: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: hrow(
          [
            hbox(
              w: 44,
              h: 44,
              bg: dk(
                context,
                const Color(0xFFE1F0FE),
                const Color.fromRGBO(4, 133, 247, 0.18),
              ),
              radius: BorderRadius.circular(22),
              child: hrow(
                [hsvg(dk(context, Svgs.s404, Svgs.s405), w: 22, h: 22)],
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
                    '选择会员',
                    style: hts(
                      16,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w600,
                      lh: 22,
                    ),
                  ),
                  Text(
                    '输入车牌、手机号或姓名查找',
                    style: hts(
                      12,
                      dk(
                        context,
                        const Color(0xFF52525B),
                        const Color(0xFFA8A8B3),
                      ),
                      lh: 17,
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.stretch,
                gap: 2,
              ),
            ),
            hsvg(dk(context, Svgs.s406, Svgs.s407), w: 18, h: 18),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.center,
          gap: 12,
        ),
      ),
    );
  }
}

class _RechargeMemberCard extends StatelessWidget {
  final WalletController c;
  const _RechargeMemberCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final m = c.memberView;
    return hbox(
      bg: dk(context, const Color(0xFF18181B), const Color(0xFF1F1F23)),
      radius: BorderRadius.circular(28),
      pad: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      clip: true,
      border: _darkCardBorder(context),
      child: hstack(
        hcol(
          [
            hrow(
              [
                hbox(
                  w: 36,
                  h: 36,
                  bg: const Color(0xFFF5D78E),
                  radius: BorderRadius.circular(18),
                  align: Alignment.center,
                  child: Text(
                    m.avatar,
                    style: hts(
                      14,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${m.name} ',
                          style: hts(
                            15,
                            const Color(0xFFFAFAFA),
                            w: FontWeight.w500,
                            lh: 22,
                          ),
                        ),
                        TextSpan(
                          text: '· ${m.maskedPhone}',
                          style: hts(
                            12,
                            dk(
                              context,
                              const Color(0xFFA1A1AA),
                              const Color(0xFF80808A),
                            ),
                            lh: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                hbox(
                  bg: const Color(0xFFF5D78E),
                  radius: BorderRadius.circular(10),
                  pad: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: Text(
                    m.levelMember,
                    style: hts(
                      11,
                      dk(
                        context,
                        const Color(0xFF18181B),
                        const Color(0xFFFAFAFA),
                      ),
                      w: FontWeight.w600,
                      lh: 20,
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => c.chooseMember(context),
                  child: hbox(
                    bg: dk(
                      context,
                      const Color.fromRGBO(255, 255, 255, 0.14),
                      const Color.fromRGBO(9, 9, 11, 0.92),
                    ),
                    radius: BorderRadius.circular(10),
                    pad: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                    child: Text(
                      '更换',
                      style: hts(
                        12,
                        const Color(0xFFFAFAFA),
                        w: FontWeight.w500,
                        lh: 20,
                      ),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 10,
            ),
            hrow(
              [
                Expanded(
                  flex: 1,
                  child: hcol(
                    [
                      Text(
                        '当前余额',
                        style: hts(
                          12,
                          dk(
                            context,
                            const Color(0xFFA1A1AA),
                            const Color(0xFF80808A),
                          ),
                          lh: 16,
                        ),
                      ),
                      Text(
                        m.balanceText,
                        style: hts(
                          24,
                          const Color(0xFFFAFAFA),
                          w: FontWeight.w600,
                          lh: 30,
                          tab: true,
                        ),
                      ),
                    ],
                    main: MainAxisAlignment.start,
                    cross: CrossAxisAlignment.stretch,
                    gap: 2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                  child: hsvg(dk(context, Svgs.s325, Svgs.s326), w: 20, h: 20),
                ),
                hcol(
                  [
                    Text(
                      '充值后',
                      style: hts(
                        12,
                        dk(
                          context,
                          const Color(0xFFA1A1AA),
                          const Color(0xFF80808A),
                        ),
                        lh: 16,
                      ),
                    ),
                    Text(
                      c.afterText,
                      style: hts(
                        24,
                        const Color(0xFFF5D78E),
                        w: FontWeight.w600,
                        lh: 30,
                        tab: true,
                      ),
                    ),
                  ],
                  main: MainAxisAlignment.start,
                  cross: CrossAxisAlignment.end,
                  gap: 2,
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.end,
              gap: 12,
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 14,
        ),
        const [],
        behind: [
          Positioned(
            right: -100,
            bottom: -128,
            child: hsvg(Svgs.s323, w: 220, h: 220),
          ),
        ],
      ),
    );
  }
}

class _CardMemberCard extends StatelessWidget {
  final WalletController c;
  const _CardMemberCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final m = c.memberView;
    return hbox(
      bg: dk(context, const Color(0xFF18181B), const Color(0xFF1F1F23)),
      radius: BorderRadius.circular(24),
      pad: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      border: _darkCardBorder(context),
      child: hrow(
        [
          hbox(
            w: 40,
            h: 40,
            bg: const Color(0xFFF5D78E),
            radius: BorderRadius.circular(20),
            align: Alignment.center,
            child: Text(
              m.avatar,
              style: hts(
                16,
                dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                w: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: hcol(
              [
                Text(
                  m.name,
                  style: hts(
                    16,
                    const Color(0xFFFAFAFA),
                    w: FontWeight.w600,
                    lh: 22,
                  ),
                ),
                Text(
                  '${m.maskedPhone} · ${m.plate}',
                  style: hts(
                    12,
                    dk(
                      context,
                      const Color(0xFFA1A1AA),
                      const Color(0xFF80808A),
                    ),
                    lh: 17,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 2,
            ),
          ),
          hbox(
            bg: const Color(0xFFF5D78E),
            radius: BorderRadius.circular(9),
            pad: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Text(
              m.levelMember,
              style: hts(
                11,
                dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 18,
              ),
              softWrap: false,
              maxLines: 1,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => c.chooseMember(context),
            child: hbox(
              bg: dk(
                context,
                const Color.fromRGBO(255, 255, 255, 0.14),
                const Color.fromRGBO(9, 9, 11, 0.92),
              ),
              radius: BorderRadius.circular(9),
              pad: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Text(
                '更换',
                style: hts(
                  12,
                  const Color(0xFFFAFAFA),
                  w: FontWeight.w500,
                  lh: 18,
                ),
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    );
  }
}

class _MiddleSection extends StatelessWidget {
  final WalletController c;
  final int tab;
  final bool hasMember;
  const _MiddleSection({
    required this.c,
    required this.tab,
    required this.hasMember,
  });

  @override
  Widget build(BuildContext context) {
    final err = c.errors[tab];
    if (!c.ready.contains(tab)) {
      if (err != null) {
        return hbox(
          bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(24),
          shadow: _cardShadow(context),
          pad: const EdgeInsets.all(20),
          child: ErrorView(
            error: AppError.from(err),
            onRetry: () => c.ensureTabLoaded(tab, force: true),
          ),
        );
      }
      return const SkeletonList(count: 2);
    }

    final body = tab == 0
        ? _RechargeSection(c: c, readOnly: !hasMember)
        : _PackageSection(c: c, hasMember: hasMember);

    if (hasMember) return body;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => c.chooseMember(context),
      child: IgnorePointer(child: hbox(opacity: .45, child: body)),
    );
  }
}

class _RechargeSection extends StatelessWidget {
  final WalletController c;
  final bool readOnly;
  const _RechargeSection({required this.c, required this.readOnly});

  Widget _presetCard(
    BuildContext context,
    SelCtrl selection,
    int index, {
    String? badge,
  }) {
    Widget content = hcol(
      [
        Text(
          c.amountLabel(index),
          style: hts(
            20,
            dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
            w: FontWeight.w600,
            lh: 28,
          ),
        ),
        Text(
          c.giftLabel(index),
          style: hts(
            12,
            dk(context, const Color(0xFF2B7745), const Color(0xFF5FD48C)),
            w: FontWeight.w500,
            lh: 16,
          ),
        ),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 4,
    );

    if (badge != null) {
      content = hstack(content, [
        Positioned(
          top: -22,
          right: -4,
          child: hbox(
            bg: dk(context, const Color(0xFF18181B), const Color(0xFF1F1F23)),
            radius: BorderRadius.circular(9),
            pad: const EdgeInsets.fromLTRB(7, 0, 7, 0),
            child: Text(
              badge,
              style: hts(
                11,
                const Color(0xFFFFFFFF),
                w: FontWeight.w600,
                lh: 18,
              ),
            ),
          ),
        ),
      ]);
    }

    return Expanded(
      flex: 1,
      child: HSel(
        ctrl: selection,
        index: index,
        on: hbox(
          bg: dk(
            context,
            const Color(0xFFF3F9FF),
            const Color.fromRGBO(4, 133, 247, 0.1),
          ),
          radius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF0485F7), width: 2),
          pad: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: content,
        ),
        off: hbox(
          bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(20),
          shadow: _cardShadow(context),
          pad: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: content,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleSelection(
      index: c.presetIndex,
      onChanged: c.selectPreset,
      builder: (context, selection) => hcol([
        hrow(
          [
            _presetCard(context, selection, 0),
            _presetCard(context, selection, 1, badge: '最多人选'),
          ],
          cross: CrossAxisAlignment.stretch,
          gap: 10,
          intrinsic: true,
          min: false,
        ),
        hrow(
          [
            _presetCard(context, selection, 2),
            _presetCard(context, selection, 3),
          ],
          cross: CrossAxisAlignment.stretch,
          gap: 10,
          intrinsic: true,
          min: false,
        ),
        hbox(
          h: 52,
          bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(20),
          shadow: _cardShadow(context),
          pad: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: hrow(
            [
              Text(
                '自定义金额',
                style: hts(
                  14,
                  dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                  lh: 20,
                ),
              ),
              Expanded(
                child: readOnly
                    ? Text(
                        '输入金额，不享赠送',
                        textAlign: TextAlign.right,
                        style: hts(
                          14,
                          dk(
                            context,
                            const Color(0xFF71717A),
                            const Color(0xFF9A9AA3),
                          ),
                          lh: 20,
                        ),
                      )
                    : AppTextInput(
                        controller: c.custom,
                        style: hts(
                          14,
                          dk(
                            context,
                            const Color(0xFF18181B),
                            const Color(0xFFFAFAFA),
                          ),
                          lh: 20,
                        ),
                        hint: '输入金额，不享赠送',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        align: TextAlign.right,
                      ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.center,
            gap: 10,
          ),
        ),
      ], gap: 10),
    );
  }
}

class _PackageSection extends StatelessWidget {
  final WalletController c;
  final bool hasMember;
  const _PackageSection({required this.c, required this.hasMember});

  @override
  Widget build(BuildContext context) {
    return hcol(
      [
        hbox(
          bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          radius: BorderRadius.circular(24),
          shadow: _cardShadow(context),
          pad: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: hcol(
            [
              Text(
                '选择套餐',
                style: hts(
                  15,
                  dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                  w: FontWeight.w600,
                  lh: 22,
                ),
              ),
              PackageChoices(
                packages: c.packages,
                selectedId: c.packageId,
                onSelected: c.selectPackage,
                limit: 3,
                readOnly: !hasMember,
              ),
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasMember ? () => c.choosePackage(context) : null,
                  child: Text(
                    c.saleAll,
                    style: hts(13, const Color(0xFF0485F7)),
                  ),
                ),
              ),
            ],
            main: MainAxisAlignment.start,
            cross: CrossAxisAlignment.stretch,
            gap: 14,
          ),
        ),
        if (hasMember) _PackagePriceSummary(c: c),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 16,
    );
  }
}

class _PackagePriceSummary extends StatelessWidget {
  final WalletController c;
  const _PackagePriceSummary({required this.c});

  Widget _line(
    BuildContext context,
    String label,
    String value, {
    bool discount = false,
    bool bold = false,
  }) {
    return hbox(
      minH: 54,
      pad: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: hrow(
        [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: hts(
                14,
                dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
                lh: 20,
              ),
            ),
          ),
          Text(
            value,
            style: hts(
              bold ? 20 : 15,
              discount
                  ? dk(
                      context,
                      const Color(0xFF2B7745),
                      const Color(0xFF5FD48C),
                    )
                  : dk(
                      context,
                      const Color(0xFF18181B),
                      const Color(0xFFFAFAFA),
                    ),
              w: bold ? FontWeight.w600 : FontWeight.w400,
              lh: bold ? 28 : 22,
            ),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.center,
        gap: 12,
      ),
    );
  }

  Widget _divider(BuildContext context) => hbox(
    h: 1,
    bg: dk(context, const Color(0xFFEFEFF1), const Color(0xFF2A2A2E)),
    margin: const EdgeInsets.fromLTRB(16, 0, 0, 0),
  );

  @override
  Widget build(BuildContext context) {
    return hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: BorderRadius.circular(24),
      shadow: _cardShadow(context),
      pad: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: hcol(
        [
          _line(context, '原价', c.saleOriginal),
          _divider(context),
          _line(context, '套餐优惠', c.saleSaving, discount: true),
          _divider(context),
          _line(context, '应收', c.saleDue, bold: true),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 0,
      ),
    );
  }
}

class _PayMethodCard extends StatelessWidget {
  final WalletController c;
  final bool disabled;
  const _PayMethodCard({required this.c, required this.disabled});

  static final _options = [
    ('微信', Svgs.s327, Svgs.s328),
    ('支付宝', Svgs.s330, Svgs.s329),
    ('现金', Svgs.s332, Svgs.s331),
  ];

  Widget _tile(
    BuildContext context,
    SelCtrl selection,
    int index,
    String label,
    String onIcon,
    String offIcon,
  ) {
    return Expanded(
      flex: 1,
      child: HSel(
        ctrl: selection,
        index: index,
        on: hbox(
          h: 64,
          bg: dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
          radius: BorderRadius.circular(16),
          child: hcol(
            [
              hsvg(dk(context, onIcon, offIcon), w: 20, h: 20),
              Text(
                label,
                style: hts(
                  13,
                  dk(context, const Color(0xFFFAFAFA), const Color(0xFF18181B)),
                  w: FontWeight.w500,
                  lh: 18,
                ),
              ),
            ],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            gap: 4,
            min: false,
          ),
        ),
        off: hbox(
          h: 64,
          bg: dk(context, const Color(0xFFF4F4F5), const Color(0xFF27272A)),
          radius: BorderRadius.circular(16),
          child: hcol(
            [
              hsvg(dk(context, offIcon, onIcon), w: 20, h: 20),
              Text(
                label,
                style: hts(
                  13,
                  dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                  lh: 18,
                ),
              ),
            ],
            main: MainAxisAlignment.center,
            cross: CrossAxisAlignment.center,
            gap: 4,
            min: false,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: BorderRadius.circular(24),
      shadow: _cardShadow(context),
      pad: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: hcol(
        [
          Text(
            '收款方式',
            style: hts(
              15,
              dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 22,
            ),
          ),
          SingleSelection(
            index: c.method,
            onChanged: c.selectMethod,
            builder: (context, selection) => hrow(
              [
                for (var i = 0; i < _options.length; i++)
                  _tile(
                    context,
                    selection,
                    i,
                    _options[i].$1,
                    _options[i].$2,
                    _options[i].$3,
                  ),
              ],
              cross: CrossAxisAlignment.stretch,
              gap: 8,
              intrinsic: true,
              min: false,
            ),
          ),
          hrow(
            [
              Expanded(
                flex: 1,
                child: Text(
                  '经办人',
                  style: hts(
                    13,
                    dk(
                      context,
                      const Color(0xFF52525B),
                      const Color(0xFFA8A8B3),
                    ),
                    lh: 18,
                  ),
                ),
              ),
              hLiveText(
                (p) => p.live ? p.operatorText : '—',
                hts(
                  13,
                  dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
                  w: FontWeight.w500,
                  lh: 18,
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
    );

    if (!disabled) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => c.chooseMember(context),
      child: IgnorePointer(child: hbox(opacity: .45, child: card)),
    );
  }
}

class _BottomDock extends StatelessWidget {
  final WalletController c;
  final int tab;
  final bool hasMember;
  const _BottomDock({
    required this.c,
    required this.tab,
    required this.hasMember,
  });

  @override
  Widget build(BuildContext context) {
    return HBottomDock(
      child: hbox(
        bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
        shadow: dk(
          context,
          [
            const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.04),
              offset: Offset(0, -8),
              blurRadius: 24,
            ),
            const BoxShadow(color: Color(0xFFE8E8EA), offset: Offset(0, -1)),
          ],
          [const BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)],
        ),
        pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
        child: !hasMember
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => c.chooseMember(context),
                child: hbox(
                  h: 50,
                  bg: dk(
                    context,
                    const Color(0xFFE4E4E7),
                    const Color(0xFF3A3A40),
                  ),
                  radius: BorderRadius.circular(25),
                  align: Alignment.center,
                  child: Text(
                    '请先选择会员',
                    style: hts(
                      15,
                      dk(
                        context,
                        const Color(0xFFA1A1AA),
                        const Color(0xFF80808A),
                      ),
                      w: FontWeight.w600,
                      lh: 22,
                    ),
                  ),
                ),
              )
            : hrow(
                [
                  Expanded(
                    flex: 1,
                    child: hcol(
                      [
                        Text(
                          tab == 0 ? c.payLine : '应收',
                          style: hts(
                            12,
                            dk(
                              context,
                              const Color(0xFF71717A),
                              const Color(0xFF9A9AA3),
                            ),
                            lh: 16,
                          ),
                        ),
                        Text(
                          tab == 0 ? c.amountText : c.saleDue,
                          style: hts(
                            24,
                            dk(
                              context,
                              const Color(0xFF18181B),
                              const Color(0xFFFAFAFA),
                            ),
                            w: FontWeight.w600,
                            lh: 30,
                            ls: -0.48,
                            tab: true,
                          ),
                        ),
                      ],
                      main: MainAxisAlignment.start,
                      cross: CrossAxisAlignment.stretch,
                      gap: 2,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => c.submit(context, sale: tab == 1),
                    child: hbox(
                      h: 50,
                      bg: const Color(0xFF0485F7),
                      radius: BorderRadius.circular(25),
                      pad: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                      child: Align(
                        alignment: Alignment.center,
                        widthFactor: 1,
                        child: hBusy(
                          c.actionKey,
                          Text(
                            '确认收款',
                            style: hts(
                              16,
                              const Color(0xFFFFFFFF),
                              w: FontWeight.w600,
                              lh: 24,
                            ),
                          ),
                          style: hts(
                            16,
                            const Color(0xFFFFFFFF),
                            w: FontWeight.w600,
                            lh: 24,
                          ),
                          label: '提交中…',
                        ),
                      ),
                    ),
                  ),
                ],
                main: MainAxisAlignment.start,
                cross: CrossAxisAlignment.center,
                gap: 12,
              ),
      ),
    );
  }
}

List<BoxShadow> _tabShadow(BuildContext context) => dk(
  context,
  const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ],
  const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)],
);

List<BoxShadow> _cardShadow(BuildContext context) => dk(
  context,
  const [
    BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.06), blurRadius: 1),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ],
  const [BoxShadow(color: Color(0xFF26262B), spreadRadius: 1)],
);

Border? _darkCardBorder(BuildContext context) =>
    dk(context, null, Border.all(color: const Color(0xFF2E2E33), width: 1));
