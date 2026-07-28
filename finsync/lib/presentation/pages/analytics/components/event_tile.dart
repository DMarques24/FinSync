import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
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
            child: Text(
              event.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
