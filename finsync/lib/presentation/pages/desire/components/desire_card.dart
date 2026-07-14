import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class DesireComponent extends StatelessWidget {
  final String image;
  final String name;
  final double price;
  //final double saved;
  final String date;
  final VoidCallback? onTap;

  const DesireComponent({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    // required this.saved,
    required this.date,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // final progress = (saved / price).clamp(0, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.border),
      ),

      child: InkWell(
        borderRadius: BorderRadius.circular(24),

        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),

                child: Image.network(
                  image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${price.toStringAsFixed(2)} €",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Objetivo: $date",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
