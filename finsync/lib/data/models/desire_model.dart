import 'package:finsync/domain/entities/desire.dart';

class DesireModel {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final String? image;

  DesireModel({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.image,
  });

  factory DesireModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'];
    return DesireModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      date: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': name,
      'price': price,
      'image': image,
      'date': date.toIso8601String(),
      'user_id': userId,
    };
  }

  Desire toEntity() {
    return Desire(id: id, name: name, price: price, date: date, image: image);
  }
}
