import 'dart:async';

import 'package:finsync/core/di/injection.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/notifications/notification_prefs_bloc.dart';
import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/usecases/reschedule_notifications.dart';
import 'package:finsync/presentation/pages/profile/components/notification_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  static const _icons = {
    NotificationPref.goalCompleted: Icons.flag_rounded,
    NotificationPref.eventReminder: Icons.event_available_rounded,
    NotificationPref.dailyLog: Icons.edit_calendar_rounded,
    NotificationPref.overspend: Icons.trending_up_rounded,
    NotificationPref.goalSaving: Icons.savings_rounded,
  };

  bool _valueOf(NotificationPrefsState state, NotificationPref pref) {
    switch (pref) {
      case NotificationPref.goalCompleted:
        return state.goalCompletedEnabled;
      case NotificationPref.eventReminder:
        return state.eventReminderEnabled;
      case NotificationPref.dailyLog:
        return state.dailyLogEnabled;
      case NotificationPref.overspend:
        return state.overspendEnabled;
      case NotificationPref.goalSaving:
        return state.goalSavingEnabled;
    }
  }

  /// Cada alteração obriga a refazer o agendamento — desligar um aviso tem
  /// de o cancelar já, não só deixar de o criar da próxima vez.
  void _reschedule() {
    unawaited(
      sl<RescheduleNotifications>()().catchError((_) {
        // Fica para a próxima abertura da app.
      }),
    );
  }

  Future<void> _pickDailyTime(
    BuildContext context,
    NotificationPrefsState state,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: state.dailyLogHour,
        minute: state.dailyLogMinute,
      ),
    );

    if (picked == null || !context.mounted) return;

    context.read<NotificationPrefsBloc>().add(
      SetDailyLogTimeEvent(picked.hour * 60 + picked.minute),
    );
    _reschedule();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                tr('notifications.title'),
                style: AppTextStyles.headingMedium,
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                tr('notifications.subtitle'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .08),
                  borderRadius: AppRadius.all(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        tr('notifications.local_note'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              BlocBuilder<NotificationPrefsBloc, NotificationPrefsState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      for (final pref in NotificationPref.values) ...[
                        NotificationToggle(
                          icon: _icons[pref]!,
                          title: tr(pref.titleKey),
                          subtitle: tr(pref.subtitleKey),
                          value: _valueOf(state, pref),
                          onChanged: (value) {
                            context.read<NotificationPrefsBloc>().add(
                              ToggleNotificationPrefEvent(pref, value),
                            );
                            _reschedule();
                          },
                        ),

                        // A hora só aparece com o lembrete diário ligado —
                        // escolher a hora de uma coisa desligada não quer
                        // dizer nada.
                        if (pref == NotificationPref.dailyLog &&
                            state.dailyLogEnabled)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                            ),
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDailyTime(context, state),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(
                                  double.infinity,
                                  AppSizes.minTouchTarget,
                                ),
                                side: BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.all(AppRadius.sm),
                                ),
                              ),
                              icon: Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: AppColors.secondary,
                              ),
                              label: Text(
                                tr('notifications.daily_log_at', {
                                  'time': _formatTime(state),
                                }),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: AppSpacing.md),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(NotificationPrefsState state) {
    final hour = state.dailyLogHour.toString().padLeft(2, '0');
    final minute = state.dailyLogMinute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
