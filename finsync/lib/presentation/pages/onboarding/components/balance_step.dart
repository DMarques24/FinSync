import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/onboarding_hero_icon.dart';
import 'package:finsync/presentation/pages/onboarding/components/step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BalanceStep extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSubmitted;

  const BalanceStep({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmitted,
  });

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
          const OnboardingHeroIcon(icon: Icons.savings_rounded),

          const SizedBox(height: AppSpacing.xxl),

          StepHeader(
            badge: tr('onboarding.balance_badge'),
            title: tr('onboarding.balance_title'),
            subtitle: tr('onboarding.balance_subtitle'),
          ),

          const SizedBox(height: AppSpacing.xxxl),

      
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmitted(),
            style: AppTextStyles.headingMedium.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: tr('onboarding.balance_label', {
                'symbol': AppCurrency.symbol,
              }),
              hintText: '0,00',
              hintStyle: AppTextStyles.headingMedium.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.disabled,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.md,
                ),
                child: Text(
                  AppCurrency.symbol,
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  tr('onboarding.balance_hint'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
