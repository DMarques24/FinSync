import 'package:finsync/core/theme/colors.dart';
import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            size: 80,
            color: AppColors.primary,
          ),

          const SizedBox(height: 20),

          const Text(
            "Bem-vindo ao FinSync 👋",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          Text(
            "A tua nova app para organizares as tuas finanças, controlares "
            "despesas e alcançares os teus objetivos com mais clareza.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
