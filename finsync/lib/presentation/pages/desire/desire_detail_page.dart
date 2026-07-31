import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_reflection.dart';
import 'package:finsync/domain/entities/desire_saving.dart';
import 'package:finsync/domain/usecases/get_desire_savings.dart';
import 'package:finsync/presentation/pages/desire/components/add_saving_sheet.dart';
import 'package:finsync/presentation/pages/desire/components/savings_chart.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DesireDetailPage extends StatefulWidget {
  final int desireId;

  const DesireDetailPage({super.key, required this.desireId});

  @override
  State<DesireDetailPage> createState() => _DesireDetailPageState();
}

class _DesireDetailPageState extends State<DesireDetailPage> {
  List<DesireSaving> _savings = const [];
  bool _isLoadingSavings = true;
  String? _savingsError;

  @override
  void initState() {
    super.initState();
    _loadSavings();
  }

  Future<void> _loadSavings() async {
    setState(() {
      _isLoadingSavings = true;
      _savingsError = null;
    });

    try {
      final savings = await sl<GetDesireSavings>()(widget.desireId);
      if (!mounted) return;
      setState(() {
        _savings = savings;
        _isLoadingSavings = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _savingsError = AppErrorTranslator.translate(e);
        _isLoadingSavings = false;
      });
    }
  }

