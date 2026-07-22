import 'package:finsync/data/datasources/calendar_events_remote_datasource.dart';
import 'package:finsync/data/models/calendar_events_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarEventsRemoteDatasourceImpl
    extends CalendarEventsRemoteDatasource {
  CalendarEventsRemoteDatasourceImpl();

  final supabase = Supabase.instance.client;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Utilizador não autenticado para guardar eventos.');
    }
    return user.id;
  }

  @override
  Future<List<CalendarEventsModel>> getAllCalendarEvents() async {
    final List<dynamic> result = await supabase
        .from('calendar_events')
        .select()
        .eq('user_id', userId);
    return result.map((json) => CalendarEventsModel.fromJson(json)).toList();
  }

  @override
  Future<void> insertCalendarEvents(CalendarEventsModel calendarEvent) async {
    try {
      await supabase
          .from('calendar_events')
          .insert(calendarEvent.toJson(userId));
    } on PostgrestException catch (e) {
      throw Exception('Erro ao guardar evento: ${e.message}');
    }
  }
}
