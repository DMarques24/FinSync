import 'package:flutter/material.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/expense.dart';

class ExpenseCard extends StatelessWidget {
  final String name;
  final String category;
  final String date;
  final double price;
  final ExpenseType type;

  const ExpenseCard({
    super.key,
    required this.name,
    required this.category,
    required this.date,
    required this.price,
    this.type = ExpenseType.despesa,
  });

  static const _categoryIcons = <String, IconData>{
    "Alimentação": Icons.restaurant_rounded,
    "Transportes": Icons.directions_car_filled_rounded,
    "Compras": Icons.shopping_bag_rounded,
    "Subscrições": Icons.autorenew_rounded,
    "Saúde": Icons.favorite_rounded,
    "Lazer": Icons.sports_esports_rounded,
  };

  IconData get _icon => _categoryIcons[category] ?? Icons.payments_rounded;

  bool get _isIncome => type == ExpenseType.receita;

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncome ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),

        border: Border.all(color: AppColors.border),
      ),

      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,

            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(_icon, color: AppColors.secondary, size: 26),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppCurrency.format(price, sign: _isIncome ? '+ ' : '- '),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
