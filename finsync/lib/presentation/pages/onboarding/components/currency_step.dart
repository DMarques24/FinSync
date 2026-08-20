import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/onboarding_hero_icon.dart';
import 'package:finsync/presentation/pages/onboarding/components/step_header.dart';
import 'package:flutter/material.dart';

/// Escolha da moeda, antes de se pedir qualquer valor.
///
/// Vem antes do saldo de propósito: a app assumia euro em silêncio, e quem
/// usa outra moeda escrevia o primeiro valor errado sem se aperceber.
class CurrencyStep extends StatelessWidget {
  final AppCurrencyType selected;
  final ValueChanged<AppCurrencyType> onChanged;
  final bool enabled;

  const CurrencyStep({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
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
          const OnboardingHeroIcon(icon: Icons.public_rounded),

          const SizedBox(height: AppSpacing.xxl),

          StepHeader(
            badge: tr('onboarding.currency_badge'),
            title: tr('onboarding.currency_title'),
            subtitle: tr('onboarding.currency_subtitle'),
          ),

          const SizedBox(height: AppSpacing.xxl),

          for (final currency in AppCurrencyType.values) ...[
            _CurrencyOption(
              currency: currency,
              isSelected: currency == selected,
              onTap: enabled ? () => onChanged(currency) : null,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  final AppCurrencyType currency;
  final bool isSelected;
  final VoidCallback? onTap;

  const _CurrencyOption({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.secondary.withValues(alpha: .08)
          : AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.all(AppRadius.md),
        side: BorderSide(
          color: isSelected ? AppColors.secondary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Text(
                  currency.symbol,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headingMedium.copyWith(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr('currency.${currency.code.toLowerCase()}'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      currency.code,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
