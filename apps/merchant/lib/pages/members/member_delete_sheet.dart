import '../../kit/buttons.dart';
import '../../kit/async_kit.dart';
import '../../backend/merchant_api.dart';
import '../../routes.dart' show openRoute;
import 'member_events.dart';
import 'member_view.dart';

import 'package:flutter/material.dart';

import '../../kit/kit.dart';

class MemberDeleteSheet extends StatelessWidget {
  final Map<String, dynamic>? member;
  const MemberDeleteSheet({super.key, this.member});

  Future<void> _delete(BuildContext context) =>
      runBusy('member-delete-${identityHashCode(context)}', () async {
        final id = member?['id'];
        if (id == null) return;
        try {
          await merchantApi.delete('members', '$id');
          memberChanged.value++;
          if (context.mounted) openRoute(context, 'Members');
        } catch (e) {
          if (context.mounted) AppToast.error(context, e);
        }
      });

  @override
  Widget build(BuildContext context) {
    if (member?['id'] == null) {
      return ErrorView(
        error: const AppError('请先选择会员', type: AppErrorType.notFound),
      );
    }
    final m = MemberView(member!);
    return AsyncActionScope(
      actionKey: 'member-delete-${identityHashCode(context)}',
      child: hbox(
        bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
        radius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
        pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
        child: hcol(
          [
            Align(
              alignment: Alignment.topCenter,
              child: hbox(
                w: 40,
                h: 5,
                bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
                radius: BorderRadius.circular(3),
              ),
            ),
            Text(
              '删除会员 ${m.name}？',
              style: hts(
                20,
                dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
                w: FontWeight.w600,
                lh: 28,
              ),
            ),
            Text(
              '将永久删除会员 ${m.name} 的档案、车辆与次卡。以下数据无法随会员一并删除：',
              style: hts(
                13,
                dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                lh: 20,
              ),
            ),
            hcol(
              [
                Text(
                  '· 历史订单与财务流水会保留，会员显示为“已删除会员”',
                  style: hts(
                    13,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    lh: 19,
                  ),
                ),
                Text(
                  '· 储值余额将作废，请先线下退还或转为消费',
                  style: hts(
                    13,
                    dk(context, Color(0xFFA43433), Color(0xFFFF7B7E)),
                    lh: 19,
                  ),
                ),
                Text(
                  '· 删除后无法恢复，也无法再收到微信通知',
                  style: hts(
                    13,
                    dk(context, Color(0xFF52525B), Color(0xFFA8A8B3)),
                    lh: 19,
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 8,
            ),
            hrow(
              [
                Expanded(
                  flex: 10,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: AppButton(
                      label: '再想想',
                      kind: AppButtonKind.secondary,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
                Expanded(
                  flex: 14,
                  child: UnconstrainedBox(
                    alignment: Alignment.topLeft,
                    constrainedAxis: Axis.horizontal,
                    child: ActionButton(
                      actionKey: 'member-delete-${identityHashCode(context)}',
                      label: '确认删除',
                      kind: AppButtonKind.danger,
                      size: AppButtonSize.large,
                      expanded: true,
                      onPressed: () => _delete(context),
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.stretch,
              gap: 10,
              intrinsic: true,
            ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 14,
        ),
      ),
    );
  }
}
