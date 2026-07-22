import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/repositories/calendar_event_repository.dart';

class GetAllCalendarEvents {
  final CalendarEventRepository repository;

  GetAllCalendarEvents(this.repository);

  Future<List<CalendarEventEntity>> call() async {
    return await repository.getAllCalendarEvents();
  }
}
