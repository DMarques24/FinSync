import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/locale/app_locale.dart';
import 'package:finsync/core/locale/locale_bloc.dart';
import 'package:finsync/core/locale/locale_event.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/profile/components/language_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguagePickerSheet extends StatelessWidget {
  const LanguagePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currentType = context.watch<LocaleBloc>().state.type;

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

            Text(tr('profile.language_title'), style: AppTextStyles.headingMedium),

            const SizedBox(height: 6),

            Text(
              tr('profile.language_subtitle'),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            for (final type in AppLocaleType.values)
              LanguageOption(
                type: type,
                selected: type == currentType,
                onTap: () {
                  context.read<LocaleBloc>().add(ChangeLocaleEvent(type));
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
