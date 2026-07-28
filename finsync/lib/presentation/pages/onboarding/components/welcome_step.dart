import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/onboarding_hero_icon.dart';
import 'package:finsync/presentation/pages/onboarding/components/step_header.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OnboardingHeroIcon(
            icon: Icons.account_balance_wallet_rounded,
          ),

          const SizedBox(height: AppSpacing.xxl),

          StepHeader(
            badge: tr('onboarding.welcome_badge'),
            title: tr('onboarding.welcome_title'),
            subtitle: tr('onboarding.welcome_subtitle'),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          _ValuePoint(
            title: tr('onboarding.welcome_point_1_title'),
            description: tr('onboarding.welcome_point_1_desc'),
          ),

          const SizedBox(height: AppSpacing.xl),

          _ValuePoint(
            title: tr('onboarding.welcome_point_2_title'),
            description: tr('onboarding.welcome_point_2_desc'),
          ),
        ],
      ),
    );
  }
}

class _ValuePoint extends StatelessWidget {
  final String title;
  final String description;

  const _ValuePoint({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: .14),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            size: 15,
            color: AppColors.success,
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
