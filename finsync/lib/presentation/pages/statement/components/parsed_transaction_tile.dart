import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/parsed_transaction.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';
import 'package:flutter/material.dart';

class ParsedTransactionTile extends StatelessWidget {
  final ParsedTransaction transaction;
  final bool selected;
  final List<String> categories;
  final VoidCallback onToggle;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<ExpenseType> onTypeChanged;

  const ParsedTransactionTile({
    super.key,
    required this.transaction,
    required this.selected,
    required this.categories,
    required this.onToggle,
    required this.onCategoryChanged,
    required this.onTypeChanged,
  });

  bool get _isIncome => transaction.type == ExpenseType.receita;

  @override
  Widget build(BuildContext context) {
    final amountColor = _isIncome ? AppColors.success : AppColors.error;
    final needsCategory = transaction.category.isEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? AppColors.secondary : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: selected,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.secondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      transaction.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  AppCurrency.format(
                    transaction.price,
                    sign: _isIncome ? '+ ' : '- ',
                  ),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: needsCategory ? null : transaction.category,
                  isExpanded: true,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    hintText: tr('statement.choose_category'),
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category,
                        child: Text(
                          categoryLabel(category),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) onCategoryChanged(value);
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                flex: 2,
                child: SegmentedButton<ExpenseType>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: ExpenseType.despesa,
                      label: Text(
                        tr('statement.expense_short'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    ButtonSegment(
                      value: ExpenseType.receita,
                      label: Text(
                        tr('statement.income_short'),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                  selected: {transaction.type},
                  onSelectionChanged: (selection) =>
                      onTypeChanged(selection.first),
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    selectedBackgroundColor: amountColor.withValues(alpha: .15),
                    selectedForegroundColor: amountColor,
                  ),
                ),
              ),
            ],
          ),

          if (!transaction.isReliable) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tr('statement.low_confidence', {
                      'line': transaction.rawLine,
                    }),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}
