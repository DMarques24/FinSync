import 'package:finsync/domain/entities/calendar_event.dart';

class CalendarEventsModel {
  final int id;
  final String nameEvent;
  final double price;
  final DateTime dateEvent;
  final CalendarEventType type;
  final bool repeatMonthly;

  CalendarEventsModel({
    required this.id,
    required this.nameEvent,
    required this.price,
    required this.dateEvent,
    this.type = CalendarEventType.despesa,
    this.repeatMonthly = false,
  });

  factory CalendarEventsModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['event_date'];
    return CalendarEventsModel(
      id: json['id'] as int,
      nameEvent: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      dateEvent: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      type: CalendarEventType.values.firstWhere(
        (value) => value.name == json['type'],
        orElse: () => CalendarEventType.despesa,
      ),
      repeatMonthly: json['repeat_monthly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': nameEvent,
      'price': price,
      'event_date': dateEvent.toIso8601String(),
      'user_id': userId,
      'type': type.name,
      'repeat_monthly': repeatMonthly,
    };
  }

  CalendarEventEntity toEntity() {
    return CalendarEventEntity(
      id: id,
      name: nameEvent,
      price: price,
      date: dateEvent,
      type: type,
      repeatMonthly: repeatMonthly,
    );
  }
}
