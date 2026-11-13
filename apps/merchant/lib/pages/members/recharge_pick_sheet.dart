import '../../kit/buttons.dart';
import 'packages/package_choices.dart' show PackageChoices;

import 'package:flutter/material.dart';

import '../../kit/kit.dart';
import '../../kit/async_kit.dart';

class RechargePickSheet extends StatefulWidget {
  final List<Map<String, dynamic>>? packages;
  final String initial;
  const RechargePickSheet({super.key, this.packages, this.initial = ''});
  @override
  State<RechargePickSheet> createState() => _RechargePickSheetState();
}

class _RechargePickSheetState extends State<RechargePickSheet> {
  late String selected = widget.initial;

  @override
  Widget build(BuildContext context) {
    if (widget.packages == null) {
      return const ErrorView(error: AppError('缺少在售套餐数据'));
    }
    return hbox(
      bg: dk(context, Color(0xFFFFFFFF), Color(0xFF18181B)),
      radius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
        bottomRight: Radius.circular(0),
        bottomLeft: Radius.circular(0),
      ),
      pad: EdgeInsets.fromLTRB(20, 10, 20, bottomInset(context)),
      child: hcol(
        [
          Align(
            alignment: Alignment.topCenter,
            child: hbox(
              w: 40,
              h: 5,
              bg: dk(context, Color(0xFFD4D4D8), Color(0xFF3F3F46)),
              radius: BorderRadius.circular(3),
            ),
          ),
          Text(
            '选择次卡套餐',
            style: hts(
              20,
              dk(context, Color(0xFF18181B), Color(0xFFFAFAFA)),
              w: FontWeight.w600,
              lh: 28,
            ),
          ),
          PackageChoices(
            packages: widget.packages!,
            selectedId: selected,
            onSelected: (id) => setState(() => selected = id),
          ),
          Text(
            '已下架的套餐不可售卖，不在此列出',
            style: hts(
              12,
              dk(context, Color(0xFF71717A), Color(0xFF9A9AA3)),
              lh: 17,
            ),
          ),
          AppButton(
            label: '确定',
            kind: AppButtonKind.primary,
            size: AppButtonSize.large,
            expanded: true,
            onPressed: () => Navigator.of(context).pop(selected),
          ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 14,
      ),
    );
  }
}
