import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:flutter/material.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardCashFlow extends StatelessWidget {
  final double cashIn;
  final double cashOut;
  final double profileBalance;

  const CardCashFlow({
    super.key,
    required this.cashIn,
    required this.cashOut,
    this.profileBalance = 0,
  });

  @override
  Widget build(BuildContext context) {
    final balance = profileBalance - cashOut;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),

        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: .25),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                ),
              ),

              const Spacer(),

              PopupMenuButton<TimeFilter>(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onSelected: (filter) {
                  context.read<HomeBloc>().add(
                    GetFilterTimeExpensesEvent(filter),
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: TimeFilter.lastDay,
                    child: Text('Last day'),
                  ),
                  PopupMenuItem(
                    value: TimeFilter.last7Days,
                    child: Text('Last 7 days'),
                  ),
                  PopupMenuItem(
                    value: TimeFilter.last30Days,
                    child: Text('Last 30 days'),
                  ),
                  PopupMenuItem(
                    value: TimeFilter.last5Months,
                    child: Text('Last 5 months'),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            "Saldo Atual",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 8),

          Text(
            AppCurrency.format(balance),
            style: AppTextStyles.headingLarge.copyWith(
              color: Colors.white,
              fontSize: 38,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.arrow_downward_rounded,
                  title: "Receitas",
                  value: cashIn,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _InfoCard(
                  icon: Icons.arrow_upward_rounded,
                  title: "Despesas",
                  value: cashOut,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),

        borderRadius: BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: Colors.white70)),

          const SizedBox(height: 6),

          Text(
            AppCurrency.format(value),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
