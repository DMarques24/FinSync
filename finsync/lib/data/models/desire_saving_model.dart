import 'package:finsync/domain/entities/desire_saving.dart';

class DesireSavingModel {
  final int id;
  final int desireId;
  final double amount;
  final DateTime date;

  const DesireSavingModel({
    required this.id,
    required this.desireId,
    required this.amount,
    required this.date,
  });

  factory DesireSavingModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['created_at'];

    return DesireSavingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      desireId: (json['desire_id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'desire_id': desireId,
      'amount': amount,
      'created_at': date.toIso8601String(),
      'user_id': userId,
    };
  }

  DesireSaving toEntity() {
    return DesireSaving(
      id: id,
      desireId: desireId,
      amount: amount,
      date: date,
    );
  }
}
