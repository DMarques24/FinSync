import 'package:finsync/data/models/calendar_events_model.dart';

abstract class CalendarEventsRemoteDatasource {
  Future<List<CalendarEventsModel>> getAllCalendarEvents();
  Future<void> insertCalendarEvents(CalendarEventsModel calendarEvent);
  Future<void> deleteCalendarEvent(int id);
}
