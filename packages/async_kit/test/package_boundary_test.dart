import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shared UI dependency graph contains no backend SDK', () {
    final config = jsonDecode(
      File('.dart_tool/package_config.json').readAsStringSync(),
    ) as Map;
    final packages = (config['packages'] as List)
        .cast<Map>()
        .map((package) => package['name'])
        .toSet();
    expect(
      packages.intersection({
        'supabase_flutter',
        'supabase',
        'gotrue',
        'functions_client',
      }),
      isEmpty,
    );
  });
  test(
    'shared UI does not know merchant routes or business skeleton templates',
    () {
      final source = Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .map((file) => file.readAsStringSync())
          .join('\n');
      for (final coupling in [
        'asyncActionKeys',
        'Recharge>RechargeSuccess',
        'class SkeletonServiceList',
        'class SkeletonTierList',
        'class SkeletonDataPage',
        'class C {',
        'Supabase',
        'supabase_flutter',
        '请联系店主',
      ]) {
        expect(
          source.contains(coupling),
          isFalse,
          reason: 'Application/backend coupling leaked into core: $coupling',
        );
      }
    },
  );
}
