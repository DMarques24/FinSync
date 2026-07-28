import 'package:flutter/material.dart';


enum ExpenseCategory {
  lazer(Icons.sports_esports_rounded),
  transporte(Icons.directions_car_filled_rounded),
  alimentacao(Icons.restaurant_rounded),
  investimentos(Icons.trending_up_rounded),
  poupanca(Icons.savings_rounded);

  final IconData icon;

  const ExpenseCategory(this.icon);

  String get dbValue => name;

  String get labelKey => 'category.$name';

  static ExpenseCategory? fromDb(String? value) {
    if (value == null) return null;
    for (final category in ExpenseCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }
}
