import 'package:finsync/core/notifications/notification_prefs_store.dart';
import 'package:finsync/core/notifications/notification_scheduler.dart';
import 'package:finsync/data/datasources/expense_remote_datasource.dart'
    show kAnalyticsExpensesLimit;
import 'package:finsync/domain/repositories/calendar_event_repository.dart';
import 'package:finsync/domain/repositories/desire_repository.dart';
import 'package:finsync/domain/repositories/expense_repository.dart';
import 'package:finsync/domain/repositories/user_repository.dart';

/// Reagenda todos os avisos a partir do que está na base de dados.
///
/// Chamado quando a app abre e sempre que as preferências mudam. Recomeça
/// sempre do zero — reconciliar o que já estava agendado com o que passou
/// a ser verdade dava muito mais trabalho do que voltar a agendar tudo.
class RescheduleNotifications {
  final CalendarEventRepository calendarRepository;
  final DesireRepository desireRepository;
  final ExpenseRepository expenseRepository;
  final UserRepository userRepository;

  RescheduleNotifications(
    this.calendarRepository,
    this.desireRepository,
    this.expenseRepository,
    this.userRepository,
  );

  Future<void> call() async {
    final prefs = await NotificationPrefsStore.load();

    // Sem nada ligado não vale a pena ir buscar dados nenhuns.
    if (!prefs.hasAnyEnabled) {
      await NotificationScheduler.rescheduleAll(
        prefs: prefs,
        events: const [],
        desires: const [],
        expenses: const [],
      );
      return;
    }

    final events = await calendarRepository.getAllCalendarEvents();
    final desires = await desireRepository.getAllDesires();
    final expenses = await expenseRepository.getAllExpenses(
      limit: kAnalyticsExpensesLimit,
    );

    final profiles = await userRepository.getUser();
    final monthlyIncome = profiles.isEmpty ? 0.0 : profiles.first.monthlyIncome;

    await NotificationScheduler.rescheduleAll(
      prefs: prefs,
      events: events,
      desires: desires,
      expenses: expenses,
      monthlyIncome: monthlyIncome,
    );
  }
}
