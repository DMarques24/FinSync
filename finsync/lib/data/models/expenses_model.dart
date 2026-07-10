import 'package:finsync/domain/entities/expenses.dart';

class ExpensesModel {
  final int id;
  final String name;
  final double price;
  final String category;
  final DateTime date;

  ExpensesModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.date,
  });

  factory ExpensesModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    return ExpensesModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category']?.toString() ?? '',
      date: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Expenses toEntity() {
    return Expenses(
      id: id,
      name: name,
      price: price,
      category: category,
      date: date,
    );
  }
}
