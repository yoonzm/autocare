import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:autocare_merchant/backend/app_cache.dart';
import 'package:autocare_merchant/kit/async_kit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() {
    busyActions.value = const {};
    // Widget tests have no installed app or native cache directory.
    PackageInfo.setMockInitialValues(
      appName: '汽美管家',
      packageName: 'com.yoonzm.autocare.merchant',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    AppCache.readFiles = () async => (images: 0, temporary: 0);
  });
  await testMain();
}
