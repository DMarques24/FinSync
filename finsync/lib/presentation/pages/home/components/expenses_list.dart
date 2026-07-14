import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/domain/entities/expenses.dart';

import 'card_list.dart';

class ExpensesList extends StatelessWidget {
  final List<Expenses> expenses;

  const ExpensesList({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Últimas Despesas",
              style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 12),
            Text(
              "Ainda não existem despesas para mostrar.",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Últimas Despesas",
            style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
          ),

          const SizedBox(height: 20),

          ...expenses.map(
            (expense) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CardList(
                nome: expense.name,
                categoria: expense.category,
                data: _formatDate(expense.date),
                price: expense.price,
                icon: Icons.payments_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
