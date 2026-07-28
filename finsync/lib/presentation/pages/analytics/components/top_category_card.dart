import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/analytics/components/category_visuals.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';
import 'package:flutter/material.dart';

class TopCategoryCard extends StatelessWidget {
  final List<CategorySlice> slices;

  const TopCategoryCard({super.key, required this.slices});

  @override
  Widget build(BuildContext context) {
    if (slices.isEmpty) {
      return Text(
        "Sem despesas registadas.",
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    final top = slices.first;
    final percentLabel = '${top.percent.toStringAsFixed(0)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: top.color.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(top.category.icon, color: top.color, size: 26),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    categoryLabel(top.category),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentLabel do total de despesas',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Text(
              AppCurrency.format(top.total),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: top.color,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.border),
              FractionallySizedBox(
                widthFactor: (top.percent / 100).clamp(0.0, 1.0),
                child: Container(height: 8, color: top.color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
