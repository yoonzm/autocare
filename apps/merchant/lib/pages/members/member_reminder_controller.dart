import 'package:flutter/material.dart';

import '../../backend/merchant_api.dart';
import '../../kit/async_kit.dart';
import '../../routes.dart' show openRoute;
import 'member_events.dart';
import 'member_route_data.dart';

class FollowView {
  final Map<String, dynamic> data;
  const FollowView(this.data);
  int get pending => (data['pending'] as num?)?.toInt() ?? 0;
  int get done => (data['done_today'] as num?)?.toInt() ?? 0;
  Map<String, dynamic> get counts => Map.from(data['counts'] as Map? ?? {});
  int count(String kind) => (counts[kind] as num?)?.toInt() ?? 0;
  int get all => (data['items'] as List? ?? []).length;
  String get chipAll => '全部 $all';
  String get chipExpire => '次卡到期 ${count('次卡到期')}';
  // TODO: 养护到期需要施工记录计算；尚无 reminders 返回值，不能伪造提醒。
  String get chipCare => '养护到期 0';
  String get chipBirthday => '生日 ${count('生日')}';
  String get chipSleep => '沉睡 ${count('沉睡客户')}';
  double get fraction => done + pending == 0
      ? 0
      : (done / (done + pending)).clamp(0, 1).toDouble();
}

class MemberReminderController extends ChangeNotifier {
  static const kinds = [null, '次卡到期', '养护到期', '生日', '沉睡客户'];
  Map<String, dynamic> data = {};
  int tab = 0;
  bool disposed = false;
  String get actionKey => 'member-reminders-${identityHashCode(this)}';
  FollowView get view => FollowView(data);
  List<Map<String, dynamic>> get items => [
    for (final row in (data['items'] as List? ?? []).cast<Map>())
      if (kinds[tab] == null || row['kind'] == kinds[tab])
        Map<String, dynamic>.from(row),
  ];
  void apply(Map<String, dynamic> value) {
    if (!disposed) data = Map.unmodifiable(value);
  }

  void selectTab(int index) {
    if (!disposed) {
      tab = index;
      notifyListeners();
    }
  }

  String markKey(String memberId) => '$actionKey-mark-$memberId';
  Future<void> mark(
    BuildContext context,
    String memberId,
    VoidCallback reload,
  ) => runBusy(markKey(memberId), () async {
    try {
      await merchantApi.markFollowedUp(memberId);
      memberChanged.value++;
      if (!disposed) reload();
    } catch (e) {
      if (context.mounted && !disposed) AppToast.error(context, e);
    }
  });
  Future<void> openMember(BuildContext context, String memberId) =>
      runBusy('$actionKey-open-$memberId', () async {
        try {
          final member = await merchantApi.member(memberId);
          if (context.mounted && !disposed) {
            openRoute(
              context,
              'MemberDetail',
              arguments: MemberRouteData(member: member),
            );
          }
        } catch (e) {
          if (context.mounted && !disposed) AppToast.error(context, e);
        }
      });
  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}
