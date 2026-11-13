import 'dart:io';

import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/pages/members/member_events.dart';
import 'package:autocare_merchant/pages/members/members_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'members_test.dart' show MemberFakeApi;

void main() {
  test('生产标签没有旧实现、双份标签布局或原时段标记', () {
    expect(File('lib/widgets/choice_chip_group.dart').existsSync(), isFalse);
    for (final file
        in Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      expect(
        RegExp(r'\b(ChoiceChipGroup|ChoiceChipItem|HChipGroup|ChipTabs)\b')
            .hasMatch(source),
        isFalse,
        reason: file.path,
      );
    }
    expect(
      File('lib/pages/booking/reschedule_slots.dart').readAsStringSync(),
      isNot(contains('isOriginal')),
    );
  });
  testWidgets('会员分类重复点击不重查，卡种删除后回到全部并重新读取', (t) async {
    final original = merchantApi;
    final api = MemberFakeApi();
    merchantApi = api;
    addTearDown(() => merchantApi = original);
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(390, 900);
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(home: MembersPage()));
    await t.pumpAndSettle();
    final group = find.byType(AppChoiceGroup<String?>);
    expect(group, findsOneWidget);
    final gold = find.descendant(
      of: group,
      matching: find.textContaining('金卡'),
    );
    await t.tap(gold);
    await t.pumpAndSettle();
    expect(api.listCalls.last.tier, 't-gold');
    final count = api.listCalls.length;
    await t.tap(gold);
    await t.pumpAndSettle();
    expect(api.listCalls.length, count);
    api.tiers.removeWhere((tier) => tier['id'] == 't-gold');
    memberChanged.value++;
    await t.pumpAndSettle();
    expect(api.listCalls.last.tier, isNull);
    expect(t.widget<AppChoiceGroup<String?>>(group).selected, isNull);
    expect(
      find.descendant(of: group, matching: find.textContaining('金卡')),
      findsNothing,
    );
    // The independent follow-up entry still exists at the end of the scrolling strip.
    expect(find.textContaining('待回访'), findsWidgets);
  });
}
