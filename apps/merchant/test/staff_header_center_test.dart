import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_merchant/kit/page_header.dart';
import 'package:autocare_merchant/theme.dart';

void main() {
  Future<double> centerOf(
    WidgetTester t,
    AppPageHeader header,
    String title,
  ) async {
    t.view.physicalSize = const Size(390, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
            child: header,
          ),
        ),
      ),
    );
    return t.getCenter(find.text(title)).dx;
  }

  testWidgets('标题在页面正中：返回、无左侧按钮两种头部都一样', (t) async {
    C.dark = false;
    expect(await centerOf(t, const AppPageHeader(title: '今日到店'), '今日到店'), 195);
    expect(
      await centerOf(
        t,
        const AppPageHeader(title: '我的任务', leading: AppHeaderLeading.none),
        '我的任务',
      ),
      195,
    );
  });

  testWidgets('右侧是变宽按钮（保存、挂单、87 宽按钮）时标题仍在正中；很长的标题省略，不压住按钮', (t) async {
    C.dark = false;
    for (final w in [87.0, 60.0, 120.0]) {
      expect(
        await centerOf(
          t,
          AppPageHeader(
            title: '编辑项目',
            trailing: SizedBox(width: w, height: 44),
          ),
          '编辑项目',
        ),
        195,
        reason: '右侧 $w 宽',
      );
    }
    await centerOf(
      t,
      AppPageHeader(
        title: '一个非常非常非常非常非常非常长的页面标题',
        trailing: const SizedBox(width: 120, height: 44),
      ),
      '一个非常非常非常非常非常非常长的页面标题',
    );
    final title = t.getRect(find.text('一个非常非常非常非常非常非常长的页面标题'));
    expect(title.right, lessThanOrEqualTo(390 - 20 - 120 - 8 + 0.5));
    expect(title.left, greaterThanOrEqualTo(20 + 120 + 8 - 0.5));
  });

  test('员工端页面不再用 87 宽的占位撑偏标题（设计稿里左右各 87，迁移后左侧只有 44）', () {
    final offenders = <String>[];
    for (final f in Directory('lib/pages/staff_app').listSync()) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (RegExp(r'trailing:\s*hbox\(w:\s*87\)')
          .hasMatch(f.readAsStringSync())) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty, reason: '标题会整体偏左 21.5：$offenders');
  });
}
