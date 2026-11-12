import 'dart:async';

import 'package:flutter/material.dart';

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';

/// 搜索框：白底胶囊，高 44，带卡片阴影；右侧可选一个圆形图标按钮（扫码）。
/// 内置逻辑：输入后 300ms 防抖再回调 [onChanged]，输入后出现清空按钮。
class AppSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? trailing;
  final TextEditingController? controller;
  final Duration debounce;
  const AppSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.trailing,
    this.controller,
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_rebuild);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _changed(String text) {
    _timer?.cancel();
    _timer = Timer(widget.debounce, () => widget.onChanged(text.trim()));
  }

  void _clear() {
    _controller.clear();
    _timer?.cancel();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: t.cardShadow,
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded, size: 18, color: t.inkMute),
                const SizedBox(width: AppSpacing.s8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _changed,
                    textInputAction: TextInputAction.search,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    style: t.base.copyWith(fontWeight: FontWeight.w400),
                    cursorColor: t.primary,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.hint,
                      hintStyle: t.base.copyWith(
                        color: t.inkMute,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  AppTapTarget(
                    onTap: _clear,
                    semanticLabel: '清空',
                    minWidth: 32,
                    builder: (context, pressed) => Icon(
                      Icons.cancel_rounded,
                      size: 18,
                      color: t.inkFaint,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          const SizedBox(width: AppSpacing.s10),
          widget.trailing!,
        ],
      ],
    );
  }
}
