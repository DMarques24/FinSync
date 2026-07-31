import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/presentation/pages/onboarding/components/feature_card.dart';
import 'package:finsync/presentation/pages/onboarding/components/step_header.dart';
import 'package:flutter/material.dart';

class FeaturesStep extends StatelessWidget {
  const FeaturesStep({super.key});

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
          StepHeader(
            badge: tr('onboarding.how_it_works_badge'),
            title: tr('onboarding.how_it_works_title'),
            subtitle: tr('onboarding.how_it_works_subtitle'),
          ),

          const SizedBox(height: AppSpacing.xxl),

          FeatureCard(
            icon: Icons.home_rounded,
            title: tr('onboarding.feature_home_title'),
            description: tr('onboarding.feature_home_desc'),
          ),

          const SizedBox(height: AppSpacing.md),

          FeatureCard(
            icon: Icons.analytics_rounded,
            title: tr('onboarding.feature_analytics_title'),
            description: tr('onboarding.feature_analytics_desc'),
          ),

          const SizedBox(height: AppSpacing.md),

          FeatureCard(
            icon: Icons.favorite_rounded,
            title: tr('onboarding.feature_goals_title'),
            description: tr('onboarding.feature_goals_desc'),
          ),

          const SizedBox(height: AppSpacing.md),

          FeatureCard(
            icon: Icons.person_rounded,
            title: tr('onboarding.feature_profile_title'),
            description: tr('onboarding.feature_profile_desc'),
          ),
        ],
      ),
    );
  }
}
