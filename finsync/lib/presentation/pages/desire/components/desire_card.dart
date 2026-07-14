import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class DesireCard extends StatelessWidget {
  final String? image;
  final String name;
  final double price;
  //final double saved;
  final String date;
  final VoidCallback? onTap;

  const DesireCard({
    super.key,
    this.image,
    required this.name,
    required this.price,
    // required this.saved,
    required this.date,
    this.onTap,
  });

  bool get _hasRemoteImage =>
      image != null &&
      (image!.startsWith('http://') || image!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    // final progress = (saved / price).clamp(0, 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: AppColors.surface,

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: AppColors.border),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                              width: 100,
                              height: 100,
                              color: AppColors.background,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: AppColors.background,
                        child: const Icon(
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
                      "${price.toStringAsFixed(2)} €",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
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
