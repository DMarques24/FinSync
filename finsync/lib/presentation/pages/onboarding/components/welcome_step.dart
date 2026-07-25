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
            "Bem-vindo ao FinSync 👋",
            style: AppTextStyles.headingLarge,
          ),

          const SizedBox(height: 12),

          Text(
            "A tua nova app para organizares as tuas finanças, controlares "
            "despesas e alcançares os teus objetivos com mais clareza.",
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
