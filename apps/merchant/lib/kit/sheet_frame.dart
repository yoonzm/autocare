import 'package:flutter/material.dart';

import '../theme.dart';
import 'kit.dart';

/// 底部弹层的外壳：白色圆角顶部、拖动条、20/600 标题，内容之间间距 14（设计稿各个弹层通用）。
/// 所有手写的底部弹层都用它，不各自再画一份。
class AppSheetFrame extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const AppSheetFrame({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context, 30)),
    decoration: BoxDecoration(
      color: C.card,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, -14),
          blurRadius: 28,
        ),
      ],
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: dk(
                  context,
                  const Color(0xFFD4D4D8),
                  const Color(0xFF3F3F46),
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: ts(20, w: FontWeight.w600, color: C.ink, h: 28),
          ),
          for (final c in children) ...[const SizedBox(height: 14), c],
        ],
      ),
    ),
  );
}
