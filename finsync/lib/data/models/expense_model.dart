import 'package:finsync/domain/entities/expense.dart';

class ExpenseModel {
  final int id;
  final String name;
  final double price;
  final String category;
  final DateTime date;
  final ExpenseType type;

  ExpenseModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.date,
    this.type = ExpenseType.despesa,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_at'];
    return ExpenseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      category: json['category']?.toString() ?? '',
      date: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      type: ExpenseType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => ExpenseType.despesa,
      ),
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': name,
      'price': price,
      'category': category,
      'created_at': date.toIso8601String(),
      'user_id': userId,
      'type': type.name,
    };
  }

  Expense toEntity() {
    return Expense(
      id: id,
      name: name,
      price: price,
      category: category,
      date: date,
      type: type,
    );
  }
}
