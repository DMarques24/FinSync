import 'package:finsync/data/datasources/calendar_events_remote_datasource.dart';
import 'package:finsync/data/models/calendar_events_model.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/repositories/calendar_event_repository.dart';

class CalendarEventsRepositoryImpl implements CalendarEventRepository {
  final CalendarEventsRemoteDatasource remoteDatasource;

  CalendarEventsRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<CalendarEventEntity>> getAllCalendarEvents() async {
    final models = await remoteDatasource.getAllCalendarEvents();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> insertCalendarEvent(CalendarEventEntity event) async {
    final model = CalendarEventsModel(
      id: event.id,
      nameEvent: event.name,
      price: event.price,
      dateEvent: event.date,
      type: event.type,
    );
    await remoteDatasource.insertCalendarEvents(model);
  }
}
