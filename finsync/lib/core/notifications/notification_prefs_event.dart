abstract class NotificationPrefsEvent {}

class LoadNotificationPrefsEvent extends NotificationPrefsEvent {}

/// Alterar uma preferência. Um evento só, com a chave a dizer qual — cinco
/// eventos praticamente iguais não acrescentavam nada.
class ToggleNotificationPrefEvent extends NotificationPrefsEvent {
  final NotificationPref pref;
  final bool value;

  ToggleNotificationPrefEvent(this.pref, this.value);
}

class SetDailyLogTimeEvent extends NotificationPrefsEvent {
  final int minutesSinceMidnight;

  SetDailyLogTimeEvent(this.minutesSinceMidnight);
}

enum NotificationPref {
  goalCompleted,
  eventReminder,
  dailyLog,
  overspend,
  goalSaving;

  String get storageKey => 'notif_$name';

  String get titleKey => 'notifications.${name}_title';
  String get subtitleKey => 'notifications.${name}_subtitle';
}
