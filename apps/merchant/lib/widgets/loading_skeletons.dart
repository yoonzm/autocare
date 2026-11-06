import 'package:flutter/material.dart';
import 'package:autocare_async_kit/async_kit.dart';

import '../theme.dart';

/// 无头像的服务价格行；保持设计稿的分类标题和分组卡片。
class SkeletonServiceList extends StatelessWidget {
  const SkeletonServiceList({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSkeleton(width: 72, height: 12),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: C.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 16),
              Padding(
                key: ValueKey('skeleton-service-row-$i'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppSkeleton(width: 105, height: 16),
                          SizedBox(height: 7),
                          AppSkeleton(width: 148, height: 12),
                        ],
                      ),
                    ),
                    const AppSkeleton(width: 62, height: 17),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

/// 卡种使用独立大卡片，不能用头像列表行代替。
class SkeletonTierList extends StatelessWidget {
  const SkeletonTierList({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 5; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        Container(
          key: ValueKey('skeleton-tier-card-$i'),
          height: 126,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: AppSkeleton(width: 112, height: 21)),
                  AppSkeleton(width: 54, height: 19),
                ],
              ),
              Spacer(),
              AppSkeleton(width: 178, height: 13),
            ],
          ),
        ),
      ],
    ],
  );
}

/// 仅用在首次取预填资料时，保留真实标题，内容区按字段或详情卡片占位。
class SkeletonDataPage extends StatelessWidget {
  final String title;
  final bool detail;
  const SkeletonDataPage({super.key, required this.title, this.detail = false});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Material(
                  color: C.card,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: detail
              ? const SkeletonDetailCards()
              : const SkeletonFormFields(),
        ),
      ],
    ),
  );
}

class SkeletonFormFields extends StatelessWidget {
  const SkeletonFormFields({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 4; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 70, height: 13),
              SizedBox(height: 14),
              AppSkeleton(height: 44, radius: 12),
            ],
          ),
        ),
      ],
    ],
  );
}

class SkeletonDetailCards extends StatelessWidget {
  const SkeletonDetailCards({super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < 3; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: C.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(width: 110, height: 18),
              SizedBox(height: 18),
              AppSkeleton(height: 13),
              SizedBox(height: 12),
              AppSkeleton(width: 190, height: 13),
            ],
          ),
        ),
      ],
    ],
  );
}
