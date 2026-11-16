import 'package:autocare_ui_kit/autocare_ui_kit.dart'
    show AppSegmented, SegmentItem;
import 'package:flutter/material.dart';

import '../kit/keyboard.dart';
import '../pages/members/member_models.dart';
import '../theme.dart';
import 'app_icon.dart';
import 'common.dart';

/// 开单、预约共用的「客户」卡片（设计稿 Order / OrderEmpty / OrderWalkIn、AppointmentAdd*）。
///
/// 标题右侧是「会员 / 散客」切换；会员页签没选会员时是蓝色的「选择会员」入口，选了之后显示
/// 会员信息和「更换」，有车辆的话下面是车辆一行；散客页签的内容由 [walkInBody] 提供。
class CustomerCard extends StatelessWidget {
  final bool walkIn;
  final ValueChanged<bool> onWalkInChanged;

  /// 是否已选了会员（会员页签）。
  final bool hasMember;
  final Member member;

  /// 会员名称下面的一行小字，如「余额 ¥3,680 · 洗车次卡剩 8 次」。
  final String subtitle;
  final VoidCallback onPick;
  final Widget walkInBody;
  const CustomerCard({
    super.key,
    required this.walkIn,
    required this.onWalkInChanged,
    required this.hasMember,
    required this.member,
    required this.subtitle,
    required this.onPick,
    required this.walkInBody,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('客户', style: ts(15, w: FontWeight.w600, h: 22)),
            ),
            SizedBox(
              width: 132,
              child: AppSegmented<bool>(
                selected: walkIn,
                onChanged: onWalkInChanged,
                items: const [
                  SegmentItem(value: false, label: '会员'),
                  SegmentItem(value: true, label: '散客'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (walkIn)
          walkInBody
        else if (!hasMember)
          _choose()
        else ...[
          _memberTile(),
          ..._vehicle(),
        ],
      ],
    ),
  );

  /// 没选会员：蓝色入口，点击打开会员选择弹层。
  Widget _choose() => Semantics(
    button: true,
    label: '选择会员',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: C.primarySoft,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: C.card, shape: BoxShape.circle),
              child: Center(
                child: AppIcon('search', size: 20, color: C.primaryInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '选择会员',
                    style: ts(
                      15,
                      w: FontWeight.w600,
                      color: C.primaryInk,
                      h: 22,
                    ),
                  ),
                  Opacity(
                    opacity: .8,
                    child: Text(
                      '车牌 / 手机号 / 姓名',
                      style: ts(12, color: C.primaryInk, h: 16),
                    ),
                  ),
                ],
              ),
            ),
            AppIcon('chevronRight', size: 16, color: C.primaryInk),
          ],
        ),
      ),
    ),
  );

  Widget _memberTile() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: C.inset,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Avatar(member.name.isEmpty ? '?' : member.name.substring(0, 1)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(15, w: FontWeight.w600, h: 22),
                    ),
                  ),
                  const SizedBox(width: 6),
                  LevelBadge(member.level),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts(12, color: C.muted, h: 16),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: '更换会员',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPick,
            child: Text(
              '更换',
              style: ts(13, w: FontWeight.w500, color: C.primaryInk, h: 18),
            ),
          ),
        ),
      ],
    ),
  );

  /// 会员名下的第一辆车：车牌 + 「品牌车型 · 颜色」；没有车辆就不显示这一行。
  List<Widget> _vehicle() {
    final first = ((member.data?['vehicles'] as List?)?.firstOrNull as Map?);
    if (first == null || '${first['plate'] ?? ''}'.isEmpty) return const [];
    final model = [
      '${first['brand_model'] ?? ''}',
      '${first['color'] ?? ''}',
    ].where((s) => s.isNotEmpty).join(' · ');
    return [
      const SizedBox(height: 12),
      Container(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            Text('车辆', style: ts(14, color: C.sub, h: 20)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: C.plate,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFF5B9BF0), width: 1.5),
              ),
              child: Text(
                member.plate,
                style: ts(11, w: FontWeight.w600, color: Colors.white, h: 16),
              ),
            ),
            if (model.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(model, style: ts(14, h: 20)),
            ],
          ],
        ),
      ),
    ];
  }
}

/// 客户卡片里的输入行：浅灰圆角底，左侧标签（固定宽度），右侧输入框。
class CustomerField extends StatelessWidget {
  final String label;
  final bool required;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final int? maxLength;
  const CustomerField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.required = false,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 44),
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: C.inset,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          child: Text.rich(
            TextSpan(
              text: label,
              children: [
                if (required)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: C.redInk),
                  ),
              ],
            ),
            style: ts(13, color: C.sub),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            maxLength: maxLength,
            onTapOutside: onTapOutsideDismiss,
            style: ts(14, h: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              counterText: '',
              hintText: hint,
              hintStyle: ts(14, color: C.muted),
            ),
          ),
        ),
      ],
    ),
  );
}
