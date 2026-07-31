import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/repositories/calendar_event_repository.dart';

/// Remove um evento do calendário.
///
/// Num evento repetido, remove a série toda. É a regra que faz sentido:
/// quem cancela uma renda mensal quer cancelar a renda, não a de março.
/// A decisão vive aqui e não no bloco para que qualquer ecrã que venha a
/// apagar eventos se comporte da mesma maneira.
///
/// Os movimentos que as repetições já tenham gerado não são tocados — esses
/// gastos aconteceram e continuam no histórico.
class DeleteCalendarEvent {
  final CalendarEventRepository repository;

  DeleteCalendarEvent(this.repository);

  /// Devolve quantos eventos foram removidos.
  Future<int> call(CalendarEventEntity event) async {
    final seriesId = event.seriesId;

    if (seriesId == null) {
      await repository.deleteCalendarEvent(event.id);
      return 1;
    }

    return repository.deleteCalendarEventSeries(seriesId);
  }
}
