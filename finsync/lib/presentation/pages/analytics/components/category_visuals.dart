import 'package:finsync/domain/entities/expense.dart';
import 'package:flutter/material.dart';


const List<Color> categoryChartPalette = [
  Color(0xFF4338CA), // indigo (AppColors.secondary)
  Color(0xFF22C55E), // verde
  Color(0xFFF59E0B), // laranja
  Color(0xFFEF4444), // vermelho
  Color(0xFF0EA5E9), // azul
  Color(0xFFA855F7), // roxo
  Color(0xFFEC4899), // rosa
  Color(0xFF14B8A6), // verde-azulado
];

Color categoryColor(int index) =>
    categoryChartPalette[index % categoryChartPalette.length];

const Map<String, IconData> _categoryIcons = {
  "Alimentação": Icons.restaurant_rounded,
  "Transportes": Icons.directions_car_filled_rounded,
  "Compras": Icons.shopping_bag_rounded,
  "Subscrições": Icons.autorenew_rounded,
  "Saúde": Icons.favorite_rounded,
  "Lazer": Icons.sports_esports_rounded,
};

IconData categoryIcon(String category) =>
    _categoryIcons[category] ?? Icons.payments_rounded;

class CategorySlice {
  final String category;
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
  final byCategory = <String, double>{};

  for (final expense in expenses) {
    if (expense.type != ExpenseType.despesa) continue;
    final category = expense.category.trim().isEmpty
        ? 'Sem categoria'
        : expense.category.trim();
    byCategory[category] = (byCategory[category] ?? 0) + expense.price;
  }

  final total = byCategory.values.fold<double>(0, (sum, value) => sum + value);

  final sorted = byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return [
    for (var i = 0; i < sorted.length; i++)
      CategorySlice(
        category: sorted[i].key,
        total: sorted[i].value,
        percent: total <= 0 ? 0 : (sorted[i].value / total) * 100,
        color: categoryColor(i),
      ),
  ];
}
