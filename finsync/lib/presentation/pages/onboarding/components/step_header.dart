import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';


class StepHeader extends StatelessWidget {
  final String badge;
  final String title;
  final String subtitle;

  const StepHeader({
    super.key,
    required this.badge,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: .10),
            borderRadius: AppRadius.all(999),
          ),
          child: Text(
            badge.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTextStyles.headingLarge.copyWith(height: 1.15),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          subtitle,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
