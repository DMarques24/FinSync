/// Preferências de avisos, guardadas só no dispositivo.
///
/// Não vão para a base de dados de propósito: os avisos são agendados
/// localmente, por isso quem precisa de os conhecer é este telemóvel.
class NotificationPrefsState {
  /// Aviso quando um objetivo fica completo.
  final bool goalCompletedEnabled;

  /// Aviso na véspera de cada evento do calendário.
  final bool eventReminderEnabled;

  /// Lembrete diário para registar gastos.
  final bool dailyLogEnabled;

  /// Hora do lembrete diário, em minutos desde a meia-noite. Guardado
  /// assim, e não como `TimeOfDay`, porque é o que cabe num inteiro nas
  /// preferências.
  final int dailyLogMinutes;

  /// Aviso quando o mês atual está bastante acima da média.
  final bool overspendEnabled;

  /// Lembrete mensal de quanto poupar por objetivo.
  final bool goalSavingEnabled;

  const NotificationPrefsState({
    this.goalCompletedEnabled = true,
    this.eventReminderEnabled = true,
    this.dailyLogEnabled = false,
    this.dailyLogMinutes = 20 * 60,
    this.overspendEnabled = true,
    this.goalSavingEnabled = true,
  });

  /// Alguma coisa ligada? Se não, não vale a pena pedir autorização ao
  /// sistema nem correr o agendamento.
  bool get hasAnyEnabled =>
      goalCompletedEnabled ||
      eventReminderEnabled ||
      dailyLogEnabled ||
      overspendEnabled ||
      goalSavingEnabled;

  int get dailyLogHour => dailyLogMinutes ~/ 60;
  int get dailyLogMinute => dailyLogMinutes % 60;

  NotificationPrefsState copyWith({
    bool? goalCompletedEnabled,
    bool? eventReminderEnabled,
    bool? dailyLogEnabled,
    int? dailyLogMinutes,
    bool? overspendEnabled,
    bool? goalSavingEnabled,
  }) {
    return NotificationPrefsState(
      goalCompletedEnabled: goalCompletedEnabled ?? this.goalCompletedEnabled,
      eventReminderEnabled: eventReminderEnabled ?? this.eventReminderEnabled,
      dailyLogEnabled: dailyLogEnabled ?? this.dailyLogEnabled,
      dailyLogMinutes: dailyLogMinutes ?? this.dailyLogMinutes,
      overspendEnabled: overspendEnabled ?? this.overspendEnabled,
      goalSavingEnabled: goalSavingEnabled ?? this.goalSavingEnabled,
    );
  }
}
