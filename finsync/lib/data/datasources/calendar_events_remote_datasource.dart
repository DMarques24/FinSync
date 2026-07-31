import 'package:finsync/data/models/calendar_events_model.dart';

abstract class CalendarEventsRemoteDatasource {
  Future<List<CalendarEventsModel>> getAllCalendarEvents();
  Future<void> insertCalendarEvents(CalendarEventsModel calendarEvent);
  Future<void> deleteCalendarEvent(int id);

  /// Apaga todas as repetições da série. Devolve quantas foram apagadas.
  Future<int> deleteCalendarEventSeries(String seriesId);

  /// Tenta reservar o evento para ser lançado. Devolve `true` só a quem
  /// conseguiu marcá-lo — se dois ecrãs pedirem ao mesmo tempo, apenas um
  /// recebe `true` e o movimento não é criado em duplicado.
  Future<bool> markCalendarEventApplied(int id);
}
