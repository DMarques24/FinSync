import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class CardList extends StatelessWidget {
  final String nome;
  final String categoria;
  final String data;
  final double price;
  final IconData icon;

  const CardList({
    super.key,
    required this.nome,
    required this.categoria,
    required this.data,
    required this.price,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),

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
              color: AppColors.secondary.withOpacity(.10),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: AppColors.secondary, size: 28),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
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
                    color: AppColors.secondary.withOpacity(.08),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Text(
                    categoria,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  data,
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
                "- ${price.toStringAsFixed(2)} €",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Icon(
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
