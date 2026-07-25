import 'package:flutter/material.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class DesireCard extends StatelessWidget {
  final String? image;
  final String name;
  final double price;
  final double saved;
  final String date;
  final VoidCallback? onTap;

  const DesireCard({
    super.key,
    this.image,
    required this.name,
    required this.price,
    this.saved = 0,
    required this.date,
    this.onTap,
  });

  bool get _hasRemoteImage =>
      image != null &&
      (image!.startsWith('http://') || image!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final progress = price > 0 ? (saved / price).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.border),

        boxShadow: AppColors.softShadow,
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

                child: _hasRemoteImage
                    ? Image.network(
                        image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            width: 100,
                            height: 100,
                            color: AppColors.background,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.secondary,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              width: 100,
                              height: 100,
                              color: AppColors.background,
                              child: Icon(
                                Icons.image_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: AppColors.background,
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.secondary,
                        ),
                      ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      AppCurrency.format(price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(AppColors.success),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Guardado ${AppCurrency.format(saved)} de ${AppCurrency.format(price)}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Objetivo: $date",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
