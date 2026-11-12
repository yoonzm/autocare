import 'package:autocare_ui_kit/autocare_ui_kit.dart';
import 'package:flutter/material.dart';

import 'data/store.dart';
import 'theme.dart';

export 'package:autocare_async_kit/async_kit.dart';
export 'package:autocare_ui_kit/autocare_ui_kit.dart';

/// 后台端的页面级组合。按钮、卡片、标签、列表行、输入框、开关、分段控件、弹层、对话框等基础组件
/// 一律使用 `autocare_ui_kit`；这里只放后台自己的页面骨架与少量业务展示。

// ───────── 提示 ─────────
void toast(BuildContext context, String msg) {
  AppToast.show(context, msg);
}

/// 页面跳转。
Future<T?> go<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

// ───────── 单选操作弹层 ─────────
class SheetOption {
  final String title;
  final String sub;
  final bool danger;
  const SheetOption(this.title, this.sub, {this.danger = false});
}

/// 设计稿里的“单选操作 + 取消/确认”底部弹层。返回选中的下标，取消为 null。
/// [onConfirm] 执行期间确认按钮显示加载中，成功后关闭，失败时弹层保持打开并提示。
Future<int?> pickOption(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<SheetOption> options,
  String? footnote,
  String ok = '确认',
  Future<void> Function(int)? onConfirm,
}) => showAppBottomSheet<int>(
  context,
  title: title,
  subtitle: subtitle,
  builder: (_) => _OptionBody(options: options, footnote: footnote, ok: ok, onConfirm: onConfirm),
);

class _OptionBody extends StatefulWidget {
  final List<SheetOption> options;
  final String? footnote;
  final String ok;
  final Future<void> Function(int)? onConfirm;
  const _OptionBody({
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
  bool loading = false;

  Future<void> _confirm() async {
    final selected = sel;
    final work = widget.onConfirm;
    if (work == null) {
      Navigator.pop(context, selected);
      return;
    }
    setState(() => loading = true);
    try {
      await work(selected);
      if (mounted) Navigator.pop(context, selected);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      AppToast.error(context, e);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      AppChoiceGroup<int>(
        kind: ChipKind.option,
        expanded: true,
        items: [
          for (var i = 0; i < widget.options.length; i++)
            ChoiceItem(
              value: i,
              label: widget.options[i].title,
              subtitle: widget.options[i].sub,
              enabled: !loading,
            ),
        ],
        selected: sel,
        onChanged: (i) => setState(() => sel = i),
      ),
      if (widget.footnote != null)
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s8),
          child: Text(widget.footnote!, style: AppTokens.of(context).caption),
        ),
      const SizedBox(height: AppSpacing.s16),
      Row(
        children: [
          Expanded(
            flex: 1,
            child: AppButton(
              label: '取消',
              kind: AppButtonKind.secondary,
              size: AppButtonSize.large,
              expanded: true,
              onPressed: loading ? null : () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: AppSpacing.s10),
          Expanded(
            flex: 2,
            child: AppButton(
              label: widget.ok,
              kind: widget.options[sel].danger ? AppButtonKind.danger : AppButtonKind.primary,
              size: AppButtonSize.large,
              expanded: true,
              loading: loading,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.s16),
    ],
  );
}

// ───────── 分组、键值、图标块 ─────────
/// 分组标题 + 内容。
class Section extends StatelessWidget {
  final String title;
  final Widget child;
  const Section(this.title, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSectionTitle(title),
      const SizedBox(height: AppSpacing.s8),
      child,
    ],
  );
}

/// 键值行（详情页的信息行）：业务展示，由基础令牌组成。
class KV extends StatelessWidget {
  final String k;
  final String v;
  final Color? vColor;
  final bool bold;
  const KV(this.k, this.v, {super.key, this.vColor, this.bold = false});
  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: t.base.copyWith(color: t.inkMute, fontWeight: FontWeight.w400)),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: t.base.copyWith(
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                color: vColor ?? t.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _tones = [
  [Color(0xFFF5B547), Color(0xFFE08A1E)],
  [Color(0xFFA78BFA), Color(0xFF7C5CE6)],
  [Color(0xFF59D49A), Color(0xFF17A864)],
  [Color(0xFF7CC0FF), Color(0xFF0485F7)],
];

/// 商家列表里的渐变图标块（业务展示，不属于基础组件）。
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

class Empty extends StatelessWidget {
  final String text;
  const Empty(this.text, {super.key});
  @override
  Widget build(BuildContext context) => EmptyView(title: text);
}

// ───────── 页面骨架 ─────────
/// 页面骨架：顶栏（返回 / 标题 / 右侧入口）+ 滚动内容 + 可选底部操作栏。
///
/// 底部只有按钮时传 [bottomBar]（`AppBottomBar`）；底栏里还要放输入框等自定义内容时用 [dock]。
class AdPage extends StatelessWidget {
  final String? title;
  final bool back;
  final Widget? action;
  final List<Widget> children;
  final Widget? bottomBar;
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
    this.bottomBar,
    this.dock,
    this.nav = false,
    this.gap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final t = AppTokens.of(context);
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
                AppPageHeader(
                  title: title!,
                  leading: back ? HeaderLeading.back : HeaderLeading.none,
                  trailing: action,
                ),
              for (final c in children) ...[SizedBox(height: gap), c],
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomBar ??
          (dock == null
              ? null
              : Container(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.pageGutter,
                    AppSpacing.s12,
                    AppSpacing.pageGutter,
                    MediaQuery.of(context).padding.bottom + AppSpacing.s12,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border(top: BorderSide(color: t.line)),
                  ),
                  child: dock,
                )),
    );
  }
}
