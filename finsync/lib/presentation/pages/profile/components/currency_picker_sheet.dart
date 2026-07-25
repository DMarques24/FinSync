import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/currency/currency_bloc.dart';
import 'package:finsync/core/currency/currency_event.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/profile/components/currency_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyPickerSheet extends StatelessWidget {
  const CurrencyPickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currentType = context.watch<CurrencyBloc>().state.type;

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

              Text("Moeda", style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                "Escolhe a moeda usada em toda a app.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              for (final type in AppCurrencyType.values)
                CurrencyOption(
                  type: type,
                  selected: type == currentType,
                  onTap: () {
                    context.read<CurrencyBloc>().add(ChangeCurrencyEvent(type));
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
