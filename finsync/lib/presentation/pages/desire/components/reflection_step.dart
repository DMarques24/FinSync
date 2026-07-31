import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire_reflection.dart';
import 'package:flutter/material.dart';

/// As cinco perguntas, com o resultado a atualizar-se enquanto se responde.
///
/// Mostrar o veredicto ao vivo é de propósito: a pessoa vê a avaliação a
/// mudar à medida que responde, o que a obriga a olhar para o conjunto em
/// vez de despachar as perguntas. Nunca bloqueia a criação — só devolve o
/// que ela própria acabou de dizer.
class ReflectionStep extends StatelessWidget {
  final DesireReflection reflection;
  final void Function(ReflectionQuestion question, bool answer) onAnswer;
  final bool enabled;

  const ReflectionStep({
    super.key,
    required this.reflection,
    required this.onAnswer,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('desire.reflection_title'),
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          tr('desire.reflection_subtitle'),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        for (final question in ReflectionQuestion.values) ...[
          _QuestionRow(
            question: question,
            answer: reflection.answerTo(question),
            enabled: enabled,
            onAnswer: (value) => onAnswer(question, value),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        const SizedBox(height: AppSpacing.xs),

        _VerdictCard(reflection: reflection),
      ],
    );
  }
}

class _QuestionRow extends StatelessWidget {
  final ReflectionQuestion question;
  final bool? answer;
  final bool enabled;
  final ValueChanged<bool> onAnswer;

  const _QuestionRow({
    required this.question,
    required this.answer,
    required this.enabled,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.all(AppRadius.md),
        border: Border.all(
          color: answer == null ? AppColors.border : AppColors.secondary,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(question.labelKey),
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr(question.hintKey),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _AnswerButton(
                  label: tr('desire.detail_reflection_yes'),
                  selected: answer == true,
                  color: AppColors.success,
                  onPressed: enabled ? () => onAnswer(true) : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _AnswerButton(
                  label: tr('desire.detail_reflection_no'),
                  selected: answer == false,
                  color: AppColors.textSecondary,
                  onPressed: enabled ? () => onAnswer(false) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback? onPressed;

  const _AnswerButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color.withValues(alpha: .12) : null,
        foregroundColor: selected ? color : AppColors.textSecondary,
        side: BorderSide(color: selected ? color : AppColors.border),
        minimumSize: const Size(0, AppSizes.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.all(AppRadius.sm),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _VerdictCard extends StatelessWidget {
  final DesireReflection reflection;

  const _VerdictCard({required this.reflection});

  Color _colorFor(ReflectionVerdict verdict) {
    switch (verdict) {
      case ReflectionVerdict.impulse:
        return AppColors.error;
      case ReflectionVerdict.think:
        return AppColors.warning;
      case ReflectionVerdict.worthwhile:
        return AppColors.success;
      case ReflectionVerdict.unanswered:
        return AppColors.textSecondary;
    }
  }

  IconData _iconFor(ReflectionVerdict verdict) {
    switch (verdict) {
      case ReflectionVerdict.impulse:
        return Icons.pan_tool_rounded;
      case ReflectionVerdict.think:
        return Icons.psychology_alt_rounded;
      case ReflectionVerdict.worthwhile:
        return Icons.verified_rounded;
      case ReflectionVerdict.unanswered:
        return Icons.help_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final verdict = reflection.verdict;
    final color = _colorFor(verdict);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: AppRadius.all(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: .30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_iconFor(verdict), size: 20, color: color),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  tr(verdict.titleKey),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                tr('desire.reflection_score', {
                  'score': '${reflection.score}',
                  'total': '${reflection.maxScore}',
                }),
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            tr(verdict.messageKey),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
