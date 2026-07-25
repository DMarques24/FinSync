import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/core/theme/theme_bloc.dart';
import 'package:finsync/core/theme/theme_event.dart';
import 'package:finsync/presentation/pages/profile/components/theme_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMode = context.watch<ThemeBloc>().state.mode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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

            Text("Tema", style: AppTextStyles.headingMedium),

            const SizedBox(height: 6),

            Text(
              "Escolhe a aparência da app.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            ThemeOption(
              icon: Icons.light_mode_outlined,
              label: "Claro",
              selected: currentMode == ThemeMode.light,
              onTap: () {
                context.read<ThemeBloc>().add(
                  ChangeThemeEvent(ThemeMode.light),
                );
                Navigator.pop(context);
              },
            ),

            ThemeOption(
              icon: Icons.dark_mode_outlined,
              label: "Escuro",
              selected: currentMode == ThemeMode.dark,
              onTap: () {
                context.read<ThemeBloc>().add(
                  ChangeThemeEvent(ThemeMode.dark),
                );
                Navigator.pop(context);
              },
            ),

            ThemeOption(
              icon: Icons.brightness_auto_outlined,
              label: "Automático (sistema)",
              selected: currentMode == ThemeMode.system,
              onTap: () {
                context.read<ThemeBloc>().add(
                  ChangeThemeEvent(ThemeMode.system),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
