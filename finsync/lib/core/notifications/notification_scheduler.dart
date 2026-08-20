import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:finsync/core/notifications/notification_service.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/expense.dart';

/// Transforma o que está na base de dados nos avisos a agendar.
///
/// Corre sempre que a app abre e recomeça do zero: cancela tudo o que
/// estava agendado e volta a agendar a partir dos dados atuais. Sem isto,
/// um evento apagado continuava a avisar, e um evento adiado avisava na
/// data antiga.
class NotificationScheduler {
  NotificationScheduler._();

  /// Quantos dias de lembretes diários se agendam de cada vez.
  ///
  /// Não há repetição automática de propósito: a alternativa obrigava a
  /// saber o nome do fuso horário do telemóvel, e um pacote a mais só para
  /// isso não compensa. Em troca, quem passar mais de um mês sem abrir a
  /// app deixa de receber o lembrete diário — o que, convenhamos, já não
  /// lhe estava a fazer diferença.
  static const _dailyHorizonDays = 30;

  /// A partir de quantas vezes acima da média mensal é que avisamos.
  static const _overspendFactor = 1.3;

  /// Que fatia do rendimento já gasta é que dispara o aviso. 80% deixa
  /// margem para reagir; a 100% já não há nada a fazer.
  static const _incomeShareLimit = 0.8;

  static Future<void> rescheduleAll({
    required NotificationPrefsState prefs,
    required List<CalendarEventEntity> events,
    required List<Desire> desires,
    required List<Expense> expenses,
    double monthlyIncome = 0,
  }) async {
    await NotificationService.cancelAllScheduled();

    if (!prefs.hasAnyEnabled) return;

    if (prefs.eventReminderEnabled) await _scheduleEvents(events);
    if (prefs.dailyLogEnabled) await _scheduleDailyLog(prefs);
    if (prefs.goalSavingEnabled) await _scheduleGoalSavings(desires);
    if (prefs.overspendEnabled) {
      await _checkOverspend(expenses, monthlyIncome);
    }
  }

  // ── Eventos do calendário ──────────────────────────────────────────

  static Future<void> _scheduleEvents(
    List<CalendarEventEntity> events,
  ) async {
    for (final event in events) {
      if (event.isApplied) continue;

      // Véspera às 9h. Avisar no próprio dia de manhã já não dá tempo de
      // fazer nada em relação a uma conta que sai nesse dia.
      final when = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
        9,
      ).subtract(const Duration(days: 1));

      final isIncome = event.type == CalendarEventType.receita;

      await NotificationService.scheduleAt(
        id: NotificationService.eventId(event.id),
        title: tr('notifications.event_title'),
        body: tr(
          isIncome
              ? 'notifications.event_body_income'
              : 'notifications.event_body_expense',
          {
            'name': event.name,
            'amount': AppCurrency.format(event.price),
          },
        ),
        when: when,
      );
    }
  }

  // ── Lembrete diário ────────────────────────────────────────────────

  static Future<void> _scheduleDailyLog(NotificationPrefsState prefs) async {
    final now = DateTime.now();

    for (var day = 0; day < _dailyHorizonDays; day++) {
      final when = DateTime(
        now.year,
        now.month,
        now.day + day,
        prefs.dailyLogHour,
        prefs.dailyLogMinute,
      );

      await NotificationService.scheduleAt(
        id: NotificationService.dailyLogId(day),
        title: tr('notifications.daily_log_title'),
        body: tr('notifications.daily_log_body'),
        when: when,
      );
    }
  }

  // ── Poupança por objetivo ──────────────────────────────────────────

  static Future<void> _scheduleGoalSavings(List<Desire> desires) async {
    final now = DateTime.now();

    for (final desire in desires) {
      if (desire.isComplete) continue;

      final target = desire.monthlyTarget();
      if (target <= 0) continue;

      // Dia 1 do mês seguinte, às 10h: quem acabou de receber o ordenado
      // ainda tem margem para separar o dinheiro.
      final when = DateTime(now.year, now.month + 1, 1, 10);

      await NotificationService.scheduleAt(
        id: NotificationService.goalSavingId(desire.id),
        title: tr('notifications.goal_saving_title'),
        body: tr('notifications.goal_saving_body', {
          'name': desire.name,
          'amount': AppCurrency.format(target),
        }),
        when: when,
      );
    }
  }

  // ── Gasto acima da média ───────────────────────────────────────────

  /// Compara o mês atual com a média dos meses anteriores.
  ///
  /// Este é mostrado na hora e não agendado: a conta só se pode fazer com
  /// os movimentos à frente, e agendar um aviso para daqui a uns dias com
  /// base em números de hoje seria dizer uma coisa que pode já não ser
  /// verdade quando chegasse.
  static Future<void> _checkOverspend(
    List<Expense> expenses,
    double monthlyIncome,
  ) async {
    final now = DateTime.now();
    final byMonth = <String, double>{};

    for (final expense in expenses) {
      if (expense.type != ExpenseType.despesa) continue;

      final key = '${expense.date.year}-${expense.date.month}';
      byMonth[key] = (byMonth[key] ?? 0) + expense.price;
    }

    final currentKey = '${now.year}-${now.month}';
    final current = byMonth.remove(currentKey) ?? 0;

    if (current <= 0) return;

    // Com rendimento declarado, o aviso funciona já no primeiro mês: a
    // referência é o que a pessoa recebe, não um histórico que ainda não
    // existe. Sem ele, é preciso esperar por dois meses fechados para ter
    // média — comparar contra um único mês não diz nada.
    if (monthlyIncome > 0) {
      if (current < monthlyIncome * _incomeShareLimit) return;

      final share = (current / monthlyIncome) * 100;

      await NotificationService.showNow(
        id: NotificationService.overspendId(),
        title: tr('notifications.overspend_title_notif'),
        body: tr('notifications.overspend_income_body', {
          'percent': '${share.round()}',
          'amount': AppCurrency.format(current),
        }),
      );
      return;
    }

    if (byMonth.length < 2) return;

    final average = byMonth.values.reduce((a, b) => a + b) / byMonth.length;

    if (current < average * _overspendFactor) return;

    final difference = ((current / average) - 1) * 100;

    await NotificationService.showNow(
      id: NotificationService.overspendId(),
      title: tr('notifications.overspend_title_notif'),
      body: tr('notifications.overspend_body', {
        'percent': '${difference.round()}',
        'amount': AppCurrency.format(current),
      }),
    );
  }

  // ── Objetivo concluído ─────────────────────────────────────────────

  /// Mostrado na hora, quando a poupança que acabou de ser feita fecha o
  /// objetivo. Não faz sentido agendar uma coisa que já aconteceu.
  static Future<void> notifyGoalCompleted({
    required NotificationPrefsState prefs,
    required Desire desire,
  }) async {
    if (!prefs.goalCompletedEnabled) return;

    await NotificationService.showNow(
      id: NotificationService.goalDoneId(desire.id),
      title: tr('notifications.goal_completed_title'),
      body: tr('notifications.goal_completed_body', {
        'name': desire.name,
        'amount': AppCurrency.format(desire.price),
      }),
    );
  }
}