  Future<void> _openSavingSheet(Desire desire) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => BlocProvider.value(
        value: context.read<DesireBloc>(),
        child: AddSavingSheet(desire: desire),
      ),
    );

    // O histórico vive fora do bloco, por isso não vem no estado novo.
    await _loadSavings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          tr('desire.detail_title'),
          style: AppTextStyles.headingSmall,
        ),
      ),
      body: BlocBuilder<DesireBloc, DesireState>(
        builder: (context, state) {
          final desire = _findDesire(state);

          // O desejo pode ter deixado de existir enquanto o ecrã estava
          // aberto. Sair é melhor do que mostrar um ecrã vazio.
          if (desire == null) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }

          return RefreshIndicator(
            color: AppColors.secondary,
            onRefresh: _loadSavings,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.bottomNavClearance,
              ),
              children: [
                _Header(desire: desire),
                const SizedBox(height: AppSpacing.xl),
                _ProgressCard(desire: desire),
                const SizedBox(height: AppSpacing.lg),
                _PaceCard(desire: desire, savings: _savings),
                const SizedBox(height: AppSpacing.lg),
                _SavingsCard(
                  desire: desire,
                  savings: _savings,
                  isLoading: _isLoadingSavings,
                  error: _savingsError,
                  onRetry: _loadSavings,
                ),
                const SizedBox(height: AppSpacing.lg),
                _ReflectionCard(desire: desire),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton.icon(
                  onPressed: () => _openSavingSheet(desire),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(
                      double.infinity,
                      AppSizes.primaryButton,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.all(AppRadius.lg),
                    ),
                  ),
                  icon: const Icon(Icons.savings_rounded),
                  label: Text(tr('desire.add_saving')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Desire? _findDesire(DesireState state) {
    if (state is! DesireLoadedState) return null;

    for (final desire in state.desires) {
      if (desire.id == widget.desireId) return desire;
    }
    return null;
  }
}

// ── Cabeçalho ────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Desire desire;

  const _Header({required this.desire});

  bool get _hasImage =>
      desire.image != null &&
      (desire.image!.startsWith('http://') ||
          desire.image!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.all(AppRadius.lg),
          child: SizedBox(
            width: 84,
            height: 84,
            child: _hasImage
                ? Image.network(
                    desire.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                desire.name,
                style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppCurrency.format(desire.price),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tr('desire.goal_date', {'date': _formatDate(desire.date)}),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surface,
      child: Icon(Icons.image_outlined, color: AppColors.secondary),
    );
  }
}

// ── Progresso ────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final Desire desire;

  const _ProgressCard({required this.desire});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: tr('desire.detail_progress'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppCurrency.format(desire.saved),
                style: AppTextStyles.headingLarge.copyWith(fontSize: 30),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '${(desire.progress * 100).round()}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: desire.progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation(AppColors.success),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                label: tr('desire.detail_saved'),
                value: AppCurrency.format(desire.saved),
                color: AppColors.success,
              ),
              _Stat(
                label: tr('desire.detail_remaining'),
                value: AppCurrency.format(desire.remaining),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Ritmo ────────────────────────────────────────────────────────────

class _PaceCard extends StatelessWidget {
  final Desire desire;
  final List<DesireSaving> savings;

  const _PaceCard({required this.desire, required this.savings});

  @override
  Widget build(BuildContext context) {
    if (desire.isComplete) {
      return _Card(
        title: tr('desire.detail_pace'),
        child: _Verdict(
          icon: Icons.celebration_rounded,
          color: AppColors.success,
          message: tr('desire.detail_complete'),
        ),
      );
    }

    final points = savings
        .map(
          (saving) =>
              DesireSavingPoint(date: saving.date, amount: saving.amount),
        )
        .toList();

    final target = desire.monthlyTarget();
    final pace = desire.monthlyPace(points);
    final onTrack = desire.isOnTrack(points);

    return _Card(
      title: tr('desire.detail_pace'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('desire.detail_monthly_target', {
              'amount': AppCurrency.format(target),
            }),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tr('desire.detail_monthly_target_months', {
              'months': '${desire.monthsUntilGoal()}',
            }),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          Text(
            savings.isEmpty
                ? tr('desire.detail_pace_none')
                : tr('desire.detail_pace_current', {
                    'amount': AppCurrency.format(pace),
                  }),
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: AppSpacing.md),

          _Verdict(
            icon: onTrack
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: onTrack ? AppColors.success : AppColors.warning,
            message: onTrack
                ? tr('desire.detail_on_track')
                : tr('desire.detail_behind'),
          ),
        ],
      ),
    );
  }
}

class _Verdict extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;

  const _Verdict({
    required this.icon,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: AppRadius.all(AppRadius.sm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Histórico ────────────────────────────────────────────────────────

class _SavingsCard extends StatelessWidget {
  final Desire desire;
  final List<DesireSaving> savings;
  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;

  const _SavingsCard({
    required this.desire,
    required this.savings,
    required this.isLoading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: tr('desire.detail_savings_history'),
      trailing: savings.isEmpty
          ? null
          : Text(
              tr('desire.detail_savings_count', {
                'count': '${savings.length}',
              }),
              style: AppTextStyles.labelSmall,
            ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 120,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.secondary,
            ),
          ),
        ),
      );
    }

    if (error != null) {
      return Column(
        children: [
          Text(
            error!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(tr('common.retry')),
          ),
        ],
      );
    }

    if (savings.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          tr('desire.detail_savings_empty'),
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SavingsChart(savings: savings, goal: desire.price),

        const SizedBox(height: AppSpacing.lg),

        // Do mais recente para o mais antigo: é a ordem em que interessa.
        for (final saving in savings.reversed)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 16,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _formatDate(saving.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  AppCurrency.format(saving.amount, sign: '+ '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Reflexão ─────────────────────────────────────────────────────────

class _ReflectionCard extends StatelessWidget {
  final Desire desire;

  const _ReflectionCard({required this.desire});

  @override
  Widget build(BuildContext context) {
    final reflection = desire.reflection;

    return _Card(
      title: tr('desire.detail_reflection'),
      trailing: reflection.isComplete
          ? Text(
              tr('desire.reflection_score', {
                'score': '${reflection.score}',
                'total': '${reflection.maxScore}',
              }),
              style: AppTextStyles.labelSmall,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!reflection.isComplete)
            Text(
              tr('desire.detail_no_reflection'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          else
            for (final question in ReflectionQuestion.values)
              _AnswerRow(
                question: question,
                answer: reflection.answerTo(question),
              ),

          if (desire.reviews.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Divider(color: AppColors.border),
            const SizedBox(height: AppSpacing.md),
            Text(
              tr('desire.review_history'),
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final review in desire.reviews.reversed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      review.stillWanted
                          ? Icons.check_circle_outline_rounded
                          : Icons.help_outline_rounded,
                      size: 16,
                      color: review.stillWanted
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        review.stillWanted
                            ? tr('desire.review_history_kept')
                            : tr('desire.review_history_dropped'),
                        style: AppTextStyles.bodySmall,
                      ),
                    ),
                    Text(
                      _formatDate(review.at),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (desire.nextReviewDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              tr('desire.review_next', {
                'date': _formatDate(desire.nextReviewDate!),
              }),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final ReflectionQuestion question;
  final bool? answer;

  const _AnswerRow({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final isYes = answer == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isYes ? Icons.check_rounded : Icons.close_rounded,
            size: 16,
            color: isYes ? AppColors.success : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              tr(question.labelKey),
              style: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            isYes
                ? tr('desire.detail_reflection_yes')
                : tr('desire.detail_reflection_no'),
            style: AppTextStyles.bodySmall.copyWith(
              color: isYes ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cartão base ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const _Card({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.all(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: AppTextStyles.headingSmall),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          child,
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
