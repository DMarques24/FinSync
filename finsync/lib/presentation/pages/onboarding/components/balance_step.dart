import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BalanceStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const BalanceStep({required this.controller, required this.isLoading});

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
              Icons.savings_rounded,
              size: 46,
              color: AppColors.secondary,
            ),
          ),

          const SizedBox(height: 28),

          Text(tr('onboarding.balance_title'), style: AppTextStyles.headingLarge),

          const SizedBox(height: 10),

          Text(
            tr('onboarding.balance_subtitle'),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 32),

          TextFormField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyLarge,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: tr('onboarding.balance_label', {'symbol': AppCurrency.symbol}),
              prefixIcon: Icon(AppCurrency.icon, color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }
}
