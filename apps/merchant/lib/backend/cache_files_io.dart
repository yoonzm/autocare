import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<Directory> _root() async {
  final dir = await getTemporaryDirectory();
  // Android/iOS return app-scoped cache directories. Desktop may return a shared temp directory.
  return defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? dir
      : Directory('${dir.path}/autocare-cache');
}

Future<List<File>> _files() async {
  final root = await _root();
  if (!await root.exists()) return [];
  final safeRoot = await root.resolveSymbolicLinks();
  final found = <File>[];
  await for (final entry in root.list(recursive: true, followLinks: false)) {
    if (entry is! File) continue;
    final resolved = await entry.resolveSymbolicLinks();
    if (resolved.startsWith('$safeRoot${Platform.pathSeparator}')) {
      found.add(entry);
    }
  }
  return found;
}

Future<({int images, int temporary})> usage() async {
  var images = 0, temporary = 0;
  for (final file in await _files()) {
    final bytes = await file.length();
    if (RegExp(
      r'\.(png|jpe?g|webp|gif|heic)$',
      caseSensitive: false,
    ).hasMatch(file.path)) {
      images += bytes;
    } else {
      temporary += bytes;
    }
  }
  return (images: images, temporary: temporary);
}

Future<void> clear() async {
  // Only files within the app's cache root; never follow links or delete preferences/documents.
  for (final file in await _files()) {
    if (await FileSystemEntity.type(file.path, followLinks: false) ==
        FileSystemEntityType.file) {
      await file.delete();
    }
  }
}
