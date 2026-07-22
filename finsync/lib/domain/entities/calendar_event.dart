enum CalendarEventType { despesa, receita }

class CalendarEventEntity {
  final int id;
  final String name;
  final double price;
  final DateTime date;
  final CalendarEventType type;

  CalendarEventEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.date,
    this.type = CalendarEventType.despesa,
  });
}
