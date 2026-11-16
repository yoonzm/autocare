import 'package:autocare_merchant/pages/expenses/payee_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const power = PayeeOption(
  name: '市供电局',
  category: '水电',
  amount: 1180,
  occurredOn: '2026-10-05',
);
const rent = PayeeOption(
  name: '恒达房产',
  category: '房租',
  amount: 12000,
  occurredOn: '2026-10-01',
);

void main() {
  test('副标题：分类 · 上次金额 · 月.日', () {
    expect(power.subtitle, '水电 · 上次 ¥1,180 · 10.05');
    expect(rent.subtitle, '房租 · 上次 ¥12,000 · 10.01');
    const cents = PayeeOption(
      name: 'x',
      category: '其他',
      amount: 326.5,
      occurredOn: '2026-09-15',
    );
    expect(cents.subtitle, '其他 · 上次 ¥326.50 · 09.15');
  });

  testWidgets('显示最近使用，当前项带勾选，点击一行立即选中并关闭', (t) async {
    String? picked = 'unset';
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showPayeeSheet(
              context,
              load: (_) async => [power, rent],
              current: '市供电局',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('最近使用'), findsOneWidget);
    expect(find.text('水电 · 上次 ¥1,180 · 10.05'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    await t.tap(find.text('恒达房产'));
    await t.pumpAndSettle();
    expect(picked, '恒达房产');
  });

  testWidgets('点清除返回空字符串', (t) async {
    String? picked = 'unset';
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showPayeeSheet(
              context,
              load: (_) async => [power],
              current: '市供电局',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('清除'));
    await t.pumpAndSettle();
    expect(picked, '');
  });

  testWidgets('输入没有完全匹配的名称时出现新增行，同名则直接匹配已有项', (t) async {
    String? picked = 'unset';
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final queries = <String>[];
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showPayeeSheet(
              context,
              load: (q) async {
                queries.add(q);
                final needle = q.replaceAll(' ', '');
                return [power].where((e) => e.name.contains(needle)).toList();
              },
              current: '',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField), '华顺轮胎');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(queries.last, '华顺轮胎');
    expect(find.text('新增收款方「华顺轮胎」'), findsOneWidget);
    expect(find.textContaining('没有找到匹配的收款方'), findsOneWidget);

    await t.enterText(find.byType(TextField), '市 供电局');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    expect(find.textContaining('新增收款方「'), findsNothing);

    await t.enterText(find.byType(TextField), '华顺轮胎');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    await t.tap(find.text('新增收款方「华顺轮胎」'));
    await t.pumpAndSettle();
    expect(picked, '华顺轮胎');
  });

  testWidgets('名称最多 20 个字，首尾空格去掉', (t) async {
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                showPayeeSheet(context, load: (_) async => [], current: ''),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('输入名称即可新增收款方'), findsOneWidget);
    expect(find.text('最近使用'), findsNothing);
    await t.enterText(find.byType(TextField), '  ${'甲' * 25}  ');
    await t.pump(const Duration(milliseconds: 400));
    await t.pumpAndSettle();
    final text = t.widget<TextField>(find.byType(TextField)).controller!.text;
    expect(text.length <= payeeMaxLength, true);
  });

  testWidgets('加载失败显示重试，仍可输入并新增', (t) async {
    var fail = true;
    t.view.physicalSize = const Size(390, 844);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => showPayeeSheet(
              context,
              load: (_) async {
                if (fail) throw Exception('network');
                return [power];
              },
              current: '',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('加载失败，点击重试'), findsOneWidget);
    fail = false;
    await t.tap(find.text('加载失败，点击重试'));
    await t.pumpAndSettle();
    expect(find.text('市供电局'), findsOneWidget);
  });
}
