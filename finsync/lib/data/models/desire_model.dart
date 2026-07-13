import 'package:finsync/domain/entities/desire.dart';

class DesireModel {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final String image;

  DesireModel({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    required this.image,
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
      image: json['image'] as String,
    );
  }

  Desire toEntity() {
    return Desire(id: id, name: name, price: price, date: date, image: image);
  }
}
