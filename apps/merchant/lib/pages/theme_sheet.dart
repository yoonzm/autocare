import 'package:flutter/material.dart';

import '../mock/theme_state.dart';
import '../theme.dart';

/// 外观：跟随系统 / 浅色 / 深色，点“应用”后真正切换全局主题。
class ThemeSheet extends StatefulWidget {
  const ThemeSheet({super.key});
  @override
  State<ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends State<ThemeSheet> {
  late ThemeMode _sel = appThemeMode.value;

  static const _opts = [
    (ThemeMode.system, '跟随系统', '自动匹配手机的深色 / 浅色设置'),
    (ThemeMode.light, '浅色', '始终使用浅色界面'),
    (ThemeMode.dark, '深色', '始终使用深色界面，夜间更护眼'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: C.dark
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFD4D4D8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '外观',
            style: ts(20, w: FontWeight.w600, color: C.ink, h: 28),
          ),
          const SizedBox(height: 4),
          Text('选择应用的显示模式', style: ts(13, color: C.muted, h: 18)),
          const SizedBox(height: 14),
          for (final o in _opts) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _sel = o.$1),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: C.inset,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _sel == o.$1 ? C.ink : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.$2,
                            style: ts(
                              15,
                              w: FontWeight.w500,
                              color: C.ink,
                              h: 22,
                            ),
                          ),
                          Text(o.$3, style: ts(12, color: C.muted, h: 17)),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _sel == o.$1 ? C.btn : Colors.transparent,
                        border: Border.all(
                          color: _sel == o.$1 ? C.btn : C.stroke,
                          width: 1.5,
                        ),
                      ),
                      child: _sel == o.$1
                          ? Icon(Icons.check, size: 14, color: C.btnFg)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.chip,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '取消',
                      style: ts(15, w: FontWeight.w500, color: C.ink, h: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 16,
                child: GestureDetector(
                  onTap: () {
                    appThemeMode.value = _sel;
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: C.btn,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      '应用',
                      style: ts(15, w: FontWeight.w600, color: C.btnFg, h: 22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
