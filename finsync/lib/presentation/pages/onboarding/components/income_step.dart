import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/onboarding/components/onboarding_hero_icon.dart';
import 'package:finsync/presentation/pages/onboarding/components/step_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Quanto a pessoa recebe por mês.
///
/// É o dado que faltava para o gráfico de fluxo das Análises deixar de ser
/// ficção: até agora a origem dizia "Salário" sem valor nenhum por trás.
/// Também é o que permite avisar de um mês caro logo no primeiro mês, em
/// vez de esperar por três para ter média.
class IncomeStep extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSubmitted;

  const IncomeStep({
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
          const OnboardingHeroIcon(icon: Icons.payments_rounded),

          const SizedBox(height: AppSpacing.xxl),

          StepHeader(
            badge: tr('onboarding.income_badge'),
            title: tr('onboarding.income_title'),
            subtitle: tr('onboarding.income_subtitle'),
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
              labelText: tr('onboarding.income_label', {
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
                  tr('onboarding.income_hint'),
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
