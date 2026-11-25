import 'package:flutter/material.dart';

import '../backend/inbox_store.dart';
import '../routes.dart' show openRoute;
import '../theme.dart';

class InboxBell extends StatelessWidget {
  const InboxBell({super.key});
  @override
  Widget build(BuildContext context) {
    final inbox = InboxScope.of(context);
    final unread = inbox?.unread ?? 0;
    return Semantics(
      label: unread > 0 ? '消息，$unread 条未读' : '消息',
      button: true,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            IconButton(
              tooltip: '消息',
              onPressed: () => openRoute(context, 'Messages'),
              icon: Icon(Icons.notifications_none_rounded, color: C.ink),
            ),
            if (unread > 0)
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (inbox?.error != null)
              const Positioned(
                right: 4,
                top: 4,
                child: Tooltip(
                  message: '消息更新失败，点击消息可重试',
                  child: Icon(
                    Icons.error_outline,
                    size: 12,
                    color: Color(0xFFF59E0B),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
