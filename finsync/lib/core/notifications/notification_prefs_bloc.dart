import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:finsync/core/notifications/notification_prefs_store.dart';
import 'package:finsync/core/notifications/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefsBloc
    extends Bloc<NotificationPrefsEvent, NotificationPrefsState> {
  NotificationPrefsBloc() : super(const NotificationPrefsState()) {
    on<LoadNotificationPrefsEvent>(_onLoad);
    on<ToggleNotificationPrefEvent>(_onToggle);
    on<SetDailyLogTimeEvent>(_onSetDailyLogTime);
  }

  Future<void> _onLoad(
    LoadNotificationPrefsEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    emit(await NotificationPrefsStore.load());
  }

  Future<void> _onToggle(
    ToggleNotificationPrefEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    // A autorização é pedida ao ligar o primeiro aviso. Pedi-la no arranque
    // da app, antes de a pessoa perceber para que serve, é a melhor forma
    // de levar com um "não" definitivo.
    if (event.value && !state.hasAnyEnabled) {
      await NotificationService.requestPermission();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(event.pref.storageKey, event.value);

    emit(_apply(event.pref, event.value));
  }

  Future<void> _onSetDailyLogTime(
    SetDailyLogTimeEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      NotificationPrefsStore.dailyLogTimeKey,
      event.minutesSinceMidnight,
    );

    emit(state.copyWith(dailyLogMinutes: event.minutesSinceMidnight));
  }

  NotificationPrefsState _apply(NotificationPref pref, bool value) {
    switch (pref) {
      case NotificationPref.goalCompleted:
        return state.copyWith(goalCompletedEnabled: value);
      case NotificationPref.eventReminder:
        return state.copyWith(eventReminderEnabled: value);
      case NotificationPref.dailyLog:
        return state.copyWith(dailyLogEnabled: value);
      case NotificationPref.overspend:
        return state.copyWith(overspendEnabled: value);
      case NotificationPref.goalSaving:
        return state.copyWith(goalSavingEnabled: value);
    }
  }
}
