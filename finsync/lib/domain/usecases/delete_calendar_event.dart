import 'package:finsync/domain/repositories/calendar_event_repository.dart';

class DeleteCalendarEvent {
  final CalendarEventRepository repository;

  DeleteCalendarEvent(this.repository);

  Future<void> call(int id) {
    return repository.deleteCalendarEvent(id);
  }
}
