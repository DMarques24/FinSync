import 'package:finsync/domain/entities/calendar_event.dart';

abstract class CalendarEventRepository {
  Future<List<CalendarEventEntity>> getAllCalendarEvents();

  Future<void> insertCalendarEvent(CalendarEventEntity event);
}
