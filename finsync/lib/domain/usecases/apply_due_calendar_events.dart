import 'package:finsync/domain/repositories/calendar_event_repository.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';

/// Lança como movimentos os eventos cuja data já chegou.
///
/// É isto que faz um evento agendado passar a contar: até ao dia marcado
/// ele é só um lembrete no calendário; nesse dia passa a ser uma linha na
/// tabela de movimentos, e é essa linha que aparece na Home e altera o
/// saldo. O evento em si nunca mexe no saldo — se mexesse, o valor era
/// contado duas vezes.
///
/// Pode ser chamado as vezes que forem precisas: a marcação é feita antes
/// da inserção e é a base de dados que garante que só acontece uma vez.
class ApplyDueCalendarEvents {
  final CalendarEventRepository calendarRepository;
  final ExpenseRepository expenseRepository;

  ApplyDueCalendarEvents(this.calendarRepository, this.expenseRepository);

  /// Devolve quantos eventos foram lançados nesta passagem.
  Future<int> call({DateTime? reference}) async {
    final today = reference ?? DateTime.now();

    final events = await calendarRepository.getAllCalendarEvents();

    final due = events.where(
      (event) => !event.isApplied && event.isDueOn(today),
    );

    if (due.isEmpty) return 0;

    var applied = 0;

    for (final event in due) {
      // Reservar primeiro, inserir depois. Ao contrário, uma falha entre
      // as duas operações deixava o movimento criado e o evento por
      // marcar — e ele voltava a ser lançado no arranque seguinte.
      final claimed = await calendarRepository.markCalendarEventApplied(
        event.id,
      );
      if (!claimed) continue;

      await expenseRepository.insertExpense(event.toExpense());
      applied++;
    }

    return applied;
  }
}
