import 'package:flutter/material.dart';

enum ExpenseCategory {
  lazer(Icons.sports_esports_rounded),
  transporte(Icons.directions_car_filled_rounded),
  alimentacao(Icons.restaurant_rounded),
  investimentos(Icons.trending_up_rounded),
  poupanca(Icons.savings_rounded),
  rendimento(Icons.payments_rounded);

  final IconData icon;

  const ExpenseCategory(this.icon);

  String get dbValue => name;

  String get labelKey => 'category.$name';

  /// Categoria reservada ao dinheiro que entra.
  ///
  /// Uma receita não se classifica como uma despesa — perguntar "isto foi
  /// Lazer ou Transporte?" a um salário não quer dizer nada. A alternativa
  /// seria tornar a coluna anulável e andar com `!` em cada leitura; um
  /// valor próprio no enum mantém o tipo fechado e a base de dados coerente.
  static const income = ExpenseCategory.rendimento;

  bool get isIncome => this == income;

  /// As categorias que o utilizador pode de facto escolher para uma despesa.
  /// `values` inclui `rendimento`, que nunca deve aparecer num seletor.
  static List<ExpenseCategory> get selectable =>
      values.where((category) => !category.isIncome).toList(growable: false);

  static ExpenseCategory? fromDb(String? value) {
    if (value == null) return null;
    for (final category in ExpenseCategory.values) {
      if (category.name == value) return category;
    }
    return null;
  }
}
