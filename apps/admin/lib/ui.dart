import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autocare_async_kit/async_kit.dart';

import 'data/store.dart';

export 'package:autocare_async_kit/async_kit.dart';

import 'theme.dart';

// ───────── 提示与弹层 ─────────
void toast(BuildContext context, String msg) {
  AppToast.show(context, msg);
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String ok = '确认',
  String cancel = '取消',
  bool danger = false,
  Future<void> Function()? onConfirm,
}) async {
  final actionKey = 'confirm-${identityHashCode(Object())}';
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AsyncActionScope(
      actionKey: actionKey,
      child: Dialog(
        backgroundColor: C.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: ts(18, w: FontWeight.w600, h: 26)),
              const SizedBox(height: 8),
              Text(message, style: ts(14, color: C.sub, h: 21)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Btn(
                      cancel,
                      ghost: true,
                      onTap: () => Navigator.pop(c, false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: Btn(
                      ok,
                      actionKey: actionKey,
                      danger: danger,
                      onTap: () async {
                        if (onConfirm != null) {
                          await Future.wait([
                            onConfirm(),
                            Future<void>.delayed(kIndicatorMinShow),
                          ]);
                        }
                        if (c.mounted && ModalRoute.of(c)?.isCurrent == true) {
                          Navigator.pop(c, true);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return r ?? false;
}

Future<T?> showSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: C.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: C.stroke2,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                builder(c),
              ],
            ),
          ),
        ),
      ),
    );

class SheetOption {
  final String title;
  final String sub;
  final bool danger;
  const SheetOption(this.title, this.sub, {this.danger = false});
}

/// 设计稿里的“单选操作 + 取消/确认”底部弹层。返回选中的下标，取消为 null。
Future<int?> pickOption(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetOption> options,
  String? footnote,
  String ok = '确认',
  Future<void> Function(int)? onConfirm,
}) => showSheet<int>(context, (c) {
  return _OptionBody(
    title: title,
    subtitle: subtitle,
    options: options,
    footnote: footnote,
    ok: ok,
    onConfirm: onConfirm,
  );
});

class _OptionBody extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<SheetOption> options;
  final String? footnote;
  final String ok;
  final Future<void> Function(int)? onConfirm;
  const _OptionBody({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.footnote,
    required this.ok,
    required this.onConfirm,
  });
  @override
  State<_OptionBody> createState() => _OptionBodyState();
}

class _OptionBodyState extends State<_OptionBody> {
  int sel = 0;
  late final actionKey = 'option-${identityHashCode(this)}';
  @override
  Widget build(BuildContext context) {
    return AsyncActionScope(
      actionKey: actionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: ts(20, w: FontWeight.w600, h: 28)),
          if (widget.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(widget.subtitle!, style: ts(12, color: C.muted, h: 17)),
          ],
          const SizedBox(height: 14),
          for (var i = 0; i < widget.options.length; i++) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => sel = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: sel == i ? C.primarySoft : C.inset,
                  borderRadius: BorderRadius.circular(18),
                  border: sel == i
                      ? Border.all(color: C.primary, width: 1.5)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.options[i].title,
                      style: ts(
                        15,
                        w: FontWeight.w600,
                        h: 22,
                        color: widget.options[i].danger ? C.redInk : C.ink,
                      ),
                    ),
                    Text(
                      widget.options[i].sub,
                      style: ts(12, color: sel == i ? C.sub : C.muted, h: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.footnote != null)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 6),
              child: Text(
                widget.footnote!,
                style: ts(12, color: C.muted, h: 17),
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: Btn(
                  '取消',
                  ghost: true,
                  onTap: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: Btn(
                  widget.ok,
                  actionKey: actionKey,
                  danger: widget.options[sel].danger,
                  onTap: () async {
                    final selected = sel;
                    if (widget.onConfirm != null) {
                      await Future.wait([
                        widget.onConfirm!(selected),
                        Future<void>.delayed(kIndicatorMinShow),
                      ]);
                    }
                    if (context.mounted &&
                        ModalRoute.of(context)?.isCurrent == true) {
                      Navigator.pop(context, selected);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ───────── 基础组件 ─────────
class Btn extends StatelessWidget {
  final String? actionKey;
  final String text;
  final Function()? onTap;
  final bool ghost;
  final bool danger;
  final bool soft;
  const Btn(
    this.text, {
    super.key,
    this.actionKey,
    this.onTap,
    this.ghost = false,
    this.danger = false,
    this.soft = false,
  });
  @override
  Widget build(BuildContext context) {
    final bg = onTap == null
        ? C.stroke
        : ghost
        ? C.chip
        : soft
        ? C.redSoft
        : danger
        ? C.red
        : C.primary;
    final fg = ghost
        ? C.ink
        : soft
        ? C.redInk
        : onTap == null
        ? C.faint
        : Colors.white;
    return AsyncAction(
      actionKey: actionKey,
      onTap: onTap,
      builder: (actionKey, tap) => BusyOverlay(
        actionKey: actionKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: tap,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(25),
            ),
            child: hBusy(
              actionKey,
              SizedBox(
                width: double.infinity,
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: ts(
                    15,
                    w: ghost ? FontWeight.w500 : FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
              style: ts(15, color: fg),
              label: '提交中…',
            ),
          ),
        ),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;
  const Pill(this.text, this.fg, this.bg, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    height: 18,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      text,
      style: ts(11, w: FontWeight.w600, color: fg, h: 18),
    ),
  );
}

class HCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  const HCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: softShadow,
      ),
      child: child,
    );
    return onTap == null
        ? box
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: box,
          );
  }
}

class Section extends StatelessWidget {
  final String title;
  final Widget child;
  const Section(this.title, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: ts(13, w: FontWeight.w500, color: C.sub, h: 18),
        ),
      ),
      child,
    ],
  );
}

class CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  final String label;
  const CircleBtn(
    this.icon,
    this.onTap, {
    super.key,
    this.primary = false,
    required this.label,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primary ? C.primary : C.card,
          shape: BoxShape.circle,
          boxShadow: primary ? null : softShadow,
        ),
        child: Icon(icon, size: 20, color: primary ? Colors.white : C.ink),
      ),
    ),
  );
}

/// 页面骨架：顶栏（返回 / 标题 / 右侧按钮）+ 滚动内容 + 可选底部操作栏。
class AdPage extends StatelessWidget {
  final String? title;
  final bool back;
  final Widget? action;
  final List<Widget> children;
  final Widget? dock;
  final bool nav; // 位于底部导航之上，不需要自己预留 home 条
  final double gap;

  /// 下拉刷新；默认刷新全部运营数据，短信记录这类独立列表传自己的刷新。
  final Future<void> Function()? onRefresh;
  const AdPage({
    super.key,
    this.onRefresh,
    this.title,
    this.back = true,
    this.action,
    required this.children,
    this.dock,
    this.nav = false,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: RefreshIndicator(
          onRefresh: onRefresh ?? () async {
            try {
              await store.refresh();
              if (context.mounted) AppToast.show(context, '已更新');
            } catch (e) {
              if (context.mounted) AppToast.error(context, e);
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(20, top + 12, 20, 32),
            children: [
              if (title != null)
                SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 44,
                        child: back
                            ? CircleBtn(
                                Icons.chevron_left_rounded,
                                () => Navigator.maybePop(context),
                                label: '返回',
                              )
                            : null,
                      ),
                      Expanded(
                        child: Text(
                          title!,
                          textAlign: TextAlign.center,
                          style: ts(17, w: FontWeight.w600, h: 24),
                        ),
                      ),
                      SizedBox(width: 44, child: action),
                    ],
                  ),
                ),
              for (final c in children) ...[SizedBox(height: gap), c],
            ],
          ),
        ),
      ),
      bottomNavigationBar: dock == null
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: C.card.withValues(alpha: .94),
                border: Border(top: BorderSide(color: C.stroke)),
              ),
              child: dock,
            ),
    );
  }
}

class Segmented extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  /// 标签后面的红色数字角标（如「失败 3」），键是标签序号。
  final Map<int, int> badges;
  final Color? badgeColor;
  const Segmented({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
    this.badges = const {},
    this.badgeColor,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: C.segment,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: Container(
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: i == index ? C.segActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: i == index ? softShadow : null,
                ),
                child: (badges[i] ?? 0) > 0
                    ? Text.rich(
                        TextSpan(
                          text: labels[i],
                          children: [
                            TextSpan(
                              text: ' ${badges[i]}',
                              style: ts(
                                13,
                                w: FontWeight.w500,
                                color: badgeColor ?? C.redInk,
                                h: 18,
                              ),
                            ),
                          ],
                        ),
                        style: ts(
                          13,
                          w: FontWeight.w500,
                          color: i == index ? C.ink : C.sub,
                          h: 18,
                        ),
                      )
                    : Text(
                        labels[i],
                        style: ts(
                          13,
                          w: FontWeight.w500,
                          color: i == index ? C.ink : C.sub,
                          h: 18,
                        ),
                      ),
              ),
            ),
          ),
      ],
    ),
  );
}

const _tones = [
  [Color(0xFFF5B547), Color(0xFFE08A1E)],
  [Color(0xFFA78BFA), Color(0xFF7C5CE6)],
  [Color(0xFF59D49A), Color(0xFF17A864)],
  [Color(0xFF7CC0FF), Color(0xFF0485F7)],
];

class ToneTile extends StatelessWidget {
  final int tone;
  final IconData icon;
  final double size;
  const ToneTile(this.tone, this.icon, {super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _tones[tone % _tones.length],
      ),
    ),
    child: Icon(icon, size: 22, color: Colors.white),
  );
}

