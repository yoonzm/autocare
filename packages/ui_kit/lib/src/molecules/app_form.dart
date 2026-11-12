import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../atoms/app_tap_target.dart';
import '../tokens/app_tokens.dart';
import 'app_card.dart';
import 'app_input_format.dart';

/// 表单卡片：连续排列的输入行放在同一张白色卡片里，行间 1px 分割线（左缩进 16），最后一行不画；
/// 不在每行外再包底色块。
class AppFormCard extends StatelessWidget {
  final List<Widget> children;
  const AppFormCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: AppDividedColumn(children: children),
  );
}

/// 标签宽度档：compact 64 · regular 72。
enum AppLabelWidth { compact, regular }

/// 行内输入（表单默认）：标签在左、输入在右对齐，行高至少 54。
/// 必填标签后加红星；单位放在输入右侧；错误时标签变红、行下方右对齐 12px 红字。
/// [hint] 必填：没有值时一定要有占位文字。
class AppFormRow extends StatelessWidget {
  final String label;
  final String hint;
  final bool required;
  final TextEditingController? controller;
  final AppInputFormat format;
  final TextInputType? keyboard;
  final String? suffix;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool enabled;
  final int? maxLength;
  final AppLabelWidth labelWidth;
  const AppFormRow({
    super.key,
    required this.label,
    required this.hint,
    this.required = false,
    this.controller,
    this.format = AppInputFormat.none,
    this.keyboard,
    this.suffix,
    this.errorText,
    this.onChanged,
    this.obscure = false,
    this.enabled = true,
    this.maxLength,
    this.labelWidth = AppLabelWidth.regular,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final hasError = errorText != null && errorText!.isNotEmpty;
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: labelWidth == AppLabelWidth.compact ? 64 : 72,
                child: Text.rich(
                  TextSpan(
                    text: label,
                    style: t.base.copyWith(
                      color: hasError ? t.requiredStar : t.inkSub,
                      fontWeight: FontWeight.w400,
                    ),
                    children: [
                      if (required)
                        TextSpan(
                          text: ' *',
                          style: TextStyle(color: t.requiredStar),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled,
                  obscureText: obscure,
                  textAlign: TextAlign.right,
                  keyboardType: keyboard ?? format.keyboard,
                  inputFormatters: [
                    ...format.formatters,
                    if (maxLength != null)
                      LengthLimitingTextInputFormatter(maxLength),
                  ],
                  onChanged: onChanged,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  style: t.body,
                  cursorColor: t.primary,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: t.body.copyWith(
                      color: t.inkMute,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (suffix != null) ...[
                const SizedBox(width: AppSpacing.s6),
                Text(
                  suffix!,
                  style: t.base.copyWith(
                    color: t.inkSub,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ],
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s4),
              child: Text(
                errorText!,
                textAlign: TextAlign.right,
                style: t.caption.copyWith(color: t.requiredStar),
              ),
            ),
        ],
      ),
    );
  }
}

/// 小数字输入（百分比、天数）：48 × 36 灰色框，居中，圆角 10，右边跟单位；中间可放换算提示。
class AppNumberBox extends StatelessWidget {
  final String label;
  final String hint;
  final String? suffix;
  final String? caption;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  const AppNumberBox({
    super.key,
    required this.label,
    required this.hint,
    this.suffix,
    this.caption,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      child: Row(
        children: [
          Text(
            label,
            style: t.base.copyWith(
              color: t.inkSub,
              fontWeight: FontWeight.w400,
            ),
          ),
          Expanded(
            child: caption == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8),
                    child: Text(
                      caption!,
                      textAlign: TextAlign.right,
                      style: t.caption,
                    ),
                  ),
          ),
          Container(
            width: 48,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.inset,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              keyboardType: AppInputFormat.decimal.keyboard,
              inputFormatters: AppInputFormat.decimal.formatters,
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              style: t.body,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: t.body.copyWith(
                  color: t.inkMute,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: AppSpacing.s6),
            Text(suffix!, style: t.base.copyWith(color: t.inkSub)),
          ],
        ],
      ),
    );
  }
}

/// 选择行（卡片内）：灰底块（圆角 14），标签在左，值在右，末尾小箭头。
/// 没选时值显示灰色占位，选了显示黑色值。
class AppSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback? onTap;
  const AppSelectField({
    super.key,
    required this.label,
    required this.placeholder,
    this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final empty = value == null || value!.isEmpty;
    return AppTapTarget(
      onTap: onTap,
      minWidth: 0,
      semanticLabel: '$label，${empty ? placeholder : value}',
      builder: (context, pressed) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s14),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            pressed ? t.pressedOverlay : Colors.transparent,
            t.inset,
          ),
          borderRadius: BorderRadius.circular(AppRadius.field),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: t.base.copyWith(
                color: t.inkSub,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: AppSpacing.s12),
            Expanded(
              child: Text(
                empty ? placeholder : value!,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: t.body.copyWith(color: empty ? t.inkMute : t.ink),
              ),
            ),
            const SizedBox(width: AppSpacing.s4),
            Icon(Icons.chevron_right_rounded, size: 18, color: t.inkFaint),
          ],
        ),
      ),
    );
  }
}

/// 金额输入（醒目数字）：灰底块、圆角 16，标签在左，¥ 和大号数字（26/32 · 600）在右，等宽数字。
/// 一个页面最多一两个，普通数字仍用行内输入。
class AppAmountField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  const AppAmountField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    final big = t.display.copyWith(
      fontSize: 26,
      height: 32 / 26,
      fontFeatures: AppTokens.tabular,
    );
    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
      decoration: BoxDecoration(
        color: t.inset,
        borderRadius: BorderRadius.circular(AppRadius.inset),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: t.base.copyWith(
              color: t.inkSub,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Row(
              children: [
                Text('¥', style: big.copyWith(color: t.inkSub, fontSize: 18)),
                const SizedBox(width: AppSpacing.s6),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    textAlign: TextAlign.right,
                    keyboardType: AppInputFormat.amount.keyboard,
                    inputFormatters: AppInputFormat.amount.formatters,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    style: big,
                    cursorColor: t.primary,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: big.copyWith(color: t.inkFaint),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 多行输入：标签在上（13/18 · 500），下方灰底块，圆角 14，内边距 10 × 12，最小高 64。
/// 单独放在卡片底部，不夹在行内输入之间。
class AppTextArea extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  const AppTextArea({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.onChanged,
    this.minLines = 2,
    this.maxLines = 6,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: t.small),
        const SizedBox(height: AppSpacing.s6),
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: AppSpacing.s10,
          ),
          decoration: BoxDecoration(
            color: t.inset,
            borderRadius: BorderRadius.circular(AppRadius.field),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            maxLength: maxLength,
            onTapOutside: (_) => FocusScope.of(context).unfocus(),
            style: t.body.copyWith(fontWeight: FontWeight.w400),
            cursorColor: t.primary,
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              counterText: '',
              hintText: hint,
              hintStyle: t.body.copyWith(
                color: t.inkMute,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
