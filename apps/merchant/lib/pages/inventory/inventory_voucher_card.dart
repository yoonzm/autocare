import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../kit/upload_gallery.dart' show previewImages;
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/common.dart';

/// 入库单详情里的「送货单 / 发票 · N 张」（设计稿 StockInDetail）：缩略图一排，点击进入大图预览。
/// 没有凭证时整块卡片不显示。
class InventoryVoucherCard extends StatelessWidget {
  /// 单据上的凭证路径；[urls] 是后端读取单据时一并返回的 路径 → 签名链接。
  final List<String> paths;
  final Map<String, String> urls;
  const InventoryVoucherCard({
    super.key,
    required this.paths,
    this.urls = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return const SizedBox.shrink();
    final previews = [
      for (final p in paths)
        if (urls.containsKey(p))
          CachedNetworkImageProvider(urls[p]!, cacheKey: p),
    ];
    var shown = -1;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '送货单 / 发票 ',
                  style: ts(15, w: FontWeight.w600, h: 22),
                ),
                TextSpan(
                  text: '· ${paths.length} 张',
                  style: ts(15, color: C.muted, h: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var i = 0; i < paths.length; i++)
                () {
                  final url = urls[paths[i]];
                  final index = url == null ? -1 : ++shown;
                  return Semantics(
                    button: url != null,
                    label: '查看凭证 ${i + 1}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: url == null
                          ? null
                          : () => previewImages(
                              context,
                              previews,
                              index: index,
                              guided: true,
                            ),
                      child: _thumb(url == null ? null : previews[index]),
                    ),
                  );
                }(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _thumb(ImageProvider? image) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Container(
      width: 72,
      height: 72,
      color: C.chip,
      child: image == null
          ? Center(child: AppIcon('document', size: 26, color: C.muted))
          : Image(
              image: ResizeImage(image, width: 216, allowUpscaling: false),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Center(child: AppIcon('document', size: 26, color: C.muted)),
            ),
    ),
  );
}
