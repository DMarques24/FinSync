class NotificationPrefsState {
  final bool goalCompletedEnabled;
  final bool expenseReminderEnabled;

  const NotificationPrefsState({
    this.goalCompletedEnabled = true,
    this.expenseReminderEnabled = true,
  });

  NotificationPrefsState copyWith({
    bool? goalCompletedEnabled,
    bool? expenseReminderEnabled,
  }) {
    return NotificationPrefsState(
      goalCompletedEnabled: goalCompletedEnabled ?? this.goalCompletedEnabled,
      expenseReminderEnabled:
          expenseReminderEnabled ?? this.expenseReminderEnabled,
    );
  }
}
