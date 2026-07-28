import 'package:finsync/domain/entities/expense_category.dart';

enum ExpenseType { despesa, receita }

class Expense {
  final int id;
  final String name;
  final double price;
  final ExpenseCategory category;
  final DateTime date;
  final ExpenseType type;

  Expense({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.date,
    this.type = ExpenseType.despesa,
  });
}
