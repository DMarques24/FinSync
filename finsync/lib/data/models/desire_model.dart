import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_reflection.dart';
import 'package:finsync/domain/entities/desire_review.dart';

class DesireModel {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final String? image;
  final double saved;
  final DesireReflection reflection;
  final ReviewInterval reviewInterval;
  final DateTime? lastReviewedAt;
  final List<DesireReview> reviews;

  DesireModel({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.image,
    this.saved = 0,
    this.reflection = DesireReflection.empty,
    this.reviewInterval = ReviewInterval.monthly,
    this.lastReviewedAt,
    this.reviews = const [],
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
      saved: (json['saved'] as num?)?.toDouble() ?? 0,
      reflection: DesireReflection.fromJson(_asMap(json['reflection'])),
      reviewInterval: ReviewInterval.fromDays(
        (json['review_interval_days'] as num?)?.toInt(),
      ),
      lastReviewedAt: DateTime.tryParse(
        json['last_reviewed_at']?.toString() ?? '',
      ),
      reviews: _asList(
        json['reviews'],
      ).map(DesireReview.fromJson).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': name,
      'price': price,
      'image': image,
      'date': date.toIso8601String(),
      'user_id': userId,
      'saved': saved,
      'reflection': reflection.toJson(),
      'review_interval_days': reviewInterval.days,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'reviews': reviews.map((review) => review.toJson()).toList(),
    };
  }

  Desire toEntity() {
    return Desire(
      id: id,
      name: name,
      price: price,
      date: date,
      image: image,
      saved: saved,
      reflection: reflection,
      reviewInterval: reviewInterval,
      lastReviewedAt: lastReviewedAt,
      reviews: reviews,
    );
  }

  factory DesireModel.fromEntity(Desire desire) {
    return DesireModel(
      id: desire.id,
      name: desire.name,
      price: desire.price,
      date: desire.date,
      image: desire.image,
      saved: desire.saved,
      reflection: desire.reflection,
      reviewInterval: desire.reviewInterval,
      lastReviewedAt: desire.lastReviewedAt,
      reviews: desire.reviews,
    );
  }

  // O PostgREST devolve `jsonb` já convertido em Map/List, mas as linhas
  // criadas antes destas colunas existirem vêm a null. Estes dois ajudantes
  // evitam repetir a mesma verificação de tipo em cada campo.
  static Map<String, dynamic>? _asMap(Object? value) =>
      value is Map<String, dynamic> ? value : null;

  static List<Map<String, dynamic>> _asList(Object? value) {
    if (value is! List) return const [];

    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
