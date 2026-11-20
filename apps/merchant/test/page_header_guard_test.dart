import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 约定：用 HPage 的页面，顶部栏必须走 `header:`（固定、不随内容滚动）。
/// 下面这些页面本来就没有顶部栏（完成页、全屏相机、员工端认证/首页大标题），不受约束。
const noHeaderPages = {
  'account/forgot_done_page.dart',
  'inventory/scan_product_bound_template.dart',
  'staff_app/st_auth_fail_template.dart',
  'staff_app/st_auth_template.dart',
  'staff_app/st_identity_template.dart',
  'staff_app/st_no_perm_template.dart',
  'staff_app/st_home_template.dart',
  'staff_app/st_front_home_template.dart',
};

void main() {
  test('HPage 页面的顶部栏都固定在滚动区外', () {
    final bad = <String>[];
    for (final f in Directory('lib/pages').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final rel = f.path.replaceAll('\\', '/').replaceFirst('lib/pages/', '');
      final s = f.readAsStringSync();
      if (!s.contains('HPage(')) continue;
      if (noHeaderPages.contains(rel)) continue;
      final at = s.indexOf('HPage(');
      final head = s.substring(at, (at + 600).clamp(0, s.length));
      if (!head.contains('header:')) bad.add(rel);
    }
    expect(bad, isEmpty, reason: '这些页面的顶部栏还在滚动内容里：$bad');
  });
}
