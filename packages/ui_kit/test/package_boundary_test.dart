import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> _sources() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  test('组件库的依赖图里没有后端 SDK', () {
    final config =
        jsonDecode(File('.dart_tool/package_config.json').readAsStringSync())
            as Map;
    final packages = (config['packages'] as List)
        .cast<Map>()
        .map((p) => p['name'])
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

  test('组件库不引用任何应用或业务代码', () {
    for (final file in _sources()) {
      final text = file.readAsStringSync();
      for (final bad in [
        'package:autocare_admin',
        'package:autocare_merchant',
        'package:supabase',
        'package:autocare_supabase_adapter',
      ]) {
        expect(text.contains(bad), isFalse, reason: '${file.path} 引用了 $bad');
      }
    }
  });

  test('颜色只从令牌取：除令牌文件外不写色值', () {
    for (final file in _sources()) {
      if (file.path.endsWith('app_tokens.dart')) continue;
      final text = file.readAsStringSync();
      expect(
        RegExp(r'Color\(0x').hasMatch(text),
        isFalse,
        reason: '${file.path} 里写了色值',
      );
      expect(
        RegExp(r'Colors\.(?!transparent)\w+').hasMatch(text),
        isFalse,
        reason: '${file.path} 里用了 Colors.*',
      );
    }
  });

  test('组件不开放任意颜色、字号、圆角参数', () {
    // 封装约定：定制只能走语义参数，没有 color / radius / textStyle / style 这类自由样式参数。
    final forbidden = RegExp(
      r'^\s+final\s+(Color|TextStyle|ButtonStyle|BorderRadius|double\s+(radius|height|fontSize))\??\s',
      multiLine: true,
    );
    for (final file in _sources()) {
      if (file.path.endsWith('app_tokens.dart')) continue;
      // 私有实现类的内部字段不算公开参数。
      final text = file.readAsStringSync();
      final publicOnly = text.split(RegExp(r'^class _', multiLine: true)).first;
      expect(
        forbidden.hasMatch(publicOnly),
        isFalse,
        reason: '${file.path} 的公开组件带有自由样式参数',
      );
    }
  });
}
