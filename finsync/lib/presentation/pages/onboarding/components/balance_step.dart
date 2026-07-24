import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BalanceStep extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;

  const BalanceStep({required this.controller, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.savings_rounded, size: 80, color: AppColors.primary),

          const SizedBox(height: 20),

          const Text(
            "Qual é o teu saldo atual? 💰",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Vamos usar este valor como ponto de partida para "
            "acompanhares as tuas finanças.",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 32),

          TextFormField(
            controller: controller,
            enabled: !isLoading,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d{0,2}')),
            ],
            decoration: InputDecoration(
              labelText: "Saldo atual (${AppCurrency.symbol})",
              prefixIcon: Icon(AppCurrency.icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
