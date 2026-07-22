import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/repositories/calendar_event_repository.dart';

class InsertCalendarEvent {
  final CalendarEventRepository repository;

  InsertCalendarEvent(this.repository);

  Future<void> call(CalendarEventEntity event) {
    return repository.insertCalendarEvent(event);
  }
}
