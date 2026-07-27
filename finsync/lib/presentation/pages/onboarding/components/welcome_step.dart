import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              size: 46,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            tr('onboarding.welcome_title'),
            style: AppTextStyles.headingLarge,
          ),

          const SizedBox(height: 12),

          Text(
            tr('onboarding.welcome_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
