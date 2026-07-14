import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/components/desire_card.dart';
import 'package:flutter/material.dart';

class DesiresList extends StatelessWidget {
  final List<Desire> desires;

  const DesiresList({super.key, required this.desires});

  @override
  Widget build(BuildContext context) {
    if (desires.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Ainda não tens objetivos",
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Adiciona um desejo para começares a poupar para ele.",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...desires.map(
          (desire) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DesireCard(
              image: desire.image,
              name: desire.name,
              price: desire.price,
              //  saved: desire.saved,
              date: _formatDate(desire.date),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
