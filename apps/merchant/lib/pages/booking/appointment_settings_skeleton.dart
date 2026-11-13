import '../../kit/buttons.dart';

import 'package:flutter/material.dart';

import '../../kit/async_kit.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

/// 仅预约设置首次读取时使用；固定页头和底栏在 300ms 延迟期间也保持可见。
class AppointmentSettingsSkeleton extends StatelessWidget {
  final bool showBlocks;
  const AppointmentSettingsSkeleton({super.key, this.showBlocks = true});

  @override
  Widget build(BuildContext context) => HPage(
    bg: dk(context, const Color(0xFFF4F4F5), const Color(0xFF09090B)),
    height: 1671,
    flow: hbox(
      pad: EdgeInsets.fromLTRB(20, topInset(context), 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              AppIconButton(
                svg: dk(context, Svgs.s0, Svgs.s1),
                semanticLabel: "返回",
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  '预约设置',
                  textAlign: TextAlign.center,
                  style: hts(
                    17,
                    dk(
                      context,
                      const Color(0xFF18181B),
                      const Color(0xFFFAFAFA),
                    ),
                    w: FontWeight.w600,
                    lh: 24,
                  ),
                ),
              ),
              const SizedBox(width: 44, height: 44),
            ],
          ),
          if (showBlocks) ...[
            const SizedBox(height: 16),
            _section(context, '在线预约', const [58, 58]),
            const SizedBox(height: 16),
            // 定休日多选采用 44px 热区，两行比旧 34px 标签增加 20px。
            _section(context, '可预约时间', const [70, 58, 86, 76, 96]),
            const SizedBox(height: 16),
            _section(context, '接待规则', const [76, 76, 76, 76, 76, 98]),
            const SizedBox(height: 16),
            _section(context, '预约通知', const [54, 54, 54]),
          ],
        ],
      ),
    ),
    overlays: [
      HBottomDock(
        child: hbox(
          bg: dk(
            context,
            const Color.fromRGBO(255, 255, 255, 0.94),
            const Color.fromRGBO(9, 9, 11, 0.92),
          ),
          pad: EdgeInsets.fromLTRB(20, 12, 20, bottomInset(context)),
          child: hbox(
            h: 50,
            bg: dk(context, const Color(0xFF18181B), const Color(0xFFFAFAFA)),
            radius: BorderRadius.circular(25),
            child: Center(
              child: Text(
                '保存设置',
                style: hts(
                  15,
                  dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
                  w: FontWeight.w600,
                  lh: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _section(
    BuildContext context,
    String title,
    List<double> rowHeights,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: hts(
            13,
            dk(context, const Color(0xFF52525B), const Color(0xFFA8A8B3)),
            w: FontWeight.w500,
            lh: 18,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < rowHeights.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  indent: 16,
                  color: dk(
                    context,
                    const Color(0xFFEFEFF1),
                    const Color(0xFF2A2A2E),
                  ),
                ),
              SizedBox(
                height: rowHeights[i],
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSkeleton(width: 112, height: 14),
                            SizedBox(height: 6),
                            AppSkeleton(width: 164, height: 11),
                          ],
                        ),
                      ),
                      AppSkeleton(width: 42, height: 24, radius: 12),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}
