import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';
import 'package:flutter/material.dart';

class EventTile extends StatelessWidget {
  final CalendarEventEntity event;
  final VoidCallback? onDelete;

  const EventTile({super.key, required this.event, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isIncome = event.type == CalendarEventType.receita;
    final color = isIncome ? AppColors.success : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isIncome
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // `Wrap` e não `Row`: são três elementos de largura
                // imprevisível (o estado, o ícone de repetição e a
                // categoria) num espaço que já é o que sobra depois do
                // valor e do botão de apagar. Numa `Row` não há por onde
                // encolher e transborda; aqui passam à linha de baixo.
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Diz se o valor já entrou nas contas ou se ainda está
                    // à espera do dia. Sem isto, um evento futuro e um
                    // passado são indistinguíveis na lista.
                    _StatusBadge(isApplied: event.isApplied),

                    // Avisa que este evento não está sozinho — apagá-lo
                    // leva as outras repetições atrás.
                    if (event.isPartOfSeries)
                      Tooltip(
                        message: tr('analytics.event_repeats'),
                        child: Icon(
                          Icons.repeat_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                    // Numa receita a categoria é sempre "Rendimento" —
                    // dizer o óbvio só rouba espaço ao nome do evento.
                    if (!isIncome)
                      Text(
                        categoryLabel(event.category),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            AppCurrency.format(event.price, sign: isIncome ? '+ ' : '- '),
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),

          if (onDelete != null)
            // `tooltip` serve de rótulo para leitores de ecrã (senão o
            // botão é anunciado apenas como "botão"), e as constraints
            // garantem os 48px mínimos de área de toque mesmo com o
            // ícone a 20px.
            IconButton(
              onPressed: onDelete,
              tooltip: tr('analytics.remove'),
              constraints: const BoxConstraints(
                minWidth: AppSizes.minTouchTarget,
                minHeight: AppSizes.minTouchTarget,
              ),
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isApplied;

  const _StatusBadge({required this.isApplied});

  @override
  Widget build(BuildContext context) {
    final color = isApplied ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isApplied ? tr('analytics.event_applied') : tr('analytics.event_pending'),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
