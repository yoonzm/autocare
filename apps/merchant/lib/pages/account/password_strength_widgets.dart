import 'package:flutter/material.dart';

import '../../backend/password_validation.dart';
import '../../kit/kit.dart';
import '../../resources/merchant_svgs.dart';

class PasswordRuleItem {
  final String label;
  final bool satisfied;

  const PasswordRuleItem({required this.label, required this.satisfied});
}

class PasswordStrengthBar extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthBar({super.key, required this.strength});

  @override
  Widget build(BuildContext context) {
    final inactiveColor = dk(
      context,
      const Color(0xFFE4E4E7),
      const Color(0xFF3A3A40),
    );
    final activeColor = switch (strength) {
      PasswordStrength.none => inactiveColor,
      PasswordStrength.weak => dk(
        context,
        const Color(0xFFF31260),
        const Color(0xFFFF7B7E),
      ),
      PasswordStrength.medium => const Color(0xFFF5A524),
      PasswordStrength.strong ||
      PasswordStrength.veryStrong => const Color(0xFF17C964),
    };
    final labelColor = switch (strength) {
      PasswordStrength.none => dk(
        context,
        const Color(0xFF71717A),
        const Color(0xFFA8A8B3),
      ),
      PasswordStrength.weak => dk(
        context,
        const Color(0xFFA43433),
        const Color(0xFFFF7B7E),
      ),
      PasswordStrength.medium => dk(
        context,
        const Color(0xFF9A6300),
        const Color(0xFFF5C451),
      ),
      PasswordStrength.strong || PasswordStrength.veryStrong => dk(
        context,
        const Color(0xFF2B7745),
        const Color(0xFF5FD48C),
      ),
    };

    return hcol(
      [
        hrow(
          [
            for (var i = 0; i < 4; i++)
              Expanded(
                flex: 1,
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  constrainedAxis: Axis.horizontal,
                  child: hbox(
                    h: 4,
                    bg: i < strength.segments ? activeColor : inactiveColor,
                    radius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
          main: MainAxisAlignment.start,
          cross: CrossAxisAlignment.stretch,
          gap: 6,
          intrinsic: true,
        ),
        Text(strength.label, style: hts(12, labelColor, w: FontWeight.w500)),
      ],
      main: MainAxisAlignment.start,
      cross: CrossAxisAlignment.stretch,
      gap: 8,
    );
  }
}

class PasswordRulesCard extends StatelessWidget {
  final List<PasswordRuleItem> rules;

  const PasswordRulesCard({super.key, required this.rules});

  @override
  Widget build(BuildContext context) {
    final satisfiedTextColor = dk(
      context,
      const Color(0xFF3F3F46),
      const Color(0xFFD4D4D8),
    );
    final unsatisfiedTextColor = dk(
      context,
      const Color(0xFFA1A1AA),
      const Color(0xFF71717A),
    );
    final dotColor = dk(
      context,
      const Color(0xFFD4D4D8),
      const Color(0xFF52525B),
    );

    return hbox(
      bg: dk(context, const Color(0xFFFFFFFF), const Color(0xFF18181B)),
      radius: BorderRadius.circular(24),
      shadow: dk(
        context,
        const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 0),
            blurRadius: 1,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            offset: Offset(0, 1),
            blurRadius: 2,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
        const [
          BoxShadow(
            color: Color(0xFF26262B),
            offset: Offset(0, 0),
            blurRadius: 0,
            spreadRadius: 1,
          ),
        ],
      ),
      pad: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: hcol(
        [
          for (final rule in rules)
            hrow(
              [
                if (rule.satisfied)
                  hsvg(Svgs.s87, w: 14, h: 14)
                else
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Center(
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: dotColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    rule.label,
                    style: hts(
                      13,
                      rule.satisfied
                          ? satisfiedTextColor
                          : unsatisfiedTextColor,
                    ),
                  ),
                ),
              ],
              main: MainAxisAlignment.start,
              cross: CrossAxisAlignment.center,
              gap: 8,
            ),
        ],
        main: MainAxisAlignment.start,
        cross: CrossAxisAlignment.stretch,
        gap: 8,
      ),
    );
  }
}
