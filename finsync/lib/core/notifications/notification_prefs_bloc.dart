import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPrefsBloc
    extends Bloc<NotificationPrefsEvent, NotificationPrefsState> {
  static const _goalCompletedKey = 'notif_goal_completed';
  static const _expenseReminderKey = 'notif_expense_reminder';

  NotificationPrefsBloc() : super(const NotificationPrefsState()) {
    on<LoadNotificationPrefsEvent>(_onLoad);
    on<ToggleGoalCompletedEvent>(_onToggleGoalCompleted);
    on<ToggleExpenseReminderEvent>(_onToggleExpenseReminder);
  }

  Future<void> _onLoad(
    LoadNotificationPrefsEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    emit(
      NotificationPrefsState(
        goalCompletedEnabled: prefs.getBool(_goalCompletedKey) ?? true,
        expenseReminderEnabled: prefs.getBool(_expenseReminderKey) ?? true,
      ),
    );
  }

  Future<void> _onToggleGoalCompleted(
    ToggleGoalCompletedEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalCompletedKey, event.value);
    emit(state.copyWith(goalCompletedEnabled: event.value));
  }

  Future<void> _onToggleExpenseReminder(
    ToggleExpenseReminderEvent event,
    Emitter<NotificationPrefsState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_expenseReminderKey, event.value);
    emit(state.copyWith(expenseReminderEnabled: event.value));
  }
}
