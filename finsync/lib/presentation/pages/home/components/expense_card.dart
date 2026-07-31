import 'package:flutter/material.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';

class ExpenseCard extends StatelessWidget {
  final String name;
  final ExpenseCategory category;
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

  IconData get _icon => category.icon;

  bool get _isIncome => type == ExpenseType.receita;

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncome ? AppColors.success : AppColors.error;

    // Numa receita a categoria é sempre "Rendimento". Pintá-la de verde,
    // como o valor, deixa claro à primeira vista que é dinheiro a entrar.
    final categoryColor = _isIncome ? AppColors.success : AppColors.secondary;

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
              color: categoryColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(_icon, color: categoryColor, size: 26),
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
                    color: categoryColor.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    categoryLabel(category),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: categoryColor,
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
