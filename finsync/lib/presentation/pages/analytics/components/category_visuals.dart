import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:flutter/material.dart';


Color categoryColor(ExpenseCategory category) =>
    AppColors.chartPalette[category.index % AppColors.chartPalette.length];

class CategorySlice {
  final ExpenseCategory category;
  final double total;
  final double percent;
  final Color color;

  const CategorySlice({
    required this.category,
    required this.total,
    required this.percent,
    required this.color,
  });
}


List<CategorySlice> buildCategorySlices(List<Expense> expenses) {
  final byCategory = <ExpenseCategory, double>{};

  for (final expense in expenses) {
    if (expense.type != ExpenseType.despesa) continue;
    byCategory[expense.category] =
        (byCategory[expense.category] ?? 0) + expense.price;
  }

  final total = byCategory.values.fold<double>(0, (sum, value) => sum + value);

  final sorted = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    for (final entry in sorted)
      CategorySlice(
        category: entry.key,
        total: entry.value,
        percent: total <= 0 ? 0 : (entry.value / total) * 100,
        color: categoryColor(entry.key),
      ),
  ];
}
