import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/feature_row.dart';
import 'package:flutter/material.dart';

class FeaturesStep extends StatelessWidget {
  const FeaturesStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tr('onboarding.how_it_works_title'), style: AppTextStyles.headingLarge),

          const SizedBox(height: 8),

          Text(
            tr('onboarding.how_it_works_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          FeatureRow(
            icon: Icons.home_rounded,
            title: tr('onboarding.feature_home_title'),
            description: tr('onboarding.feature_home_desc'),
          ),

          const SizedBox(height: 24),

          FeatureRow(
            icon: Icons.favorite_rounded,
            title: tr('onboarding.feature_goals_title'),
            description: tr('onboarding.feature_goals_desc'),
          ),

          const SizedBox(height: 24),

          FeatureRow(
            icon: Icons.person_rounded,
            title: tr('onboarding.feature_profile_title'),
            description: tr('onboarding.feature_profile_desc'),
          ),
        ],
      ),
    );
  }
}
