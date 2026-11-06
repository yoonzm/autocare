import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/region_dictionary.dart';
import 'package:autocare_merchant/kit/async_kit.dart';
import 'package:autocare_merchant/kit/pickers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegionApi extends MerchantApi {
  bool fail = true;
  int calls = 0;
  @override
  Future<Map<String, dynamic>> invoke(
    Map<String, dynamic> body, {
    Duration timeout = kRequestTimeout,
    String? requestId,
  }) async {
    calls++;
    if (fail) throw Exception('offline');
    return {
      'version': 'test',
      'items': [
        {'code': '330000', 'name': '浙江省', 'parent_code': null, 'level': 1},
        {'code': '330100', 'name': '杭州市', 'parent_code': '330000', 'level': 2},
        {'code': '330200', 'name': '宁波市', 'parent_code': '330000', 'level': 2},
        {'code': '330106', 'name': '西湖区', 'parent_code': '330100', 'level': 3},
        {'code': '310000', 'name': '上海市', 'parent_code': null, 'level': 1},
        {'code': '310100', 'name': '上海市', 'parent_code': '310000', 'level': 2},
      ],
    };
  }
}

void main() {
  testWidgets('省市选择：错误重试、回显、联动、取消、缓存与深色模式', (t) async {
    SharedPreferences.setMockInitialValues({});
    final original = merchantApi;
    final api = RegionApi();
    merchantApi = api;
    addTearDown(() => merchantApi = original);
    CitySelection? selected;
    Future<void> open({bool dark = false}) async {
      await t.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: dark ? Brightness.dark : Brightness.light,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  selected = await pickCity(context, '浙江省 · 宁波市');
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
    }

    await open();
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('确定'), findsNothing);
    api.fail = false;
    await t.tap(find.text('重试'));
    await t.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsNWidgets(2));
    expect(find.text('西湖区'), findsNothing);
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(selected?.city.code, '330200');
    expect(selected?.province.code, '330000');
    await open(dark: true);
    expect(api.calls, 2); // The second opening uses backend-derived cache.
    final picker = t.widget<CupertinoPicker>(
      find.byType(CupertinoPicker).first,
    );
    picker.scrollController!.jumpToItem(1);
    await t.pumpAndSettle();
    await t.tap(find.text('确定'));
    await t.pumpAndSettle();
    expect(selected?.label, '上海市 · 上海市');
    await open();
    await t.tap(find.text('取消'));
    await t.pumpAndSettle();
    expect(selected, isNull);
    expect(t.takeException(), isNull);
    final dictionary = await RegionDictionary.load();
    expect(dictionary.children('330100').single.name, '西湖区');
  });
}
