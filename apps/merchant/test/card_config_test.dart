import 'package:autocare_ui_kit/autocare_ui_kit.dart' show AppSegmented;

import 'dart:async';

import 'package:autocare_merchant/backend/merchant_api.dart';
import 'package:autocare_merchant/backend/store_profile.dart';
import 'package:autocare_merchant/kit/kit.dart' show HSwitch;
import 'package:autocare_merchant/pages/catalog/card_tiers_live_page.dart';
import 'package:autocare_merchant/pages/catalog/card_tier_edit_page.dart';
import 'package:autocare_merchant/widgets/card_face.dart';
import 'package:autocare_merchant/widgets/color_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 会员卡种配置（不依赖其他模块的部分）都走真实后端。
class _Api extends MerchantApi {
  List<Map<String, dynamic>> cards = [];
  final saved = <Map<String, dynamic>>[];
  final ruleCalls = <({bool autoUpgrade, bool balanceRefundable})>[];
  bool autoUpgrade = true;
  bool balanceRefundable = false;
  Object? listError;
  Object? ruleError;
  Completer<void>? ruleGate;
  @override
  bool get hasSession => true;
  @override
  Future<List<Map<String, dynamic>>> list(String kind) async {
    if (listError != null) throw listError!;
    return cards;
  }

  @override
  Future<Map<String, dynamic>> save(
    String kind,
    Map<String, dynamic> values,
  ) async {
    saved.add(values);
    return {'item': values};
  }

  @override
  Future<({bool autoUpgrade, bool balanceRefundable})> cardRules() async =>
      (autoUpgrade: autoUpgrade, balanceRefundable: balanceRefundable);
  @override
  Future<void> saveCardRules({
    required bool autoUpgrade,
    required bool balanceRefundable,
  }) async {
    ruleCalls.add((
      autoUpgrade: autoUpgrade,
      balanceRefundable: balanceRefundable,
    ));
    await ruleGate?.future;
    if (ruleError != null) throw ruleError!;
    this.autoUpgrade = autoUpgrade;
    this.balanceRefundable = balanceRefundable;
  }
}

Map<String, dynamic> _card({
  String id = 'c1',
  String name = '黑金卡',
  num discount = 0.9,
  String color = 'black',
  num? recharge = 10000,
  num? cumulative = 30000,
  num multiplier = 2,
  String gift = '赠精致洗车 2 次',
  bool priority = true,
  String validity = '1y',
}) => {
  'id': id,
  'name': name,
  'discount': discount,
  'description': '',
  'active': true,
  'color': color,
  'upgrade_recharge': recharge,
  'upgrade_cumulative': cumulative,
  'points_multiplier': multiplier,
  'birthday_gift': gift,
  'priority_booking': priority,
  'validity': validity,
};

