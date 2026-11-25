import 'package:flutter/material.dart';

import '../routes.dart' show openRoute;
import '../theme.dart';
import 'app_icon.dart';

/// 收款 / 充值 / 购卡成功页展示后端返回的同步短信提交状态。
class SmsReceiptNoticeCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const SmsReceiptNoticeCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final status = '${data['sms_status'] ?? ''}'.trim();
    if (status.isEmpty) return const SizedBox.shrink();
    final phone = '${data['sms_phone_masked'] ?? ''}'.trim();
    final error = '${data['sms_error'] ?? ''}'.trim();

    final (Color bg, Color fg, String text, bool canOpenLogs) = switch (status) {
      'sent' => (
        C.greenSoft,
        C.greenInk,
        phone.isNotEmpty ? '已提交短信通知至 $phone' : '已提交短信通知',
        true,
      ),
      'failed' => (
        C.redSoft,
        C.redInk,
        error.isNotEmpty ? '短信通知发送失败：$error' : '短信通知发送失败，点击查看记录',
        true,
      ),
      _ => (
        C.card,
        C.muted,
        error.isNotEmpty ? error : '本次未发送短信通知',
        false,
      ),
    };

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: status == 'skipped' ? Border.all(color: C.line) : null,
      ),
      child: Row(
        children: [
          AppIcon('bell', size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: ts(13, w: FontWeight.w500, color: fg, h: 18),
            ),
          ),
          if (canOpenLogs) ...[
            const SizedBox(width: 6),
            Text(
              '记录',
              style: ts(12, w: FontWeight.w600, color: fg, h: 16),
            ),
          ],
        ],
      ),
    );

    if (!canOpenLogs) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openRoute(context, 'NotifySettings'),
      child: card,
    );
  }
}
