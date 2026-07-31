import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';

class ParsedTransaction {
  final String name;
  final double price;
  final DateTime date;
  final ExpenseCategory? category;
  final ExpenseType type;

  final double confidence;

  final String rawLine;

  const ParsedTransaction({
    required this.name,
    required this.price,
    required this.date,
    required this.category,
    required this.type,
    required this.confidence,
    required this.rawLine,
  });

  bool get isReliable => confidence >= 0.6;

  ParsedTransaction copyWith({
    String? name,
    double? price,
    DateTime? date,
    ExpenseCategory? category,
    ExpenseType? type,
    // Com `category ?? this.category` não há forma de voltar a "sem
    // categoria". É preciso quando um movimento deixa de ser receita e a
    // categoria `rendimento` que tinha passa a não servir.
    bool clearCategory = false,
  }) {
    return ParsedTransaction(
      name: name ?? this.name,
      price: price ?? this.price,
      date: date ?? this.date,
      category: clearCategory ? null : (category ?? this.category),
      type: type ?? this.type,
      confidence: confidence,
      rawLine: rawLine,
    );
  }


  Expense toExpense() {
    return Expense(
      id: 0,
      name: name,
      price: price,
      category: category!,
      date: date,
      type: type,
    );
  }
}
