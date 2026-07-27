import 'package:finsync/core/notifications/notification_prefs_bloc.dart';
import 'package:finsync/core/notifications/notification_prefs_event.dart';
import 'package:finsync/core/notifications/notification_prefs_state.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/profile/components/notification_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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

              const SizedBox(height: 24),

              Text("Notificações", style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                "Escolhe que avisos queres receber.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Estas preferências ficam guardadas neste dispositivo. "
                        "O envio de notificações push chega numa atualização "
                        "futura.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              BlocBuilder<NotificationPrefsBloc, NotificationPrefsState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      NotificationToggle(
                        icon: Icons.flag_rounded,
                        title: "Objetivos concluídos",
                        subtitle:
                            "Avisar quando atingires o valor de um desejo.",
                        value: state.goalCompletedEnabled,
                        onChanged: (value) => context
                            .read<NotificationPrefsBloc>()
                            .add(ToggleGoalCompletedEvent(value)),
                      ),
                      const SizedBox(height: 12),
                      NotificationToggle(
                        icon: Icons.event_repeat_rounded,
                        title: "Lembretes de despesas",
                        subtitle:
                            "Lembrar de despesas e eventos recorrentes do "
                            "calendário.",
                        value: state.expenseReminderEnabled,
                        onChanged: (value) => context
                            .read<NotificationPrefsBloc>()
                            .add(ToggleExpenseReminderEvent(value)),
                      ),
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
}
