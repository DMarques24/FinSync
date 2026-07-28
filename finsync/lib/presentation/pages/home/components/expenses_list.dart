import 'package:flutter/material.dart';

import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/domain/entities/expense.dart';

import 'expense_card.dart';


class ExpensesList extends StatefulWidget {
  final List<Expense> expenses;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;

  const ExpensesList({
    super.key,
    required this.expenses,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
  });

  @override
  State<ExpensesList> createState() => _ExpensesListState();
}

class _ExpensesListState extends State<ExpensesList> {
  @override
  Widget build(BuildContext context) {
    if (widget.expenses.isEmpty) return const _EmptyExpenses();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('home.recent_expenses'),
            style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 20),

          // A lista vive dentro de um scroll exterior (a página), por isso
          // não pode ter scroll próprio nem altura infinita.
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: widget.expenses.length + (widget.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Última posição: pede a página seguinte e mostra o
              // indicador enquanto ela não chega.
              if (index >= widget.expenses.length) {
                if (!widget.isLoadingMore) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.onLoadMore?.call();
                  });
                }
                return const _LoadingMoreRow();
              }

              final expense = widget.expenses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ExpenseCard(
                  // A chave evita que o Flutter reaproveite o cartão
                  // errado quando a lista cresce.
                  key: ValueKey(expense.id),
                  name: expense.name,
                  category: expense.category,
                  date: _formatDate(expense.date),
                  price: expense.price,
                  type: expense.type,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class _LoadingMoreRow extends StatelessWidget {
  const _LoadingMoreRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
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
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('home.recent_expenses'),
            style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 24),
          Center(
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
                    Icons.receipt_long_rounded,
                    color: AppColors.secondary,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tr('home.no_expenses_title'),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  tr('home.no_expenses_subtitle'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