void main() {
  late MerchantApi original;
  late _Api api;
  Map<String, dynamic>? initial;
  setUp(() {
    original = merchantApi;
    api = _Api();
    merchantApi = api;
    initial = null;
    storeProfile.clear();
  });
  tearDown(() {
    merchantApi = original;
    storeProfile.clear();
  });

  void phone(WidgetTester t, {double h = 844}) {
    t.view.physicalSize = Size(390 * 3, h * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
  }

  Future<void> openEdit(WidgetTester t) async {
    phone(t, h: 1400);
    final old = FlutterError.onError;
    FlutterError.onError = (d) {
      if (!d.exceptionAsString().contains('overflowed')) old?.call(d);
    };
    addTearDown(() => FlutterError.onError = old);
    await t.pumpWidget(
      MaterialApp(
        initialRoute: 'CardTierEdit',
        onGenerateRoute: (s) => MaterialPageRoute(
          settings: s,
          builder: (_) => CardTierEditPage(initial: initial),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Finder field(String hint) => find.byWidgetPredicate(
    (w) => w is TextField && w.decoration?.hintText == hint,
  );

  Future<void> select(WidgetTester t, String current, String next) async {
    await t.ensureVisible(find.text(current).last);
    await t.tap(find.text(current).last);
    await t.pumpAndSettle();
    await t.tap(find.text(next).last);
    await t.pumpAndSettle();
  }

  group('编辑页读写真实字段', () {
    testWidgets('已有卡种：各项配置回显', (t) async {
      initial = _card();
      await openEdit(t);
      expect(t.widget<TextField>(field('请输入单次充值满')).controller!.text, '10000');
      expect(t.widget<TextField>(field('请输入累计消费满')).controller!.text, '30000');
      expect(find.text('2 倍'), findsOneWidget);
      expect(find.text('赠精致洗车 2 次'), findsWidgets);
      expect(t.widget<HSwitch>(find.byType(HSwitch)).initial, isTrue);
      // 预览显示名称和折扣
      expect(find.text('NO. 0000 0028 · 全场 9 折'), findsOneWidget);
    });

    testWidgets('新建卡种：默认值，升级条件为空并显示 placeholder', (t) async {
      initial = null;
      await openEdit(t);
      expect(t.widget<TextField>(field('请输入单次充值满')).controller!.text, isEmpty);
      expect(t.widget<TextField>(field('请输入累计消费满')).controller!.text, isEmpty);
      expect(find.text('1 倍'), findsOneWidget);
      expect(find.text('不赠送'), findsOneWidget);
      expect(t.widget<HSwitch>(find.byType(HSwitch)).value, isFalse);
      expect(find.text('卡种名称'), findsWidgets); // 预览里的占位名
    });

    testWidgets('卡面预览随名称实时变化，门店名来自当前门店', (t) async {
      storeProfile.apply({'name': '蓝鲸养护', 'phone': '+8613900000000'});
      initial = null;
      await openEdit(t);
      expect(find.text('蓝鲸养护'), findsOneWidget);
      await t.enterText(field('请输入卡种名称'), '至尊卡');
      await t.pump();
      expect(find.text('至尊卡'), findsWidgets);
    });

    testWidgets('普通会员是白色卡面：编辑时不选任何色块，保存后仍是白色', (t) async {
      initial = _card(
        name: '普通会员',
        color: 'white',
        discount: 1,
        recharge: null,
        cumulative: null,
        multiplier: 1,
        gift: '',
        priority: false,
        validity: 'forever',
      );
      await openEdit(t);
      expect(
        t.widget<CardColorChoices>(find.byType(CardColorChoices)).value,
        'white',
      ); // 普通会员配色是第 4 个系统默认配色
      expect(t.widget<CardPreview>(find.byType(CardPreview)).color, 'white');
      await t.tap(find.text('保存').first);
      await t.pump(const Duration(milliseconds: 800));
      expect(api.saved.single['color'], 'white');
      expect(api.saved.single['upgrade_recharge'], isNull);
      expect(api.saved.single['discount'], 1);
      await t.pump(const Duration(seconds: 3));
    });

    testWidgets('白色卡面的卡种可以改成别的颜色', (t) async {
      initial = _card(color: 'white');
      await openEdit(t);
      final sem = t.ensureSemantics();
      await t.tap(find.bySemanticsLabel('银卡配色'));
      await t.pumpAndSettle();
      expect(t.widget<CardPreview>(find.byType(CardPreview)).color, 'silver');
      sem.dispose();
    });

    testWidgets('选卡面颜色 / 有效期 / 预约优先：更新页面状态并刷新预览', (t) async {
      initial = _card(validity: 'forever', priority: false);
      await openEdit(t);
      final sem = t.ensureSemantics();
      expect(
        t.widget<CardColorChoices>(find.byType(CardColorChoices)).value,
        'black',
      );
      await t.tap(find.bySemanticsLabel('金卡配色'));
      await t.pumpAndSettle();
      expect(
        t.widget<CardPreview>(find.byType(CardPreview)).color,
        'champagne',
      );
      final segments = find.byType(AppSegmented<int>);
      expect(segments, findsOneWidget);
      await t.ensureVisible(find.text('1 年'));
      await t.tap(find.text('1 年'));
      await t.pumpAndSettle();
      expect(t.widget<AppSegmented<int>>(segments).selected, 1);
      await t.ensureVisible(find.byType(HSwitch));
      await t.tap(find.byType(HSwitch));
      await t.pumpAndSettle();
      expect(t.widget<HSwitch>(find.byType(HSwitch)).value, isTrue);
      sem.dispose();
    });

    testWidgets('积分倍率 / 生日礼的选择器可以打开，不再提示未接通', (t) async {
      initial = _card();
      await openEdit(t);
      await t.ensureVisible(find.text('2 倍'));
      await t.tap(find.text('2 倍'));
      await t.pumpAndSettle();
      expect(find.text('暂未接通'), findsNothing);
      expect(find.text('1.5 倍'), findsWidgets);
      await t.tap(find.text('3 倍').last);
      await t.pumpAndSettle();
      expect(find.text('3 倍'), findsOneWidget);
      await select(t, '赠精致洗车 2 次', '赠 50 元券');
      expect(find.text('赠 50 元券'), findsOneWidget);
      await select(t, '赠 50 元券', '不赠送');
      expect(find.text('不赠送'), findsOneWidget);
    });

    testWidgets('保存：所有配置一起提交', (t) async {
      initial = _card();
      await openEdit(t);
      await t.enterText(field('请输入单次充值满'), '8,000');
      await t.enterText(field('请输入累计消费满'), '');
      final semantics = t.ensureSemantics();
      await t.tap(find.bySemanticsLabel('银卡配色'));
      await t.pumpAndSettle();
      semantics.dispose();
      await select(t, '2 倍', '1.5 倍');
      await select(t, '赠精致洗车 2 次', '不赠送');
      await t.tap(find.text('保存').first);
      await t.pump(const Duration(milliseconds: 800));
      expect(api.saved, hasLength(1));
      final v = api.saved.single;
      expect(v['id'], 'c1');
      expect(v['name'], '黑金卡');
      expect(v['discount'], 0.9);
      expect(v['color'], 'silver');
      expect(v['upgrade_recharge'], 8000);
      expect(v['upgrade_cumulative'], isNull); // 留空 = 不按这一项升级
      expect(v['points_multiplier'], 1.5);
      expect(v['birthday_gift'], '');
      expect(v['priority_booking'], true);
      expect(v['validity'], '1y');
      await t.pump(const Duration(seconds: 3));
    });

    testWidgets('升级条件金额不合法：提示并且不提交', (t) async {
      initial = _card();
      await openEdit(t);
      await t.enterText(field('请输入单次充值满'), 'abc');
      await t.tap(find.text('保存').first);
      await t.pump(const Duration(milliseconds: 800));
      expect(find.text('请输入正确的单次充值满金额'), findsOneWidget);
      expect(api.saved, isEmpty);
      await t.pump(const Duration(seconds: 4));
    });
  });

  group('列表页', () {
    Future<void> openList(WidgetTester t, {double h = 844}) async {
      phone(t, h: h);
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      await t.pumpAndSettle();
    }

    testWidgets('卡片显示升级条件 / 积分倍率，颜色跟随所选卡面颜色', (t) async {
      api.cards = [
        _card(),
        _card(
          id: 'c2',
          name: '银卡',
          color: 'silver',
          recharge: null,
          cumulative: 3000,
          multiplier: 1,
          discount: 0.98,
        ),
        _card(
          id: 'c3',
          name: '海蓝卡',
          color: 'blue',
          recharge: null,
          cumulative: null,
        ),
      ];
      await openList(t, h: 1400);
      expect(find.text('充值 ¥10,000 / 累计消费 ¥30,000 · 积分 2 倍'), findsOneWidget);
      expect(find.text('累计消费 ¥3,000 · 积分 1 倍'), findsOneWidget);
      expect(find.text('无升级条件 · 积分 2 倍'), findsOneWidget);
      Color? bgOf(String name) {
        final box = find
            .ancestor(of: find.text(name), matching: find.byType(Container))
            .evaluate()
            .map((e) => (e.widget as Container).decoration)
            .whereType<BoxDecoration>()
            .firstWhere((d) => d.color != null);
        return box.color;
      }

      expect(bgOf('黑金卡'), const Color(0xFF18181B));
      expect(bgOf('银卡'), const Color(0xFFE4E4E7));
      expect(bgOf('海蓝卡'), const Color(0xFF0B5FD6));
    });

    testWidgets('白色卡面（普通会员）的列表样式', (t) async {
      api.cards = [_card(name: '普通会员', color: 'white', discount: 1)];
      await openList(t);
      final box = find
          .ancestor(of: find.text('普通会员'), matching: find.byType(Container))
          .evaluate()
          .map((e) => (e.widget as Container).decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.color != null);
      expect(box.color, const Color(0xFFFFFFFF));
      expect(find.text('原价'), findsOneWidget);
    });

    testWidgets('没有升级条件的卡显示卡种自己的说明（设计稿的普通会员）', (t) async {
      api.cards = [
        {
          ..._card(name: '普通会员', color: 'white', discount: 1),
          'upgrade_recharge': null,
          'upgrade_cumulative': null,
          'description': '扫码免费注册 · 消费累积积分',
        },
      ];
      await openList(t);
      expect(find.text('扫码免费注册 · 消费累积积分'), findsOneWidget);
    });

    testWidgets('折扣为 1 的卡种显示“原价”', (t) async {
      api.cards = [_card(discount: 1, name: '普通会员')];
      await openList(t);
      expect(find.text('原价'), findsOneWidget);
    });

    testWidgets('通用规则：有卡种才显示；加载中 / 没数据 / 失败时不显示', (t) async {
      // 空
      await openList(t);
      expect(find.text('还没有会员卡种'), findsOneWidget);
      expect(find.text('通用规则'), findsNothing);
      // 失败
      api.listError = const AppError.network();
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      await t.pumpAndSettle();
      expect(find.text('网络不太给力'), findsOneWidget);
      expect(find.text('通用规则'), findsNothing);
      // 有数据
      api.listError = null;
      api.cards = [_card()];
      await t.tap(find.text('重试'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      await t.pumpAndSettle();
      expect(find.text('通用规则'), findsOneWidget);
    });

    testWidgets('加载中不显示通用规则', (t) async {
      phone(t);
      api.cards = [_card()];
      await t.pumpWidget(const MaterialApp(home: CardTiersLivePage()));
      // 请求还没返回的这一帧
      expect(find.text('通用规则'), findsNothing);
      await t.pumpAndSettle();
      expect(find.text('通用规则'), findsOneWidget);
    });

    testWidgets('通用规则来自后端，开关保存到后端', (t) async {
      api.cards = [_card()];
      api.autoUpgrade = false;
      api.balanceRefundable = true;
      await openList(t);
      final switches = find.byType(HSwitch);
      expect(t.widget<HSwitch>(switches.at(0)).value, isFalse);
      expect(t.widget<HSwitch>(switches.at(1)).value, isTrue);

      await t.ensureVisible(switches.at(0));
      await t.tap(switches.at(0));
      await t.pumpAndSettle();
      expect(api.ruleCalls.single, (
        autoUpgrade: true,
        balanceRefundable: true,
      ));
      expect(t.widget<HSwitch>(switches.at(0)).value, isTrue);

      await t.tap(switches.at(1));
      await t.pumpAndSettle();
      expect(api.ruleCalls.last, (autoUpgrade: true, balanceRefundable: false));
    });

    testWidgets('保存失败：开关回滚并提示原因', (t) async {
      api.cards = [_card()];
      api.ruleError = const AppError('保存失败');
      await openList(t);
      final sw = find.byType(HSwitch).at(0);
      expect(t.widget<HSwitch>(sw).value, isTrue);
      await t.ensureVisible(sw);
      api.ruleGate = Completer<void>(); // 让保存请求先卡住
      await t.tap(sw);
      await t.pump();
      expect(t.widget<HSwitch>(sw).value, isFalse); // 乐观更新
      api.ruleGate!.complete();
      await t.pumpAndSettle();
      expect(t.widget<HSwitch>(sw).value, isTrue); // 失败回滚
      expect(find.text('保存失败'), findsOneWidget);
      await t.pump(const Duration(seconds: 4));
    });

    testWidgets('页面高度跟随内容：只有一张卡时不滚动，卡多了才滚动', (t) async {
      api.cards = [_card()];
      await openList(t);
      double extent() => t
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .maxScrollExtent;
      expect(extent(), 0);

      api.cards = [for (var i = 0; i < 8; i++) _card(id: 'c$i', name: '卡$i')];
      await t.pumpWidget(const SizedBox());
      await openList(t);
      expect(extent(), greaterThan(0));
    });
  });
}
