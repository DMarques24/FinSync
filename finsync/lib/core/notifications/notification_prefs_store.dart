import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Leitura das preferências de avisos, fora do bloco.
///
/// O bloco serve o ecrã de definições, mas quem agenda os avisos corre no
/// arranque e ao guardar uma poupança — sítios onde o bloco pode ainda não
/// ter carregado. Ler das preferências é a única fonte que está sempre
/// pronta.
class NotificationPrefsStore {
  NotificationPrefsStore._();

  static const dailyLogTimeKey = 'notif_daily_log_minutes';

  static Future<NotificationPrefsState> load() async {
    final prefs = await SharedPreferences.getInstance();

    bool read(NotificationPref pref, {bool fallback = true}) =>
        prefs.getBool(pref.storageKey) ?? fallback;

    return NotificationPrefsState(
      goalCompletedEnabled: read(NotificationPref.goalCompleted),
      eventReminderEnabled: read(NotificationPref.eventReminder),
      dailyLogEnabled: read(NotificationPref.dailyLog, fallback: false),
      dailyLogMinutes: prefs.getInt(dailyLogTimeKey) ?? 20 * 60,
      overspendEnabled: read(NotificationPref.overspend),
      goalSavingEnabled: read(NotificationPref.goalSaving),
    );
  }
}