class SoftTile extends StatelessWidget {
  final IconData icon;
  final Color fg;
  final Color bg;
  final double size;
  const SoftTile(this.icon, this.fg, this.bg, {super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(size > 40 ? 14 : 11),
    ),
    child: Icon(icon, size: size > 40 ? 22 : 16, color: fg),
  );
}

/// 列表行：图标 + 标题 + 副标题 + 右侧内容 + 箭头。
class Row1 extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? sub;
  final Widget? trailing;
  final bool chevron;
  final VoidCallback? onTap;
  final double minHeight;
  const Row1({
    super.key,
    required this.leading,
    required this.title,
    this.sub,
    this.trailing,
    this.chevron = true,
    this.onTap,
    this.minHeight = 72,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ts(15, w: FontWeight.w600, h: 22),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(12, color: C.muted, h: 17),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            if (chevron && onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded, size: 20, color: C.faint),
            ],
          ],
        ),
      ),
    ),
  );
}

/// 圆角卡片内的分组列表，行间带缩进分割线。
class RowGroup extends StatelessWidget {
  final List<Widget> rows;
  final double indent;
  const RowGroup(this.rows, {super.key, this.indent = 72});
  @override
  Widget build(BuildContext context) => HCard(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Container(
              height: 1,
              margin: EdgeInsets.only(left: indent),
              color: C.line,
            ),
          rows[i],
        ],
      ],
    ),
  );
}

class KV extends StatelessWidget {
  final String k;
  final String v;
  final Color? vColor;
  final bool bold;
  const KV(this.k, this.v, {super.key, this.vColor, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: ts(14, color: C.muted, h: 20)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            v,
            textAlign: TextAlign.right,
            style: ts(
              14,
              w: bold ? FontWeight.w600 : FontWeight.w500,
              color: vColor ?? C.ink,
              h: 20,
            ),
          ),
        ),
      ],
    ),
  );
}

class Field extends StatefulWidget {
  final String label;
  final bool required;
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? formatters;
  final Widget? suffix;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final String? prefix;
  const Field({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.hint = '',
    this.obscure = false,
    this.keyboard,
    this.formatters,
    this.suffix,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.prefix,
  });
  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  /// 密码框是否明文显示。
  bool show = false;

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final required = widget.required;
    final obscure = widget.obscure;
    final error = widget.error;
    final prefix = widget.prefix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required)
                TextSpan(
                  text: ' *',
                  style: ts(13, color: C.redInk),
                ),
            ],
          ),
          style: ts(13, w: FontWeight.w500, h: 18),
        ),
        const SizedBox(height: 6),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: C.inset,
            borderRadius: BorderRadius.circular(14),
            border: error != null ? Border.all(color: C.red, width: 1.2) : null,
          ),
          child: Row(
            children: [
              if (prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(prefix, style: ts(15, color: C.muted)),
                ),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: obscure && !show,
                  keyboardType: widget.keyboard,
                  inputFormatters: widget.formatters,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  maxLines: obscure ? 1 : widget.maxLines,
                  minLines: 1,
                  style: ts(15, h: 22),
                  cursorColor: C.primary,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint.isEmpty
                        ? '请输入${widget.label}'
                        : widget.hint,
                    hintStyle: ts(15, color: C.faint, h: 22),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
              if (obscure)
                IconButton(
                  onPressed: () => setState(() => show = !show),
                  tooltip: show ? '隐藏密码' : '显示密码',
                  icon: Icon(
                    show
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: C.muted,
                  ),
                ),
              ?widget.suffix,
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(error, style: ts(12, color: C.redInk, h: 17)),
          ),
      ],
    );
  }
}

class Switch1 extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const Switch1(this.value, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 48,
      height: 28,
      padding: const EdgeInsets.all(2),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      decoration: BoxDecoration(
        color: value ? C.primary : C.stroke2,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

/// 深色渐变英雄卡（概览 / 订阅 / 商家详情共用）。
class DarkHero extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius radius;
  const DarkHero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = const BorderRadius.all(Radius.circular(28)),
  });
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: radius,
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-.6, -1),
          end: Alignment(.8, 1),
          colors: [Color(0xFF26262C), Color(0xFF18181B), Color(0xFF2B2418)],
          stops: [0, .55, 1],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -100,
            top: -100,
            child: CustomPaint(size: const Size(260, 260), painter: _Rings()),
          ),
          Positioned(
            right: -60,
            top: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x4DF5D78E), Color(0x00F5D78E)],
                  stops: [0, .68],
                ),
              ),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    ),
  );
}

class _Rings extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF34343A);
    final c = size.center(Offset.zero);
    for (final r in [60.0, 90.0, 118.0]) {
      canvas.drawCircle(c, r * size.width / 240, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class Empty extends StatelessWidget {
  final String text;
  const Empty(this.text, {super.key});
  @override
  Widget build(BuildContext context) => EmptyView(title: text);
}

/// 页面跳转。
Future<T?> go<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
