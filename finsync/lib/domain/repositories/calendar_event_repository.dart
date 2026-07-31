import 'package:finsync/domain/entities/calendar_event.dart';

abstract class CalendarEventRepository {
  Future<List<CalendarEventEntity>> getAllCalendarEvents();

  Future<void> insertCalendarEvent(CalendarEventEntity event);

  Future<void> deleteCalendarEvent(int id);

  /// Apaga todas as repetições da série. Devolve quantas foram apagadas.
  Future<int> deleteCalendarEventSeries(String seriesId);

  /// Marca o evento como lançado. `false` se já estava lançado.
  Future<bool> markCalendarEventApplied(int id);
}
