import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/components/desire_card.dart';
import 'package:finsync/presentation/pages/desire/components/review_prompt_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              child: Icon(
                Icons.flag_rounded,
                color: AppColors.secondary,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tr('desire.no_goals_title'),
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tr('desire.no_goals_subtitle'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Só o primeiro por reavaliar. Empilhar cinco cartões amarelos de uma
    // vez faz com que sejam todos ignorados; um de cada vez ainda é lido.
    final pending = desires.where((desire) => desire.needsReview()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pending.isNotEmpty)
          ReviewPromptCard(
            key: ValueKey('review-${pending.first.id}'),
            desire: pending.first,
          ),

        ...desires.map(
          (desire) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DesireCard(
              image: desire.image,
              name: desire.name,
              price: desire.price,
              saved: desire.saved,
              date: _formatDate(desire.date),
              onTap: () => context.push('/desire/${desire.id}'),
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
