import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  group('输入格式', () {
    TextEditingValue run(TextInputFormatter f, String text) =>
        f.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length)));

    test('手机号分段 3-4-4，最多 11 位，过滤非数字', () {
      expect(run(PhoneFormatter(), '13916885530').text, '139 1688 5530');
      expect(run(PhoneFormatter(), '139').text, '139');
      expect(run(PhoneFormatter(), '1391').text, '139 1');
      expect(run(PhoneFormatter(), '139 1688 5530 99').text, '139 1688 5530');
      expect(run(PhoneFormatter(), 'a1b3').text, '13');
      expect(PhoneFormatter.digits('139 1688 5530'), '13916885530');
    });

    test('金额千分位，最多两位小数', () {
      expect(run(AmountFormatter(), '1580').text, '1,580');
      expect(run(AmountFormatter(), '1580.5').text, '1,580.5');
      expect(run(AmountFormatter(), '1234567.891').text, '1,234,567.89');
      expect(run(AmountFormatter(), '.5').text, '0.5');
      expect(run(AmountFormatter(), '007').text, '7');
      expect(run(AmountFormatter(), '1.2.3').text, '1.23');
      expect(AmountFormatter.plain('1,580.50'), '1580.50');
    });

    test('小数：一个小数点，两位小数', () {
      expect(run(DecimalFormatter(), '12.345').text, '12.34');
      expect(run(DecimalFormatter(), '1a2').text, '12');
    });
  });

  group('表单', () {
    testWidgets('行内输入：标签、必填星、占位、单位；输入右对齐', (t) async {
      final controller = TextEditingController();
      await pump(
        t,
        AppFormCard(children: [
          AppFormRow(label: '手机号', hint: '请输入手机号', required: true, format: AppInputFormat.phone, controller: controller),
          const AppFormRow(label: '安全库存', hint: '数量', suffix: '卷'),
        ]),
      );
      expect(find.text('请输入手机号'), findsOneWidget, reason: '没值时有占位');
      expect(find.text('数量'), findsOneWidget);
      expect(find.text('卷'), findsOneWidget);
      expect(find.textContaining('*', findRichText: true), findsOneWidget);
      await t.enterText(find.byType(TextField).first, '13916885530');
      expect(controller.text, '139 1688 5530');
      expect(t.widget<TextField>(find.byType(TextField).first).textAlign, TextAlign.right);
    });

    testWidgets('错误：标签变红，行下方右对齐红字', (t) async {
      const tokens = AppTokens.light;
      await pump(t, const AppFormCard(children: [AppFormRow(label: '成本价', hint: '0', errorText: '成本价不能小于 0')]));
      expect(find.text('成本价不能小于 0'), findsOneWidget);
      final label = t.widget<Text>(find.byWidgetPredicate((w) => w is Text && w.textSpan?.toPlainText() == '成本价'));
      expect(label.textSpan!.style!.color, tokens.requiredStar);
    });

    testWidgets('选择行：没选显示占位，选了显示值；点击回调', (t) async {
      var n = 0;
      await pump(
        t,
        Column(children: [
          AppSelectField(label: '推荐人', placeholder: '请选择', onTap: () => n++),
          const AppSelectField(label: '供应商', placeholder: '请选择', value: '蓝盾膜业'),
        ]),
      );
      expect(find.text('请选择'), findsOneWidget);
      expect(find.text('蓝盾膜业'), findsOneWidget);
      await t.tap(find.text('请选择'));
      expect(n, 1);
    });

    testWidgets('金额输入、多行输入、小数字输入都有占位', (t) async {
      final amount = TextEditingController();
      await pump(
        t,
        Column(children: [
          AppAmountField(label: '门店价', hint: '0.00', controller: amount),
          const AppTextArea(label: '备注', hint: '如：车主偏好'),
          const AppNumberBox(label: '提成比例', hint: '0', suffix: '%', caption: '约 ¥126 / 单'),
        ]),
      );
      expect(find.text('0.00'), findsOneWidget);
      expect(find.text('如：车主偏好'), findsOneWidget);
      expect(find.text('约 ¥126 / 单'), findsOneWidget);
      await t.enterText(find.byType(TextField).first, '1580.5');
      expect(amount.text, '1,580.5');
    });
  });

  group('搜索框', () {
    testWidgets('300ms 防抖后才回调；输入后出现清空按钮，清空回调空串', (t) async {
      final calls = <String>[];
      await pump(t, AppSearchBar(hint: '搜索商品名称 / SKU', onChanged: calls.add));
      expect(find.text('搜索商品名称 / SKU'), findsOneWidget);
      expect(find.bySemanticsLabel('清空'), findsNothing);
      await t.enterText(find.byType(TextField), '膜');
      await t.pump(const Duration(milliseconds: 100));
      await t.enterText(find.byType(TextField), '隐形车衣');
      await t.pump(const Duration(milliseconds: 299));
      expect(calls, isEmpty);
      await t.pump(const Duration(milliseconds: 2));
      expect(calls, ['隐形车衣']);
      await t.tap(find.bySemanticsLabel('清空'));
      await t.pump();
      expect(calls.last, '');
      expect(find.bySemanticsLabel('清空'), findsNothing);
    });
  });

  group('分段控件', () {
    testWidgets('选中是白色滑块；点击回调；角标显示数字', (t) async {
      var tab = 0;
      await pump(
        t,
        StatefulBuilder(
          builder: (context, set) => AppSegmented<int>(
            items: const [
              SegmentItem(value: 0, label: '入库单'),
              SegmentItem(value: 1, label: '出库单'),
              SegmentItem(value: 2, label: '失败', badge: 3),
            ],
            selected: tab,
            onChanged: (v) => set(() => tab = v),
          ),
        ),
      );
      await t.tap(find.text('出库单'));
      await t.pump();
      expect(tab, 1);
      expect(find.text('失败 3', findRichText: true), findsOneWidget);
    });

    test('只支持 2~4 项', () {
      expect(
        () => AppSegmented<int>(items: const [SegmentItem(value: 0, label: 'a')], selected: 0, onChanged: (_) {}),
        throwsAssertionError,
      );
    });
  });

  group('卡片与列表', () {
    testWidgets('列表行：整行可点才显示箭头；点击回调', (t) async {
      var n = 0;
      await pump(
        t,
        SizedBox(
          width: 350,
          child: AppListGroup(rows: [
            AppListRow(title: '营业时间', value: '每天 09:00 – 21:00', onTap: () => n++),
            const AppListRow(title: '消息通知', subtitle: '已开启', trailing: AppSwitch(value: true)),
          ]),
        ),
      );
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      await t.tap(find.text('营业时间'));
      expect(n, 1);
      expect(find.text('已开启'), findsOneWidget);
    });

    testWidgets('卡片、分组标题、分割线', (t) async {
      await pump(
        t,
        const SizedBox(
          width: 350,
          child: Column(children: [
            AppSectionTitle('基础设置'),
            AppCard(child: Text('店铺名称')),
            AppDividedColumn(children: [Text('a'), Text('b'), Text('c')]),
          ]),
        ),
      );
      expect(find.text('基础设置'), findsOneWidget);
      // 两条分割线（3 行之间），最后一行下面不画
      expect(
        find.byWidgetPredicate((w) => w is Container && w.constraints?.maxHeight == 1),
        findsNWidgets(2),
      );
    });

    testWidgets('概览卡、横幅', (t) async {
      var n = 0;
      await pump(
        t,
        SizedBox(
          width: 350,
          child: Column(children: [
            const AppHeroCard(title: '库存概览', value: '¥86,420', footnote: '248 种商品 · 7 项低库存'),
            AppBanner.warn('7 项低于安全库存', onTap: () => n++),
            const AppBanner.err('库存不足'),
            const AppBanner.info('同一时间只能有一张盘点单'),
          ]),
        ),
      );
      expect(find.text('¥86,420'), findsOneWidget);
      await t.tap(find.text('7 项低于安全库存'));
      expect(n, 1);
    });
  });

  group('图片上传', () {
    final items = [
      const AppUploadItem(id: '1', state: AppUploadState.uploaded),
      const AppUploadItem(id: '2', state: AppUploadState.uploading, progress: .62),
      const AppUploadItem(id: '3', state: AppUploadState.failed),
    ];

    testWidgets('网格：已选 / 上限、各状态、添加格排最后，传满后消失', (t) async {
      var picks = 0;
      final removed = <String>[];
      final retried = <String>[];
      final cancelled = <String>[];
      await pump(
        t,
        SizedBox(
          width: 350,
          child: AppImageUploader.grid(
            title: '凭证',
            max: 4,
            items: items,
            onPick: () => picks++,
            onRemove: (i) => removed.add(i.id),
            onRetry: (i) => retried.add(i.id),
            onCancel: (i) => cancelled.add(i.id),
          ),
        ),
      );
      expect(find.text('3 / 4'), findsOneWidget);
      expect(find.text('62%'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
      await t.tap(find.bySemanticsLabel('第 1 张，删除'));
      await t.tap(find.text('重试'));
      await t.tap(find.text('62%'));
      await t.tap(find.bySemanticsLabel('添加凭证'));
      expect([removed, retried, cancelled, picks], [['1'], ['3'], ['2'], 1]);
      await pump(
        t,
        SizedBox(
          width: 350,
          child: AppImageUploader.grid(title: '凭证', max: 3, items: items),
        ),
      );
      expect(find.bySemanticsLabel('添加凭证'), findsNothing, reason: '传满后添加格消失');
    });

    testWidgets('网格：权限被拒绝时显示提示并可跳转设置', (t) async {
      var opened = 0;
      await pump(
        t,
        SizedBox(
          width: 350,
          child: AppImageUploader.grid(title: '凭证', items: const [], permissionDenied: true, onOpenSettings: () => opened++),
        ),
      );
      await t.tap(find.text('未授权相机，去设置开启'));
      expect(opened, 1);
    });

    testWidgets('单格槽位：未传 / 上传中 / 已传 / 失败四种状态一致', (t) async {
      var picks = 0;
      var retries = 0;
      Widget slot(AppUploadItem? item) => SizedBox(
        width: 160,
        child: AppImageUploader.slot(label: '人像面', item: item, onPick: () => picks++, onRetry: (_) => retries++),
      );
      await pump(t, slot(null));
      expect(find.text('人像面'), findsOneWidget);
      await t.tap(find.text('人像面'));
      expect(picks, 1);
      await pump(t, slot(const AppUploadItem(id: 'a', state: AppUploadState.uploading, progress: .62)));
      expect(find.text('62%'), findsOneWidget);
      await pump(t, slot(const AppUploadItem(id: 'a', state: AppUploadState.uploaded)));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await t.tap(find.text('人像面'));
      expect(picks, 2, reason: '已上传再点一下就是重新选择');
      await pump(t, slot(const AppUploadItem(id: 'a', state: AppUploadState.failed)));
      await t.tap(find.text('重试'));
      expect(retries, 1);
    });

    test('通用规则常量', () {
      expect(AppImageRules.maxEdge, 2048);
      expect(AppImageRules.maxBytes, 5 * 1024 * 1024);
      expect(AppImageRules.defaultMax, 6);
    });
  });

  testWidgets('深色模式：组合组件可渲染', (t) async {
    await pump(
      t,
      SizedBox(
        width: 350,
        child: Column(children: [
          const AppHeroCard(title: '库存概览', value: '¥86,420'),
          const AppBanner.warn('提示'),
          AppImageUploader.grid(title: '凭证', items: const [AppUploadItem(id: '1', state: AppUploadState.uploading, progress: .5)]),
        ]),
      ),
      brightness: Brightness.dark,
    );
    expect(t.takeException(), isNull);
  });

  group('AppTextField', () {
    testWidgets('标签在上、必填星、占位、错误红字；密码框可显示 / 隐藏', (t) async {
      const tokens = AppTokens.light;
      final controller = TextEditingController();
      await pump(
        t,
        SizedBox(
          width: 350,
          child: Column(children: [
            AppTextField(label: '用户名', required: true, hint: '请输入用户名', controller: controller),
            const AppTextField(label: '密码', hint: '请输入密码', obscure: true, errorText: '用户名或密码错误'),
          ]),
        ),
      );
      expect(find.text('请输入用户名'), findsOneWidget);
      expect(find.text('请输入密码'), findsOneWidget);
      expect(find.text('用户名或密码错误'), findsOneWidget);
      expect(t.widget<Text>(find.text('用户名或密码错误')).style!.color, tokens.requiredStar);
      expect(find.textContaining('*', findRichText: true), findsOneWidget);
      expect(t.getTopLeft(find.text('请输入用户名')).dy, greaterThan(t.getTopLeft(find.byWidgetPredicate((w) => w is Text && w.textSpan?.toPlainText() == '用户名 *')).dy), reason: '标签在输入框上方');
      final password = find.byType(TextField).last;
      expect(t.widget<TextField>(password).obscureText, isTrue);
      await t.tap(find.byTooltip('显示密码'));
      await t.pump();
      expect(t.widget<TextField>(password).obscureText, isFalse);
      expect(find.byTooltip('隐藏密码'), findsOneWidget);
    });

    testWidgets('搜索框 keyboard 参数', (t) async {
      await pump(t, AppSearchBar(hint: '搜索', keyboard: TextInputType.phone, onChanged: (_) {}));
      expect(t.widget<TextField>(find.byType(TextField)).keyboardType, TextInputType.phone);
    });
  });

  test('状态色调：violet / gold / okOnDark / dark 取自令牌', () {
    const light = AppTokens.light;
    expect(toneColors(light, Tone.violet).fg, const Color(0xFF5B3FC0));
    expect(toneColors(light, Tone.dark).bg, const Color(0xFF18181B));
    expect(toneColors(light, Tone.dark).fg, light.gold);
    expect(toneColors(light, Tone.okOnDark).fg, const Color(0xFF6EE7A8));
    expect(toneColors(AppTokens.dark, Tone.dark).bg, const Color(0xFF34343A));
    for (final tone in Tone.values) {
      expect(toneColors(light, tone).bg, isNotNull);
    }
  });
}
