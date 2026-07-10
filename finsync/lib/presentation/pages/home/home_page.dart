import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

import 'package:finsync/presentation/pages/home/componente/card_cash_flow.dart';
import 'package:finsync/presentation/pages/home/componente/expenses_list.dart';

import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    context.read<HomeBloc>().add(GetAllExpensesEvent());
  }

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

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeErrorState) {
              return Center(child: Text(state.message));
            }

            double cashOut = 0;
            double cashIn = 0;

            if (state is HomeLoadedState) {
              cashOut = state.expenses.fold(
                0,
                (sum, expense) => sum + expense.price,
              );
            }

            return SingleChildScrollView(
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

                  CardCashFlow(cashIn: cashIn, cashOut: cashOut),

                  const SizedBox(height: 30),

                  if (state is HomeLoadedState)
                    ExpensesList(expenses: state.expenses),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
