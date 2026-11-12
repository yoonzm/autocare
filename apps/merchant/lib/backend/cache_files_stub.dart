Future<({int images, int temporary})> usage() async =>
    (images: 0, temporary: 0);
// Browsers manage their own HTTP cache; this app owns no persistent browser file cache.
Future<void> clear() async {}
