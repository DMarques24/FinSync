import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/entities/expense_category.dart';

class CalendarEventsModel {
  final int id;
  final String nameEvent;
  final double price;
  final DateTime dateEvent;
  final CalendarEventType type;
  final ExpenseCategory category;
  final bool repeatMonthly;
  final DateTime? appliedAt;
  final String? seriesId;

  CalendarEventsModel({
    required this.id,
    required this.nameEvent,
    required this.price,
    required this.dateEvent,
    this.type = CalendarEventType.despesa,
    this.category = ExpenseCategory.lazer,
    this.repeatMonthly = false,
    this.appliedAt,
    this.seriesId,
  });

  factory CalendarEventsModel.fromJson(Map<String, dynamic> json) {
    final rawDate = json['event_date'];

    final type = CalendarEventType.values.firstWhere(
      (value) => value.name == json['type'],
      orElse: () => CalendarEventType.despesa,
    );

    return CalendarEventsModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nameEvent: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      dateEvent: rawDate is DateTime
          ? rawDate
          : DateTime.tryParse(rawDate?.toString() ?? '') ?? DateTime.now(),
      type: type,
      // Eventos criados antes desta coluna existir vêm sem categoria. O
      // tipo é a melhor pista que temos para os classificar.
      category:
          ExpenseCategory.fromDb(json['category']?.toString()) ??
          (type == CalendarEventType.receita
              ? ExpenseCategory.income
              : ExpenseCategory.lazer),
      repeatMonthly: json['repeat_monthly'] as bool? ?? false,
      appliedAt: DateTime.tryParse(json['applied_at']?.toString() ?? ''),
      seriesId: json['series_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': nameEvent,
      'price': price,
      'event_date': dateEvent.toIso8601String(),
      'user_id': userId,
      'type': type.name,
      'category': category.dbValue,
      'repeat_monthly': repeatMonthly,
      // Num evento novo isto é sempre null. Vai no JSON por causa do
      // "desfazer": restaurar um evento que já tinha sido contabilizado
      // tem de o recriar já contabilizado, senão era lançado outra vez e
      // o movimento ficava duplicado.
      'applied_at': appliedAt?.toIso8601String(),
      'series_id': seriesId,
    };
  }

  CalendarEventEntity toEntity() {
    return CalendarEventEntity(
      id: id,
      name: nameEvent,
      price: price,
      date: dateEvent,
      type: type,
      category: category,
      repeatMonthly: repeatMonthly,
      appliedAt: appliedAt,
      seriesId: seriesId,
    );
  }
}
