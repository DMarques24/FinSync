import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

/// Linha selecionável usada dentro do [CurrencyPickerSheet] para escolher a
/// moeda usada em toda a app.
class CurrencyOption extends StatelessWidget {
  final AppCurrencyType type;
  final bool selected;
  final VoidCallback onTap;

  const CurrencyOption({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.secondary : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondary.withValues(alpha: .10)
                : AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  type.symbol,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? AppColors.secondary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      type.code,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
