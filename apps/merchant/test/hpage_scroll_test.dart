import 'package:autocare_merchant/kit/kit.dart';
import 'package:autocare_merchant/kit/page_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpPage(
  WidgetTester t,
  double contentHeight, {
  Widget? header,
}) async {
  t.view.physicalSize = const Size(390, 800);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      home: HPage(
        bg: Colors.white,
        header: header,
        flow: SizedBox(height: contentHeight, width: double.infinity),
      ),
    ),
  );
}

void main() {
  testWidgets('内容不足一屏时页面不可滚动', (t) async {
    await pumpPage(t, 300);
    final scroll = t.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, 0);
  });

  testWidgets('内容超过一屏时才可滚动，滚动范围等于超出的高度', (t) async {
    await pumpPage(t, 1000);
    final scroll = t.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, 200);
  });

  testWidgets('固定头部：内容滚动后头部位置不变，滚动时才出现分隔线', (t) async {
    await pumpPage(t, 1500, header: const AppPageHeader(title: '开支管理'));
    final top = t.getTopLeft(find.text('开支管理'));
    BorderSide line() {
      final box = t.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byType(AppPageHeader),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return ((box.decoration as BoxDecoration).border! as Border).bottom;
    }

    expect(line().color, Colors.transparent);
    await t.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await t.pump();
    expect(t.getTopLeft(find.text('开支管理')), top);
    expect(line().color, isNot(Colors.transparent));
    await t.drag(find.byType(SingleChildScrollView), const Offset(0, 300));
    await t.pump();
    expect(line().color, Colors.transparent);
  });

  testWidgets('固定头部：内容区高度扣掉头部，内容刚好超出时才滚动', (t) async {
    await pumpPage(t, 780, header: const AppPageHeader(title: '开支管理'));
    final scroll = t.state<ScrollableState>(find.byType(Scrollable));
    expect(scroll.position.maxScrollExtent, 780 - (800 - 64));
  });

  testWidgets('AppPageHeader：左上角可为空、点击可自定义、标题可换成自定义内容', (t) async {
    var tapped = 0;
    await pumpPage(
      t,
      300,
      header: AppPageHeader(
        leading: AppHeaderLeading.close,
        onLeading: () => tapped++,
        center: const Text('自定义标题区'),
      ),
    );
    expect(find.text('自定义标题区'), findsOneWidget);
    await t.tap(find.byType(GestureDetector).first);
    expect(tapped, 1);
    await pumpPage(
      t,
      300,
      header: const AppPageHeader(title: '无返回', leading: AppHeaderLeading.none),
    );
    expect(find.byType(GestureDetector), findsNothing);
  });

  testWidgets('HHeaderFrame：ListView 页面头部固定，滚动才出现分隔线', (t) async {
    t.view.physicalSize = const Size(390, 800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HHeaderFrame(
            bg: Colors.white,
            header: const AppPageHeader(title: '订单'),
            body: ListView(
              children: [
                for (var i = 0; i < 40; i++)
                  SizedBox(height: 50, child: Text('行$i')),
              ],
            ),
          ),
        ),
      ),
    );
    final top = t.getTopLeft(find.text('订单'));
    await t.drag(find.byType(ListView), const Offset(0, -300));
    await t.pump();
    expect(t.getTopLeft(find.text('订单')), top);
    final box = t.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byType(AppPageHeader),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    expect(
      ((box.decoration as BoxDecoration).border! as Border).bottom.color,
      isNot(Colors.transparent),
    );
  });
}
