import 'dart:async';

import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A pergunta periódica, no topo da lista de desejos.
///
/// Aparece sozinha quando passa o intervalo escolhido. É aqui e não numa
/// caixa de diálogo de propósito: uma janela a interromper quem abriu a app
/// para ver outra coisa é fechada sem ler.
class ReviewPromptCard extends StatefulWidget {
  final Desire desire;

  const ReviewPromptCard({super.key, required this.desire});

  @override
  State<ReviewPromptCard> createState() => _ReviewPromptCardState();
}

class _ReviewPromptCardState extends State<ReviewPromptCard> {
  bool _isSaving = false;

  Future<void> _answer(bool stillWanted) async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final completer = Completer<void>();
      context.read<DesireBloc>().add(
        ReviewDesireEvent(widget.desire, stillWanted, completer: completer),
      );

      await completer.future.timeout(const Duration(seconds: 12));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stillWanted
                ? tr('desire.review_kept', {
                    'days': '${widget.desire.reviewInterval.days}',
                  })
                : tr('desire.review_dropped'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppErrorTranslator.translate(e))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  int get _daysSinceLastCheck {
    final reference =
        widget.desire.lastReviewedAt ?? widget.desire.reflection.answeredAt;

    if (reference == null) return widget.desire.reviewInterval.days;

    return DateTime.now().difference(reference).inDays;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: .08),
        borderRadius: AppRadius.all(AppRadius.xl),
        border: Border.all(color: AppColors.warning.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                size: 20,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  tr('desire.review_title'),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            tr('desire.review_question', {
              'days': '$_daysSinceLastCheck',
              'name': widget.desire.name,
            }),
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : () => _answer(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, AppSizes.minTouchTarget),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.all(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    tr('desire.review_keep'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSaving ? null : () => _answer(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: BorderSide(color: AppColors.border),
                    minimumSize: const Size(0, AppSizes.minTouchTarget),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.all(AppRadius.sm),
                    ),
                  ),
                  child: Text(
                    tr('desire.review_drop'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
