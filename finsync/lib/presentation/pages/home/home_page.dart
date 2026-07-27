import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/expense.dart';

import 'package:finsync/presentation/pages/home/components/card_cash_flow.dart';
import 'package:finsync/presentation/pages/home/components/expenses_list.dart';

import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/presentation/pages/home/home_state.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:finsync/presentation/pages/profile/profile_state.dart';

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
      for (var i = 1; i <= 12; i++) tr('common.month_$i'),
    ];

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoadingState) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              );
            }

            if (state is HomeErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_off_rounded,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: () => context.read<HomeBloc>().add(
                          GetAllExpensesEvent(),
                        ),
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(tr('home.retry')),
                      ),
                    ],
                  ),
                ),
              );
            }

            double cashOut = 0;
            double cashIn = 0;
            double profileBalance = 0;

            if (state is HomeLoadedState) {
              cashOut = state.expenses
                  .where((expense) => expense.type == ExpenseType.despesa)
                  .fold(0, (sum, expense) => sum + expense.price);

              cashIn = state.expenses
                  .where((expense) => expense.type == ExpenseType.receita)
                  .fold(0, (sum, expense) => sum + expense.price);
            }

            final profileState = context.watch<ProfileBloc>().state;
            String username = '';
            if (profileState is ProfileLoadedState) {
              username = profileState.user.username;
              profileBalance = profileState.user.balance;
            }

            return RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: () async {
                context.read<HomeBloc>().add(GetAllExpensesEvent());
                context.read<ProfileBloc>().add(LoadProfileEvent());
              },
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isNotEmpty
                        ? tr('home.greeting_named', {'name': username})
                        : tr('home.greeting'),
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

                  CardCashFlow(
                    cashIn: cashIn,
                    cashOut: cashOut,
                    profileBalance: profileBalance,
                  ),

                  const SizedBox(height: 30),

                  if (state is HomeLoadedState)
                    ExpensesList(expenses: state.expenses),
                ],
              ),
              ),
            );
          },
        ),
      ),
    );
  }
}
