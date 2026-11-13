import 'dart:async';
import 'dart:convert';

import 'package:autocare_merchant/kit/upload_gallery.dart';
import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
  );
  AppImageUploader grid(WidgetTester t) =>
      t.widget<AppImageUploader>(find.byType(AppImageUploader));
  testWidgets('上传失败保留图片，重试复用编号，移除失败保留图片', (t) async {
    final ids = <String>[];
    var failUpload = true, failRemove = true;
    final gate = Completer<void>();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadGallery(
            title: '照片',
            max: 2,
            load: () async => [],
            pickBytes: () async => bytes,
            upload: (data, id) async {
              ids.add(id);
              expectSync(data, bytes);
              await gate.future;
              if (failUpload) throw const AppError('上传失败');
              return UploadRecord('saved', MemoryImage(bytes));
            },
            remove: (_) async {
              if (failRemove) throw const AppError('移除失败');
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    grid(t).onPick!();
    await t.pump();
    await t.pump();
    expect(grid(t).items.single.state, AppUploadState.uploading);
    expect(grid(t).items.single.progress, isNull);
    expect(grid(t).enabled, isFalse);
    gate.complete();
    await t.pumpAndSettle();
    expect(grid(t).items.single.state, AppUploadState.failed);
    failUpload = false;
    grid(t).onRetry!(grid(t).items.single);
    await t.pumpAndSettle();
    expect(ids.length, 2);
    expect(ids.first, ids.last);
    expect(grid(t).items.single.state, AppUploadState.uploaded);
    grid(t).onRemove!(grid(t).items.single);
    await t.pumpAndSettle();
    expect(grid(t).items, hasLength(1));
    failRemove = false;
    grid(t).onRemove!(grid(t).items.single);
    await t.pumpAndSettle();
    expect(grid(t).items, isEmpty);
  });
  testWidgets('失败图片移除清理服务器占位，失败可重试移除', (t) async {
    var fails = true;
    String? removedId;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadGallery(
            title: '照片',
            max: 2,
            load: () async => [],
            pickBytes: () async => bytes,
            upload: (_, _) async => throw const AppError('网络中断'),
            remove: (_) async {},
            discard: (id) async {
              removedId = id;
              if (fails) throw const AppError('网络中断');
            },
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    grid(t).onPick!();
    await t.pumpAndSettle();
    final id = grid(t).items.single.id;
    grid(t).onRemove!(grid(t).items.single);
    await t.pumpAndSettle();
    expect(grid(t).items, hasLength(1));
    expect(removedId, id);
    fails = false;
    grid(t).onRemove!(grid(t).items.single);
    await t.pumpAndSettle();
    expect(grid(t).items, isEmpty);
  });
  testWidgets('退出后上传完成不更新销毁的控件', (t) async {
    final gate = Completer<UploadRecord>();
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadGallery(
            title: '照片',
            max: 2,
            load: () async => [],
            pickBytes: () async => bytes,
            upload: (_, _) => gate.future,
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    grid(t).onPick!();
    await t.pump();
    await t.pump();
    await t.pumpWidget(const MaterialApp(home: SizedBox()));
    gate.complete(UploadRecord('saved', MemoryImage(bytes)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
  testWidgets('只读图片没有添加删除入口', (t) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UploadGallery(
            title: '照片',
            max: 2,
            load: () async => [UploadRecord('saved', MemoryImage(bytes))],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(grid(t).readOnly, isTrue);
    expect(grid(t).onPick, isNull);
    expect(grid(t).onRemove, isNull);
    expect(find.bySemanticsLabel('添加照片'), findsNothing);
  });
}
