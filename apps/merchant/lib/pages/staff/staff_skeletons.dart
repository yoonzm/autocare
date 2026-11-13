import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;
import 'package:flutter/material.dart';

import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../kit/page_header.dart';
import '../../resources/merchant_svgs.dart';

/// 员工 / 工位相关页面的首次加载骨架：外壳（标题栏、页签、分区标题）与真实页面一致，
/// 只有等待数据的区域用灰块占位；[showBlocks] 为 false 时只显示外壳（300ms 延迟期间）。
enum ResourceSkeletonKind { staffList, staffForm, bayForm, business }

class ResourceSkeleton extends StatelessWidget {
  final ResourceSkeletonKind kind;
  final bool editing;
  final bool showBlocks;
  const ResourceSkeleton({
    super.key,
    required this.kind,
    this.editing = false,
    this.showBlocks = true,
  });

  @override
  Widget build(BuildContext context) => HPage(
    bg: dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B)),
    height: 844,
    fixedHeight: false,
    flow: hbox(
      pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(context),
          if (kind == ResourceSkeletonKind.staffList) ..._staffList(context),
          if (kind != ResourceSkeletonKind.staffList && showBlocks)
            ..._form(context),
        ],
      ),
    ),
  );

  Widget _header(BuildContext context) => switch (kind) {
    ResourceSkeletonKind.staffList => AppPageHeader(
      title: '员工与权限',
      trailing: const AppHeaderAction(
        lightSvg: Svgs.s81,
        darkSvg: Svgs.s82,
        label: '新增员工',
      ),
    ),
    ResourceSkeletonKind.staffForm => AppPageHeader(
      title: editing ? '编辑员工' : '新增员工',
      leading: AppHeaderLeading.close,
      trailing: editing ? _saveText(context) : null,
    ),
    ResourceSkeletonKind.bayForm => AppPageHeader(
      title: '编辑工位',
      trailing: _saveText(context),
    ),
    ResourceSkeletonKind.business => AppPageHeader(
      title: '营业时间与工位',
      trailing: _saveText(context),
    ),
  };

  Widget _saveText(BuildContext context) => SizedBox(
    height: 44,
    child: Center(
      child: Text(
        '保存',
        style: hts(15, const Color(0xFF0485F7), w: FontWeight.w500, lh: 22),
      ),
    ),
  );

  Color _card(BuildContext context) =>
      dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B));

  Widget _cardBox(BuildContext context, Widget child, {EdgeInsets? pad}) =>
      Container(
        width: double.infinity,
        padding: pad ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card(context),
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      );

  // ───────── 员工列表 ─────────
  List<Widget> _staffList(BuildContext context) {
    final muted = dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3));
    return [
      const SizedBox(height: 16),
      // 角色页签：标签是固定文案，直接显示；人数等数据到了再出现
      AppSegmented<int>(
        items: const [
          SegmentItem(value: 0, label: '全部'),
          SegmentItem(value: 1, label: '店长'),
          SegmentItem(value: 2, label: '前台收银'),
          SegmentItem(value: 3, label: '施工技师'),
        ],
        selected: 0,
        enabled: false,
        onChanged: (_) {},
      ),
      if (showBlocks) ...[
        const SizedBox(height: 16),
        _cardBox(
          context,
          Column(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 52),
                    color: dk(
                      context,
                      const Color(0xFFEFEFF1),
                      const Color(0xFF2A2A2E),
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      AppSkeleton.circle(size: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton(width: 120, height: 15),
                            SizedBox(height: 8),
                            AppSkeleton(width: 84, height: 12),
                          ],
                        ),
                      ),
                      AppSkeleton(width: 58, height: 20, radius: 10),
                    ],
                  ),
                ),
              ],
            ],
          ),
          pad: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        ),
        const SizedBox(height: 16),
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _card(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(child: Text('已停用账号', style: hts(15, muted, lh: 22))),
              const AppSkeleton(width: 36, height: 13),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _cardBox(
          context,
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 88, height: 16),
              SizedBox(height: 14),
              AppSkeleton(height: 14),
              SizedBox(height: 12),
              AppSkeleton(height: 14),
              SizedBox(height: 12),
              AppSkeleton(width: 180, height: 14),
            ],
          ),
        ),
      ],
    ];
  }

  // ───────── 表单 / 营业时间 ─────────
  Widget _field(String label) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppSkeleton(width: label.length * 14.0, height: 14),
      const SizedBox(height: 8),
      const AppSkeleton(height: 48, radius: 16),
    ],
  );

  List<Widget> _form(BuildContext context) {
    Widget title(double w) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppSkeleton(width: w, height: 16),
    );
    Widget card(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: _cardBox(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
    return switch (kind) {
      ResourceSkeletonKind.staffForm => [
        card([
          title(72),
          _field('姓名'),
          const SizedBox(height: 14),
          _field('手机号'),
          const SizedBox(height: 14),
          _field('入职日期'),
        ]),
        card([
          title(40),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            const AppSkeleton(height: 62, radius: 18),
          ],
        ]),
        card([
          title(72),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppSkeleton(width: 64, height: 34, radius: 17),
              AppSkeleton(width: 84, height: 34, radius: 17),
              AppSkeleton(width: 64, height: 34, radius: 17),
              AppSkeleton(width: 64, height: 34, radius: 17),
            ],
          ),
        ]),
      ],
      ResourceSkeletonKind.bayForm => [
        card([
          _field('工位名称'),
          const SizedBox(height: 18),
          const AppSkeleton(width: 60, height: 14),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            children: [
              AppSkeleton(width: 58, height: 34, radius: 17),
              AppSkeleton(width: 58, height: 34, radius: 17),
              AppSkeleton(width: 58, height: 34, radius: 17),
            ],
          ),
        ]),
        card([
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            const AppSkeleton(height: 18),
          ],
        ]),
      ],
      _ => [
        card([
          title(72),
          const Row(
            children: [
              Expanded(child: AppSkeleton(height: 48, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: AppSkeleton(height: 48, radius: 16)),
            ],
          ),
          const SizedBox(height: 20),
          const AppSkeleton(width: 60, height: 14),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < 7; i++)
                AppSkeleton(width: 58, height: 34, radius: 17),
            ],
          ),
        ]),
        card([
          title(60),
          for (var i = 0; i < 2; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            const AppSkeleton(height: 18),
          ],
        ]),
        card([
          title(80),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            const AppSkeleton(height: 18),
          ],
        ]),
      ],
    };
  }
}
