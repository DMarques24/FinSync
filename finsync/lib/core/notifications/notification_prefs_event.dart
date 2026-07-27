abstract class NotificationPrefsEvent {}

class LoadNotificationPrefsEvent extends NotificationPrefsEvent {}

class ToggleGoalCompletedEvent extends NotificationPrefsEvent {
  final bool value;

  ToggleGoalCompletedEvent(this.value);
}

class ToggleExpenseReminderEvent extends NotificationPrefsEvent {
  final bool value;

  ToggleExpenseReminderEvent(this.value);
}
