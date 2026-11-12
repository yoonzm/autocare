import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'cache_files_stub.dart'
    if (dart.library.io) 'cache_files_io.dart'
    as files;
import 'service_store.dart';

class CacheUsage {
  final int images, offline, temporary;
  const CacheUsage(this.images, this.offline, this.temporary);
  int get total => images + offline + temporary;
  static String format(int bytes) => bytes == 0
      ? '0 MB'
      : bytes < 1024 * 1024
      ? '${(bytes / 1024).ceil()} KB'
      : '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class AppCache {
  @visibleForTesting
  static Future<({int images, int temporary})> Function() readFiles =
      files.usage;
  static final changed = ValueNotifier<int>(0);
  static Future<CacheUsage> usage() async {
    final disk = await readFiles();
    return CacheUsage(
      PaintingBinding.instance.imageCache.currentSizeBytes + disk.images,
      // This App has no persistent offline database. Do not invent a storage size for it.
      0,
      disk.temporary,
    );
  }

  static Future<void> clear() async {
    await files.clear();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    ServiceStore.clear();
    changed.value++;
  }
}
