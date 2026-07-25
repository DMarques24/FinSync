import 'package:flutter/material.dart';

import 'package:finsync/core/currency/app_currency.dart';

/// Pequeno cartão usado dentro do [CardCashFlow] para mostrar um resumo
/// (receitas/despesas) sobre o fundo em gradiente do cartão principal.
class CashFlowInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final Color color;

  const CashFlowInfoCard({
    super.key,
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
