import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/home/componente/card_cash_flow.dart';
import 'package:finsync/presentation/pages/home/componente/expenses_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final months = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Olá, Diogo 👋",
              style: AppTextStyles.headingLarge.copyWith(fontSize: 30),
            ),

            const SizedBox(height: 6),

            Text(
              "${now.day} ${months[now.month]}",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 28),

            const CardCashFlow(cashIn: 1000, cashOut: 20),

            const SizedBox(height: 30),

            const ExpensesList(),
          ],
        ),
      ),
    );
  }
}
