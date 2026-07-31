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

  @override
  Future<bool> markCalendarEventApplied(int id) async {
    try {
      // O `isFilter('applied_at', null)` é o que torna isto seguro: a
      // condição é avaliada pela base de dados no momento do UPDATE, por
      // isso duas chamadas simultâneas nunca marcam a mesma linha. Sem o
      // `select()` não saberíamos quantas linhas foram afetadas.
      final List<dynamic> updated = await supabase
          .from('calendar_events')
          .update({'applied_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', id)
          .eq('user_id', userId)
          .isFilter('applied_at', null)
          .select('id');

      return updated.isNotEmpty;
    } on PostgrestException catch (e) {
      throw Exception('Erro ao lançar evento: ${e.message}');
    }
  }

  @override
  Future<void> deleteCalendarEvent(int id) async {
    try {
      await supabase
          .from('calendar_events')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw Exception('Erro ao remover evento: ${e.message}');
    }
  }

  @override
  Future<int> deleteCalendarEventSeries(String seriesId) async {
    try {
      // Um único DELETE apaga todas as repetições de uma vez. Fazê-lo
      // linha a linha deixaria a série meio apagada se falhasse a meio.
      final List<dynamic> deleted = await supabase
          .from('calendar_events')
          .delete()
          .eq('series_id', seriesId)
          .eq('user_id', userId)
          .select('id');

      return deleted.length;
    } on PostgrestException catch (e) {
      throw Exception('Erro ao remover eventos repetidos: ${e.message}');
    }
  }
}
